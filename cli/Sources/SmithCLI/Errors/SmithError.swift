import Foundation

// MARK: - Core SmithError Protocol

protocol SmithError: Error, LocalizedError {
    var errorCode: String { get }
    var userMessage: String { get }
    var technicalDetails: String? { get }
    var suggestedActions: [String] { get }
    var documentationURL: URL? { get }
    var isFatal: Bool { get }
}

// MARK: - Base SmithError Implementation

struct BaseSmithError: SmithError {
    let errorCode: String
    let userMessage: String
    let technicalDetails: String?
    let suggestedActions: [String]
    let documentationURL: URL?
    let isFatal: Bool
    
    var errorDescription: String? {
        var message = "❌ \(userMessage)"
        
        if let technicalDetails = technicalDetails {
            message += "\n\nDetails: \(technicalDetails)"
        }
        
        if !suggestedActions.isEmpty {
            message += "\n\nTo fix:"
            for (index, action) in suggestedActions.enumerated() {
                message += "\n  \(index + 1). \(action)"
            }
        }
        
        if let documentationURL = documentationURL {
            message += "\n\nFor more help: \(documentationURL.absoluteString)"
        }
        
        message += "\n\nRun with --help for more options"
        
        return message
    }
    
    var failureReason: String? {
        technicalDetails
    }
    
    var recoverySuggestion: String? {
        suggestedActions.first
    }
}

// MARK: - Error Code Constants

enum SmithErrorCodes {
    // CLI Errors (CLI_XXX)
    static let invalidCommand = "SMITH_CLI_001"
    static let invalidArguments = "SMITH_CLI_002"
    static let missingArgument = "SMITH_CLI_003"
    static let invalidOptionValue = "SMITH_CLI_004"
    
    // Validation Errors (VAL_XXX)
    static let validationFailed = "SMITH_VAL_001"
    static let tcaViolation = "SMITH_VAL_002"
    static let missingDependency = "SMITH_VAL_003"
    static let circularDependency = "SMITH_VAL_004"
    static let performanceIssue = "SMITH_VAL_005"
    
    // Tool Errors (TOOL_XXX)
    static let toolNotFound = "SMITH_TOOL_001"
    static let toolVersionMismatch = "SMITH_TOOL_002"
    static let toolExecutionFailed = "SMITH_TOOL_003"
    static let toolPermissionDenied = "SMITH_TOOL_004"
    
    // System Errors (SYS_XXX)
    static let permissionDenied = "SMITH_SYS_001"
    static let diskSpaceInsufficient = "SMITH_SYS_002"
    static let memoryInsufficient = "SMITH_SYS_003"
    static let networkUnavailable = "SMITH_SYS_004"
    
    // Build Errors (BUILD_XXX)
    static let compilationFailed = "SMITH_BUILD_001"
    static let buildTimeout = "SMITH_BUILD_002"
    static let invalidBuildConfig = "SMITH_BUILD_003"
    
    // File System Errors (FS_XXX)
    static let fileNotFound = "SMITH_FS_001"
    static let invalidFileFormat = "SMITH_FS_002"
    static let readOnlyFileSystem = "SMITH_FS_003"
}

// MARK: - Specific Error Types

// CLI Errors
struct CLIError: SmithError {
    let errorCode: String = SmithErrorCodes.invalidCommand
    let userMessage: String
    let technicalDetails: String?
    let suggestedActions: [String]
    let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/cli-usage")
    let isFatal: Bool
    
    init(_ message: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) {
        self.userMessage = message
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? ["Check available commands with 'smith --help'", "Use 'smith <command> --help' for specific command help"] : suggestedActions
        self.isFatal = isFatal
    }
}

// Validation Errors
struct SmithValidationError: SmithError {
    let errorCode: String
    let userMessage: String
    let technicalDetails: String?
    let suggestedActions: [String]
    let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/tca-rules")
    let isFatal: Bool
    
    init(code: String = SmithErrorCodes.validationFailed, message: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) {
        self.errorCode = code
        self.userMessage = message
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? [
            "Review TCA architecture guidelines",
            "Run 'smith validate --help' for specific rules",
            "Check documentation at https://smith-tools.dev/docs/tca-rules"
        ] : suggestedActions
        self.isFatal = isFatal
    }
}

// Tool Errors
struct ToolError: SmithError {
    let errorCode: String
    let userMessage: String
    let toolName: String
    let technicalDetails: String?
    let suggestedActions: [String]
    let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/installation")
    let isFatal: Bool
    
    init(code: String = SmithErrorCodes.toolNotFound, toolName: String, message: String? = nil, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) {
        self.errorCode = code
        self.toolName = toolName
        self.userMessage = message ?? "\(toolName) not found or cannot be executed"
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? [
            "Install \(toolName): brew install \(toolName)",
            "Check PATH: echo $PATH",
            "Verify installation: \(toolName) --version",
            "See installation guide: https://smith-tools.dev/docs/installation"
        ] : suggestedActions
        self.isFatal = isFatal
    }
}

// System Errors
struct SystemError: SmithError {
    let errorCode: String
    let userMessage: String
    let technicalDetails: String?
    let suggestedActions: [String]
    let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/troubleshooting")
    let isFatal: Bool
    
    init(code: String, message: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) {
        self.errorCode = code
        self.userMessage = message
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? [
            "Check system resources and permissions",
            "Try running with different user permissions",
            "Review troubleshooting guide for similar issues"
        ] : suggestedActions
        self.isFatal = isFatal
    }
}

