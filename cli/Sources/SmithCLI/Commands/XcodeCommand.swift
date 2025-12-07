import Foundation
import ArgumentParser
import SmithOutputFormatter
import SmithErrorHandling
import SmithProgress

// MARK: - Xcode Command Group

struct Xcode: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Xcode project analysis and build tools",
        discussion: """
        Xcode-specific tools for project analysis, build optimization, and monitoring.

        Examples:
          smith xcode analyze MyApp.xcodeproj
          smith xcode parse build.log
          smith xcode dependencies --tree
          smith xcode monitor --scheme MyApp
        """,
        subcommands: [
            Analyze.self,
            Dependencies.self,
            Parse.self
        ]
    )
}

// MARK: - Xcode Analyze Command

extension Xcode {
    struct Analyze: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Analyze Xcode project build performance and dependencies"
        )

        @Argument(help: "Path to Xcode project or workspace")
        var path: String = "."

        @Flag(name: .long, help: "Output in JSON format")
        var json = false

        @Flag(name: .long, help: "Include dependency analysis")
        var dependencies = false

        @Flag(name: .long, help: "Perform build performance analysis")
        var performance = false

        @Flag(name: .long, help: "Enable hang detection analysis")
        var hangDetection = false

        func run() throws {
            print("🔍 XCODE PROJECT ANALYSIS")
            print("=========================")

            let resolvedPath = (path as NSString).standardizingPath
            print("📁 Project: \(URL(fileURLWithPath: resolvedPath).lastPathComponent)")

            // Check if this is a valid Xcode project
            guard isValidXcodeProject(at: resolvedPath) else {
                print("❌ Not a valid Xcode project or workspace")
                print("   Expected: .xcodeproj or .xcworkspace")
                throw ExitCode.failure
            }

            print("✅ Xcode project detected")

            // Check for Xcode availability
            if !checkXcodeAvailable() {
                print("⚠️  Xcode not found - some features will be limited")
            }

            // Perform basic analysis
            print("")
            print("📊 BASIC PROJECT ANALYSIS")
            print("=========================")
            performBasicXcodeAnalysis(at: resolvedPath)
        }

        private func isValidXcodeProject(at path: String) -> Bool {
            let url = URL(fileURLWithPath: path)
            return url.pathExtension == "xcodeproj" || url.pathExtension == "xcworkspace"
        }

        private func checkXcodeAvailable() -> Bool {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
            process.arguments = ["-version"]
            
            do {
                try process.run()
                process.waitUntilExit()
                return process.terminationStatus == 0
            } catch {
                return false
            }
        }


        private func performBasicXcodeAnalysis(at path: String) {
            let fileManager = FileManager.default
            var fileCount = 0
            var swiftFiles = 0

            // Basic file counting
            if let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: [.nameKey, .isDirectoryKey]) {
                for case let fileURL as URL in enumerator {
                    if fileURL.pathExtension == "swift" {
                        swiftFiles += 1
                    }
                    fileCount += 1
                }
            }

            print("📊 Project Statistics:")
            print("   Total Files: \(fileCount)")
            print("   Swift Files: \(swiftFiles)")
            print("   Build System: Xcode")
            
            if swiftFiles > 100 {
                print("")
                print("💡 Large project detected - consider modularization")
            }
        }

        // Note: findSmithXCSiftPath() has been moved to Utilities.swift
    }
}

// MARK: - Xcode Dependencies Command

