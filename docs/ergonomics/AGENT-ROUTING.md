# Agent Routing Guide - @smith vs @maxwell

When working with Smith Tools in Claude Code, you have specialized agents available for different types of work. This guide explains **when to use which agent** and **what each agent does**.

## Quick Decision Tree

```
Have a question about HOW to structure code?
├─ YES → Use @maxwell (Teaching/Guidance)
│   Examples: patterns, architecture decisions, best practices
│
└─ NO → Check next question

Have implemented code you want validated?
├─ YES → Use @smith (Enforcement/Validation)
│   Examples: rule checking, anti-pattern detection, build diagnostics
│
└─ NO → Use general Claude Code capabilities
```

---

## The Agents

### @maxwell - The Oracle (Teaching & Guidance)

**Role**: Architect and pattern expert who teaches you HOW to write code correctly

**Use Maxwell for:**

#### Architecture & Design Questions
```
"What's the difference between @DependencyClient and Singleton?"
"When should I create a Swift Package module?"
"Where should business logic live in TCA?"
"How do I refactor an inline reducer?"
```

#### Pattern & Recipe Questions
```
"Show me a TestStore pattern for async effects"
"What's the right way to handle keyboard in iOS?"
"How do I implement split-view on iPad?"
"What's the pattern for RealityKit in visionOS?"
```

#### Platform-Specific Guidance
```
"What are macOS-specific patterns I should know?"
"How does iPadOS multitasking affect my architecture?"
"What's different about visionOS development?"
"iOS best practices for safe area and dynamic type"
```

#### Decision Frameworks
```
"Should I use @DependencyClient or Singleton?"
"When should I extract to a module?"
"Where does error handling belong in TCA?"
"How do I decide between NavigationStack and .sheet?"
```

**Maxwell Delivers:**
- ✅ Comprehensive guides and tutorials
- ✅ Code examples and patterns
- ✅ Decision frameworks and pros/cons
- ✅ Best practices and recommendations
- ✅ Related resources and cross-references

**Maxwell Does NOT:**
- ❌ Validate your code against rules
- ❌ Diagnose build failures
- ❌ Enforce architectural standards
- ❌ Analyze your codebase

---

### @smith - The Enforcer (Validation & Enforcement)

**Role**: Strict enforcer who validates that your code follows TCA rules and best practices

**Use Smith for:**

#### TCA Rule Validation
```
"Validate my reducer against TCA composition rules"
"Does my feature violate Rule 1.1 (monolithic state)?"
"Check if I'm properly using @Dependency injection"
"Are there any deprecated patterns in this code?"
```

#### Build Issue Diagnosis
```
"Why is my build hanging?"
"What's causing the type inference explosion?"
"Diagnose slow compilation in my project"
"Find circular dependencies in my package structure"
```

#### Code Review Validation
```
"Check my code against Smith's architectural standards"
"Are there anti-patterns in this reducer?"
"Validate my dependency injection approach"
"Does this code follow TCA best practices?"
```

#### Performance & Structure Analysis
```
"Analyze my package structure for issues"
"Check for code duplication patterns"
"Validate that my state is properly organized"
"Are there tightly coupled components?"
```

**Smith Delivers:**
- ✅ Specific violation detection with line numbers
- ✅ Explanation of WHY it's a violation
- ✅ Concrete suggestions for fixing issues
- ✅ Code examples demonstrating corrections
- ✅ Build diagnostics with root causes

