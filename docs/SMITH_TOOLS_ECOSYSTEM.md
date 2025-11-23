# Smith Tools Ecosystem - Complete Architecture

## Overview

The Smith Tools ecosystem is a unified system for Swift development discipline. It consists of two complementary agents: **Smith** (enforcement) and **Maxwell** (guidance), supported by specialized analysis tools.

---

## The Two Core Agents

### Smith: Enforcement Agent

**Role**: System Police for Swift Architecture

**Purpose**: Strict validation and build health enforcement throughout the entire development lifecycle.

**Components**:
- **smith** - Unified orchestrator and command-line interface
- **smith-skill** - Claude Code skill for interactive validation
- **smith-validation** - TCA rules engine (Rules 1.1-1.5)

**Operational Phases**:
1. **Package Setup** - `smith-spmsift` analyzes dependencies
2. **Build Monitoring** - `smith-sbsift` + `smith-xcsift` real-time monitoring
3. **Code Review** - `smith` + `smith-skill` architectural validation
4. **Build Recovery** - `smith-xcsift` intelligent recovery strategies

**Philosophy**:
- Code quality isn't negotiable
- Builds shouldn't hang
- Architecture is discipline
- No exceptions to rules

**Repository**: `/Volumes/Plutonian/_Developer/Smith Tools/Smith/`

---

### Maxwell: Oracle Agent

**Role**: Knowledge Companion for Swift Development

**Purpose**: Teach patterns and guide implementation before Smith validates.

**Components**:
- **maxwell-cli** - Knowledge access via command-line
- **auto-triggered skills** - 3 specialized skill domains
- **SQLite database** - 153 migrated documents, FTS5 search

**Specialized Skills**:
- `skill-pointfree` - TCA authority (@Shared, @Bindable, Reducer)
- `skill-shareplay` - SharePlay expert (GroupActivities, collaboration)
- `skill-meta` - Maxwell's self-knowledge (architecture patterns)

**Philosophy**:
- Patterns are taught, not enforced
- Multiple valid approaches exist
- Context matters
- Learning through examples

**Repository**: `/Volumes/Plutonian/_Developer/Smith Tools/Maxwell/`

---

## The Specialized Analysis Tools

These are standalone utilities that Smith orchestrates:

### smith-core

**Purpose**: Shared foundation for all Smith tools

**Provides**:
- Common data models (BuildAnalysis, DependencyGraph, etc.)
- Hang detection with root cause analysis
- Build diagnostics (type inference, anti-patterns)
- Project detection (SPM vs Xcode)

**Used By**: All other Smith tools

**Repository**: `smith-core/`

### smith-sbsift (Swift Build Sift)

**Purpose**: Real-time Swift build output analysis

**Capabilities**:
- Parse Swift compiler output
- Real-time progress tracking with ETA
- File-level timing and bottleneck analysis
- Hang detection with termination
- 43% context reduction for AI agents

**Usage**:
```bash
swift build 2>&1 | smith-sbsift parse --format json
swift build 2>&1 | smith-sbsift monitor --eta --hang-detection
```

**Repository**: `smith-sbsift/`

### smith-spmsift (SPM Sift)

**Purpose**: Context-efficient SPM analysis

**Capabilities**:
- Package structure analysis
- Dependency tree visualization
- Circular dependency detection
- Version conflict reporting
- 95%+ context savings vs raw output

**Usage**:
```bash
swift package dump-package | smith-spmsift dump-package
smith-spmsift show-dependencies --format json
```

**Repository**: `smith-spmsift/`

### smith-xcsift (Xcode Sift)

**Purpose**: Xcode-specific build analysis and recovery

**Capabilities**:
- Xcode project analysis
- Priority rebuild strategies
- DerivedData management
- Build phase timing
- Hang detection with diagnostics

**Usage**:
```bash
smith-xcsift diagnose --detailed
smith-xcsift rebuild --smart-strategy
smith-xcsift monitor --hang-detection
```

**Repository**: `smith-xcsift/`

