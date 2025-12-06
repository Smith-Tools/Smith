import Foundation

// MARK: - GitHub DocC Fetcher

/// Fetches DocC archives from GitHub releases using the `gh` CLI
public struct GitHubDocCFetcher: Sendable {

    public init() {}

    // MARK: - Public API

    /// Check if a GitHub release has a .doccarchive asset
    /// - Parameters:
    ///   - owner: Repository owner (e.g., "pointfreeco")
    ///   - repo: Repository name (e.g., "swift-composable-architecture")
    ///   - version: Version tag (e.g., "1.24.0")
    /// - Returns: URL to download the asset, or nil if not available
    public func checkRelease(
        owner: String,
        repo: String,
        version: String
    ) async throws -> (assetURL: URL, assetName: String)? {
        // Verify gh CLI is available
        guard ghCLIAvailable() else {
            throw DocCError.ghCLINotFound
        }

        // Query release assets
        // gh release view {version} --repo {owner}/{repo} --json assets -q '.assets[].name'
        let command = "gh release view \(version) --repo \(owner)/\(repo) --json assets -q '.assets[] | \"\\(.name):\\(.url)\"'"

        let (output, exitCode) = await runShellCommand(command)

        // Exit code 1 usually means release not found
        if exitCode != 0 {
            // Check if it's a "release not found" vs other error
            if output.contains("release not found") {
                throw DocCError.releaseNotFound(owner: owner, repo: repo, version: version)
            }
            // Other errors might be network/auth - return nil to skip this source
            return nil
        }

        // Parse output looking for .doccarchive
        // Output format: "AssetName.doccarchive.zip:https://..."
        let lines = output.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains(".doccarchive") {
                // Parse name:url format
                let parts = trimmed.components(separatedBy: ":")
                if parts.count >= 2 {
                    let assetName = parts[0]
                    // URL may contain colons (https://...), so rejoin
                    let urlString = parts.dropFirst().joined(separator: ":")
                    if let url = URL(string: urlString) {
                        return (url, assetName)
                    }
                }
            }
        }

