# Project Overview

**Project:** Pixel Sandbox Survival AI  
**Engine:** Godot 4.x  
**Language:** GDScript (primary), Python (ML integration)  
**Status:** Ready for Implementation  
**Last Updated:** 2025-11-25

---

## What Is This Project?

This is a **2D pixel-art sandbox survival game** that combines three innovative systems:

1. **Noita-style Pixel Physics** - Every pixel is simulated, creating complete environmental destruction and interaction
2. **Terraria-style Survival** - Exploration, crafting, building, and progression mechanics
3. **Arc Raiders-style AI** - Enemies powered by deep learning that adapt and learn from player behavior

The game features procedurally generated worlds, complex crafting systems, multiplayer/co-op support, and enemies that evolve to create unique challenges with each playthrough.

---

## Game Concept

### Core Vision

Create an innovative survival game where:
- **Every pixel matters** - Complete environmental destruction and physics simulation
- **Enemies learn** - AI adapts to player tactics, creating dynamic encounters
- **Emergent gameplay** - Physics interactions create unexpected situations
- **Progressive difficulty** - AI naturally adapts to player skill level

### Target Audience

- Players who enjoy sandbox survival games (Terraria, Minecraft, Starbound)
- Fans of physics-based games (Noita, Worms)
- Gamers interested in AI-driven gameplay experiences
- Indie game enthusiasts looking for innovative mechanics

### Core Gameplay Loop

1. **Explore** - Discover procedurally generated worlds with destructible terrain
2. **Gather** - Collect resources from the environment
3. **Craft** - Build tools, weapons, and structures
4. **Survive** - Face AI enemies that learn from your tactics
5. **Adapt** - Develop new strategies as enemies evolve
6. **Build** - Create bases and structures in the destructible world

---

## Technical Architecture

### Technology Stack

- **Engine:** Godot 4.x (latest stable)
- **Primary Language:** GDScript
- **ML Integration:** Python 3.9+ with TensorFlow/PyTorch
- **ML Runtime:** TensorFlow Lite / ONNX Runtime (via Python subprocess)
- **Physics:** Godot Physics 2D (customized for pixel simulation)
- **Rendering:** Godot Sprite2D + TileMap
- **Version Control:** Git

### Architecture Layers

1. **Rendering & Presentation** - Sprite rendering, UI, camera
2. **Game Logic** - Player controller, survival, crafting, building, inventory
3. **Physics Simulation** - Pixel-level physics, materials, destruction, liquids/powders
4. **AI System** - Python-Godot bridge, ML model loading, enemy behavior, training pipeline
5. **World Management** - Procedural generation, chunk loading, persistence

### Key Design Principles

1. **Modularity** - Systems work independently with clear interfaces
2. **Configurability** - Everything is configurable via @export or Resources
3. **Performance** - Target 60+ FPS on mid-range hardware
4. **Extensibility** - Plugin-friendly architecture, modding support
5. **Data-Driven** - Use Resources (.tres files) instead of hardcoded data

---

## System Overview

### Foundation Systems (Phase 1)

**Foundation System:**
- Player Controller (CharacterBody2D, snappy movement)
- Input System (keyboard + controller, runtime remapping)
- Camera System (Terraria-style smooth follow, zoom)
- Game Manager (autoload singleton, state management)
- Pixel Art Configuration (640x360 base, integer scaling)

**Item Database System:**
- Centralized item management
- Resource-based item data (.tres files)
- Item lookup and query system
- Used by ALL systems that handle items

### Core Gameplay Systems (Phase 2)

**Survival System:**
- Health, hunger, thirst, temperature, radiation, oxygen, sleep
- Environmental effects and hazards
- Status effects integration

**Inventory System:**
- Expandable inventory (starts 20 slots)
- Hotbar (starts 8 slots, upgradeable)
- Equipment slots (Head, Chest, Legs, Feet + 3 accessories)
- Storage containers (placeable, individual access)
- Auto-pickup and auto-stacking

**Crafting System:**
- Instant crafting (with quantity support)
- Recipe discovery (found, learned, unlocked)
- Tech tree integration
- Ingredient refund on failure

**Building System:**
- Grid/freeform placement
- Modular building pieces
- Material refund on placement failure
- Structural integrity (optional)

**Combat System:**
- Melee, ranged, energy weapons
- Damage calculation with modifiers
- Armor and resistance system
- Boss fights with phases

**Status Effects System:**
- Per-effect stacking rules
- Buff/Debuff categories
- Stat modifier calculation
- Multiple curing methods

### World & Environment Systems (Phase 3)

**Pixel Physics System:**
- Pixel grid with chunking
- Material simulation (solids, liquids, powders, gases)
- Destruction system
- Chemical reactions (customizable)
- Performance optimization (spatial partitioning, multithreading)

