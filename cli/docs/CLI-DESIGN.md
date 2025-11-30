# Smith Tools CLI Design Principles

## Overview

This document outlines the design principles and guidelines used in the Smith Tools unified CLI interface. The design follows industry best practices from [Command Line Interface Guidelines (clig.dev)](https://clig.dev/) and modern CLI development patterns.

## Core Design Philosophy

### 1. Unified Interface with Tool Wrapping

The Smith CLI provides a **Git-style unified interface** while maintaining **backward compatibility** with existing standalone tools:

```bash
# New unified interface
smith validate ./MyApp
smith xcode analyze MyApp.xcodeproj
smith swift parse
smith spm analyze
smith tca trace ./MyFeature

# Legacy standalone tools still work
smith-validation ./MyApp
smith-xcsift analyze MyApp.xcodeproj
smith-sbsift parse
smith-spmsift analyze
smith-tca-trace trace ./MyFeature
```

**Rationale:**
- **User choice**: Users can choose their preferred interface
- **Backward compatibility**: Existing scripts and workflows continue to work
- **Gradual migration**: Users can adopt the unified interface at their own pace
- **Extensibility**: Third parties can add custom `smith-*` tools

### 2. Consistent Command Structure

All commands follow the **verb-noun pattern** with clear, descriptive names:

```bash
# Consistent structure: <verb> <noun> [options]
smith validate <path>              # TCA architectural validation
smith analyze <path>               # General project analysis
smith xcode parse                  # Xcode build output parsing
smith swift parse                  # Swift build output parsing
smith spm analyze                  # Swift Package Manager analysis
smith tca trace                    # TCA performance tracing
```

**Benefits:**
- **Predictable**: Users can guess command names
- **Discoverable**: `smith --help` shows clear organization
- **Composable**: Easy to chain tools in pipelines

### 3. Standard Flags Across All Commands

Consistent flags provide **familiarity** and **discoverability**:

#### Universal Flags
- `--help, -h`: Show help text
- `--version, -v`: Show version information
- `--quiet, -q`: Minimal output
- `--verbose`: Detailed output
- `--format <json|summary>`: Output format control
- `--no-color`: Disable ANSI colors
- `--dry-run, -n`: Preview changes without applying

#### Command-Specific Flags
- `--json`: Machine-readable JSON output
- `--deep`: Perform comprehensive analysis
- `--level <critical|standard|comprehensive>`: Analysis depth
- `--performance`: Include performance metrics
- `--dependencies`: Analyze dependency relationships

### 4. Human-First Error Handling

Errors provide **actionable guidance** with clear next steps:

```bash
# Bad error (old approach)
❌ Error: validation failed

# Good error (new approach)
❌ Error: TCA architecture validation failed

Found 3 violations in MyFeature.swift:
  • Line 42: Monolithic reducer (>40 actions)
  • Line 108: Hard-wired dependency
  • Line 156: Missing @Dependency

To fix:
  1. Split reducer into smaller features
  2. Use @Dependency injection
  3. See: https://smith-tools.dev/docs/tca-rules

Run with --help for more options
```

**Error Message Structure:**
1. **What happened**: Clear description of the error
2. **Where**: Specific file, line, and context
3. **Why**: Root cause explanation
4. **How to fix**: Actionable steps
5. **Where to learn more**: Documentation links
6. **Next steps**: How to get help

### 5. Graceful Dependency Handling

Tools **degrade gracefully** when dependencies are missing:

```bash
# Level 1: Tool completely missing (fatal)
❌ ERROR: swift not found

Smith requires Swift 5.9 or later to function.

To install:
  • macOS: Install Xcode Command Line Tools
    xcode-select --install
  • Linux: Download from https://swift.org/download/

Verify installation: swift --version

# Level 2: Tool missing (non-fatal)
⚠️  WARNING: xcodebuild not found

Xcode-specific features are unavailable:
  • Workspace analysis
  • Build log parsing
  • DerivedData diagnostics

Continuing with Swift Package analysis only...

# Level 3: Tool version mismatch (warning)
⚠️  WARNING: xcodebuild 14.0 detected (recommended: 15.0+)

Some features may not work correctly.
Consider upgrading Xcode for best results.
```

**Progressive Disclosure Strategy:**
- **Fatal errors**: Required tools for basic functionality
- **Warnings**: Optional tools for enhanced features
- **Information**: Version mismatches that don't break functionality

### 6. TTY-Aware Output

Output format **automatically adapts** to context:

#### Human-Readable (TTY - Interactive Terminal)
```bash
smith validate ./MyApp

Analyzing project...
✓ Found 12 Swift files
✓ Detected TCA architecture

Violations (3 found):

  MyFeature.swift:42
    ✗ Monolithic reducer (48 actions, limit: 40)
    Rule: 1.1 - Keep features focused

  MyFeature.swift:108
    ✗ Hard-wired dependency
    Rule: 1.2 - Use @Dependency injection

Summary: 3 critical, 0 warnings
```

#### Machine-Readable (Pipe/Redirection)
```bash
smith validate ./MyApp --format json | jq '.violations[] | select(.severity == "critical")'
{
  "file": "MyFeature.swift",
  "line": 42,
  "severity": "critical",
  "message": "Monolithic reducer",
  "rule": "1.1"
}
```

**Smart Detection Logic:**
```swift
struct OutputFormatter {
    let isTTY: Bool
    let format: OutputFormat

    init() {
        self.isTTY = isatty(STDOUT_FILENO) != 0
        self.format = isTTY ? .human : .json
    }

    func format<T: Encodable>(_ result: T) -> String {
        switch format {
        case .json:
            return try! JSONEncoder().encode(result).asString()
        case .human:
            return result.prettyPrint()
        }
    }
}
```

### 7. Progress Indicators for Long Operations

For operations exceeding 100ms, show **meaningful progress**:

```bash
smith validate ./LargeProject --deep

Analyzing project... ⠋
  ✓ Found 234 Swift files (0.2s)
  ✓ Parsed syntax trees (1.4s)
  ⠙ Running validation rules... (12/45)
  ✓ Analyzed dependency graph (3.1s)
  ⠸ Generating report... (43/45)

Validation completed successfully (4.2s)
```

**Progress Design Principles:**
- **Meaningful milestones**: Not just percentage, but actual work units
- **Time estimates**: Help users understand duration
- **Non-intrusive**: Can be disabled with `--quiet`
- **Structured data**: Progress events are machine-parsable

## Implementation Patterns

### 1. Tool Delegation Pattern

```swift
struct Validation: ParsableCommand {
    func run() throws {
        // Pre-flight checks
        let requirements = checkRequirements()
        showRequirementsReport(requirements)
        
        // Delegate to actual tool
        if let toolPath = findSmithValidationPath() {
            let result = executeSmithValidation(path: toolPath, arguments: buildArguments())
            processResult(result)
        } else {
            // Fallback behavior
            performBasicValidation()
        }
    }
}
```

### 2. Smart Auto-Detection

```swift
struct SmartAnalyze: ParsableCommand {
    func run() throws {
        // Auto-detect project type
        let projectType = ProjectDetector.detectProjectType(at: path)
        
        // Determine best tool
        let recommendedTool = determineBestTool(for: projectType)
        
        // Execute with recommended tool
        let result = executeAnalysis(with: recommendedTool)
        
        // Present results with context
        presentResults(result, context: projectType)
    }
}
```

### 3. Dependency Checking Pattern

```swift
protocol ToolRequirement {
    var toolName: String { get }
    var isFatal: Bool { get }
    func check() -> Bool
    func installationHelp() -> String
}

struct RequirementChecker {
    static func check(_ requirements: [ToolRequirement]) -> (fatal: [ToolRequirement], warnings: [ToolRequirement]) {
        // Implementation that filters missing tools
    }
}
```

## Command Organization

### Primary Commands (Git-style)
```bash
smith <verb> <noun> [options]
```

**Available verbs:**
- `validate` - Architecture and dependency validation
- `analyze` - General project analysis  
- `parse` - Build output parsing
- `trace` - Performance tracing and profiling
- `monitor` - Real-time build monitoring
- `compare` - Between different states/snapshots

### Specialized Command Groups
```bash
smith <group> <command> [options]
```

**Command groups:**
- `smith xcode` - Xcode-specific tools
- `smith swift` - Swift build tools
- `smith spm` - Swift Package Manager tools
- `smith tca` - The Composable Architecture tools

### Legacy Compatibility
```bash
smith-<toolname> [options]  # Original standalone tools still work
```

## Success Metrics

After implementation, the unified CLI should achieve:

- [ ] `smith --help` shows clear, organized command structure
- [ ] All subcommands follow consistent patterns
- [ ] Error messages include actionable guidance
- [ ] Tools gracefully degrade when dependencies are missing
- [ ] Output is TTY-aware (human-readable in terminal, JSON in pipes)
- [ ] Progress indicators for operations >100ms
- [ ] Comprehensive documentation with examples
- [ ] Individual tools still work standalone
- [ ] Swift packages have documented public APIs

## References

- [Command Line Interface Guidelines (clig.dev)](https://clig.dev/) - Primary design reference
- [12 Factor CLI Apps](https://12factor.net/config) - Configuration best practices
- [Atlassian: 10 Design Principles for CLIs](https://blog.developer.atlassian.com/10-design-principles-for-delightful-clis/)
- [Git's extensibility model](https://git.github.io/htmldocs/howto/new-command.html)
- [Swift ArgumentParser documentation](https://github.com/apple/swift-argument-parser)

## Future Enhancements

### Phase 2: Enhanced Error Handling
- Structured error codes with documentation links
- Recovery suggestions based on error patterns
- Integration with external documentation systems

### Phase 3: Advanced Output Formatting
- Custom output templates
- Interactive progress bars
- Real-time streaming for long operations

### Phase 4: Plugin System
- Third-party tool integration
- Custom command registration
- Distributed analysis workflows

### Phase 5: AI Integration
- Natural language query support
- Automated fix suggestions
- Intelligent issue prioritization