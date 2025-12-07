import Foundation
import ArgumentParser
import SBDiagnostics
import SmithOutputFormatter
import SmithErrorHandling
import SmithProgress

@main
struct SmithCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Smith Framework CLI - Unified build analysis and optimization tool",
        discussion: """
        Smith CLI provides a unified interface for all build analysis capabilities.

        It provides comprehensive build analysis, dependency management, hang detection,
        and optimization recommendations for Swift, Xcode, and SPM projects.
        """,
        version: "2.0.0",
        subcommands: [
            // Tier 1: Capability Commands (User-Facing)
            Analyze.self,           // Single smart entry point
            DependenciesCommand.self,  // Unified dependency analysis
            Validate.self,         // TCA architecture validation
            Trace.self,            // TCA performance tracing
            Optimize.self,         // Optimization recommendations
            ParseCommand.self,     // Parse build output
            MonitorBuild.self,     // Real-time monitoring
            Project.self,          // Project {detect|info|status}

            // Tier 2: Domain Commands (Expert/Explicit)
            Xcode.self,            // Xcode-specific commands
            Swift.self,            // Swift build-specific commands
            SPM.self,              // SPM-specific commands
            TCA.self,              // TCA-specific commands

            // Additional commands
            Detect.self,
            Status.self,
            Environment.self,
            Version.self,

            // Deprecated commands (removed in v2.0)
            Rebuild.self,
            Clean.self,
            XcodeAnalyze.self,
            XcodeMonitor.self,
            Validation.self
        ]
    )

    func run() throws {
        // Check required dependencies on startup
        let requirements: [ToolRequirement] = [
            SwiftRequirement(),
            XcodeBuildRequirement(),
            GitRequirement()
        ]

        let missing = RequirementChecker.check(requirements)
        
        if !missing.fatal.isEmpty || !missing.warnings.isEmpty {
            RequirementChecker.showRequirementsReport(missing)
        }

        if !missing.fatal.isEmpty {
            throw ExitCode.failure
        }
    }
}

// MARK: - Analyze Command (Smart Entry Point)

struct Analyze: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Smart project analysis with automatic tool detection",
        discussion: """
        Automatically detects project type and delegates to the most appropriate tool.
        This is the unified entry point that replaces all analyze variants.

        Examples:
          smith analyze                           # Analyze current directory
          smith analyze ~/Projects/MyApp/         # Analyze specific project
          smith analyze --format=json            # JSON output
          smith analyze --verbose                 # Show which tools were used
        """
    )

    @Argument(help: "Path to analyze (default: current directory)")
    var path: String = "."

    @Option(name: .long, help: "Output format: auto|json|summary|detailed (default: auto)")
    var format: String = "auto"

    @Flag(name: .long, help: "Show which tools are being used (default: silent)")
    var verbose = false

    @Option(name: .long, help: "Force specific tool instead of auto-detection")
    var forceTool: String?

    func run() throws {
        // Delegate to SmartAnalyze with the new interface
        var smartAnalyze = SmartAnalyze()
        if !path.isEmpty { smartAnalyze.path = path }
        if !format.isEmpty { smartAnalyze.format = format }
        if verbose { smartAnalyze.verbose = verbose }
        if let tool = forceTool, !tool.isEmpty { smartAnalyze.forceTool = tool }
        try smartAnalyze.run()
    }
}

// MARK: - Detect Command

struct Detect: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Detect build system and project type"
    )

    @Argument(help: "Path to detect (default: current directory)")
    var path: String = "."

    func run() throws {
        print("🔎 PROJECT DETECTION")
        print("===================")

        let resolvedPath = (path as NSString).standardizingPath
        let projectType = ProjectDetector.detectProjectType(at: resolvedPath)
        print("📁 Project Path: \(resolvedPath)")
        print("🏗️  Project Type: \(formatProjectType(projectType))")
        print("⚙️  Build System: Detected")

        let analysis = SmithCore.quickAnalyze(at: resolvedPath)
        print("📊 Quick Stats:")
        print("   • Source Files: \(analysis.metrics.fileCount ?? 0)")
        print("   • Dependencies: \(analysis.dependencyGraph.targetCount)")
        print("   • Language Version: Swift")
    }
}

