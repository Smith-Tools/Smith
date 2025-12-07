import Foundation

// MARK: - Tool Path Utilities

/// Find the path to a Smith tool in common locations
func findSmithToolPath(_ toolName: String) -> String? {
    let commonPaths = [
        "/usr/local/bin/\(toolName)",
        "/opt/homebrew/bin/\(toolName)",
        "/usr/local/opt/smith-tools/bin/\(toolName)",
        "~/.smith/bin/\(toolName)".expandingTildeInPath,
    ]

    for path in commonPaths {
        if FileManager.default.fileExists(atPath: path) {
            return path
        }
    }

    // Try to find via which
    return which(toolName)
}

/// Find smith-validation in common locations
func findSmithValidationPath() -> String? {
    findSmithToolPath("smith-validation")
}

/// Find smith-tca-trace in common locations
func findSmithTCATracePath() -> String? {
    findSmithToolPath("smith-tca-trace")
}

/// Find smith-parser in common locations
func findSBParserPath() -> String? {
    findSmithToolPath("smith-parser")
}

/// Use the 'which' command to find an executable
func which(_ command: String) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
    process.arguments = [command]

    let pipe = Pipe()
    process.standardOutput = pipe

    do {
        try process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            return path?.isEmpty == false ? path : nil
        }
        return nil
    } catch {
        return nil
    }
}

// MARK: - String Extensions

private extension String {
    var expandingTildeInPath: String {
        return (self as NSString).expandingTildeInPath
    }
}
