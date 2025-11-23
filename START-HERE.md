# Smith - Swift Architecture Enforcement System

Welcome to Smith, the **construction police** for Swift development. This guide helps you get started.

## What is Smith?

Smith is the **enforcement agent** in the Smith Tools ecosystem. It operates throughout your entire development lifecycle:

- **During Build**: Real-time monitoring with `smith-sbsift`, `smith-spmsift`, `smith-xcsift`
- **During Code Review**: Architectural validation with TCA Rules 1.1-1.5
- **For Recovery**: Smart rebuild strategies and diagnostic analysis

Smith's philosophy: **strict analysis of the construction process, not just checking final output**.

---

## Quick Start: 3 Ways to Use Smith

### 1. **Use Smith Skill in Claude Code** (Recommended)
For architectural validation while coding:
```
"Use smith-skill for my TCA code"
"Check if my reducer violates TCA composition rules"
```

The skill auto-triggers on:
- TCA patterns (`@Reducer`, `CombineReducers`, `Reducer`)
- Architecture keywords (`monolithic`, `coupling`, `testability`)
- Swift patterns (`@State`, `async/await`, dependency injection)

### 2. **Use Smith CLI for Automated Analysis**
```bash
smith analyze /path/to/project
smith validate --tca
smith optimize
```

### 3. **Use Diagnostic Tools During Build**
```bash
swift build 2>&1 | smith-sbsift analyze --hang-detection
smith-spmsift show-dependencies
smith-xcsift rebuild --smart-strategy
```

---

## Directory Guide

| Directory | Purpose | Use When |
|-----------|---------|----------|
| `skills/` | Claude Code skill definition | You need architectural guidance |
| `cli/` | Command-line tool source | Building from source |
| `validation/` | TCA validation rules | Extending validation rules |
| `scripts/` | Build analysis shell scripts | Diagnosing build issues |
| `agent/` | Smith orchestrator agent | Understanding Smith architecture |

---

## Core Concepts

### Smith's Three Phases

1. **Build Phase**: Real-time monitoring
   - `smith-sbsift` - Swift build output analysis
   - `smith-spmsift` - SPM dependency analysis
   - `smith-xcsift` - Xcode project analysis

2. **Code Review Phase**: Static architecture validation
   - `smith-validation` - TCA rules and patterns
   - `smith-skill` - Claude Code integration

3. **Recovery Phase**: Intelligent rebuild strategies
   - `smith-xcsift rebuild` - Smart recovery
   - Hang detection and diagnostics

### TCA Rules (Rules 1.1-1.5)

Smith enforces strict TCA composition rules:
- **1.1**: Monolithic features (State > 15 props, Actions > 40 cases)
- **1.2**: Proper dependency injection
- **1.3**: Code duplication detection
- **1.4**: Unclear organization
- **1.5**: Tightly coupled state

---

## Installation

### From Source
```bash
cd Smith
make install
```

### Using Homebrew
```bash
brew install smith
```

This installs:
- `smith` - CLI tool
- `smith-sbsift` - Swift build analyzer
- `smith-spmsift` - SPM analyzer
- `smith-xcsift` - Xcode analyzer
- Smith Claude Code skill

---

## Common Tasks

### Check Architecture of Your Project
```bash
smith analyze --level critical
smith validate --tca
```

### Diagnose Build Hangs
```bash
swift build 2>&1 | smith-sbsift analyze --hang-detection
smith-xcsift diagnose
```

### Debug Package Dependencies
```bash
smith-spmsift show-dependencies --format json
```

### Get Smart Rebuild Strategy
```bash
smith-xcsift rebuild --smart-strategy
```

---

## Documentation

| Document | Read This For |
|----------|---------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Design and philosophy |
| [agent/smith.md](agent/smith.md) | Smith orchestrator agent |
| [skills/skill-smith/skill/SKILL.md](skills/skill-smith/skill/SKILL.md) | Claude Code skill reference |
| [skills/skill-smith/patterns/AGENTS-AGNOSTIC.md](skills/skill-smith/patterns/AGENTS-AGNOSTIC.md) | Swift universal patterns |
| [skills/skill-smith/patterns/AGENTS-DECISION-TREES.md](skills/skill-smith/patterns/AGENTS-DECISION-TREES.md) | Architectural decisions |

---

## Integration with Maxwell

Smith and Maxwell work together:

- **Maxwell** (Oracle): "How should I write this code?"
  - Provides patterns and examples
  - Guides implementation

- **Smith** (Enforcement): "Is this code correct?"
  - Validates against strict rules
  - Detects anti-patterns

**Workflow**:
```
Maxwell teaches pattern → You implement → Smith validates
```

---

## Get Help

### For TCA Questions
Ask about `@Reducer`, `@ObservableState`, `@Shared`, `Reducer` composition

### For Build Issues
Use `smith-sbsift analyze --hang-detection` or `smith-xcsift diagnose`

### For Architectural Validation
Use `smith validate --tca` or invoke Smith skill in Claude Code

---

## Next Steps

1. **Read [ARCHITECTURE.md](ARCHITECTURE.md)** - Understand Smith's design
2. **Try smith** - `smith analyze /path/to/project`
3. **Use Smith Skill** - Ask about your code architecture
4. **Check Your Builds** - Pipe builds through `smith-sbsift`

---

**Smith: Because code quality matters. Because builds should never hang. Because architecture is discipline.**
