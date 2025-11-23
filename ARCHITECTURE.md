# Smith Architecture

## Design Philosophy

Smith is the **enforcement agent** in the Smith Tools ecosystem. It operates as the "construction police" for Swift development, with a philosophy centered on:

1. **Strict Analysis of the Construction Process** - Not just checking final output
2. **Real-Time Enforcement** - Catches problems as they happen, not after failure
3. **System Police Attitude** - Uncompromising about code quality and build health
4. **Complete Lifecycle Coverage** - From package setup through recovery

---

## Three Operational Phases

### Phase 1: Package Setup & Dependency Analysis

**Tools**: `smith-spmsift`

**When**: During package resolution and dependency updates

**What it Does**:
- Analyzes SPM Package structure
- Detects circular dependencies
- Identifies version conflicts
- Reports branch dependencies (anti-patterns)
- Estimates complexity and index time

**Integration**:
```bash
swift package dump-package | smith-spmsift dump-package --format json
```

---

### Phase 2: Build Monitoring & Diagnosis

**Tools**: `smith-sbsift`, `smith-xcsift`

**When**: During active builds

**What it Does**:

**smith-sbsift** (Swift Build):
- Real-time build progress tracking
- File-level timing analysis
- Build bottleneck identification
- Intelligent hang detection with root cause analysis
- 43% context reduction for AI agents

**smith-xcsift** (Xcode):
- Xcode-specific build analysis
- Priority rebuild strategies
- DerivedData cleanup and optimization
- Build phase timing
- Memory pressure detection

**Integration**:
```bash
# Swift builds
swift build 2>&1 | smith-sbsift parse --format json
swift build 2>&1 | smith-sbsift monitor --eta --hang-detection

# Xcode builds
smith-xcsift rebuild --smart-strategy
smith-xcsift monitor --hang-detection
```

---

### Phase 3: Code Review & Architectural Validation

**Tools**: `smith-validation`, `smith-skill`, `smith`

**When**: During code review and implementation

**What it Does**:

**smith-validation**:
- TCA Rules 1.1-1.5 enforcement
- Monolithic feature detection
- Dependency injection validation
- Code duplication detection
- Progressive intelligence (3 analysis levels)

**smith-skill** (Claude Code):
- Architecture guidance for developers
- Pattern reference and examples
- Red flag detection for deprecated patterns
- Anti-pattern identification

**smith**:
- Unified orchestration of all validation
- Comprehensive project analysis
- Environment status reporting

**Integration**:
```bash
smith analyze /path/to/project --level critical
smith validate --tca
smith optimize
```

---

### Phase 4: Build Recovery & Diagnostics

**Tools**: `smith-xcsift`, `smith-core`

**When**: After build failures

**What it Does**:
- Intelligent hang detection with root cause analysis
- Priority rebuild strategies:
  - Clean with Cache Reset
  - Memory-Optimized Rebuild
  - Dependency Resolution Rebuild
  - Fast Incremental Rebuild
- DerivedData cleanup
- Diagnostic reports

**Integration**:
```bash
smith-xcsift diagnose --detailed
smith-xcsift rebuild --smart-strategy
```

---

## Component Architecture

```
smith-core (Foundation)
    ↓ (provides shared models and utilities)
    ├─→ smith-sbsift (Swift Build Analysis)
    ├─→ smith-spmsift (SPM Analysis)
    ├─→ smith-xcsift (Xcode Build Analysis)
    └─→ smith-validation (Architectural Rules)
        ↓
        ├─→ smith (Orchestrator)
        └─→ smith-skill (Claude Code Integration)
```

### smith-core

**Purpose**: Universal Swift patterns and shared utilities

**Provides**:
- `BuildAnalysis` - Build status and metrics
- `DependencyGraph` - Package dependency modeling
- `HangDetector` - Intelligent hang detection with root cause
- `BuildDiagnostics` - Type inference and TCA anti-patterns
- `ProjectDetector` - SPM vs Xcode detection
- `SyntaxValidators` - Code pattern validation

**Used By**: All other Smith tools

### smith-sbsift

**Purpose**: Context-efficient Swift build output analysis

**Capabilities**:
- Parse Swift compiler output
- Real-time progress tracking with ETA
- File-level timing and bottleneck analysis
- Hang detection and termination
- 43% context reduction for AI

**Deployment**: Homebrew

### smith-spmsift

**Purpose**: Context-efficient SPM analysis

**Capabilities**:
- Package structure analysis
- Dependency tree visualization
- Circular dependency detection
- Version conflict reporting
- 95%+ context savings vs raw output

**Deployment**: Homebrew

### smith-xcsift

**Purpose**: Xcode-specific build analysis and recovery

**Capabilities**:
- Xcode project analysis
- Priority rebuild strategies
- DerivedData management
- Build phase timing
- Hang detection with diagnostics

**Deployment**: Homebrew

### smith-validation

**Purpose**: Architectural rules engine for TCA

**Rules** (1.1-1.5):
- Monolithic feature detection
- Proper DI patterns
- Code duplication
- Organization clarity
- Coupling analysis

**Output**: Progressive intelligence with automation confidence

**Integrated Into**: Smith CLI and Skill

### smith

**Purpose**: Unified CLI orchestrator

