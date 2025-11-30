# Smith Tools Frequently Asked Questions

This FAQ addresses the most common questions and issues when using Smith Tools CLI.

## General Questions

### What is Smith Tools?

Smith Tools is a comprehensive suite of command-line utilities for Swift development, focusing on TCA (The Composable Architecture) validation, Xcode project analysis, Swift build optimization, and performance profiling.

### Why should I use Smith Tools?

**Key Benefits:**
- **Unified Interface**: Single CLI for all development tools
- **TCA Compliance**: Ensures your architecture follows TCA best practices
- **Build Optimization**: Identifies performance bottlenecks and optimization opportunities
- **Developer Experience**: Rich terminal output with progress indicators and smart formatting
- **CI/CD Ready**: JSON output formats for automation and integration

### Is Smith Tools free?

Yes, Smith Tools is open-source and free to use under the MIT License.

## Installation & Setup

### What are the system requirements?

**macOS (Primary Platform):**
- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later
- Swift 5.7 or later
- 8GB RAM (16GB recommended)

**Linux (Experimental):**
- Ubuntu 20.04 LTS or later
- Debian 11 or later
- Swift 5.7 or later

See [Installation Guide](INSTALLATION-GUIDE.md) for detailed requirements.

### How do I install Smith Tools?

**Recommended (Homebrew):**
```bash
brew tap smith-tools/smith
brew install smith-tools
```

**Alternative (Manual):**
```bash
curl -L https://github.com/Smith-Tools/smith/releases/latest/download/smith-cli -o smith
chmod +x smith
./smith install-all
```

See [Installation Guide](INSTALLATION-GUIDE.md) for all installation methods.

### Why am I getting "command not found" errors?

**Solutions:**
1. Check PATH: `echo $PATH | grep smith`
2. Add to PATH: `export PATH="$HOME/bin/smith-tools/bin:$PATH"`
3. Reinstall: `brew reinstall smith-tools`
4. Check installation: `which smith`

### How do I verify the installation?

```bash
smith --version      # Check CLI version
smith status         # Check all tools
smith validate --version  # Test individual tools
```

## Usage Questions

### How do I use the smart analysis?

```bash
# Auto-detect and analyze current project
smith smart-analyze

# Analyze specific directory
smith smart-analyze ./MyProject

# Force specific tool
smith smart-analyze --force-tool smith-xcsift
```

### What does "auto" format mean?

The `auto` format automatically selects the best output based on context:
- **Terminal (TTY)**: Human-readable with colors and emojis
- **Piped/Redirected**: Machine-readable JSON

```bash
smith validate  # Auto-detects context
smith validate --format auto  # Explicit auto mode
```

### How do I get JSON output for scripts?

```bash
# Force JSON format
smith validate --format json

# Or use auto format in scripts (recommended)
smith validate --format auto  # Automatically uses JSON when piped
```

### What validation levels are available?

- **critical**: Basic TCA rules only (fastest)
- **standard**: Standard TCA compliance (recommended for development)
- **comprehensive**: All rules including experimental (slowest)

```bash
smith validate --level critical   # Quick checks
smith validate --level standard   # Balanced approach
smith validate --level comprehensive  # Full analysis
```

## Error Troubleshooting

### "smith-validation not found"

**Cause:** Individual tool not installed or not in PATH.

**Solutions:**
```bash
# Install missing tools
brew install smith-validation smith-xcsift smith-sbsift smith-spmsift smith-tca-trace

# Check PATH
echo $PATH

# Set custom paths
smith config set tools.smithValidationPath /opt/homebrew/bin/smith-validation
```

### "Not a valid Xcode project"

**Cause:** Path doesn't contain `.xcodeproj` or `.xcworkspace`.

**Solutions:**
```bash
# Verify path
ls -la MyApp.xcodeproj

# Use correct path
smith xcode analyze ./MyApp/MyApp.xcodeproj

# Use smart detection instead
smith smart-analyze
```

### "Swift version not supported"

**Cause:** Swift version too old or not found.

**Solutions:**
```bash
# Check Swift version
swift --version

# Update Xcode Command Line Tools
xcode-select --install

# Install Swift separately (Linux)
wget https://swift.org/download/
```

### TCA validation fails with many violations

**This is normal for existing projects.** Recommendations:

1. **Start with critical level:**
   ```bash
   smith validate --level critical
   ```

2. **Fix critical issues first:**
   - Monolithic reducers (>40 actions)
   - Missing dependency injection
   - Large view structs

