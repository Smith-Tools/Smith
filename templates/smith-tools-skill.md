---
name: smith-tools-project-integration
description: "Project-level configuration for Smith Tools. When working on TCA, architecture validation, or build issues: use @smith for enforcement, @maxwell for patterns, sosumi for Apple docs. Auto-triggers when: analyzing @Reducer, discussing monolithic features, validating composition, or reviewing architecture."
---

# Smith Tools Project Integration

Project-level configuration to enable Smith Tools suggestions and direct access in Claude Code.

## Available Tools

### @smith - Enforcement Agent
**Purpose**: Strict architectural validation
**When to use**:
- Validating TCA reducer composition
- Checking Rule 1.1-1.5 compliance
- Detecting architectural violations
- Code review validation
- Build health diagnostics

**Example usage**:
```
@smith validate my TCA reducer
Check if this monolithic feature should be split
```

### @maxwell - Pattern Expertise
**Purpose**: Architectural patterns and best practices
**When to use**:
- Learning TCA patterns
- Getting implementation guidance
- Exploring architectural decisions
- Finding examples of complex patterns
- Understanding composition strategies

**Example usage**:
```
@maxwell search "reducer composition"
Show me examples of properly structured features
```

### sosumi - Apple Documentation
**Purpose**: Apple frameworks and WWDC sessions
**When to use**:
- SwiftUI implementation questions
- Core Data patterns
- Concurrency best practices
- Performance optimization
- Apple framework guidance

**Example usage**:
```
sosumi docs "SwiftUI navigation"
sosumi session "10043"  # WWDC performance talk
```

### smith-cli (Command Line)
**Purpose**: Programmatic validation and analysis
**When to use**:
- CI/CD integration
- Batch validation
- Automated analysis
- Build monitoring
- Dependency analysis

**Example usage**:
```bash
smith-cli detect              # Project analysis
smith validate --tca          # TCA validation
smith-sbsift analyze          # Build analysis
```

---

## How This Works

Claude will automatically suggest using Smith Tools when you:

1. **Ask about TCA architecture**
   - Monolithic reducer detection
   - Composition strategies
   - Dependency injection patterns
   - State management

2. **Use TCA-related keywords**
   - `@Reducer`
   - `@ObservableState`
   - `@Shared`
   - `CombineReducers`
   - `Reducer` composition

3. **Request code validation**
   - Architecture review
   - Anti-pattern detection
   - Testability assessment
   - Coupling analysis

4. **Ask for patterns or guidance**
   - Implementation examples
   - Best practices
   - Alternative approaches
   - Feature extraction

---

## Usage Examples

### Example 1: Code Review
```
User: "Here's my UserProfileReducer. Is it too monolithic?"

Claude: "I can analyze this with Smith Tools. Let me validate against TCA composition rules..."

@smith validate my code
```

### Example 2: Learning Patterns
```
User: "How do I properly split a large reducer?"

Claude: "Let me show you some patterns for reducer composition..."

@maxwell search "reducer composition"
```

### Example 3: Framework Questions
```
User: "How do I handle SwiftUI navigation with TCA?"

Claude: "Let me search Apple's documentation..."

sosumi docs "SwiftUI navigation"
@maxwell search "TCA navigation"
```

### Example 4: Build Issues
```
User: "My build is very slow. What's the bottleneck?"

Claude: "Let me analyze your build with Smith Tools..."

swift build 2>&1 | smith-sbsift analyze --hang-detection
```

---

## How to Enable This Skill

### For Your Own Projects (5-second setup)

1. Copy this file to your project:
   ```bash
   mkdir -p .claude/skills
   cp smith-tools-skill.md .claude/skills/smith-tools.md
   ```

2. No additional configuration needed - Claude will auto-detect and use it

3. Start developing - Claude will suggest Smith Tools when appropriate

### For Teams (Distribution)

1. Add `.claude/skills/smith-tools.md` to your team repository
2. All team members get the skill automatically
3. Consistent Smith Tools usage across the team

---

## Explicit vs. Automatic

### Automatic (This Skill)
Claude suggests Smith Tools when it detects they're relevant.
- Requires no action from you
- Context-aware (Claude decides if applicable)
- Respects your preferences

### Explicit (Manual Invocation)
You explicitly request Smith Tools:
```
@smith validate my code
@maxwell search "pattern"
smith validate --tca
```

- Always available
- Guaranteed to invoke
- Good for specific, direct requests

**Recommendation**: Use both. Let Claude auto-suggest when relevant, and explicitly invoke for specific needs.

---

## Customization

### To Modify Trigger Conditions

Edit the `description` field at the top:

```markdown
description: "Add your custom trigger conditions here. When to use Smith Tools in your project."
```

### To Change Tool Preferences

Edit the "Available Tools" section to focus on what your team uses most.

### To Add Team-Specific Guidance

Add a new section with your team's architectural standards or patterns.

---

## Troubleshooting

### Smith Tools not suggesting?

1. Check file is in `.claude/skills/smith-tools.md`
2. Restart Claude Code or start a new session
3. Ask explicitly: `@smith help` or `@maxwell help`

### Want explicit shortcuts?

Add to `.claude/commands/` directory:

```markdown
# smith-check.md
---
description: "Quick architecture validation"
---

!smith validate --tca
```

Then use: `/smith-check`

---

## How This Complements the Main Smith Skill

**Main Smith Skill** (`Smith/skills/skill-smith/`):
- Comprehensive pattern library (TCA, testing, concurrency, platforms)
- Architectural guidance and decision trees
- Auto-loads based on keywords and context
- Used for learning and implementation guidance

**This Project File** (`.claude/skills/smith-tools-project.md`):
- Project-level configuration
- Clarifies "use @smith, @maxwell, sosumi for our needs"
- Helps Claude understand your project context
- Works alongside the main skill
- **Does NOT replace** the main skill

**They work together**: Main skill provides knowledge, project file provides context.

---

## Related Documentation

- **Smith Ergonomics**: See Smith/docs/ergonomics/
- **Main Smith Skill**: See Smith/skills/skill-smith/skill/SKILL.md
- **Triggering Guide**: See Smith/docs/ergonomics/TRIGGERING.md
- **Getting Started**: See Smith/docs/ergonomics/GETTING_STARTED.md

---

**Last Updated**: November 23, 2025
**Status**: Complementary project-level configuration file
**Purpose**: Enable context-aware Smith Tools suggestions in your project
