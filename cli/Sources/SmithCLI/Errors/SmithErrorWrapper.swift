import Foundation

// MARK: - SmithErrorWrapper

enum SmithErrorWrapper: Error {
    case cliError(CLIError)
    case validationError(SmithValidationError)
    case toolError(ToolError)
    case systemError(SystemError)
    case buildError(BuildError)
    case fileSystemError(FileSystemError)
}

// MARK: - SmithError Conformance

extension SmithErrorWrapper: SmithError {
    var errorCode: String {
        switch self {
        case .cliError(let error):
            return error.errorCode
        case .validationError(let error):
            return error.errorCode
        case .toolError(let error):
            return error.errorCode
        case .systemError(let error):
            return error.errorCode
        case .buildError(let error):
            return error.errorCode
        case .fileSystemError(let error):
            return error.errorCode
        }
    }

    var userMessage: String {
        switch self {
        case .cliError(let error):
            return error.userMessage
        case .validationError(let error):
            return error.userMessage
        case .toolError(let error):
            return error.userMessage
        case .systemError(let error):
            return error.userMessage
        case .buildError(let error):
            return error.userMessage
        case .fileSystemError(let error):
            return error.userMessage
        }
    }

    var technicalDetails: String? {
        switch self {
        case .cliError(let error):
            return error.technicalDetails
        case .validationError(let error):
            return error.technicalDetails
        case .toolError(let error):
            return error.technicalDetails
        case .systemError(let error):
            return error.technicalDetails
        case .buildError(let error):
            return error.technicalDetails
        case .fileSystemError(let error):
            return error.technicalDetails
        }
    }

    var suggestedActions: [String] {
        switch self {
        case .cliError(let error):
            return error.suggestedActions
        case .validationError(let error):
            return error.suggestedActions
        case .toolError(let error):
            return error.suggestedActions
        case .systemError(let error):
            return error.suggestedActions
        case .buildError(let error):
            return error.suggestedActions
        case .fileSystemError(let error):
            return error.suggestedActions
        }
    }

    var documentationURL: URL? {
        switch self {
        case .cliError(let error):
            return error.documentationURL
        case .validationError(let error):
            return error.documentationURL
        case .toolError(let error):
            return error.documentationURL
        case .systemError(let error):
            return error.documentationURL
        case .buildError(let error):
            return error.documentationURL
        case .fileSystemError(let error):
            return error.documentationURL
        }
    }

    var isFatal: Bool {
        switch self {
        case .cliError(let error):
            return error.isFatal
        case .validationError(let error):
            return error.isFatal
        case .toolError(let error):
            return error.isFatal
        case .systemError(let error):
            return error.isFatal
        case .buildError(let error):
            return error.isFatal
        case .fileSystemError(let error):
            return error.isFatal
        }
    }
}

// MARK: - Convenience Initializers

extension SmithErrorWrapper {
    static func cli(_ message: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) -> SmithErrorWrapper {
        .cliError(CLIError(message, technicalDetails: technicalDetails, suggestedActions: suggestedActions, isFatal: isFatal))
    }

    static func validation(_ message: String, code: String = SmithErrorCodes.validationFailed, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) -> SmithErrorWrapper {
        .validationError(SmithValidationError(code: code, message: message, technicalDetails: technicalDetails, suggestedActions: suggestedActions, isFatal: isFatal))
    }

    static func tool(toolName: String, message: String? = nil, code: String = SmithErrorCodes.toolNotFound, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) -> SmithErrorWrapper {
        .toolError(ToolError(code: code, toolName: toolName, message: message, technicalDetails: technicalDetails, suggestedActions: suggestedActions, isFatal: isFatal))
    }

    static func system(_ message: String, code: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) -> SmithErrorWrapper {
        .systemError(SystemError(code: code, message: message, technicalDetails: technicalDetails, suggestedActions: suggestedActions, isFatal: isFatal))
    }

    static func build(_ message: String, code: String = SmithErrorCodes.compilationFailed, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) -> SmithErrorWrapper {
        .buildError(BuildError(code: code, message: message, technicalDetails: technicalDetails, suggestedActions: suggestedActions, isFatal: isFatal))
    }

    static func fileSystem(filePath: String, message: String? = nil, code: String = SmithErrorCodes.fileNotFound, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) -> SmithErrorWrapper {
        .fileSystemError(FileSystemError(code: code, filePath: filePath, message: message, technicalDetails: technicalDetails, suggestedActions: suggestedActions, isFatal: isFatal))
    }
}