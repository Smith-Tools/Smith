# Smith Tools CLI Command Reference

## Overview

The Smith Tools CLI provides a unified interface to all Smith build analysis tools. This reference covers all available commands, options, and usage patterns.

## Quick Start

### Basic Usage
```bash
# Show help
smith --help

# Show version
smith --version

# Analyze current directory with smart detection
smith smart-analyze

# Validate TCA architecture
smith validate ./MyApp
```

### Common Workflows
```bash
# Xcode project analysis
smith xcode analyze MyApp.xcodeproj

# Swift package dependency analysis
smith spm analyze

# Build output parsing
swift build | smith swift parse

# TCA performance tracing
smith tca trace ./MyFeature
```

## Command Structure

The CLI follows a consistent **verb-noun** pattern:

```
smith <verb> <target> [options]
smith <group> <command> [options]  # Specialized commands
```

## Primary Commands

### smith validate

Validates Swift projects for TCA (The Composable Architecture) compliance.

**Synopsis:**
```bash
smith validate [path] [options]
```

**Arguments:**
- `path` - Path to project directory (default: current directory)

**Options:**
- `--deep` - Perform deep validation including all files
- `--level <critical|standard|comprehensive>` - Validation level (default: critical)
- `--format <json|summary>` - Output format (default: summary)
- `--config <path>` - PKL configuration file path

**Examples:**
```bash
# Basic validation
smith validate ./MyApp

# Comprehensive validation with JSON output
smith validate ./MyApp --level comprehensive --format json

# Deep validation with custom config
smith validate ./MyApp --deep --config rules.json
```

### smith smart-analyze

Automatically detects project type and delegates to the most appropriate tool.

**Synopsis:**
```bash
smith smart-analyze [path] [options]
```

**Arguments:**
- `path` - Path to analyze (default: current directory)

**Options:**
- `--format <json|summary>` - Output format (default: summary)
- `--verbose` - Include detailed diagnostics
- `--force-tool <tool>` - Force specific tool instead of auto-detection

**Examples:**
```bash
# Auto-detect and analyze
smith smart-analyze

# Force specific tool
smith smart-analyze ./MyApp --force-tool smith-xcsift

# JSON output for automation
smith smart-analyze ./MyApp --format json
```

### smith analyze

General project analysis with basic diagnostics.

**Synopsis:**
```bash
smith analyze [path] [options]
```

**Options:**
- `--hang-detection` - Enable hang detection
- `--cpu-threshold <percentage>` - CPU threshold for hang detection
- `--memory-threshold <gb>` - Memory threshold for hang detection
- `--timeout <seconds>` - Hang detection timeout (default: 30)

**Examples:**
```bash
# Basic analysis
smith analyze ./MyApp

# Analysis with hang detection
smith analyze ./MyApp --hang-detection --cpu-threshold 80
```

### smith parse

Parse build output from stdin (delegates to appropriate parser).

**Synopsis:**
```bash
command | smith parse [options]
```

**Options:**
- `--format <json|summary|detailed>` - Output format (default: summary)
- `--verbose` - Include verbose output
- `--compact` - Compact output mode
- `--minimal` - Minimal output mode (85%+ size reduction)

**Examples:**
```bash
# Parse Xcode build output
xcodebuild | smith parse

# Parse Swift build output with minimal format
swift build | smith parse --minimal

# Detailed JSON output
swift test | smith parse --format json --verbose
```

## Specialized Command Groups

### smith xcode

Xcode-specific tools for project analysis and build monitoring.

#### smith xcode analyze

Analyze Xcode project build performance and dependencies.

**Synopsis:**
```bash
smith xcode analyze [path] [options]
```

**Options:**
- `--json` - Output in JSON format
- `--dependencies` - Include dependency analysis
- `--performance` - Perform build performance analysis
- `--hang-detection` - Enable hang detection analysis

**Examples:**
```bash
# Basic Xcode analysis
smith xcode analyze MyApp.xcodeproj

# Comprehensive analysis with JSON output
smith xcode analyze MyApp.xcodeproj --performance --dependencies --json
```

#### smith xcode parse

Parse Xcode build output from stdin.

**Synopsis:**
```bash
xcodebuild [options] | smith xcode parse [options]
```

**Options:**
- `--format <json|summary|detailed>` - Output format (default: summary)
- `--verbose` - Include verbose output
- `--compact` - Compact output mode

**Examples:**
```bash
# Parse Xcode build
xcodebuild | smith xcode parse

# Parse with detailed output
xcodebuild | smith xcode parse --format detailed --verbose
```

### smith swift

Swift build analysis and parsing tools.

#### smith swift analyze

Analyze Swift build performance and issues.

**Synopsis:**
```bash
smith swift analyze [path] [options]
```

**Options:**
- `--json` - Output in JSON format
- `--hang-detection` - Perform hang detection analysis
- `--file-timing` - Show file-level compilation timing
- `--bottleneck <count>` - Show top N slowest files (default: 5)

**Examples:**
```bash
# Basic Swift analysis
smith swift analyze ./MyPackage

# Analysis with timing and bottleneck detection
smith swift analyze ./MyPackage --file-timing --bottleneck 10
```

