# Smith Tools CLI Error Codes Reference

This document provides a comprehensive reference for all error codes, their meanings, and suggested solutions.

## Error Code Format

Error codes follow the pattern: `SMITH_<CATEGORY>_<NUMBER>`

- **SMITH**: Prefix identifying Smith Tools
- **CATEGORY**: Error category (VAL, CLI, TOOL, SYS, NET)
- **NUMBER**: Three-digit error number

## Exit Codes

Smith Tools CLI uses standard exit codes:

| Code | Name | Description |
|------|------|-------------|
| 0 | SUCCESS | Operation completed successfully |
| 1 | GENERAL_ERROR | Generic error occurred |
| 2 | INVALID_ARGUMENTS | Invalid command-line arguments |
| 3 | TOOL_NOT_FOUND | Required tool not found |
| 4 | VALIDATION_FAILED | Validation failed |
| 5 | TIMEOUT | Operation timed out |
| 126 | CANNOT_EXECUTE | Command cannot be executed |
| 127 | COMMAND_NOT_FOUND | Command not found |
| 128 | INVALID_EXIT_CODE | Invalid exit code argument |

## Error Categories

### CLI Errors (SMITH_CLI_XXX)

#### SMITH_CLI_001 - Invalid Command
**Message:** "Invalid command: {command}"

**Description:** The specified command is not recognized.

**Solution:**
```bash
# Check available commands
smith --help

# Use correct command syntax
smith validate ./MyApp
```

#### SMITH_CLI_002 - Invalid Arguments
**Message:** "Invalid arguments: {details}"

**Description:** Command-line arguments are malformed or invalid.

**Solution:**
```bash
# Check command syntax
smith <command> --help

# Ensure paths exist and are accessible
ls -la ./MyApp
```

#### SMITH_CLI_003 - Missing Required Argument
**Message:** "Missing required argument: {argument}"

**Description:** A required command argument was not provided.

**Solution:**
```bash
# Provide the missing argument
smith validate ./MyApp

# Check which arguments are required
smith validate --help
```

#### SMITH_CLI_004 - Invalid Option Value
**Message:** "Invalid value for option {option}: {value}"

**Description:** The provided value for an option is not valid.

**Solution:**
```bash
# Use valid option values
smith validate --level critical    # Valid: critical, standard, comprehensive
smith validate --format json       # Valid: json, summary

# Check allowed values
smith validate --help
```

### Validation Errors (SMITH_VAL_XXX)

#### SMITH_VAL_001 - TCA Architecture Violation
**Message:** "TCA architecture violation: {description}"

**Description:** The code violates TCA (The Composable Architecture) principles.

**Common Violations:**
- Monolithic reducers (>40 actions)
- Missing @Dependency injection
- Hard-wired dependencies
- Improper state management

**Solution:**
```bash
# Get detailed violation information
smith validate --level comprehensive --format json

# Review TCA best practices
# https://smith-tools.dev/docs/tca-rules

# Fix specific issues:
# 1. Split large reducers into smaller features
# 2. Use @Dependency injection for external dependencies
# 3. Avoid hard-coding dependencies
# 4. Follow TCA state management patterns
```

**Example Fix:**
```swift
// Before: Monolithic reducer
struct AppReducer {
    var body: some ReducerProtocol {
        Reduce { state, action in
            switch action {
            case .userProfileAction(let action):
                return .run { ... } // 40+ actions in one reducer
            // ... 39 more action cases
            }
        }
    }
}

// After: Modularized reducers
struct UserProfileReducer: ReducerProtocol {
    struct State { ... }
    enum Action { ... }
    
    var body: some ReducerProtocol {
        Reduce { state, action in
            switch action {
            // Only user profile actions
            }
        }
    }
}
```

#### SMITH_VAL_002 - Dependency Injection Missing
**Message:** "Missing @Dependency injection: {details}"

**Description:** External dependencies should be injected using @Dependency.

