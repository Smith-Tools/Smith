---
name: smith
description: Swift architecture validation, code analysis, and build health coordinator. Orchestrates smith-core and smith-platforms for comprehensive development guidance. For TCA-specific questions use maxwell-pointfree, for platform patterns use smith-platforms, for general Swift use smith-core.
tags:
  - "Swift architecture"
  - "validation"
  - "build"
  - "architecture"
  - "code analysis"
triggers:
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
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
version: "3.0.0"
author: "Claude Code Skill - Smith Architecture"
---

# Smith - Architecture Validation & Coordination

## Core Responsibility

Smith coordinates Swift architecture validation and provides code analysis. Smith interprets validation results and routes domain-specific questions to specialized skills.

## Specialized Skills

Smith works with three specialized skills for comprehensive coverage:

- **smith-core**: General Swift architecture, dependencies, concurrency, testing, access control
- **smith-tca**: Swift Composable Architecture patterns, reducers, state management, navigation
- **smith-platforms**: Platform-specific patterns for iOS, macOS, iPadOS, visionOS

## Quick Navigation

For comprehensive guidance on Swift architecture, dependencies, and best practices:

- **Smith Core Knowledge**: [knowledge/AGENTS-AGNOSTIC.md](knowledge/AGENTS-AGNOSTIC.md)
- **Decision Trees**: [knowledge/AGENTS-DECISION-TREES.md](knowledge/AGENTS-DECISION-TREES.md)
- **Claude Integration**: [knowledge/CLAUDE.md](knowledge/CLAUDE.md)

## Search Your Knowledge

When analyzing code or architectural patterns:

1. **Use Glob** to find relevant files: `Glob("knowledge/**/*.md")`
2. **Use Grep** to search content: `Grep("pattern keyword", "knowledge/")`
3. **Use Read** to access files: `Read("knowledge/AGENTS-AGNOSTIC.md")`

All knowledge is in the `knowledge/` directory.

## How Smith Routes Questions

**Single-domain questions auto-trigger appropriate skill:**
- "How do I use @Dependency?" → smith-core
- "How do I implement @Shared state?" → smith-tca
- "How do I structure visionOS views?" → smith-platforms

**Multi-domain questions:** Smith synthesizes from multiple skills
**Code analysis questions:** Smith interprets validation results
**Build diagnostics:** Smith uses bash tools for analysis

## When to Use Smith

✅ **Use Smith for:**
- Code structure validation and analysis
- Build diagnostics and troubleshooting
- Architectural guidance through pattern reference
- Interpretation of validation results

❌ **Don't use Smith for:**
- Detailed pattern teaching (skills handle this)
- TCA-specific guidance (use smith-tca directly)
- Platform API documentation (use smith-platforms directly)

---

## 🔧 Build Command Protocols

**CRITICAL**: When executing build commands, ALWAYS use the appropriate Smith tool.

### Command Routing Table

| Build System | Command Pattern | Required Tool |
|-------------|----------------|---------------|
| Xcode workspace/project | `xcodebuild ...` | `... 2>&1 \| smith-xcsift` |
| Swift Package Manager | `swift build` | `... 2>&1 \| smith-sbsift` |
| SPM dependencies | `swift package ...` | `... \| smith-spmsift` |
| TCA validation | Architecture analysis | `smith-validation` |

### Default Behavior Rules

1. **NEVER run bare build commands** - always pipe through analyzer
2. **NEVER use --quiet or suppress output** - Smith tools need the output
3. **ALWAYS capture stderr** - use `2>&1` to capture errors
4. **ALWAYS use appropriate format** - `--format summary` for quick review

### Examples

#### ✅ Correct Patterns

```bash
# Xcode build
xcodebuild build -workspace App.xcworkspace -scheme App -destination 'platform=macOS' 2>&1 | smith-xcsift

# Swift build
swift build 2>&1 | smith-sbsift --format summary

# SPM analysis
swift package show-dependencies | smith-spmsift
```

#### ❌ Anti-Patterns

```bash
# DON'T: Bare commands
xcodebuild build -workspace App.xcworkspace -scheme App
swift build

# DON'T: Quiet mode
xcodebuild build -quiet
swift build 2>/dev/null

# DON'T: No analysis
xcodebuild build && echo "Success"
```

### Decision Tree

See [knowledge/TOOL-SELECTION-DECISION-TREE.md](knowledge/TOOL-SELECTION-DECISION-TREE.md) for comprehensive tool selection logic.
See [knowledge/BUILD-COMMAND-DEFAULTS.md](knowledge/BUILD-COMMAND-DEFAULTS.md) for command templates and scenarios.