### smith-validation

**Purpose**: Architectural rules engine for TCA

**Rules** (1.1-1.5):
- Monolithic feature detection (State >15 props, Actions >40 cases)
- Proper dependency injection validation
- Code duplication detection
- Organization clarity
- Coupling analysis

**Progressive Intelligence Levels**:
- Critical: Only critical+high severity
- Standard: All violations with smart filtering
- Comprehensive: Standard + pattern insights

**Repository**: `smith-validation/` (now in Smith/)

---

## Complete Architecture Diagram

```
                    ┌──────────────────────────────────┐
                    │     Smith Tools Ecosystem        │
                    └──────────────────────────────────┘
                              │
                ┌─────────────┴──────────────┐
                │                            │
          ┌─────▼─────┐              ┌──────▼──────┐
          │   SMITH   │              │  MAXWELL    │
          │ Enforcement│              │   Oracle   │
          └─────┬─────┘              └──────┬──────┘
                │                            │
        ┌───────┴────────┐          ┌────────┴────────┐
        │                │          │                 │
    ┌───▼──┐      ┌─────▼────┐   ┌──▼──────┐    ┌────▼────┐
    │smith-│      │smith-    │   │  maxwell │    │auto-    │
    │cli   │      │skill     │   │CLI       │    │triggered│
    └──────┘      └──────────┘   └──────────┘    │skills   │
        │                │            │           └─────────┘
        └────────┬───────┘            │
                 │                    │
          ┌──────▼───────┐      ┌────▼──────┐
          │smith-core    │      │SQLite DB  │
          │(shared libs) │      │153 docs   │
          └──────┬───────┘      └───────────┘
                 │
    ┌────────────┼────────────┬───────────┐
    │            │            │           │
 ┌──▼──┐     ┌──▼──┐     ┌───▼──┐    ┌──▼────┐
 │smith│     │smith│     │smith │    │smith  │
 │sbsift    │spmsift    │xcsift    │validation│
 └──────┘   └──────┘    └────────┘   └────────┘
```

---

## Development Workflow with Smith Tools

```
┌──────────────────────────────────────────────────────────┐
│           Developer's Complete Workflow                   │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ 1. SETUP PHASE                                          │
│    ↓ smith-spmsift → Analyze dependencies              │
│                       Check for conflicts              │
│                                                          │
│ 2. LEARNING PHASE                                       │
│    ↓ Maxwell → Teach pattern                           │
│               "How should I implement this?"            │
│                                                          │
│ 3. IMPLEMENTATION PHASE                                 │
│    ↓ Developer writes code                             │
│                                                          │
│ 4. BUILD PHASE                                          │
│    ↓ swift build 2>&1 | smith-sbsift                  │
│       Real-time monitoring, hang detection             │
│                                                          │
│ 5. CODE REVIEW PHASE                                    │
│    ↓ Smith → Validate architecture                     │
│             "Is this correct?"                         │
│             Check TCA Rules 1.1-1.5                    │
│             Detect anti-patterns                       │
│                                                          │
│ 6. FAILURE RECOVERY (if needed)                         │
│    ↓ smith-xcsift → Intelligent recovery              │
│                     Smart rebuild strategy             │
│                                                          │
│ 7. PRODUCTION READY ✓                                   │
│    All validations passed                              │
│    Architecture sound                                  │
│    Build successful                                    │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Tool Selection Decision Tree

```
What's your task?

├─ Package/dependency issue?
│  └→ smith-spmsift show-dependencies
│
├─ Swift build problem?
│  ├─ During build?
│  │  └→ swift build 2>&1 | smith-sbsift
│  │
│  └─ Need diagnostics?
│     └→ smith-xcsift diagnose
│
├─ Xcode build problem?
│  ├─ Hangs or slow?
│  │  └→ smith-xcsift monitor --hang-detection
│  │
│  └─ Need recovery?
│     └→ smith-xcsift rebuild --smart-strategy
│
├─ Architecture validation?
│  ├─ Command line?
│  │  └→ smith validate --tca
│  │
│  └─ Interactive in Claude Code?
│     └→ "@smith validate my code"
│
├─ Learn a pattern?
│  ├─ TCA patterns?
│  │  └→ @maxwell or "Use skill-pointfree"
│  │
│  ├─ SharePlay patterns?
│  │  └→ @maxwell or "Use skill-shareplay"
│  │
│  └─ General patterns?
│     └→ maxwell search "pattern name"
│
└─ Need help?
   └→ START-HERE.md (Smith)
   └→ maxwell --help
