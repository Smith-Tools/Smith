# Smith Tools: Realistic Triggering Guide

How to actually trigger Smith Tools in practice (no magic, no auto-surprises).

---

## ⚠️ Reality Check

**Automatic keyword-based triggering doesn't work reliably.**

This was attempted in earlier designs but is fundamentally unreliable:
- Keywords appear in comments, unrelated code, documentation
- Context matters (same keyword = different meaning in different contexts)
- False positives and false negatives are inevitable

**Solution**: Two practical, reliable approaches below.

---

## 🎯 Approach 1: Explicit Invocation (Default)

User explicitly requests Smith Tools.

### In Claude Code

```
@smith validate my TCA reducer
Check if my reducer violates composition rules
```

or

```
@maxwell search "reducer composition"
Show me patterns for splitting monolithic features
```

**Pros**:
- ✅ Reliable - always works as intended
- ✅ User-controlled - you decide when
- ✅ No surprises - clear what's happening
- ✅ Works anywhere - no project setup needed

**Cons**:
- ❌ Requires remembering to ask
- ❌ No ambient awareness

**Use this when**:
- You know exactly what you need
- You want guaranteed results
- You're in a new or unfamiliar project
- You need specific, direct help

### At Command Line

```bash
smith-cli validate --tca
smith-cli detect
smith-sbsift analyze
maxwell search "TCA patterns"
```

**When to use**: Automation, CI/CD, scripting, batch operations.

---

## 🔧 Approach 2: Project-Level Configuration (Enhanced)

Optimize your project to work better with Smith Tools.

### How It Works

1. **You add a Skill file** to your project: `.claude/skills/smith-tools.md`
2. **Claude reads it** on startup and in each session
3. **Claude uses the skill description** to decide when Smith Tools are relevant
4. **You work normally** - Claude suggests tools when appropriate

### Setup (5 seconds)

```bash
# In your Swift project root
mkdir -p .claude/skills
cp Smith/templates/smith-tools-skill.md .claude/skills/smith-tools.md
```

**That's it.** No other changes needed.

### What Happens

**Claude's perspective**:
```
User is discussing TCA reducers...
I have a "smith-tools-integration" skill
Its description mentions @Reducer, composition, monolithic features
This matches the user's context
I'll suggest: "Would you like me to use Smith Tools to validate this?"
```

**Pros**:
- ✅ Context-aware (Claude decides based on conversation)
- ✅ Automatic suggestions (no prompting needed)
- ✅ Project-specific (only in projects that opt-in)
- ✅ Team-friendly (shared via git)
- ✅ Drop-in template (copy one file)

**Cons**:
- ❌ Requires project setup
- ❌ Suggestions, not automatic invocation (Claude asks first)
- ⚠️ Depends on Claude's context understanding

**Use this when**:
- You have a team working on Swift/TCA projects
- You want consistent tool usage
- You want "smart suggestions" but control over invocation
- You want a repeatable setup

### File Structure

```
your-project/
├── .claude/
│   └── skills/
│       └── smith-tools.md          # ← Copy here
├── .claude/settings.local.json     # Already configured
└── your-code/
```

---

## 🤝 Combination Approach (Recommended)

Use **both** for maximum flexibility.

### Default: Explicit Invocation
Users can always explicitly ask:
```
@smith validate my code
@maxwell search "pattern"
```

### Enhanced: Project Config (Optional)
Projects can add skill file for suggestions:
```
mkdir -p .claude/skills
cp Smith/templates/smith-tools-skill.md .claude/skills/smith-tools.md
```

### Real-World Example

```
Team A (No setup):
  Developer: "Check my TCA code"
  Claude: "I don't have Smith Tools context"
  Developer: "@smith validate my code"
  Claude: ✅ Validates

Team B (With skill file):
  Developer: "Check my TCA code"
  Claude: "I have a Smith Tools skill! Let me suggest validation"
  Claude: "Would you like me to use @smith?"
  Developer: "Yes"
  Claude: ✅ Validates
```

**Team B gets better UX with 5 seconds of setup.**

---

## 🚫 What DOESN'T Work (& Why)

### ❌ Auto-invocation on Keywords
```
"My @Reducer is too big"
→ Does NOT automatically invoke @smith
```
**Why**: Keywords appear everywhere (comments, docs, examples). Leads to false positives.

