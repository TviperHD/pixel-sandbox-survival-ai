# Phase 0: Foundation & Setup - Detailed Checklist

**Phase:** 0  
**Status:** Not Started  
**Dependencies:** None  
**Estimated Time:** 1-2 days

## Overview

This phase sets up the Godot project, configures project settings, creates the folder structure, and establishes the development environment. This is the foundation for all future development.

---

## Project Initialization

### 1. Create Godot Project
- [ ] Open Godot 4.x editor
- [ ] Create new project
- [ ] Choose 2D project template
- [ ] Set project name: `pixel-sandbox-survival-ai`
- [ ] Choose project location
- [ ] Initialize project

### 2. Configure Project Settings
- [ ] **Display > Window:**
  - [ ] Set Size: 640x360
  - [ ] Set Stretch Mode: `viewport`
  - [ ] Set Stretch Aspect: `keep`
  - [ ] Set Stretch Scale Mode: `integer`
  - [ ] Test window scaling
- [ ] **Rendering > Textures:**
  - [ ] Set Default Texture Filter: `Nearest`
  - [ ] Verify pixel art stays crisp
- [ ] **Rendering > 2D:**
  - [ ] Enable "Snap 2D Transforms to Pixel"
  - [ ] Enable "Snap 2D Vertices to Pixel"
  - [ ] Test pixel snapping