```

---

## Directory Layout

```
Smith Tools/
│
├── Smith/                          [Unified enforcement]
│   ├── README.md
│   ├── START-HERE.md
│   ├── ARCHITECTURE.md
│   ├── agent/smith.md
│   ├── skills/skill-smith/
│   ├── cli/
│   ├── validation/
│   ├── scripts/
│   └── resources/
│
├── Maxwell/                        [Oracle guidance]
│   ├── agent/maxwell.md
│   ├── skills/
│   ├── cli/
│   ├── database/
│   └── install.sh
│
├── smith-core/                     [Shared library]
├── smith-sbsift/                   [Swift build analyzer]
├── smith-spmsift/                  [SPM analyzer]
├── smith-xcsift/                   [Xcode analyzer]
├── smith-validation/               [Rules engine]
│
├── sosumi/                         [Apple docs/WWDC search]
│
└── _archived/                      [Legacy components]
    ├── smith.archive/
    └── smith-skill.archive/
```

---

## Smith vs Maxwell: Interaction Model

### Maxwell Teaches
```
User: "How do I use @Shared for state sharing?"
    ↓
Maxwell (skill-pointfree) returns:
- Pattern explanation
- Code example
- Best practices
- Common mistakes to avoid
```

### Smith Validates
```
User: "Check if my code is correct"
    ↓
Smith (smith-skill or smith) returns:
- TCA Rules 1.1-1.5 violations
- Anti-pattern detection
- Specific line numbers
- Exact fixes needed
```

### Complete Workflow
```
Maxwell teaches → Developer implements → Smith validates → Production Ready
```

---

## Installation and Usage

### Install Smith Tools

```bash
# Smith (Enforcement)
cd Smith
./install.sh

# Maxwell (Oracle)
cd Maxwell
./install.sh

# Supporting tools (via Homebrew)
brew tap elkraneo/tap
brew install smith-sbsift smith-spmsift smith-xcsift
```

### Use Smith

```bash
# CLI validation
smith analyze /path/to/project
smith validate --tca

# During builds
swift build 2>&1 | smith-sbsift analyze

# In Claude Code
"@smith validate my code"
```

### Use Maxwell

```bash
# Knowledge access
maxwell search "TCA patterns"
maxwell pattern "@Shared"

# In Claude Code
"@maxwell how do I use @Shared?"
```

---

## Key Principles

### Smith's Principles
1. **Strict Standards** - No exceptions to TCA rules
2. **Real-Time Enforcement** - Catch problems early
3. **Clear Communication** - Know exactly what's wrong
4. **Actionable Fixes** - Get concrete solutions
5. **System Police Attitude** - Uncompromising quality

### Maxwell's Principles
1. **Knowledge First** - Teach before enforcement
2. **Multiple Approaches** - Context matters
3. **Example-Driven** - Learn from patterns
4. **Patient Teaching** - No pressure
5. **Wisdom Over Rules** - Understanding matters

---

## Summary

The Smith Tools ecosystem provides:

✅ **Smith (Enforcement)**: Strict validation throughout development lifecycle
✅ **Maxwell (Guidance)**: Teaches patterns and best practices
✅ **Specialized Tools**: Real-time monitoring and analysis
✅ **Unified Interface**: CLI, Claude Code, and automation-friendly
✅ **Complete Coverage**: From package setup to production deployment

**Together, they ensure code quality, architectural discipline, and build health.**

Smith: Strict. Maxwell: Wise. Together: Unstoppable.