**World Generation System:**
- Procedural terrain generation
- Biome system
- Structure placement (procedural templates)
- Resource distribution
- Cave generation
- Chunk loading/unloading

**Day/Night Cycle System:**
- Variable duration (biome/season dependent)
- Visual effects (lighting, sky color)
- Survival effects (temperature, visibility)
- Enemy spawn modifiers

**Weather System:**
- Normal + Sci-Fi weather types
- Biome-dependent weather
- Visual effects (particles, overlay)
- Survival and physics effects

### AI & Progression Systems (Phase 4)

**AI System:**
- Traditional AI (state machines, behavior trees)
- ML Integration (Python subprocess bridge)
- Hybrid training (pre-trained models + in-game fine-tuning)
- Observation/action systems
- Boss AI with phases

**Progression System:**
- XP from all activities
- Skill Tree (combat, survival, crafting, movement, passive, utility)
- Tech Tree (unlocks recipes, research time + level requirement)
- Achievements (all types, cosmetic rewards)

### Content Systems (Phase 5)

**NPC System:**
- NPC data and behavior (static, patrol, wander, guard, flee)
- Quest giving
- Dialogue management
- State persistence

**Dialogue System:**
- Dialogue trees with branching
- Conditional logic and variables
- Actions (set variables, start quests, give items)
- Speech bubble UI

**Quest System:**
- Main story, side, daily (5/day), repeatable, achievement, environmental
- Multiple objective types (kill, collect, reach, craft, build, etc.)
- Quest discovery (NPCs, environmental, notes, auto-start)
- Rewards (XP, items, currency, unlocks, reputation, recipes, skill points)

**Relationship System:**
- Reputation tiers (Stranger → Ally, with negative tiers)
- Reputation sources (quests, dialogue, actions)
- Benefits (trading discounts, unlock quests/items, story content)

**Trading/Economy System:**
- Dynamic pricing (relationship + supply/demand)
- Currency system (droppable items, currency slot)
- Barter system (items reduce purchase cost)
- NPC shop inventory (fixed core + rotating + relationship unlocks)

### UI/UX Systems (Phase 6)

**UI/UX System:**
- Main menu (New Game, Load Game, Settings, Quit)
- HUD (Health, Hunger, Thirst, Temperature, Minimap, Time/Day)
- Inventory UI (Tab key, semi-transparent overlay, no pause)
- Crafting UI (always visible when inventory open)
- Building UI (B key, building palette, grid overlay)
- Dialogue UI (speech bubbles, choices)
- Quest log and HUD indicators
- Settings menu (Graphics, Audio, Controls, Gameplay, Accessibility)
- Notification system (top-right, all types, stacking)
- Death screen (cause-specific messages, respawn)

**Minimap System:**
- Hybrid rendering (SubViewport + TileMap + Events + Fog)
- Real-time world updates
- Fog of war (radius + line of sight)
- Configurable markers
- Separate minimap (zoom only) and full map (zoom + pan)

**Item Pickup System:**
- Auto-pickup range (base + upgrades)
- Pull animation visual feedback
- Currency longer base range

**Tutorial/Onboarding System:**
- Progressive/contextual tutorials
- Hybrid format (text + visual + interactive)
- Hybrid triggers (automatic + contextual)
- Hybrid skipping (individual + all disable)

### Advanced Systems (Phase 7)

**Save System:**
- Multiple save slots
- Cloud save integration (Godot BaaS)
- Encryption and compression
- Version handling (multiple save versions simultaneously)

**Audio System:**
- Configurable buses (Master, Music, SFX + optional)
- Hybrid spatial audio (2D for UI, 3D for gameplay)
- Dynamic music (playlists + layers)
- Automatic sound pooling
- Priority-based playback

**Performance/Profiling System:**
- Comprehensive metrics (FPS, frame time, memory, CPU, GPU, network)
- Toggleable overlay
- Visual warnings
- Performance budgets per system
- Multiple export formats

**Debug/Development Tools System:**
- Advanced console (commands, variables, scripting)
- Comprehensive debug tools (scene inspector, visualizers, debug camera)
- Comprehensive time control (pause, slow motion, frame-by-frame)
- Comprehensive debug logging
- Security (setting to enable debug commands)

**Accessibility Features System:**
- Colorblind support
- Subtitles/captions
- Audio cues
- Screen reader support
- High contrast mode
- Motion reduction
- Text size scaling

**Localization/Translation System:**
- Godot's CSV-based translation system
- Support for 10 languages
- Runtime language switching
- Missing translation handling
- Text expansion management
- Font fallback

