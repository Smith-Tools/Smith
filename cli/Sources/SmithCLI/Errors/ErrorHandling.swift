import Foundation
import ArgumentParser

// MARK: - Supporting Types

struct SmithToolResult: Codable {
    let success: Bool
    let output: String
    let tool: String
}

// MARK: - Enhanced Error Handling Utilities

struct ErrorHandler {
    
    // MARK: - Tool Path Resolution
    
    static func findToolPath(_ toolName: String) -> String? {
        // Try PATH first
        if let path = which(toolName) {
            return path
        }

        // Try common installation paths
        let commonPaths = [
            "/opt/homebrew/bin/\(toolName)",  // Apple Silicon
            "/usr/local/bin/\(toolName)",     // Intel
            "~/.local/bin/\(toolName)",       // User local
            "/usr/bin/\(toolName)"            // System
        ]

        for path in commonPaths {
            let expandedPath = NSString(string: path).expandingTildeInPath
            if FileManager.default.fileExists(atPath: expandedPath) {
                return expandedPath
            }
        }

        return nil
    }
    
    static func checkToolAvailability(_ toolName: String, format: String = "summary") -> Result<String, SmithErrorWrapper> {
        guard let toolPath = findToolPath(toolName) else {
            let error = ToolError.toolNotFound(toolName: toolName)
            return .failure(.toolError(error))
        }
        return .success(toolPath)
    }
    
    // MARK: - Process Execution
    
    static func executeTool(
        toolName: String,
        toolPath: String,
        arguments: [String],
        format: String = "summary",
        timeout: TimeInterval = 300
    ) -> Result<(success: Bool, output: String, error: String?), SmithErrorWrapper> {
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: toolPath)
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
            
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

