# Smith Tools: Installation Guide

Complete installation and setup instructions.

---

## 🚀 Quick Start

### For New Users (Recommended)

```bash
# Navigate to Smith Tools root
cd /path/to/Smith-Tools

# Run the installer
./install.sh --core
```

**This installs:**
- `smith-cli` - Unified CLI interface
- `maxwell` - Pattern expertise system
- `smith-validation` - TCA validation engine
- `@smith` - Claude Code agent

### For Complete Suite

```bash
./install.sh --complete
```

**This adds:**
- `sosumi` - Apple documentation search
- `smith-sbsift` - Build analysis
- `smith-spmsift` - Dependency analysis
- `smith-xcsift` - Xcode analysis

### Verify Installation

```bash
smith-cli status
```

**Expected output:**
```
✅ smith-cli v1.0.7
✅ maxwell v1.2.1
✅ smith-validation v1.0.5
✅ smith-sbsift v1.0.3
✅ sosumi v2.1.0
✅ @smith agent (registered)
```

---

## 📋 Installation Methods

### Method 1: Main Installation Script (Recommended)

Located in: `/Volumes/Plutonian/_Developer/Smith Tools/`

```bash
./install.sh --help
```

**Options:**
```bash
./install.sh --core              # Minimal setup (smith-cli, maxwell, validation)
./install.sh --complete          # Full suite with all tools
./install.sh --components X,Y    # Specific components
./install.sh --help              # Show all options
```

### Method 2: Homebrew (If Available)

```bash
brew tap Smith-Tools/smith
brew install smith-cli
brew install smith-validation
brew install maxwell
brew install sosumi
```

### Method 3: Source Build (For Development)

```bash
cd Smith
make install
# OR
swift build --configuration release
cp .build/release/smith /usr/local/bin/
```

---

## 🔧 Installation Details

### What Gets Installed Where

| Component | Location | Type |
|-----------|----------|------|
| `smith-cli` | `/usr/local/bin/smith-cli` | Binary |
| `maxwell` | `/usr/local/bin/maxwell` | Binary |
| `smith-validation` | `/usr/local/bin/smith-validation` | Binary |
| `sosumi` | `/usr/local/bin/sosumi` | Binary |
| `smith-sbsift` | `/usr/local/bin/smith-sbsift` | Binary |
| `smith-spmsift` | `/usr/local/bin/smith-spmsift` | Binary |
| `smith-xcsift` | `/usr/local/bin/smith-xcsift` | Binary |
| `@smith` agent | `~/.claude/agents/smith.md` | Configuration |
| Cache | `~/.smith/cache/` | Data (created on first use) |

### System Requirements

- **macOS** 11.0 or later
- **Swift** 5.8 or later (for command-line tools)
- **Bash** 4.0 or later (for installation script)
- **~50 MB** disk space (tools + cache)

### Network Requirements

Installation may download:
- Tool binaries (if via Homebrew)
- Dependencies (if building from source)
- Pattern indices (for maxwell and sosumi)

---

## ✅ Post-Installation Setup

### Step 1: Verify Installation

```bash
smith-cli status
```

If all tools show ✅, skip to Step 4.

### Step 2: Check Agent Registration

```bash
ls ~/.claude/agents/smith.md
```

If file exists, skip to Step 4.

If missing:
```bash
mkdir -p ~/.claude/agents
cp Smith/agent/smith.md ~/.claude/agents/smith.md
```

### Step 3: Initialize Cache

Smith creates cache on first use. To pre-initialize:

```bash
# Pre-warm the cache
smith-cli status > /dev/null
maxwell search "TCA" --limit 1 > /dev/null
```

### Step 4: Configure Shell (Optional)

Add to `~/.bash_profile` or `~/.zshrc`:

```bash
# Smith Tools configuration
export SMITH_VERBOSE=false     # Reduce output
export SMITH_FORMAT=json       # Default output format
export SMITH_CACHE_DIR=$HOME/.smith/cache

# Add Smith Tools to PATH (if needed)
export PATH="/usr/local/bin:$PATH"
```

---

## 🐛 Troubleshooting

### Problem: Command Not Found

**Symptom**: `smith-cli: command not found`

**Solution**:
```bash
# Check if installed
which smith-cli

# If not found, check /usr/local/bin
ls /usr/local/bin/smith*

# If missing, reinstall
./install.sh --core

# If still missing, check PATH
echo $PATH

# Add to PATH if needed
export PATH="/usr/local/bin:$PATH"
```