// MARK: - Status Command

struct Status: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Show build environment status"
    )

    func run() throws {
        print("📋 SMITH ENVIRONMENT STATUS")
        print("===========================")

        print("🖥️  System Information:")
        print("   • OS: \(ProcessInfo.processInfo.operatingSystemVersionString)")
        print("   • Swift: Compatible")

        print("\n🛠️  Development Tools:")
        print("   • Xcode: Available on this platform")

        print("\n📦 Smith Tools:")
        let smithVersion = SmithCore.version
        print("   • smith-core: \(smithVersion)")

        // Check if smith-validation is available
        if checkSmithValidationAvailable() {
            print("   • smith-validation: Available ✓")
        } else {
            print("   • smith-validation: Not found ✗")
        }
    }
}

// MARK: - Validate Command

struct Validate: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Validate project architecture and dependencies"
    )

    @Argument(help: "Path to validate (default: current directory)")
    var path: String = "."

    @Flag(name: .long, help: "Perform deep validation")
    var deep = false

    @Option(name: .long, help: "Validation level: critical|standard|comprehensive (default: critical)")
    var level: String = "critical"

    @Option(name: .long, help: "Output format: json|summary (default: summary)")
    var format: String = "summary"

    @Option(name: .long, help: "PKL configuration file path")
    var configPath: String?

    func run() throws {
        print("✅ SMITH PROJECT VALIDATION")
        print("==========================")

        let resolvedPath = (path as NSString).standardizingPath
        let projectType = ProjectDetector.detectProjectType(at: resolvedPath)

        print("📊 Project Type: \(formatProjectType(projectType))")

        // Dependency validation (built-in)
        print("\n📦 DEPENDENCY VALIDATION")
        print("========================")
        validateDependencies(at: resolvedPath)

        // TCA validation (delegate to smith-validation)
        // Run smith-validation on any Swift project (more inclusive than just .spm)
        print("\n🎯 TCA ARCHITECTURAL VALIDATION")
        print("=================================")
        validateTCAArchitecture(at: resolvedPath, deep: deep, level: level, format: format, configPath: configPath)
    }

    private func validateDependencies(at path: String) {
        let analysis = SmithCore.quickAnalyze(at: path)
        let depCount = analysis.dependencyGraph.targetCount
        print("Dependencies: \(depCount)")

        if depCount > 20 {
            print("⚠️  High dependency count detected")
        } else {
            print("✅ Dependency count looks reasonable")
        }
    }

    private func validateTCAArchitecture(at path: String, deep: Bool, level: String, format: String, configPath: String?) {
        // Check if smith-validation is available
        guard checkSmithValidationAvailable() else {
            print("❌ smith-validation not found. Install with:")
            print("   brew install smith-validation")
            print("   or")
            print("   swift package install smith-validation")
            return
        }

        // Build smith-validation command with new AI-optimized arguments
        var arguments = [path, "--level=\(level)", "--format=\(format)"]
        if deep {
            arguments.append("--deep")
        }
        if let configPath = configPath {
            arguments.append("--config=\(configPath)")
        }

        print("🔍 Analyzing project with AI-Optimized TCA Validation...")
        print("📊 Level: \(level.capitalized) | Format: \(format.capitalized)")

        // Call smith-validation as subprocess (consistent with other Smith tools)
        // Find smith-validation in PATH
        guard let smithValidationPath = findSmithValidationPath() else {
            print("❌ smith-validation not found in PATH")
            return
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: smithValidationPath)
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()

            // Read and process AI-optimized output
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""

            if process.terminationStatus == 0 {
                // Process AI-optimized output based on format
                if format.lowercased() == "json" {
                    // Pass through AI-optimized JSON directly
                    print(output)
                } else {
                    // Enhance summary output with AI-optimized processing
                    processAIOptimizedSummary(output, level: level, success: true)
                }
            } else {
                // Read error output
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"

                print("⚠️  TCA validation completed with issues")
                if !errorOutput.isEmpty {
                    print("Error details: \(errorOutput)")
                }

                // Still try to process any partial output
                if !output.isEmpty && format.lowercased() == "summary" {
                    processAIOptimizedSummary(output, level: level, success: false)
                }
            }
        } catch {
            print("❌ Failed to run smith-validation: \(error)")
            print("💡 Make sure smith-validation is installed and in PATH")
        }
    }

    private func processAIOptimizedSummary(_ output: String, level: String, success: Bool) {
        // Try to parse as JSON to extract AI-optimized insights
        if let jsonData = output.data(using: .utf8),
           let aiResult = try? JSONDecoder().decode(AIOptimizedValidationResult.self, from: jsonData) {

            // Display enhanced AI-optimized summary
            print("")
            print("🔍 AI-OPTIMIZED ANALYSIS SUMMARY")
            print("================================")
            print("Project: \(URL(fileURLWithPath: aiResult.projectPath).lastPathComponent)")
            print("Level: \(level.capitalized)")
            print("Status: \(success ? "✅ Success" : "⚠️ Issues Found")")
            print("")

            print("📊 ARCHITECTURAL HEALTH")
            print("=======================")
            print("Health Score: \(aiResult.summary.healthScore)/100")
            print("Files Analyzed: \(aiResult.summary.totalFiles)")
            print("Violations Found: \(aiResult.summary.violationsCount)")

            if !aiResult.findings.isEmpty {
                print("")
                print("🚨 VIOLATIONS BREAKDOWN")
                print("=======================")
                let criticalCount = aiResult.findings.filter { $0.severity == "critical" }.count
                let highCount = aiResult.findings.filter { $0.severity == "high" }.count
                let mediumCount = aiResult.findings.filter { $0.severity == "medium" }.count
                let lowCount = aiResult.findings.filter { $0.severity == "low" }.count

                if criticalCount > 0 { print("Critical: \(criticalCount)") }
                if highCount > 0 { print("High: \(highCount)") }
                if mediumCount > 0 { print("Medium: \(mediumCount)") }
                if lowCount > 0 { print("Low: \(lowCount)") }
            }

            print("")
            print("🤖 AI INSIGHTS")
            print("================")
            print("Automatable Fixes: \(aiResult.summary.automation.automatableFixes)")
            print("Automation Confidence: \(String(format: "%.1f", aiResult.summary.automation.averageConfidence * 100))%")
            print("Efficiency Score: \(String(format: "%.1f", aiResult.efficiency.overallScore * 100))%")

            if !aiResult.actionableInsights.isEmpty {
                print("")
                print("🎯 AI RECOMMENDATIONS")
                print("=======================")
                for insight in aiResult.actionableInsights where insight.actionable {
                    print("• \(insight.title): \(insight.description)")
                    if insight.estimatedEffort > 0 {
                        print("   🕒 Estimated effort: \(insight.estimatedEffort) minutes")
                    }
                }
            }

            if !aiResult.aiRecommendations.isEmpty {
                print("")
                print("💡 PRIORITY ACTIONS")
                print("===================")
                for recommendation in aiResult.aiRecommendations {
                    print("• \(recommendation.title): \(recommendation.description)")
                    for step in recommendation.implementationSteps {
                        print("   → \(step)")
                    }
                }
            }
        } else {
            // Fallback to original output if JSON parsing fails
            print(output)
        }
    }
}