**Solution:**
```swift
// Before: Hard-wired dependency
class MyService {
    private let apiClient = APIClient()
}

// After: Dependency injection
import Dependencies

struct MyFeature: ReducerProtocol {
    @Dependency var apiClient: APIClient
    
    // Use injected dependency
}
```

#### SMITH_VAL_003 - Circular Dependency Detected
**Message:** "Circular dependency detected: {dependency-chain}"

**Description:** Circular dependencies found in the dependency graph.

**Solution:**
```bash
# Identify circular dependencies
smith spm analyze --circular --dependencies --format json

# Break the cycle by:
# 1. Moving common code to a shared module
# 2. Inverting dependencies
# 3. Using protocols to break tight coupling
```

#### SMITH_VAL_004 - Performance Issue Detected
**Message:** "Performance issue: {description}"

**Description:** Code patterns that may cause performance problems.

**Common Issues:**
- Large view hierarchies
- Expensive operations in reducers
- Memory leaks
- Inefficient algorithms

**Solution:**
```bash
# Analyze performance impact
smith tca trace --memory --complexity

# Address specific performance issues:
# 1. Optimize view hierarchies
# 2. Move expensive operations to effects
# 3. Fix memory leaks
# 4. Use more efficient algorithms
```

### Tool Errors (SMITH_TOOL_XXX)

#### SMITH_TOOL_001 - Smith Tool Not Found
**Message:** "{tool-name} not found"

**Description:** The required Smith tool is not installed or not in PATH.

**Solution:**
```bash
# Check available tools
smith status

# Install missing tools
brew install smith-validation
brew install smith-xcsift
brew install smith-sbsift
brew install smith-spmsift
brew install smith-tca-trace

# Or install manually
curl -L https://github.com/smith-tools/{tool}/releases/latest | \
  tar -xz && sudo mv {tool} /usr/local/bin/
```

#### SMITH_TOOL_002 - Tool Version Mismatch
**Message:** "{tool-name} version {current} incompatible (required: {required})"

**Description:** The installed tool version is not compatible.

**Solution:**
```bash
# Update to compatible version
brew upgrade {tool}

# Or install specific version
brew install {tool}@<version>

# Check version requirements
smith --version
```

#### SMITH_TOOL_003 - Tool Execution Failed
**Message:** "Failed to execute {tool-name}: {error}"

**Description:** The tool failed to execute properly.

**Solution:**
```bash
# Check tool permissions
chmod +x $(which {tool})

# Verify tool integrity
{tool} --version

# Check dependencies
smith status --verbose

# Run with verbose output for debugging
smith {command} --verbose
```

### System Errors (SMITH_SYS_XXX)

#### SMITH_SYS_001 - Permission Denied
**Message:** "Permission denied: {path}"

**Description:** Insufficient permissions to access the specified path.

**Solution:**
```bash
# Check current permissions
ls -la {path}

# Fix permissions
chmod 755 {path}
chown $USER {path}

# Run with appropriate privileges (if necessary)
sudo smith {command}
```

#### SMITH_SYS_002 - Disk Space Insufficient
**Message:** "Insufficient disk space: {path}"

**Description:** Not enough disk space to complete the operation.

**Solution:**
```bash
# Check disk usage
df -h {path}

# Free up disk space
# - Clean build artifacts
# - Remove temporary files
# - Clear derived data

# Clean Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean Swift build cache
swift build --clean
```

#### SMITH_SYS_003 - Memory Insufficient
**Message:** "Insufficient memory: {operation}"

**Description:** Not enough memory to complete the operation.

**Solution:**
```bash
# Monitor memory usage
smith analyze --verbose

# Close unnecessary applications
# Increase virtual memory
# Use --memory-threshold option to limit memory usage
smith {command} --memory-threshold 2.0
```

#### SMITH_SYS_004 - Network Unavailable
**Message:** "Network unavailable: {operation}"

