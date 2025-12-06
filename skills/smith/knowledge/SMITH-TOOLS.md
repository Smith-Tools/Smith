# Smith Tools - Complete Guide

**For agents and developers:** How to use Smith Tools in your Swift development workflow.

---

## Quick Reference

| Problem | Tool | Command |
|---------|------|---------|
| Swift `swift build` fails | **smith-sbsift** | `swift build 2>&1 \| smith-sbsift --format summary` |
| Xcode `xcodebuild` fails | **smith-xcsift** | `xcodebuild ... 2>&1 \| smith-xcsift --format summary` |
| Package/dependency issues | **smith-spmsift** | `swift package show-dependencies \| smith-spmsift` |
| TCA reducer or architecture issues | **smith-validation** | `smith-validation . --level=standard` |
| Need Apple documentation | **sosumi** | `/skill sosumi search "topic"` |

---

## When to Use Each Tool

### 🔧 smith-sbsift - Swift Build Analysis

**Use when:**
- `swift build` fails with errors
- Need to understand build performance
- Have compilation errors you need to parse
- Want structured error output instead of raw logs

**What it does:**
- Extracts errors and warnings with file/line info
- Identifies compilation bottlenecks
- Shows build timing
- 43% output reduction vs raw logs

**Command:**
```bash
swift build 2>&1 | smith-sbsift --format summary
```

**Example:**
```bash
# Instead of:
swift build
# (Raw output, hard to parse)

# Do:
swift build 2>&1 | smith-sbsift --format summary
# (Structured, agent-friendly)
```

---

### 🏗️ smith-xcsift - Xcode Build Analysis

**Use when:**
- `xcodebuild` fails with errors
- Building iOS/macOS app in Xcode workspace
- Need to debug build configuration issues
- Want to analyze build performance

**What it does:**
- Parses xcodebuild output into structured format
- Extracts compilation errors with context
- Shows build status and timing
- 60% output reduction vs raw logs

**Command:**
```bash
xcodebuild build -workspace App.xcworkspace -scheme App -destination 'platform=macOS' 2>&1 | smith-xcsift --format summary
```

**Example:**
```bash
# macOS build
xcodebuild build -workspace Scroll.xcworkspace -scheme Scroll -destination 'platform=macOS' 2>&1 | smith-xcsift

# iOS simulator
xcodebuild build -workspace Scroll.xcworkspace -scheme Scroll -destination 'platform=iOS Simulator,name=iPhone 15' 2>&1 | smith-xcsift
```

---

### 📦 smith-spmsift - Swift Package Manager Analysis

**Use when:**
- Dependency issues or conflicts
- Need to understand package structure
- Want to check for circular dependencies
- Updating or resolving dependencies

**What it does:**
- Shows package structure and dependencies
- Detects circular imports
- Identifies version conflicts
- 95%+ output reduction

**Commands:**
```bash
# Show dependencies
swift package show-dependencies | smith-spmsift

# Resolve dependencies
swift package resolve 2>&1 | smith-spmsift

# Analyze package structure
swift package dump-package | smith-spmsift
```

---

### 🏛️ smith-validation - Architecture & TCA Validation

**Use when:**
- Working with TCA (The Composable Architecture)
- Need to validate reducer patterns
- Check architectural compliance
- Want code quality analysis

**What it does:**
- Validates TCA patterns and reducers
- Checks for common architectural issues
- Identifies missing error handling
- Analyzes code structure

**Levels:**
- `--level=critical` - Only critical issues (fast)
- `--level=standard` - Critical + warnings (balanced)
- `--level=comprehensive` - All issues + suggestions (thorough)

**Command:**
```bash
# Quick check
smith-validation . --level=critical

# Standard validation
smith-validation . --level=standard

# Deep analysis
smith-validation . --level=comprehensive --format=detailed
```

---

### 📚 sosumi - Apple Documentation & WWDC

