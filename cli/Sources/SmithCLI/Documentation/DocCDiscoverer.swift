import Foundation

// MARK: - DocC Discoverer

/// Main API for discovering DocC documentation for Swift packages
/// Follows a priority chain: Cache → Xcode DerivedData → SPM Cache → GitHub Source (cloned)
public struct DocCDiscoverer: Sendable {
    private let cache: DocCCache
    private let xcodeFinder: XcodeDocCFinder
    private let spmFinder: SPMCacheFinder
    private let gitHubFetcher: GitHubDocCFetcher

    public init(
        cache: DocCCache = DocCCache(),
        xcodeFinder: XcodeDocCFinder = XcodeDocCFinder(),
        spmFinder: SPMCacheFinder = SPMCacheFinder(),
        gitHubFetcher: GitHubDocCFetcher = GitHubDocCFetcher()
    ) {
        self.cache = cache
        self.xcodeFinder = xcodeFinder
        self.spmFinder = spmFinder
        self.gitHubFetcher = gitHubFetcher
    }

    // MARK: - Public API

    /// Synchronous discovery - checks cache and local sources only (no network)
    /// - Parameters:
    ///   - package: Package name (e.g., "ComposableArchitecture")
    ///   - version: Version string (e.g., "1.24.0")
    /// - Returns: DocCResult if found locally, nil otherwise
    public func discoverSync(package: String, version: String) -> DocCResult? {
        // Phase 1: Check cache (0 tokens, instant)
        if let cachedURL = cache.retrieve(package: package, version: version) {
            return DocCResult(
                source: .cache,
                archiveURL: cachedURL,
                cost: 0,
                isLocal: true
            )
        }

        // Phase 2a: Check Xcode DerivedData (0-100 tokens)
        if let xcodePath = xcodeFinder.findInDerivedData(package: package, version: version) {
            // Found locally, copy to persistent cache
            do {
                try cache.store(source: xcodePath, package: package, version: version)
                if let cachedURL = cache.retrieve(package: package, version: version) {
                    return DocCResult(
                        source: .xcodeDerivedData,
                        archiveURL: cachedURL,
                        cost: 100,
                        isLocal: true
                    )
                }
            } catch {
                // If caching fails, still return the Xcode path
                return DocCResult(
                    source: .xcodeDerivedData,
                    archiveURL: xcodePath,
                    cost: 100,
                    isLocal: true
                )
            }
        }

        // Phase 2b: Check SPM cache (0 tokens, instant)
        if let spmPath = spmFinder.findInSPMCache(package: package, version: version) {
            // Found locally, copy to persistent cache
            do {
                try cache.store(source: spmPath, package: package, version: version)
                if let cachedURL = cache.retrieve(package: package, version: version) {
                    return DocCResult(
                        source: .spmCache,
                        archiveURL: cachedURL,
                        cost: 0,
                        isLocal: true
                    )
                }
            } catch {
                // If caching fails, still return the SPM path
                return DocCResult(
                    source: .spmCache,
                    archiveURL: spmPath,
                    cost: 0,
                    isLocal: true
                )
            }
        }

        return nil
    }

