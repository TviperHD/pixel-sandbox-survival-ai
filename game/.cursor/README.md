# Cursor IDE Rules

**Location:** `.cursor/rules/`  
**Purpose:** AI coding assistant rules for game implementation

## Overview

This folder contains Cursor IDE rules that guide the AI assistant when implementing the game. These rules ensure consistency, quality, and adherence to project standards.

---

## Project Overview

**Start here:** `../PROJECT_OVERVIEW.md`

This document provides comprehensive context about the project, including:
- Game concept and vision
- Technical architecture overview
- System overview and relationships
- Development standards and constraints
- Documentation structure
- Implementation workflow

**Read this first** before implementing any system.

---

## Rules Files

The rules are split into focused, composable files (each under 500 lines):

### `rules/code-standards.mdc`

Covers:
- **Naming Conventions:** Classes, variables, functions, constants, files
- **Type Hints:** Always required, examples
- **Code Organization:** Standard script structure
- **Project Structure:** Directory organization requirements
- **Code Style:** Spacing, line length, comments
- **Implementation Standards:** Modularity, configurability, editor support
- **Documentation Standards:** Class, function, and comment documentation

### `rules/godot-patterns.mdc`

Covers:
- **Autoload Singletons:** Initialization order, patterns
- **Signals vs Direct Calls:** When to use each
- **Performance Optimization:** Object pooling, physics, collision, update frequency
- **Error Handling:** Error functions, best practices, examples
- **Resource Management:** Loading, instances, paths
- **Scene Management:** Loading scenes, references
- **Signal Connections:** Connection patterns, disconnection
- **Common Patterns:** Manager singleton, resource loading, timer patterns

### `rules/system-integration.mdc`

Covers:
- **Manager Communication:** Hybrid pattern (signals + direct calls)
- **System Dependencies:** Checking dependencies, initialization order
- **Integration Points:** Documenting how systems connect
- **Cross-System Data Flow:** Examples of data flowing between systems
- **System Interfaces:** Defining clear APIs
- **Integration Testing:** Testing system interactions
- **Common Integration Patterns:** Manager-to-manager, component-to-manager, event-driven

### `rules/implementation-workflow.mdc`

Covers:
- **Implementation Workflow:** Step-by-step process
- **Reference Documentation:** Links to all technical specifications and checklists
- **Testing:** Test checklist, patterns, integration testing
- **Common Patterns:** Manager singleton, resource loading, signal connection, update loops
- **Critical Rules:** DOs and DON'Ts checklist
- **Implementation Checklist:** Step-by-step checklist for each system

### `rules/research-planning.mdc`

Covers:
- **Research Standards:** How to research best practices, tools, and verify approaches
- **Review Standards:** How to review specifications for completeness and consistency
- **Update Standards:** When and how to update specifications
- **Discussion Guidelines:** How to discuss design decisions and review specs
- **Research Workflow:** Step-by-step process for research tasks
- **Question Guidelines:** How to ask questions (one at a time)
- **Documentation Locations:** Where to find and update documentation
- **Critical Rules:** DOs and DON'Ts for research/planning sessions

**Note:** This rule file is for research/planning sessions, not implementation sessions.

### `rules/git-auto-commit.mdc`

Covers:
- **Automatic Commits:** Always commit changes after making them
- **Commit Process:** Step-by-step Git commands
- **Commit Messages:** Format guidelines and examples
- **Phase Milestones:** Creating tags for completed phases
- **Implementation Pattern:** When and how to commit
- **Troubleshooting:** Common issues and solutions

**CRITICAL:** This rule ensures all changes are automatically backed up to GitHub.

---

## How Cursor Uses These Rules

Cursor IDE automatically reads `.mdc` files in `.cursor/rules/` and applies them when:

- Generating code
- Refactoring code
- Answering questions about the codebase
- Making suggestions
- Completing code

The rules ensure the AI assistant:
- Follows project conventions
- Uses correct naming conventions
- Implements systems according to specifications
- Maintains code quality standards
- Follows Godot 4 best practices

---

## Updating Rules

When updating rules:

1. Edit the appropriate rule file in `rules/` directory
2. Rules are automatically applied by Cursor IDE
3. No restart needed (Cursor reloads rules automatically)

**Rule File Organization:**
- Edit `code-standards.mdc` for naming conventions and code structure
- Edit `godot-patterns.mdc` for Godot-specific patterns
- Edit `system-integration.mdc` for system communication patterns
- Edit `implementation-workflow.mdc` for workflow and references
- Edit `git-auto-commit.mdc` for Git commit workflow

---

## Related Documentation

- **Technical Specifications:** `../03-planning/technical-specs-*.md`
- **Implementation Checklists:** `checklists/phase-*.md`
- **Specification Standards:** `../03-planning/specification-standards.md`

---

**Last Updated:** 2025-11-25

