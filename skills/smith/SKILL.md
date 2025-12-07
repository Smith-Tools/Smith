---
name: smith
description: Swift build analysis and architecture validation. Use for xcodebuild errors, swift build issues, dependency problems, circular dependencies, and general Swift project analysis. Automatically triggers when working with build diagnostics, Swift package structure, and project architecture questions. Does NOT cover Apple APIs (use sosumi) or TCA patterns (use maxwell) or third-party packages (use scully).
allowed-tools: Read, Glob, Grep, Bash
---

# Smith - Build Analysis and Architecture Validation

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

## Common Commands

```bash
# List project dependencies and structure
smith dependencies /path/to/project

# Analyze complete project architecture
smith analyze /path/to/project

# Validate TCA reducer architecture
smith validate --tca

# Get build diagnostics
smith diagnose
```

## What Smith Analyzes

- **Project Structure**: Targets, frameworks, dependencies
- **Build Issues**: Compilation errors, hanging builds, xcodebuild failures
- **Architecture**: Code organization, dependency ranking, circular dependencies
- **Swift Package Manager**: Package.swift manifests, dependency versions
- **Xcode Projects**: Workspaces, project files, build settings
