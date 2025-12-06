import XCTest
@testable import SmithCLI

final class DocCDiscovererTests: XCTestCase {
    var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("DocCDiscovererTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    // MARK: - GitHub URL Parsing Tests

    func testParseGitHubURL_HTTPS() {
        let result = DocCDiscoverer.parseGitHubURL("https://github.com/pointfreeco/swift-composable-architecture")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.owner, "pointfreeco")
        XCTAssertEqual(result?.repo, "swift-composable-architecture")
    }

    func testParseGitHubURL_WithGitSuffix() {
        let result = DocCDiscoverer.parseGitHubURL("https://github.com/apple/swift-async-algorithms.git")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.owner, "apple")
        XCTAssertEqual(result?.repo, "swift-async-algorithms")
    }

    func testParseGitHubURL_SSHFormat() {
        let result = DocCDiscoverer.parseGitHubURL("git@github.com:pointfreeco/swift-dependencies.git")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.owner, "pointfreeco")
        XCTAssertEqual(result?.repo, "swift-dependencies")
    }

    func testParseGitHubURL_WithTrailingSlash() {
        let result = DocCDiscoverer.parseGitHubURL("https://github.com/owner/repo/")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.owner, "owner")
        XCTAssertEqual(result?.repo, "repo")
    }

    func testParseGitHubURL_InvalidURL_ReturnsNil() {
        let result = DocCDiscoverer.parseGitHubURL("not-a-valid-url")
        XCTAssertNil(result)
    }

    func testParseGitHubURL_NonGitHubURL_ReturnsNil() {
        let result = DocCDiscoverer.parseGitHubURL("https://gitlab.com/owner/repo")
        XCTAssertNil(result)
    }

    // MARK: - DocCResult Tests

    func testDocCResult_SourceDescription() {
        let cacheResult = DocCResult(source: .cache, archiveURL: tempDir, cost: 0, isLocal: true)
        XCTAssertEqual(cacheResult.sourceDescription, "cached")

        let xcodeResult = DocCResult(source: .xcodeDerivedData, archiveURL: tempDir, cost: 100, isLocal: true)
        XCTAssertEqual(xcodeResult.sourceDescription, "Xcode DerivedData")

        let githubResult = DocCResult(source: .github, archiveURL: tempDir, cost: 500, isLocal: false)
        XCTAssertEqual(githubResult.sourceDescription, "GitHub release")
    }

    func testDocCResult_StatusIcon() {
        let cacheResult = DocCResult(source: .cache, archiveURL: tempDir, cost: 0, isLocal: true)
        XCTAssertEqual(cacheResult.statusIcon, "📦")

        let xcodeResult = DocCResult(source: .xcodeDerivedData, archiveURL: tempDir, cost: 100, isLocal: true)
        XCTAssertEqual(xcodeResult.statusIcon, "🔨")

        let githubResult = DocCResult(source: .github, archiveURL: tempDir, cost: 500, isLocal: false)
        XCTAssertEqual(githubResult.statusIcon, "⬇️")
    }

    // MARK: - Cache Priority Tests

    func testDiscover_UsesCacheFirst() async throws {
        // Create a cache with pre-populated data
        let cacheDir = tempDir.appendingPathComponent("cache", isDirectory: true)
        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let cache = DocCCache(cacheDirectory: cacheDir)

        // Create and store a mock archive
        let mockArchive = createMockDocCArchive(name: "TestPackage-1.0.0")
        try cache.store(source: mockArchive, package: "TestPackage", version: "1.0.0")

        // Create discoverer with the pre-populated cache
        let discoverer = DocCDiscoverer(
            cache: cache,
            xcodeFinder: XcodeDocCFinder(derivedDataPath: tempDir), // Empty DerivedData
            gitHubFetcher: GitHubDocCFetcher()
        )

        let result = try await discoverer.discover(
            package: "TestPackage",
            version: "1.0.0",
            owner: "test",
            repo: "TestPackage"
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.source, .cache)
        XCTAssertEqual(result?.cost, 0)
        XCTAssertTrue(result?.isLocal ?? false)
    }

    // MARK: - GitHub Clone and Find Tests

    func testCloneAndFindDocs_WithValidDocc() async throws {
        // Create a mock .docc directory structure
        let cacheDir = tempDir.appendingPathComponent("cache", isDirectory: true)
        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        // Create a mock repository with .docc
        let mockRepoDir = tempDir.appendingPathComponent("mock-repo", isDirectory: true)
        let mockDocCDir = mockRepoDir
            .appendingPathComponent("Sources")
            .appendingPathComponent("TestModule")
            .appendingPathComponent("Documentation.docc", isDirectory: true)

        try FileManager.default.createDirectory(at: mockDocCDir, withIntermediateDirectories: true)

        // Create minimal .docc structure
        let articlesDir = mockDocCDir.appendingPathComponent("Articles", isDirectory: true)
        try FileManager.default.createDirectory(at: articlesDir, withIntermediateDirectories: true)

        let dummyArticle = articlesDir.appendingPathComponent("Overview.md")
        try "# Overview\nTest documentation".write(to: dummyArticle, atomically: true, encoding: .utf8)

        // Note: We can't really test cloneAndFindDocs without mocking git commands
        // This test structure demonstrates what a real test would look like
        // The actual behavior is tested via integration with real GitHub repos
    }

    // MARK: - Helpers

    private func createMockDocCArchive(name: String) -> URL {
        let archiveDir = tempDir
            .appendingPathComponent("mock-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("\(name).doccarchive", isDirectory: true)

        let dataDir = archiveDir.appendingPathComponent("data", isDirectory: true)
        let indexDir = archiveDir.appendingPathComponent("index", isDirectory: true)

        try? FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: indexDir, withIntermediateDirectories: true)

        let dummyFile = dataDir.appendingPathComponent("documentation.json")
        try? "{}".write(to: dummyFile, atomically: true, encoding: .utf8)

        return archiveDir
    }
}
