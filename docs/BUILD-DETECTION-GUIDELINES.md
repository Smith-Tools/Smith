# Build Detection Guidelines for Smith Agent

**Purpose:** Detailed auto-trigger logic for Smith to detect when it should proactively offer analysis and guidance during build-related tasks.

**Status:** Active Deployment
**Version:** 1.0
**Last Updated:** November 26, 2025

---

## Overview

Smith's primary failure mode: **Silent non-invocation when build guidance is most needed.**

Your scenario exemplifies this:
```
⏺ Perfect! Now let me test the compilation:
Bash(xcodebuild -workspace Scroll.xcworkspace -scheme Scroll -configuration Release...)
```

**Smith should have auto-triggered here** because:
- ✅ Apple platform build detected (xcworkspace)
- ✅ Build command is about to execute
- ✅ Smith has specific guidance on workspace vs project priority
- ✅ Smith should validate build strategy BEFORE execution
- ❌ **But Smith never triggered** because triggers were too generic

---

## Build Activity Detection Patterns

### Pattern 1: xcodebuild/swift build Command Execution

**Trigger:** User is about to run xcodebuild or swift build

**When to detect:**
- Bash tool with `xcodebuild` in command
- Bash tool with `swift build` in command
- User mentions "compile", "build", "test compilation"
- Command includes workspace (`.xcworkspace`), project (`.xcodeproj`), or package name

**What Smith should do:**
1. Detect project type (workspace > project > package)
2. Validate build command matches project type
3. **For workspaces:** Warn if command uses `.xcodeproj` instead of workspace
4. Recommend smith-xcsift piping for analysis
5. Offer to analyze build output for performance issues

**Trigger keywords:**
- `xcodebuild`
- `swift build`
- `swift package`
- `swiftc`
- Workspace name (e.g., `Scroll.xcworkspace`)
- Project name (e.g., `MyApp.xcodeproj`)
- Scheme name in context

**Smith's response template:**
```
🔨 Build command detected: xcodebuild with Scroll.xcworkspace

⚠️ CRITICAL: This is a workspace. Build the workspace, not embedded .xcodeproj:
✅ Correct:   xcodebuild -workspace Scroll.xcworkspace -scheme Scroll
❌ Incorrect: xcodebuild -project Scroll.xcodeproj -scheme Scroll

To pipe through smith-xcsift for analysis:
xcodebuild -workspace Scroll.xcworkspace -scheme Scroll 2>&1 | smith-xcsift

Smith can analyze this build for:
• Compilation bottlenecks
• Dependency issues
• Performance metrics
• Error/warning summary
```

---

### Pattern 2: Build Failures or Errors

**Trigger:** Build has failed or user reports build errors

**When to detect:**
- Error message mentions "failed to build"
- Bash output contains compilation errors
- User asks "why did my build fail?"
- Build log shows errors (ClangError, LinkError, etc.)
- Type inference or circular dependency errors

**What Smith should do:**
1. Diagnose root cause using smith-xcsift or smith-sbsift
2. Provide specific fix recommendations
3. Suggest code changes if architectural issue
4. Route to smith-core for dependency/concurrency issues if needed

**Trigger keywords:**
- `error:`
- `failed to build`
- `build failed`
- `compilation error`
- `type mismatch`
- `circular dependency`
- `linker error`
- `symbol not found`
- `build halted`

**Smith's response template:**
```
⚠️ Build failed with X errors

Smith diagnostics:
1. Root cause analysis
2. Specific file/line locations
3. Recommended fixes
4. Prevention strategies

Run this for full analysis:
[command with smith-xcsift or smith-sbsift]
```

---

### Pattern 3: Build Hangs or Slow Builds

**Trigger:** Build has hung, timed out, or is unusually slow

**When to detect:**
- User says "build is stuck"
- Build is taking >5 minutes for typical project
- Progress reports show "Processing files" for extended time
- Xcode process consuming high CPU but making no progress

**What Smith should do:**
1. Detect hang location using smith-xcsift --hang-detection
2. Analyze workspace dependencies for circular imports
3. Check index store corruption
4. Provide immediate recovery options
5. Suggest code structure improvements