// Build Errors
struct BuildError: SmithError {
    let errorCode: String
    let userMessage: String
    let technicalDetails: String?
    let suggestedActions: [String]
    let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/build-troubleshooting")
    let isFatal: Bool
    
    init(code: String = SmithErrorCodes.compilationFailed, message: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) {
        self.errorCode = code
        self.userMessage = message
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? [
            "Check build logs for specific compilation errors",
            "Verify project configuration and dependencies",
            "Try cleaning build artifacts and rebuilding",
            "See build troubleshooting guide for common issues"
        ] : suggestedActions
        self.isFatal = isFatal
    }
}

// File System Errors
struct FileSystemError: SmithError {
    let errorCode: String
    let userMessage: String
    let filePath: String
    let technicalDetails: String?
    let suggestedActions: [String]
    let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/file-operations")
    let isFatal: Bool
    
    init(code: String = SmithErrorCodes.fileNotFound, filePath: String, message: String? = nil, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) {
        self.errorCode = code
        self.filePath = filePath
        self.userMessage = message ?? "File not found: \(filePath)"
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? [
            "Verify the file path exists: ls -la \(filePath)",
            "Check file permissions: ls -la \(filePath)",
            "Ensure you have read access to the file",
            "See file operations guide for path handling"
        ] : suggestedActions
        self.isFatal = isFatal
    }
}

// MARK: - Error Handling Extensions

extension SmithError {
    var formattedOutput: String {
        errorDescription ?? userMessage
    }
    
    var jsonOutput: [String: Any] {
        var result: [String: Any] = [
            "errorCode": errorCode,
            "userMessage": userMessage,
            "isFatal": isFatal
        ]
        
        if let technicalDetails = technicalDetails {
            result["technicalDetails"] = technicalDetails
        }
        
        if !suggestedActions.isEmpty {
            result["suggestedActions"] = suggestedActions
        }
        
        if let documentationURL = documentationURL {
            result["documentationURL"] = documentationURL.absoluteString
        }
        
        return result
    }
}

// MARK: - Error Display Manager

struct ErrorDisplayManager {
    static func displayError(_ error: SmithError, format: ErrorFormat = .auto) {
        switch format {
        case .json:
            displayJSONError(error)
        case .human:
            displayHumanError(error)
        case .auto:
            displayAutoError(error)
        }
    }
    
    private static func displayJSONError(_ error: SmithError) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: error.jsonOutput),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
    }
    
    private static func displayHumanError(_ error: SmithError) {
        print(error.formattedOutput)
    }
    
    private static func displayAutoError(_ error: SmithError) {
        // Check if output is TTY or piped
        if isatty(STDOUT_FILENO) != 0 {
            displayHumanError(error)
        } else {
            displayJSONError(error)
        }
    }
}

// MARK: - Error Format Options

enum ErrorFormat {
    case json
    case human
    case auto
}

// MARK: - Convenience Error Creators

extension SmithError where Self == SmithValidationError {
    static func tcaViolation(message: String, file: String? = nil, line: Int? = nil, rule: String? = nil) -> SmithValidationError {
        var technicalDetails: String? = nil
        var suggestedActions = [
            "Review TCA architecture best practices",
            "Consider splitting large reducers into smaller features",
            "Use @Dependency injection for external dependencies"
        ]
        
        if let file = file {
            technicalDetails = "Found in \(file)"
            if let line = line {
                technicalDetails! += " at line \(line)"
            }
            if let rule = rule {
                suggestedActions.insert("Review rule \(rule): https://smith-tools.dev/docs/tca-rules#\(rule.lowercased())", at: 0)
            }
        }
        
        return SmithValidationError(
            code: SmithErrorCodes.tcaViolation,
            message: "TCA architecture violation: \(message)",
            technicalDetails: technicalDetails,
            suggestedActions: suggestedActions
        )
    }
    
    static func missingDependency(dependency: String, location: String? = nil) -> SmithValidationError {
        let message = "Missing dependency injection: \(dependency)"
        var technicalDetails: String? = nil
        
        if let location = location {
            technicalDetails = "Required at \(location)"
        }
        
        return SmithValidationError(
            code: SmithErrorCodes.missingDependency,
            message: message,
            technicalDetails: technicalDetails,
            suggestedActions: [
                "Add @Dependency property to your reducer",
                "Register dependency in your app's dependency container",
                "See dependency injection guide: https://smith-tools.dev/docs/dependency-injection"
            ]
        )
    }
}

extension SmithError where Self == ToolError {
    static func toolNotFound(toolName: String) -> ToolError {
        return ToolError(
            toolName: toolName,
            message: "\(toolName) not found",
            suggestedActions: [
                "Install \(toolName): brew install \(toolName)",
                "Check if tool is in PATH: which \(toolName)",
                "Verify installation: \(toolName) --version",
                "Manual installation: https://smith-tools.dev/docs/installation"
            ]
        )
    }
    
    static func toolExecutionFailed(toolName: String, error: Error) -> ToolError {
        return ToolError(
            code: SmithErrorCodes.toolExecutionFailed,
            toolName: toolName,
            message: "Failed to execute \(toolName)",
            technicalDetails: error.localizedDescription,
            suggestedActions: [
                "Check tool permissions: chmod +x $(which \(toolName))",
                "Verify tool integrity: \(toolName) --version",
                "Check system dependencies",
                "Reinstall tool if necessary"
            ]
        )
    }
}