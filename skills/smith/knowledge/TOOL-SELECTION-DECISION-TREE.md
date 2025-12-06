# Tool Selection Decision Tree - Complete Guide

Comprehensive decision trees for selecting and using Smith tools across ALL development scenarios.

---

## Overview

Smith Tools cover 5 main domains:
1. **Build Analysis** (smith-xcsift, smith-sbsift)
2. **Dependency Management** (smith-spmsift)
3. **Architecture Validation** (smith-validation)
4. **Performance Analysis** (smith-tca-trace)
5. **Documentation Search** (sosumi)

---

## Master Decision Tree

```
User request received
        │
        ▼
What domain?
        │
        ├─ Build/Compile ────────────────► Section A: Build Analysis
        │
        ├─ Dependencies/Packages ────────► Section B: Dependency Management
        │
        ├─ Architecture/Code Quality ────► Section C: Architecture Validation
        │
        ├─ Performance/Profiling ────────► Section D: Performance Analysis
        │
        ├─ Documentation/API Lookup ─────► Section E: Documentation Search
        │
        └─ Multiple domains ─────────────► Section F: Multi-Tool Workflows
```

---

## Section A: Build Analysis

### Level 1: Identify Build System

```
User request contains build/test/analyze keywords
        │
        ▼
Check project structure:
        │
        ├─ .xcworkspace or .xcodeproj exists? ──► Xcode build system
        │                                          │
        │                                          └─► smith-xcsift
        │
        ├─ Package.swift exists? ───────────────► Swift Package Manager
        │                                          │
        │                                          └─► smith-sbsift
        │
        └─ SPM dependency question? ─────────────► smith-spmsift
```

### Level 2: Xcode Build System (smith-xcsift)

**Triggers** - User mentions any of:
- "xcodebuild"
- ".xcworkspace" / ".xcodeproj"
- "build failed" + Xcode project
- "iOS app" / "macOS app" / "visionOS"
- "workspace" / "scheme"

**Decision**:
```
Is user asking to build/analyze?
        │
        ├─ YES ─► xcodebuild ... 2>&1 | smith-xcsift --format summary
        │
        └─ NO ──► Check if structural analysis
                  │
                  ├─ Analyze project ─► smith-xcsift analyze
                  │
                  └─ Validate config ─► smith-xcsift validate
```

**Command Construction**:
```
xcodebuild [action] \
  -workspace [WORKSPACE] or -project [PROJECT] \
  -scheme [SCHEME] \
  -destination 'platform=[PLATFORM]' \
  2>&1 | smith-xcsift [--format FORMAT]
```

**Actions**: build, test, clean, archive
**Platforms**: macOS, iOS Simulator, visionOS Simulator
**Formats**: summary (default), detailed, json, compact

### Level 3: Swift Package Manager (smith-sbsift)

**Triggers** - User mentions any of:
- "swift build"
- "Package.swift"
- "SPM build"
- "Swift package build"

**Decision**:
```
What SPM command?
        │
        ├─ swift build ────► swift build 2>&1 | smith-sbsift --format summary
        │
        ├─ swift test ─────► swift test 2>&1 | smith-sbsift --format summary
        │
        └─ swift run ──────► swift run 2>&1 | smith-sbsift --format summary
```

**Command Construction**:
```
swift [action] [-c release] 2>&1 | smith-sbsift [--format FORMAT]
```

**Actions**: build, test, run
**Config**: -c debug (default), -c release
**Formats**: summary (default), detailed, json

---

## Section B: Dependency Management (smith-spmsift)

**Triggers** - User mentions:
- "dependencies"
- "Package.swift" / "Package.resolved"
- "dependency graph"
- "update packages"
- "resolve dependencies"
- "outdated packages"

