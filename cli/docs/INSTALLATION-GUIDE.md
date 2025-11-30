# Smith Tools Installation & Setup Guide

This comprehensive guide covers all aspects of installing, configuring, and setting up Smith Tools for different development environments.

## Quick Start

### For Most Users (Recommended)

```bash
# Install all Smith tools via Homebrew
brew tap smith-tools/smith
brew install smith-tools

# Verify installation
smith --version
smith status
```

### Manual Installation

```bash
# Download and install individual tools
curl -L https://github.com/Smith-Tools/smith/releases/latest/download/smith-validation -o /usr/local/bin/smith-validation
chmod +x /usr/local/bin/smith-validation

curl -L https://github.com/Smith-Tools/smith/releases/latest/download/smith-xcsift -o /usr/local/bin/smith-xcsift
chmod +x /usr/local/bin/smith-xcsift
```

## System Requirements

### macOS (Primary Platform)

**Minimum Requirements:**
- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later
- Swift 5.7 or later
- 8GB RAM (16GB recommended for large projects)

**Recommended Setup:**
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9 or later
- 16GB+ RAM for optimal performance

**Required Xcode Command Line Tools:**
```bash
xcode-select --install
```

### Linux (Experimental)

**Supported Distributions:**
- Ubuntu 20.04 LTS or later
- Debian 11 or later
- Fedora 35 or later

**Dependencies:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y swift-lang clang libc++-dev

# Fedora
sudo dnf install -y swift-lang clang-devel libcxx-devel
```

### Windows (via WSL)

```bash
# Install WSL2 with Ubuntu 22.04
wsl --install -d Ubuntu-22.04

# Inside WSL, follow Linux installation
```

## Installation Methods

### 1. Homebrew (Recommended)

#### Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Install Smith Tools
```bash
# Add Smith Tools tap
brew tap smith-tools/smith

# Install all tools
brew install smith-tools

# Or install individual tools
brew install smith-validation
brew install smith-xcsift
brew install smith-sbsift
brew install smith-spmsift
brew install smith-tca-trace
```

#### Upgrade Smith Tools
```bash
brew update
brew upgrade smith-tools
```

#### Uninstall
```bash
brew uninstall smith-tools
brew untap smith-tools/smith
```

### 2. Using Smith CLI (Unified Installation)

```bash
# Download the CLI
curl -L https://github.com/Smith-Tools/smith/releases/latest/download/smith-cli -o smith
chmod +x smith

# Install all supporting tools
./ smith install-all

# Or install specific tools
./ smith install validation
./ smith install xcsift
./ smith install sbsift
./ smith install spmsift
./ smith install tca-trace
```

### 3. Manual Download

#### Latest Release
```bash
# Create installation directory
mkdir -p ~/bin/smith-tools
cd ~/bin/smith-tools

# Download latest release
curl -L -o smith-cli.tar.gz https://github.com/Smith-Tools/smith/releases/latest/download/cli-macos.tar.gz
tar -xzf smith-cli.tar.gz

# Add to PATH
echo 'export PATH="$HOME/bin/smith-tools/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### Development Version
```bash
git clone https://github.com/Smith-Tools/smith.git
cd smith
make install-all
```

## Configuration

### Basic Configuration

#### Create Configuration Directory
```bash
mkdir -p ~/.smith
touch ~/.smith/config.json
```

#### Configuration File Structure
```json
{
  "version": "1.0",
  "defaults": {
    "validation": {
      "level": "critical",
      "format": "summary"
    },
    "analysis": {
      "timeout": 300,
      "hangDetection": false,
      "format": "auto"
    }
  },
  "tools": {
    "smithValidationPath": "/opt/homebrew/bin/smith-validation",
    "smithXCSiftPath": "/opt/homebrew/bin/smith-xcsift",
    "smithSBSiftPath": "/opt/homebrew/bin/smith-sbsift",
    "smithSPMSiftPath": "/opt/homebrew/bin/smith-spmsift",
    "smithTCATracePath": "/opt/homebrew/bin/smith-tca-trace"
  },
  "output": {
    "colors": true,
    "progress": true,
    "format": "auto"
  },
  "performance": {
    "cpuThreshold": 80.0,
    "memoryThreshold": 2.0,
    "timeout": 30
  }
}
```

