# Multi-Agent Workflow Guide for Smith Tools

**Status**: Ergonomic Recommendation (Not Canonical)
**Purpose**: Document the recommended workflow pattern for using Smith Tools agents effectively
**Context**: Based on real-world usage patterns and multi-agent system best practices

---

## Overview

This guide captures the workflow that naturally emerges when using Smith Tools with clear agent boundaries. It represents a **recommendation based on what works well in practice**, not a prescriptive requirement.

The key insight: **Use agents for their strengths (evaluation, planning, validation) and keep implementation in the main session where you maintain full orchestration control.**

---

## The Core Pattern

```
PHASE 1: Evaluation
  │
  ├─ You: "@smith evaluate my code"
  │  ↓
  │  Smith: Detects project context → Runs validation → Interprets results
  │
  ├─ You: "Maxwell, what do you think about this?"
  │  ↓
  │  Maxwell: Naturally triggered → Synthesizes plan → Identifies options
  │
PHASE 2: Planning
  │
  ├─ Main agent reasons about recommendations
  │  ↓
  │  Develops action plan based on Smith's findings + Maxwell's guidance
  │
PHASE 3: Implementation
  │
  ├─ You: "Claude, implement this refactoring"
  │  ↓
  │  Main session: Executes implementation → Maintains full control
  │  (Keep implementation in main session, not delegated to agents)
  │
PHASE 4: Validation
  │
  ├─ You: "@smith verify my changes"
  │  ↓
  │  Smith: Re-runs validation → Confirms fixes → Loop complete
```

---

## Why This Pattern Works

### 1. Agent Strengths Match Their Roles

**@smith (Evaluation Expert)**
- ✅ Detects project context and patterns
- ✅ Runs validation tools with precision
- ✅ Interprets complex results into actionable feedback
- ✅ Verifies compliance after changes
- ❌ Not appropriate for creative implementation decisions

**@maxwell (Planning Expert)**
- ✅ Synthesizes architectural patterns
- ✅ Provides multiple perspective options
- ✅ Explains trade-offs and reasoning
- ✅ Teaches implementation patterns
- ❌ Not appropriate for validating existing code

