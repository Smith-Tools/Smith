.PHONY: help build install clean test all

# Colors for output
RESET := \033[0m
BOLD := \033[1m
BLUE := \033[34m
GREEN := \033[32m

help:
	@echo "$(BOLD)$(BLUE)Smith - Swift Architecture Enforcement System$(RESET)"
	@echo ""
	@echo "Available commands:"
	@echo ""
	@echo "  $(BOLD)make build$(RESET)       Build Smith CLI from source"
	@echo "  $(BOLD)make install$(RESET)     Install Smith (CLI, skill, and supporting tools)"
	@echo "  $(BOLD)make clean$(RESET)       Clean build artifacts"
	@echo "  $(BOLD)make test$(RESET)        Run tests"
	@echo "  $(BOLD)make all$(RESET)         Build, test, and install"
	@echo ""
	@echo "  $(BOLD)make install-cli$(RESET)        Install Smith CLI only"
	@echo "  $(BOLD)make install-skill$(RESET)      Install Smith skill to Claude Code"
	@echo "  $(BOLD)make install-tools$(RESET)      Install supporting tools (sbsift, spmsift, xcsift)"
	@echo ""
	@echo "Installation will:"
	@echo "  • Build Smith CLI from $(PWD)/cli"
	@echo "  • Install to ~/.local/bin"
	@echo "  • Install skill to ~/.claude/skills/smith"
	@echo "  • Install supporting tools via Homebrew"
	@echo ""

# Build Smith CLI from source
build:
	@echo "$(BOLD)$(BLUE)Building Smith CLI...$(RESET)"
	cd cli && swift build -c release
	@echo "$(GREEN)✓ Build complete$(RESET)"

# Build and run tests
test: build
	@echo "$(BOLD)$(BLUE)Running tests...$(RESET)"
	cd cli && swift test
	@echo "$(GREEN)✓ Tests complete$(RESET)"

# Install everything
install: build install-cli install-skill install-tools
	@echo "$(GREEN)✓ Smith installation complete$(RESET)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Read START-HERE.md for quick start"
	@echo "  2. Try: smith analyze /path/to/project"
	@echo "  3. Use Smith skill in Claude Code"

# Install CLI binary
install-cli: build
	@echo "$(BOLD)$(BLUE)Installing Smith CLI...$(RESET)"
	@mkdir -p ~/.local/bin
	@cp cli/.build/release/smith ~/.local/bin/
	@chmod +x ~/.local/bin/smith
	@echo "$(GREEN)✓ CLI installed to ~/.local/bin/smith$(RESET)"
	@echo ""
	@echo "Add to PATH if not already present:"
	@echo "  export PATH=\"\$$HOME/.local/bin:\$$PATH\""

# Install Claude Code skill
install-skill:
	@echo "$(BOLD)$(BLUE)Installing Smith skill for Claude Code...$(RESET)"
	@mkdir -p ~/.claude/skills/smith
	@cp -r skills/skill-smith/* ~/.claude/skills/smith/
	@echo "$(GREEN)✓ Skill installed to ~/.claude/skills/smith$(RESET)"
	@echo ""
	@echo "Smith will auto-trigger on:"
	@echo "  • TCA patterns (@Reducer, CombineReducers)"
	@echo "  • Architecture keywords (monolithic, coupling)"
	@echo "  • Swift patterns (@State, async/await)"

# Install supporting tools via Homebrew
install-tools:
	@echo "$(BOLD)$(BLUE)Installing supporting Smith tools...$(RESET)"
	@echo "These tools require Homebrew:"
	@echo ""
	@echo "  smith-sbsift  - Swift build analysis"
	@echo "  smith-spmsift - SPM dependency analysis"
	@echo "  smith-xcsift  - Xcode build analysis"
	@echo ""
	@echo "To install:"
	@echo "  brew tap elkraneo/tap"
	@echo "  brew install smith-sbsift smith-spmsift smith-xcsift"
	@echo ""

# Clean build artifacts
clean:
	@echo "$(BOLD)$(BLUE)Cleaning build artifacts...$(RESET)"
	cd cli && swift build --clean
	@rm -rf .build 2>/dev/null || true
	@echo "$(GREEN)✓ Clean complete$(RESET)"

# Full build, test, and install
all: clean test install
	@echo ""
	@echo "$(GREEN)✓ Smith setup complete!$(RESET)"

# Development help
dev-help:
	@echo "$(BOLD)$(BLUE)Smith Development$(RESET)"
	@echo ""
	@echo "Building:"
	@echo "  cd cli && swift build -c release"
	@echo ""
	@echo "Testing:"
	@echo "  cd cli && swift test"
	@echo ""
	@echo "Debugging:"
	@echo "  cd cli && swift build"
	@echo "  .build/debug/smith analyze /path/to/project"
	@echo ""
	@echo "Extending Smith:"
	@echo "  • Add validation rules in validation/"
	@echo "  • Add guidance in skills/skill-smith/"
	@echo "  • Add scripts in scripts/"
	@echo ""

.DEFAULT_GOAL := help
