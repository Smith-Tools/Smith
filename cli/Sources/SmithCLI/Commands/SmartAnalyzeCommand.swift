import Foundation
import ArgumentParser
import SBDiagnostics
import SmithOutputFormatter
import SmithErrorHandling
import SmithProgress

// MARK: - Smart Analyze Command

struct SmartAnalyze: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Smart project analysis with automatic tool detection",
        discussion: """
        Automatically detects project type and delegates to the most appropriate tool.
        
        This command analyzes your project and determines whether to use:
        • smith-validation for TCA architecture validation
        • smith-xcsift for Xcode project analysis  
        • smith-sbsift for Swift build analysis
        • smith-spmsift for Swift Package Manager analysis
        
        Examples:
          smith smart-analyze                    # Analyze current directory
          smith smart-analyze ~/Projects/MyApp/  # Analyze specific project
          smith smart-analyze --format=json      # JSON output
        """
    )

    @Argument(help: "Path to analyze (default: current directory)")
    var path: String = "."

    @Option(name: .long, help: "Output format: auto|json|summary|detailed|compact|minimal (default: auto)")
    var format: String = "auto"

    @Flag(name: .long, help: "Include detailed diagnostics")
    var verbose = false

    @Option(name: .long, help: "Force specific tool instead of auto-detection")
    var forceTool: String?

    func run() throws {
        let output = SmithCLIOutput()
        output.section("SMART PROJECT ANALYSIS")

        // Validate and resolve path
        let resolvedPath = try ErrorHandler.processToolResult(
            ErrorHandler.validateProjectPath(path),
            format: format
        )

        output.info("Path: \(resolvedPath)")
        output.info("Detecting project type...")

        // Auto-detect project type
        let projectType = ProjectDetector.detectProjectType(at: resolvedPath)
        output.info("Project Type: \(formatProjectType(projectType))")

        // Determine best tool for analysis
        let recommendedTool = determineBestTool(for: projectType, forceTool: forceTool)
        output.info("Recommended Tool: \(recommendedTool.name)")

        if verbose {
            output.info("Description: \(recommendedTool.description)")
        }

        // Execute analysis with recommended tool
        let result = try executeAnalysis(with: recommendedTool, at: resolvedPath, format: format)

        displayResults(result, tool: recommendedTool, projectType: projectType, verbose: verbose)
    }

    private func determineBestTool(for projectType: ProjectType, forceTool: String?) -> ToolRecommendation {
        // Force specific tool if requested
        if let forcedTool = forceTool?.lowercased() {
            switch forcedTool {
            case "validation", "smith-validation":
                return ToolRecommendation(
                    name: "smith-validation",
                    command: "validate",
                    description: "TCA architecture validation",
                    confidence: 1.0,
                    requiresPath: true
                )
            case "xcode", "smith-xcsift":
                return ToolRecommendation(
                    name: "smith-xcsift",
                    command: "analyze",
                    description: "Xcode project analysis",
                    confidence: 1.0,
                    requiresPath: true
                )
            case "swift", "smith-sbsift":
                return ToolRecommendation(
                    name: "smith-sbsift",
                    command: "analyze",
                    description: "Swift build analysis",
                    confidence: 1.0,
                    requiresPath: true
                )
            case "spm", "smith-spmsift":
                return ToolRecommendation(
                    name: "smith-spmsift",
                    command: "analyze",
                    description: "Swift Package Manager analysis",
                    confidence: 1.0,
                    requiresPath: true
                )
            default:
                print("⚠️  Unknown tool: \(forcedTool). Using auto-detection.")
            }
        }

        // Auto-detect best tool based on project type
        switch projectType {
        case .xcodeWorkspace, .xcodeProject:
            return ToolRecommendation(
                name: "smith-xcsift",
                command: "analyze",
                description: "Xcode project analysis",
                confidence: 0.95,
                requiresPath: true
            )
        case .spm:
            return ToolRecommendation(
                name: "smith-spmsift",
                command: "analyze", 
                description: "Swift Package Manager analysis",
                confidence: 0.90,
                requiresPath: true
            )
        case .unknown:
            // For unknown types, try Swift analysis as fallback
            return ToolRecommendation(
                name: "smith-sbsift",
                command: "analyze",
                description: "Swift build analysis (fallback)",
                confidence: 0.60,
                requiresPath: true
            )
        }
    }

    private func executeAnalysis(with tool: ToolRecommendation, at path: String, format: String) throws -> AnalysisResult {
        // Use the centralized error handling
        let toolResult = ErrorHandler.checkToolAvailability(tool.name, format: format)
        
        switch toolResult {
        case .success(let toolPath):
            // Build command arguments
            var arguments = [tool.command, path]
            if format.lowercased() == "json" {
                arguments.append("--json")
            }

            // Execute tool using centralized handling
            let executionResult = ErrorHandler.executeTool(
                toolName: tool.name,
                toolPath: toolPath,
                arguments: arguments,
                format: format
            )

            switch executionResult {
            case .success(let result):
                return AnalysisResult(
                    success: result.success,
                    output: result.output,
                    error: result.error,
                    tool: tool.name,
                    confidence: tool.confidence
                )
            case .failure(let error):
                ErrorDisplayManager.displayError(error, format: format.lowercased() == "json" ? .json : .human)
                return AnalysisResult(
                    success: false,
                    output: "",
                    error: error.userMessage,
                    tool: tool.name,
                    confidence: tool.confidence
                )
            }
        case .failure(let error):
            ErrorDisplayManager.displayError(error, format: format.lowercased() == "json" ? .json : .human)
            return AnalysisResult(
                success: false,
                output: "",
                error: error.userMessage,
                tool: tool.name,
                confidence: tool.confidence
            )
        }
    }

    private func displayResults(_ result: AnalysisResult, tool: ToolRecommendation, projectType: ProjectType, verbose: Bool) {
        let output = SmithCLIOutput()

        if format.lowercased() == "json" {
            outputJSON(result, tool: tool)
        } else {
            outputSummary(result, tool: tool, projectType: projectType)
        }

        // Show additional recommendations for non-JSON output
        if format.lowercased() != "json" && !verbose {
            output.info("")
            output.info("💡 Run with --verbose for detailed diagnostics")
            output.info("💡 Use --format=json for machine-readable output")
        }
    }

    private func outputJSON(_ result: AnalysisResult, tool: ToolRecommendation) {
        let output: [String: Any] = [
            "success": result.success,
            "tool": result.tool,
            "confidence": result.confidence,
            "output": result.output,
            "error": result.error as Any
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: output),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
    }

    private func outputSummary(_ result: AnalysisResult, tool: ToolRecommendation, projectType: ProjectType) {
        let status = result.success ? "✅" : "❌"
        let output = SmithCLIOutput()
        output.info("")
        output.info("📋 ANALYSIS RESULTS")
        output.info("===================")
        output.info("Status: \(status) \(result.success ? "Success" : "Failed")")
        output.info("Tool: \(result.tool)")
        output.info("Confidence: \(Int(result.confidence * 100))%")

        if let error = result.error, !error.isEmpty {
            output.error("Error: \(error)")
        }

        if !result.output.isEmpty {
            output.info("")
            output.info("📄 OUTPUT:")
            output.info(result.output)
        }

        // Success recommendations
        if result.success {
            print("")
            print("🎯 RECOMMENDATIONS")
            print("==================")
            
            switch projectType {
            case .xcodeWorkspace, .xcodeProject:
                print("• Use 'smith xcode analyze' for detailed Xcode analysis")
                print("• Use 'smith xcode monitor' for build monitoring")
                print("• Consider 'smith validate' for TCA architecture validation")
            case .spm:
                print("• Use 'smith spm analyze' for detailed dependency analysis")
                print("• Use 'smith spm dependencies' for dependency tree")
                print("• Consider 'smith validate' for TCA architecture validation")
            case .unknown:
                print("• Verify project structure and dependencies")
                print("• Consider running 'smith detect' for more details")
                print("• Use specific tools: smith swift, smith spm, smith xcode")
            }
        }
    }

    private func findToolPath(_ toolName: String) -> String? {
        return ErrorHandler.findToolPath(toolName)
    }
}

// MARK: - Supporting Types

struct ToolRecommendation {
    let name: String
    let command: String
    let description: String
    let confidence: Double
    let requiresPath: Bool
}

struct AnalysisResult: Codable {
    let success: Bool
    let output: String
    let error: String?
    let tool: String
    let confidence: Double
}

// MARK: - Helper Functions

private func formatProjectType(_ type: ProjectType) -> String {
    switch type {
    case .spm: return "Swift Package Manager"
    case .xcodeProject(let project): return "Xcode Project (\(project))"
    case .xcodeWorkspace(let workspace): return "Xcode Workspace (\(workspace))"
    case .unknown: return "Unknown"
    }
}

