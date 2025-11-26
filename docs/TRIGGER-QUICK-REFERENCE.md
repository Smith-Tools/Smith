# Smith Skills Trigger Quick Reference

**Quick lookup for when Smith auto-triggers**

---

## Smith Skill Auto-Triggers

When will **Smith** automatically offer help?

| Trigger | What Happens | Smith Does |
|---------|-------------|-----------|
| `xcodebuild` in command | Build command pending | Validates workspace/project priority |
| `swift build` in command | Package build pending | Recommends smith-sbsift integration |
| "build failed" in message | Compilation failed | Diagnoses with smith-xcsift/sbsift |
| "build stuck/hang/timeout" | Build not progressing | Hang detection & recovery |
| "how do i build" question | User asking for guidance | Auto-detects project type, explains |
| "@smith" explicitly | User invoked Smith | Always responds (code analysis, validation) |
| "xcworkspace"/"workspace" | Workspace structure mentioned | Validates build strategy |
| "TCA reducer"/"@Reducer" | TCA code analysis needed | Offers validation |

---

## smith-core Skill Auto-Triggers

When will **smith-core** automatically offer help?

| Trigger | Context | smith-core Does |
|---------|---------|----------------|
| `@Dependency` used | Dependency injection | Validates pattern |
| `@DependencyClient` used | Client dependency | Validates pattern |
| `@Test` or `TestStore` | Testing code | Provides guidance |
| `@MainActor` mentioned | Concurrency safety | Validates usage |
| `Date()` or `UUID()` | ⚠️ Anti-pattern | Explains dependencies |
| `async/await` pattern | Concurrency code | Provides guidance |
| "MainActor safety" issue | Concurrency problem | Diagnoses & explains |
| "Task { @MainActor" | Task pattern | Validates safety |
| "public API" question | Access control | Validates cascade |

**False positives prevented:**
- ❌ NOT triggered by casual "Swift" mentions
- ❌ NOT triggered by "dependency" in non-code contexts
- ❌ NOT triggered by "testing" discussions

---

## smith-platforms Skill Auto-Triggers

When will **smith-platforms** automatically offer help?

| Trigger | Platform | smith-platforms Does |
|---------|----------|-------------------|
| `RealityView` | visionOS | API guidance |
| `RealityKit` API | visionOS | Framework guidance |
| `PresentationComponent` | visionOS | Spatial pattern help |
| `ARView` | AR platforms | API guidance |
| `Model3D` | visionOS | API guidance |
| `SwiftUI on iOS` | iOS-specific | Pattern validation |
| `SwiftUI on macOS` | macOS-specific | Pattern validation |
| `UIKit`/`AppKit` | Legacy frameworks | Integration guidance |
| "spatial computing" | visionOS context | Architecture guidance |
| "cross-platform" pattern | Multi-platform | Pattern guidance |
| "conditional compilation" | Platform-specific | Pattern guidance |

**False positives prevented:**
- ❌ NOT triggered by casual "iOS" or "macOS" mentions
- ❌ NOT triggered by platform in non-development contexts
- ❌ NOT triggered by just "RealityKit" without context

---

## When Smith Does NOT Trigger

These common phrases do NOT trigger Smith (by design):

- ❌ "We're building this feature" (non-technical build)
- ❌ "Swift is a great language" (discussion, not code)
- ❌ "I depend on this library" (dependency in conversation)
- ❌ "Let's test this idea" (testing in discussion)
- ❌ "The iOS app is popular" (casual platform mention)
- ❌ "I'm using Swift Package Manager" (setup discussion)
- ❌ "visionOS is interesting" (non-development discussion)

---

## Explicit Invocation Still Works

Use `@smith` for:
- Code validation requests
- Interpretation of error messages
- Testing/maintenance implications
- Architecture questions (will route to @maxwell)

Example:
```
@smith validate my TCA reducer
@smith check this code for anti-patterns
@smith diagnose my build failure
```

---

## How to Know When Smith Triggers

**Smith will offer help by:**
1. Detecting the build/code/platform context
2. Asking if you want Smith's help
3. Explaining what Smith can analyze

**Before:** You had to ask `@smith` explicitly
**After:** Smith proactively offers when appropriate

---

## Skill Specialization

**smith** (Orchestrator)
- Build commands & failures
- Code review & validation
- Routes to smith-core & smith-platforms

**smith-core** (Universal Swift)
- Dependency injection (@Dependency, @DependencyClient)
- Concurrency patterns (async/await, @MainActor)
- Testing (Swift Testing, @Test)
- Access control (public APIs)

**smith-platforms** (Platform-Specific)
- visionOS (RealityView, spatial computing)
- iOS/macOS SwiftUI patterns
- UIKit/AppKit integration
- Cross-platform abstractions

---

## Quick Decision Tree

**Build-related?** → Smith auto-triggers
**Dependency/Concurrency/Testing?** → smith-core auto-triggers
**Platform-specific/RealityKit/AR?** → smith-platforms auto-triggers
**Multiple topics?** → Multiple skills may trigger

---

## Examples of Auto-Triggering

### ✅ This triggers Smith:
```
"Let me build with xcodebuild and see what happens"
Bash(xcodebuild -workspace MyApp.xcworkspace -scheme MyApp)
```
→ Smith: "I see a workspace build. Should I validate your build strategy?"

### ✅ This triggers smith-core:
```
"I need to add dependency injection with @Dependency"
```
→ smith-core: "I can help validate your @Dependency pattern"

### ✅ This triggers smith-platforms:
```
"How do I create a RealityView for visionOS?"
```
→ smith-platforms: "I can guide you through RealityView patterns"

### ❌ This does NOT trigger (intentionally):
```
"We should build on top of the auth system"
```
→ No trigger (non-development context)

---

## Need Help?

- **See all details**: Read `BUILD-DETECTION-GUIDELINES.md`
- **Understand changes**: Read `TRIGGER-IMPROVEMENTS-SUMMARY.md`
- **Check specific trigger**: See tables above