**Decision Tree**:
```
Dependency operation?
        │
        ├─ Show graph ────────► swift package show-dependencies | smith-spmsift
        │
        ├─ Resolve ───────────► swift package resolve 2>&1 | smith-spmsift
        │
        ├─ Update ────────────► swift package update 2>&1 | smith-spmsift
        │
        ├─ Analyze conflicts ─► smith-spmsift analyze
        │
        └─ Check outdated ────► swift package show-dependencies | smith-spmsift --check-outdated
```

**Mandatory Pattern**: ALWAYS pipe swift package commands through smith-spmsift for dependency analysis.

---

## Section C: Architecture Validation (smith-validation)

**Triggers** - User mentions:
- "TCA" / "Composable Architecture"
- "@Reducer" / "reducer"
- "architecture validation"
- "code quality"
- "architectural issues"

**Decision Tree**:
```
What validation level?
        │
        ├─ Quick check ───────► smith-validation . --level=critical
        │                        (Only critical issues, fast)
        │
        ├─ Standard check ────► smith-validation . --level=standard
        │                        (Critical + warnings, balanced)
        │
        └─ Deep analysis ─────► smith-validation . --level=comprehensive
                                 (All issues + suggestions, thorough)
```

**Format Options**:
```
What output format?
        │
        ├─ Human-readable ────► smith-validation . --format=summary
        │
        ├─ Detailed report ───► smith-validation . --format=detailed
        │
        └─ JSON for tools ────► smith-validation . --format=json
```

**Common Workflows**:
- Check before commit: `smith-validation . --level=critical --format=summary`
- Pre-release: `smith-validation . --level=comprehensive --format=detailed`
- CI/CD: `smith-validation . --level=standard --format=json > validation.json`

---

## Section D: Performance Analysis (smith-tca-trace)

**Triggers** - User mentions:
- "TCA performance"
- "slow reducers"
- "action processing time"
- "state updates slow"
- "performance trace"

**Decision Tree**:
```
What to trace?
        │
        ├─ Live app tracing ──► smith-tca-trace monitor
        │                        (Attach to running app)
        │
        ├─ Analyze trace file ─► smith-tca-trace analyze trace.json
        │                         (Parse existing trace)
        │
        └─ Performance report ─► smith-tca-trace report --top 20
                                  (Show slowest actions)
```

**Mandatory Pattern**: ALWAYS use smith-tca-trace for TCA performance analysis (not Instruments).

---

## Section E: Documentation Search (sosumi)

**Triggers** - User mentions:
- "Apple documentation"
- "WWDC session"
- "SwiftUI docs"
- "API reference"
- "How does [Apple API] work?"

**Decision Tree**:
```
What documentation source?
        │
        ├─ SwiftUI docs ───────► sosumi search "SwiftUI [query]"
        │
        ├─ WWDC sessions ──────► sosumi wwdc "[topic]"
        │
        ├─ API reference ──────► sosumi api "[framework].[type]"
        │
        └─ General search ─────► sosumi "[query]"
```

**Examples**:
```bash
# Search SwiftUI documentation
sosumi search "SwiftUI navigation"

# Find WWDC sessions
sosumi wwdc "visionOS spatial computing"

# API reference
sosumi api "RealityKit.PresentationComponent"
```

---

## Section F: Multi-Tool Workflows

### Workflow 1: "Build and Validate"

```
Step 1: Build with analysis
  ├─ Xcode? ──► xcodebuild ... 2>&1 | smith-xcsift --format summary
  └─ SPM? ────► swift build 2>&1 | smith-sbsift --format summary

Step 2: Validate architecture (if TCA project)
  └─► smith-validation . --level=standard
```

### Workflow 2: "Check Dependencies and Rebuild"

```
Step 1: Update dependencies
  └─► swift package update 2>&1 | smith-spmsift

Step 2: Resolve any conflicts
  └─► swift package resolve 2>&1 | smith-spmsift

Step 3: Clean rebuild
  └─► swift build -c release 2>&1 | smith-sbsift --format detailed
```

### Workflow 3: "Performance Troubleshooting"

