import Foundation

// MARK: - Tool Requirement Protocol

protocol ToolRequirement {
    var toolName: String { get }
    var minVersion: String? { get }
    var isFatal: Bool { get }
    func check() -> Bool
    func installationHelp() -> String
}

// MARK: - Specific Tool Requirements

struct SwiftRequirement: ToolRequirement {
    let toolName = "swift"
    let minVersion: String? = "5.9"
    let isFatal = true
    
    func check() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["--version"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8) {
                    return checkVersion(output: output, minVersion: minVersion ?? "5.9")
                }
            }
            return false
        } catch {
            return false
        }
    }
    
    func installationHelp() -> String {
        """
        Swift \(minVersion ?? "5.9") or later is required for Smith Tools to function.

        To install:
          • macOS: Install Xcode Command Line Tools
            xcode-select --install

          • Linux: Download from https://swift.org/download/

        Verify installation: swift --version
        """
    }
}

struct XcodeBuildRequirement: ToolRequirement {
    let toolName = "xcodebuild"
    let minVersion: String? = "14.0"
    let isFatal = false  // Can gracefully degrade
    
    func check() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
        process.arguments = ["-version"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8) {
                    return checkVersion(output: output, minVersion: minVersion ?? "14.0")
                }
            }
            return false
        } catch {
            return false
        }
    }
    
    func installationHelp() -> String {
        """
        xcodebuild is required for Xcode project analysis.

        To install:
          xcode-select --install

        Or download Xcode from the App Store.

        Note: Some Smith tools will work without Xcode, but Xcode-specific features will be limited.
        """
    }
}

struct GitRequirement: ToolRequirement {
    let toolName = "git"
    let minVersion: String? = "2.0"
    let isFatal = false
    
    func check() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["--version"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    func installationHelp() -> String {
        """
        git is required for some Smith features.

        To install:
          • macOS: Usually pre-installed, or:
            xcode-select --install

          • Other platforms: Install via your package manager

        Verify installation: git --version
        """
    }
}

// MARK: - Requirement Checker

struct RequirementChecker {
    static func check(_ requirements: [ToolRequirement]) -> (fatal: [ToolRequirement], warnings: [ToolRequirement]) {
        let missing = requirements.filter { !$0.check() }
        let fatal = missing.filter { $0.isFatal }
        let warnings = missing.filter { !$0.isFatal }
        
        return (fatal: fatal, warnings: warnings)
    }
    
    static func showRequirementsReport(_ missing: (fatal: [ToolRequirement], warnings: [ToolRequirement])) {
        if !missing.warnings.isEmpty {
            print("⚠️  WARNING: Some development tools are not available")
            print(String(repeating: "=", count: 50))
            
            for req in missing.warnings {
                print("\n🔧 \(req.toolName) not found")
                print(req.installationHelp())
            }
            print("\nContinuing with available tools...\n")
        }
        
        if !missing.fatal.isEmpty {
            print("❌ ERROR: Required tools are missing")
            print(String(repeating: "=", count: 50))
            
            for req in missing.fatal {
                print("\n🚨 \(req.toolName) required")
                print(req.installationHelp())
            }
        }
    }
}

// MARK: - Helper Functions

private func checkVersion(output: String, minVersion: String) -> Bool {
    // Simple version parsing - extract first version number
    let versionPattern = #"(\d+\.\d+)"#
    guard let range = output.range(of: versionPattern, options: .regularExpression),
          let version = Double(String(output[range])) else {
        return false
    }
    
    let minVersionDouble = Double(minVersion) ?? 0
    return version >= minVersionDouble
}