**Smith Does NOT:**
- ❌ Teach you HOW to structure code (that's Maxwell)
- ❌ Make exceptions or accept workarounds
- ❌ Explain design patterns (those go to Maxwell)
- ❌ Provide architecture guidance (see Maxwell)

---

## Real-World Examples

### Example 1: Learning about Dependency Injection

**Your Question**: "How should I handle dependency injection in my reducer?"

**Which agent**: @maxwell (this is teaching/guidance)

**Maxwell's response:**
- Explanation of `@DependencyClient` and when to use it
- Implementation patterns with code examples
- Comparison with Singleton approach
- Decision framework: when to use each
- Link to testing patterns

**What Smith would say if you asked it**:
- ❌ "That's a Maxwell question, not an enforcement question"
- ❌ "Ask @maxwell for architecture guidance"

---

### Example 2: Reviewing Implemented Reducer

**Your Question**: "Validate that my reducer follows TCA rules"

**Which agent**: @smith (this is validation/enforcement)

**Smith's response:**
- ✅ Checks Rules 1.1-1.5 compliance
- ✅ Lists any violations with exact locations
- ✅ Explains why each violation matters
- ✅ Suggests concrete fixes
- ✅ Provides code examples

**Then optionally**:
- Ask @maxwell: "How do I restructure this to follow Rule 1.1?"
- (Maxwell teaches you how)
- Ask @smith: "Validate my restructured code"
- (Smith confirms it's compliant)

---

### Example 3: Build Failure Diagnosis

**Your Question**: "My build is hanging during compilation. What's wrong?"

**Which agent**: @smith (this is build diagnostics)

**Smith's response:**
- Root cause analysis (type inference explosion, circular dependency, etc.)
- Affected files with line numbers
- Explanation of why it's a problem
- Smart rebuild strategies
- Prevention tips

**Not Maxwell**, because:
- This isn't about learning patterns
- This is about diagnosing a specific problem
- Maxwell doesn't do build analysis

---

### Example 4: Understanding Platform-Specific Patterns

**Your Question**: "What are the best practices for handling iPad split view?"

**Which agent**: @maxwell (this is teaching/guidance)

**Maxwell's response:**
- Explanation of size classes and adaptive layouts
- Code patterns for responsive design
- Navigation patterns specific to iPad
- Drag & drop between split panes
- Testing strategies

**Then optionally**:
- Implement the pattern
- Ask @smith: "Validate my split view implementation"
- (Smith checks for architectural issues)

---

## Routing Quick Reference

| Question Type | Agent | Why |
|---------------|-------|-----|
| "How do I...?" | @maxwell | Teaching question |
| "Should I use X or Y?" | @maxwell | Design decision |
| "What's the pattern for...?" | @maxwell | Pattern guidance |
| "Validate my code" | @smith | Enforcement question |
| "Check for violations" | @smith | Rule validation |
| "Diagnose my build" | @smith | Build analysis |
| "Are there anti-patterns?" | @smith | Code review validation |
| "How do I test...?" | @maxwell | Testing patterns |

---

## Common Routing Mistakes

### ❌ Wrong: Asking Smith for Pattern Guidance
```
"How should I structure my TCA reducer?"
→ That's a Maxwell question (teaching)
→ Try: "Show me TCA reducer patterns"
```

### ❌ Wrong: Asking Maxwell to Validate Your Code
```
"Does my reducer violate Rule 1.1?"
→ That's a Smith question (enforcement)
→ Try: "@smith check my reducer for violations"
```

### ❌ Wrong: Asking Maxwell About Build Failures
```
"Why is my build hanging?"
→ That's a Smith question (diagnostics)
→ Try: "@smith diagnose my build"
```

### ✅ Right: Proper Routing

```
Step 1: Learn the pattern
"@maxwell how do I structure a TCA reducer?"

Step 2: Implement the pattern
(You write code)

Step 3: Validate your implementation
"@smith validate my reducer"

Step 4: If violations found, ask Maxwell again
"@maxwell how do I fix Rule 1.1 violations?"
```

---

## The Complete Workflow

### Ideal Development Flow

```
1. START: Have a question about architecture
   ↓
2. "@maxwell show me the pattern for X"
   ↓
   (Maxwell teaches you the pattern)
   ↓
3. IMPLEMENT: Write your code following the pattern
   ↓
4. VALIDATE: "@smith check my code"
   ↓
   ↓─ NO VIOLATIONS → Code review ready ✅
   │
   ↓─ VIOLATIONS FOUND → Continue to step 5
   │
5. UNDERSTAND: "@maxwell explain how to fix Rule X"
   ↓
   (Maxwell teaches you the fix)
   ↓
6. FIX: Update your code
   ↓
7. REVALIDATE: "@smith validate again"
   ↓
   ↓─ PASSES → Code review ready ✅
   │
   ↓─ STILL FAILING → Repeat steps 5-7
```

---

## Agent Boundaries

### @maxwell Handles These Domains

- **Architecture**: TCA structure, composition, state management
- **Design Patterns**: Reducer patterns, dependency injection, navigation
- **Platform-Specific**: iOS, macOS, iPadOS, visionOS patterns
- **Concurrency**: Async/await, Task groups, cancellation patterns
- **Testing**: Test patterns, TestStore usage, dependency mocking
- **Best Practices**: Code organization, separation of concerns
- **Decisions**: Decision frameworks for architectural choices

### @smith Handles These Domains

- **TCA Rules Enforcement**: Rules 1.1-1.5 validation
- **Anti-Pattern Detection**: Deprecated patterns, code smells
- **Build Diagnostics**: Hangs, bottlenecks, dependency issues
- **Code Structure Analysis**: Monolithic features, duplication, coupling
- **Dependency Validation**: Hard-wired dependencies, circular dependencies
- **Performance Analysis**: Type inference issues, compilation bottlenecks
- **Build Health**: Package structure, targets, resolved dependencies

---

## When to Use Neither

Use general Claude Code capabilities (without @smith or @maxwell) for:

- General Swift syntax questions
- Project setup and configuration
- File navigation and exploration
- Markdown documentation writing
- Non-architectural code changes
- Apple framework questions (not TCA/architecture specific)

For Apple framework questions that are architectural, use:
- @maxwell for "how to structure code using SwiftUI"
- @smith for validating your SwiftUI implementation against standards

---

## Quick Help

If you're unsure which agent to use:

1. **Is it about learning/patterns?** → @maxwell
2. **Is it about validating/enforcing?** → @smith
3. **Is it about something else?** → Regular Claude Code

---

## Summary

| Aspect | @maxwell | @smith |
|--------|----------|--------|
| Purpose | Teaching | Enforcement |
| Questions | "How?" "When?" "Should I?" | "Is this valid?" "Where's the issue?" |
| Answers | Patterns, guides, decisions | Violations, diagnostics, rules |
| Style | Educational, comprehensive | Direct, precise, strict |
| Typical Output | Code examples, best practices | Specific violations with locations |

**The Golden Rule**:
- **Maxwell teaches you what to build**
- **Smith validates that you built it right**

Use both agents together for the best results.

