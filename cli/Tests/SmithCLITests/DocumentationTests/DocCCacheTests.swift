import XCTest
@testable import SmithCLI

final class DocCCacheTests: XCTestCase {
    var tempDir: URL!
    var cache: DocCCache!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("DocCCacheTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        cache = DocCCache(cacheDirectory: tempDir)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    // MARK: - Retrieve Tests

    func testRetrieve_WhenNotCached_ReturnsNil() {
        let result = cache.retrieve(package: "NonExistent", version: "1.0.0")
        XCTAssertNil(result)
    }

    func testRetrieve_WhenCached_ReturnsURL() throws {
        // Create a mock .doccarchive with valid structure
        let mockArchive = createMockDocCArchive(package: "TestPackage", version: "1.0.0")

        // Store it
        try cache.store(source: mockArchive, package: "TestPackage", version: "1.0.0")

        // Retrieve it
        let result = cache.retrieve(package: "TestPackage", version: "1.0.0")
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.path.contains("TestPackage-1.0.0.doccarchive"))
    }

    func testRetrieve_WithDifferentVersion_ReturnsNil() throws {
        let mockArchive = createMockDocCArchive(package: "TestPackage", version: "1.0.0")
        try cache.store(source: mockArchive, package: "TestPackage", version: "1.0.0")

        let result = cache.retrieve(package: "TestPackage", version: "2.0.0")
        XCTAssertNil(result)
    }

    // MARK: - Store Tests

    func testStore_CreatesArchiveInCache() throws {
        let mockArchive = createMockDocCArchive(package: "MyLib", version: "0.5.0")
        try cache.store(source: mockArchive, package: "MyLib", version: "0.5.0")

        let expectedPath = tempDir.appendingPathComponent("MyLib-0.5.0.doccarchive")
        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedPath.path))
    }

    func testStore_OverwritesExisting() throws {
        let mockArchive1 = createMockDocCArchive(package: "MyLib", version: "1.0.0")
        try cache.store(source: mockArchive1, package: "MyLib", version: "1.0.0")

        let mockArchive2 = createMockDocCArchive(package: "MyLib", version: "1.0.0")
        try cache.store(source: mockArchive2, package: "MyLib", version: "1.0.0")

        // Should still only have one entry
        let cached = cache.listCached()
        let matching = cached.filter { $0.package == "MyLib" && $0.version == "1.0.0" }
        XCTAssertEqual(matching.count, 1)
    }

    // MARK: - List Tests

    func testListCached_WhenEmpty_ReturnsEmptyArray() {
        let result = cache.listCached()
        XCTAssertTrue(result.isEmpty)
    }

    func testListCached_ReturnsAllCachedPackages() throws {
        let mock1 = createMockDocCArchive(package: "PackageA", version: "1.0.0")
        let mock2 = createMockDocCArchive(package: "PackageB", version: "2.0.0")
        let mock3 = createMockDocCArchive(package: "PackageA", version: "1.1.0")

        try cache.store(source: mock1, package: "PackageA", version: "1.0.0")
        try cache.store(source: mock2, package: "PackageB", version: "2.0.0")
        try cache.store(source: mock3, package: "PackageA", version: "1.1.0")

        let result = cache.listCached()
        XCTAssertEqual(result.count, 3)
    }

    // MARK: - Clear Tests

    func testClearAll_RemovesAllCachedPackages() throws {
        let mock1 = createMockDocCArchive(package: "PackageA", version: "1.0.0")
        let mock2 = createMockDocCArchive(package: "PackageB", version: "2.0.0")

        try cache.store(source: mock1, package: "PackageA", version: "1.0.0")
        try cache.store(source: mock2, package: "PackageB", version: "2.0.0")

        try cache.clearAll()

        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.path))
    }

    func testClear_ForPackage_RemovesOnlyThatPackage() throws {
        let mock1 = createMockDocCArchive(package: "PackageA", version: "1.0.0")
        let mock2 = createMockDocCArchive(package: "PackageB", version: "2.0.0")
        let mock3 = createMockDocCArchive(package: "PackageA", version: "1.1.0")

        try cache.store(source: mock1, package: "PackageA", version: "1.0.0")
        try cache.store(source: mock2, package: "PackageB", version: "2.0.0")
        try cache.store(source: mock3, package: "PackageA", version: "1.1.0")

        try cache.clear(package: "PackageA")

        let result = cache.listCached()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.package, "PackageB")
    }

    // MARK: - Helpers

    private func createMockDocCArchive(package: String, version: String) -> URL {
        let archiveDir = tempDir
            .appendingPathComponent("mock-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("\(package)-\(version).doccarchive", isDirectory: true)

        // Create a valid .doccarchive structure
        let dataDir = archiveDir.appendingPathComponent("data", isDirectory: true)
        let indexDir = archiveDir.appendingPathComponent("index", isDirectory: true)

        try? FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: indexDir, withIntermediateDirectories: true)

        // Add a dummy file
        let dummyFile = dataDir.appendingPathComponent("documentation.json")
        try? "{}".write(to: dummyFile, atomically: true, encoding: .utf8)

        return archiveDir
    }
}
