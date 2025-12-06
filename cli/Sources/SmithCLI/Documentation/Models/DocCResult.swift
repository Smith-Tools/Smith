import Foundation

// MARK: - DocC Result Models

/// Represents the result of a DocC discovery operation
public struct DocCResult: Sendable {
    /// Where the DocC archive was found
    public enum Source: String, Sendable {
        /// Found in local cache (~/.cache/smith/docc/)
        case cache = "cache"
        /// Found in Xcode's DerivedData
        case xcodeDerivedData = "xcode"
        /// Found in SPM cache (~/.cache/swift-package-manager/repositories/)
        case spmCache = "spm"
        /// Downloaded from GitHub release
        case github = "github"
    }

    /// The source where the documentation was found
    public let source: Source

    /// Path to the .doccarchive directory
    public let archiveURL: URL

    /// Token cost estimate for this discovery (0 if cached/local)
    public let cost: Int

    /// Whether the documentation was found locally (no download required)
    public let isLocal: Bool

    public init(source: Source, archiveURL: URL, cost: Int, isLocal: Bool) {
        self.source = source
        self.archiveURL = archiveURL
        self.cost = cost
        self.isLocal = isLocal
    }
}

// MARK: - DocC Errors

/// Errors that can occur during DocC discovery
public enum DocCError: Error, LocalizedError {
    /// Cache directory could not be created
    case cacheCreationFailed(underlying: Error)

    /// Failed to copy archive to cache
    case cacheCopyFailed(source: URL, underlying: Error)

    /// GitHub CLI (gh) is not available
    case ghCLINotFound

    /// GitHub release not found for version
    case releaseNotFound(owner: String, repo: String, version: String)

    /// No .doccarchive asset in release
    case docCNotPublished(owner: String, repo: String, version: String)

    /// Download failed
    case downloadFailed(url: URL, underlying: Error)

    /// Extraction failed (for zip files)
    case extractionFailed(file: URL, underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .cacheCreationFailed(let error):
            return "Failed to create cache directory: \(error.localizedDescription)"
        case .cacheCopyFailed(let source, let error):
            return "Failed to copy \(source.lastPathComponent) to cache: \(error.localizedDescription)"
        case .ghCLINotFound:
            return "GitHub CLI (gh) not found. Install with: brew install gh"
        case .releaseNotFound(let owner, let repo, let version):
            return "Release \(version) not found for \(owner)/\(repo)"
        case .docCNotPublished(let owner, let repo, let version):
            return "No .doccarchive published for \(owner)/\(repo)@\(version)"
        case .downloadFailed(let url, let error):
            return "Failed to download \(url.lastPathComponent): \(error.localizedDescription)"
        case .extractionFailed(let file, let error):
            return "Failed to extract \(file.lastPathComponent): \(error.localizedDescription)"
        }
    }
}
