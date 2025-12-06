import Foundation
import ArgumentParser
import SmithBuildAnalysis
import SmithOutputFormatter
import SmithErrorHandling
import SmithProgress

// MARK: - Diagnose Command

struct DiagnoseCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "diagnose",
        abstract: "Consolidated diagnosis for build, performance, architecture, and environment",
        discussion: """
        Comprehensive diagnosis tool that analyzes various aspects of your Swift project:
        - Build diagnosis: build issues, configuration problems
        - Performance diagnosis: slow builds, memory issues
        - Architecture diagnosis: TCA patterns, code organization
        - Environment diagnosis: tool availability, configuration

        This command auto-detects project type and uses appropriate Smith tools for analysis.

        Examples:
          smith diagnose                         # Run all diagnosis types
          smith diagnose all                      # Run all diagnosis types
          smith diagnose build                    # Build-specific diagnosis
          smith diagnose performance              # Performance analysis
          smith diagnose architecture             # Architecture validation
          smith diagnose environment              # Environment check
          smith diagnose all --format=json       # JSON output
          smith diagnose build ~/Projects/MyApp/ # Diagnose specific project
        """,
        subcommands: [
            BuildDiagnosis.self,
            PerformanceDiagnosis.self,
            ArchitectureDiagnosis.self,
            EnvironmentDiagnosis.self,
            AllDiagnosis.self
        ],
        defaultSubcommand: AllDiagnosis.self
    )
}

// MARK: - All Diagnosis (default)

struct AllDiagnosis: ParsableCommand {
    @Argument(help: "Path to analyze (default: current directory)")
    var path: String = "."

    @Option(name: .long, help: "Output format: summary|json (default: summary)")
    var format: String = "summary"

    @Flag(name: .long, help: "Show detailed output and which tools are being used")
    var verbose = false

    @Flag(name: .long, help: "Auto-fix common issues when possible")
    var autoFix = false

    func run() throws {
        let output = SmithCLIOutput()
        output.section("SMITH DIAGNOSIS")

        // Validate and resolve path
        let resolvedPath = try ErrorHandler.processToolResult(
            ErrorHandler.validateProjectPath(path),
            format: format
        )

        output.info("Path: \(resolvedPath)")

        // Detect project types
        let projectTypes = detectAllProjectTypes(at: resolvedPath)

        if projectTypes.isEmpty {
            output.error("No supported projects found at \(resolvedPath)")
            output.info("Supported: Xcode projects (.xcodeproj, .xcworkspace) and Swift Packages (Package.swift)")
            throw ExitCode.failure
        }

        // Show project info
        showProjectInfo(output: output, projectTypes: projectTypes, path: resolvedPath)

        // Run all diagnosis types
        let diagnosisTypes = ["build", "performance", "architecture", "environment"]

        // Run requested diagnosis types
        for diagnosisType in diagnosisTypes {
            print("")
            print("\(diagnosisType.uppercased()) DIAGNOSIS")
            print(String(repeating: "-", count: diagnosisType.count + 11))

            switch diagnosisType {
            case "build":
                try runBuildDiagnosis(at: resolvedPath, projectTypes: projectTypes, output: output)
            case "performance":
                try runPerformanceDiagnosis(at: resolvedPath, projectTypes: projectTypes, output: output)
            case "architecture":
                try runArchitectureDiagnosis(at: resolvedPath, projectTypes: projectTypes, output: output)
            case "environment":
                try runEnvironmentDiagnosis(output: output)
            default:
                output.warning("Unknown diagnosis type: \(diagnosisType)")
            }
        }

        // Show summary
        print("")
        print("DIAGNOSIS SUMMARY")
        print(String(repeating: "-", count: 17))
        output.success("Analysis complete")
        output.info("Use specific 'smith diagnose <type>' commands for targeted analysis")
    }
}

// MARK: - Build Diagnosis

struct BuildDiagnosis: ParsableCommand {
    @Argument(help: "Path to analyze (default: current directory)")
    var path: String = "."

    @Option(name: .long, help: "Output format: summary|json (default: summary)")
    var format: String = "summary"

    @Flag(name: .long, help: "Show detailed output and which tools are being used")
    var verbose = false

    @Flag(name: .long, help: "Auto-fix common issues when possible")
    var autoFix = false

