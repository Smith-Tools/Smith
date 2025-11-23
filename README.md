# Smith - Swift Architecture Enforcement System

The **construction police** for Swift development. Smith enforces architectural discipline and build health throughout your entire development lifecycle.

## What is Smith?

Smith is the enforcement agent in the Smith Tools ecosystem. It's not permissive. It's not flexible about rules. It validates code against strict architectural standards and ensures build quality.

**Smith's Philosophy**: Code quality isn't negotiable. Builds shouldn't hang. Architecture is discipline.

---

## Quick Start

### Installation (30 seconds)

```bash
cd /Volumes/Plutonian/_Developer/Smith\ Tools/Smith
./install.sh
```

This installs:
- ✅ Smith CLI (`smith`)
- ✅ Smith Claude Code skill
- ✅ Integration with build tools

### First Use

```bash
# Analyze your project
smith analyze /path/to/project

# Validate TCA architecture
smith validate --tca

# Use in Claude Code
# Type: "@smith validate my code"
```

---

## Three Ways to Use Smith

### 1. Claude Code Skill (Recommended)

Interactive architectural guidance in Claude Code:

```
"@smith check my TCA reducer"
"Validate my code against Smith rules"
"Smith, diagnose my build issue"
```

### 2. Command Line Tool

For automation and CI/CD:

```bash
smith analyze /path/to/project
smith validate --tca
smith optimize
```

### 3. Build Integration

Real-time monitoring during builds:

```bash
# Swift builds
swift build 2>&1 | smith-sbsift analyze --hang-detection

# Xcode builds
smith-xcsift rebuild --smart-strategy
```

---

## What Smith Validates

### TCA Rules (Rules 1.1-1.5)

Smith enforces strict rules for The Composable Architecture:

| Rule | Validates |
|------|-----------|
| **1.1** | Monolithic features (State >15 props, Actions >40 cases) |
| **1.2** | Proper dependency injection |
| **1.3** | Code duplication |
| **1.4** | Unclear organization |
| **1.5** | Tightly coupled state |

### Build Health

Smith monitors your build for:
- Build hangs with root cause analysis
- Type inference explosions
- Dependency conflicts
- DerivedData issues
- Memory pressure problems

### Code Quality

Smith detects:
- Deprecated patterns (`.@State` in reducers, `WithViewStore`)
- Anti-patterns (hard-wired dependencies, circular imports)
- Testability issues
- Documentation gaps

---

## Directory Structure

```
Smith/
├── README.md                    ← You are here
├── START-HERE.md               ← Quick start guide
├── ARCHITECTURE.md             ← Design philosophy
├── Makefile                    ← Build orchestration
├── install.sh                  ← Installation script
│
├── agent/
│   └── smith.md               ← Agent definition
│
├── skills/
│   └── skill-smith/           ← Claude Code skill
│       ├── skill/SKILL.md
│       ├── patterns/          ← Swift patterns
│       └── platforms/         ← Platform guides
│
├── cli/                        ← Smith CLI source
│   ├── Package.swift
│   └── Sources/
│
├── validation/                 ← Validation rules
│   ├── Package.swift
│   └── Sources/
│
├── scripts/                    ← Analysis scripts
│   ├── smith-smart-builder.sh
│   └── validate-syntax.sh
│
└── resources/
    └── trigger-phrases.txt
```

---

## Smith's Four Operational Phases

### Phase 1: Package Setup
**Tool**: `smith-spmsift`

Analyzes package dependencies, detects conflicts, identifies version issues.

```bash
swift package dump-package | smith-spmsift dump-package
```

### Phase 2: Build Monitoring
**Tools**: `smith-sbsift`, `smith-xcsift`

Real-time monitoring with hang detection, bottleneck identification, progress tracking.

```bash
swift build 2>&1 | smith-sbsift monitor --eta --hang-detection
```

### Phase 3: Code Review
**Tools**: `smith`, `smith-skill`

Architectural validation against TCA rules, anti-pattern detection, pattern guidance.

```bash
smith validate --tca
# or use Smith skill in Claude Code
```

### Phase 4: Build Recovery
**Tool**: `smith-xcsift`

Smart rebuild strategies, intelligent diagnostics, recovery recommendations.

```bash
smith-xcsift rebuild --smart-strategy
smith-xcsift diagnose --detailed
```

---

## Smith's Attitude

Smith is not flexible about its standards:

✅ **Smith Will**:
- Give exact error locations
- Explain why rules matter
- Provide concrete fixes
- Suggest code examples
- Help diagnose build issues
- Give confidence scoring

❌ **Smith Won't**:
- Accept workarounds
- Make exceptions
- Suggest unsound designs
- Ignore architectural debt
- Accept unclear code
- Be permissive

