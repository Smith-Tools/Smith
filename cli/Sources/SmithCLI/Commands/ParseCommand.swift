import Foundation
import ArgumentParser
import SmithOutputFormatter
import SmithErrorHandling
import SmithProgress

// MARK: - Parse Command

struct ParseCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Parse build output from stdin using sbparser",
        discussion: """
        Unified build output parsing that automatically detects and parses
        Swift, Xcode, and SPM build outputs.

        This command delegates to sbparser, which provides consolidated parsing
        for all build system types.

        Examples:
          xcodebuild -scheme MyApp | smith parse
          swift build | smith parse --format=json
          cat build.log | smith parse --verbose

        The parse command will:
        1. Auto-detect the build format (Xcode, Swift, SPM)
        2. Parse errors, warnings, and diagnostics
        3. Extract timing and metrics information
        4. Output in the requested format
        """,
        version: "0.1.0"
    )

    @Option(name: .shortAndLong, help: "Output format: json, text, summary, or compact (default: summary)")
    var format: String = "summary"

    @Flag(name: .shortAndLong, help: "Include verbose output for detailed analysis")
    var verbose: Bool = false

    @Flag(name: .shortAndLong, help: "Show only errors")
    var errors: Bool = false

    @Flag(name: .shortAndLong, help: "Show only warnings")
    var warnings: Bool = false

    @Flag(name: .shortAndLong, help: "Minimal one-line output")
    var minimal: Bool = false

    @Option(name: .shortAndLong, help: "Path to output file (default: stdout)")
    var output: String?

    func run() throws {
        // Check if input is being piped
        if isatty(STDIN_FILENO) != 0 {
            print("smith parse: No input detected. Pipe build output to stdin.")
            print("Usage: xcodebuild | smith parse")
            print("   or: swift build | smith parse --format=json")
            throw ExitCode.failure
        }

        let input = FileHandle.standardInput.readDataToEndOfFile()
        let inputString = String(data: input, encoding: .utf8) ?? ""

        guard !inputString.isEmpty else {
            print("{\"error\": \"No input received\"}")
            throw ExitCode.failure
        }

        print("🔍 PARSING BUILD OUTPUT")
        print("========================")

        // Check if sbparser is available
        if let sbparserPath = findSBParserPath() {
            try runSBParser(input: inputString)
        } else {
            // Fallback to basic parsing
            print("⚠️  sbparser not found - using basic parsing")
            print("")
            performBasicParse(output: inputString, format: format)
        }
    }

    private func runSBParser(input: String) throws {
        var arguments = [String]()

        // Add format argument
        arguments.append("--format=\(format)")

        // Add other options
        if verbose {
            arguments.append("--verbose")
        }
        if errors {
            arguments.append("--errors")
        }
        if warnings {
            arguments.append("--warnings")
        }
        if minimal {
            arguments.append("--minimal")
        }
        if let outputPath = output {
            arguments.append("--output=\(outputPath)")
        }

        print("🔧 Running sbparser...")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: findSBParserPath()!)
        process.arguments = arguments

        let inputPipe = Pipe()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()

        // Write input to process
        inputPipe.fileHandleForWriting.write(input.data(using: .utf8) ?? Data())
        inputPipe.fileHandleForWriting.closeFile()

        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let resultOutput = String(data: outputData, encoding: .utf8) ?? ""

        if process.terminationStatus == 0 {
            if output == nil {
                print(resultOutput)
            } else {
                print("✅ Results written to \(output!)")
            }
        } else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            print("❌ Parse failed: \(errorOutput)")

            // Fallback to basic parsing
            print("")
            print("📊 FALLING BACK TO BASIC PARSING")
            print("=================================")
            performBasicParse(output: input, format: format)
        }
    }

    private func performBasicParse(output: String, format: String) {
        let hasErrors = output.contains(": error: ")
        let hasWarnings = output.contains(": warning: ")
        let buildSucceeded = output.contains("Build succeeded") || output.contains("BUILD SUCCEEDED")

        if format == "json" {
            let result: [String: Any] = [
                "success": buildSucceeded,
                "errors": output.components(separatedBy: ": error: ").count - 1,
                "warnings": output.components(separatedBy: ": warning: ").count - 1,
                "buildSucceeded": buildSucceeded,
                "parser": "basic-fallback"
            ]

            if let jsonData = try? JSONSerialization.data(withJSONObject: result),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } else {
            let status = buildSucceeded ? "✅" : "❌"
            print("\(status) Build \(buildSucceeded ? "succeeded" : "failed")")
            if hasErrors {
                print("🚨 Errors: \(output.components(separatedBy: ": error: ").count - 1)")
            }
            if hasWarnings {
                print("⚠️  Warnings: \(output.components(separatedBy: ": warning: ").count - 1)")
            }
            print("")
            print("💡 Install sbparser for detailed analysis:")
            print("   https://github.com/Smith-Tools/sbparser")
        }
    }
}