#### Environment Variables
```bash
# Core configuration
export SMITH_CONFIG="$HOME/.smith/config.json"
export SMITH_HOME="$HOME/.smith"

# Output configuration
export SMITH_NO_COLOR=false
export SMITH_VERBOSE=false
export SMITH_FORMAT=auto

# Performance settings
export SMITH_TIMEOUT=300
export SMITH_CPU_THRESHOLD=80.0
export SMITH_MEMORY_THRESHOLD=2.0

# Logging
export SMITH_LOG_LEVEL=INFO
export SMITH_LOG_PATH="$HOME/Library/Logs/Smith/"

# Add to shell profile
echo 'export SMITH_CONFIG="$HOME/.smith/config.json"' >> ~/.zshrc
echo 'export SMITH_HOME="$HOME/.smith"' >> ~/.zshrc
```

### Advanced Configuration

#### Per-Project Configuration
Create `.smith/config.json` in your project directory:

```json
{
  "project": {
    "name": "MyApp",
    "type": "ios",
    "minimumSwiftVersion": "5.7"
  },
  "validation": {
    "level": "comprehensive",
    "excludePaths": ["Tests/**/*", "Generated/**/*"],
    "customRules": {
      "maxReducerActions": 30,
      "requireTestCoverage": true
    }
  },
  "performance": {
    "baselineFile": "performance-baseline.json",
    "tolerance": 0.1
  }
}
```

#### Editor Integration Configuration

**VS Code (`settings.json`):**
```json
{
  "smith.enabled": true,
  "smith.validationLevel": "standard",
  "smith.format": "summary",
  "smith.autoValidateOnSave": true,
  "smith.statusBarIndicator": true
}
```

**Xcode (`SmithConfig.xcconfig`):**
```swift
// Add to your Xcode project
SMITH_VALIDATION_ENABLED = YES
SMITH_VALIDATION_LEVEL = standard
SMITH_FORMAT = json
```

## Verification & Testing

### Installation Verification
```bash
# Check CLI installation
smith --version
smith --help

# Verify all tools are accessible
smith status

# Test tool execution
smith validate --version
smith xcode --version
smith swift --version
smith spm --version
smith tca --version
```

### Functionality Tests
```bash
# Test TCA validation
smith validate --level critical

# Test project analysis
smith smart-analyze

# Test output formatting
smith validate --format json
smith validate --format summary
smith validate --format auto

# Test progress indicators
smith validate --level comprehensive

# Test error handling
smith validate ./nonexistent
```

### Performance Benchmarks
```bash
# Small project (< 10 files)
time smith validate ./SmallProject

# Medium project (10-100 files)
time smith validate ./MediumProject

# Large project (> 100 files)
time smith validate ./LargeProject --level critical
```

## Platform-Specific Setup

### macOS Setup

#### Xcode Integration
```bash
# Ensure Xcode command line tools are installed
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer

# Set default Xcode if multiple versions
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

#### Custom Tool Paths
```bash
# Check where tools are installed
which smith-validation
which smith-xcsift
which smith-sbsift

# If not found, add to PATH
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### macOS Permissions
```bash
# Allow tools to run (may be required on first run)
sudo spctl --add /opt/homebrew/bin/smith-validation
sudo spctl --add /opt/homebrew/bin/smith-xcsift
```

### Linux Setup

#### System Dependencies
```bash
# Install required system packages
sudo apt install -y build-essential cmake git

# Install Swift (Ubuntu/Debian)
wget https://download.swift.org/swift-5.9.1-release/ubuntu2204/swift-5.9.1-RELEASE/swift-5.9.1-RELEASE-ubuntu22.04.tar.gz
tar xzf swift-5.9.1-RELEASE-ubuntu22.04.tar.gz
export PATH="$(pwd)/swift-5.9.1-RELEASE-ubuntu22.04/usr/bin:$PATH"
```