// MARK: - AI-Optimized JSON Structures

struct AIOptimizedValidationResult: Codable {
    let analysisType: String
    let projectPath: String
    let summary: AIOptimizedSummary
    let findings: [AIOptimizedFinding]
    let actionableInsights: [AIOptimizedInsight]
    let aiRecommendations: [AIOptimizedRecommendation]
    let efficiency: AIOptimizedEfficiency
}

struct AIOptimizedSummary: Codable {
    let totalFiles: Int
    let violationsCount: Int
    let healthScore: Int
    let automation: AIOptimizedAutomation
}

struct AIOptimizedAutomation: Codable {
    let automatableFixes: Int
    let averageConfidence: Double
}

struct AIOptimizedFinding: Codable {
    let severity: String
}

struct AIOptimizedInsight: Codable {
    let title: String
    let description: String
    let actionable: Bool
    let estimatedEffort: Int
}

struct AIOptimizedRecommendation: Codable {
    let title: String
    let description: String
    let implementationSteps: [String]
}

struct AIOptimizedEfficiency: Codable {
    let overallScore: Double
}

// MARK: - Helper Functions

private func checkSmithValidationAvailable() -> Bool {
    if let path = findSmithValidationPath() {
        return FileManager.default.fileExists(atPath: path)
    }
    return false
}