```
Step 1: Build optimized
  └─► swift build -c release 2>&1 | smith-sbsift

Step 2: Profile TCA performance
  └─► smith-tca-trace monitor

Step 3: Analyze slowest actions
  └─► smith-tca-trace report --top 20

Step 4: Validate architecture for issues
  └─► smith-validation . --level=comprehensive
```

### Workflow 4: "Pre-Release Checklist"

```
Step 1: Clean build with analysis
  └─► xcodebuild clean build ... 2>&1 | smith-xcsift --format detailed

Step 2: Comprehensive validation
  └─► smith-validation . --level=comprehensive --format=detailed

Step 3: Check dependencies
  └─► swift package show-dependencies | smith-spmsift

Step 4: Performance check
  └─► smith-tca-trace monitor
```

### Workflow 5: "Onboard New Developer"

```
Step 1: Show architecture
  └─► smith-validation . --level=standard --format=summary

Step 2: Explain dependencies
  └─► swift package show-dependencies | smith-spmsift

Step 3: Search relevant APIs
  └─► sosumi search "[framework used in project]"
```

---

## Quick Reference: When to Use Each Tool

| User Says | Tool | Command Pattern |
|-----------|------|-----------------|
| "Build this" | smith-xcsift/sbsift | xcodebuild/swift build ... \| [tool] |
| "Test this" | smith-xcsift/sbsift | xcodebuild/swift test ... \| [tool] |
| "Update dependencies" | smith-spmsift | swift package update \| smith-spmsift |
| "Validate architecture" | smith-validation | smith-validation . --level=standard |
| "Check TCA performance" | smith-tca-trace | smith-tca-trace monitor |
| "How does [API] work?" | sosumi | sosumi search "[API]" |
| "Dependency graph" | smith-spmsift | swift package show-dependencies \| smith-spmsift |
| "Why is build slow?" | smith-xcsift/sbsift | ... \| [tool] --format detailed |
| "Architectural issues?" | smith-validation | smith-validation . --level=comprehensive |

---

## Context-Based Tool Selection

### When User Mentions File Types

| File Type | Likely Tool |
|-----------|------------|
| `.xcworkspace`, `.xcodeproj` | smith-xcsift |
| `Package.swift` | smith-sbsift or smith-spmsift |
| `Package.resolved` | smith-spmsift |
| `@Reducer`, TCA code | smith-validation, smith-tca-trace |
| Build logs | smith-xcsift or smith-sbsift |

### When User Mentions Symptoms

| Symptom | Likely Tool |
|---------|------------|
| "Build failed" | smith-xcsift or smith-sbsift |
| "Slow build" | smith-xcsift/sbsift --format detailed |
| "Dependency conflict" | smith-spmsift |
| "Reducer slow" | smith-tca-trace |
| "Architecture smell" | smith-validation |
| "How do I use [API]?" | sosumi |

---

## Default Assumptions

When in doubt, apply these defaults:

1. **Build commands**: Always pipe through smith-xcsift or smith-sbsift
2. **Package commands**: Always pipe through smith-spmsift
3. **TCA projects**: Use smith-validation for architecture checks
4. **Performance issues**: Use smith-tca-trace for profiling
5. **API questions**: Use sosumi for documentation lookup
6. **Format**: Default to `--format summary` unless detail requested
7. **stderr**: Always capture with `2>&1`

---

## Tool Combinations

Some scenarios benefit from multiple tools:

### TCA Project Workflow
1. Build → smith-sbsift
2. Validate → smith-validation
3. Profile → smith-tca-trace
4. API lookup → sosumi

### Xcode Project Workflow
1. Build → smith-xcsift
2. Dependencies → smith-spmsift
3. Validate (if TCA) → smith-validation

### CI/CD Workflow
1. Build → smith-xcsift/sbsift --format json
2. Validate → smith-validation --format json
3. Dependencies → smith-spmsift
4. Performance gate → smith-tca-trace report

---

**Last Updated**: December 4, 2025