3. **Gradually improve:**
   ```bash
   smith validate --level standard
   smith validate --level comprehensive
   ```

4. **Use validation in CI/CD:**
   ```bash
   smith validate --level critical --format json
   ```

### Performance issues during validation

**For large projects:**

```bash
# Use faster validation level
smith validate --level critical

# Exclude test/generated files
smith validate --exclude "Tests/**/*" --exclude "Generated/**/*"

# Use lightweight analysis
smith analyze --timeout 60
```

## Configuration Questions

### How do I create a configuration file?

```bash
# Create default config
smith config init

# Edit config
smith config edit
```

**Example config:**
```json
{
  "defaults": {
    "validation": {
      "level": "standard",
      "format": "summary"
    }
  },
  "tools": {
    "smithValidationPath": "/opt/homebrew/bin/smith-validation"
  }
}
```

### Where is the configuration stored?

- **Global**: `~/.smith/config.json`
- **Project**: `./.smith/config.json`
- **Environment**: `SMITH_CONFIG` environment variable

### How do I disable colors?

```bash
# Environment variable
export SMITH_NO_COLOR=1
smith validate

# Command line
smith validate --no-color

# Configuration file
{
  "output": {
    "colors": false
  }
}
```

### How do I increase timeout for large projects?

```bash
# Command line
smith validate --timeout 300

# Configuration
{
  "performance": {
    "timeout": 300
  }
}

# Environment
export SMITH_TIMEOUT=300
```

## Output & Formatting Questions

### Why does output look different in different contexts?

Smith Tools automatically adapts output based on context:

- **Interactive terminal**: Human-readable with colors and progress
- **Piped output**: Machine-readable JSON
- **Redirected output**: Machine-readable JSON

```bash
# Terminal - rich output
smith validate

# Piped - JSON output
smith validate | jq '.'

# Explicit format control
smith validate --format summary
smith validate --format json
smith validate --format detailed
```

### What do the different output formats mean?

- **auto**: Automatically detect best format (recommended)
- **json**: Machine-readable JSON for scripts
- **summary**: Human-readable with emojis and structure
- **detailed**: Comprehensive output with full context
- **compact**: Space-efficient output (85% size reduction)
- **minimal**: Essential information only (95% size reduction)

### How do I interpret validation results?

**JSON format:**
```json
{
  "success": true,
  "summary": {
    "totalFiles": 45,
    "violationsCount": 3,
    "healthScore": 92
  },
  "violations": [
    {
      "severity": "critical",
      "file": "MyFeature.swift",
      "line": 42,
      "message": "Monolithic reducer",
      "rule": "1.1"
    }
  ]
}
```

**Summary format:**
```
🎯 TCA ARCHITECTURE VALIDATION
===============================
Status: ✅ Success
Files Analyzed: 45
Violations Found: 3
Health Score: 92/100

🚨 VIOLATIONS (3 found)

MyFeature.swift:42
  ✗ Monolithic reducer (48 actions, limit: 40)
  Rule: 1.1 - Keep features focused
```

## CI/CD & Automation

### How do I integrate with GitHub Actions?

```yaml
- name: Validate TCA Architecture
  run: |
    smith validate --level critical --format json > validation.json
    
- name: Fail on Violations
  run: |
    VIOLATIONS=$(jq '.violations | length' validation.json)
    if [ "$VIOLATIONS" -gt 0 ]; then
      echo "TCA validation failed with $VIOLATIONS violations"
      jq '.violations[]' validation.json
      exit 1
    fi
```

### How do I fail builds on TCA violations?

```bash
# Fail fast on critical issues
smith validate --level critical --format json | jq -e '.success == true' > /dev/null

# Or use specific violation count
smith validate --level critical --format json | \
  jq -e '[.violations[] | select(.severity == "critical")] | length == 0' > /dev/null
```

### How do I use in pre-commit hooks?

```bash
# .git/hooks/pre-commit
smith validate --level critical --quiet || {
    echo "❌ TCA validation failed"
    echo "Run 'smith validate' for details"
    exit 1
}
```

### How do I generate reports for CI?

```bash
# Comprehensive report
smith validate --level comprehensive --format json --output validation-report.json

# Multiple formats
smith validate --format detailed > detailed-report.txt
smith validate --format json | jq '.' > structured-report.json
```

## Migration Questions

### How do I migrate from standalone tools?

See the comprehensive [Migration Guide](MIGRATION-GUIDE.md).

**Quick migration:**
```bash
# Old command
smith-validation ./MyApp --level critical

# New command (same options)
smith validate ./MyApp --level critical
```