**Commands**:
- `analyze` - Comprehensive project analysis
- `validate` - Specific validation (e.g., `--tca`)
- `optimize` - Performance suggestions
- `detect` - Project type detection
- `status` - Environment status
- `environment` - Detailed environment info

**Integration Points**:
- Smith Core (models and diagnostics)
- Smith Validation (rules engine)
- Smith Skill (documentation and patterns)

### smith-skill

**Purpose**: Claude Code integration for architectural guidance

**Structure**:
- `skill/SKILL.md` - Main skill definition
- `skill/CLAUDE.md` - Agent instructions
- `patterns/AGENTS-*.md` - Universal patterns
- `patterns/AGENTS-DECISION-TREES.md` - Decision guidance
- `platforms/PLATFORM-*.md` - Platform-specific patterns

**Auto-Triggers On**:
- TCA keywords: `@Reducer`, `CombineReducers`, `Reducer`
- Architecture keywords: `monolithic`, `coupling`, `testability`
- Swift patterns: `@State`, `async/await`, dependency injection

**Features**:
- Red flag detection (deprecated patterns)
- Anti-pattern identification
- TCA composition validation
- Platform-specific guidance

---

## Development Lifecycle with Smith

```
┌─────────────────────────────────────────────────────────┐
│              Developer's Workflow                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Step 1: Setup Package                                  │
│  ↓                                                       │
│  smith-spmsift → Analyze dependencies                   │
│                  Check for conflicts                    │
│                                                          │
│  Step 2: Code Implementation                            │
│  ↓                                                       │
│  Maxwell Skill → Pattern guidance                       │
│  ↓                                                       │
│  Developer writes code                                  │
│                                                          │
│  Step 3: During Build                                   │
│  ↓                                                       │
│  swift build 2>&1 | smith-sbsift                        │
│  ↓                                                       │
│  Real-time monitoring, hang detection                   │
│                                                          │
│  Step 4: Code Review                                    │
│  ↓                                                       │
│  smith validate --tca                               │
│  Smith Skill in Claude Code                             │
│  ↓                                                       │
│  Architectural validation, TCA rules check              │
│                                                          │
│  Step 5: Build Failure (if any)                         │
│  ↓                                                       │
│  smith-xcsift diagnose                                  │
│  smith-xcsift rebuild --smart-strategy                  │
│  ↓                                                       │
│  Intelligent recovery                                   │
│                                                          │
│  Step 6: Production Ready                               │
│  ✓ All validations passed                               │
│  ✓ Build successful                                     │
│  ✓ Architecture sound                                   │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Smith's Attitude: System Police

Smith enforces discipline through:

1. **Strict Rules** - No exceptions for TCA composition
2. **Real-Time Monitoring** - Catches issues as they happen
3. **Clear Error Messages** - Tells you exactly what's wrong and why
4. **Actionable Fixes** - Provides solutions, not just problems
5. **Continuous Validation** - Every phase of development

**Motto**: "Code quality isn't negotiable. Builds shouldn't hang. Architecture is discipline."

---

## Integration with Maxwell

Smith and Maxwell are complementary:

| Aspect | Maxwell | Smith |
|--------|---------|-------|
| Role | Oracle (Teacher) | Police (Enforcer) |
| When | Before/during implementation | After implementation |
| Question | "How should I write this?" | "Is this correct?" |
| Approach | Knowledge-based, advisory | Rules-based, strict |
| Output | Patterns, examples, guidance | Pass/fail, violations, warnings |

**Workflow**:
```
Maxwell: "Use @ObservableState instead of @State in reducers"
   ↓
Developer: "Got it, implementing now"
   ↓
Smith: "Validates that @ObservableState is used correctly"
   ↓
Production Ready Code
```

---

## Design Decisions

### Why Separate Tools?

Each Smith tool specializes in one phase:
- `spmsift` handles package setup
- `sbsift` handles Swift builds
- `xcsift` handles Xcode builds
- `validation` handles architecture
- `cli` orchestrates everything

This separation allows:
- Independent evolution
- Reusability (e.g., sbsift in automation)
- Clear responsibility
- Easy testing

### Why smith-core?

All tools need:
- Consistent data models
- Hang detection logic
- Build analysis utilities

`smith-core` provides these as a shared library, ensuring:
- Consistent behavior
- Reduced duplication
- Easy updates

### Why CLI + Skill?

- **CLI** for automation and CI/CD
- **Skill** for interactive development guidance

They use the same validation rules but serve different users.

---

## Extending Smith

### Adding a New Validation Rule

1. Create rule in `validation/`
2. Add test cases
3. Update smith
4. Document in smith-skill

### Adding a New Analysis Tool

1. Create tool structure following smith-*sift pattern
2. Output JSON for integration with CLI
3. Add orchestration to smith
4. Document in START-HERE.md

### Adding Platform-Specific Guidance

1. Create `platforms/PLATFORM-*.md` in skill
2. Document patterns for that platform
3. Add auto-trigger keywords
4. Link from main SKILL.md

---

## Summary

Smith is the architectural guardian of your Swift codebase. It:

- **Operates throughout your entire development lifecycle**
- **Combines real-time monitoring with strict validation**
- **Provides clear, actionable error messages**
- **Works in harmony with Maxwell to ensure code quality**

It's not permissive. It's not flexible about rules. And that's exactly the point.

**Smith: The construction police for Swift development.**