**Trigger keywords:**
- `build stuck`
- `build hang`
- `compilation taking forever`
- `Xcode frozen`
- `stuck at X/Y`
- `slow build`
- `timeout`
- `still compiling`

**Smith's response template:**
```
🔍 Build hang detected

Smith hang analysis:
1. Checking index store corruption...
2. Analyzing dependency graph...
3. Identifying type inference bottlenecks...

Quick recovery:
[recommended commands]

Long-term fixes:
[code structure recommendations]
```

---

### Pattern 4: Project Structure or Build Configuration Questions

**Trigger:** User asks how to build the project, what's the right way to build, etc.

**When to detect:**
- "How do I build this?"
- "What's the right way to build?"
- "Should I use workspace or project?"
- Questions about build configuration

**What Smith should do:**
1. Auto-detect project type
2. Provide exact build command
3. Recommend smith-xcsift integration
4. Explain project structure

**Trigger keywords:**
- "how do i build"
- "how to build"
- "build this project"
- "build command"
- "proper build"
- "build strategy"

---

## Smart Build Detection Algorithm

Smith should implement this detection logic:

### Step 1: Context Inspection (On Every User Message)

```swift
enum BuildContext {
  case buildCommandPending        // User about to run xcodebuild/swift
  case buildFailure              // Build failed, errors present
  case buildHang                 // Build stuck/slow
  case buildQuestion             // How to build questions
  case none                       // Not build-related
}

func detectBuildContext(_ message: String, _ command: String?) -> BuildContext {
  // Check for pending build commands
  if let cmd = command {
    if cmd.contains("xcodebuild") || cmd.contains("swift build") {
      return .buildCommandPending
    }
  }

  // Check for failure indicators
  if message.contains("error:") ||
     message.contains("failed to build") ||
     message.contains("compilation error") {
    return .buildFailure
  }

  // Check for hang indicators
  if message.contains("stuck") ||
     message.contains("hang") ||
     message.contains("forever") ||
     message.contains("timeout") {
    return .buildHang
  }

  // Check for how-to-build questions
  if message.contains("how do i build") ||
     message.contains("how to build") ||
     message.contains("build command") {
    return .buildQuestion
  }

  return .none
}
```

### Step 2: Project Type Detection (For Build Commands)

When `buildCommandPending` or `buildQuestion` detected:

```swift
func detectProjectType(_ workingDir: String) -> ProjectType {
  // Step 1: Check for workspace (highest priority)
  if findFiles(pattern: "*.xcworkspace") {
    return .workspace
  }

  // Step 2: Check for project file
  if findFiles(pattern: "*.xcodeproj") {
    return .project
  }

  // Step 3: Check for Swift package
  if fileExists("Package.swift") {
    return .swiftPackage
  }

  // Step 4: Check for Swift files
  if findFiles(pattern: "*.swift") {
    return .swiftFiles
  }

  return .unknown
}
```

### Step 3: Appropriate Response by Context

```swift
func smithResponse(context: BuildContext, projectType: ProjectType) {
  switch context {
  case .buildCommandPending:
    // Validate the command against detected project type
    validateBuildCommand(projectType)
    recommendSmithXcsiftIntegration(projectType)

  case .buildFailure:
    // Diagnose with appropriate tool
    if projectType == .workspace || projectType == .project {
      diagnoseWithSmithXcsift()
    } else if projectType == .swiftPackage {
      diagnoseWithSmithSbsift()
    }

  case .buildHang:
    // Use hang detection
    analyzeHangWithSmithTools(projectType)
    suggestRecoveryStrategy()

  case .buildQuestion:
    // Detect and explain project type
    explainProjectType(projectType)
    provideExactBuildCommand(projectType)

  case .none:
    // Let Smith remain silent unless explicitly invoked
    break
  }
}
```

---

## Trigger Keyword Mapping

### Build Command Triggers (Should → buildCommandPending)