**Use when:**
- Need Apple developer documentation
- Looking for WWDC session references
- Want to understand Apple APIs
- Need current API availability info

**What it does:**
- Searches live Apple documentation
- Accesses 3,216 WWDC sessions (2014-2025)
- Shows code examples and API details
- Provides video links

**Commands:**
```bash
# Universal search (docs + WWDC)
/skill sosumi search "SwiftUI navigation"

# WWDC only
/skill sosumi wwdc "visionOS spatial computing"

# Fetch specific doc
/skill sosumi doc swiftui/view

# Compact agent mode (token efficient)
/skill sosumi search "async await" --mode compact-agent
```

---

## Decision Trees

### Building a Swift Package

```
Running `swift build`?
    │
    ├─ Compile error?
    │   └─ Pipe through smith-sbsift
    │       swift build 2>&1 | smith-sbsift
    │
    ├─ Build slow?
    │   └─ Use detailed format
    │       swift build 2>&1 | smith-sbsift --format detailed
    │
    ├─ Dependency issues?
    │   └─ Use smith-spmsift
    │       swift package show-dependencies | smith-spmsift
    │
    └─ TCA code?
        └─ Validate architecture
            smith-validation . --level=standard
```

### Building an Xcode Project

```
Running `xcodebuild`?
    │
    ├─ Build error?
    │   └─ Pipe through smith-xcsift
    │       xcodebuild ... 2>&1 | smith-xcsift
    │
    ├─ Need to understand workspace?
    │   └─ Check dependencies
    │       swift package show-dependencies | smith-spmsift
    │
    ├─ TCA reducers involved?
    │   └─ Validate patterns
    │       smith-validation . --level=standard
    │
    └─ Need API reference?
        └─ Use sosumi
            /skill sosumi search "Framework.Type"
```

### When You Have Architecture Questions

```
Working on TCA code?
    │
    ├─ "How should I structure this reducer?"
    │   └─ Search documentation
    │       /skill sosumi search "TCA reducer patterns"
    │
    ├─ "Does my code follow TCA patterns?"
    │   └─ Validate
    │       smith-validation . --level=comprehensive
    │
    ├─ "Is my @Shared usage correct?"
    │   └─ Run validation
    │       smith-validation . --level=standard
    │
    └─ "How do I handle X in TCA?"
        └─ Search WWDC
            /skill sosumi wwdc "TCA [feature]"
```

---

## Integration Patterns

### Git Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Validate Swift code quality
smith-validation . --level=critical || exit 1

# Check dependencies
swift package show-dependencies 2>&1 | smith-spmsift || exit 1

echo "✅ Pre-commit validation passed"
```

### Makefile

```makefile
.PHONY: build
build:
	swift build 2>&1 | smith-sbsift --format summary

.PHONY: validate
validate:
	smith-validation . --level=standard

.PHONY: check-deps
check-deps:
	swift package show-dependencies | smith-spmsift

.PHONY: full-check
full-check: validate check-deps build
	@echo "✅ All checks passed"
```

### CI/CD (GitHub Actions)

```yaml
name: Build & Validate

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build Swift Package
        run: swift build 2>&1 | smith-sbsift --format json > build-report.json

      - name: Validate Architecture
        run: smith-validation . --level=standard --format=json > validation-report.json

      - name: Check Dependencies
        run: swift package show-dependencies | smith-spmsift > deps-report.json

      - name: Upload Reports
        uses: actions/upload-artifact@v3
        with:
          name: analysis-reports
          path: |
            build-report.json
            validation-report.json
            deps-report.json
```

---

## Common Workflows

### "I'm getting a build error"

```bash
# 1. Run build with analysis
swift build 2>&1 | smith-sbsift --format summary

# 2. If error is unclear, use detailed format
swift build 2>&1 | smith-sbsift --format detailed

# 3. If it's a dependency issue
swift package show-dependencies | smith-spmsift

