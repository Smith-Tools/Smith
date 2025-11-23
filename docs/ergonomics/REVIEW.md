# Smith Tools: Ergonomics & Architecture Review

## Executive Summary

Smith Tools is a **well-designed, multi-phase enforcement system** for Swift development. However, there are **critical ergonomic gaps** between the documented vision and practical user experience. This review identifies bottlenecks, consolidates learnings, and recommends improvements to the installation, usage, and tool concatenation workflows.

---

## 📊 Current State Analysis

### Architecture Quality: ⭐⭐⭐⭐⭐
- Clear separation of concerns (4 sift tools + validation + CLI)
- Well-defined responsibility boundaries
- Sophisticated tool integration (smith-core as foundation)
- Strong philosophical clarity (Smith as "construction police")

### Ergonomics Quality: ⭐⭐⭐☆☆
- **High cognitive load** on users for tool selection
- **Multiple entry points** with unclear decision logic
- **Installation complexity** (separate tools, skills, agents)
- **Documentation consistency** issues across guides

### Tool Concatenation: ⭐⭐⭐☆☆
- Tools designed for **piping** (sbsift, spmsift take stdin)
- No **unified output format** across all tools
- Unclear **sequencing requirements**
- Difficult to **compose tools in CI/CD**

---

## 🎯 Key Findings

### 1. **Entry Point Confusion**

Users face **5 conflicting entry paths**:

| Entry Point | When to Use? | Documented? | Works? |
|-------------|-------------|------------|--------|
| `./smith-install.sh --core` | Installation | ✅ Yes | ✅ Yes |
| `smith-cli detect` | Project analysis | ⚠️ Implicit | ⚠️ Limited |
| `smith validate --tca` | Code validation | ✅ Yes | ✅ Yes |
| `smith-tools-install.sh` | Full suite | ✅ Yes | ✅ Yes |
| `@smith agent` | Claude integration | ⚠️ Implicit | ⚠️ Manual setup |

**Problem**: New users don't know which to start with.

**Reality**: The "Workflow Guide" shows automatic keyword triggers that **don't actually work** (documented in AGENTIC_WORKFLOW.md).

---

### 2. **Installation Workflow Fragmentation**

**Current state**:
- `smith-install.sh` - Legacy approach (not referenced in deploy.sh)
- `smith-tools-install.sh` - Complete suite installer
- `deploy.sh` - Multi-repo deployment orchestrator
- `deploy-org.sh` - Organization-level deployment

**Problem**:
- Users can't tell which installer to use
- Installation order unclear when all four exist
- No "single source of truth" installation command

**Reality**:
```bash
# Current confusion:
./smith-install.sh --core        # What does this do?
./smith-tools-install.sh         # Or this?
./deploy.sh 1                    # Or this?
```

---

### 3. **Tool Concatenation Gaps**

Smith tools are designed to **pipe together**, but:

**What Works**:
- `swift build 2>&1 | smith-sbsift analyze`
- `swift package dump-package | smith-spmsift`

**What's Unclear**:
- Tool output formats differ (some JSON, some text)
- No documented **sequencing order** for multi-tool workflows
- No **data passing mechanism** between tools
- Xcode builds don't easily pipe through sbsift

**Example of confusion**:
```bash
# This works (documented):
swift build 2>&1 | smith-sbsift analyze

# But what about:
smith-spmsift show-dependencies | smith-sbsift analyze?  # Does this make sense?
```

---

### 4. **Agent Integration Unclear**

**Smith Agent Setup**:
- `smith.md` is in `Smith/agent/`
- Must be manually copied to `~/.claude/agents/smith.md`
- Or `smith-tools-install.sh` does it
- But `smith-install.sh` doesn't mention this

**Reality**: Users might not realize they need the agent, or get it installed incorrectly.

---

### 5. **Documentation Inconsistencies**

| Document | Claims | Reality |
|----------|--------|---------|
| WORKFLOW_GUIDE.md | Auto-triggers on keywords | Doesn't work (AGENTIC_WORKFLOW.md) |
| README.md | "Primary unified interface" | smith-cli is limited |
| SMITH_TOOLS_WORKFLOW_GUIDE.md | maxwell/sosumi triggers | Requires explicit commands |
| ARCHITECTURE.md | Clear lifecycle | Lifecycle isn't user-facing |

---

## 🔧 Root Cause Analysis

### Why These Gaps Exist

1. **Tool-Centric Design** → User-facing workflows unclear
   - Architecture assumes tools will be used directly
   - Doesn't account for "How do I start?" question