| Keyword | Project Type Hint | Tool |
|---------|----------|------|
| `xcodebuild` | Workspace/Project | smith-xcsift |
| `swift build` | Package | smith-sbsift |
| `swiftc` | Loose files | Direct compilation |
| `.xcworkspace` | Workspace (highest) | smith-xcsift |
| `.xcodeproj` | Project | smith-xcsift |
| `Package.swift` | Package | smith-sbsift |
| `-scheme` | Workspace/Project | smith-xcsift |
| `-workspace` | Workspace (explicit) | smith-xcsift |
| `-project` | Project (explicit) | smith-xcsift |

### Build Failure Triggers (Should → buildFailure)

| Keyword | Severity | Smith Action |
|---------|----------|--------------|
| `error:` | High | Analyze with smith tools |
| `failed to build` | High | Diagnose root cause |
| `build failed` | High | Full error analysis |
| `compilation error` | High | Specific error fix |
| `type mismatch` | Medium | May route to smith-core |
| `circular dependency` | High | Dependency analysis |
| `linker error` | High | Link phase diagnosis |
| `symbol not found` | Medium | Access control check |
| `undefined reference` | Medium | Public API validation |

### Build Hang/Performance Triggers (Should → buildHang)

| Keyword | Severity | Smith Action |
|---------|----------|--------------|
| `stuck` | High | Hang detection |
| `hang` | High | Hang detection |
| `taking forever` | Medium | Performance analysis |
| `timeout` | High | Hang detection |
| `slow` | Low | Suggest optimization |
| `frozen` | High | Recovery strategy |
| `processing files` | Medium | Index corruption check |

### Build Question Triggers (Should → buildQuestion)

| Phrase | Smith Action |
|--------|------|
| "how do i build" | Auto-detect + explain |
| "how to build" | Auto-detect + explain |
| "build command" | Provide exact command |
| "build this" | Detect + explain |
| "right way to build" | Best practices |
| "proper build" | Strategy explanation |

---

## False Positive Prevention

Smith should **NOT** trigger on these, even if "build" appears:

❌ **Generic mentions of "build" without context:**
- "I'm building a new feature"
- "Let's build this together"
- "This will build upon..."

❌ **Hypothetical build discussions:**
- "You could build this by..."
- "If we were to build..."
- "How would you build..."

❌ **Non-Apple build systems:**
- "npm build"
- "cargo build"
- "gradle build"
- "make build"

✅ **Smith should trigger on:**
- Actual `xcodebuild` or `swift build` commands
- Explicit build failures with errors
- Reports of stuck/slow builds
- "How do I build my iOS/Swift project?" questions

**Implementation:**
```swift
func isRelevantBuildTrigger(_ message: String) -> Bool {
  // Must contain Apple platform indicators
  let hasAppleIndicators = message.contains(oneOf: [
    "xcodebuild", "swift build", "swiftc",
    "xcworkspace", "xcodeproj", "Package.swift",
    "Xcode", "iOS", "macOS", "visionOS"
  ])

  // Must not be hypothetical
  let isHypothetical = message.contains(oneOf: [
    "could build", "would build", "if we", "imagine"
  ])

  return hasAppleIndicators && !isHypothetical
}
```

---

## Implementation in Smith Agent

Add to `smith.md` agent definition:

```yaml
# BUILD DETECTION PROTOCOL
# Smith auto-triggers on specific build-related contexts

auto_triggers:
  - context: "build_command_pending"
    keywords: ["xcodebuild", "swift build", "swiftc", "xcworkspace", "xcodeproj"]
    action: "validate_build_strategy"

  - context: "build_failure"
    keywords: ["error:", "failed to build", "compilation error", "circular dependency"]
    action: "diagnose_with_smith_tools"

  - context: "build_hang"
    keywords: ["stuck", "hang", "timeout", "processing files", "frozen"]
    action: "hang_detection"

  - context: "build_question"
    keywords: ["how do i build", "build command", "right way to build"]
    action: "auto_detect_and_explain"

# PREVENT FALSE POSITIVES
# Don't trigger on generic "build" mentions without context
exclusion_patterns:
  - "building a .*feature"
  - "build .*together"
  - "would build"
  - "could build"
  - "npm build|cargo build|gradle build|make build"
```

---

## Testing Smith's Build Detection