**Modding Support System:**
- Hybrid mod distribution (manual, in-game browser, Steam Workshop)
- Full modding capabilities (content, scripts, assets, UI, shaders)
- Multiple scripting languages (GDScript, C#, visual scripting)
- Dependency-based load order
- Priority-based conflict resolution
- Sandboxed security with permission system

**Multiplayer/Co-op System:**
- Both local and online multiplayer (coop-focused with PvP option)
- Hybrid network (P2P default, optional dedicated servers)
- Host-authoritative world + client-side prediction
- Hybrid saves (world + character)
- Character locking option per world
- Full modding support
- Anti-cheat measures
- Text chat system

---

## System Relationships

### Dependency Hierarchy

```
Foundation Layer:
├── GameManager
├── InputManager
├── SettingsManager
├── PauseManager
└── ReferenceManager

Data Layer:
└── ItemDatabase (used by ALL systems)

Core Gameplay Layer:
├── SurvivalManager
├── InventoryManager
├── CraftingManager
├── BuildingManager
├── CombatManager
└── StatusEffectManager

World Layer:
├── PixelPhysicsManager
├── WorldGenerator
├── TimeManager
└── WeatherManager

AI & Progression Layer:
├── EnemyAI (uses CombatManager)
├── MLAgent (Python bridge)
└── ProgressionManager

Content Layer:
├── NPCManager
├── DialogueManager
├── QuestManager
├── RelationshipManager
└── TradingManager

UI Layer:
├── UIManager
├── MinimapManager
├── ItemPickupManager
└── TutorialManager

Advanced Layer:
├── SaveManager
├── AudioManager
├── PerformanceProfiler
├── DebugConsole
├── AccessibilityManager
├── LocalizationManager
├── ModManager
└── MultiplayerManager
```

### Key Integration Points

- **ItemDatabase** → Used by Inventory, Crafting, Combat, Building, Progression, Quest, Save
- **InventoryManager** → Used by Crafting, Building, Combat, Trading, ItemPickup
- **SurvivalManager** → Used by Combat, Quest, Weather, Day/Night Cycle
- **CombatManager** → Uses Inventory, StatusEffects, Progression
- **CraftingManager** → Uses ItemDatabase, Inventory, Progression (Tech Tree)
- **ProgressionManager** → Used by Combat, Crafting, Quest, Achievement
- **QuestManager** → Uses NPC, Dialogue, Inventory, Crafting, Building, Combat, Survival
- **WorldGenerator** → Used by PixelPhysics, Minimap, ResourceGathering

---

## Development Standards

### Code Standards

**Naming Conventions:**
- Classes: PascalCase (`PlayerController`, `GameManager`)
- Variables: snake_case (`player_speed`, `is_running`)
- Functions: snake_case (`handle_input()`, `apply_damage()`)
- Constants: UPPER_SNAKE_CASE (`WALK_SPEED`, `GRAVITY`)
- Scenes: PascalCase (`Player.tscn`, `Main.tscn`)
- Scripts: snake_case (`player_controller.gd`)

**Type Hints:** ALWAYS required
```gdscript
var health: int = 100
func move_player(direction: Vector2) -> void
```

**Code Organization:** Follow standard structure (constants, signals, exports, variables, functions)

### Implementation Standards

**Modularity:**
- Systems work independently
- Clear interfaces between systems
- Easy to add/remove features
- Component-based architecture

**Configurability:**
- Use `@export` for configuration
- Use Resource files (.tres) for data
- No hardcoded values
- Easy to tweak without code changes

**Resource-Based Design:**
- ALWAYS use Resources for data
- Create resources in editor, not code
- Use Resource.duplicate() for runtime instances

### Godot Patterns

**Autoload Order:**
1. GameManager
2. InputManager
3. SettingsManager
4. PauseManager
5. ReferenceManager
6. Other managers

**Signals vs Direct Calls:**
- Signals for events (decoupled, one-way)
- Direct calls for queries (simple, efficient, return values)

**Performance:**
- Target 60+ FPS
- Use object pooling for frequent objects
- Limit physics bodies
- Use appropriate update methods (_process vs _physics_process)

**Error Handling:**
- Always handle errors
- Use `push_error()` for errors
- Use `push_warning()` for warnings
- Return early on errors (fail fast)

---

## Important Constraints

### Performance Targets

- **Frame Rate:** 60+ FPS minimum
- **Physics Rate:** 60 Hz (default)
- **Input Latency:** < 16ms (1 frame)
- **ML Inference:** < 16ms per frame
- **Memory:** Monitor for leaks, use profiler

### Pixel Art Configuration

- **Base Resolution:** 640x360
- **Stretch Mode:** viewport
- **Stretch Aspect:** keep
- **Stretch Scale Mode:** integer
- **Texture Filter:** Nearest
- **Snap 2D Transforms:** Enabled
- **Snap 2D Vertices:** Enabled

### Project Structure

**STRICTLY follow directory structure:**
- `scenes/` - All scene files organized by type
- `scripts/` - All scripts organized by system
- `assets/` - All assets (sprites, audio, fonts, particles)
- `resources/` - All resource files (.tres) organized by type
- `autoload/` or `scripts/managers/` - Autoload singleton scripts

---

## Documentation Structure

### Technical Specifications

**Location:** `../03-planning/technical-specs-*.md`

**33 Complete Specifications:**
- Foundation, Item Database, Interaction, Resource Gathering, Dialogue, NPC
- Survival, Inventory, Crafting, Building, Combat, Status Effects
- Pixel Physics, World Generation, Day/Night Cycle, Weather
- AI System, Progression
- Quest, Relationship, Trading/Economy
- UI/UX, Minimap, Item Pickup, Tutorial/Onboarding
- Save System, Audio, Performance/Profiling, Debug Tools
- Accessibility, Localization, Modding, Multiplayer

**Index:** `../03-planning/technical-specs-index.md`

### Implementation Checklists

**Location:** `checklists/phase-*.md`

**10 Phase Checklists:**
- Phase 0: Foundation & Setup
- Phase 1: Foundation Systems
- Phase 2: Core Gameplay Systems
- Phase 3: World & Environment Systems
- Phase 4: AI & Progression Systems
- Phase 5: Content Systems
- Phase 6: UI/UX Systems
- Phase 7: Advanced Systems
- Phase 8: Integration & Testing
- Phase 9: Polish & Release

**Navigation:** `checklists/README.md`

### Cursor Rules

**Location:** `.cursor/rules/*.mdc`

**4 Rule Files:**
- `code-standards.mdc` - Naming conventions, code organization
- `godot-patterns.mdc` - Godot-specific patterns and best practices
- `system-integration.mdc` - How systems communicate
- `implementation-workflow.mdc` - Implementation workflow and references

---

## Implementation Workflow

### Before Starting Any System

1. **Read the technical specification** (`../03-planning/technical-specs-[system].md`)
2. **Check the phase checklist** (`checklists/phase-[N]-*.md`)
3. **Review related systems** (check dependencies and integration points)
4. **Follow naming conventions** (see `.cursor/rules/code-standards.mdc`)
5. **Use Resources for data** (create .tres files in editor)
6. **Make it configurable** (use @export variables)
7. **Handle errors** (see `.cursor/rules/godot-patterns.mdc`)
8. **Document code** (class and function documentation)
9. **Test thoroughly** (individual functions + integration)
10. **Verify performance** (60+ FPS target)

### Critical Rules

**DO:**
✅ Always read technical specifications first  
✅ Always follow naming conventions  
✅ Always use type hints  
✅ Always use Resources for data  
✅ Always make systems modular and configurable  
✅ Always handle errors  
✅ Always document code  
✅ Always test before marking complete  
✅ Always use @export for configuration  
✅ Always use signals for events  

**DON'T:**
❌ Don't hardcode values  
❌ Don't create god objects  
❌ Don't skip error handling  
❌ Don't ignore type hints  
❌ Don't violate naming conventions  
❌ Don't create circular dependencies  
❌ Don't skip documentation  
❌ Don't implement without checking specs  
❌ Don't skip testing  
❌ Don't use direct calls for events (use signals)  

---

## Key Principles

### Modularity

Every system must:
- Work independently
- Have clear interfaces
- Be easy to add/remove
- Use component-based architecture

### Configurability

Everything must be:
- Configurable via @export or Resources
- Easy to tweak without code changes
- Data-driven (Resources, not hardcoded)

### Performance

Always consider:
- 60+ FPS target
- Efficient algorithms
- Object pooling
- Appropriate update frequencies
- Memory management

### Documentation

Always provide:
- Class documentation (## comments)
- Function documentation (@param, @return)
- Complex logic comments
- Integration point documentation

---

## Remember

**The technical specifications are comprehensive and implementation-ready.** They contain all the information needed to implement each system correctly. Always refer to them before implementing.

**Key Points:**
- This is a complex project with 33 systems
- All systems are fully specified and ready for implementation
- Follow the phase checklists for detailed tasks
- Maintain modularity and configurability
- Test everything thoroughly
- Target 60+ FPS performance

**Start with Phase 0 (Foundation & Setup), then proceed through phases sequentially.**

---

**For detailed information, see:**
- Technical Specifications: `../03-planning/technical-specs-index.md`
- Implementation Checklists: `checklists/README.md`
- Code Standards: `.cursor/rules/code-standards.mdc`
- Godot Patterns: `.cursor/rules/godot-patterns.mdc`
- System Integration: `.cursor/rules/system-integration.mdc`
- Implementation Workflow: `.cursor/rules/implementation-workflow.mdc`

