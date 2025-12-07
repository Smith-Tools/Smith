# Smith Architecture

## Design Philosophy

Smith is the **enforcement agent** in the Smith Tools ecosystem. It operates as the "construction police" for Swift development, with a philosophy centered on:

1. **Value Delivery First** - Every feature is measured by: Does this save time? Does this prevent mistakes?
2. **Strict Analysis of the Construction Process** - Not just checking final output
3. **Real-Time Enforcement** - Catches problems as they happen, not after failure
4. **System Police Attitude** - Uncompromising about code quality and build health
5. **Complete Lifecycle Coverage** - From package setup through recovery

### Value Delivery Principle

Smith is not about being comprehensive. It's about being useful.

Every command, every output format, every validation rule is evaluated by:
- ✅ **Saves agents/developers time** - Smith findings are actionable and save implementation time
- ✅ **Prevents real mistakes** - Smith catches architectural issues before they become costly
- ✅ **Fits naturally into workflow** - Agents naturally reach for Smith when making decisions
- ❌ **Wastes time** - Comprehensive but overwhelming output gets ignored
- ❌ **Enforces for enforcement's sake** - Mandatory usage without clear benefit

---

## Unified smith CLI Approach

The `smith` CLI provides unified access to all analysis capabilities:

```bash
# Project analysis and dependency review
smith dependencies /path/to/project

# Architectural validation
smith validate --tca

# Comprehensive analysis
smith analyze /path/to/project

# Build diagnostics
smith diagnose
```

**Key Capabilities**:
- Package structure analysis (SPM/Xcode)
- Dependency ranking and circular dependency detection
- TCA architectural validation (Rules 1.1-1.5)
- Build performance analysis
- Code pattern validation
- Environment diagnostics

All analysis is integrated through the `smith` CLI, providing a consistent interface for:
- Project setup and dependency review
- During-development guidance
- Code review validation
- Build diagnostics and recovery

---

## Component Architecture

```
smith-foundation (Shared Libraries)
    ├─ SmithOutputFormatter - Consistent output
    ├─ SmithErrorHandling - Error management
    └─ SmithProgress - Progress tracking

smith-build-analysis (Shared Parsing)
    └─ Build output parsing and diagnostics

smith (Unified CLI)
    ├─ dependencies - Project and package analysis
    ├─ validate - Architectural validation
    ├─ analyze - Comprehensive analysis
    └─ diagnose - Build diagnostics

smith-validation (Rules Engine)
    ├─ TCA Rules 1.1-1.5
    ├─ Pattern validation
    └─ Anti-pattern detection

smith-skill (Claude Code Integration)
    ├─ Architecture guidance
    ├─ Pattern references
    └─ Platform-specific patterns
```

### smith CLI

**Purpose**: Unified interface to all Smith analysis

**Primary Commands**:
- `dependencies` - Analyze project dependencies and structure
- `validate` - Validate architecture (e.g., TCA rules)
- `analyze` - Comprehensive project analysis
- `diagnose` - Build diagnostics

**Features**:
- Auto-detects project type (SPM/Xcode)
- Analyzes dependencies and imports
- Validates TCA composition
- Detects circular dependencies
- Provides actionable error messages

### smith-validation

**Purpose**: Architectural rules engine for TCA

**Rules** (1.1-1.5):
- Monolithic feature detection
- Proper dependency injection patterns
- Code duplication detection
- Organization clarity
- Coupling analysis

**Output**: Progressive intelligence with automation confidence

### smith-foundation

**Purpose**: Shared utilities for consistent behavior across tools

**Provides**:
- Output formatting (TTY-aware)
- Error handling (structured, actionable)
- Progress tracking (with ETA)

### smith-skill

**Purpose**: Claude Code integration for architectural guidance

**Structure**:
- `skill/SKILL.md` - Main skill definition
- `patterns/AGENTS-*.md` - Universal patterns
- `platforms/PLATFORM-*.md` - Platform-specific patterns

**Auto-Triggers On**:
- TCA keywords: `@Reducer`, `CombineReducers`, `Reducer`
- Architecture keywords: `monolithic`, `coupling`, `testability`
- Swift patterns: `@State`, `async/await`, dependency injection

**Features**:
- Architecture guidance
- Pattern examples
- Anti-pattern identification

---

## Development Lifecycle with Smith

```
┌─────────────────────────────────────────────────────────┐
│              Developer's Workflow                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Step 1: Project Setup                                  │
│  ↓                                                       │
│  smith dependencies /path → Analyze dependencies        │
│                             Check for conflicts         │
│                             Dependency rankings         │
│                                                          │
│  Step 2: Code Implementation                            │
│  ↓                                                       │
│  Maxwell Skill → Pattern guidance                       │
│  ↓                                                       │
│  Developer writes code                                  │
│                                                          │
│  Step 3: Code Review                                    │
│  ↓                                                       │
│  smith validate --tca → Architectural validation        │
│  Smith Skill in Claude Code → TCA rules check           │
│                                                          │
│  Step 4: Build                                          │
│  ↓                                                       │
│  smith analyze → Comprehensive analysis                 │
│  ↓                                                       │
│  Build and test                                         │
│                                                          │
│  Step 5: Build Issues (if any)                          │
│  ↓                                                       │
│  smith diagnose → Intelligent diagnostics               │
│  ↓                                                       │
│  Recovery                                               │
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

1. Create rule in `smith-validation/`
2. Add test cases
3. Integrate into smith CLI
4. Document in smith-skill

### Improving smith CLI

1. Add new command to smith CLI
2. Implement analysis logic
3. Ensure JSON output format
4. Update documentation (START-HERE.md, ARCHITECTURE.md)

### Adding Platform-Specific Guidance

1. Create `platforms/PLATFORM-*.md` in smith-skill
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
