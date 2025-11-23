# Smith Tools: Composition & Integration

How to combine Smith tools for maximum impact.

---

## 🔗 Tool Relationships

Smith Tools consists of **independent, composable pieces** that work together:

```
smith-core (Foundation Library)
    ↓ (provides shared models)
    ├─→ smith-sbsift (Swift Build Analysis)
    ├─→ smith-spmsift (SPM Dependency Analysis)
    ├─→ smith-xcsift (Xcode Build Analysis)
    └─→ smith-validation (TCA Rule Engine)
        ↓
        ├─→ smith-cli (Orchestrator CLI)
        └─→ @smith (Claude Code Agent)

External Partners:
    ├─→ maxwell (Pattern Expertise)
    ├─→ sosumi (Apple Documentation)
```

---

## 📊 Tool Output Formats

### smith-sbsift (Build Analysis)

**Input**: Build log (via stdin)
```bash
swift build 2>&1 | smith-sbsift analyze
```

**Output**: JSON or text
```json
{
  "tool": "smith-sbsift",
  "status": "success",
  "build_time_seconds": 45,
  "files_compiled": 127,
  "bottlenecks": [
    {
      "file": "Sources/Features/Analytics.swift",
      "time_seconds": 8.5,
      "reason": "Type inference"
    }
  ]
}
```

### smith-spmsift (Dependency Analysis)

**Input**: Package manifest
```bash
swift package dump-package | smith-spmsift analyze
```

**Output**: JSON dependency tree
```json
{
  "tool": "smith-spmsift",
  "status": "success",
  "targets": 12,
  "issues": [
    {
      "type": "circular_dependency",
      "packages": ["FeatureA", "FeatureB"]
    }
  ]
}
```

### smith-validation (Architecture Rules)

**Input**: Directory path or files
```bash
smith-validation . --level standard
```

**Output**: JSON violations
```json
{
  "violations": [
    {
      "rule": "1.1",
      "severity": "critical",
      "file": "UserProfileReducer.swift:42",
      "issue": "Monolithic state: 18 properties",
      "suggestion": "Break into sub-features"
    }
  ]
}
```

---

## 🔄 Complete Workflows

### Workflow 1: Full Project Validation

**Scenario**: Before pushing to main branch

**Commands**:
```bash
# Step 1: Check dependencies for conflicts
swift package dump-package | smith-spmsift analyze --format json

# Step 2: Analyze architecture
smith validate --tca --level comprehensive

# Step 3: Create build and monitor
swift build 2>&1 | smith-sbsift monitor --hang-detection

# Step 4: Get summary
smith-cli status
```

**Expected output**:
- ✅ No circular dependencies
- ✅ All TCA rules pass
- ✅ Build completes without hangs
- ✅ Ready to commit

---

### Workflow 2: Quick Daily Check

**Scenario**: Morning validation before feature work

**Commands**:
```bash
# Quick validation (< 1 minute)
smith-cli status              # Check tools
smith validate --tca          # Quick TCA check
smith-spmsift show-dependencies --summary  # Dependency overview
```

**Expected output**:
- Quick pass/fail on architecture
- Dependency count
- Tool status

---

### Workflow 3: Diagnosis & Recovery

**Scenario**: Build is hanging or failing

**Commands**:
```bash
# Step 1: Capture the issue
swift build 2>&1 | smith-sbsift analyze --hang-detection > build-analysis.json

# Step 2: Detailed diagnosis
smith-xcsift diagnose

# Step 3: Get recovery strategy
smith-xcsift rebuild --smart-strategy

# Step 4: Apply and monitor
swift build 2>&1 | smith-sbsift monitor --eta
```

**Expected output**:
- Root cause of hang
- Recovery strategy (clean, incremental, etc.)
- Time estimate for rebuild
- Progress indication

---

### Workflow 4: Code Review Validation

**Scenario**: Reviewing pull request before merge

**Commands**:
```bash
# Comprehensive validation
smith-cli analyze \
  --level critical \
  --format json > pr-analysis.json

# TCA-specific check
smith validate --tca --format json > tca-validation.json

# Summary report
smith-cli report pr-analysis.json tca-validation.json
```

**Expected output**:
- JSON report suitable for CI/CD
- All violations catalogued
- Suggestions for fixes

---

## 🔀 Tool Integration Patterns

### Pattern 1: Sequential Validation

Use when you need comprehensive analysis:

```bash
#!/bin/bash
set -e

echo "Phase 1: Dependency Analysis"
swift package dump-package | smith-spmsift analyze

echo "Phase 2: Architecture Validation"
smith validate --tca --level standard

echo "Phase 3: Build Check"
swift build 2>&1 | smith-sbsift analyze

echo "✅ All validations passed!"
```

### Pattern 2: Real-Time Monitoring

Use during active development:

```bash
#!/bin/bash

# Terminal 1: Watch builds
watch -n 5 'smith-cli status'

# Terminal 2: Run build and analyze
swift build 2>&1 | smith-sbsift monitor --hang-detection
```

### Pattern 3: Problem-Driven Investigation