**Description:** Network connection required but not available.

**Solution:**
```bash
# Check network connectivity
ping google.com

# For offline analysis, use --offline flag
smith {command} --offline

# Some operations require network access:
# - Dependency resolution
# - Tool updates
# - Remote analysis
```

### Build Errors (SMITH_BUILD_XXX)

#### SMITH_BUILD_001 - Compilation Failed
**Message:** "Compilation failed: {details}"

**Description:** Swift compilation errors detected during analysis.

**Solution:**
```bash
# Fix compilation errors
# 1. Check syntax errors
# 2. Resolve type mismatches
# 3. Fix missing imports
# 4. Address access control issues

# Run compiler directly to see detailed errors
swift build --verbose

# Then parse the output
swift build 2>&1 | smith swift parse --format detailed
```

#### SMITH_BUILD_002 - Build Timeout
**Message:** "Build timeout: {duration}s"

**Description:** Build operation exceeded the specified timeout.

**Solution:**
```bash
# Increase timeout
smith {command} --timeout 600  # 10 minutes

# Optimize build configuration
smith optimize --apply

# Use incremental builds
smith xcode rebuild --incremental
```

#### SMITH_BUILD_003 - Invalid Build Configuration
**Message:** "Invalid build configuration: {details}"

**Description:** Project build configuration has issues.

**Solution:**
```bash
# Validate build configuration
smith xcode analyze --configuration

# Fix common issues:
# 1. Invalid scheme names
# 2. Missing target configurations
# 3. Broken build settings
# 4. Missing provisioning profiles

# Regenerate project files
swift package generate-xcodeproj
```

### File System Errors (SMITH_FS_XXX)

#### SMITH_FS_001 - File Not Found
**Message:** "File not found: {path}"

**Description:** The specified file or directory does not exist.

**Solution:**
```bash
# Verify file exists
ls -la {path}

# Use correct path
smith validate ./Correct/Path/To/Project

# Find project files
find . -name "Package.swift" -o -name "*.xcodeproj" -o -name "*.xcworkspace"
```

#### SMITH_FS_002 - Invalid File Format
**Message:** "Invalid file format: {path}"

**Description:** The file format is not supported or is corrupted.

**Solution:**
```bash
# Check file format
file {path}

# Verify file integrity
# - Re-download if from remote source
# - Regenerate if auto-generated
# - Restore from backup if corrupted

# For Package.swift files
swift package describe --type json
```

#### SMITH_FS_003 - Read-Only File System
**Message:** "Read-only file system: {path}"

**Description:** Cannot write to the specified location.

**Solution:**
```bash
# Use a writable location
smith {command} --output /tmp/smith-output.json

# Check mount status
mount | grep {path}

# Remount as read-write (if possible)
sudo mount -o remount,rw {path}
```

### Network Errors (SMITH_NET_XXX)

#### SMITH_NET_001 - Connection Timeout
**Message:** "Connection timeout: {url}"

**Description:** Network connection to remote service timed out.

**Solution:**
```bash
# Check network connectivity
curl -I {url}

# Increase timeout
smith {command} --timeout 60

# Use offline mode if possible
smith {command} --offline
```

#### SMITH_NET_002 - Authentication Failed
**Message:** "Authentication failed: {service}"

**Description:** Failed to authenticate with remote service.

**Solution:**
```bash
# Check credentials
# - API tokens
# - Certificates
# - SSH keys

# For GitHub/GitLab integration
git remote -v
smith {command} --credentials-file ~/.smith/credentials
```

### Performance Errors (SMITH_PERF_XXX)

#### SMITH_PERF_001 - Memory Limit Exceeded
**Message:** "Memory limit exceeded: {usage}MB (limit: {limit}MB)"

**Description:** Operation exceeded memory usage limit.

