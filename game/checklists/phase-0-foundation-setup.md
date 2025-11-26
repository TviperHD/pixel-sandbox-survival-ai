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
- [ ] Add `.gitignore` contents:
  ```
  # Godot-specific ignores
  .godot/
  *.tmp
  *.import
  .import/
  export_presets.cfg
  
  # System files
  .DS_Store
  Thumbs.db
  
  # IDE files
  .vscode/
  .idea/
  *.swp
  *.swo
  
  # Build files
  bin/
  build/
  ```
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
  - [ ] `assets/sprites/tiles/` - Tile sprites
  - [ ] `assets/sprites/ui/` - UI sprites
- [ ] `assets/audio/` - Audio files
  - [ ] `assets/audio/music/` - Music tracks
  - [ ] `assets/audio/sfx/` - Sound effects
- [ ] `assets/fonts/` - Font files
- [ ] `assets/particles/` - Particle effect resources

#### Resources Structure
- [ ] `resources/items/` - Item data resources
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
- [ ] Test all input actions work

### 8. Autoload Singletons Structure
- [ ] Plan autoload order (dependencies)
- [ ] Document autoload initialization order
- [ ] Create placeholder scripts for:
  - [ ] `GameManager.gd`
  - [ ] `InputManager.gd`
  - [ ] `SettingsManager.gd`
  - [ ] `PauseManager.gd`
  - [ ] `ReferenceManager.gd`
- [ ] **Note:** Actual implementation happens in Phase 1

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
- [ ] Create `README.md` in project root
- [ ] Document project structure
- [ ] Document setup instructions
- [ ] Link to technical specifications
- [ ] Document development workflow

### 11. Testing Setup
- [ ] Create test scene for quick testing
- [ ] Set up basic test environment
- [ ] Verify project runs without errors
- [ ] Test project export (optional, for later)

---

## Verification Checklist

### Project Structure Verification
- [ ] All folders created correctly
- [ ] Folder structure matches specification
- [ ] No typos in folder names
- [ ] All paths are lowercase (following conventions)

### Configuration Verification
- [ ] Project settings configured correctly
- [ ] Pixel art settings working
- [ ] Input map configured
- [ ] Window scaling works correctly
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

