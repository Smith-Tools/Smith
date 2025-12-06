# Build Command Defaults - Mandatory Patterns

This document defines the default behavior for running build commands with Smith Tools.

---

## Core Principle

**NEVER run build commands without Smith tool analysis.**

Build output is verbose and token-intensive. Smith tools compress it by 40-60% while extracting structured errors, warnings, and metrics.

---

## Decision Tree

```
User asks to build/test/analyze
        │
        ├─ Is it Xcode? ─────────► xcodebuild ... 2>&1 | smith-xcsift
        │
        ├─ Is it Swift Package? ──► swift build 2>&1 | smith-sbsift
        │
        ├─ Is it SPM deps? ───────► swift package ... | smith-spmsift
        │
        └─ Is it TCA code? ───────► smith-validation
```

---

## Template Commands

### Xcode Builds

**macOS app**:
```bash
xcodebuild build \
  -workspace [WORKSPACE].xcworkspace \
  -scheme [SCHEME] \
  -destination 'platform=macOS' \
  2>&1 | smith-xcsift --format summary
```

**iOS app**:
```bash
xcodebuild build \
  -workspace [WORKSPACE].xcworkspace \
  -scheme [SCHEME] \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  2>&1 | smith-xcsift --format summary
```

**Clean build** (for thorough analysis):
```bash
xcodebuild clean build \
  -workspace [WORKSPACE].xcworkspace \
  -scheme [SCHEME] \
  -destination 'platform=macOS' \
  2>&1 | smith-xcsift --format detailed
```

### Swift Package Manager

**Debug build**:
```bash
swift build 2>&1 | smith-sbsift --format summary
```

**Release build**:
```bash
swift build -c release 2>&1 | smith-sbsift --format summary
```

**With performance analysis**:
```bash
swift build 2>&1 | smith-sbsift --format detailed
```

### SPM Dependencies

**Show dependencies**:
```bash
swift package show-dependencies | smith-spmsift
```

**Resolve dependencies**:
```bash
swift package resolve 2>&1 | smith-spmsift
```

**Update dependencies**:
```bash
swift package update 2>&1 | smith-spmsift
```

---

## Flags to AVOID

### ❌ Never Use These Flags

- `--quiet` / `-quiet`: Suppresses output smith tools need
- `-hideShellScriptEnvironment`: Makes debugging harder
- `2>/dev/null`: Discards errors
- `> /dev/null`: Discards all output

### ✅ Flags to USE

- `2>&1`: Captures both stdout and stderr
- `-destination`: Specifies build target
- `-scheme`: Specifies build scheme
- `--format summary`: Quick smith-xcsift output (recommended default)

---

## Output Format Selection

### When to use each format:

| Format | Use When | Token Size |
|--------|----------|------------|
| `summary` | Quick build check, CI/CD | Smallest (40-60% reduction) |
| `detailed` | Deep error analysis | Medium |
| `json` | Programmatic parsing | Medium |
| `compact` | Minimal context, quick scan | Smallest |

**Default**: Use `--format summary` unless user requests detail.

---

## Special Cases

### When User Says "Just build it"

**Interpret as**: "Build and analyze the results"

**Action**: Run build with smith tool (summary format)

```bash
xcodebuild build ... 2>&1 | smith-xcsift --format summary
```

### When User Says "Quick build"

**Interpret as**: "Fast build with minimal analysis"

**Action**: Still use smith tool but with compact format

```bash
xcodebuild build ... 2>&1 | smith-xcsift --format compact
```

### When User Says "Show me the raw output"

**Only then**: Run bare command

```bash
xcodebuild build ...  # No smith-xcsift
```

---

## Integration with Other Tools

### With git hooks

```bash
#!/bin/bash
# pre-commit hook
swift build 2>&1 | smith-sbsift --format summary || exit 1
```

### With CI/CD

```yaml
- name: Build and Analyze
  run: |
    xcodebuild build ... 2>&1 | smith-xcsift --format json > analysis.json

- name: Check Results
  run: |
    if grep -q '"status":"failed"' analysis.json; then
      exit 1
    fi
```

---

## Performance Considerations

### Token Savings

- **Raw xcodebuild**: ~50,000 tokens for medium build
- **With smith-xcsift**: ~20,000 tokens (60% reduction)

### Time Savings

- **Parsing**: <500ms overhead
- **Analysis**: Agent spends less time reading output
- **Net benefit**: 2-3x faster error identification

---

## Enforcement

These patterns are **mandatory**, not optional.

- Skills should auto-apply these patterns
- Only deviate when user explicitly requests
- Default to using Smith tools in all build scenarios

---

**Last Updated**: December 4, 2025
