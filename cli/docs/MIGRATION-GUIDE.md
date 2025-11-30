# Smith Tools Migration Guide

This guide helps you migrate from standalone Smith tools to the unified CLI interface while maintaining backward compatibility.

## Overview

Smith Tools has evolved from separate standalone tools (`smith-validation`, `smith-xcsift`, etc.) to a unified CLI interface (`smith validate`, `smith xcode analyze`, etc.). This migration provides a better user experience while maintaining full backward compatibility.

## Migration Benefits

### Before (Standalone Tools)
```bash
# Different interfaces for each tool
smith-validation ./MyApp --level critical --format json
smith-xcsift analyze MyApp.xcodeproj --performance --json
smith-sbsift parse
smith-spmsift analyze --dependencies
smith-tca-trace trace ./MyFeature --json
```

### After (Unified CLI)
```bash
# Consistent interface
smith validate ./MyApp --level critical --format json
smith xcode analyze MyApp.xcodeproj --performance --json
smith swift parse
smith spm analyze --dependencies
smith tca trace ./MyFeature --json
```

### Key Improvements
- **Consistent Interface**: Git-style commands with predictable structure
- **Auto-detection**: Smart project analysis without needing to know tool names
- **Better Help**: Unified help system across all tools
- **Progress Indicators**: TTY-aware progress display
- **Error Handling**: Consistent error messages and recovery suggestions
- **Output Formatting**: Multiple output formats with automatic TTY detection

## Migration Paths

### Path 1: Gradual Migration (Recommended)

Keep using standalone tools while gradually adopting the unified CLI:

```bash
# Old way (still works)
smith-validation ./MyApp

# New way (gradually adopt)
smith validate ./MyApp

# Mix and match during transition
smith-validation ./MyApp --level critical
smith smart-analyze ./OtherProject
```

### Path 2: Immediate Migration

Switch all scripts to use the unified CLI immediately:

```bash
# Find all usages of standalone tools
grep -r "smith-validation\|smith-xcsift\|smith-sbsift\|smith-spmsift\|smith-tca-trace" .

# Replace with unified CLI equivalents
```

### Path 3: Parallel Installation

Install both versions during transition period:

```bash
# Standalone tools
brew install smith-validation smith-xcsift smith-sbsift smith-spmsift smith-tca-trace

# Unified CLI
brew tap smith-tools/smith
brew install smith-tools

# Use both interfaces
smith-validation ./MyApp    # Old interface
smith validate ./MyApp      # New interface
```

## Command Mapping

### Validation Tools

| Old Command | New Command | Notes |
|-------------|-------------|-------|
| `smith-validation [path]` | `smith validate [path]` | Direct replacement |
| `smith-validation --level critical` | `smith validate --level critical` | Same options |
| `smith-validation --format json` | `smith validate --format json` | Same options |
| `smith-validation --deep` | `smith validate --deep` | Same options |
| `smith-validation --config rules.json` | `smith validate --config rules.json` | Same options |

**Migration Example:**
```bash
# Old
smith-validation ./MyApp --level comprehensive --format json > validation.json

# New
smith validate ./MyApp --level comprehensive --format json > validation.json
```

### Xcode Analysis Tools

| Old Command | New Command | Notes |
|-------------|-------------|-------|
| `smith-xcsift analyze [path]` | `smith xcode analyze [path]` | Grouped under `xcode` |
| `smith-xcsift --json` | `smith xcode analyze --json` | Same options |
| `smith-xcsift --performance` | `smith xcode analyze --performance` | Same options |
| `smith-xcsift --dependencies` | `smith xcode analyze --dependencies` | Same options |

**Migration Example:**
```bash
# Old
smith-xcsift analyze MyApp.xcodeproj --performance --json

# New
smith xcode analyze MyApp.xcodeproj --performance --json
```

### Swift Build Tools

| Old Command | New Command | Notes |
|-------------|-------------|-------|
| `smith-sbsift analyze [path]` | `smith swift analyze [path]` | Grouped under `swift` |
| `smith-sbsift parse` | `smith swift parse` | Same behavior |
| `smith-sbsift --hang-detection` | `smith swift analyze --hang-detection` | Enhanced options |

**Migration Example:**
```bash
# Old
swift build | smith-sbsift parse --format json

# New
swift build | smith swift parse --format json
```

### Swift Package Manager Tools

| Old Command | New Command | Notes |
|-------------|-------------|-------|
| `smith-spmsift analyze [path]` | `smith spm analyze [path]` | Grouped under `spm` |
| `smith-spmsift dependencies [path]` | `smith spm dependencies [path]` | Same options |
| `smith-spmsift --json` | `smith spm analyze --json` | Same options |

**Migration Example:**
```bash
# Old
smith-spmsift analyze --dependencies --circular --json

# New
smith spm analyze --dependencies --circular --json
```