        // No .doccarchive asset found in this release
        return nil
    }

    /// Clone a repository and find Documentation.docc in the source
    /// - Parameters:
    ///   - owner: Repository owner (e.g., "pointfreeco")
    ///   - repo: Repository name (e.g., "swift-composable-architecture")
    ///   - version: Version tag (e.g., "1.23.1")
    ///   - package: Package name for cache naming
    ///   - destinationDir: Directory to store the documentation
    /// - Returns: URL to the found .docc directory, or nil if not found
    public func cloneAndFindDocs(
        owner: String,
        repo: String,
        version: String,
        package: String,
        to destinationDir: URL
    ) async throws -> URL? {
        // Verify git is available
        guard gitAvailable() else {
            throw DocCError.ghCLINotFound  // Reuse error, git is also required
        }

        // Create temp directory for clone
        let tempCloneDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("smith-docc-clone-\(UUID().uuidString)", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: tempCloneDir, withIntermediateDirectories: true)
        } catch {
            throw DocCError.downloadFailed(url: URL(string: "https://github.com/\(owner)/\(repo)")!, underlying: error)
        }

        defer {
            try? FileManager.default.removeItem(at: tempCloneDir)
        }

        // Shallow clone with minimal download
        let cloneCommand = """
        git clone \
            --depth 1 \
            --branch \(version) \
            --filter=blob:none \
            https://github.com/\(owner)/\(repo).git \
            "\(tempCloneDir.path)"
        """

        let (cloneOutput, cloneExitCode) = await runShellCommand(cloneCommand)

        if cloneExitCode != 0 {
            // Check if it's a "branch not found" error
            if cloneOutput.lowercased().contains("not found") || cloneOutput.lowercased().contains("unknown revision") {
                return nil  // Version not found, not an error
            }
            return nil  // Clone failed for other reasons
        }

        // Search for any *.docc directory in the cloned source
        // This handles different naming conventions (Documentation.docc, ModuleName.docc, etc.)
        let findDocCommand = "find \"\(tempCloneDir.path)\" -name '*.docc' -type d | head -1"
        let (findOutput, findExitCode) = await runShellCommand(findDocCommand)

        guard findExitCode == 0, !findOutput.isEmpty else {
            return nil  // No .docc directory found
        }

        let docSourcePath = findOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        let docSourceURL = URL(fileURLWithPath: docSourcePath)

        // Verify it's a valid .docc directory
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: docSourcePath, isDirectory: &isDir),
              isDir.boolValue else {
            return nil
        }

        // Copy the .docc directory to cache destination
        let cachePath = destinationDir.appendingPathComponent("\(package)-\(version).docc", isDirectory: true)

        // Remove existing if present
        if FileManager.default.fileExists(atPath: cachePath.path) {
            try? FileManager.default.removeItem(at: cachePath)
        }

        do {
            try FileManager.default.copyItem(at: docSourceURL, to: cachePath)
            return cachePath
        } catch {
            throw DocCError.cacheCopyFailed(source: docSourceURL, underlying: error)
        }
    }

    /// Download a .doccarchive from GitHub
    /// - Parameters:
    ///   - assetURL: URL to the release asset
    ///   - assetName: Name of the asset file
    ///   - package: Package name for cache naming
    ///   - version: Version string
    ///   - destinationDir: Directory to store the extracted archive
    /// - Returns: URL to the extracted .doccarchive
    public func download(
        from assetURL: URL,
        assetName: String,
        package: String,
        version: String,
        to destinationDir: URL
    ) async throws -> URL {
        // Create temp directory for download
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("smith-docc-\(UUID().uuidString)", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        } catch {
            throw DocCError.downloadFailed(url: assetURL, underlying: error)
        }

        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let downloadedFile = tempDir.appendingPathComponent(assetName)

        // Download using curl (more reliable than URLSession for large files)
        let curlCommand = "curl -L -o \"\(downloadedFile.path)\" \"\(assetURL.absoluteString)\""
        let (_, exitCode) = await runShellCommand(curlCommand)

        if exitCode != 0 {
            throw DocCError.downloadFailed(url: assetURL, underlying: NSError(domain: "DownloadError", code: Int(exitCode)))
        }

        // Check what we downloaded
        let finalPath = destinationDir.appendingPathComponent("\(package)-\(version).doccarchive", isDirectory: true)

        // Remove existing if present
        if FileManager.default.fileExists(atPath: finalPath.path) {
            try? FileManager.default.removeItem(at: finalPath)
        }

        // Handle zip vs directory
        if assetName.hasSuffix(".zip") {
            // Extract zip file
            let extractDir = tempDir.appendingPathComponent("extracted", isDirectory: true)
            let unzipCommand = "unzip -q \"\(downloadedFile.path)\" -d \"\(extractDir.path)\""
            let (_, unzipExitCode) = await runShellCommand(unzipCommand)

            if unzipExitCode != 0 {
                throw DocCError.extractionFailed(file: downloadedFile, underlying: NSError(domain: "UnzipError", code: Int(unzipExitCode)))
            }

            // Find the .doccarchive in extracted contents
            if let contents = try? FileManager.default.contentsOfDirectory(at: extractDir, includingPropertiesForKeys: nil) {
                for item in contents {
                    if item.pathExtension == "doccarchive" {
                        try FileManager.default.moveItem(at: item, to: finalPath)
                        return finalPath
                    }
                }
            }

            // If no .doccarchive found, maybe the zip itself is the archive structure
            // Move the entire extracted content
            if let firstItem = try? FileManager.default.contentsOfDirectory(at: extractDir, includingPropertiesForKeys: nil).first {
                try FileManager.default.moveItem(at: firstItem, to: finalPath)
                return finalPath
            }

            throw DocCError.extractionFailed(file: downloadedFile, underlying: NSError(domain: "NoArchiveFound", code: 1))
        } else {
            // Already a directory or uncompressed file
            try FileManager.default.moveItem(at: downloadedFile, to: finalPath)
            return finalPath
        }
    }

    // MARK: - Private Helpers

    private func ghCLIAvailable() -> Bool {
        let (_, exitCode) = runShellCommandSync("which gh")
        return exitCode == 0
    }

    private func gitAvailable() -> Bool {
        let (_, exitCode) = runShellCommandSync("which git")
        return exitCode == 0
    }

    private func runShellCommand(_ command: String) async -> (output: String, exitCode: Int32) {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = runShellCommandSync(command)
                continuation.resume(returning: result)
            }
        }
    }
}

// MARK: - Shell Command Helper

private func runShellCommandSync(_ command: String) -> (output: String, exitCode: Int32) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    process.arguments = ["-c", command]

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

        return (output + errorOutput, process.terminationStatus)
    } catch {
        return ("Error: \(error.localizedDescription)", 1)
    }
}
