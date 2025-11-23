# Smith Tools: Action Items & Implementation Guide

Concrete next steps for improving Smith Tools based on ergonomics review.

---

## 📋 Quick Wins (Do These First)

### ✅ 1. Link to Ergonomics Documentation

**What**: Add reference to new documentation
**Where**: Main README.md and Smith/START-HERE.md
**Time**: 5 minutes

**Add to README.md**:
```markdown
## 📖 Getting Started Guides

- **New to Smith Tools?** → See [GETTING_STARTED.md](Smith/docs/ergonomics/GETTING_STARTED.md)
- **Setting up?** → See [INSTALLATION_GUIDE.md](Smith/docs/ergonomics/INSTALLATION_GUIDE.md)
- **Integrating tools?** → See [TOOL_COMPOSITION.md](Smith/docs/ergonomics/TOOL_COMPOSITION.md)
- **Strategic overview?** → See [REVIEW.md](Smith/docs/ergonomics/REVIEW.md)
```

### ✅ 2. Update Installation Script Output

**What**: Better messages during installation
**Where**: `smith-tools-install.sh`
**Time**: 30 minutes

**Current**:
```
Installing Smith Tools...
```

**Better**:
```
🚀 Smith Tools Installation

Phase 1: Installing smith-cli (orchestrator)
  ✅ smith-cli installed

Phase 2: Installing maxwell (pattern expert)
  ✅ maxwell installed

Phase 3: Installing smith-validation (TCA enforcement)
  ✅ smith-validation installed

Phase 4: Registering @smith agent
  ✅ Agent registered at ~/.claude/agents/smith.md

Installation Complete! ✨

What's Next:
  1. Verify: smith-cli status
  2. Analyze: smith-cli detect
  3. Learn: See Smith/docs/ergonomics/GETTING_STARTED.md
```

### ✅ 3. Create smith-cli Verification Command

**What**: Add `smith-cli verify` command
**Where**: `Smith/cli/` source
**Time**: 1-2 hours

**Usage**:
```bash
smith-cli verify
```

**Output**:
```
Smith Tools Verification
========================

Tools:
  ✅ smith-cli v1.0.7
  ✅ maxwell v1.2.1
  ✅ smith-validation v1.0.5
  ✅ smith-sbsift v1.0.3
  ✅ sosumi v2.1.0

Agent:
  ✅ @smith registered at ~/.claude/agents/smith.md

Cache:
  ✅ Cache directory: ~/.smith/cache/ (42 MB)

Tests (all passed):
  ✅ smith validate --tca (works)
  ✅ maxwell search "TCA" (works)
  ✅ smith-cli detect (works)
  ✅ @smith agent (available)

Status: All systems operational! 🎉
```

### ✅ 4. Add smith-cli Help for Common Tasks

**What**: Enhanced help system
**Where**: `Smith/cli/` source
**Time**: 1-2 hours

**Usage**:
```bash
smith-cli help validate
smith-cli help diagnose
smith-cli help patterns
```

**Output**:
```
Command: smith validate

Description:
  Validate your Swift/TCA code against architectural rules

Common Usage:
  smith validate --tca              # Quick check
  smith validate --tca --level standard  # Standard check
  smith validate --tca --level comprehensive  # Strict check

Examples:
  # Validate current directory
  smith validate --tca

  # Validate specific file
  smith validate --tca Sources/Features/UserProfile/

When to Use:
  • Before committing code
  • During code review
  • Checking TCA compliance
  • Architecture validation

See Also:
  maxwell search "TCA"         # Get pattern examples
  @smith validate my code      # Interactive validation in Claude Code
```

---

## 🔧 Medium-Priority Items (1-2 Weeks)

### 2. Consolidate Installation Scripts

**What**: Make `install.sh` the primary entry point
**Where**: Root directory
**Time**: 2-3 days

**Changes**:
1. Rename `smith-tools-install.sh` → `install.sh`
2. Add deprecation notice to `smith-install.sh`
3. Update all documentation to reference `./install.sh`
4. Make `deploy.sh` internal-only (developers only)

**Verification**:
```bash
./install.sh --help              # Clear options
./install.sh --core              # Works
./install.sh --complete          # Works
smith-cli status                 # Shows all tools
```

### 3. Standardize Tool Output

**What**: All tools output compatible JSON
**Where**: Each tool (sbsift, spmsift, validation, etc.)
**Time**: 3-5 days

**Standard format**:
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

**Testing**:
```bash
# Each tool should produce consistent output
smith-sbsift analyze --format json | jq '.status'
smith-spmsift show-dependencies --format json | jq '.status'
smith-validation . --format json | jq '.status'
```

### 4. Create smith-cli Feature Set

**What**: Enhance smith-cli with useful commands
**Where**: `Smith/cli/` source
**Time**: 3-5 days

**New commands**:
```bash
smith-cli status                 # Tool and version status
smith-cli verify                 # Run verification tests
smith-cli suggest <task>         # Get tool suggestions
smith-cli examples <command>     # Show usage examples
smith-cli config --show          # Show current config
smith-cli config --set KEY=VAL   # Set configuration
```

---

## 🏗️ Strategic Items (2-4 Weeks)

### 5. Create Metadata & Configuration System

**What**: manifest.json + ~/.smith/config.json
**Where**: `Smith/manifest.json` and tooling
**Time**: 2-3 days

