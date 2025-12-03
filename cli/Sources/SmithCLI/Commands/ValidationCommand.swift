import Foundation
import ArgumentParser
import SmithOutputFormatter
import SmithErrorHandling
import SmithProgress

// MARK: - Validation Wrapper Command

struct Validation: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "TCA architecture validation using smith-validation",
        discussion: """
        Validates Swift projects for TCA (The Composable Architecture) compliance.
        
        This command delegates to smith-validation for comprehensive architectural analysis
        including dependency injection patterns, reducer organization, and best practices.
        
        Examples:
          smith validate MyApp/
          smith validate . --level=comprehensive --format=json
          smith validate ~/Projects/MyFeature --deep --config=rules.json
        """
    )

    @Argument(help: "Path to project directory (default: current directory)")
    var path: String = "."

    @Flag(name: .long, help: "Perform deep validation including all files")
    var deep = false

    @Option(name: .long, help: "Validation level: critical|standard|comprehensive (default: critical)")
    var level: String = "critical"

    @Option(name: .long, help: "Output format: auto|json|summary|detailed|compact|minimal (default: auto)")
    var format: String = "auto"

    @Option(name: .long, help: "PKL configuration file path")
    var configPath: String?

    func run() throws {
        let output = SmithCLIOutput()
        output.section("TCA ARCHITECTURAL VALIDATION")

        let resolvedPath = (path as NSString).standardizingPath
        output.info("Project: \(URL(fileURLWithPath: resolvedPath).lastPathComponent)")
        output.info("Level: \(level.capitalized)")
        output.info("Format: \(format.capitalized)")

        if deep {
            output.info("Deep validation: Enabled")
        }
        if let configPath = configPath {
            output.info("Config: \(configPath)")
        }

        // Check if smith-validation is available
        guard let validationPath = findSmithValidationPath() else {
            let error = SmithErrorHandling.ResourceError(
                code: "SMITH_TOOL_001",
                message: "smith-validation tool not found",
                technicalDetails: "Could not locate smith-validation in PATH or common installation directories",
                suggestedActions: ["Install smith-validation using: brew install smith-tools", "Check that smith-validation is in your PATH"],
                isFatal: true
            )
            SmithErrorDisplay.display(error, format: .human)
            throw ExitCode.failure
        }

        output.info("Running TCA validation...")

        // Use progress indicator for better UX in TTY environments
        let progress = SmithProgress()
        if isatty(STDOUT_FILENO) != 0 {
            progress.start(title: "Validating TCA architecture", style: .spinner)
        }

        // Build smith-validation command arguments
        var arguments = [resolvedPath, "--level=\(level)", "--format=\(format)"]
        if deep {
            arguments.append("--deep")
        }
        if let configPath = configPath {
            arguments.append("--config=\(configPath)")
        }

        // Execute smith-validation
        let result = try executeSmithValidation(path: validationPath, arguments: arguments)

        progress.finish(success: result.success, finalMessage: "TCA validation completed")

        // Handle output based on format with TTY awareness
        let outputFormatter = SmithOutputFormatter()
        let resolvedFormat: SmithOutputFormatter.Format

        switch format.lowercased() {
        case "json": resolvedFormat = .json
        case "summary": resolvedFormat = .summary
        case "detailed": resolvedFormat = .detailed
        case "compact": resolvedFormat = .compact
        case "minimal": resolvedFormat = .minimal
        default: resolvedFormat = .auto
        }

        if resolvedFormat == .json || resolvedFormat == .auto && !outputFormatter.isTTY {
            // Pass through JSON directly
            print(result.output)
        } else {
            // Process summary format with enhanced output
            processSummaryOutput(result.output, level: level, success: result.success)
        }

        if !result.success {
            output.error("Validation completed with issues")
            throw ExitCode.failure
        } else {
            output.success("TCA validation completed successfully")
        }
    }

    private func executeSmithValidation(path: String, arguments: [String]) throws -> (success: Bool, output: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""

            return (success: process.terminationStatus == 0, output: output)
        } catch {
            let error = ToolError.toolExecutionFailed(toolName: "smith-validation", error: error)
            ErrorDisplayManager.displayError(error, format: format.lowercased() == "json" ? .json : .human)
            return (success: false, output: "")
        }
    }

    private func processSummaryOutput(_ output: String, level: String, success: Bool) {
        print("")
        print("📋 VALIDATION SUMMARY")
        print("====================")
        
        // Try to parse as JSON for enhanced formatting
        if let jsonData = output.data(using: .utf8),
           let validationResult = try? JSONDecoder().decode(ValidationResult.self, from: jsonData) {
            
            print("Project: \(URL(fileURLWithPath: validationResult.projectPath).lastPathComponent)")
            print("Status: \(success ? "✅ Success" : "⚠️ Issues Found")")
            print("Files Analyzed: \(validationResult.summary.totalFiles)")
            print("Violations Found: \(validationResult.summary.violationsCount)")
            
            if !validationResult.findings.isEmpty {
                print("")
                print("🚨 VIOLATIONS BREAKDOWN")
                print("=======================")
                let criticalCount = validationResult.findings.filter { $0.severity == "critical" }.count
                let highCount = validationResult.findings.filter { $0.severity == "high" }.count
                let mediumCount = validationResult.findings.filter { $0.severity == "medium" }.count
                let lowCount = validationResult.findings.filter { $0.severity == "low" }.count

                if criticalCount > 0 { print("Critical: \(criticalCount)") }
                if highCount > 0 { print("High: \(highCount)") }
                if mediumCount > 0 { print("Medium: \(mediumCount)") }
                if lowCount > 0 { print("Low: \(lowCount)") }
                
                print("")
                print("📝 RECOMMENDATIONS")
                print("==================")
                print("• Review critical issues first")
                print("• Consider automated fixes where available")
                print("• See TCA documentation: https://smith-tools.dev/docs/tca-rules")
            }
        } else {
            // Fallback to raw output
            print(output)
        }
    }

}

// MARK: - JSON Response Structures

struct ValidationResult: Codable {
    let analysisType: String
    let projectPath: String
    let summary: ValidationSummary
    let findings: [ValidationFinding]
}

struct ValidationSummary: Codable {
    let totalFiles: Int
    let violationsCount: Int
    let healthScore: Int
}

struct ValidationFinding: Codable {
    let severity: String
    let file: String?
    let line: Int?
    let message: String
    let rule: String?
}

// Note: Helper functions 'which()' and 'findSmith*' are now in Utilities.swift