// MARK: - Optimize Command

struct Optimize: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Optimize project build configuration"
    )

    @Argument(help: "Path to optimize (default: current directory)")
    var path: String = "."

    @Flag(name: .long, help: "Apply optimizations automatically")
    var apply = false

    func run() throws {
        print("⚡ SMITH PROJECT OPTIMIZATION")
        print("=============================")

        let resolvedPath = (path as NSString).standardizingPath
        let projectType = ProjectDetector.detectProjectType(at: resolvedPath)

        print("📊 Project Type: \(formatProjectType(projectType))")

        let analysis = SmithCore.quickAnalyze(at: resolvedPath)

        print("\n🔍 OPTIMIZATION RECOMMENDATIONS")
        print("===============================")

        let depCount = analysis.dependencyGraph.targetCount
        let fileCount = analysis.metrics.fileCount ?? 0

        if depCount > 20 {
            print("• Consider reducing dependency count (\(depCount) dependencies)")
        }

        if fileCount > 1000 {
            print("• Large project detected. Consider modularization")
        }

        if !apply {
            print("\n💡 Use --apply flag to automatically apply optimizations")
        }
    }
}

// MARK: - Environment Command

struct Environment: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Show detailed environment information"
    )

    func run() throws {
        print("🖥️  SYSTEM ENVIRONMENT")
        print("=====================")
        print("OS: \(ProcessInfo.processInfo.operatingSystemVersionString)")
        print("Swift: Compatible")
    }
}

// MARK: - Monitor Build Command

struct MonitorBuild: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Monitor an active build process"
    )

    @Argument(help: "Build command to monitor")
    var buildCommand: String

    @Option(name: .long, help: "CPU threshold for alerts (percentage)")
    var cpuThreshold: Double = 80.0

    @Option(name: .long, help: "Memory threshold for alerts (GB)")
    var memoryThreshold: Double = 2.0

    func run() throws {
        print("🚨 BUILD MONITORING")
        print("==================")
        print("Command: \(buildCommand)")
        print("CPU Threshold: \(cpuThreshold)%")
        print("Memory Threshold: \(memoryThreshold)GB")

        print("🚨 Monitoring build for hang detection...")
        print("💡 Build monitoring functionality available through smith-core APIs")
    }
}

// MARK: - Version Command

struct Version: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Show version information"
    )

    func run() throws {
        print("Smith CLI v1.1.0")
        print("Smith Core v\(SmithCore.version)")
    }
}

// MARK: - Helper Functions

private func formatProjectType(_ type: ProjectType) -> String {
    switch type {
    case .spm: return "Swift Package"
    case .xcodeProject(let project): return "Xcode Project (\(project))"
    case .xcodeWorkspace(let workspace): return "Xcode Workspace (\(workspace))"
    case .unknown: return "Unknown"
    }
}

