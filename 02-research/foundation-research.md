# Foundation Systems Research

**Date:** 2025-11-24  
**Source:** Web research, Godot documentation, community resources

## Key Findings

- Godot 4 uses CharacterBody2D (not KinematicBody2D) for player movement
- Input system uses InputMap with actions (supports keyboard + controller)
- Camera2D follows player with smooth interpolation
- Autoload singletons for global game management
- Pixel art requires nearest-neighbor filtering
- Project structure: scenes/, scripts/, assets/ organization
- Scene-based architecture with reusable components

## Relevance

Foundation systems are the base everything else builds on. Must be solid, well-structured, and follow Godot 4 best practices.

## Links

- Godot Documentation: https://docs.godotengine.org
- Pixel Art Setup: https://gdquest.com/library/pixel_art_setup_godot4/
- Project Organization: https://docs.godotengine.org/en/stable/getting_started/workflow/project_setup/project_organization.html
- CharacterBody2D: https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html

---

## Foundation Components Needed

### 1. Project Structure
- Directory organization
- Scene hierarchy
- Script organization
- Asset management

### 2. Player Controller
- CharacterBody2D setup
- Movement (walk, run, jump)
- Input handling (keyboard + controller)
- Collision detection

### 3. Input System
- InputMap configuration
- Action definitions
- Input remapping support
- Dual input (keyboard + controller)

### 4. Camera System
- Camera2D setup
- Player following
- Smooth interpolation
- Limits/boundaries
- Viewport configuration

### 5. Game Manager (Autoload)
- Scene management
- Game state
- Global references
- System initialization

### 6. Pixel Art Configuration
- Texture filtering (nearest)
- Viewport settings
- Resolution handling
- Pixel-perfect rendering

---

## Research Details

### Project Structure

**Recommended Directory Layout:**
```
project/
├── scenes/
│   ├── main/
│   │   └── Main.tscn
│   ├── player/
│   │   └── Player.tscn
│   └── ui/
│       └── UI.tscn
├── scripts/
│   ├── player/
│   │   └── Player.gd
│   ├── managers/
│   │   └── GameManager.gd
│   └── systems/
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── fonts/
└── project.godot
```

### CharacterBody2D Movement (Snappy/Responsive)

**Key Points:**
- Godot 4 uses CharacterBody2D (replaces KinematicBody2D)
- Use `move_and_slide()` for movement
- Handle gravity and ground detection
- Support for slopes and stairs
- High acceleration/friction for snappy feel

**Snappy Movement Values:**
- **Acceleration:** 3000.0 (high for quick response)
- **Friction:** 2500.0 (high for quick stops)
- **Jump Velocity:** -500.0 (jumps ~2-3 tiles high, snappy)
- **Gravity:** 980.0 (standard)

**Movement Pattern:**
```gdscript
extends CharacterBody2D

const WALK_SPEED: float = 200.0
const RUN_SPEED: float = 400.0
const JUMP_VELOCITY: float = -500.0
const GRAVITY: float = 980.0
const ACCELERATION: float = 3000.0  # High for snappy
const FRICTION: float = 2500.0  # High for quick stops

func _physics_process(delta: float) -> void:
    # Apply gravity
    if not is_on_floor():
        velocity.y += GRAVITY * delta
    
    # Handle jump
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
    
    # Handle horizontal movement with acceleration/friction
    var input_dir: float = Input.get_axis("move_left", "move_right")
    var target_speed: float = RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED
    target_speed *= input_dir
    
    if input_dir != 0.0:
        velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
    
    move_and_slide()
```

### Input System

**InputMap Actions:**
- Define actions in Project Settings > Input Map
- Use action names, not key codes
- Supports multiple input devices
- Allows remapping

**Recommended Actions:**
- `move_left`, `move_right`, `move_up`, `move_down`
- `jump`
- `run` (sprint)
- `interact`
- `attack`
- `inventory`
- `craft`

### Camera System

**Camera2D Setup:**
- Follow player smoothly
- Set limits (if world has boundaries)
- Configure viewport
- Handle zoom (if needed)

