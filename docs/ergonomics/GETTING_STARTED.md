# Getting Started with Smith Tools

A clear, decision-based entry point for all Smith Tools users.

## What Do You Want To Do?

### 🚀 "I'm setting up Smith Tools for the first time"

```bash
# Option 1: Minimal core setup (recommended for most users)
./install.sh --core

# Option 2: Complete suite with all tools
./install.sh --complete

# Option 3: Specific components
./install.sh --components maxwell,smith-validation
```

**What gets installed:**
- `smith-cli` - Unified command-line interface
- `maxwell` - Architectural pattern expertise
- `smith-validation` - TCA validation engine
- `sosumi` - Apple documentation search
- `@smith` agent - Claude Code integration

**Next step:** Run `smith-cli status` to verify installation

---

### 🔍 "I need to validate my TCA code"

**Quick check:**
```bash
smith validate --tca
```

**Detailed analysis:**
```bash
smith validate --tca --level comprehensive
```

**In Claude Code:**
```
@smith validate my TCA reducer
```

**What Smith checks:**
- ✅ Rule 1.1: Monolithic features (>15 properties)
- ✅ Rule 1.2: Proper dependency injection
- ✅ Rule 1.3: Code duplication
- ✅ Rule 1.4: Clear organization
- ✅ Rule 1.5: Tightly coupled state

---

### 🏗️ "I need architectural patterns"

**Search for patterns:**
```bash
maxwell search "TCA navigation"
maxwell search "dependency injection"
```

**In Claude Code:**
```
@maxwell search "reducer composition"
Show me examples of TCA patterns
```

**What Maxwell provides:**
- Pattern examples
- Implementation guidance
- Architectural decisions
- Best practices

---

### 🎯 "I want Claude to suggest Smith Tools in my project"

**Setup (5 seconds):**
```bash
# In your Swift project root
mkdir -p .claude/skills
cp Smith/templates/smith-tools-skill.md .claude/skills/smith-tools-project.md
```

**What this does:**
- Claude reads the skill description when you discuss TCA, architecture, or build issues
- Claude suggests using `@smith`, `@maxwell`, or `sosumi` when relevant
- You decide whether to accept the suggestion
- Works automatically in future sessions
- **Does NOT replace** the main Smith skill - complements it for project-level guidance

**Two ways to trigger:**

1. **Explicit** (always works, no setup needed):
   ```
   @smith validate my code
   @maxwell search "pattern"
   sosumi docs "SwiftUI"
   ```

2. **Suggestions** (with project config file, Claude offers help):
   ```
   You: "Is my reducer too big?"
   Claude: "I can analyze this with @smith for TCA enforcement..."
   ```

**See**: `TRIGGERING.md` for complete details on how triggering works

**Note**: This complements the main Smith skill (`Smith/skills/skill-smith/`). The project file helps Claude understand YOUR project context, while the main skill provides the patterns and implementation details.

---

### 📚 "I need Apple documentation"

**Search Apple docs:**
```bash
sosumi docs "SwiftUI"
sosumi docs "Core Data"
```

**Search WWDC sessions:**
```bash
sosumi session "10190"
sosumi wwdc "SwiftUI" --year 2023
```

**What Sosumi provides:**
- Apple developer documentation
- WWDC session references
- Framework guidance
- Apple best practices

---

### 🐛 "My build is slow or hanging"

**Quick diagnosis:**
```bash
swift build 2>&1 | smith-sbsift analyze
```

**Detailed hang detection:**
```bash
swift build 2>&1 | smith-sbsift analyze --hang-detection
```

**Xcode-specific analysis:**
```bash
smith-xcsift diagnose
smith-xcsift rebuild --smart-strategy
```

**What Smith will show you:**
- Build bottlenecks
- Type inference problems
- Compilation time per file
- Hang detection with root causes
- Recovery strategies

---

### 📦 "I need to check my package dependencies"

**Analyze SPM structure:**
```bash
smith-spmsift show-dependencies
smith-spmsift show-dependencies --format json
```

**Check for issues:**
```bash
smith-spmsift check-conflicts
```

**What Smith checks:**
- Circular dependencies
- Version conflicts
- Branch dependencies (anti-patterns)
- Dependency complexity

---

### 🎯 "I'm not sure what to do"

**Get project analysis:**
```bash
smith-cli detect          # Detect project type
smith-cli status          # Show tools and versions
smith-cli analyze         # Comprehensive analysis
```

**Get help on any command:**
```bash
smith --help
smith validate --help
smith-cli detect --help
```

---

## Installation Details

### Location Check

Smith Tools installs to:
- **CLI tools**: `/usr/local/bin/` (via Homebrew)
- **Agent**: `~/.claude/agents/smith.md`
- **Cache**: `~/.smith/cache/` (created on first use)

### Verification

After installation, verify everything works:

```bash
# Check all tools are installed
smith-cli status

# You should see:
# ✅ smith-cli v1.0.7
# ✅ maxwell v1.2.1
# ✅ smith-validation v1.0.5
# ✅ @smith agent registered
```

### Troubleshooting

**Command not found:**
```bash
# Check if installation completed
ls /usr/local/bin/smith*

# If missing, reinstall:
./install.sh --core
```

**Agent not working:**
```bash
# Check agent location
ls ~/.claude/agents/smith.md

# If missing, reinstall:
./install.sh --core
```

---

## Quick Command Reference

| Task | Command |
|------|---------|
| Verify installation | `smith-cli status` |
| Analyze project | `smith-cli detect` |
| Validate TCA code | `smith validate --tca` |
| Diagnose build | `smith-sbsift analyze` |
| Check dependencies | `smith-spmsift show-dependencies` |
| Get patterns | `maxwell search "topic"` |
| Get Apple docs | `sosumi docs "framework"` |
| Claude Code help | `@smith` |

---

## Next Steps

1. **Run installation:**
   ```bash
   ./install.sh --core
   ```

2. **Verify it works:**
   ```bash
   smith-cli status
   ```

3. **Try your first command:**
   ```bash
   smith-cli detect
   ```

4. **Read appropriate guide:**
   - For validation: See VALIDATION_GUIDE.md
   - For tools: See TOOL_COMPOSITION.md
   - For architecture: See ARCHITECTURE.md

---

## Need More Help?

- **Installation issues** → Check TROUBLESHOOTING.md
- **Workflow questions** → Check SMITH_TOOLS_WORKFLOW_GUIDE.md
- **Architecture decisions** → Read ARCHITECTURE.md
- **Tool details** → Check TOOL_REFERENCE.md

