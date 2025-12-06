import Foundation

// MARK: - SPM Cache Finder

/// Searches for DocC documentation in the Swift Package Manager local cache
/// SPM stores downloaded packages at: ~/.cache/swift-package-manager/repositories/
public struct SPMCacheFinder: Sendable {
    private let spmCachePath: URL

    public init() {
        self.spmCachePath = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".cache/swift-package-manager/repositories", isDirectory: true)
    }

    /// Find Documentation.docc in SPM cache
    /// - Parameters:
    ///   - package: Package name (e.g., "swift-composable-architecture")
    ///   - version: Version string (unused but kept for API consistency)
    /// - Returns: URL to Documentation.docc if found, nil otherwise
    /// - Cost: 0 tokens (already cached by SPM)
    /// - Time: <100ms
    public func findInSPMCache(package: String, version: String) -> URL? {
        guard FileManager.default.fileExists(atPath: spmCachePath.path) else {
            return nil
        }

        guard let contents = try? FileManager.default
            .contentsOfDirectory(atPath: spmCachePath.path) else {
            return nil
        }

        // SPM stores packages as: package-COMMITHASH/
        // Example: swift-composable-architecture-abc123def456efgh/
        for dirname in contents {
            // Match directory name containing the package name
            if dirname.contains(package) {
                let packagePath = spmCachePath.appendingPathComponent(dirname, isDirectory: true)
                let sourcesPath = packagePath.appendingPathComponent("Sources", isDirectory: true)

                guard let sourceContents = try? FileManager.default
                    .contentsOfDirectory(atPath: sourcesPath.path) else {
                    continue
                }

                // Search for Documentation.docc in Sources/*/
                // Pattern: Sources/{TargetName}/Documentation.docc/
                for sourceDir in sourceContents {
                    let docPath = sourcesPath
                        .appendingPathComponent(sourceDir, isDirectory: true)
                        .appendingPathComponent("Documentation.docc", isDirectory: true)

                    if FileManager.default.fileExists(atPath: docPath.path) {
                        return docPath
                    }
                }
            }
        }

        return nil
    }
}