**Smith/manifest.json**:
```json
{
  "version": "1.0.0",
  "installation_options": {
    "core": ["smith-cli", "maxwell", "smith-validation"],
    "complete": [all tools],
    "build-tools": [build-specific tools]
  },
  "entry_points": {
    "first_time": "./install.sh --core",
    "project_analysis": "smith-cli detect",
    "code_validation": "smith validate --tca"
  }
}
```

### 6. Implement Tool Composition Helpers

**What**: Shell functions for common workflows
**Where**: New file: `Smith/scripts/workflows.sh`
**Time**: 1-2 days

**Usage**:
```bash
source Smith/scripts/workflows.sh

smith-workflow validate-all      # Full validation
smith-workflow quick-check       # 30-second check
smith-workflow diagnose-build    # Build issues
smith-workflow pre-commit        # Before commit
```

### 7. Create CI/CD Integration Examples

**What**: Ready-to-use CI/CD configurations
**Where**: `Smith/docs/ci-cd/`
**Time**: 1-2 days

**Examples**:
- GitHub Actions workflow
- GitLab CI configuration
- Jenkins pipeline
- Local pre-commit hook

---

## 📊 Phase-Based Implementation Plan

### Phase 1: Quick Wins (Week 1)
- [ ] Add documentation links to README
- [ ] Improve installation script output
- [ ] Create smith-cli verify command
- [ ] Add smith-cli help system
- **Impact**: Better user experience, clear guidance, no breaking changes

### Phase 2: Core Improvements (Week 2-3)
- [ ] Consolidate installation scripts
- [ ] Standardize tool output formats
- [ ] Enhance smith-cli command set
- [ ] Create manifest.json
- **Impact**: Consistent experience, better integration, clearer workflows

### Phase 3: Advanced Features (Week 3-4)
- [ ] Implement workflow helpers
- [ ] Create CI/CD examples
- [ ] Build configuration system
- [ ] Improve error messages
- **Impact**: Easier automation, better enterprise adoption, less confusion

---

## 🎯 Success Criteria

### Phase 1: Quick Wins
- ✅ New users can find GETTING_STARTED.md from README
- ✅ Installation output is clear and reassuring
- ✅ `smith-cli verify` shows all tools are working
- ✅ `smith-cli help validate` explains common usage

### Phase 2: Core Improvements
- ✅ One clear installation entry point (`./install.sh`)
- ✅ All tools output consistent JSON format
- ✅ `smith-cli status`, `suggest`, `examples` all work
- ✅ Documentation links are up-to-date

### Phase 3: Advanced Features
- ✅ Common workflows available as shell functions
- ✅ CI/CD integrations documented and tested
- ✅ Configuration system is in place
- ✅ Error messages are actionable

---

## 🚀 Example: Implementing Quick Win #3

### Task: Create `smith-cli verify` Command

**Files to modify**:
1. `Smith/cli/Sources/SmithCLI/Commands/VerifyCommand.swift` (new)
2. `Smith/cli/Sources/SmithCLI/SmithCLI.swift` (add subcommand)
3. `Smith/cli/Package.swift` (if needed)

**Implementation outline**:

```swift
struct VerifyCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "verify",
        abstract: "Verify Smith Tools installation and functionality"
    )

    func run() throws {
        print("Smith Tools Verification\n")

        // Check each tool
        try checkTool("smith-cli", "--version")
        try checkTool("maxwell", "--version")
        try checkTool("smith-validation", "--version")

        // Check agent
        try checkAgent()

        // Run quick tests
        try runTests()

        print("\n✅ All systems operational!")
    }
}
```

**Testing**:
```bash
cd Smith/cli
swift build --configuration release
./.build/release/smith-cli verify
```

---

## 📝 Documentation Updates

For each action item, update documentation:

| Item | Update |
|------|--------|
| Installation consolidation | INSTALLATION_GUIDE.md |
| New CLI commands | GETTING_STARTED.md quick reference |
| Tool output standardization | TOOL_COMPOSITION.md tool reference |
| Workflow helpers | TOOL_COMPOSITION.md integration patterns |
| CI/CD examples | Create new docs/ci-cd/ folder |

---

## 🎓 How to Use This Document

### For Quick Implementation
1. Read "Quick Wins" (5 min)
2. Pick one item
3. Follow steps
4. Test & verify
5. Update documentation

### For Planning
1. Review entire document (15 min)
2. Assess team capacity
3. Propose Phase 1-3 timeline
4. Get stakeholder buy-in
5. Execute phase by phase

### For Reporting
Use this to show:
- What's been done (completed items)
- What's in progress (tracked items)
- What's planned (upcoming phases)
- Impact of each improvement

---

## 💾 Tracking Progress

Create a tracking file (e.g., `Smith/docs/ergonomics/PROGRESS.md`):

```markdown
# Implementation Progress

## Phase 1: Quick Wins
- [ ] Add documentation links (Start: Nov 23)
- [ ] Improve installation output
- [ ] Create smith-cli verify
- [ ] Add smith-cli help

## Phase 2: Core Improvements
- [ ] Consolidate install scripts
- [ ] Standardize tool output
- [ ] Enhance smith-cli
- [ ] Create manifest.json

## Phase 3: Advanced
- [ ] Workflow helpers
- [ ] CI/CD examples
- [ ] Config system
- [ ] Better errors
```

---

## 🎯 Final Notes

### Starting Point
Begin with **Quick Wins** - these provide immediate value with minimal risk.

### Decision Point
After Phase 1, assess:
- User feedback
- Team capacity
- Strategic priorities

Then decide on Phase 2 & 3 timeline.

### Monitoring
Track effectiveness by:
- User confusion reduced?
- Installation success rate improved?
- Tool composition easier?
- Integration better supported?