2. **Organic Growth** → Multiple installers, multiple guides
   - Each component added its own installation method
   - Guides written independently

3. **Aspirational Features** → Documented features don't work
   - Auto-trigger system was envisioned but unreliable
   - Documentation wasn't updated when approach changed

4. **Separation of Concerns** → Integration points hidden
   - Smith, Maxwell, Sosumi are separate
   - How they coordinate is unclear

---

## ✅ Recommended Improvements

### Priority 1: Single Installation Entry Point

**Current State**: 4 installation scripts
**Target State**: 1 clear entry point with options

```bash
# SINGLE COMMAND FOR EVERYTHING
./install.sh              # Install minimal core
./install.sh --complete   # Install everything
./install.sh --help       # Show options
```

**Implementation**:
- Rename `smith-tools-install.sh` → `install.sh` (primary)
- Archive/deprecate `smith-install.sh`
- Make `deploy.sh` internal-only (for developers)
- Update all documentation to reference `./install.sh`

### Priority 2: Clear Entry Point Decision Tree

**Create**: `.claude/GETTING_STARTED.md`

```markdown
# Getting Started with Smith Tools

## What do you want to do?

### "I'm setting up Smith Tools for the first time"
→ Run: ./install.sh --core

### "I need to validate my TCA code"
→ Use: smith validate --tca

### "My build is slow/hanging"
→ Use: swift build 2>&1 | smith-sbsift analyze

### "I need architectural patterns"
→ Use: maxwell search "topic"

### "I need Apple documentation"
→ Use: sosumi docs "framework"
```

### Priority 3: Standardized Tool Output Format

**Create**: `Smith/docs/TOOL_OUTPUT_FORMAT.md`

All tools should output compatible JSON:

```json
{
  "tool": "smith-sbsift",
  "version": "1.0.0",
  "timestamp": "2025-11-23T12:30:00Z",
  "status": "success|warning|error",
  "results": {
    "analysis": [...],
    "suggestions": [...]
  },
  "metadata": {
    "duration_ms": 1234,
    "file_count": 42
  }
}
```

### Priority 4: Documented Tool Concatenation Patterns

**Create**: `Smith/docs/TOOL_COMPOSITION.md`

```markdown
# Tool Composition Workflows

## Phase 1: Package Analysis
```bash
swift package dump-package | smith-spmsift analyze --format json
```

## Phase 2: Build Monitoring
```bash
swift build 2>&1 | smith-sbsift analyze --hang-detection
```

## Phase 3: Architecture Validation
```bash
smith validate --tca --level standard
```

## Complete Workflow
```bash
# 1. Check dependencies
swift package dump-package | smith-spmsift analyze

# 2. Monitor build
swift build 2>&1 | smith-sbsift monitor

# 3. Validate architecture
smith validate --tca

# 4. Get recovery strategy (if needed)
smith-xcsift diagnose
```

## Data Passing Between Tools
Tools coordinate via:
- **File system**: Shared analysis cache
- **JSON piping**: Compatible output format
- **Exit codes**: Indicate success/failure
- **Environment**: SMITH_ANALYSIS_CACHE env var
```

### Priority 5: Agent Registration Clarity

**Update**: `smith-tools-install.sh`

Add explicit agent registration step:

```bash
# Register Smith agent with Claude
register_smith_agent() {
    info "Registering @smith agent with Claude Code..."
    local agent_src="$SMITH_ROOT/Smith/agent/smith.md"
    local agent_dst="$HOME/.claude/agents/smith.md"

    mkdir -p "$(dirname "$agent_dst")"
    cp "$agent_src" "$agent_dst"

    success "Agent registered at: $agent_dst"
    info "Use @smith in Claude Code for enforcement validation"
}
```

And add explicit success message:
```
✅ Smith Tools Installation Complete!

What's installed:
  • smith-cli (CLI orchestrator)
  • maxwell (Pattern expert)
  • sosumi (Apple documentation)
  • smith-validation (TCA enforcement)
  • @smith agent (Claude Code integration)

Quick start:
  smith-cli detect              # Analyze your project
  maxwell search "TCA"          # Get patterns
  smith validate --tca          # Validate code
  @smith                        # In Claude Code
```

### Priority 6: Smith CLI Capabilities Documentation

**Create**: `Smith/docs/SMITH_CLI_REFERENCE.md`