#### smith swift parse

Parse Swift build output from stdin.

**Synopsis:**
```bash
swift build [options] | smith swift parse [options]
```

**Options:**
- `--format <json|summary|detailed>` - Output format (default: summary)
- `--verbose` - Include verbose output
- `--compact` - Compact output mode
- `--minimal` - Minimal output mode

**Examples:**
```bash
# Parse Swift build
swift build | smith swift parse

# Minimal output for CI/CD
swift build | smith swift parse --minimal
```

### smith spm

Swift Package Manager specific tools.

#### smith spm analyze

Analyze Swift Package Manager dependencies and structure.

**Synopsis:**
```bash
smith spm analyze [path] [options]
```

**Options:**
- `--json` - Output in JSON format
- `--dependencies` - Include dependency tree analysis
- `--optimize` - Perform package optimization analysis
- `--circular` - Check for circular dependencies

**Examples:**
```bash
# Basic SPM analysis
smith spm analyze ./MyPackage

# Analysis with dependency tree
smith spm analyze ./MyPackage --dependencies --circular
```

#### smith spm dependencies

Analyze Swift Package dependencies.

**Synopsis:**
```bash
smith spm dependencies [path] [options]
```

**Options:**
- `--tree` - Show dependency tree
- `--outdated` - Check for outdated dependencies
- `--json` - Output in JSON format

**Examples:**
```bash
# Show dependency tree
smith spm dependencies ./MyPackage --tree

# Check for outdated dependencies
smith spm dependencies ./MyPackage --outdated
```

### smith tca

The Composable Architecture specific tools.

#### smith tca trace

TCA performance profiling and trace analysis.

**Synopsis:**
```bash
smith tca trace [path] [options]
```

**Options:**
- `--json` - Output trace data in JSON format
- `--memory` - Include memory analysis
- `--complexity` - Include reducer complexity analysis
- `--output <path>` - Output file for trace results

**Examples:**
```bash
# Basic TCA tracing
smith tca trace ./MyFeature

# Comprehensive tracing with memory analysis
smith tca trace ./MyFeature --memory --complexity --output trace.json
```

#### smith tca analyze

Analyze TCA architecture patterns and performance.

**Synopsis:**
```bash
smith tca analyze [path] [options]
```

**Options:**
- `--json` - Output in JSON format
- `--complexity` - Check reducer complexity
- `--dependencies` - Analyze dependency injection patterns
- `--antipatterns` - Check for anti-patterns

**Examples:**
```bash
# Basic TCA architecture analysis
smith tca analyze ./MyFeature

# Comprehensive analysis
smith tca analyze ./MyFeature --complexity --dependencies --antipatterns
```

#### smith tca compare

Compare TCA performance or architecture between two states.

**Synopsis:**
```bash
smith tca compare <baseline> <current> [options]
```

**Arguments:**
- `baseline` - Baseline trace file or path
- `current` - Current trace file or path

**Options:**
- `--json` - Output in JSON format
- `--detailed` - Show detailed differences

**Examples:**
```bash
# Compare two trace files
smith tca compare baseline.json current.json

# Detailed comparison
smith tca compare baseline.json current.json --detailed
```

## Legacy Commands

These commands provide backward compatibility with standalone tools:

### smith detect

Detect build system and project type.

**Synopsis:**
```bash
smith detect [path]
```

### smith status

Show build environment status.

**Synopsis:**
```bash
smith status
```

### smith optimize

Optimize project build configuration.

**Synopsis:**
```bash
smith optimize [path] [options]
```

**Options:**
- `--apply` - Apply optimizations automatically

### smith environment

Show detailed environment information.

**Synopsis:**
```bash
smith environment
```

### smith monitor-build

Monitor an active build process.

**Synopsis:**
```bash
smith monitor-build <command> [options]
```

**Options:**
- `--cpu-threshold <percentage>` - CPU threshold for alerts (default: 80.0)
- `--memory-threshold <gb>` - Memory threshold for alerts (default: 2.0)

### smith version

Show version information.

**Synopsis:**
```bash
smith version
```

## Global Options

Available on all commands:

- `--help, -h` - Show help text
- `--version, -v` - Show version information
- `--quiet, -q` - Minimal output
- `--verbose` - Detailed output
- `--format <json|summary>` - Output format
- `--no-color` - Disable ANSI colors
- `--dry-run, -n` - Preview changes without applying

## Exit Codes

- `0` - Success
- `1` - General error
- `2` - Invalid arguments
- `3` - Required tool not found
- `4` - Validation failed
- `5` - Timeout
- `126` - Command cannot execute
- `127` - Command not found

## Environment Variables

- `SMITH_CONFIG` - Path to configuration file
- `SMITH_VERBOSE` - Enable verbose output (any non-empty value)
- `SMITH_NO_COLOR` - Disable colored output (any non-empty value)
- `SMITH_TIMEOUT` - Default timeout in seconds

## Configuration

### Configuration File

Create `~/.smith/config.json` or use `SMITH_CONFIG`:

