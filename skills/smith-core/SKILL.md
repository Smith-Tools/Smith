---
name: smith-core
description: Swift architecture, dependency injection, concurrency patterns, testing, and access control. Use for general Swift development, dependency injection, testing patterns, concurrency, and access control issues.
tags:
  - "Swift"
  - "dependency injection"
  - "concurrency"
  - "testing"
  - "access control"
triggers:
  - "Swift"
  - "dependency"
  - "concurrency"
  - "testing"
  - "access control"
  - "@Dependency"
  - "async/await"
  - "Swift Testing"
allowed-tools:
  - Read
  - Glob
  - Grep
version: "3.0.0"
author: "Claude Code Skill - Smith Architecture"
---

# Smith Core - Universal Swift Patterns

## Core Knowledge Base

For comprehensive guidance on Swift architecture, dependencies, concurrency, testing, and access control:

- **Universal Swift Patterns**: [knowledge/AGENTS-AGNOSTIC.md](knowledge/AGENTS-AGNOSTIC.md)
- **Decision Trees**: [knowledge/AGENTS-DECISION-TREES.md](knowledge/AGENTS-DECISION-TREES.md)
- **Claude Integration Guide**: [knowledge/CLAUDE.md](knowledge/CLAUDE.md)

## Quick Navigation

When asked about Swift architecture, dependency injection, concurrency, testing, or access control:

1. **Use Glob** to find relevant files: `Glob("knowledge/**/*.md")`
2. **Use Grep** to search content: `Grep("@Dependency", "knowledge/")`
3. **Use Read** to access files: `Read("knowledge/AGENTS-AGNOSTIC.md")`

All knowledge is in the `knowledge/` directory - search there for answers.

## Skill Domains

**smith-core** handles:
- ✅ Dependency injection patterns (@Dependency, @DependencyClient)
- ✅ Concurrency patterns (async/await, @MainActor, Task)
- ✅ Testing framework (Swift Testing, @Test, TestStore)
- ✅ Access control and public API boundaries
- ✅ Universal Swift patterns (not TCA-specific)

**For TCA-specific questions**, use the dedicated **smith-tca** skill.
**For platform-specific patterns**, use the dedicated **smith-platforms** skill.
