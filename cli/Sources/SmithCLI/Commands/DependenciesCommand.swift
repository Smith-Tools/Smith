import Foundation
import ArgumentParser
import SmithBuildAnalysis
import SmithOutputFormatter
import SmithErrorHandling
import SmithProgress

// MARK: - Dependencies Command

struct DependenciesCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "dependencies",
        abstract: "Unified dependency analysis for Xcode and SPM projects",
        discussion: """
        Analyzes project dependencies automatically detecting both Xcode and SPM projects.
        Shows dependency trees, circular dependencies, outdated packages, and conflicts.

        This command automatically detects project types and provides unified analysis
        for both Xcode projects and Swift Package Manager projects.

        Examples:
          smith dependencies                      # Analyze current directory
          smith dependencies ~/Projects/MyApp/    # Analyze specific project
          smith dependencies --tree               # Show dependency tree
          smith dependencies --circular           # Check for circular deps
          smith dependencies --outdated           # Show outdated packages
          smith dependencies --format=json        # JSON output
        """
    )

    @Argument(help: "Path to analyze (default: current directory)")
    var path: String = "."

    @Flag(name: .long, help: "Show dependency tree")
    var tree = false

    @Flag(name: .long, help: "Check for circular dependencies")
    var circular = false

    @Flag(name: .long, help: "Show outdated packages")
    var outdated = false

    @Flag(name: .long, help: "Check for dependency conflicts")
    var conflicts = false

    @Option(name: .long, help: "Output format: summary|tree|json|dot|mermaid (default: summary)")
    var format: String = "summary"

    @Flag(name: .long, help: "Show which tools are being used")
    var verbose = false

    func run() throws {
        let output = SmithCLIOutput()
        output.section("DEPENDENCY ANALYSIS")

        // Validate and resolve path
        let resolvedPath = try ErrorHandler.processToolResult(
            ErrorHandler.validateProjectPath(path),
            format: format
        )

        output.info("Path: \(resolvedPath)")
        output.info("Detecting project types...")

        // Detect all project types in the directory
        let projectTypes = detectAllProjectTypes(at: resolvedPath)

        if projectTypes.isEmpty {
            output.error("No supported projects found at \(resolvedPath)")
            output.info("Supported: Xcode projects (.xcodeproj, .xcworkspace) and Swift Packages (Package.swift)")
            throw ExitCode.failure
        }

        // Analyze each detected project
        var hasXcodeProject = false
        var hasSPMProject = false

        for projectType in projectTypes {
            switch projectType {
            case .xcodeProject, .xcodeWorkspace:
                hasXcodeProject = true
            case .spm:
                hasSPMProject = true
            case .unknown:
                continue
            }
        }

        output.info("Found: \(hasXcodeProject ? "Xcode " : "")\(hasXcodeProject && hasSPMProject ? "+ " : "")\(hasSPMProject ? "Swift Package " : "")")

        // Run Xcode dependency analysis if found
        if hasXcodeProject {
            output.info("")
            print("XCODE DEPENDENCY ANALYSIS")
            try analyzeXcodeDependencies(at: resolvedPath)
        }

        // Run SPM dependency analysis if found
        if hasSPMProject {
            output.info("")
            print("SWIFT PACKAGE DEPENDENCY ANALYSIS")
            try analyzeSPMDependencies(at: resolvedPath)
        }

        // Show summary if multiple project types
        if hasXcodeProject && hasSPMProject {
            output.info("")
            print("COMBINED SUMMARY")
            output.info("✅ Analysis complete for both Xcode and Swift Package dependencies")
            output.info("💡 Use 'smith xcode dependencies' or 'smith spm dependencies' for detailed analysis")
        }
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

    private func analyzeXcodeDependencies(at path: String) throws {
        if verbose {
            print("🔧 Analyzing Xcode dependencies...")
        }

        // Use smith-xcsift if available, otherwise do basic analysis
        if let xcsiftPath = findSmithXCSiftPath() {
            var arguments = ["analyze"]

            // Add format-specific arguments
            if tree { arguments.append("--tree") }
            if circular { arguments.append("--circular") }
            if !format.isEmpty && format != "summary" { arguments.append("--format=\(format)") }

            let process = Process()
            process.executableURL = URL(fileURLWithPath: xcsiftPath)
            process.arguments = arguments

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            try process.run()
            process.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""

            if process.terminationStatus == 0 {
                if !output.isEmpty {
                    print(output)
                }
            } else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                print("⚠️  Xcode dependency analysis failed: \(errorOutput)")

                // Fall back to basic analysis
                performBasicXcodeDependencyAnalysis(at: path)
            }
        } else {
            if verbose {
                print("⚠️  smith-xcsift not found, using basic analysis")
            }
            performBasicXcodeDependencyAnalysis(at: path)
        }
    }

    private func analyzeSPMDependencies(at path: String) throws {
        if verbose {
            print("🔧 Analyzing Swift Package dependencies...")
        }

        // Check if smith-spmsift is available
        if let spmsiftPath = findSmithSPMSiftPath() {
            var arguments = ["dependencies", path]

            // Add format-specific arguments
            if tree { arguments.append("--tree") }
            if outdated { arguments.append("--outdated") }
            if conflicts { arguments.append("--conflicts") }
            if !format.isEmpty && format != "summary" { arguments.append("--format=\(format)") }

            let process = Process()
            process.executableURL = URL(fileURLWithPath: spmsiftPath)
            process.arguments = arguments

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            try process.run()
            process.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""

            if process.terminationStatus == 0 {
                if !output.isEmpty {
                    print(output)
                } else {
                    print("✅ No Swift Package dependencies found")
                }
            } else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                print("⚠️  Swift Package dependency analysis failed: \(errorOutput)")

                // Fall back to basic analysis
                performBasicSPMDependencyAnalysis(at: path)
            }
        } else {
            if verbose {
                print("⚠️  smith-spmsift not found, using basic analysis")
            }
            performBasicSPMDependencyAnalysis(at: path)
        }
    }

    private func performBasicXcodeDependencyAnalysis(at path: String) {
        print("📊 Basic Xcode Dependency Analysis")
        print("==================================")

        // Look for .xcodeproj files
        let fileManager = FileManager.default
        var projectCount = 0

        if let contents = try? fileManager.contentsOfDirectory(atPath: path) {
            for item in contents {
                if item.hasSuffix(".xcodeproj") {
                    projectCount += 1
                    print("📁 Project: \(item)")
                }
            }
        }

        if projectCount == 0 {
            print("ℹ️  No Xcode projects found")
        } else {
            print("✅ Found \(projectCount) Xcode project(s)")
            print("💡 Install smith-xcsift for detailed dependency analysis")
        }
    }

    private func performBasicSPMDependencyAnalysis(at path: String) {
        print("📦 Basic Swift Package Dependency Analysis")
        print("=========================================")

        let packagePath = (path as NSString).appendingPathComponent("Package.swift")
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: packagePath) {
            print("✅ Swift Package found: Package.swift")

            // Try to parse basic Package.swift info
            if let packageContent = try? String(contentsOfFile: packagePath) {
                let lines = packageContent.components(separatedBy: .newlines)
                var inDependencies = false
                var depCount = 0

                for line in lines {
                    if line.contains(".dependencies") {
                        inDependencies = true
                        continue
                    }
                    if inDependencies && line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "]") {
                        inDependencies = false
                        continue
                    }
                    if inDependencies && (line.contains(".package(") || line.contains(".target(")) {
                        depCount += 1
                    }
                }

                print("📊 Dependencies detected: \(depCount)")
                print("💡 Install smith-spmsift for detailed dependency analysis")
            }
        } else {
            print("ℹ️  No Swift Package found")
        }
    }
}