### ❌ Ambient Triggering
```
"I'm working on TCA today"
→ Does NOT continuously offer Smith Tools
```
**Why**: Context is fragmented across messages. Leads to spam and noise.

### ❌ Implicit Understanding
```
"Is my code good?"
→ Does NOT automatically know you mean architectural validation
```
**Why**: "Good" is ambiguous. Could mean performance, readability, etc.

### ❌ One-Shot Discovery
```
First time mentioning TCA
→ Does NOT remember to suggest Smith Tools for the rest of the session
```
**Why**: Each context window is independent.

---

## 📋 Decision Tree: Choose Your Approach

```
Do you know you need Smith Tools?
├─ YES → Use Explicit Invocation
│   └─ @smith validate my code
│   └─ @maxwell search "pattern"
│   └─ smith validate --tca (CLI)
│
└─ NO → Want Smart Suggestions?
    ├─ Just this session → Explicit when needed
    │   └─ Works, but requires remembering
    │
    └─ Ongoing across sessions → Add Skill File
        └─ Setup: cp smith-tools-skill.md .claude/skills/smith-tools.md
        └─ Get: Context-aware suggestions
        └─ Control: You decide whether to accept
```

---

## 🛠️ Advanced: Custom Triggers

### Option 1: Project-Specific Commands

Create `.claude/commands/smith-check.md`:

```markdown
---
description: "Validate TCA architecture quickly"
---

!smith validate --tca
```

Then use: `/smith-check`

### Option 2: Enhanced Skill Description

Edit `.claude/skills/smith-tools.md` to match your project:

```markdown
---
name: smith-tools-integration
description: "For our project: validates TCA reducers, checks monolithic features, ensures proper composition. Use when: reviewing TCA code, extracting features, designing reducers, or implementing complex patterns."
---
```

### Option 3: Multiple Skills

Create different skills for different needs:
- `.claude/skills/tca-validation.md` - Strict enforcement
- `.claude/skills/tca-learning.md` - Pattern discovery
- `.claude/skills/build-optimization.md` - Performance

---

## 📖 Quick Reference

### You Want → Do This

| Situation | Action | Command |
|-----------|--------|---------|
| Quick validation now | Explicit | `@smith validate my code` |
| Build analysis now | Explicit | `swift build 2>&1 \| smith-sbsift analyze` |
| Patterns & examples | Explicit | `@maxwell search "TCA"` |
| Smart suggestions ongoing | Setup skill | `cp smith-tools-skill.md .claude/skills/` |
| Team consistency | Add to git | Commit `.claude/skills/smith-tools.md` |
| Custom shortcut | Create command | Create `.claude/commands/my-command.md` |
| CLI validation | CLI | `smith validate --tca` |

---

## ✅ What Works Best

### For Individual Developers
**Explicit invocation** - No setup, ask when needed
```
@smith validate my code
```

### For Small Teams (2-5 people)
**Explicit + optional skill** - Choose per project
```
# Project wants suggestions?
cp smith-tools-skill.md .claude/skills/smith-tools.md
```

### For Growing Teams
**Skill + commands** - Standardized approach
```
.claude/skills/smith-tools.md        # Shared
.claude/commands/smith-check.md      # Team shortcuts
```

### For Large Organizations
**Skill + settings + commands** - Full setup
```
.claude/skills/                      # Multiple skills
.claude/commands/                    # Custom shortcuts
.claude/settings.json                # Team permissions
CLAUDE.md                            # Shared guidelines
```

---

## 🎓 Summary

### The Myth
"Automatic triggering on keywords"

### The Reality
1. **Explicit invocation** - Always works, user-controlled
2. **Project skill files** - Provides smart suggestions, requires 5-second setup
3. **Combination** - Best UX, flexible, no magic

### The Recommendation
- **Start with**: Explicit (`@smith`, `@maxwell`)
- **Add if you want**: Project skill file for suggestions
- **Never expect**: Automatic invocation without setup

### The Principle
**No surprises. Clear control. Explicit > implicit.**

Users always understand exactly when and why Smith Tools are being used.

---

## 📞 Related Documentation

- **Drop-in template**: `Smith/templates/smith-tools-skill.md`
- **Usage guide**: `Smith/docs/ergonomics/GETTING_STARTED.md`
- **Complete reference**: `Smith/docs/ergonomics/INDEX.md`
- **Architecture**: `Smith/ARCHITECTURE.md`