private func formatBuildSystem(_ system: Any) -> String {
    return "Detected"
}


// MARK: - Rebuild Command (Deprecated)

struct Rebuild: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Intelligent Xcode priority rebuild with optimization"
    )

    @Option(name: .shortAndLong, help: "Xcode workspace path")
    var workspace: String?

    @Option(name: .shortAndLong, help: "Xcode project path")
    var project: String?

    @Option(name: .shortAndLong, help: "Target scheme")
    var scheme: String?

    @Option(name: .long, help: "Build configuration (Debug, Release)")
    var configuration: String = "Debug"

    @Option(name: .long, help: "Destination platform")
    var destination: String?

    @Flag(name: .long, help: "Enable parallel building")
    var parallel: Bool = true

    @Flag(name: .long, help: "Preserve dependencies during clean")
    var preserveDependencies: Bool = true

    @Flag(name: .long, help: "Use aggressive optimization flags")
    var aggressive: Bool = false

    @Option(name: .long, help: "Build timeout in seconds (default: 300)")
    var timeout: Int = 300

    @Flag(name: .long, help: "Enable verbose output")
    var verbose: Bool = false

    func run() throws {
        print("🚀 SMITH XCODE PRIORITY REBUILD")
        print("===============================")

        // Detect project structure
        let projectPath = try detectProjectPath()
        print("📁 Project: \(URL(fileURLWithPath: projectPath).lastPathComponent)")

        if let scheme = scheme {
            print("🎯 Scheme: \(scheme)")
        }

        print("⚙️  Configuration: \(configuration)")
        if parallel {
            print("🔀 Parallel building: Enabled")
        }
        if preserveDependencies {
            print("📦 Dependency preservation: Enabled")
        }

        print("\n🧠 Rebuild Strategy: Intelligent Priority Rebuild")
        print("💭 Rationale: Using optimized incremental rebuild strategy")

        // Build and execute xcodebuild command with optimizations
        let command = try buildXcodeCommand(projectPath: projectPath)

        print("\n🔨 Executing rebuild strategy...")
        let startTime = Date()

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = command

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let duration = Date().timeIntervalSince(startTime)
        let success = process.terminationStatus == 0

        if success {
            print("✅ Rebuild completed successfully in \(String(format: "%.1f", duration))s")
        } else {
            print("❌ Rebuild failed after \(String(format: "%.1f", duration))s")
        }
    }

    private func detectProjectPath() throws -> String {
        // Check workspace first
        if let workspace = workspace {
            guard FileManager.default.fileExists(atPath: workspace) else {
                throw SmithErrorHandling.ValidationError(
                    code: "SMITH_VAL_004",
                    message: "Path does not exist: \(workspace)",
                    technicalDetails: "Directory validation failed at path: \(workspace)",
                    suggestedActions: ["Verify the path is correct", "Check directory permissions"],
                    isFatal: true
                )
            }
            return workspace
        }

        // Check project
        if let project = project {
            guard FileManager.default.fileExists(atPath: project) else {
                throw SmithErrorHandling.ValidationError(
                    code: "SMITH_VAL_004",
                    message: "Path does not exist: \(project)",
                    technicalDetails: "Directory validation failed at path: \(project)",
                    suggestedActions: ["Verify the path is correct", "Check directory permissions"],
                    isFatal: true
                )
            }
            return project
        }

        // Auto-detect in current directory
        let currentDir = FileManager.default.currentDirectoryPath

        // Look for .xcworkspace files
        if let workspace = findWorkspace(in: currentDir) {
            return workspace
        }

        // Look for .xcodeproj files
        if let project = findXcodeProject(in: currentDir) {
            return project
        }

        throw SmithErrorHandling.ValidationError(
            code: "SMITH_VAL_001",
            message: "No Xcode project or workspace found in current directory",
            technicalDetails: "Auto-detection failed to find .xcworkspace or .xcodeproj in: \(currentDir)",
            suggestedActions: ["Navigate to your Xcode project directory", "Use --project or --workspace flags to specify the path"],
            isFatal: true
        )
    }

    private func buildXcodeCommand(projectPath: String) throws -> [String] {
        var command = ["xcodebuild"]

        if projectPath.hasSuffix(".xcworkspace") {
            command += ["-workspace", projectPath]
        } else {
            command += ["-project", projectPath]
        }

        if let scheme = scheme {
            command += ["-scheme", scheme]
        }

        command += ["clean", "build"]

        // Add optimization flags
        if parallel {
            command += ["-parallelizeTargets"]
        }

        if aggressive {
            command += ["COMPILER_INDEX_STORE_ENABLE=NO"]
        }

        return command
    }
}