    /// Discover DocC documentation for a package (async, includes GitHub)
    /// - Parameters:
    ///   - package: Package name (e.g., "ComposableArchitecture")
    ///   - version: Version string (e.g., "1.24.0")
    ///   - owner: GitHub owner (default: "pointfreeco")
    ///   - repo: GitHub repository name (default: same as package)
    /// - Returns: DocCResult if found, nil if not available
    public func discover(
        package: String,
        version: String,
        owner: String = "pointfreeco",
        repo: String? = nil
    ) async throws -> DocCResult? {
        let repoName = repo ?? package

        // Phase 1: Check cache (0 tokens, instant)
        if let cachedURL = cache.retrieve(package: package, version: version) {
            return DocCResult(
                source: .cache,
                archiveURL: cachedURL,
                cost: 0,
                isLocal: true
            )
        }

        // Phase 2a: Check Xcode DerivedData (0-100 tokens)
        if let xcodePath = xcodeFinder.findInDerivedData(package: package, version: version) {
            // Found locally, copy to persistent cache
            do {
                try cache.store(source: xcodePath, package: package, version: version)
                if let cachedURL = cache.retrieve(package: package, version: version) {
                    return DocCResult(
                        source: .xcodeDerivedData,
                        archiveURL: cachedURL,
                        cost: 100,
                        isLocal: true
                    )
                }
            } catch {
                // If caching fails, still return the Xcode path
                return DocCResult(
                    source: .xcodeDerivedData,
                    archiveURL: xcodePath,
                    cost: 100,
                    isLocal: true
                )
            }
        }

        // Phase 2b: Check SPM cache (0 tokens, instant)
        if let spmPath = spmFinder.findInSPMCache(package: package, version: version) {
            // Found locally, copy to persistent cache
            do {
                try cache.store(source: spmPath, package: package, version: version)
                if let cachedURL = cache.retrieve(package: package, version: version) {
                    return DocCResult(
                        source: .spmCache,
                        archiveURL: cachedURL,
                        cost: 0,
                        isLocal: true
                    )
                }
            } catch {
                // If caching fails, still return the SPM path
                return DocCResult(
                    source: .spmCache,
                    archiveURL: spmPath,
                    cost: 0,
                    isLocal: true
                )
            }
        }

        // Phase 3: Clone from GitHub and find Documentation.docc in source (250 tokens)
        guard let docURL = try await gitHubFetcher.cloneAndFindDocs(
            owner: owner,
            repo: repoName,
            version: version,
            package: package,
            to: DocCCache.defaultCacheDirectory
        ) else {
            // This version doesn't have .docc in source
            return nil
        }

        return DocCResult(
            source: .github,
            archiveURL: docURL,
            cost: 250, // shallow clone + find + cache
            isLocal: false
        )
    }

    /// Discover documentation for multiple packages sequentially
    /// - Parameters:
    ///   - packages: Array of (name, version) tuples
    ///   - owner: GitHub owner for all packages
    /// - Returns: Dictionary mapping package name to DocCResult (or nil)
    public func discoverMultiple(
        packages: [(name: String, version: String)],
        owner: String = "pointfreeco"
    ) async throws -> [String: DocCResult?] {
        var results: [String: DocCResult?] = [:]

        for (name, version) in packages {
            let result = try await discover(
                package: name,
                version: version,
                owner: owner
            )
            results[name] = result
        }

        return results
    }

    /// List all cached documentation
    public func listCached() -> [(package: String, version: String)] {
        cache.listCached()
    }

    /// Clear all cached documentation
    public func clearCache() throws {
        try cache.clearAll()
    }

    /// Clear cache for a specific package
    public func clearCache(for package: String) throws {
        try cache.clear(package: package)
    }
}

// MARK: - Utility Extensions

extension DocCResult {
    /// Human-readable description of the source
    public var sourceDescription: String {
        switch source {
        case .cache:
            return "cached"
        case .xcodeDerivedData:
            return "Xcode DerivedData"
        case .spmCache:
            return "SPM cache"
        case .github:
            return "GitHub release"
        }
    }

    /// Status icon for display
    public var statusIcon: String {
        switch source {
        case .cache:
            return "📦"
        case .xcodeDerivedData:
            return "🔨"
        case .spmCache:
            return "📚"
        case .github:
            return "⬇️"
        }
    }
}

// MARK: - Package URL Parsing

extension DocCDiscoverer {
    /// Extract owner and repo from a GitHub URL
    /// - Parameter url: GitHub URL (e.g., "https://github.com/pointfreeco/swift-composable-architecture")
    /// - Returns: Tuple of (owner, repo) if parseable
    public static func parseGitHubURL(_ url: String) -> (owner: String, repo: String)? {
        // Handle various URL formats:
        // https://github.com/owner/repo
        // https://github.com/owner/repo.git
        // git@github.com:owner/repo.git

        var cleanURL = url
            .replacingOccurrences(of: ".git", with: "")
            .replacingOccurrences(of: "git@github.com:", with: "https://github.com/")

        // Remove trailing slashes
        while cleanURL.hasSuffix("/") {
            cleanURL.removeLast()
        }

        // Parse the URL
        guard let urlComponents = URLComponents(string: cleanURL),
              urlComponents.host == "github.com" else {
            return nil
        }

        let pathComponents = urlComponents.path.split(separator: "/")
        guard pathComponents.count >= 2 else {
            return nil
        }

        let owner = String(pathComponents[0])
        let repo = String(pathComponents[1])

        return (owner, repo)
    }
}