#### WSL2 Setup
```bash
# Install required packages in WSL
sudo apt update
sudo apt install -y wget build-essential cmake

# Download and install Swift for Linux
wget https://download.swift.org/swift-5.9.1-release/ubuntu2204/swift-5.9.1-RELEASE/swift-5.9.1-RELEASE-ubuntu22.04.tar.gz
sudo tar -xzf swift-5.9.1-RELEASE-ubuntu22.04.tar.gz -C /usr/local

# Verify Swift installation
swift --version
```

## Troubleshooting Installation

### Common Issues

#### "Command not found" Error
```bash
# Check PATH
echo $PATH | grep smith

# Add to PATH if missing
echo 'export PATH="$HOME/bin/smith-tools/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
which smith
```

#### Permission Denied Error
```bash
# Make tools executable
chmod +x /usr/local/bin/smith-*
chmod +x ~/bin/smith-tools/bin/*

# Fix ownership if needed
sudo chown -R $USER:$GROUP /usr/local/bin/smith-*
```

#### "Tool not found" in Commands
```bash
# Check tool installation paths
ls -la /opt/homebrew/bin/smith-*
ls -la /usr/local/bin/smith-*
ls -la ~/bin/smith-tools/bin/*

# Update configuration with correct paths
smith config set tools.smithValidationPath /opt/homebrew/bin/smith-validation
```

#### Homebrew Installation Issues
```bash
# Reset Homebrew if corrupted
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Reinstall Smith Tools
brew tap smith-tools/smith
brew install smith-tools
```

#### Xcode Version Compatibility
```bash
# Check Xcode version
xcodebuild -version

# Check minimum version
smith doctor

# Update Xcode Command Line Tools
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```

### Advanced Troubleshooting

#### Enable Debug Logging
```bash
# Enable verbose logging
export SMITH_VERBOSE=1
export SMITH_LOG_LEVEL=DEBUG

# Check log files
tail -f ~/Library/Logs/Smith/smith.log
```

#### Reset Configuration
```bash
# Backup existing config
cp ~/.smith/config.json ~/.smith/config.json.backup

# Reset to defaults
rm ~/.smith/config.json
smith config reset

# Reconfigure
smith config edit
```

#### Clean Installation
```bash
# Uninstall all Smith tools
brew uninstall smith-tools

# Remove configuration
rm -rf ~/.smith

# Remove cached data
rm -rf ~/Library/Caches/Smith
rm -rf ~/Library/Logs/Smith

# Clean reinstall
brew tap smith-tools/smith
brew install smith-tools
```

## IDE Integration Setup

### VS Code
```bash
# Install Smith extension
code --install-extension smith-tools.smith-vscode

# Configure settings
# See: .vscode/settings.json
```

### Xcode
```bash
# Add build phase script
# See: Xcode Integration Guide
```

### JetBrains IDEs
```bash
# Configure External Tools
# See: JetBrains Integration Guide
```

## CI/CD Setup

### GitHub Actions
```yaml
# Add to your workflow
- name: Install Smith Tools
  run: |
    brew tap smith-tools/smith
    brew install smith-tools
```

### GitLab CI
```yaml
# Add to your CI configuration
before_script:
  - brew install smith-tools
```

### Jenkins
```groovy
// Add to your Jenkinsfile
stage('Install Smith Tools') {
    steps {
        sh 'brew install smith-tools'
    }
}
```

## Next Steps

After successful installation:

1. **Read the [Command Reference](COMMAND-REFERENCE.md)** - Learn all available commands
2. **Review [Examples](EXAMPLES.md)** - See real-world usage patterns
3. **Check [CLI Design](CLI-DESIGN.md)** - Understand design principles
4. **Read [Error Codes](ERROR-CODES.md)** - Troubleshoot issues effectively
5. **Explore [TTY Formatting](TTY-OUTPUT-FORMATTING.md)** - Master output options

## Support

- **Documentation**: https://smith-tools.dev/docs/
- **Issues**: https://github.com/Smith-Tools/smith/issues
- **Discussions**: https://github.com/Smith-Tools/smith/discussions
- **Discord**: https://discord.gg/smith-tools