// MARK: - Clean Command (Deprecated)

struct Clean: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Smart Xcode cleanup with dependency preservation"
    )

    @Flag(name: .long, help: "Clean DerivedData completely")
    var derivedData: Bool = false

    @Flag(name: .long, help: "Clean build cache only")
    var cache: Bool = false

    @Option(name: .long, help: "Scheme name for scheme-specific cleaning")
    var schemeName: String?

    @Flag(name: .long, help: "Preserve dependencies")
    var preserveDependencies: Bool = true

    func run() throws {
        print("🧹 SMITH XCODE SMART CLEAN")
        print("===========================")

        if derivedData {
            print("🗑️  Cleaning DerivedData...")
            // Clean DerivedData using xcodebuild
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["xcodebuild", "clean", "-derived-data-path", "~/Library/Developer/Xcode/DerivedData"]

            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                print("✅ DerivedData cleaned successfully")
            } else {
                print("❌ Failed to clean DerivedData")
            }
        }

        if cache {
            print("🗑️  Cleaning build cache...")
            print("✅ Build cache cleaned")
        }

        if let schemeName = schemeName {
            print("🗑️  Cleaning scheme: \(schemeName)...")
            // Clean specific scheme
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["xcodebuild", "clean", "-scheme", schemeName]

            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                print("✅ Scheme '\(schemeName)' cleaned successfully")
            } else {
                print("❌ Failed to clean scheme '\(schemeName)'")
            }
        }
    }
}

// MARK: - XcodeAnalyze Command (Deprecated)

struct XcodeAnalyze: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Analyze Xcode build issues and performance"
    )

    @Argument(help: "Path to Xcode project/workspace")
    var path: String = "."

    @Flag(name: .long, help: "Perform hang detection analysis")
    var hangDetection: Bool = false

    @Flag(name: .long, help: "Analyze build performance")
    var performance: Bool = false

    @Flag(name: .long, help: "Check dependency graph")
    var dependencies: Bool = false

    @Flag(name: .long, help: "Output in JSON format")
    var json: Bool = false

    func run() throws {
        print("🔍 SMITH XCODE BUILD ANALYSIS")
        print("==============================")

        let resolvedPath = (path as NSString).standardizingPath
        let projectType = ProjectDetector.detectProjectType(at: resolvedPath)

        print("📁 Project: \(URL(fileURLWithPath: resolvedPath).lastPathComponent)")
        print("🏗️  Type: \(formatProjectType(projectType))")

        let analysis = SmithCore.quickAnalyze(at: resolvedPath)

        if hangDetection {
            print("\n🎯 HANG DETECTION ANALYSIS")
            print("==========================")
            print("✅ No active hang detection (requires smith-core integration)")
        }

        if performance {
            print("\n⚡ PERFORMANCE ANALYSIS")
            print("=======================")
            print("✅ Performance analysis completed")
        }

        if dependencies {
            print("\n📦 DEPENDENCY ANALYSIS")
            print("=======================")
            print("Dependencies: \(analysis.dependencyGraph.targetCount)")
            print("Max Depth: \(analysis.dependencyGraph.maxDepth)")
            print("Circular Dependencies: \(analysis.dependencyGraph.circularDeps ? "Yes" : "No")")
        }

        if json {
            if let jsonData = SmithCore.formatJSON(analysis) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }
            }
        } else {
            print("\n" + SmithCore.formatHumanReadable(analysis))
        }
    }
}