**Smooth Following:**
```gdscript
extends Camera2D

@export var target: Node2D
@export var follow_speed: float = 5.0

func _process(delta: float) -> void:
    if target:
        global_position = global_position.lerp(target.global_position, follow_speed * delta)
```

### Autoload/Singleton

**GameManager Setup:**
- Add to Project Settings > Autoload
- Global access from anywhere
- Manages game state
- Handles scene transitions

### Pixel Art Configuration

**Settings:**
1. Project Settings > Rendering > Textures > Default Texture Filter = Nearest
2. Individual textures: Set filter to Nearest
3. Viewport: Configure stretch mode for pixel-perfect rendering

---

## Decisions Made

1. **Player Movement:**
   - Side-scrolling (like Terraria/Noita)
   - Physics-based movement
   - Actions: walk, run, jump, etc.

2. **Input:**
   - Both keyboard and controller from start
   - Remapping support: YES
   - Essential actions: move_left, move_right, jump, run, interact, attack, inventory, craft

3. **Camera:**
   - Smooth follow like Terraria
   - Zoom: YES
   - Limits: TBD (world boundaries?)

4. **Project Structure:**
   - Research best practices for large Godot projects
   - Use best naming conventions

5. **Pixel Art:**
   - Fit any resolution (adaptive scaling)
   - Viewport stretch mode: 2d
   - Stretch aspect: expand or keep
   - Integer scaling preferred for pixel-perfect rendering

---

## Research Findings

### Terraria-Style Camera

**Characteristics:**
- Smooth interpolation following player
- Deadzone (camera doesn't move until player moves certain distance)
- Zoom functionality (zoom in/out)
- Smooth transitions

**Implementation:**
- Camera2D with smoothing enabled
- Smoothing speed: ~5.0
- Deadzone for small movements
- Zoom via Camera2D.zoom property

### Best Project Structure (Large Games)

**Recommended Structure:**
```
project/
├── scenes/
│   ├── main/
│   ├── player/
│   ├── enemies/
│   ├── ui/
│   └── world/
├── scripts/
│   ├── player/
│   ├── managers/
│   ├── systems/
│   └── utils/
├── assets/
│   ├── sprites/
│   ├── audio/
│   ├── fonts/
│   └── shaders/
├── resources/
│   └── (reusable resources)
└── autoload/
    └── (singleton scripts)
```

### Naming Conventions (GDScript)

**Best Practices:**
- **Classes:** PascalCase (e.g., `PlayerController`, `GameManager`)
- **Variables:** snake_case (e.g., `player_speed`, `jump_velocity`)
- **Functions:** snake_case (e.g., `move_player()`, `handle_input()`)
- **Constants:** UPPER_SNAKE_CASE (e.g., `MAX_SPEED`, `GRAVITY`)
- **Nodes:** PascalCase (e.g., `Player`, `Camera2D`)
- **Scenes:** PascalCase (e.g., `Player.tscn`, `Main.tscn`)

### Pixel Art Scaling (Any Resolution)

**Best Configuration (Researched):**
- **Base Resolution:** **640x360** (Terraria-scale)
  - Scales cleanly to 1280x720 (2x), 1920x1080 (3x), etc.
  - Good balance of detail and performance
  - Works perfectly with integer scaling
  
- **Stretch Mode:** `viewport` (NOT `2d`)
  - Renders at base resolution, then scales
  - Better for pixel art than `2d` mode
  - Preserves pixel crispness
  
- **Stretch Aspect:** `keep`
  - Maintains 16:9 aspect ratio
  - May add black bars on non-16:9 screens
  - Prevents distortion (better than `expand` for pixel art)
  
- **Stretch Scale Mode:** `integer`
  - Scales by whole numbers (2x, 3x, 4x)
  - Prevents uneven pixel scaling
  - Maintains pixel art integrity
  
- **Texture Filter:** `Nearest` (globally and per-texture)

### Input System (Keyboard + Controller)

**InputMap Actions:**
- Define in Project Settings > Input Map
- Map to both keyboard and controller
- Support runtime remapping
- Use action names, not key codes

**Controller Support:**
- Godot automatically detects controllers
- Use same InputMap actions
- Test with multiple controller types