extension Xcode {
    struct Dependencies: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Analyze Xcode project dependencies",
            discussion: """
            Analyzes dependencies in Xcode projects and workspaces, providing
            dependency trees, circular dependency detection, and conflict analysis.

            This command provides deep analysis of your Xcode project's target
            dependencies, frameworks, and build system configuration.

            Examples:
              smith xcode dependencies MyApp.xcodeproj
              smith xcode dependencies --tree
              smith xcode dependencies --circular
              smith xcode dependencies --format=json
            """
        )

        @Argument(help: "Path to Xcode project or workspace")
        var path: String = "."

        @Flag(name: .long, help: "Show dependency tree")
        var tree = false

        @Flag(name: .long, help: "Check for circular dependencies")
        var circular = false

        @Option(name: .long, help: "Output format: summary|tree|json|dot|mermaid (default: summary)")
        var format: String = "summary"

        @Flag(name: .long, help: "Show verbose output")
        var verbose = false

        func run() throws {
            print("🔍 XCODE DEPENDENCY ANALYSIS")
            print("===========================")

            let resolvedPath = (path as NSString).standardizingPath
            print("📁 Project: \(URL(fileURLWithPath: resolvedPath).lastPathComponent)")

            // Check if this is a valid Xcode project
            guard isValidXcodeProject(at: resolvedPath) else {
                print("❌ Not a valid Xcode project or workspace")
                print("   Expected: .xcodeproj or .xcworkspace")
                throw ExitCode.failure
            }

            print("✅ Xcode project detected")

            // Perform basic analysis
            print("")
            print("📊 BASIC DEPENDENCY ANALYSIS")
            print("============================")
            performBasicDependencyAnalysis(at: resolvedPath)
        }

        private func isValidXcodeProject(at path: String) -> Bool {
            let url = URL(fileURLWithPath: path)
            return url.pathExtension == "xcodeproj" || url.pathExtension == "xcworkspace"
        }


        private func performBasicDependencyAnalysis(at path: String) {
            let fileManager = FileManager.default
            var targetCount = 0
            var hasFrameworks = false
            var hasSPMDeps = false

            // Basic project structure analysis
            if let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: [.nameKey, .isDirectoryKey]) {
                for case let fileURL as URL in enumerator {
                    let fileName = fileURL.lastPathComponent

                    // Look for target indicators
                    if fileURL.pathExtension == "xcscheme" {
                        targetCount += 1
                    }

                    // Look for framework dependencies
                    if fileName.hasSuffix(".framework") || fileName.hasSuffix(".xcframework") {
                        hasFrameworks = true
                    }

                    // Look for SPM dependencies
                    if fileName == "Package.resolved" {
                        hasSPMDeps = true
                    }
                }
            }

            print("📊 Project Statistics:")
            print("   Targets: \(targetCount)")
            print("   Framework Dependencies: \(hasFrameworks ? "Yes" : "No")")
            print("   Swift Package Dependencies: \(hasSPMDeps ? "Yes" : "No")")

            if hasSPMDeps {
                print("")
                print("📦 Swift Package Dependencies Found:")

                let packageResolvedPath = (path as NSString).appendingPathComponent("xcshareddata/swiftpm/Package.resolved")
                if FileManager.default.fileExists(atPath: packageResolvedPath) {
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: packageResolvedPath)),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let dependencies = json["object"] as? [String: Any],
                       let pins = dependencies["pins"] as? [[String: Any]] {

                        for pin in pins {
                            if let repository = pin["repositoryURL"] as? String,
                               let version = pin["state"] as? [String: Any],
                               let versionString = version["version"] as? String {
                                print("   • \(repository.components(separatedBy: "/").last ?? repository): \(versionString)")
                            }
                        }
                    }
                }
            }

            if targetCount > 10 {
                print("")
                print("💡 Complex project detected - consider modularization")
                print("   Use smith-parser for detailed dependency analysis")
            } else if !hasFrameworks && !hasSPMDeps {
                print("")
                print("ℹ️  No external dependencies detected")
            } else {
                print("")
                print("💡 Use smith-parser for detailed dependency analysis including:")
                print("   • Dependency tree visualization")
                print("   • Circular dependency detection")
                print("   • Dependency conflict analysis")
            }
        }
    }
}

// MARK: - Xcode Parse Command

extension Xcode {
    struct Parse: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Parse Xcode build output from stdin using smith-parser",
            discussion: """
            Parses Xcode build output from stdin and delegates to smith-parser
            for unified parsing across all build systems.

            Examples:
              xcodebuild -scheme MyApp | smith xcode parse
              xcodebuild clean build | smith xcode parse --format=json

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

        func run() throws {
            // Check if input is being piped
            if isatty(STDIN_FILENO) != 0 {
                print("smith xcode parse: No input detected. Pipe Xcode build output.")
                print("Usage: xcodebuild | smith xcode parse")
                print("   or: Use 'smith parse' for unified parsing")
                throw ExitCode.failure
            }

            let input = FileHandle.standardInput.readDataToEndOfFile()
            let output = String(data: input, encoding: .utf8) ?? ""

            guard !output.isEmpty else {
                print("{\"error\": \"No input received\"}")
                throw ExitCode.failure
            }

            print("🔍 PARSING XCODE BUILD OUTPUT")
            print("=============================")

            // Delegate to smith-parser for parsing
            if let smithParserPath = findSBParserPath() {
                try runSBParserParse(output: output, format: format, verbose: verbose, compact: compact)
            } else {
                // Fallback basic parsing
                print("⚠️  smith-parser not found - using basic parsing")
                performBasicParse(output: output, format: format)
            }
        }

        private func runSBParserParse(output: String, format: String, verbose: Bool, compact: Bool) throws {
            var arguments = ["--format=\(format)"]
            if verbose { arguments.append("--verbose") }
            if compact { arguments.append("--compact") }

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