```markdown
# smith-cli Command Reference

smith-cli is the unified entry point for all Smith analysis.

## Installation Detection
smith-cli detect              # Auto-detect project type and tools
smith-cli status              # Check installed tools and versions

## Project Analysis
smith-cli analyze             # Comprehensive project analysis
smith-cli analyze --level critical  # Strict analysis

## Validation
smith-cli validate            # Full validation suite
smith-cli validate --tca      # TCA-specific rules
smith-cli validate --focus <rule>  # Specific rule validation

## Build Analysis
smith-cli build-diagnose      # Diagnose build issues
smith-cli build-fix           # Get recovery strategies
smith-cli monitor-build       # Monitor build in progress

## Environment
smith-cli environment         # Show development environment details
smith-cli tips                # Daily tips and patterns
```

---

## 🌐 Architecture Improvements

### 1. **Consolidate Installation**

```
BEFORE:
smith-install.sh (legacy)
smith-tools-install.sh
deploy.sh
deploy-org.sh

AFTER:
install.sh (primary)
  ├─ install.sh --core (minimal)
  ├─ install.sh --complete (full suite)
  ├─ install.sh --components maxwell,sosumi
  └─ install.sh --org (organization deployment)

deploy.sh → internal use only (for developers)
```

### 2. **Create Metadata Layer**

Add `Smith/manifest.json`:

```json
{
  "version": "1.0.0",
  "components": {
    "smith-cli": {
      "description": "Unified CLI orchestrator",
      "entry_point": "smith-cli",
      "requirements": ["smith-core"],
      "auto_trigger": false
    },
    "maxwell": {
      "description": "Pattern expertise coordinator",
      "entry_point": "maxwell search",
      "requirements": [],
      "auto_trigger": true
    },
    "smith-validation": {
      "description": "TCA enforcement engine",
      "entry_point": "smith-validation .",
      "requirements": ["smith-core"],
      "auto_trigger": false
    }
  },
  "entry_points": {
    "first_time": "./install.sh --core",
    "project_analysis": "smith-cli detect",
    "code_validation": "smith validate --tca",
    "architecture_help": "@smith in Claude Code"
  }
}
```

### 3. **Unified Configuration**

Create `~/.smith/config.json`:

```json
{
  "installation_method": "homebrew",
  "components": ["smith-cli", "maxwell", "smith-validation"],
  "validation_level": "standard",
  "cache_location": "~/.smith/cache",
  "output_format": "json",
  "auto_updates": true
}
```

---

## 📋 Specific Recommendations by Area

### Installation & Setup

1. **Consolidate to single `install.sh`**
   - Remove `smith-install.sh`
   - Make `smith-tools-install.sh` the primary (rename it)
   - Add clear progress indicators
   - Show what's being installed at each step

2. **Post-installation verification**
   ```bash
   # After install, run:
   smith-cli status
   # Shows: ✅ smith-cli, ✅ maxwell, ✅ smith-validation, ✅ @smith
   ```

3. **Quick verification command**
   ```bash
   smith-cli verify-installation
   # Tests each component with a simple command
   ```

### Usage & Discovery

1. **In-tool help system**
   ```bash
   smith --help              # Shows common commands
   smith --help validate     # Shows validate subcommand
   smith examples validate   # Shows example usage
   ```

2. **Interactive setup mode**
   ```bash
   smith init
   # Guided setup for first time users
   # Asks: Project type? Validation strictness? Output format?
   ```

3. **Command discovery**
   ```bash
   smith suggest "slow build"
   # Suggests: Use smith-sbsift or smith-xcsift

   smith suggest "TCA validation"
   # Suggests: Use smith validate --tca or @smith
   ```

### Tool Composition

1. **Documented workflows in shell scripts**
   ```bash
   smith-workflow analyze-build
   # Runs: spmsift → sbsift → validation sequence

   smith-workflow quick-check
   # Runs: detect → status → validate
   ```

2. **CLI presets**
   ```bash
   smith validate --preset critical      # Strict validation
   smith validate --preset standard      # Normal validation
   smith validate --preset learning      # Verbose with explanations
   ```

3. **Integration documentation**
   - Document what each tool outputs
   - Show tool compatibility matrix
   - Provide CI/CD integration examples

---

## 🎯 Implementation Roadmap

### Phase 1: Documentation (Low Risk, High Impact)
- [ ] Create GETTING_STARTED.md (entry point guide)
- [ ] Create TOOL_COMPOSITION.md (concatenation patterns)
- [ ] Update README.md (remove aspirational claims)
- [ ] Fix WORKFLOW_GUIDE.md (align with reality)
- [ ] Create smith-cli reference guide

**Timeline**: 1-2 days
**Risk**: None (documentation only)

### Phase 2: Installation Consolidation (Medium Risk)
- [ ] Create unified install.sh
- [ ] Add progress indicators
- [ ] Add post-install verification
- [ ] Deprecate old installers
- [ ] Update all references