    func run() throws {
        let output = SmithCLIOutput()
        output.section("SMITH BUILD DIAGNOSIS")

        // Validate and resolve path
        let resolvedPath = try ErrorHandler.processToolResult(
            ErrorHandler.validateProjectPath(path),
            format: format
        )

        // Detect project types
        let projectTypes = detectAllProjectTypes(at: resolvedPath)

        if projectTypes.isEmpty {
            output.error("No supported projects found at \(resolvedPath)")
            throw ExitCode.failure
        }

        // Run build diagnosis
        try runBuildDiagnosis(at: resolvedPath, projectTypes: projectTypes, output: output, verbose: verbose, autoFix: autoFix)
    }
}

// MARK: - Performance Diagnosis

struct PerformanceDiagnosis: ParsableCommand {
    @Argument(help: "Path to analyze (default: current directory)")
    var path: String = "."

    @Option(name: .long, help: "Output format: summary|json (default: summary)")
    var format: String = "summary"

    @Flag(name: .long, help: "Show detailed output and which tools are being used")
    var verbose = false

    func run() throws {
        let output = SmithCLIOutput()
        output.section("SMITH PERFORMANCE DIAGNOSIS")

        // Validate and resolve path
        let resolvedPath = try ErrorHandler.processToolResult(
            ErrorHandler.validateProjectPath(path),
            format: format
        )

        // Detect project types
        let projectTypes = detectAllProjectTypes(at: resolvedPath)

        if projectTypes.isEmpty {
            output.error("No supported projects found at \(resolvedPath)")
            throw ExitCode.failure
        }

        // Run performance diagnosis
        try runPerformanceDiagnosis(at: resolvedPath, projectTypes: projectTypes, output: output, verbose: verbose)
    }
}

// MARK: - Architecture Diagnosis

struct ArchitectureDiagnosis: ParsableCommand {
    @Argument(help: "Path to analyze (default: current directory)")
    var path: String = "."

    @Option(name: .long, help: "Output format: summary|json (default: summary)")
    var format: String = "summary"

    @Flag(name: .long, help: "Show detailed output and which tools are being used")
    var verbose = false

    func run() throws {
        let output = SmithCLIOutput()
        output.section("SMITH ARCHITECTURE DIAGNOSIS")

        // Validate and resolve path
        let resolvedPath = try ErrorHandler.processToolResult(
            ErrorHandler.validateProjectPath(path),
            format: format
        )

        // Detect project types
        let projectTypes = detectAllProjectTypes(at: resolvedPath)

        if projectTypes.isEmpty {
            output.error("No supported projects found at \(resolvedPath)")
            throw ExitCode.failure
        }

        // Run architecture diagnosis
        try runArchitectureDiagnosis(at: resolvedPath, projectTypes: projectTypes, output: output, format: format, verbose: verbose)
    }
}

// MARK: - Environment Diagnosis

struct EnvironmentDiagnosis: ParsableCommand {
    @Option(name: .long, help: "Output format: summary|json (default: summary)")
    var format: String = "summary"

    @Flag(name: .long, help: "Show detailed output and which tools are being used")
    var verbose = false

    func run() throws {
        let output = SmithCLIOutput()
        output.section("SMITH ENVIRONMENT DIAGNOSIS")

        // Run environment diagnosis
        try runEnvironmentDiagnosis(output: output, verbose: verbose)
    }
}

// MARK: - Helper Functions

