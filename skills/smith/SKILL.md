---
name: smith
description: Swift architecture validation, code analysis, and build health coordinator. Routes questions to maxwell (discoveries), sosumi (Apple docs), and scully (package docs) for comprehensive development guidance.
tags:
  - "Swift architecture"
  - "validation"
  - "build"
  - "architecture"
  - "code analysis"
triggers:
  - "Smith"
  - "smith-validation"
  - "smith dependencies"
  - "code review"
  - "xcodebuild"
  - "swift build"
  - "build failed"
  - "build hang"
  - "build stuck"
  - "compilation error"
  - "type inference"
  - "circular dependency"
  - "TCA reducer"
  - "@Reducer"
  - "xcworkspace"
  - "workspace"
  - "architecture validation"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
version: "3.0.0"
author: "Claude Code Skill - Smith Architecture"
---

# Smith Skill - Auto-Trigger & Ecosystem Routing

## What This Skill Is

This is the **Smith SKILL** (not the Smith agent). It's designed for:
- ✅ **Auto-trigger** on build commands (xcodebuild, swift build, etc.)
- ✅ **Other ecosystems** (beyond Claude, e.g., Codex, VS Code extensions)
- ✅ **Routing guidance** - tells you which skill/agent to ask

## What This Skill Does NOT Do

This skill does NOT:
- ❌ Have built-in knowledge
- ❌ Call subagents (only agents can do that)
- ❌ Provide detailed analysis

## What This Skill Provides

This skill gives you:
- ✅ Quick routing to the right resource
- ✅ Command suggestions (smith CLI)
- ✅ "Ask @maxwell" style guidance

## What Smith DOES Provide

Smith provides:
- ✅ Code analysis via `smith` CLI commands
- ✅ Build diagnostics and validation
- ✅ Interpretation of validation results
- ✅ Routing questions to appropriate knowledge sources

## How Smith Routes Questions

**Smith routes to specialized skills based on natural triggers:**

| Question Type | Auto-Triggers | Or Use |
|--------------|---------------|--------|
| Swift patterns, TCA | @maxwell (auto) | `@maxwell` explicitly |
| Apple APIs, WWDC | @sosumi (auto) | `@sosumi` explicitly |
| Package documentation | @scully (auto) | `@scully` explicitly |
| TCA validation | - | `smith validate --tca` (uses smith-validation CLI) |
| TCA performance | - | `smith trace` (uses smith-tca-trace CLI) |
| Build analysis | smith-skill suggests | `smith CLI` commands |

**Complete Ecosystem:**
- **4 Skills**: smith, maxwell, sosumi, scully (auto-trigger)
- **2 Agents**: smith, maxwell (can be called via @name)
- **Pure CLI Tools**: smith-validation, smith-tca-trace, etc. (used by smith-CLI)

## When to Use Smith

✅ **Use Smith for:**
- Code structure validation: `@smith validate my code`
- Build diagnostics: `@smith why is my build hanging?`
- Project analysis: `smith analyze /path/to/project`
- Interpreting validation results

❌ **DON'T ask Smith for knowledge:**
- "How do I implement TCA patterns?" → Ask `@maxwell` instead
- "What's the Apple recommended approach?" → Ask `@sosumi` instead
- "What does this package offer?" → Ask `@scully` instead

**Smith will route you to the right skill for knowledge questions.**

---

## Smith Agent vs Smith Skill

### **Use @smith (Agent) When:**
- You want detailed analysis
- You need coordination with multiple skills/agents
- You're in Claude and can invoke agents explicitly
- Example: `"@smith validate my TCA reducer architecture"`

### **Use Smith Skill When:**
- You want quick routing guidance
- You're in a non-Claude environment
- A build command auto-triggered this skill
- Example: Auto-triggered when you run `xcodebuild build...`

### **The Relationship:**
```
@smith (AGENT) can call subagents
└── Task(maxwell) for patterns
└── Uses smith CLI for analysis

smith (SKILL) provides routing
└── "Ask @maxwell for patterns"
└── "Use smith CLI for diagnostics"
```

---

## 🔧 Build Command Protocols

**CRITICAL**: When executing build commands, ALWAYS use the appropriate Smith tool.

### Command Routing Table

| Task | Smith CLI Command |
|------|-------------------|
| Project analysis | `smith dependencies /path/to/project` |
| Architecture validation | `smith validate --tca` |
| Comprehensive analysis | `smith analyze /path/to/project` |
| Build diagnostics | `smith diagnose` |

### Default Behavior Rules

1. **NEVER provide analysis without running smith** - always execute commands first
2. **NEVER assume results** - Smith tools must be invoked to get real data
3. **ALWAYS capture real output** - use smith CLI commands to get actual results
4. **ALWAYS report actual findings** - base statements on real command execution

### Examples

#### ✅ Correct Patterns

```bash
# Project structure analysis
smith dependencies /path/to/project

# Architecture validation
smith validate --tca

# Comprehensive project analysis
smith analyze /path/to/project

# Build diagnostics
smith diagnose
```

#### ❌ Anti-Patterns

```bash
# DON'T: Assume results without running commands
"Code appears healthy" (without running smith validate)

# DON'T: Fake analysis
"No issues detected" (without running smith commands)

# DON'T: Generic advice
"Try refactoring this" (without understanding actual project structure)
```

### Decision Tree

See [knowledge/TOOL-SELECTION-DECISION-TREE.md](knowledge/TOOL-SELECTION-DECISION-TREE.md) for comprehensive tool selection logic.
See [knowledge/BUILD-COMMAND-DEFAULTS.md](knowledge/BUILD-COMMAND-DEFAULTS.md) for command templates and scenarios.
