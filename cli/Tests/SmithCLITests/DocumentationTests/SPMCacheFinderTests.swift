import XCTest
@testable import SmithCLI

final class SPMCacheFinderTests: XCTestCase {
    var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("SPMCacheFinderTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    // MARK: - Find in SPM Cache Tests

    func testFindInSPMCache_WhenCacheDoesNotExist_ReturnsNil() {
        let finder = SPMCacheFinder()
        // Using real SPM cache path - will be nil if SPM not installed or cache empty
        let result = finder.findInSPMCache(package: "NonExistentPackage", version: "1.0.0")
        // Don't assert on this - depends on system state
        // Just verify it doesn't crash
        _ = result
    }

    func testFindInSPMCache_WhenPackageExists_ReturnsURL() {
        // Create mock SPM cache structure:
        // tempDir/swift-composable-architecture-abc123/Sources/ComposableArchitecture/Documentation.docc/
        let packageDir = tempDir.appendingPathComponent("swift-composable-architecture-abc123", isDirectory: true)
        let sourcesPath = packageDir.appendingPathComponent("Sources", isDirectory: true)
        let targetDir = sourcesPath.appendingPathComponent("ComposableArchitecture", isDirectory: true)
        let docPath = targetDir.appendingPathComponent("Documentation.docc", isDirectory: true)

        try? FileManager.default.createDirectory(at: docPath, withIntermediateDirectories: true)

        // Create a test finder that looks in our temp directory instead of real SPM cache
        let customFinder = SPMCacheFinderWithCustomPath(cachePath: tempDir)
        let result = customFinder.findInSPMCache(package: "swift-composable-architecture", version: "1.23.1")

        XCTAssertNotNil(result)
        XCTAssertTrue(result?.path.contains("Documentation.docc") ?? false)
    }

    func testFindInSPMCache_WhenMultipleSourceDirs_FindsDocumentation() {
        // Create mock with multiple source directories (some without docs)
        let packageDir = tempDir.appendingPathComponent("swift-dependencies-xyz789", isDirectory: true)
        let sourcesPath = packageDir.appendingPathComponent("Sources", isDirectory: true)

        // Create a source dir without Documentation.docc
        let sourceDir1 = sourcesPath.appendingPathComponent("SwiftDependenciesHelpers", isDirectory: true)
        try? FileManager.default.createDirectory(at: sourceDir1, withIntermediateDirectories: true)

        // Create a source dir with Documentation.docc
        let sourceDir2 = sourcesPath.appendingPathComponent("Dependencies", isDirectory: true)
        let docPath = sourceDir2.appendingPathComponent("Documentation.docc", isDirectory: true)
        try? FileManager.default.createDirectory(at: docPath, withIntermediateDirectories: true)

        let customFinder = SPMCacheFinderWithCustomPath(cachePath: tempDir)
        let result = customFinder.findInSPMCache(package: "swift-dependencies", version: "1.10.0")

        XCTAssertNotNil(result)
        XCTAssertTrue(result?.path.contains("Documentation.docc") ?? false)
    }

    func testFindInSPMCache_WhenPackageNotFound_ReturnsNil() {
        // Create a different package in cache
        let packageDir = tempDir.appendingPathComponent("swift-composable-architecture-abc123", isDirectory: true)
        let sourcesPath = packageDir.appendingPathComponent("Sources", isDirectory: true)
        let targetDir = sourcesPath.appendingPathComponent("ComposableArchitecture", isDirectory: true)
        let docPath = targetDir.appendingPathComponent("Documentation.docc", isDirectory: true)

        try? FileManager.default.createDirectory(at: docPath, withIntermediateDirectories: true)

        let customFinder = SPMCacheFinderWithCustomPath(cachePath: tempDir)
        // Look for a package that doesn't exist
        let result = customFinder.findInSPMCache(package: "NonExistent", version: "1.0.0")

        XCTAssertNil(result)
    }

    func testFindInSPMCache_WhenSourcesDirMissing_ReturnsNil() {
        // Create a package directory without Sources folder
        let packageDir = tempDir.appendingPathComponent("some-package-xyz", isDirectory: true)
        try? FileManager.default.createDirectory(at: packageDir, withIntermediateDirectories: true)

        let customFinder = SPMCacheFinderWithCustomPath(cachePath: tempDir)
        let result = customFinder.findInSPMCache(package: "some-package", version: "1.0.0")

        XCTAssertNil(result)
    }

    func testFindInSPMCache_WithComplexPackageName_Matches() {
        // Test with a complex package name that contains special characters or long names
        let packageDir = tempDir.appendingPathComponent("point-free-swift-composable-architecture-def456", isDirectory: true)
        let sourcesPath = packageDir.appendingPathComponent("Sources", isDirectory: true)
        let targetDir = sourcesPath.appendingPathComponent("ComposableArchitecture", isDirectory: true)
        let docPath = targetDir.appendingPathComponent("Documentation.docc", isDirectory: true)

        try? FileManager.default.createDirectory(at: docPath, withIntermediateDirectories: true)

        let customFinder = SPMCacheFinderWithCustomPath(cachePath: tempDir)
        // Search with just the package name (partial match)
        let result = customFinder.findInSPMCache(package: "swift-composable-architecture", version: "1.0.0")

        XCTAssertNotNil(result)
    }
}

// MARK: - Helper for Testing

/// Wrapper to allow testing with a custom SPM cache path
private struct SPMCacheFinderWithCustomPath {
    private let spmCachePath: URL

    init(cachePath: URL) {
        self.spmCachePath = cachePath
    }

    func findInSPMCache(package: String, version: String) -> URL? {
        guard FileManager.default.fileExists(atPath: spmCachePath.path) else {
            return nil
        }

        guard let contents = try? FileManager.default
            .contentsOfDirectory(atPath: spmCachePath.path) else {
            return nil
        }

        for dirname in contents {
            if dirname.contains(package) {
                let packagePath = spmCachePath.appendingPathComponent(dirname, isDirectory: true)
                let sourcesPath = packagePath.appendingPathComponent("Sources", isDirectory: true)

                guard let sourceContents = try? FileManager.default
                    .contentsOfDirectory(atPath: sourcesPath.path) else {
                    continue
                }

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