```json
{
  "defaults": {
    "validation": {
      "level": "standard",
      "format": "summary"
    },
    "analysis": {
      "timeout": 300,
      "hangDetection": false
    }
  },
  "tools": {
    "smithValidationPath": "/usr/local/bin/smith-validation",
    "smithXCSiftPath": "/usr/local/bin/smith-xcsift"
  },
  "output": {
    "colors": true,
    "progress": true
  }
}
```

### Per-Command Configuration

#### Validation Settings
```json
{
  "validation": {
    "levels": {
      "critical": "Basic TCA rules only",
      "standard": "Standard TCA compliance",
      "comprehensive": "All rules including experimental"
    },
    "rules": {
      "maxReducerActions": 40,
      "requireDependencyInjection": true,
      "checkTestCoverage": false
    }
  }
}
```

#### Analysis Settings
```json
{
  "analysis": {
    "timeouts": {
      "validation": 120,
      "tracing": 300,
      "parsing": 60
    },
    "hangDetection": {
      "cpuThreshold": 80.0,
      "memoryThreshold": 2.0,
      "timeout": 30
    }
  }
}
```

## Troubleshooting

### Common Issues

#### Tool Not Found
```
❌ smith-validation not found
```
**Solution:** Install smith-validation via Homebrew:
```bash
brew install smith-validation
```

#### Permission Denied
```
❌ Cannot execute smith-xcsift: Permission denied
```
**Solution:** Make tool executable:
```bash
chmod +x /usr/local/bin/smith-xcsift
```

#### Invalid Project Path
```
❌ Not a valid Xcode project
```
**Solution:** Ensure path contains `.xcodeproj` or `.xcworkspace`:
```bash
smith xcode analyze ./MyApp/MyApp.xcodeproj
```

#### Dependency Version Mismatch
```
⚠️  xcodebuild 14.0 detected (recommended: 15.0+)
```
**Solution:** Update Xcode to latest version or use compatible tool version.

### Debug Mode

Enable verbose logging:
```bash
export SMITH_VERBOSE=1
smith validate ./MyApp --verbose
```

### Logging

Smith CLI logs to:
- **macOS**: `~/Library/Logs/Smith/`
- **Linux**: `~/.local/share/smith/logs/`
- **Configurable**: Via `SMITH_LOG_PATH` environment variable

Log levels:
- `ERROR` - Critical errors only
- `WARN` - Warnings and errors
- `INFO` - General information
- `DEBUG` - Detailed debugging information

## Integration Examples

### CI/CD Integration

#### GitHub Actions
```yaml
- name: Validate TCA Architecture
  run: |
    smith validate ./MyApp --format json > validation-results.json
    if [ $(jq '.violations | length' validation-results.json) -gt 0 ]; then
      echo "TCA validation failed"
      exit 1
    fi
```

#### GitLab CI
```yaml
validate_tca:
  script:
    - smith validate ./MyApp --format json
  artifacts:
    reports:
      junit: validation-results.xml
```

### Shell Integration

#### Bash Completion
```bash
# Add to ~/.bashrc
source <(smith completion bash)
```

#### Alfred Workflow
```json
{
  "name": "Smith Tools",
  "actions": [{
    "type": "runScript",
    "script": "smith {query}"
  }]
}
```

### IDE Integration

#### VS Code Task
```json
{
  "label": "Smith Validate",
  "type": "shell",
  "command": "smith",
  "args": ["validate", "${workspaceFolder}"],
  "group": "build"
}
```

#### Xcode Build Phase
```bash
# Add to Run Script build phase
smith xcode analyze "${PROJECT_FILE_PATH}" --json > "${BUILD_DIR}/smith-analysis.json"
```

## Performance Tuning

### For Large Projects

```bash
# Use lighter analysis
smith validate ./LargeProject --level critical --quiet

# Parallel processing
smith smart-analyze ./LargeProject --verbose

# Exclude unnecessary files
smith validate ./LargeProject --exclude "Tests/**/*" --exclude "**/*.generated.swift"
```

### For CI/CD

```bash
# Fast validation for PRs
smith validate ./MyApp --level critical --format json --quiet

# Detailed analysis for main branch
smith validate ./MyApp --deep --format json --output results.json
```

### Memory Optimization

```bash
# Reduce memory usage
smith analyze ./LargeProject --memory-threshold 1.0 --timeout 60

# Stream processing for build output
swift build | smith swift parse --minimal --no-color
```

## Best Practices

1. **Use specific commands** when you know the project type
2. **Use `smart-analyze`** for unknown or mixed project types
3. **Enable `--verbose`** for debugging issues
4. **Use `--format json`** for automation and CI/CD
5. **Set timeouts** for automated environments
6. **Check dependencies** before running analysis
7. **Use `--dry-run`** to preview changes
8. **Enable hang detection** for long-running builds

## See Also

- [CLI Design Principles](CLI-DESIGN.md) - Design philosophy and guidelines
- [Examples](EXAMPLES.md) - Real-world usage examples
- [Error Codes](ERROR-CODES.md) - Comprehensive error reference
- [Smith Tools Documentation](https://smith-tools.dev/docs/)