**Timeline**: 2-3 days
**Risk**: Installer could break existing workflows (mitigate with fallback)

### Phase 3: Tool Enhancement (Medium Risk)
- [ ] Add manifest.json for tool metadata
- [ ] Standardize output formats across tools
- [ ] Add help system to smith-cli
- [ ] Create command suggestions system

**Timeline**: 3-5 days
**Risk**: Requires changes to multiple tools

### Phase 4: Integration Examples (Low Risk)
- [ ] CI/CD integration examples
- [ ] shell workflow scripts
- [ ] Claude Code workflow examples
- [ ] Team deployment guide

**Timeline**: 1-2 days
**Risk**: None (documentation and examples)

---

## 📊 Comparison: Current vs. Recommended

### User Flow: New Developer

**CURRENT PATH**:
```
User: "How do I use Smith Tools?"
  ↓
Read README.md (confusing, multiple entry points)
  ↓
Run smith-cli detect? or ./smith-install.sh? or ./smith-tools-install.sh?
  ↓
Not sure which one to use
  ↓
Tries all three, gets confused about what each does
  ↓
Eventually gets it working but with wrong expectations
```

**RECOMMENDED PATH**:
```
User: "How do I use Smith Tools?"
  ↓
Read GETTING_STARTED.md (clear decision tree)
  ↓
"I'm setting up for the first time"
  ↓
Run: ./install.sh --core
  ↓
Installer shows progress, explains what's being installed
  ↓
smith-cli status shows: ✅ All components ready
  ↓
Follow next steps from GETTING_STARTED.md
```

### Validation Workflow

**CURRENT PATH**:
```
Developer: "Is my TCA code correct?"
  ↓
Run smith validate --tca? Or use @smith agent?
  ↓
smith validate --tca gives output
  ↓
Unclear what the output means or how to fix it
  ↓
Goes to @smith agent in Claude Code
  ↓
Two different feedback mechanisms
```

**RECOMMENDED PATH**:
```
Developer: "Is my TCA code correct?"
  ↓
Option A: Command line → smith validate --tca --help
Option B: IDE → @smith validate my code
  ↓
Consistent output format and explanations
  ↓
Clear suggestions for fixes
  ↓
Examples of correct code
```

---

## 🚀 Quick Wins (Do These First)

### 1. **Create `.claude/GETTING_STARTED.md`** (30 min)
   - Simple decision tree
   - Links to appropriate tools/guides
   - "I'm setting up" vs "I'm validating" vs "I'm debugging"

### 2. **Update README.md** (30 min)
   - Remove claims about auto-triggers
   - Point to GETTING_STARTED.md
   - Clear statement: "Use ./install.sh or smith-tools-install.sh"
   - Link to workflow guides

### 3. **Create Smith CLI Reference** (1 hour)
   - All commands
   - Examples for each command
   - When to use each variant

### 4. **Add Version/Status Commands** (1-2 hours)
   ```bash
   smith-cli status          # Shows installed tools
   smith-cli version         # Shows versions
   smith-cli verify          # Tests each tool
   ```

### 5. **Fix Installation Script Output** (1-2 hours)
   - Add progress indicators
   - Show what's being installed
   - Clear success/failure messages
   - Post-install guidance

---

## 🎓 Key Takeaways

### Strengths
1. ✅ **Architecture is excellent** - Clear separation, well-designed
2. ✅ **Tools are sophisticated** - Intelligent analysis, good features
3. ✅ **Documentation is comprehensive** - Detailed guides exist
4. ✅ **Enforcement is strong** - Clear rules, good validation

### Gaps
1. ❌ **Entry point clarity** - Too many ways to start
2. ❌ **Installation experience** - Multiple scripts, unclear which to use
3. ❌ **Documentation alignment** - Reality doesn't match claims
4. ❌ **Tool integration** - How to compose tools is unclear

### Path Forward
- Single, clear entry point (install.sh)
- User-facing documentation (GETTING_STARTED.md)
- Reality-based workflow guides (remove auto-trigger claims)
- Tool integration documentation (composition patterns)

---

## Conclusion

Smith Tools is a **powerful, well-architected system** that suffers from **poor ergonomics and unclear workflows**. The gaps aren't technical—they're about helping users understand **which tool to use when** and **how tools work together**.

**The good news**: These are all fixable with documentation, small UX improvements, and installation consolidation. No major architectural changes needed.

**The recommendation**: Start with documentation (GETTING_STARTED.md, fix README.md), then move to installation consolidation and tool enhancement.