---

## Integration with Maxwell

Smith and Maxwell are complementary:

| Aspect | Maxwell | Smith |
|--------|---------|-------|
| Role | Oracle/Teacher | Police/Enforcer |
| Purpose | "How should I write this?" | "Is this correct?" |
| When | Before/during implementation | After implementation |
| Approach | Knowledge-based | Rules-based |

**Workflow**:
```
Maxwell teaches pattern → You implement → Smith validates
```

---

## Key Commands

### CLI Commands

```bash
# Comprehensive analysis
smith analyze /path/to/project

# TCA validation
smith validate --tca

# Performance suggestions
smith optimize

# Project type detection
smith detect

# Build status
smith status
```

### Build Monitoring

```bash
# Monitor Swift builds with hang detection
swift build 2>&1 | smith-sbsift parse --format json
swift build 2>&1 | smith-sbsift monitor --eta

# Analyze SPM dependencies
swift package dump-package | smith-spmsift dump-package

# Monitor Xcode builds
smith-xcsift monitor --hang-detection
smith-xcsift rebuild --smart-strategy
```

### Diagnostics

```bash
# Diagnose build issues
smith-xcsift diagnose --detailed

# Analyze SPM conflicts
smith-spmsift resolve

# Check environment
smith environment
```

---

## Documentation

| Document | Read For |
|----------|----------|
| [START-HERE.md](START-HERE.md) | Quick start and common tasks |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Design philosophy and phases |
| [agent/smith.md](agent/smith.md) | Smith agent definition |
| [skills/skill-smith/skill/SKILL.md](skills/skill-smith/skill/SKILL.md) | Claude Code skill reference |
| [skills/skill-smith/patterns/AGENTS-AGNOSTIC.md](skills/skill-smith/patterns/AGENTS-AGNOSTIC.md) | Swift patterns and best practices |

---

## Installation Methods

### Method 1: Script (Easiest)

```bash
./install.sh
```

### Method 2: Make

```bash
make install
```

### Method 3: Homebrew (Coming Soon)

```bash
brew tap elkraneo/tap
brew install smith
```

---

## How Smith Fits Into Your Workflow

```
┌─────────────────────────────────────────┐
│     Your Swift Development Workflow      │
├─────────────────────────────────────────┤
│                                         │
│  1. Setup Package                       │
│     ↓ smith-spmsift → Check deps        │
│                                         │
│  2. Get Pattern Guidance                │
│     ↓ Maxwell → Learn pattern           │
│                                         │
│  3. Code Implementation                 │
│     ↓ Your code                         │
│                                         │
│  4. Build with Monitoring               │
│     ↓ smith-sbsift → Real-time feedback│
│                                         │
│  5. Code Review                         │
│     ↓ Smith → Architectural validation  │
│                                         │
│  6. Build Recovery (if needed)          │
│     ↓ smith-xcsift → Smart recovery    │
│                                         │
│  7. Production Ready ✓                  │
│                                         │
└─────────────────────────────────────────┘
```

---

## Support and Extension

### Getting Help

- Read [START-HERE.md](START-HERE.md)
- Check [ARCHITECTURE.md](ARCHITECTURE.md)
- Review [agent/smith.md](agent/smith.md)
- Use `smith --help`

### Extending Smith

- Add validation rules in `validation/`
- Add patterns in `skills/skill-smith/patterns/`
- Add scripts in `scripts/`
- Update `ARCHITECTURE.md`

### Reporting Issues

Issues in Smith Tools are tracked in the respective repositories:
- CLI/Skill issues: This repository
- Build tool issues: smith-sbsift, smith-spmsift, smith-xcsift
- Validation issues: smith-validation

---

## Smith's Core Principles

1. **Strict Standards** - TCA rules aren't suggestions
2. **Real-Time Enforcement** - Catch problems early
3. **Clear Communication** - Know exactly what's wrong
4. **Actionable Fixes** - Get concrete solutions
5. **No Exceptions** - Rules apply always

---

## What's Next?

1. **Install Smith**: `./install.sh`
2. **Read START-HERE.md**: Get oriented
3. **Try smith**: `smith analyze /path/to/project`
4. **Use Smith in Claude Code**: `"@smith validate my code"`
5. **Monitor your builds**: Pipe through `smith-sbsift`

---

## Summary

Smith is the **architectural guardian** of your Swift codebase. It operates throughout your development lifecycle, enforcing discipline and ensuring quality.

**Smith is:**
- ✅ Strict about architecture
- ✅ Thorough in build monitoring
- ✅ Clear in error reporting
- ✅ Helpful with solutions
- ❌ Not flexible about rules
- ❌ Not permissive about standards

**Your code will be better for it.**

---

*Smith: The construction police for Swift development.*