### TCA Tools

| Old Command | New Command | Notes |
|-------------|-------------|-------|
| `smith-tca-trace trace [path]` | `smith tca trace [path]` | Grouped under `tca` |
| `smith-tca-trace --json` | `smith tca trace --json` | Same options |
| `smith-tca-trace --memory` | `smith tca trace --memory` | Same options |

**Migration Example:**
```bash
# Old
smith-tca-trace trace ./MyFeature --memory --json --output trace.json

# New
smith tca trace ./MyFeature --memory --json --output trace.json
```

## Configuration Migration

### Environment Variables

| Old Variable | New Variable | Notes |
|--------------|-------------|-------|
| `SMITH_VALIDATION_LEVEL` | `SMITH_VALIDATION_LEVEL` | Same |
| `SMITH_VALIDATION_FORMAT` | `SMITH_FORMAT` | Consolidated |
| `SMITH_VERBOSE_MODE` | `SMITH_VERBOSE` | Same |
| `SMITH_NO_COLOR` | `SMITH_NO_COLOR` | Same |

**Migration:**
```bash
# Old
export SMITH_VALIDATION_LEVEL=critical
export SMITH_VALIDATION_FORMAT=json
export SMITH_VERBOSE_MODE=1

# New
export SMITH_VALIDATION_LEVEL=critical
export SMITH_FORMAT=json
export SMITH_VERBOSE=1
```

### Configuration Files

**Old Location:**
```bash
~/.smith-validation/config.json
~/.smith-xcsift/config.json
~/.smith-sbsift/config.json
~/.smith-spmsift/config.json
~/.smith-tca-trace/config.json
```

**New Location:**
```bash
~/.smith/config.json  # Unified configuration
```

**Configuration Migration:**
```bash
# Create unified config from old configs
mkdir -p ~/.smith
cat ~/.smith-validation/config.json ~/.smith-xcsift/config.json > ~/.smith/config.json

# Or use migration tool
smith config migrate
```

## Script Migration

### Shell Scripts

**Before:**
```bash
#!/bin/bash
# old-validation-script.sh

set -e

echo "Running TCA validation..."
smith-validation ./MyApp --level critical --format json > validation.json

echo "Checking for violations..."
VIOLATIONS=$(jq '.violations | length' validation.json)

if [ "$VIOLATIONS" -gt 0 ]; then
    echo "❌ Found $VIOLATIONS violations"
    jq '.violations[] | select(.severity == "critical")' validation.json
    exit 1
fi

echo "✅ Validation passed"
```

**After:**
```bash
#!/bin/bash
# new-validation-script.sh

set -e

echo "Running TCA validation..."
smith validate ./MyApp --level critical --format json > validation.json

echo "Checking for violations..."
VIOLATIONS=$(jq '.violations | length' validation.json)

if [ "$VIOLATIONS" -gt 0 ]; then
    echo "❌ Found $VIOLATIONS violations"
    jq '.violations[] | select(.severity == "critical")' validation.json
    exit 1
fi

echo "✅ Validation passed"
```

### Git Hooks

**Before (`.git/hooks/pre-commit`):**
```bash
#!/bin/sh
smith-validation --level critical --quiet || {
    echo "TCA validation failed"
    exit 1
}
```

**After (`.git/hooks/pre-commit`):**
```bash
#!/bin/sh
smith validate --level critical --quiet || {
    echo "TCA validation failed"
    exit 1
}
```

### CI/CD Pipelines

**Before (GitHub Actions):**
```yaml
- name: Validate TCA
  run: |
    smith-validation --level critical --format json > validation.json
    if [ $(jq '.violations | length' validation.json) -gt 0 ]; then
      exit 1
    fi
```

**After (GitHub Actions):**
```yaml
- name: Validate TCA
  run: |
    smith validate --level critical --format json > validation.json
    if [ $(jq '.violations | length' validation.json) -gt 0 ]; then
      exit 1
    fi
```

## Smart Detection Migration

### Automatic Tool Detection

The new CLI includes smart auto-detection that removes the need to know specific tool names:

**Before:**
```bash
# Need to know project type
smith-xcsift analyze MyApp.xcodeproj
smith-spmsift analyze MyPackage
smith-validation ./UnknownProject
```

**After:**
```bash
# Auto-detects project type
smith smart-analyze
smith validate ./UnknownProject
```

### Migration Helper

Use the migration helper to convert old commands:

```bash
# Interactive migration guide
smith migrate

# Batch convert old commands
smith migrate --batch --scripts=./scripts/

# Check which commands can be migrated
smith migrate --dry-run --verbose
```

## Common Migration Issues

### Issue 1: "Command not found" Error

**Problem:**
```bash
$ smith validate
zsh: command not found: smith
```

