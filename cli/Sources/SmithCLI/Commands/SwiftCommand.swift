import Foundation
import ArgumentParser
import SmithOutputFormatter
import SmithErrorHandling
import SmithProgress

// Note: which() and findSmithSBSiftPath() have been moved to Utilities.swift

// MARK: - Swift Command Group

struct Swift: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Swift build analysis and parsing tools",
        discussion: """
        Swift-specific tools for build output parsing and analysis.

        Examples:
          swift build | smith-parser
          smith swift analyze MyPackage/
          smith swift monitor --target MyTarget
        """
    )
}

// MARK: - Swift Analyze Command

extension Swift {
    struct Analyze: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Analyze Swift build performance and issues"
        )

        @Argument(help: "Path to Swift package (default: current directory)")
        var path: String = "."

        @Flag(name: .long, help: "Output in JSON format")
        var json = false

        @Flag(name: .long, help: "Perform hang detection analysis")
        var hangDetection = false

        @Flag(name: .long, help: "Show file-level compilation timing")
        var fileTiming = false

        @Option(name: .long, help: "Show top N slowest files (default: 5)")
        var bottleneck: Int = 5

        func run() throws {
            print("🔍 SWIFT BUILD ANALYSIS")
            print("======================")

            let resolvedPath = (path as NSString).standardizingPath
            print("📁 Package: \(URL(fileURLWithPath: resolvedPath).lastPathComponent)")

            // Check if this is a valid Swift package
            guard isValidSwiftPackage(at: resolvedPath) else {
                print("❌ Not a valid Swift package")
                print("   Expected: Package.swift or Swift project structure")
                throw ExitCode.failure
            }

            print("✅ Swift package detected")

            // Check Swift availability
            guard checkSwiftAvailable() else {
                print("❌ Swift toolchain not found")
                print("   Install Xcode Command Line Tools: xcode-select --install")
                throw ExitCode.failure
            }

            // Perform basic analysis
            print("")
            print("📊 BASIC SWIFT ANALYSIS")
            print("=======================")
            performBasicSwiftAnalysis(at: resolvedPath)
        }

        private func isValidSwiftPackage(at path: String) -> Bool {
            let packageSwift = URL(fileURLWithPath: path).appendingPathComponent("Package.swift")
            return FileManager.default.fileExists(atPath: packageSwift.path)
        }

        private func checkSwiftAvailable() -> Bool {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
            process.arguments = ["--version"]
            
            do {
                try process.run()
                process.waitUntilExit()
                return process.terminationStatus == 0
            } catch {
                return false
            }
        }


        private func performBasicSwiftAnalysis(at path: String) {
            let fileManager = FileManager.default
            var swiftFiles = 0

            // Count Swift files
            if let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: [.nameKey, .isDirectoryKey]) {
                for case let fileURL as URL in enumerator {
                    if fileURL.pathExtension == "swift" {
                        swiftFiles += 1
                    }
                }
            }

            print("📊 Package Statistics:")
            print("   Swift Files: \(swiftFiles)")
            print("   Build System: Swift Package Manager")
            
            if swiftFiles > 50 {
                print("")
                print("💡 Large package detected - consider modularization")
            }
        }
    }
}

// MARK: - Swift Parse Command

extension Swift {
    struct Parse: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Parse Swift build output from stdin using smith-parser",
            discussion: """
            Parses Swift build output from stdin and delegates to smith-parser
            for unified parsing across all build systems.

            Examples:
              swift build | smith swift parse
              swift build | smith swift parse --format=json

            Note: This command now delegates to smith-parser, which provides
            consolidated parsing for Xcode, Swift, and SPM builds.
            """
        )

        @Option(name: .long, help: "Output format: json, text, summary, or compact (default: summary)")
        var format: String = "summary"

        @Flag(name: .long, help: "Include verbose output")
        var verbose = false

        @Flag(name: .long, help: "Compact output mode")
        var compact = false

        @Flag(name: .long, help: "Minimal output mode")
        var minimal = false

        func run() throws {
            // Check if input is being piped
            if isatty(STDIN_FILENO) != 0 {
                print("smith swift parse: No input detected. Pipe Swift build output.")
                print("Usage: swift build | smith swift parse")
                print("   or: Use 'smith parse' for unified parsing")
                throw ExitCode.failure
            }

            let input = FileHandle.standardInput.readDataToEndOfFile()
            let output = String(data: input, encoding: .utf8) ?? ""

            guard !output.isEmpty else {
                print("{\"error\": \"No input received\"}")
                throw ExitCode.failure
            }

            print("🔍 PARSING SWIFT BUILD OUTPUT")
            print("=============================")

            // Delegate to smith-parser for parsing
            if let smithParserPath = findSBParserPath() {
                try runSBParserParse(output: output, format: format, verbose: verbose, compact: compact, minimal: minimal)
            } else {
                // Fallback basic parsing
                print("⚠️  smith-parser not found - using basic parsing")
                performBasicParse(output: output, format: format)
            }
        }

        private func runSBParserParse(output: String, format: String, verbose: Bool, compact: Bool, minimal: Bool) throws {
            var arguments = ["--format=\(format)"]
            if verbose { arguments.append("--verbose") }
            if compact { arguments.append("--compact") }
            if minimal { arguments.append("--minimal") }

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
            inputPipe.fileHandleForWriting.write(output.data(using: .utf8) ?? Data())
            inputPipe.fileHandleForWriting.closeFile()

            process.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let resultOutput = String(data: outputData, encoding: .utf8) ?? ""

            if process.terminationStatus == 0 {
                print(resultOutput)
            } else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                print("❌ Parse failed: \(errorOutput)")
                throw ExitCode.failure
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
            }
        }
    }
}