### Can I use both old and new interfaces?

Yes, both interfaces work simultaneously during migration:
```bash
# Old interface (still works)
smith-validation ./MyApp

# New interface
smith validate ./MyApp

# Smart analysis (new feature)
smith smart-analyze
```

### When will standalone tools be deprecated?

Standalone tools will continue to work indefinitely. The new unified CLI is an enhancement, not a replacement.

## Performance Questions

### Why is validation slow on large projects?

**Solutions:**
1. **Use appropriate level**: `smith validate --level critical`
2. **Exclude unnecessary files**: `smith validate --exclude "Tests/**/*"`
3. **Parallel processing**: Smith automatically uses multiple cores
4. **Timeout settings**: `smith validate --timeout 300`

### How can I speed up TCA validation?

```bash
# Fast validation
smith validate --level critical --exclude "Tests/**/*"

# Parallel validation
smith validate --parallel

# Cache results
smith validate --use-cache
```

### What are the memory requirements?

- **Small projects** (< 50 files): ~100MB
- **Medium projects** (50-500 files): ~500MB
- **Large projects** (> 500 files): ~1-2GB

Smith Tools automatically manages memory usage and provides progress updates.

## Feature Questions

### Does Smith Tools support SwiftUI previews?

Currently, Smith Tools focuses on source code analysis rather than runtime behavior. SwiftUI preview analysis may be added in future versions.

### Can I create custom validation rules?

Yes, custom rules can be defined in configuration:

```json
{
  "validation": {
    "customRules": {
      "maxReducerActions": 30,
      "requireTestCoverage": true,
      "checkDependencyInjection": true
    }
  }
}
```

### Does it work with Swift Package Manager?

Yes, full SPM support:
```bash
smith spm analyze
smith spm dependencies --tree
smith spm analyze --circular --dependencies
```

### Can I integrate with Xcode?

Yes, multiple integration points:
- Build phase scripts
- Xcode project analysis
- Build log parsing
- Performance monitoring

See [IDE Integration](https://smith-tools.dev/docs/integration/) for details.

## Support & Getting Help

### How do I get help?

```bash
# General help
smith --help

# Command-specific help
smith validate --help
smith xcode --help

# Check system status
smith doctor
```

### Where can I report bugs?

- **GitHub Issues**: https://github.com/Smith-Tools/smith/issues
- **Discussions**: https://github.com/Smith-Tools/smith/discussions
- **Discord**: https://discord.gg/smith-tools

### How do I request features?

- **GitHub Discussions**: Feature requests and community discussion
- **GitHub Issues**: Specific feature requests with details
- **Discord**: Real-time community chat

### What information should I include in bug reports?

1. **System information**: `smith doctor`
2. **Command used**: Exact command and parameters
3. **Expected vs actual behavior**
4. **Minimal reproduction case**
5. **Error messages**: Full output including errors

### How do I enable debug logging?

```bash
# Enable verbose logging
export SMITH_VERBOSE=1
export SMITH_LOG_LEVEL=DEBUG

# Check log files
tail -f ~/Library/Logs/Smith/smith.log
```

## Advanced Questions

### How does smart project detection work?

Smith Tools analyzes project structure to determine the best tool:

1. **File inspection**: Looks for `.xcodeproj`, `Package.swift`, etc.
2. **Dependency analysis**: Examines build files and dependencies
3. **Tool recommendation**: Suggests best tool with confidence score
4. **Fallback handling**: Uses general analysis if specific type unclear

### Can I extend Smith Tools with plugins?

Plugin architecture is planned for future versions. Currently, you can:
- Create custom validation rules
- Add build phase scripts
- Integrate with external tools via shell scripts

### How does TCA architecture scoring work?

The health score (0-100) is calculated based on:
- **Redux anti-patterns**: -10 to -30 points each
- **Dependency injection**: +10 to +20 points
- **Test coverage**: +5 to +15 points
- **Performance patterns**: +5 to +10 points
- **Code organization**: +5 to +15 points

See [TCA Rules Documentation](https://smith-tools.dev/docs/tca-rules/) for detailed scoring.

### What data does Smith Tools collect?

**Privacy Policy:**
- **No personal data collection**
- **No usage analytics by default**
- **All processing done locally**
- **Optional anonymous telemetry** (can be disabled)

To disable telemetry:
```bash
smith config set telemetry.enabled false
```

This FAQ covers the most common questions. For more detailed information, see the full documentation at https://smith-tools.dev/docs/.