# 4. If TCA-related
smith-validation . --level=standard
```

### "Build is slow, what's the bottleneck?"

```bash
# Run with detailed output to see timings
swift build 2>&1 | smith-sbsift --format detailed

# Or for Xcode:
xcodebuild build -workspace App.xcworkspace -scheme App -destination 'platform=macOS' 2>&1 | smith-xcsift --format detailed
```

### "I'm working on TCA code and want to ensure it's correct"

```bash
# 1. Validate the architecture
smith-validation . --level=comprehensive

# 2. If you need to understand a pattern
/skill sosumi search "TCA [specific pattern]"

# 3. Check WWDC for similar examples
/skill sosumi wwdc "TCA [feature name]"
```

### "Dependencies are a mess, how do I understand them?"

```bash
# 1. Show dependency tree
swift package show-dependencies | smith-spmsift

# 2. Analyze package structure
swift package dump-package | smith-spmsift

# 3. Try to resolve
swift package resolve 2>&1 | smith-spmsift
```

---

## Output Formats

Each tool supports multiple output formats:

### smith-sbsift & smith-xcsift

```bash
# Summary (default, recommended for most cases)
swift build 2>&1 | smith-sbsift --format summary

# Detailed (full diagnostic info)
swift build 2>&1 | smith-sbsift --format detailed

# JSON (for programmatic parsing)
swift build 2>&1 | smith-sbsift --format json

# Compact (minimal output)
swift build 2>&1 | smith-sbsift --format compact
```

### smith-validation

```bash
# Summary (human-readable)
smith-validation . --format=summary

# Detailed (complete diagnostic)
smith-validation . --format=detailed

# JSON (for tools/CI)
smith-validation . --format=json
```

### sosumi

```bash
# Markdown (default)
/skill sosumi search "topic"

# Compact agent mode (token efficient)
/skill sosumi search "topic" --mode compact-agent

# JSON
/skill sosumi search "topic" --format json

# Compact JSON
/skill sosumi search "topic" --format json-compact
```

---

## Performance Impact

| Tool | Token Reduction | Parse Time | Use Case |
|------|-----------------|------------|----------|
| smith-sbsift | 43% | <100ms | Swift builds |
| smith-xcsift | 60% | <200ms | Xcode builds |
| smith-spmsift | 95%+ | <1ms | Dependencies |
| smith-validation | N/A | 2-5s | Architecture |
| sosumi | Varies | 50-500ms | Documentation |

Using these tools consistently saves **50-70% token usage** on average builds.

---

## Troubleshooting

### "Tool not found" error

```bash
# Verify installation
which smith-sbsift
which smith-xcsift
which smith-spmsift
smith-validation --version

# If not found, reinstall
bash install-smith-tools-unified.sh
```

### "Command not recognized" (for sosumi)

```bash
# sosumi is accessed via Claude Code skill, use:
/skill sosumi search "topic"

# Not as a CLI tool
```

### "Output is too verbose"

Use `--format summary` or `--format compact`:
```bash
swift build 2>&1 | smith-sbsift --format summary
```

### "I need more detail"

Use `--format detailed`:
```bash
swift build 2>&1 | smith-sbsift --format detailed
smith-validation . --format=detailed
```

---

## Summary

**Key Patterns:**

1. **Always pipe build output** through analysis tools (smith-sbsift, smith-xcsift)
   ```bash
   swift build 2>&1 | smith-sbsift
   ```

2. **Use smith-spmsift for dependencies**
   ```bash
   swift package show-dependencies | smith-spmsift
   ```

3. **Validate TCA code regularly**
   ```bash
   smith-validation . --level=standard
   ```

4. **Reference Apple docs with sosumi**
   ```bash
   /skill sosumi search "topic"
   ```

5. **Choose format based on need**
   - `--format summary` (default, most cases)
   - `--format detailed` (troubleshooting)
   - `--format json` (automation)

---

**Last Updated:** December 4, 2025