            return .success((
                success: process.terminationStatus == 0,
                output: output,
                error: errorOutput
            ))
        } catch {
            let error = ToolError.toolExecutionFailed(toolName: toolName, error: error)
            return .failure(.toolError(error))
        }
    }
    
    // MARK: - Project Validation
    
    static func validateProjectPath(_ path: String) -> Result<String, SmithErrorWrapper> {
        let resolvedPath = (path as NSString).standardizingPath
        
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: resolvedPath, isDirectory: &isDirectory) else {
            let error = FileSystemError(
                code: SmithErrorCodes.fileNotFound,
                filePath: path,
                message: "Project path not found: \(path)",
                suggestedActions: [
                    "Verify the path exists: ls -la \(path)",
                    "Use current directory: '.'",
                    "Check relative vs absolute paths"
                ]
            )
            return .failure(.fileSystemError(error))
        }
        
        if !isDirectory.boolValue {
            let error = FileSystemError(
                code: SmithErrorCodes.invalidFileFormat,
                filePath: path,
                message: "Path is not a directory: \(path)",
                suggestedActions: [
                    "Provide a directory path, not a file",
                    "For files, specify the containing directory"
                ]
            )
            return .failure(.fileSystemError(error))
        }
        
        return .success(resolvedPath)
    }
    
    // MARK: - Argument Validation
    
    static func validateArguments(
        _ arguments: [String: Any],
        required: [String],
        format: String = "summary"
    ) -> Result<[String: Any], SmithErrorWrapper> {
        
        var missingArgs: [String] = []
        let validatedArgs = arguments
        
        for requiredArg in required {
            if validatedArgs[requiredArg] == nil || 
               (validatedArgs[requiredArg] is String && (validatedArgs[requiredArg] as! String).isEmpty) {
                missingArgs.append(requiredArg)
            }
        }
        
        if !missingArgs.isEmpty {
            let error = CLIError(
                "Missing required arguments: \(missingArgs.joined(separator: ", "))",
                technicalDetails: "The following arguments are required but were not provided",
                suggestedActions: [
                    "Provide all required arguments",
                    "Check command syntax with --help",
                    "Review command documentation"
                ]
            )
            return .failure(.cliError(error))
        }
        
        return .success(validatedArgs)
    }
    
    // MARK: - Level Validation
    
    static func validateLevel(_ level: String, allowedLevels: [String] = ["critical", "standard", "comprehensive"]) -> Result<String, SmithErrorWrapper> {
        guard allowedLevels.contains(level.lowercased()) else {
            let error = CLIError(
                "Invalid validation level: \(level)",
                technicalDetails: "Allowed levels: \(allowedLevels.joined(separator: ", "))",
                suggestedActions: [
                    "Use one of the allowed levels: \(allowedLevels.joined(separator: ", "))",
                    "Check command help for available options"
                ]
            )
            return .failure(.cliError(error))
        }
        
        return .success(level.lowercased())
    }
    
    // MARK: - Format Validation
    
    static func validateFormat(_ format: String, allowedFormats: [String] = ["json", "summary"]) -> Result<String, SmithErrorWrapper> {
        guard allowedFormats.contains(format.lowercased()) else {
            let error = CLIError(
                "Invalid output format: \(format)",
                technicalDetails: "Allowed formats: \(allowedFormats.joined(separator: ", "))",
                suggestedActions: [
                    "Use one of the allowed formats: \(allowedFormats.joined(separator: ", "))",
                    "Check command help for available options"
                ]
            )
            return .failure(.cliError(error))
        }
        
        return .success(format.lowercased())
    }
    
    // MARK: - Timeout Validation
    
    static func validateTimeout(_ timeout: Int) -> Result<Int, SmithErrorWrapper> {
        guard timeout > 0 else {
            let error = CLIError(
                "Invalid timeout value: \(timeout)",
                technicalDetails: "Timeout must be a positive integer",
                suggestedActions: [
                    "Use a positive integer for timeout",
                    "Timeout is measured in seconds",
                    "Common values: 30, 60, 300, 600"
                ]
            )
            return .failure(.cliError(error))
        }
        
        guard timeout <= 3600 else {  // Max 1 hour
            let error = CLIError(
                "Timeout value too large: \(timeout)",
                technicalDetails: "Timeout must be 3600 seconds (1 hour) or less",
                suggestedActions: [
                    "Use a timeout of 3600 seconds or less",
                    "For longer operations, consider breaking them into smaller tasks"
                ]
            )
            return .failure(.cliError(error))
        }
        
        return .success(timeout)
    }
    
    // MARK: - System Resource Checks
    
    static func checkSystemResources() -> Result<Void, SmithErrorWrapper> {
        // Check disk space
        let fileManager = FileManager.default
        let homeDir = fileManager.homeDirectoryForCurrentUser
        do {
            let resources = try homeDir.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            if let availableCapacity = resources.volumeAvailableCapacity,
               availableCapacity < 1024 * 1024 * 100 { // Less than 100MB
                let error = SystemError(
                    code: SmithErrorCodes.diskSpaceInsufficient,
                    message: "Insufficient disk space",
                    technicalDetails: "Available space: \(availableCapacity / 1024 / 1024)MB",
                    suggestedActions: [
                        "Free up disk space",
                        "Clean temporary files and cache",
                        "Remove old build artifacts"
                    ]
                )
                return .failure(.systemError(error))
            }
        } catch {
            // Non-fatal: can't check disk space
        }

        return .success(())
    }

    // MARK: - Result Processing
    
    static func processToolResult<T>(
        _ result: Result<T, SmithErrorWrapper>,
        format: String = "summary",
        successMessage: String? = nil
    ) throws -> T {
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            ErrorDisplayManager.displayError(error, format: format.lowercased() == "json" ? .json : .human)
            throw ExitCode.failure
        }
    }
    
    // MARK: - Build Arguments
    
    static func buildToolArguments(
        baseArguments: [String],
        path: String,
        options: [String: Any]
    ) -> [String] {
        var arguments = baseArguments + [path]
        
        // Add boolean flags
        for (key, value) in options {
            if let boolValue = value as? Bool, boolValue {
                arguments.append("--\(key)")
            }
        }
        
        // Add value options
        for (key, value) in options {
            if let stringValue = value as? String, !stringValue.isEmpty, !(value is Bool) {
                arguments.append("--\(key)=\(stringValue)")
            } else if let intValue = value as? Int {
                arguments.append("--\(key)=\(intValue)")
            }
        }
        
        return arguments
    }
}

