# Changelog

All notable changes to Smith CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.0] - 2024-12-03

### Changed
- **Foundation Integration**: Migrated to Smith Foundation libraries
  - Now uses SmithBuildAnalysis for core orchestration
  - Integrated SmithProgress for progress tracking in ValidationCommand
  - Integrated SmithOutputFormatter for consistent output formatting
  - Integrated SmithErrorHandling for error management
- **Fixed Build Errors**: Corrected import statement (SmithBuildAnalysis, not SmithCore)
- **Improved Error Messages**: ValidationCommand uses structured SmithError types

### Dependencies
- Added: smith-build-analysis
- Added: smith-foundation/SmithProgress
- Added: smith-foundation/SmithOutputFormatter
- Added: smith-foundation/SmithErrorHandling

### Internal
- Removed duplicate SmithError definitions
- Unified with foundation error handling
- Consistent output across all commands

## [1.2.0] - 2024-11-01

### Added
- Validate command
- Check command
- Analyze command

## [1.0.6] - 2024-10-15

### Added
- Initial release
- Basic orchestration
- Integration with analysis tools