### Test Case 1: Workspace Build Command
```
User: "Let me build and test the Scroll app"
Bash(xcodebuild -workspace Scroll.xcworkspace -scheme Scroll -configuration Release...)

Expected Smith trigger: buildCommandPending
Expected Smith message: Validate workspace vs project, recommend smith-xcsift piping
```

### Test Case 2: Build Failure
```
User output: "error: 'LoginFeature' does not conform to 'Equatable'"

Expected Smith trigger: buildFailure
Expected Smith action: Diagnose with smith-validation, suggest fix
```

### Test Case 3: Build Hang
```
User: "My build is stuck at 'Linking' phase for 5 minutes"

Expected Smith trigger: buildHang
Expected Smith action: Hang detection, recovery strategy
```

### Test Case 4: How to Build Question
```
User: "How do I build this project properly?"

Expected Smith trigger: buildQuestion
Expected Smith action: Auto-detect project type, provide exact command
```

### Test Case 5: False Positive Prevention
```
User: "We're building this feature on top of the auth system"

Expected Smith trigger: NONE (no Apple build indicators)
Expected Smith action: Stay silent
```

---

## Summary of Changes

### Improved smith Skill Triggers

**Old:** `["Smith", "architecture", "validation", "build", "code analysis"]`

**New:**
```yaml
- "Smith"
- "smith-validation"
- "code review"
- "xcodebuild"
- "swift build"
- "build failed"
- "build hang"
- "build stuck"
- "compilation error"
- "type inference"
- "circular dependency"
- "TCA reducer"
- "@Reducer"
- "smith-xcsift"
- "smith-sbsift"
- "xcworkspace"
- "workspace"
- "architecture validation"
```

**Benefits:**
- ✅ Catches actual build commands (`xcodebuild`, `swift build`)
- ✅ Catches build failures/hangs with specific keywords
- ✅ Catches workspace/project indicators
- ✅ Catches TCA validation requests
- ✅ Prevents false positives on generic "build" mentions

### Improved smith-core Triggers

**Old:** `["Swift", "dependency", "concurrency", "testing", "access control", "@Dependency", "async/await", "Swift Testing"]`

**New:**
```yaml
- "@Dependency"
- "@DependencyClient"
- "async/await"
- "Swift Testing"
- "@Test"
- "TestStore"
- "MainActor"
- "MainActor safety"
- "concurrency pattern"
- "access control"
- "public API"
- "dependency injection"
- "Task { @MainActor"
- "Date()"
- "UUID()"
- "concurrency bug"
- "swift package dependency"
```

**Benefits:**
- ✅ More specific: `@Dependency` instead of generic "dependency"
- ✅ Catches common anti-patterns: `Date()`, `UUID()` direct calls
- ✅ Catches safety issues: `MainActor`, concurrency patterns
- ✅ Catches API patterns: `@Test`, `TestStore`

### Improved smith-platforms Triggers

**Old:** `["visionOS", "iOS", "macOS", "iPadOS", "RealityKit", "UIKit", "AppKit", "platform", "spatial"]`

**New:**
```yaml
- "visionOS"
- "RealityKit"
- "RealityView"
- "PresentationComponent"
- "spatial computing"
- "iOS"
- "macOS"
- "iPadOS"
- "platform-specific"
- "UIKit"
- "AppKit"
- "SwiftUI on iOS"
- "SwiftUI on macOS"
- "ARView"
- "Model3D"
- "platform abstraction"
- "cross-platform"
- "conditional compilation"
```

**Benefits:**
- ✅ More granular: `RealityView` instead of just `RealityKit`
- ✅ Catches spatial APIs: `ARView`, `Model3D`, `PresentationComponent`
- ✅ Catches cross-platform patterns
- ✅ Better precision for when to trigger

---

## Next Steps

1. **Deploy skill trigger updates** (✅ Done)
2. **Add build detection logic to Smith agent** (Pending)
3. **Test with real scenarios** (Pending)
4. **Monitor for false positives/negatives** (Pending)
5. **Refine triggers based on feedback** (Ongoing)

---

## References

- Smith agent definition: `Smith/agent/smith.md`
- Skill definitions: `Smith/skills/{smith,smith-core,smith-platforms}/SKILL.md`
- Build analysis tools: Smith Tools ecosystem (smith-xcsift, smith-sbsift)