**Main Session (Implementation Expert)**
- ✅ Makes creative implementation decisions
- ✅ Handles code file operations and Git
- ✅ Maintains global context across the project
- ✅ Coordinates across multiple concerns
- ❌ Not optimized for deep domain expertise (that's agents)

### 2. Context Management

The pattern respects how multi-agent systems work best:

**Isolated Agent Context** (Smith & Maxwell)
- Each agent has focused, deep expertise
- Smaller context windows = faster, cheaper analysis
- Reduced cognitive load = better quality decisions
- No global state to maintain

**Orchestrator Context** (Main Session)
- Maintains global project understanding
- Tracks decisions and trade-offs
- Coordinates between specialized agents
- Makes final implementation choices

**Trade-off**: Agents lose some global context but gain focus. The main session loses some specialized knowledge but maintains orchestration.

**Result**: 90.2% better performance compared to single monolithic agent for complex tasks.

### 3. Realistic Tool Invocation

The pattern avoids problematic auto-triggering:

- **Explicit invocation** (@smith, @maxwell) is reliable and predictable
- **Natural triggering** (mentioning an agent in conversation) works through context
- **No implicit detection** (avoiding false positives and unexpected behavior)
- **User maintains control** over when agents are engaged

---

## Real-World Example: TCA Refactoring

Here's a concrete example of the pattern in action:

### Phase 1: Evaluation

```
You: "@smith evaluate my TCA reducer"

Smith:
  ✓ Detected TCA project (Swift, Composable Architecture framework)
  ✓ Ran smith-validation rules
  ✓ Found violations: Rule 1.1 (18 properties > 15 limit)
  ✓ Interpreted results for clarity

Result:
  📊 Your UserProfileFeature has 18 state properties
  🔍 Violations Found: Rule 1.1 - Monolithic state scope
  💡 Impact: Harder to test, complex view updates
  🎯 Location: Sources/Features/UserProfile/UserProfileReducer.swift:42
```

### Phase 2: Planning

```
You: "Maxwell, what do you think about this?"

Maxwell: (naturally triggered in context)
  ✓ Reviewed Smith's violations
  ✓ Considered architectural patterns
  ✓ Synthesized options

Response:
  You have several refactoring options:

  Option 1: Sub-features with @Reducer
    • Break into UserInfo + UserSettings + UserPermissions
    • Cleaner composition, independent testing
    • Complexity: Medium

  Option 2: Scoped state using DynamicMember
    • Keep single reducer, scope property access
    • Less refactoring required
    • Complexity: Low

  Option 3: Domain vs UI state separation
    • Separate domain logic from presentation
    • Best long-term maintainability
    • Complexity: High

  Recommendation: Consider your codebase maturity and team.
  Ask me more about any option.
```

### Phase 3: Implementation

```
You: "Claude, implement Option 1 - refactor into sub-features"

Main Session:
  1. Analyze current UserProfileReducer
  2. Extract UserInfo sub-feature (@Reducer)
  3. Extract UserSettings sub-feature (@Reducer)
  4. Extract UserPermissions sub-feature (@Reducer)
  5. Update parent reducer to compose sub-features
  6. Update views to use scoped stores
  7. Update tests for new structure

Note: Implementation stays in main session
      This allows you to ask follow-up questions,
      handle unexpected patterns, make trade-off decisions
```

### Phase 4: Validation

```
You: "@smith verify the refactored code"

Smith:
  ✓ Re-ran smith-validation
  ✓ Checked all sub-features
  ✓ Verified Rule 1.1 compliance

Result:
  ✅ UserInfo: 8 properties ✓
  ✅ UserSettings: 6 properties ✓
  ✅ UserPermissions: 4 properties ✓
  ✅ Parent: 3 sub-features ✓

  All violations resolved. Ready for code review.
```

---

## When to Use Each Part of the Pattern

### Use @smith When:

- You want to understand current code violations
- You need build diagnostics and root cause analysis
- You want to verify compliance after changes
- You're unsure if code follows TCA rules
- You need specific location information for issues

**Don't use @smith for**: Architecture guidance, learning patterns, implementation decisions

### Use @maxwell When:

- You want to understand recommended patterns
- You need to compare architectural options
- You want to learn the reasoning behind best practices
- You want to understand trade-offs
- You need platform-specific guidance

**Don't use @maxwell for**: Code validation, build diagnostics, enforcement

### Use Main Session When:

- You're implementing code changes
- You need to coordinate across multiple files
- You're making creative implementation decisions
- You want full project context
- You need to ask follow-up questions and refine incrementally

**Don't use main session for**: Deep domain expertise (use agents for that)

---

## Phase Details

### Phase 1: Evaluation with @smith

**Goal**: Understand current state and what needs to change

**Questions for Smith**:
```
"@smith evaluate my project"
"Check my TCA reducer for violations"
"Diagnose why my build is hanging"
"Find architectural issues in my code"
```

**What Smith Provides**:
- Specific violations with exact locations
- Explanation of why it's a violation
- Impact analysis for your codebase
- Concrete suggestions for fixes

**Expected Outcome**: Clear understanding of problems and their severity

---

### Phase 2: Planning with @maxwell

**Goal**: Synthesize options and create a refactoring strategy

**Questions for Maxwell**:
```
"What architectural patterns apply here?"
"How should I fix Rule 1.1 violations?"
"Compare @DependencyClient vs Singleton for this case"
"Show me patterns for structuring this module"
```

**What Maxwell Provides**:
- Pattern guidance and best practices
- Multiple approach options with trade-offs
- Code examples and implementation patterns
- Teaching on architectural decisions

**Expected Outcome**: Clear understanding of options and how to implement each

---

### Phase 3: Implementation in Main Session

**Goal**: Transform the plan into working code

**Approach**:
```
1. Read affected files and understand current structure
2. Make incremental changes following Maxwell's guidance
3. Ask questions about unexpected patterns
4. Adjust plan based on what you discover
5. Maintain clean Git commits at logical points
```

**Why in Main Session?**:
- You maintain full project context
- You can ask "what if" questions mid-implementation
- You can make trade-off decisions dynamically
- You handle file operations, Git, and testing
- You see the complete picture as code evolves

**Example**:
```
"Read the UserProfileReducer file"
(Review current implementation)

"Here's what I see... what's the best approach for extracting
UserInfoFeature while keeping shared dependencies?"

(Make first refactoring)

"Check my test file structure - what do I need to update?"
```

---

### Phase 4: Validation with @smith

**Goal**: Confirm that changes resolve violations and don't create new ones

**Questions for Smith**:
```
"@smith verify the refactored code"
"Check for any remaining violations"
"Confirm this passes all TCA rules"
"Are there new issues I introduced?"
```

**What Smith Provides**:
- Fresh validation on updated code
- Confirmation of fixes
- Detection of any new violations
- Path to code review readiness

**Expected Outcome**: Confidence that code is ready to share with team

---

## Common Workflow Variations

### Variation 1: Iterative Refinement

```
Phase 1: @smith evaluate
Phase 2: @maxwell plan (first time)
Phase 3: Main session implements (partial)
Phase 2: @maxwell refine plan (second time, asking about what we discovered)
Phase 3: Main session continues implementation
Phase 4: @smith verify
```

**Use When**: Requirements become clearer during implementation

### Variation 2: Focused Evaluation Loop

```
Phase 1: @smith evaluate
Phase 4: @smith verify (after quick fix)
Phase 4: @smith verify again (after another fix)
```

**Use When**: Simple issues with clear fixes, no planning needed

### Variation 3: Learning First

```
Phase 2: @maxwell teach (learn about a pattern first)
Phase 3: Main session implements
Phase 1: @smith evaluate (make sure it's correct)
Phase 4: @smith verify (confirm compliance)
```

**Use When**: You're learning a new pattern or technique

### Variation 4: Build Diagnostics

```
Phase 1: @smith diagnose build
Phase 2: @maxwell explain (understand root cause)
Phase 3: Main session fix (apply the fix)
Phase 4: @smith verify (confirm build is fixed)
```

**Use When**: Build issues block your work

---

## Context Management Trade-offs

### Why Agents Have Isolated Context

**Benefit: Performance**
- Smaller context windows = 90.2% better performance
- Faster analysis = quicker feedback
- Focused expertise = higher quality

**Cost: Limited Global Context**
- Agents may not remember previous decisions
- Agents lose sight of downstream impacts
- Agents can't coordinate across domains

### Why Main Session Maintains Context

**Benefit: Orchestration**
- You remember why decisions were made
- You see how changes affect entire project
- You can make informed trade-offs

**Cost: Lacks Deep Expertise**
- You can't match agent's domain knowledge
- You need agents to validate and teach
- Complex analysis is slower without tools

### The Balance

**Implementation in main session is intentional**:
- You have enough context for creative decisions
- Agents provide expertise when you need it (evaluation, planning, validation)
- You maintain control while leveraging specialization
- The loop is tight: evaluate → plan → implement → verify

---

## Tips for Using This Workflow

### 1. Be Specific with @smith

```
✅ Good: "@smith check if my UserProfileReducer violates Rule 1.1"
❌ Vague: "@smith look at my code"
```

Smith gives better results with specific scope.

### 2. Ask Maxwell for Options, Not Answers

```
✅ Good: "@maxwell what are the patterns for handling this?"
❌ Directive: "@maxwell refactor my code to use sub-features"
```

Maxwell teaches; implementation stays with you.

### 3. Keep Implementation Interactive

```
✅ Good:
  "Read the file"
  (You review)
  "Here's what I see, how should I restructure?"
  (Interactive refinement)

❌ Hands-off:
  "@smith evaluate my code"
  (Smith reports)
  "Claude, fix all the violations"
  (You lose control of decisions)
```

### 4. Close the Loop with Validation

```
Always end with: "@smith verify the changes"
```

This confirms you've actually resolved the violations.

### 5. Use Maxwell for Trade-offs

When Smith finds violations, ask Maxwell **why** the rule exists:

```
Smith: "Rule 1.1 violation: 18 properties"

You: "@maxwell why does Rule 1.1 exist and what are my options?"

Maxwell: Explains the reasoning and options
```

This helps you make informed decisions, not just follow rules.

---

## When This Pattern Breaks Down

### ❌ Problem: Agent Loses Context Mid-Implementation

**Scenario**: You're deep in implementation, ask an agent something, they don't remember what you're doing

**Solution**: Keep agents for evaluation/planning/validation phases. Stay in main session for implementation.

### ❌ Problem: Too Many Back-and-Forths

**Scenario**: Implementation phase becomes "@smith evaluate", "@maxwell explain", "@smith verify" repeated 10 times

**Solution**: Move evaluation and planning earlier, consolidate findings, then do implementation

### ❌ Problem: Agents Give Conflicting Advice

**Scenario**: @smith reports violations, @maxwell suggests something different

**Solution**: Ask @maxwell to explain the reasoning, then you decide the priority

---

## Summary Table

| Phase | Who | Tool | Goal | Example |
|-------|-----|------|------|---------|
| **1: Evaluate** | @smith | smith-validation | Understand problems | "Evaluate my code" |
| **2: Plan** | @maxwell | Maxwell patterns DB | Design solution | "What patterns apply?" |
| **3: Implement** | Main session | Claude Code tools | Build the solution | "Implement the refactoring" |
| **4: Validate** | @smith | smith-validation | Confirm success | "Verify the changes" |

---

## Key Principles

1. **Agents are specialists** - Use them for their domain expertise, not general work
2. **You are the orchestrator** - Make final decisions, maintain control
3. **Keep context where it matters** - Agents for focused analysis, main session for orchestration
4. **Close the loop** - Always validate after implementing changes
5. **Ask for options, not solutions** - Especially from Maxwell (teaching oracle)
6. **Be specific with requests** - Better specificity = better results
7. **Stay interactive during implementation** - Ask questions, refine as you go

---

## Related Documentation

- **AGENT-ROUTING.md** - Quick decision tree for which agent to use
- **smith.md** - Smith agent definition and capabilities
- **maxwell.md** - Maxwell agent definition and capabilities
- **TRIGGERING.md** - How to reliably invoke agents (explicit vs. natural)

---

*This workflow guide represents a recommendation based on real-world patterns and multi-agent system best practices. It's not canonical, but captures what works well when using Smith Tools ergonomically.*
