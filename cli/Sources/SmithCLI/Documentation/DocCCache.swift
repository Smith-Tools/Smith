import Foundation

// MARK: - DocC Cache Manager

/// Manages the local cache for downloaded DocC archives
/// Cache location: ~/.cache/smith/docc/
public struct DocCCache: Sendable {
    /// Default cache directory
    public static let defaultCacheDirectory: URL = {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        return homeDir.appendingPathComponent(".cache/smith/docc", isDirectory: true)
    }()

    private let cacheDirectory: URL

    public init(cacheDirectory: URL = DocCCache.defaultCacheDirectory) {
        self.cacheDirectory = cacheDirectory
    }

    // MARK: - Public API

    /// Check if a package version is cached
    /// - Parameters:
    ///   - package: Package name (e.g., "ComposableArchitecture")
    ///   - version: Version string (e.g., "1.24.0")
    /// - Returns: URL to cached .doccarchive if found, nil otherwise
    public func retrieve(package: String, version: String) -> URL? {
        let cachePath = archivePath(for: package, version: version)

        // Check if the directory exists and contains expected content
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: cachePath.path, isDirectory: &isDirectory) && isDirectory.boolValue {
            // Verify it looks like a valid .doccarchive (has data subdirectory or index files)
            if hasValidDocCStructure(at: cachePath) {
                return cachePath
            }
        }
        return nil
    }

    /// Store a .doccarchive in the cache
    /// - Parameters:
    ///   - source: URL to the source .doccarchive directory
    ///   - package: Package name
    ///   - version: Version string
    /// - Throws: DocCError if storage fails
    public func store(source: URL, package: String, version: String) throws {
        // Ensure cache directory exists
        try ensureCacheDirectoryExists()

        let destination = archivePath(for: package, version: version)

        // Remove existing if present
        if FileManager.default.fileExists(atPath: destination.path) {
            try? FileManager.default.removeItem(at: destination)
        }

        // Copy the .doccarchive directory
        do {
            try FileManager.default.copyItem(at: source, to: destination)
        } catch {
            throw DocCError.cacheCopyFailed(source: source, underlying: error)
        }
    }

    /// List all cached packages
    /// - Returns: Array of (package, version) tuples
    public func listCached() -> [(package: String, version: String)] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ) else {
            return []
        }

        return contents.compactMap { url -> (String, String)? in
            let name = url.deletingPathExtension().lastPathComponent
            // Expected format: PackageName-1.0.0.doccarchive
            guard url.pathExtension == "doccarchive",
                  let dashRange = name.range(of: "-", options: .backwards) else {
                return nil
            }
            let packageName = String(name[..<dashRange.lowerBound])
            let version = String(name[dashRange.upperBound...])
            return (packageName, version)
        }
    }

    /// Clear all cached documentation
    public func clearAll() throws {
        if FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try FileManager.default.removeItem(at: cacheDirectory)
        }
    }

    /// Clear cache for a specific package (all versions)
    public func clear(package: String) throws {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ) else {
            return
        }

        for url in contents {
            let name = url.deletingPathExtension().lastPathComponent
            if name.hasPrefix("\(package)-") {
                try FileManager.default.removeItem(at: url)
            }
        }
    }

    // MARK: - Private Helpers

    private func archivePath(for package: String, version: String) -> URL {
        cacheDirectory.appendingPathComponent("\(package)-\(version).doccarchive", isDirectory: true)
    }

    private func ensureCacheDirectoryExists() throws {
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            } catch {
                throw DocCError.cacheCreationFailed(underlying: error)
            }
        }
    }

    private func hasValidDocCStructure(at url: URL) -> Bool {
        // .doccarchive directories typically contain:
        // - data/ directory with JSON documentation
        // - index/ directory with search index
        // - metadata.json
        let dataDir = url.appendingPathComponent("data", isDirectory: true)
        let indexDir = url.appendingPathComponent("index", isDirectory: true)

        return FileManager.default.fileExists(atPath: dataDir.path) ||
               FileManager.default.fileExists(atPath: indexDir.path)
    }
}