Use when something specific is wrong:

```bash
#!/bin/bash

# Identify the problem
PROBLEM="$1"  # e.g., "slow_build", "type_error", "hang"

case "$PROBLEM" in
  slow_build)
    swift build 2>&1 | smith-sbsift analyze --slow-detection
    ;;
  type_error)
    smith-cli analyze --focus type-inference
    ;;
  hang)
    swift build 2>&1 | smith-sbsift analyze --hang-detection
    smith-xcsift diagnose
    ;;
  architecture)
    smith validate --tca --level comprehensive
    ;;
esac
```

### Pattern 4: CI/CD Integration

Use in automated pipelines:

```yaml
# Example GitHub Actions
- name: Smith Tools Validation
  run: |
    # Dependency check
    swift package dump-package | smith-spmsift analyze --format json > deps.json

    # Architecture validation
    smith validate --tca --format json > validation.json

    # Report
    smith-cli report deps.json validation.json > report.md

    # Fail if critical violations
    if grep -q '"severity": "critical"' validation.json; then
      exit 1
    fi
```

---

## 📋 Tool Selection Matrix

**Use this to choose which tool(s) to use:**

| Situation | Primary Tool | Secondary | Command |
|-----------|-------------|-----------|---------|
| First time setup | smith-cli | - | `detect` |
| Validating code | smith-validation | maxwell | `smith validate --tca` |
| Build is slow | smith-sbsift | smith-xcsift | `swift build 2>&1 \| smith-sbsift analyze` |
| Build is hanging | smith-sbsift | smith-xcsift | `smith-sbsift analyze --hang-detection` |
| Dependencies broken | smith-spmsift | - | `smith-spmsift show-dependencies` |
| Need patterns | maxwell | - | `maxwell search "topic"` |
| Need documentation | sosumi | - | `sosumi docs "framework"` |
| Architectural decision | smith | maxwell | `smith validate` + `maxwell search` |
| Build failure recovery | smith-xcsift | smith-sbsift | `smith-xcsift diagnose` |

---

## ⚙️ Configuration & Customization

### Output Format Configuration

**Default to JSON for piping:**
```bash
smith validate --tca --format json
smith-spmsift show-dependencies --format json
smith-sbsift analyze --format json
```

**Use text for human reading:**
```bash
smith validate --tca --format text
smith-spmsift show-dependencies
smith-sbsift analyze --verbose
```

### Caching & Performance

Smith tools use a shared cache in `~/.smith/cache/`:

```bash
# Clear cache if issues
rm -rf ~/.smith/cache

# Check cache size
du -sh ~/.smith/cache

# Set custom cache location
export SMITH_CACHE_DIR=~/my-smith-cache
```

### Environment Variables

```bash
# Control logging verbosity
export SMITH_LOGLEVEL=debug    # debug, info, warn, error

# Parallel processing
export SMITH_PARALLEL=8        # Number of workers

# Output format
export SMITH_FORMAT=json       # json, text, csv

# Skip validation levels
export SMITH_SKIP_WARNING=true # Only show critical
```

---

## 🚀 Best Practices

### 1. Always Start with Status Check
```bash
smith-cli status  # See what's installed
smith-cli detect  # Understand project context
```

### 2. Use Appropriate Validation Level
```bash
# During development
smith validate --tca --level standard

# Before commit
smith validate --tca --level comprehensive

# In CI/CD
smith validate --tca --level critical
```

### 3. Monitor Builds in Real-Time
```bash
# Live progress with hang detection
swift build 2>&1 | smith-sbsift monitor --hang-detection --eta
```

### 4. Keep Dependencies Clean
```bash
# Regularly check
swift package dump-package | smith-spmsift analyze

# Watch for changes
watch -n 5 'smith-spmsift show-dependencies --summary'
```

### 5. Use JSON for Automation
```bash
# Capture for later analysis
swift build 2>&1 | smith-sbsift analyze --format json > build.json

# Parse with jq
cat build.json | jq '.bottlenecks | length'

# Generate reports
smith-cli report build.json
```

---

## 🔧 Troubleshooting Tool Composition

### Issue: Tool output format incompatible

**Solution**: Use explicit --format flag
```bash
smith-sbsift analyze --format json  # Explicit JSON output
```

### Issue: Tools not piping correctly

**Verify each tool individually:**
```bash
swift build 2>&1 > build.log        # Capture build
cat build.log | smith-sbsift analyze # Test piping
```

### Issue: Performance degradation

**Check cache:**
```bash
du -sh ~/.smith/cache/
rm -rf ~/.smith/cache/  # Clear if needed
```

**Use faster tools:**
```bash
# Quick check instead of comprehensive
smith validate --tca --level standard
# Instead of:
smith validate --tca --level comprehensive
```

---

## 📚 Related Documents

- **GETTING_STARTED.md** - Which tool to use for your task
- **SMITH_TOOLS_WORKFLOW_GUIDE.md** - Overall workflow philosophy
- **ARCHITECTURE.md** - How tools are designed
- **Tool reference docs** - Specific tool options