// MARK: - Convenience Extensions

extension ParsableCommand {
    func handleToolExecution<T>(
        toolName: String,
        baseArguments: [String],
        path: String,
        options: [String: Any] = [:],
        format: String = "summary",
        timeout: TimeInterval = 300,
        resultProcessor: ((Bool, String) -> T)? = nil
    ) throws -> T {
        
        // Validate inputs
        let validatedPath = try ErrorHandler.processToolResult(
            ErrorHandler.validateProjectPath(path),
            format: format
        )
        
        let validatedFormat = try ErrorHandler.processToolResult(
            ErrorHandler.validateFormat(format),
            format: format
        )
        
        // Check tool availability
        let toolPath = try ErrorHandler.processToolResult(
            ErrorHandler.checkToolAvailability(toolName, format: format),
            format: format
        )
        
        // Build arguments
        let arguments = ErrorHandler.buildToolArguments(
            baseArguments: baseArguments,
            path: validatedPath,
            options: options
        )
        
        // Execute tool
        let executionResult = try ErrorHandler.processToolResult(
            ErrorHandler.executeTool(
                toolName: toolName,
                toolPath: toolPath,
                arguments: arguments,
                format: validatedFormat,
                timeout: timeout
            ),
            format: format
        )
        
        // Process result
        if let resultProcessor = resultProcessor {
            return resultProcessor(executionResult.success, executionResult.output)
        } else {
            // Default processing
            if !executionResult.success {
                let error = ToolError.toolExecutionFailed(
                    toolName: toolName,
                    error: NSError(domain: "smith", code: executionResult.success ? 0 : 1)
                )
                ErrorDisplayManager.displayError(error, format: validatedFormat == "json" ? .json : .human)
                throw ExitCode.failure
            }
            
            // Return formatted output
            if validatedFormat == "json" {
                let result = SmithToolResult(success: executionResult.success, output: executionResult.output, tool: toolName)
                let jsonData = try! JSONEncoder().encode(result)
                return String(data: jsonData, encoding: .utf8)! as! T
            } else {
                return executionResult.output as! T
            }
        }
    }
}

// MARK: - Tool-Specific Error Helpers

extension ErrorHandler {
    
    static func createValidationError(
        violations: [(file: String?, line: Int?, severity: String, message: String, rule: String?)],
        format: String = "summary"
    ) -> SmithValidationError {
        let criticalCount = violations.filter { $0.severity == "critical" }.count
        let message = "TCA validation found \(violations.count) violations"
        
        var suggestedActions = [
            "Review TCA architecture guidelines",
            "Fix critical violations first",
            "Consider automated fixes where available"
        ]
        
        if criticalCount > 0 {
            suggestedActions.insert("Address \(criticalCount) critical violations immediately", at: 0)
        }
        
        return SmithValidationError(
            code: SmithErrorCodes.tcaViolation,
            message: message,
            technicalDetails: "\(criticalCount) critical, \(violations.count - criticalCount) non-critical",
            suggestedActions: suggestedActions
        )
    }
    
    static func createPerformanceError(
        issues: [String],
        format: String = "summary"
    ) -> SmithValidationError {
        let message = "Performance issues detected: \(issues.count) problems found"
        
        return SmithValidationError(
            code: SmithErrorCodes.performanceIssue,
            message: message,
            technicalDetails: issues.joined(separator: "; "),
            suggestedActions: [
                "Review performance bottlenecks",
                "Optimize slow operations",
                "Use TCA performance profiling tools"
            ]
        )
    }
}
// Note: 'which()' function moved to Utilities.swift as a global utility