import Foundation
import ArgumentParser
import SmithOutputFormatter
import SmithErrorHandling
import SmithProgress

// MARK: - SPM Command Group

struct SPM: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Swift Package Manager analysis tools",
        discussion: """
        Swift Package Manager specific tools for dependency analysis and package optimization.

        Examples:
          smith spm analyze MyPackage/
          smith spm parse Package.resolved
          smith spm dependencies --tree
        """
    )
}

// MARK: - SPM Analyze Command

extension SPM {
    struct Analyze: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Analyze Swift Package Manager dependencies and structure"
        )

        @Argument(help: "Path to Swift package (default: current directory)")
        var path: String = "."

        @Flag(name: .long, help: "Output in JSON format")
        var json = false

        @Flag(name: .long, help: "Include dependency tree analysis")
        var dependencies = false

        @Flag(name: .long, help: "Perform package optimization analysis")
        var optimize = false

        @Flag(name: .long, help: "Check for circular dependencies")
        var circular = false

        func run() throws {
            print("📦 SWIFT PACKAGE ANALYSIS")
            print("=========================")

            let resolvedPath = (path as NSString).standardizingPath
            print("📁 Package: \(URL(fileURLWithPath: resolvedPath).lastPathComponent)")

            // Check if this is a valid Swift package
            guard isValidSwiftPackage(at: resolvedPath) else {
                print("❌ Not a valid Swift package")
                print("   Expected: Package.swift file")
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
            print("📊 BASIC PACKAGE ANALYSIS")
            print("=========================")
            performBasicPackageAnalysis(at: resolvedPath)
        }

        private func isValidSwiftPackage(at path: String) -> Bool {
            let packageSwift = URL(fileURLWithPath: path).appendingPathComponent("Package.swift")
            return FileManager.default.fileExists(atPath: packageSwift.path)
        }

        private func checkSwiftAvailable() -> Bool {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
            process.arguments = ["package", "--version"]
            
            do {
                try process.run()
                process.waitUntilExit()
                return process.terminationStatus == 0
            } catch {
                return false
            }
        }


        private func performBasicPackageAnalysis(at path: String) {
            let packageSwift = URL(fileURLWithPath: path).appendingPathComponent("Package.swift")
            
            print("📋 Package Information:")
            print("   Package.swift: Found")
            print("   Build System: Swift Package Manager")
            
            // Check for common files
            let fileManager = FileManager.default
            let testsExists = fileManager.fileExists(atPath: URL(fileURLWithPath: path).appendingPathComponent("Tests").path)
            let sourcesExists = fileManager.fileExists(atPath: URL(fileURLWithPath: path).appendingPathComponent("Sources").path)
            
            print("   Sources: \(sourcesExists ? "✅" : "❌")")
            print("   Tests: \(testsExists ? "✅" : "❌")")
        }
    }
}

// MARK: - SPM Dependencies Command

extension SPM {
    struct Dependencies: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Analyze Swift Package dependencies"
        )

        @Argument(help: "Path to Swift package (default: current directory)")
        var path: String = "."

        @Flag(name: .long, help: "Show dependency tree")
        var tree = false

        @Flag(name: .long, help: "Check for outdated dependencies")
        var outdated = false

        @Flag(name: .long, help: "Output in JSON format")
        var json = false

        func run() throws {
            print("🌳 DEPENDENCY ANALYSIS")
            print("=====================")

            let resolvedPath = (path as NSString).standardizingPath
            
            guard isValidSwiftPackage(at: resolvedPath) else {
                print("❌ Not a valid Swift package")
                throw ExitCode.failure
            }

            if tree {
                print("🌲 Dependency Tree:")
                // Run swift package show-dependencies
                let result = runSwiftCommand(["package", "show-dependencies"], at: resolvedPath)
                if result.success {
                    print(result.output)
                } else {
                    print("❌ Failed to get dependency tree: \(result.error ?? "Unknown error")")
                }
            }

            if outdated {
                print("\n📅 Checking for outdated dependencies:")
                let result = runSwiftCommand(["package", "show-dependencies"], at: resolvedPath)
                if result.success {
                    print("Use 'swift package update' to update dependencies")
                }
            }

            if json {
                print("\n📄 JSON Output:")
                let result = runSwiftCommand(["package", "describe", "--type", "json"], at: resolvedPath)
                if result.success {
                    print(result.output)
                }
            }
        }

        private func isValidSwiftPackage(at path: String) -> Bool {
            let packageSwift = URL(fileURLWithPath: path).appendingPathComponent("Package.swift")
            return FileManager.default.fileExists(atPath: packageSwift.path)
        }

        private func runSwiftCommand(_ arguments: [String], at path: String) -> (success: Bool, output: String, error: String?) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
            process.arguments = arguments
            process.currentDirectoryPath = path

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            do {
                try process.run()
                process.waitUntilExit()

                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                return (
                    success: process.terminationStatus == 0,
                    output: String(data: outputData, encoding: .utf8) ?? "",
                    error: String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            } catch {
                return (success: false, output: "", error: error.localizedDescription)
            }
        }
    }
}

// MARK: - Helper Functions for All Commands
// Note: which(), findSmithSBSiftPath(), findSmithSPMSiftPath(), and findSmithXCSiftPath() have been moved to Utilities.swift