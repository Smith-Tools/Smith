#!/bin/bash
set -e

echo "🚀 Smith Installation"
echo "======================================"
echo ""

# Check Swift is installed
if ! command -v swift &> /dev/null; then
    echo "❌ Swift not found. Please install Swift first."
    exit 1
fi

SMITH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
CLAUDE_SKILLS="$HOME/.claude/skills"
SMITH_SKILL_DIR="$CLAUDE_SKILLS/smith"

# Create directories
echo "📁 Creating directories..."
mkdir -p "$LOCAL_BIN"
mkdir -p "$CLAUDE_SKILLS"

# Build CLI
echo ""
echo "🔨 Building Smith CLI..."
cd "$SMITH_DIR/cli"
swift build -c release

# Install CLI
echo ""
echo "📦 Installing CLI binary..."
cp .build/release/smith "$LOCAL_BIN/"
chmod +x "$LOCAL_BIN/smith"
echo "✅ Installed to $LOCAL_BIN/smith"

# Install Skill
echo ""
echo "🎯 Installing Claude Code skill..."
rm -rf "$SMITH_SKILL_DIR" 2>/dev/null || true
mkdir -p "$SMITH_SKILL_DIR"
cp -r "$SMITH_DIR/skills/skill-smith"/* "$SMITH_SKILL_DIR/"
echo "✅ Installed to $SMITH_SKILL_DIR"

# Check PATH
echo ""
if [[ ":$PATH:" == *":$LOCAL_BIN:"* ]]; then
    echo "✅ $LOCAL_BIN is already in PATH"
else
    echo "⚠️  Adding $LOCAL_BIN to PATH..."
    echo ""
    if [[ -f ~/.zshrc ]]; then
        echo "export PATH=\"$LOCAL_BIN:\$PATH\"" >> ~/.zshrc
        echo "✅ Added to ~/.zshrc"
    fi
    if [[ -f ~/.bashrc ]]; then
        echo "export PATH=\"$LOCAL_BIN:\$PATH\"" >> ~/.bashrc
        echo "✅ Added to ~/.bashrc"
    fi
    echo ""
    echo "Please run: source ~/.zshrc (or ~/.bashrc)"
fi

# Install supporting tools
echo ""
echo "🛠️  Supporting Tools"
echo "------------------------------------"
echo ""
echo "The following tools enhance Smith's capabilities:"
echo ""
echo "  • smith-sbsift  - Swift build analysis"
echo "  • smith-spmsift - SPM dependency analysis"
echo "  • smith-xcsift  - Xcode build analysis"
echo ""
echo "To install them, run:"
echo "  brew tap elkraneo/tap"
echo "  brew install smith-sbsift smith-spmsift smith-xcsift"
echo ""

# Final message
echo ""
echo "======================================"
echo "✅ Smith Installation Complete!"
echo "======================================"
echo ""
echo "📖 Next Steps:"
echo ""
echo "1. Read START-HERE.md:"
echo "   open $SMITH_DIR/START-HERE.md"
echo ""
echo "2. Try Smith CLI:"
echo "   smith --help"
echo "   smith analyze /path/to/your/project"
echo ""
echo "3. Use in Claude Code:"
echo "   \"@smith validate my code\""
echo "   \"Check my TCA reducer for violations\""
echo ""
echo "4. During builds:"
echo "   swift build 2>&1 | smith-sbsift analyze --hang-detection"
echo ""
echo "📚 Documentation:"
echo "  • START-HERE.md      - Quick start guide"
echo "  • ARCHITECTURE.md    - Design philosophy"
echo "  • agent/smith.md     - Smith agent definition"
echo ""
echo "💡 Smith is the 'construction police' for Swift."
echo "   Strict, uncompromising, and always right."
echo ""