private func showProjectInfo(output: SmithCLIOutput, projectTypes: [ProjectType], path: String) {
        var hasXcode = false
        var hasSPM = false

        for projectType in projectTypes {
            switch projectType {
            case .xcodeProject, .xcodeWorkspace:
                hasXcode = true
            case .spm:
                hasSPM = true
            case .unknown:
                continue
            }
        }

        output.info("Project types detected: \(hasXcode ? "Xcode " : "")\(hasXcode && hasSPM ? "+ " : "")\(hasSPM ? "Swift Package " : "")")
    }

    private func detectAllProjectTypes(at path: String) -> [ProjectType] {
        var detectedTypes: [ProjectType] = []
        let fileManager = FileManager.default

        // Check for Xcode workspace
        if let contents = try? fileManager.contentsOfDirectory(atPath: path) {
            for item in contents {
                if item.hasSuffix(".xcworkspace") {
                    detectedTypes.append(.xcodeWorkspace(workspace: item))
                } else if item.hasSuffix(".xcodeproj") {
                    detectedTypes.append(.xcodeProject(project: item))
                }
            }
        }

        // Check for SPM
        let packagePath = (path as NSString).appendingPathComponent("Package.swift")
        if fileManager.fileExists(atPath: packagePath) {
            detectedTypes.append(.spm)
        }

        return detectedTypes
    }

    // MARK: - Build Diagnosis

    private func runBuildDiagnosis(at path: String, projectTypes: [ProjectType], output: SmithCLIOutput, verbose: Bool = false, autoFix: Bool = false) throws {
        if verbose {
            output.info("🔧 Running build diagnosis...")
        }

        var hasXcode = false
        var hasSPM = false

        for projectType in projectTypes {
            switch projectType {
            case .xcodeProject, .xcodeWorkspace:
                hasXcode = true
            case .spm:
                hasSPM = true
            case .unknown:
                continue
            }
        }

        // Xcode build diagnosis
        if hasXcode {
            print("📱 Xcode Build Diagnosis")
            print(String(repeating: "-", count: 25))

            if let xcsiftPath = findSmithXCSiftPath() {
                var arguments = ["diagnose", path, "--build"]
                if autoFix { arguments.append("--auto-fix") }
                if verbose { arguments.append("--verbose") }

                let result = try runTool(xcsiftPath, arguments: arguments)
                if !result.output.isEmpty {
                    print(result.output)
                }
            } else {
                performBasicBuildDiagnosis(at: path, output: output, projectType: "Xcode")
            }
        }

        // SPM build diagnosis
        if hasSPM {
            if hasXcode { output.info("") }

            print("📦 Swift Package Build Diagnosis")
            print(String(repeating: "-", count: 32))

            if let spmsiftPath = findSmithSPMSiftPath() {
                var arguments = ["diagnose", path, "--build"]
                if autoFix { arguments.append("--auto-fix") }
                if verbose { arguments.append("--verbose") }

                let result = try runTool(spmsiftPath, arguments: arguments)
                if !result.output.isEmpty {
                    print(result.output)
                }
            } else {
                performBasicBuildDiagnosis(at: path, output: output, projectType: "Swift Package")
            }
        }
    }

    // MARK: - Performance Diagnosis

    private func runPerformanceDiagnosis(at path: String, projectTypes: [ProjectType], output: SmithCLIOutput, verbose: Bool = false) throws {
        if verbose {
            output.info("⚡ Running performance diagnosis...")
        }

        var hasXcode = false
        var hasSPM = false

        for projectType in projectTypes {
            switch projectType {
            case .xcodeProject, .xcodeWorkspace:
                hasXcode = true
            case .spm:
                hasSPM = true
            case .unknown:
                continue
            }
        }

        // Check build times and performance metrics
        print("⏱️  Build Performance Analysis")
        print(String(repeating: "-", count: 30))

        if hasXcode && hasXcodeSiftAvailable() {
            // Analyze recent build logs
            output.info("Analyzing recent build performance...")

            // Use smith-tca-trace for performance profiling if available
            if let tcaTracePath = findSmithTCATracePath() {
                let result = try runTool(tcaTracePath, arguments: ["analyze", path, "--performance"])
                if !result.output.isEmpty {
                    print(result.output)
                }
            } else {
                output.info("💡 Install smith-tca-trace for detailed performance profiling")
            }
        }

        // Memory and resource usage
        output.info("")
        print("💾 Resource Usage Check")
        print(String(repeating: "-", count: 23))

        checkResourceUsage(at: path, output: output)
    }

    // MARK: - Architecture Diagnosis

    private func runArchitectureDiagnosis(at path: String, projectTypes: [ProjectType], output: SmithCLIOutput, format: String = "summary", verbose: Bool = false) throws {
        if verbose {
            output.info("🏗️  Running architecture diagnosis...")
        }

        // TCA pattern validation
        print("🔗 TCA Pattern Analysis")
        print(String(repeating: "-", count: 24))

        if let validationPath = findSmithValidationPath() {
            var arguments = ["validate", path, "--architecture"]
            if format == "json" { arguments.append("--format=json") }

            let result = try runTool(validationPath, arguments: arguments)
            if !result.output.isEmpty {
                print(result.output)
            }
        } else {
            output.info("💡 Install smith-validation for TCA pattern analysis")
        }

        // Code organization analysis
        output.info("")
        print("📁 Code Organization")
        print(String(repeating: "-", count: 20))

        analyzeCodeOrganization(at: path, output: output)

        // Dependency structure
        output.info("")
        print("🕸️  Dependency Structure")
        print(String(repeating: "-", count: 23))

        analyzeDependencyStructure(at: path, output: output)
    }

    // MARK: - Environment Diagnosis

    private func runEnvironmentDiagnosis(output: SmithCLIOutput, verbose: Bool = false) throws {
        if verbose {
            output.info("🌍 Running environment diagnosis...")
        }

        // Tool availability check
        print("🛠️  Smith Tools Availability")
        print(String(repeating: "-", count: 27))

        checkToolAvailability(output: output)

        // Development environment check
        output.info("")
        print("🖥️  Development Environment")
        print(String(repeating: "-", count: 27))

        checkDevelopmentEnvironment(output: output)

        // Configuration check
        output.info("")
        print("⚙️  Configuration Status")
        print(String(repeating: "-", count: 24))

        checkConfiguration(output: output)
    }

    // MARK: - Helper Methods

    private func runTool(_ toolPath: String, arguments: [String]) throws -> (output: String, error: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(data: outputData, encoding: .utf8) ?? ""
        let error = String(data: errorData, encoding: .utf8) ?? ""

        return (output, error)
    }

    private func hasXcodeSiftAvailable() -> Bool {
        return findSmithXCSiftPath() != nil
    }

    // MARK: - Basic Diagnosis Methods

    private func performBasicBuildDiagnosis(at path: String, output: SmithCLIOutput, projectType: String) {
        print("Basic \(projectType) Build Check")
        print(String(repeating: "-", count: 28))

        let fileManager = FileManager.default

        // Check for common build files
        if projectType == "Xcode" {
            if let contents = try? fileManager.contentsOfDirectory(atPath: path) {
                let projectCount = contents.filter { $0.hasSuffix(".xcodeproj") || $0.hasSuffix(".xcworkspace") }.count
                output.info("✅ Found \(projectCount) \(projectType) project(s)")
            }
        } else {
            let packagePath = (path as NSString).appendingPathComponent("Package.swift")
            if fileManager.fileExists(atPath: packagePath) {
                output.info("✅ Swift Package.swift found")
            }
        }

        output.info("💡 Install smith-\(projectType.lowercased().replacingOccurrences(of: " ", with: "")) for detailed build analysis")
    }

    private func checkResourceUsage(at path: String, output: SmithCLIOutput) {
        // Check derived data size if Xcode project
        output.info("Derived data size: Not calculated (install smith-xcsift for details)")
        output.info("Build cache status: Not checked")
        output.info("Memory usage patterns: Not analyzed")
        output.info("💡 Use smith-tca-trace for detailed performance profiling")
    }

    private func analyzeCodeOrganization(at path: String, output: SmithCLIOutput) {
        let fileManager = FileManager.default
        var swiftFileCount = 0

        if let enumerator = fileManager.enumerator(atPath: path) {
            for case let file as String in enumerator {
                if file.hasSuffix(".swift") {
                    swiftFileCount += 1
                }
            }
        }

        output.info("Swift files found: \(swiftFileCount)")
        output.info("Code organization: Basic analysis only")
        output.info("💡 Install smith-validation for detailed architecture analysis")
    }

    private func analyzeDependencyStructure(at path: String, output: SmithCLIOutput) {
        output.info("External dependencies: Not analyzed")
        output.info("Internal dependencies: Not analyzed")
        output.info("Circular dependencies: Not checked")
        output.info("💡 Run 'smith dependencies' for detailed dependency analysis")
    }

    private func checkToolAvailability(output: SmithCLIOutput) {
        let tools = [
            ("smith-xcsift", findSmithXCSiftPath),
            ("smith-sbsift", findSmithSBSiftPath),
            ("smith-spmsift", findSmithSPMSiftPath),
            ("smith-validation", findSmithValidationPath),
            ("smith-tca-trace", findSmithTCATracePath)
        ]

        for (toolName, findFunction) in tools {
            if findFunction() != nil {
                output.info("✅ \(toolName): Available")
            } else {
                output.info("❌ \(toolName): Not found")
            }
        }
    }

    private func checkDevelopmentEnvironment(output: SmithCLIOutput) {
        // Check Xcode
        let xcodePath = "/Applications/Xcode.app/Contents/Developer"
        if FileManager.default.fileExists(atPath: xcodePath) {
            output.info("✅ Xcode: Installed")
        } else {
            output.info("❌ Xcode: Not found")
        }

        // Check Swift
        if which("swift") != nil {
            output.info("✅ Swift: Available")
        } else {
            output.info("❌ Swift: Not found")
        }

        // Check Git
        if which("git") != nil {
            output.info("✅ Git: Available")
        } else {
            output.info("❌ Git: Not found")
        }
    }

    private func checkConfiguration(output: SmithCLIOutput) {
        output.info("Smith configuration: Not checked")
        output.info("Environment variables: Not checked")
        output.info("Paths and permissions: Not checked")
        output.info("💡 Run specific tools for detailed configuration analysis")
    }