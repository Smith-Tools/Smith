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
  - "smith dependencies"
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

| Task | Smith CLI Command |
|------|-------------------|
| Project analysis | `smith dependencies /path/to/project` |
| Architecture validation | `smith validate --tca` |
| Comprehensive analysis | `smith analyze /path/to/project` |
| Build diagnostics | `smith diagnose` |

### Default Behavior Rules

1. **NEVER provide analysis without running smith** - always execute commands first
2. **NEVER assume results** - Smith tools must be invoked to get real data
3. **ALWAYS capture real output** - use smith CLI commands to get actual results
4. **ALWAYS report actual findings** - base statements on real command execution

### Examples

#### ✅ Correct Patterns

```bash
# Project structure analysis
smith dependencies /path/to/project

# Architecture validation
smith validate --tca

# Comprehensive project analysis
smith analyze /path/to/project

# Build diagnostics
smith diagnose
```

#### ❌ Anti-Patterns

```bash
# DON'T: Assume results without running commands
"Code appears healthy" (without running smith validate)

# DON'T: Fake analysis
"No issues detected" (without running smith commands)

# DON'T: Generic advice
"Try refactoring this" (without understanding actual project structure)
```

### Decision Tree

See [knowledge/TOOL-SELECTION-DECISION-TREE.md](knowledge/TOOL-SELECTION-DECISION-TREE.md) for comprehensive tool selection logic.
See [knowledge/BUILD-COMMAND-DEFAULTS.md](knowledge/BUILD-COMMAND-DEFAULTS.md) for command templates and scenarios.
