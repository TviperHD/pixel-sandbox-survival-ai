# AI Session Start Prompt

**Copy and paste this prompt at the beginning of each new AI coding session.**

---

## Session Start Instructions

You are helping implement a **2D pixel-art sandbox survival game** built in **Godot 4.x** using **GDScript**.

### Project Context

This is a complex game project with **33 fully-specified systems** ready for implementation. The game combines:
- **Noita-style pixel physics** (every pixel simulated)
- **Terraria-style survival** (exploration, crafting, building)
- **Arc Raiders-style AI** (deep learning enemies that adapt)

### Before You Start

**1. Read the Project Overview:**
- `PROJECT_OVERVIEW.md` - Complete project context, system overview, architecture

**2. Review the Cursor Rules:**
- `.cursor/rules/code-standards.mdc` - Naming conventions, code organization
- `.cursor/rules/godot-patterns.mdc` - Godot-specific patterns and best practices
- `.cursor/rules/system-integration.mdc` - How systems communicate
- `.cursor/rules/implementation-workflow.mdc` - Implementation workflow

**3. Check Current Phase:**
- Review `checklists/phase-*.md` files to see what phase we're on
- Check `IMPLEMENTATION_CHECKLIST.md` for overall progress

**4. Read Technical Specifications:**
- Before implementing ANY system, read its technical spec: `../03-planning/technical-specs-[system].md`
- See `../03-planning/technical-specs-index.md` for complete list

### Critical Rules

**ALWAYS:**
- ✅ Read technical specifications before implementing
- ✅ Follow naming conventions (PascalCase classes, snake_case variables/functions)
- ✅ Use type hints for ALL variables and functions
- ✅ Use Resources (.tres files) for data, not hardcoded values
- ✅ Make systems modular and configurable (@export variables)
- ✅ Handle errors properly (push_error, push_warning)
- ✅ Document code (class and function documentation)
- ✅ Test before marking complete
- ✅ Use signals for events, direct calls for queries
- ✅ Target 60+ FPS performance
- ✅ **Automatically commit changes to Git after making them** (see `GIT_AUTO_COMMIT.md`)

**NEVER:**
- ❌ Hardcode values
- ❌ Create god objects
- ❌ Skip error handling
- ❌ Ignore type hints
- ❌ Violate naming conventions
- ❌ Create circular dependencies
- ❌ Skip documentation
- ❌ Implement without checking specs
- ❌ Skip testing

### Implementation Workflow

For each system you implement:

1. **Read** the technical specification (`../03-planning/technical-specs-[system].md`)
2. **Check** the phase checklist (`checklists/phase-[N]-*.md`)
3. **Review** related systems (check dependencies)
4. **Follow** naming conventions (see `code-standards.mdc`)
5. **Use** Resources for data (create .tres files in editor)
6. **Make** it configurable (@export variables)
7. **Handle** errors (see `godot-patterns.mdc`)
8. **Document** code (class and function docs)
9. **Test** thoroughly (individual + integration)
10. **Verify** performance (60+ FPS target)
11. **Commit changes** automatically to Git (see `GIT_AUTO_COMMIT.md`)

### Project Structure

**STRICTLY follow this structure:**
```
game/
├── scenes/          # Scene files (PascalCase: Player.tscn)
├── scripts/         # Script files (snake_case: player_controller.gd)
├── assets/         # Assets (sprites, audio, fonts, particles)
├── resources/      # Resource files (.tres) organized by type
└── autoload/      # Autoload singletons (or scripts/managers/)
```

### Key Documentation Locations

- **Project Overview:** `PROJECT_OVERVIEW.md`
- **Technical Specs:** `../03-planning/technical-specs-*.md`
- **Spec Index:** `../03-planning/technical-specs-index.md`
- **Implementation Checklists:** `checklists/phase-*.md`
- **Main Checklist:** `IMPLEMENTATION_CHECKLIST.md`
- **Cursor Rules:** `.cursor/rules/*.mdc`

### System Dependencies

**Foundation Layer (must be first):**
- GameManager, InputManager, SettingsManager, PauseManager, ReferenceManager
- ItemDatabase (used by ALL systems)

**Then build in phases:**
- Phase 1: Foundation Systems
- Phase 2: Core Gameplay Systems
- Phase 3: World & Environment Systems
- Phase 4: AI & Progression Systems
- Phase 5: Content Systems
- Phase 6: UI/UX Systems
- Phase 7: Advanced Systems
- Phase 8: Integration & Testing
- Phase 9: Polish & Release

### When Asked to Implement Something

1. **Confirm** you've read the relevant technical specification
2. **Check** dependencies are already implemented
3. **Follow** the phase checklist for that system
4. **Implement** according to the spec (it's comprehensive and implementation-ready)
5. **Test** as you go
6. **Document** your code

### Code Examples

**Good Code:**
```gdscript
## Manages player inventory, including items, equipment, and storage containers.
class_name InventoryManager
extends Node

## Adds an item to the inventory.
## @param item_id: The ID of the item to add
## @param quantity: The quantity to add (default: 1)
## @return: True if item was added successfully, false otherwise
func add_item(item_id: String, quantity: int = 1) -> bool:
    if not ItemDatabase.has_item(item_id):
        push_error("Item '%s' not found" % item_id)
        return false
    
    # Implementation...
    return true
```

**Bad Code:**
```gdscript
func add_item(id, qty):
    # No type hints, no documentation, no error handling
    inventory[id] = qty
```

### Questions to Ask

If you're unsure about something:
1. Check the technical specification first
2. Check the phase checklist
3. Check the Cursor rules
4. Check PROJECT_OVERVIEW.md
5. Then ask the user for clarification

### Remember

- **Technical specifications are comprehensive** - they contain all implementation details
- **Follow the phase checklists** - they break down tasks step-by-step
- **Maintain modularity** - systems must work independently
- **Keep it configurable** - use @export and Resources
- **Test everything** - individual functions + integration
- **Document as you go** - don't leave it for later

---

**Ready to start? Check what phase we're on and what system needs to be implemented next.**