**Solution:**
```bash
# Install the unified CLI
brew tap smith-tools/smith
brew install smith-tools

# Or create a wrapper script
cat > /usr/local/bin/smith << 'EOF'
#!/bin/bash
# Unified Smith CLI wrapper
if [ "$1" == "validate" ]; then
    smith-validation "${@:2}"
elif [ "$1" == "xcode" ]; then
    smith-xcsift "${@:2}"
else
    echo "Unknown command: $1"
    exit 1
fi
EOF
chmod +x /usr/local/bin/smith
```

### Issue 2: Different Output Format

**Problem:** Old and new tools produce slightly different output formats.

**Solution:**
```bash
# Force JSON format for consistency
smith validate --format json | jq '.'

# Or use the compatibility mode
smith validate --legacy-format
```

### Issue 3: Missing Dependencies

**Problem:** Some tools may not be available in PATH.

**Solution:**
```bash
# Check tool availability
smith status

# Install missing tools
brew install smith-validation smith-xcsift smith-sbsift smith-spmsift smith-tca-trace

# Or set custom paths
smith config set tools.smithValidationPath /custom/path/smith-validation
```

### Issue 4: Configuration Compatibility

**Problem:** Old configuration files are not recognized.

**Solution:**
```bash
# Migrate old configuration
smith config migrate

# Or manually merge
smith config import --from ~/.smith-validation/config.json
```

## Rollback Strategy

If you need to rollback to standalone tools:

### Immediate Rollback
```bash
# Remove unified CLI
brew uninstall smith-tools

# Ensure standalone tools are installed
brew install smith-validation smith-xcsift smith-sbsift smith-spmsift smith-tca-trace

# Restore old scripts
git checkout HEAD~1 -- .git/hooks/pre-commit
```

### Gradual Rollback
```bash
# Keep both interfaces
# Use standalone tools in critical scripts
# Use unified CLI in new development
```

## Testing Migration

### Automated Migration Testing

```bash
# Test old commands still work
smith-validation --version
smith-xcsift --version
smith-sbsift --version

# Test new commands
smith --version
smith status

# Run equivalent tests
smith-validation ./TestProject --level critical
smith validate ./TestProject --level critical

# Compare outputs
smith-validation ./TestProject --format json > old-output.json
smith validate ./TestProject --format json > new-output.json
diff old-output.json new-output.json
```

### Manual Verification

```bash
# Test each command category
smith validate ./TestProject --level critical
smith xcode analyze ./TestProject --json
smith swift parse < <(swift build 2>&1)
smith spm analyze --dependencies
smith tca trace ./TestFeature --json

# Test with different formats
smith validate --format json
smith validate --format summary
smith validate --format auto
```

## Migration Timeline

### Phase 1: Preparation (Week 1)
- [ ] Backup existing scripts and configurations
- [ ] Install unified CLI alongside standalone tools
- [ ] Test basic functionality

### Phase 2: Gradual Migration (Weeks 2-3)
- [ ] Update non-critical scripts to use unified CLI
- [ ] Update documentation and development tools
- [ ] Train team on new interface

### Phase 3: Full Migration (Week 4)
- [ ] Update all production scripts
- [ ] Update CI/CD pipelines
- [ ] Update Git hooks
- [ ] Remove or deprecate standalone tool usage

### Phase 4: Optimization (Week 5)
- [ ] Optimize configurations
- [ ] Update custom integrations
- [ ] Remove backward compatibility wrappers
- [ ] Clean up old configurations

## Post-Migration

### Benefits Realization

After migration, you should see:
- **Improved Consistency**: Same interface for all tools
- **Better Discoverability**: `smith --help` shows all options
- **Enhanced Features**: Smart detection, progress indicators, better error messages
- **Future-Proof Architecture**: Easier to add new tools and features

### Optimization Opportunities

```bash
# Leverage new features
smith smart-analyze                    # Auto-detection
smith validate --format auto           # TTY-aware formatting
smith validate --level comprehensive   # Enhanced validation

# Use new capabilities
smith xcode parse --format detailed    # Rich output formats
smith tca compare baseline.json current.json  # New comparison feature
```

## Support

### Migration Assistance
- **Migration Helper**: `smith migrate --help`
- **Compatibility Check**: `smith doctor`
- **Configuration Validation**: `smith config validate`

### Getting Help
- **Migration Issues**: [GitHub Discussions](https://github.com/Smith-Tools/smith/discussions)
- **Bug Reports**: [GitHub Issues](https://github.com/Smith-Tools/smith/issues)
- **Documentation**: [Smith Tools Docs](https://smith-tools.dev/docs/)

The migration process is designed to be as smooth as possible while providing immediate benefits from the unified interface. Most users find that the new CLI is more intuitive and powerful while maintaining full compatibility with existing workflows.