# Smith CLI

Unified command-line interface and orchestrator for Smith Tools ecosystem.

## Overview

Smith CLI provides a single entry point for all Smith Tools functionality, including build analysis, validation, and diagnostics. It acts as an orchestrator, delegating to specialized tools while providing a consistent user experience.

## Installation

### Via Homebrew (Recommended)

```bash
brew tap elkraneo/tap
brew install smith-cli
```

### Via Installer Script

```bash
cd /path/to/Smith/cli
bash install.sh
```

### Building from Source

```bash
cd /path/to/Smith/cli
swift build -c release
cp .build/release/smith ~/.local/bin/
```

## Quick Start

```bash
# Show help
smith --help

# Validate a project
smith validate .

# Analyze build output
xcodebuild build | smith analyze

# Check project structure
smith check .
```

## Features

- **Unified Interface**: Single CLI for all Smith Tools
- **Foundation Integration**: Built on Smith Foundation libraries
- **Progress Tracking**: Visual progress indicators for long operations
- **Structured Output**: JSON or human-readable output formats
- **Error Recovery**: Comprehensive error handling with actionable suggestions

## Architecture

Smith CLI is an orchestrator that:
1. Parses user commands via ArgumentParser
2. Delegates to specialized tools (smith-xcsift, smith-sbsift, smith-validation)
3. Uses SmithBuildAnalysis for core parsing logic
4. Presents results using Smith Foundation libraries

```
┌──────────────────────────┐
│      Smith CLI           │
│    (Orchestrator)        │
└────────┬─────────────────┘
         │
    ┌────┴────┬────────┬──────────┐
    ▼         ▼        ▼          ▼
┌────────┐ ┌──────┐ ┌────────┐ ┌────────┐
│xcsift  │ │sbsift│ │validate│ │ trace  │
└────────┘ └──────┘ └────────┘ └────────┘
    │         │        │          │
    └────┬────┴────┬───┴──────────┘
         ▼         ▼
    ┌──────────────────────┐
    │  SmithBuildAnalysis  │
    └──────────────────────┘
         │
    ┌────▼────────────────┐
    │  Smith Foundation   │
    └─────────────────────┘
```

## Commands

### `smith validate [PATH]`

Validate Swift/Xcode project structure and configuration.

```bash
smith validate .
smith validate . --level=critical --format=json
```

### `smith analyze [PATH]`

Analyze build output or project structure.

```bash
xcodebuild build 2>&1 | smith analyze
smith analyze build.log
```

### `smith check [PATH]`

Quick health check of project configuration.

```bash
smith check .
```

## Dependencies

- **SmithBuildAnalysis**: Core parsing and analysis
- **SmithProgress**: Progress tracking
- **SmithOutputFormatter**: Output formatting
- **SmithErrorHandling**: Error management

These are automatically resolved via Swift Package Manager.

## Configuration

Smith CLI respects the following environment variables:

- `SMITH_OUTPUT_FORMAT`: Default output format (json|summary|detailed)
- `SMITH_COLOR`: Enable/disable color output (auto|always|never)
- `NO_COLOR`: Disable all color output (standard convention)

## Requirements

- Swift 6.0+
- macOS 13.0+
- Xcode 15.0+ (for Xcode project analysis)

## Documentation

See the [docs/](docs/) directory for detailed documentation:

- [CLI Design](docs/CLI-DESIGN.md)
- [Command Reference](docs/COMMAND-REFERENCE.md)
- [Examples](docs/EXAMPLES.md)
- [Error Codes](docs/ERROR-CODES.md)
- [TTY Output Formatting](docs/TTY-OUTPUT-FORMATTING.md)
- [Installation Guide](docs/INSTALLATION-GUIDE.md)
- [Migration Guide](docs/MIGRATION-GUIDE.md)
- [FAQ](docs/FAQ.md)

## Claude Code Integration

Smith CLI includes Claude Code skills for AI-assisted development:

```bash
# Skills are installed to ~/.claude/skills/
~/.claude/skills/smith/         # Main orchestrator skill
~/.claude/skills/smith-core/    # Core patterns skill
~/.claude/skills/smith-platforms/  # Platform-specific patterns
```

See [docs/CLAUDE-INTEGRATION.md](docs/CLAUDE-INTEGRATION.md) for details.

## License

MIT License - See LICENSE file for details

## Related Projects

- [smith-xcsift](../../smith-xcsift) - Xcode build analysis
- [smith-sbsift](../../smith-sbsift) - Swift build analysis
- [smith-validation](../../smith-validation) - TCA validation
- [smith-foundation](../../smith-foundation) - Foundation libraries