### Problem: Agent Not Working

**Symptom**: `@smith` doesn't appear in Claude Code

**Solution**:
```bash
# Check agent file
ls ~/.claude/agents/smith.md

# If missing, reinstall
mkdir -p ~/.claude/agents
cp Smith/agent/smith.md ~/.claude/agents/smith.md

# Restart Claude Code or new session
```

### Problem: Permission Denied

**Symptom**: `permission denied` when running install.sh

**Solution**:
```bash
# Make script executable
chmod +x install.sh

# Then run
./install.sh --core
```

### Problem: Installation Hangs

**Symptom**: Installation takes too long or freezes

**Solution**:
```bash
# Cancel with Ctrl+C
# Try with minimal components
./install.sh --components smith-cli

# Or try via Homebrew
brew install smith-cli
```

### Problem: Verification Fails

**Symptom**: `smith-cli status` shows ❌ for some tools

**Solution**:
```bash
# Reinstall specific component
./install.sh --components smith-validation

# Or manually check
smith-validation --version
maxwell --version
smith-cli --version
```

### Problem: Cache Corruption

**Symptom**: Tools behave oddly or return wrong results

**Solution**:
```bash
# Clear cache
rm -rf ~/.smith/cache/

# Reinitialize
smith-cli status
```

---

## 🔄 Updating Smith Tools

### Update via Homebrew

```bash
brew upgrade smith-cli smith-validation maxwell sosumi
```

### Update via Script

```bash
./install.sh --core --update
```

### Update Agent

```bash
cp Smith/agent/smith.md ~/.claude/agents/smith.md
```

### Check Version

```bash
smith-cli --version
maxwell --version
smith-validation --version
sosumi --version
```

---

## 🗑️ Uninstalling

### Remove Tools

```bash
# Via Homebrew
brew uninstall smith-cli maxwell smith-validation sosumi

# Manual removal
rm /usr/local/bin/smith*
rm /usr/local/bin/maxwell
rm /usr/local/bin/sosumi
```

### Remove Agent

```bash
rm ~/.claude/agents/smith.md
```

### Clear Cache

```bash
rm -rf ~/.smith/cache/
```

---

## 🌐 Network Proxy Setup

If behind a corporate proxy:

```bash
# Set environment variables
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=https://proxy.example.com:8080

# Or for Homebrew
brew config | grep -i proxy

# Then install
./install.sh --core
```

---

## 📊 Installation Scenarios

### Scenario 1: Individual Developer

```bash
# Minimal installation for single developer
./install.sh --core

# Validate TCA code locally
smith validate --tca

# Get architecture help
@smith validate my code
```

### Scenario 2: Team Development

```bash
# Install complete suite
./install.sh --complete

# Set up team configuration
smith-cli configure --team

# Enable build monitoring
swift build 2>&1 | smith-sbsift monitor

# Validate in CI
smith validate --tca --level critical
```

### Scenario 3: CI/CD Pipeline

```bash
# Minimal installation for CI
./install.sh --components smith-validation

# Run validation
smith validate --tca --format json > report.json

# Exit with error if critical violations
if grep -q critical report.json; then exit 1; fi
```

### Scenario 4: Development Environment

```bash
# Full suite for local development
./install.sh --complete

# Enable all monitoring
smith-cli configure --verbose
maxwell init --include-experimental

# Set up aliases (optional)
alias smith-check='smith validate --tca'
alias smith-build='swift build 2>&1 | smith-sbsift monitor'
alias smith-analyze='smith-cli analyze --level standard'
```

---

## 🎯 Next Steps

After installation:

1. **Verify it works**: `smith-cli status`
2. **Analyze your project**: `smith-cli detect`
3. **Try validation**: `smith validate --tca`
4. **Read guides**:
   - Quick start → GETTING_STARTED.md
   - Tool details → TOOL_COMPOSITION.md
   - Workflows → SMITH_TOOLS_WORKFLOW_GUIDE.md

---

## 📞 Getting Help

### Installation Help
```bash
./install.sh --help
```

### Tool Help
```bash
smith-cli --help
smith validate --help
maxwell --help
smith-validation --help
```

### Documentation
- **GETTING_STARTED.md** - Quick start guide
- **REVIEW.md** - Ergonomics analysis
- **TOOL_COMPOSITION.md** - Tool integration
- **ARCHITECTURE.md** - System design

