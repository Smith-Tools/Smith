---
name: smith
description: Swift build analysis and architecture validation. Use for xcodebuild errors, swift build issues, dependency problems, circular dependencies, and general Swift project analysis. Automatically triggers when working with build diagnostics, Swift package structure, and project architecture questions. Does NOT cover Apple APIs (use sosumi) or TCA patterns (use maxwell) or third-party packages (use scully).
allowed-tools: Read, Glob, Grep, Bash
---

# Smith - Build Analysis and Architecture Validation

**Reference**: 
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- `/Volumes/Plutonian/_Developer/Smith-Tools/ARCHITECTURE.md` (canonical architecture)

**Swift Version**: 6.2+ required (strict concurrency)

## When to Use Smith

✅ **Use Smith for:**
- Build diagnostics: `smith analyze /path/to/project`
- Dependency analysis: `smith dependencies /path/to/project`
- Architecture validation: `smith validate --tca`
- Circular dependency detection
- Swift build issues and xcodebuild errors
- Project structure analysis

❌ **When NOT to use Smith:**
- Apple API questions → Use **sosumi** instead
- TCA pattern guidance → Use **maxwell** instead
- Third-party package documentation → Use **scully** instead

## Smith's Four Operational Phases

### Phase 1: Package Setup
Analyze dependencies and package manifest:
```bash
smith dependencies /path/to/project --metrics
swift package dump-package | smith dependencies --format json
```

### Phase 2: Build Monitoring
Real-time monitoring with hang detection:
```bash
swift build 2>&1 | smith parse --format json
smith xcode monitor --hang-detection
```

### Phase 3: Code Review
AI-optimized architectural validation:
```bash
# Multi-level validation (critical, standard, comprehensive)
smith validate /path/to/project --level=critical --format=json
smith validate /path/to/project --level=standard --format=summary
smith validate /path/to/project --level=comprehensive --format=json
```

### Phase 4: Build Recovery
Smart rebuild strategies and diagnostics:
```bash
smith xcode diagnose --detailed
smith xcode rebuild --smart-strategy
```

## Common Commands

```bash
# Comprehensive project analysis
smith analyze /path/to/project

# List dependencies and structure
smith dependencies /path/to/project --metrics

# Validate TCA architecture (multi-level)
smith validate /path/to/project --level=critical
smith validate /path/to/project --level=standard
smith validate /path/to/project --level=comprehensive

# Monitor builds
swift build 2>&1 | smith parse --format json
smith xcode monitor --hang-detection

# Diagnostics and recovery
smith xcode diagnose --detailed
smith xcode rebuild --smart-strategy
smith detect  # Project type detection
smith status  # Build status
```

## TCA Validation Rules (1.1-1.5)

Smith validates strict TCA architectural rules:

| Rule | Validates | Threshold |
|------|-----------|-----------|
| **1.1** | Monolithic features | State >15 props, Actions >40 cases |
| **1.2** | Dependency injection | Proper container setup |
| **1.3** | Code duplication | Repeated patterns |
| **1.4** | Unclear organization | Module boundaries, naming |
| **1.5** | Tightly coupled state | State dependencies |

## What Smith Analyzes

- **Project Structure**: Targets, frameworks, dependencies, build settings
- **Build Issues**: Compilation errors, hanging builds, type inference explosions
- **Architecture**: Code organization, dependency ranking, circular dependencies
- **Swift Package Manager**: Package.swift manifests, dependency versions, conflicts
- **Xcode Projects**: Workspaces, project files, schemes
- **Code Quality**: Deprecated patterns, anti-patterns, testability
- **Documentation**: Documentation gaps and coverage
- **Build Health**: Memory pressure, DerivedData issues, type inference