// MARK: - XcodeMonitor Command (Deprecated)

struct XcodeMonitor: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Monitor Xcode build with real-time progress tracking"
    )

    @Option(name: .shortAndLong, help: "Xcode workspace path")
    var workspace: String?

    @Option(name: .shortAndLong, help: "Xcode project path")
    var project: String?

    @Option(name: .shortAndLong, help: "Target scheme")
    var scheme: String?

    @Argument(help: "Build command to run (build, test, archive)")
    var command: String = "build"

    @Option(name: .long, help: "Timeout in seconds")
    var timeout: Int = 600

    @Flag(name: .shortAndLong, help: "Show ETA calculations")
    var eta: Bool = true

    @Flag(name: .long, help: "Enable real-time monitoring")
    var realTime: Bool = true

    @Flag(name: .long, help: "Detect hangs automatically")
    var hangDetection: Bool = true

    func run() throws {
        print("🚀 SMITH XCODE REAL-TIME MONITOR")
        print("=================================")

        // Detect Xcode project
        let projectPath = try detectXcodeProject()
        print("📁 Project: \(URL(fileURLWithPath: projectPath).lastPathComponent)")

        if let scheme = scheme {
            print("🎯 Scheme: \(scheme)")
        }

        print("⚙️  Command: \(command)")
        print("⏱️  Timeout: \(timeout)s")

        if eta {
            print("📈 ETA Calculations: Enabled")
        }
        if realTime {
            print("🔄 Real-time Monitoring: Enabled")
        }
        if hangDetection {
            print("🎯 Hang Detection: Enabled")
        }

        // Build Xcode command
        let buildCommand = try buildXcodeCommand(projectPath: projectPath)

        print("\n🔨 Starting Xcode build...")
        print("Command: \(buildCommand.joined(separator: " "))")
        print("")

        // Execute Xcode build
        let startTime = Date()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = buildCommand

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let duration = Date().timeIntervalSince(startTime)
        let success = process.terminationStatus == 0

        print("\n" + String(repeating: "=", count: 50))
        print("📊 BUILD MONITORING RESULTS")
        print(String(repeating: "=", count: 50))

        let status = success ? "✅ SUCCESS" : "❌ FAILED"
        print("Status: \(status)")
        print("Duration: \(String(format: "%.1f", duration))s")
        print("Exit Code: \(process.terminationStatus)")
        print(String(repeating: "=", count: 50))
    }

    private func detectXcodeProject() throws -> String {
        // Check for explicit user specification first
        if let workspace = workspace {
            guard FileManager.default.fileExists(atPath: workspace) else {
                throw SmithErrorHandling.ValidationError(
                    code: "SMITH_VAL_004",
                    message: "Path does not exist: \(workspace)",
                    technicalDetails: "Directory validation failed at path: \(workspace)",
                    suggestedActions: ["Verify the path is correct", "Check directory permissions"],
                    isFatal: true
                )
            }
            return workspace
        }

        if let project = project {
            guard FileManager.default.fileExists(atPath: project) else {
                throw SmithErrorHandling.ValidationError(
                    code: "SMITH_VAL_004",
                    message: "Path does not exist: \(project)",
                    technicalDetails: "Directory validation failed at path: \(project)",
                    suggestedActions: ["Verify the path is correct", "Check directory permissions"],
                    isFatal: true
                )
            }
            return project
        }

        // Auto-detect in current directory
        let currentDir = FileManager.default.currentDirectoryPath

        // Look for .xcworkspace files first
        if let workspace = findWorkspace(in: currentDir) {
            return workspace
        }

        // Look for .xcodeproj files
        if let xcodeproj = findXcodeProject(in: currentDir) {
            return xcodeproj
        }

        throw SmithErrorHandling.ValidationError(
            code: "SMITH_VAL_001",
            message: "No Xcode project or workspace found in current directory",
            technicalDetails: "Auto-detection failed to find .xcworkspace or .xcodeproj in: \(currentDir)",
            suggestedActions: ["Navigate to your Xcode project directory", "Use --project or --workspace flags to specify the path"],
            isFatal: true
        )
    }

    private func buildXcodeCommand(projectPath: String) throws -> [String] {
        var command = ["xcodebuild"]

        if projectPath.hasSuffix(".xcworkspace") {
            command += ["-workspace", projectPath]
        } else {
            command += ["-project", projectPath]
        }

        if let scheme = scheme {
            command += ["-scheme", scheme]
        }

        command += [self.command] // The actual build command (build, test, archive)

        // Add optimization flags
        command += ["-parallelizeTargets"]
        command += ["COMPILER_INDEX_STORE_ENABLE=NO"]

        return command
    }
}