**Solution:**
```bash
# Reduce memory threshold
smith {command} --memory-threshold 1.0

# Process in smaller chunks
smith {command} --chunk-size 100

# Close other applications
# Monitor memory usage
smith analyze --memory-threshold 2.0
```

#### SMITH_PERF_002 - CPU Usage High
**Message:** "High CPU usage detected: {usage}% (threshold: {threshold}%)"

**Description:** Operation using excessive CPU resources.

**Solution:**
```bash
# Reduce CPU threshold
smith {command} --cpu-threshold 90

# Use lighter analysis
smith {command} --level critical

# Monitor system load
smith analyze --hang-detection --cpu-threshold 80
```

## Error Recovery Strategies

### Automatic Retry

Many operations automatically retry with exponential backoff:

```bash
# Configure retry behavior
export SMITH_MAX_RETRIES=3
export SMITH_RETRY_DELAY=5

smith {command}  # Will retry up to 3 times with 5s delay
```

### Graceful Degradation

When optional tools are missing, Smith CLI degrades gracefully:

```bash
# smith-xcsift not available
⚠️  Xcode analysis limited - smith-xcsift not found
📊 Basic analysis completed with available tools
```

### Fallback Analysis

When advanced tools fail, basic analysis is still performed:

```bash
# smith-tca-trace fails
📊 Using basic TCA analysis instead of full trace
✅ Basic analysis completed
💡 Install smith-tca-trace for detailed performance analysis
```

## Debug Mode

### Verbose Output

```bash
# Enable verbose logging
smith {command} --verbose

# Set log level
export SMITH_LOG_LEVEL=DEBUG
smith {command}

# Log to file
smith {command} --log-file smith-debug.log
```

### Debug Information

```bash
# Show debug information
smith --debug-info

# Environment details
smith status --verbose

# System information
smith environment --detailed
```

## Error Reporting

### Submit Bug Reports

When encountering errors, collect the following information:

```bash
# 1. Error details
smith {command} --verbose > error-report.txt 2>&1

# 2. System information
smith status --verbose >> error-report.txt

# 3. Project information
smith detect --verbose >> error-report.txt

# 4. Log files (if available)
cp ~/Library/Logs/Smith/*.log error-report.txt 2>/dev/null || true
```

### Integration with External Tools

#### Sentry Integration
```bash
# Configure Sentry DSN
export SMITH_SENTRY_DSN="https://..."
smith {command}  # Errors automatically reported
```

#### Custom Error Handlers
```bash
# Use error hooks
export SMITH_ERROR_HOOK="/usr/local/bin/smith-error-handler"
smith {command}  # Custom handler called on errors
```

## Error Prevention

### Pre-flight Checks

```bash
# Run before important operations
smith status  # Check system health
smith detect  # Validate project structure
smith validate --level critical  # Quick validation
```

### Configuration Validation

```bash
# Validate configuration
smith config --validate

# Check tool compatibility
smith status --compatibility-check
```

### Health Monitoring

```bash
# Regular health checks
crontab -e
# Add: 0 9 * * 1 smith smart-analyze --quiet && smith status --health-report
```

## Error Code Quick Reference

| Code | Category | Description | Quick Fix |
|------|----------|-------------|-----------|
| 0 | SUCCESS | Operation successful | None needed |
| 1 | GENERAL | Generic error | Check verbose output |
| 2 | CLI | Invalid arguments | Use `--help` |
| 3 | TOOL | Tool not found | Install via Homebrew |
| 4 | VAL | Validation failed | Review TCA rules |
| 5 | TIMEOUT | Operation timed out | Increase timeout |
| SMITH_VAL_001 | VAL | TCA violation | See TCA rules |
| SMITH_TOOL_001 | TOOL | Tool missing | `brew install` |
| SMITH_SYS_001 | SYS | Permission denied | Fix permissions |
| SMITH_BUILD_001 | BUILD | Compile failed | Fix code errors |

For the most up-to-date error codes and solutions, visit:
https://smith-tools.dev/docs/error-codes