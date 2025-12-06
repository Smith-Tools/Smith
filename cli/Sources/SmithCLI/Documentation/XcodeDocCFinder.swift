import Foundation

// MARK: - Xcode DocC Finder

/// Searches Xcode's DerivedData for pre-built DocC archives
public struct XcodeDocCFinder: Sendable {
    /// Default DerivedData location
    public static let defaultDerivedDataPath: URL = {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        return homeDir.appendingPathComponent("Library/Developer/Xcode/DerivedData", isDirectory: true)
    }()

    private let derivedDataPath: URL

    public init(derivedDataPath: URL = XcodeDocCFinder.defaultDerivedDataPath) {
        self.derivedDataPath = derivedDataPath
    }

    // MARK: - Public API

    /// Find a .doccarchive for a package in Xcode's DerivedData
    /// - Parameters:
    ///   - package: Package name (e.g., "ComposableArchitecture")
    ///   - version: Version string (optional, used for verification)
    /// - Returns: URL to .doccarchive if found, nil otherwise
    public func findInDerivedData(package: String, version: String? = nil) -> URL? {
        guard FileManager.default.fileExists(atPath: derivedDataPath.path) else {
            return nil
        }

        // DerivedData structure: ProjectName-xxx/Build/Products/Debug/Package.doccarchive
        // We need to search recursively for .doccarchive files

        guard let enumerator = FileManager.default.enumerator(
            at: derivedDataPath,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }

        // Search patterns to match
        let searchPatterns = [
            "\(package).doccarchive",
            "\(package)-\(version ?? "").doccarchive"
        ].filter { !$0.contains("-.doccarchive") } // Remove if version is nil

        for case let fileURL as URL in enumerator {
            // Skip non-directories
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.isDirectoryKey]),
                  resourceValues.isDirectory == true else {
                continue
            }

            let fileName = fileURL.lastPathComponent

            // Check if this matches our package
            for pattern in searchPatterns {
                if fileName == pattern || fileName.hasPrefix("\(package).") && fileName.hasSuffix(".doccarchive") {
                    // Verify it's a valid .doccarchive
                    if hasValidDocCStructure(at: fileURL) {
                        return fileURL
                    }
                }
            }

            // Also check for common naming patterns like PackageName_Documentation.doccarchive
            if fileName.hasSuffix(".doccarchive") && fileName.contains(package) {
                if hasValidDocCStructure(at: fileURL) {
                    return fileURL
                }
            }
        }

        return nil
    }

    /// Find all DocC archives in DerivedData
    /// - Returns: Array of discovered DocC archive URLs with their package names
    public func findAllInDerivedData() -> [(package: String, url: URL)] {
        guard FileManager.default.fileExists(atPath: derivedDataPath.path) else {
            return []
        }

        guard let enumerator = FileManager.default.enumerator(
            at: derivedDataPath,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var results: [(String, URL)] = []

        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.isDirectoryKey]),
                  resourceValues.isDirectory == true,
                  fileURL.pathExtension == "doccarchive" else {
                continue
            }

            if hasValidDocCStructure(at: fileURL) {
                let packageName = fileURL.deletingPathExtension().lastPathComponent
                results.append((packageName, fileURL))
            }
        }

        return results
    }

    // MARK: - Private Helpers

    private func hasValidDocCStructure(at url: URL) -> Bool {
        // .doccarchive directories typically contain:
        // - data/ directory with JSON documentation
        // - index/ directory with search index
        let dataDir = url.appendingPathComponent("data", isDirectory: true)
        let indexDir = url.appendingPathComponent("index", isDirectory: true)

        return FileManager.default.fileExists(atPath: dataDir.path) ||
               FileManager.default.fileExists(atPath: indexDir.path)
    }
}