### 3. Version Control Setup
- [ ] Initialize Git repository (`git init`)
- [ ] Create `.gitignore` file for Godot
- [ ] Create `.gitignore` file with comprehensive Godot ignores:
  - [ ] Include Godot-specific ignores (.godot/, .import/, export_presets.cfg, etc.)
  - [ ] Include system files (.DS_Store, Thumbs.db, etc.)
  - [ ] Include IDE files (.vscode/, .idea/, etc.)
  - [ ] Include build files and temporary files
  - [ ] Include user-specific files (user://)
  - [ ] **Note:** See existing `.gitignore` in project root for complete list
- [ ] Make initial commit: "Initial project setup"
- [ ] Set up remote repository (if using GitHub/GitLab)
- [ ] Push initial commit

---

## Folder Structure Creation

### 4. Create Main Directories
- [ ] Create `scenes/` folder
- [ ] Create `scripts/` folder
- [ ] Create `assets/` folder
- [ ] Create `resources/` folder
- [ ] Create `autoload/` folder (or use `scripts/managers/`)

### 5. Create Subdirectories

#### Scenes Structure
- [ ] `scenes/player/` - Player scenes
- [ ] `scenes/enemies/` - Enemy scenes
- [ ] `scenes/npcs/` - NPC scenes
- [ ] `scenes/ui/` - UI scenes
- [ ] `scenes/world/` - World/environment scenes
- [ ] `scenes/items/` - Item pickup scenes
- [ ] `scenes/buildings/` - Building piece scenes
- [ ] `scenes/main/` - Main scene

#### Scripts Structure
- [ ] `scripts/player/` - Player scripts
- [ ] `scripts/managers/` - Manager singletons
- [ ] `scripts/enemies/` - Enemy scripts
- [ ] `scripts/npcs/` - NPC scripts
- [ ] `scripts/ui/` - UI scripts
- [ ] `scripts/world/` - World generation scripts
- [ ] `scripts/items/` - Item scripts
- [ ] `scripts/buildings/` - Building scripts
- [ ] `scripts/camera/` - Camera scripts
- [ ] `scripts/utils/` - Utility scripts

#### Assets Structure
- [ ] `assets/sprites/` - Sprite images
  - [ ] `assets/sprites/player/` - Player sprites
  - [ ] `assets/sprites/enemies/` - Enemy sprites
  - [ ] `assets/sprites/npcs/` - NPC sprites
  - [ ] `assets/sprites/items/` - Item sprites
    - [ ] `assets/sprites/items/icons/` - Item icon sprites (for inventory/UI)
    - [ ] `assets/sprites/items/world/` - Item world sprites (for ground items)
  - [ ] `assets/sprites/tiles/` - Tile sprites
  - [ ] `assets/sprites/ui/` - UI sprites
- [ ] `assets/audio/` - Audio files
  - [ ] `assets/audio/music/` - Music tracks
  - [ ] `assets/audio/sfx/` - Sound effects
- [ ] `assets/fonts/` - Font files
- [ ] `assets/particles/` - Particle effect resources

#### Resources Structure
- [ ] `resources/items/` - Item data resources
- [ ] `resources/config/` - Configuration resources (CommonItemsConfig, etc.)
- [ ] `resources/recipes/` - Crafting recipe resources
- [ ] `resources/buildings/` - Building piece resources
- [ ] `resources/dialogue/` - Dialogue data resources
- [ ] `resources/quests/` - Quest data resources
- [ ] `resources/biomes/` - Biome data resources
- [ ] `resources/materials/` - Pixel physics material resources
- [ ] `resources/settings/` - Settings resources

---

## Project Configuration

### 6. Pixel Art Configuration
- [ ] Verify viewport settings (640x360 base resolution)
- [ ] Test integer scaling (2x, 3x, 4x)
- [ ] Test different screen resolutions:
  - [ ] 1920x1080 (should scale 3x)
  - [ ] 1280x720 (should scale 2x)
  - [ ] 2560x1440 (should scale 4x)
- [ ] Verify pixel art stays crisp at all scales
- [ ] Test with sample pixel art sprite

### 7. Input Map Configuration
- [ ] Open Project Settings > Input Map
- [ ] Add action: `move_left`
  - [ ] Assign default key: A / Left Arrow
  - [ ] Assign controller: D-Pad Left / Left Stick Left
- [ ] Add action: `move_right`
  - [ ] Assign default key: D / Right Arrow
  - [ ] Assign controller: D-Pad Right / Left Stick Right
- [ ] Add action: `jump`
  - [ ] Assign default key: Space / W / Up Arrow
  - [ ] Assign controller: A Button / X Button
- [ ] Add action: `run`
  - [ ] Assign default key: Left Shift
  - [ ] Assign controller: Left Trigger
- [ ] Add action: `interact`
  - [ ] Assign default key: E
  - [ ] Assign controller: X Button / Y Button
- [ ] Add action: `attack`
  - [ ] Assign default key: Left Mouse Button
  - [ ] Assign controller: Right Trigger
- [ ] Add action: `inventory`
  - [ ] Assign default key: Tab
  - [ ] Assign controller: Select Button
- [ ] Add action: `craft`
  - [ ] Assign default key: C
  - [ ] Assign controller: (none initially)
- [ ] Add action: `build`
  - [ ] Assign default key: B
  - [ ] Assign controller: (none initially)
- [ ] Add action: `dig`
  - [ ] Assign default key: Right Mouse Button
  - [ ] Assign controller: Left Trigger
- [ ] Add action: `pause` (optional, can be handled by InputManager)
  - [ ] Assign default key: Escape
  - [ ] Assign controller: Start Button
- [ ] Test all input actions work:
  - [ ] Verify keyboard inputs register
  - [ ] Verify controller inputs register (if controller available)
  - [ ] **Note:** Full input handling will be implemented in Phase 1 via InputManager

### 8. Autoload Singletons Structure
- [ ] Plan autoload order (dependencies matter - initialization order is critical)
- [ ] Document autoload initialization order:
  - [ ] Order 1: `GameManager` (core game state)
  - [ ] Order 2: `InputManager` (input handling)
  - [ ] Order 3: `SettingsManager` (settings/configuration)
  - [ ] Order 4: `PauseManager` (pause system)
  - [ ] Order 5: `ReferenceManager` (node references)
  - [ ] Order 6: `ItemDatabase` (item data - Phase 1)
- [ ] Create placeholder scripts in `scripts/managers/` for:
  - [ ] `GameManager.gd` (will be implemented in Phase 1)
  - [ ] `InputManager.gd` (will be implemented in Phase 1)
  - [ ] `SettingsManager.gd` (will be implemented in Phase 1)
  - [ ] `PauseManager.gd` (will be implemented in Phase 1)
  - [ ] `ReferenceManager.gd` (will be implemented in Phase 1)
- [ ] **Note:** Actual implementation happens in Phase 1
- [ ] **Note:** ItemDatabase will be added in Phase 1, but structure should be ready

---

## Development Environment

### 9. Editor Configuration
- [ ] Configure editor theme (optional)
- [ ] Set up code editor preferences
- [ ] Configure GDScript formatting (if using formatter)
- [ ] Set up editor plugins (if any):
  - [ ] Pixel Art tools (optional)
  - [ ] Code formatter (optional)
  - [ ] Git integration (optional)

### 10. Documentation Setup
- [ ] Create `README.md` in project root (`game/README.md`)
- [ ] Document project structure
- [ ] Document setup instructions
- [ ] Link to technical specifications (in `../03-planning/`)
- [ ] Document development workflow
- [ ] **Note:** If using Cursor AI, ensure `.cursor/` folder exists (may already exist)

### 11. Testing Setup
- [ ] Create test scene for quick testing (`scenes/test/` or `scenes/main/TestScene.tscn`)
- [ ] Set up basic test environment:
  - [ ] Create simple scene with basic nodes
  - [ ] Test viewport scaling works
  - [ ] Test pixel art rendering
- [ ] Verify project runs without errors
- [ ] Test project export (optional, for later)
- [ ] **Note:** This is a basic test scene - full game scenes come in Phase 1+

---

## Verification Checklist

### Project Structure Verification
- [ ] All folders created correctly:
  - [ ] Main directories: `scenes/`, `scripts/`, `assets/`, `resources/`
  - [ ] Subdirectories: `scripts/managers/`, `scripts/camera/`, `scripts/utils/`, `scripts/player/`
  - [ ] Resources: `resources/items/`, `resources/config/` (required for Phase 1)
  - [ ] Assets: `assets/sprites/items/icons/`, `assets/sprites/items/world/` (required for Phase 1)
- [ ] Folder structure matches specification
- [ ] No typos in folder names
- [ ] All paths are lowercase (following conventions)
- [ ] Critical Phase 1 directories exist: `resources/config/`, `scripts/managers/`, `scripts/camera/`

### Configuration Verification
- [ ] Project settings configured correctly:
  - [ ] Display > Window: 640x360, viewport stretch, integer scaling
  - [ ] Rendering > Textures: Nearest filter
  - [ ] Rendering > 2D: Snap transforms/vertices enabled
- [ ] Pixel art settings working:
  - [ ] Test with sample sprite (if available)
  - [ ] Verify crisp rendering at different scales
- [ ] Input map configured:
  - [ ] All required actions added (move_left, move_right, jump, run, interact, attack, inventory, craft, build, dig)
  - [ ] Default keys assigned
  - [ ] Controller inputs assigned (where applicable)
- [ ] Window scaling works correctly:
  - [ ] Test at different resolutions (1920x1080, 1280x720, etc.)
  - [ ] Verify integer scaling (2x, 3x, 4x)
- [ ] Texture filtering set to Nearest

### Version Control Verification
- [ ] Git initialized
- [ ] `.gitignore` created and working
- [ ] Initial commit made
- [ ] Remote repository set up (if applicable)

### Documentation Verification
- [ ] README created
- [ ] Project structure documented
- [ ] Setup instructions clear
- [ ] Links to specs working

---

## Notes

- **Order Matters:** Complete steps in order, as later steps depend on earlier ones
- **Test Frequently:** Test each configuration change immediately
- **Document Everything:** Keep notes on any custom configurations
- **Version Control:** Commit after each major step

---

## Next Phase

After completing Phase 0, proceed to **Phase 1: Foundation Systems** where you'll implement:
- Player Controller
- Input System
- Camera System
- Game Manager
- Item Database System

---

**Last Updated:** 2025-11-25  
**Status:** Ready to Start

