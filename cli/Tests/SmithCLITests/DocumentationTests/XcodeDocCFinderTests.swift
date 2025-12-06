import XCTest
@testable import SmithCLI

final class XcodeDocCFinderTests: XCTestCase {
    var tempDir: URL!
    var finder: XcodeDocCFinder!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("XcodeDocCFinderTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        finder = XcodeDocCFinder(derivedDataPath: tempDir)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    // MARK: - Find Tests

    func testFind_WhenDerivedDataEmpty_ReturnsNil() {
        let result = finder.findInDerivedData(package: "NonExistent")
        XCTAssertNil(result)
    }

    func testFind_WhenDerivedDataDoesNotExist_ReturnsNil() {
        let nonexistentPath = tempDir.appendingPathComponent("nonexistent", isDirectory: true)
        let finderWithBadPath = XcodeDocCFinder(derivedDataPath: nonexistentPath)

        let result = finderWithBadPath.findInDerivedData(package: "Test")
        XCTAssertNil(result)
    }

    func testFind_WhenPackageExists_ReturnsURL() {
        // Create mock DerivedData structure
        createMockDerivedDataArchive(package: "ComposableArchitecture")

        let result = finder.findInDerivedData(package: "ComposableArchitecture")
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.path.contains("ComposableArchitecture.doccarchive"))
    }

    func testFind_WhenPackageExistsNested_ReturnsURL() {
        // Create a more realistic DerivedData structure
        let projectDir = tempDir.appendingPathComponent("MyApp-abcdef123456", isDirectory: true)
        let buildDir = projectDir.appendingPathComponent("Build/Products/Debug", isDirectory: true)
        let archiveDir = buildDir.appendingPathComponent("MyPackage.doccarchive", isDirectory: true)
        let dataDir = archiveDir.appendingPathComponent("data", isDirectory: true)

        try? FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)

        let result = finder.findInDerivedData(package: "MyPackage")
        XCTAssertNotNil(result)
    }

    // MARK: - Find All Tests

    func testFindAll_WhenEmpty_ReturnsEmptyArray() {
        let result = finder.findAllInDerivedData()
        XCTAssertTrue(result.isEmpty)
    }

    func testFindAll_ReturnsAllArchives() {
        createMockDerivedDataArchive(package: "PackageA")
        createMockDerivedDataArchive(package: "PackageB")
        createMockDerivedDataArchive(package: "PackageC")

        let result = finder.findAllInDerivedData()
        XCTAssertEqual(result.count, 3)

        let names = result.map { $0.package }
        XCTAssertTrue(names.contains("PackageA"))
        XCTAssertTrue(names.contains("PackageB"))
        XCTAssertTrue(names.contains("PackageC"))
    }

    func testFindAll_SkipsInvalidArchives() {
        // Create a valid archive
        createMockDerivedDataArchive(package: "ValidPackage")

        // Create an invalid archive (no data/index directories)
        let invalidDir = tempDir.appendingPathComponent("Invalid.doccarchive", isDirectory: true)
        try? FileManager.default.createDirectory(at: invalidDir, withIntermediateDirectories: true)

        let result = finder.findAllInDerivedData()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.package, "ValidPackage")
    }

    // MARK: - Helpers

    private func createMockDerivedDataArchive(package: String) {
        let archiveDir = tempDir.appendingPathComponent("\(package).doccarchive", isDirectory: true)
        let dataDir = archiveDir.appendingPathComponent("data", isDirectory: true)
        let indexDir = archiveDir.appendingPathComponent("index", isDirectory: true)

        try? FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: indexDir, withIntermediateDirectories: true)

        // Add a dummy file to make it look real
        let dummyFile = dataDir.appendingPathComponent("documentation.json")
        try? "{}".write(to: dummyFile, atomically: true, encoding: .utf8)
    }
}