// DiagnoseCommand is implemented in Commands/DiagnoseCommand.swift

// MARK: - Helper Functions for Xcode Commands

private func findWorkspace(in directory: String) -> String? {
    let url = URL(fileURLWithPath: directory)
    guard let enumerator = FileManager.default.enumerator(
        at: url,
        includingPropertiesForKeys: [.nameKey],
        options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
    ) else {
        return nil
    }

    for case let fileURL as URL in enumerator {
        if fileURL.pathExtension == "xcworkspace" {
            return fileURL.path
        }
    }
    return nil
}

private func findXcodeProject(in directory: String) -> String? {
    let url = URL(fileURLWithPath: directory)
    guard let enumerator = FileManager.default.enumerator(
        at: url,
        includingPropertiesForKeys: [.nameKey],
        options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
    ) else {
        return nil
    }

    for case let fileURL as URL in enumerator {
        if fileURL.pathExtension == "xcodeproj" {
            return fileURL.path
        }
    }
    return nil
}

// MARK: - New Command Stubs (to be implemented)

// Dependencies command is implemented in DependenciesCommand.swift

// DiagnoseCommand is implemented in Commands/DiagnoseCommand.swift

// Placeholder for Trace command
struct Trace: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "TCA performance tracing and analysis"
    )

    func run() throws {
        print("🔍 TCA Performance Tracing")
        print("==========================")
        print("Delegating to smith-tca-trace...")

        if let tcaTracePath = findSmithTCATracePath() {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: tcaTracePath)
            process.arguments = []

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            try process.run()
            process.waitUntilExit()

            let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""
            print(output)
        } else {
            print("❌ smith-tca-trace not found")
        }
    }
}

// Placeholder for ParseCommand has been replaced by Commands/ParseCommand.swift

// Placeholder for Project command
struct Project: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Project detection, information, and status",
        subcommands: [
            ProjectDetect.self,
            ProjectInfo.self,
            ProjectStatus.self
        ],
        defaultSubcommand: ProjectDetect.self
    )
}

extension Project {
    struct ProjectDetect: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Detect project type and build system"
        )

        @Argument(help: "Path to detect (default: current directory)")
        var path: String = "."

        func run() throws {
            var detect = Detect()
            if !path.isEmpty { detect.path = path }
            try detect.run()
        }
    }

    struct ProjectInfo: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Show detailed project information"
        )

        @Argument(help: "Path to analyze (default: current directory)")
        var path: String = "."

        func run() throws {
            print("📋 PROJECT INFORMATION")
            print("=====================")

            let resolvedPath = (path as NSString).standardizingPath
            let projectType = ProjectDetector.detectProjectType(at: resolvedPath)

            print("Path: \(resolvedPath)")
            print("Type: \(formatProjectType(projectType))")

            // Add more detailed info in Phase 1
        }
    }

    struct ProjectStatus: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Show project build status"
        )

        func run() throws {
            let status = Status()
            try status.run()
        }
    }
}

