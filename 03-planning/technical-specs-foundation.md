# Technical Specifications: Foundation Systems

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the foundation systems: project structure, player controller, input system, camera, game manager, and pixel art configuration.

---

## Research Notes

### CharacterBody2D Movement Best Practices

**Research Findings:**
- CharacterBody2D is the recommended node for 2D platformer movement in Godot 4
- `move_and_slide()` handles collision automatically and returns collision information
- Acceleration/friction approach provides snappy, responsive controls
- Coyote time and jump buffering are industry-standard techniques for better feel

**Sources:**
- [Godot 4 CharacterBody2D Documentation](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) - Official documentation
- [Godot 4 2D Movement Tutorial](https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html) - Official movement tutorial

**Implementation Approach:**
- Use CharacterBody2D with custom movement logic
- Apply acceleration/friction for snappy controls
- Implement coyote time (0.15s) and jump buffering (0.1s)
- Use `move_and_slide()` for collision handling

**Why This Approach:**
- CharacterBody2D provides better control than RigidBody2D for platformers
- Acceleration/friction gives responsive, snappy feel
- Coyote time and jump buffering improve player experience significantly

### Input System Best Practices

**Research Findings:**
- InputMap is the recommended way to handle input in Godot 4
- Runtime remapping requires storing events and rebuilding InputMap
- ConfigFile is best for persisting input settings
- Wrapper functions provide abstraction and easier remapping

**Sources:**
- [Godot 4 InputMap Documentation](https://docs.godotengine.org/en/stable/classes/class_inputmap.html) - Official InputMap docs
- [Godot 4 Input Remapping Tutorial](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html) - Input examples

**Implementation Approach:**
- Use InputMap for all actions
- Store remaps in ConfigFile
- Provide wrapper functions for input checking
- Support both keyboard and controller

**Why This Approach:**
- InputMap allows runtime remapping
- ConfigFile provides persistent storage
- Wrapper functions enable easy remapping without code changes

### Camera System Best Practices

**Research Findings:**
- Camera2D with manual deadzone calculation provides best control
- Lerp-based smoothing gives smooth camera movement
- Deadzone prevents camera jitter from small movements
- Limit clamping prevents camera from going out of bounds

**Sources:**
- [Godot 4 Camera2D Documentation](https://docs.godotengine.org/en/stable/classes/class_camera2d.html) - Official Camera2D docs
- Terraria-style camera tutorials - Industry standard approach

**Implementation Approach:**
- Manual deadzone calculation (distance check)
- Lerp-based smoothing with configurable speed
- Limit clamping for boundaries
- Zoom support with mouse wheel

**Why This Approach:**
- Manual calculation gives precise control
- Matches Terraria-style camera behavior
- Smooth and responsive feel

### Pixel Art Configuration Best Practices

**Research Findings:**
- Viewport stretch mode with integer scaling is best for pixel art
- Base resolution should scale cleanly (640x360 = 16:9, scales 2x, 3x, 4x)
- Nearest-neighbor filtering preserves pixel art crispness
- Snap 2D transforms/vertices to pixel prevents sub-pixel rendering

**Sources:**
- [Godot 4 Viewport Stretch Documentation](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html) - Resolution handling
- [Godot 4 Pixel Art Best Practices](https://docs.godotengine.org/en/stable/tutorials/2d/pixel_perfect.html) - Pixel art guide

**Implementation Approach:**
- Base resolution: 640x360 (Terraria-scale)
- Stretch mode: viewport
- Stretch aspect: keep
- Stretch scale mode: integer
- Texture filter: Nearest
- Snap 2D transforms/vertices: Enabled

**Why This Approach:**
- 640x360 scales perfectly to common resolutions
- Integer scaling prevents pixel distortion
- Nearest filtering preserves crispness
- Snap prevents blurry sub-pixel rendering

### Autoload Singleton Best Practices

**Research Findings:**
- Autoload singletons initialize before scenes load
- Order matters - dependencies must load first
- Signals provide decoupled communication
- Direct calls are fine for queries

**Sources:**
- [Godot 4 Autoload Documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Autoload guide

**Implementation Approach:**
- Modular managers (GameManager, PauseManager, SettingsManager, ReferenceManager)
- Hybrid communication (signals for events, direct calls for queries)
- Proper initialization order

**Why This Approach:**
- Modular design prevents god objects
- Hybrid communication balances decoupling and simplicity
- Clear responsibilities for each manager

---

## Project Structure

### Directory Organization

```
pixel-sandbox-survival-ai/
├── scenes/
│   ├── main/
│   │   └── Main.tscn
│   ├── player/
│   │   └── Player.tscn
│   ├── enemies/
│   ├── ui/
│   │   ├── HUD.tscn
│   │   └── Menu.tscn
│   └── world/
│       └── World.tscn
├── scripts/
│   ├── player/
│   │   ├── PlayerController.gd
│   │   └── PlayerStats.gd
│   ├── managers/
│   │   ├── GameManager.gd
│   │   ├── InputManager.gd
│   │   ├── PauseManager.gd
│   │   ├── SettingsManager.gd
│   │   └── ReferenceManager.gd
│   ├── camera/
│   │   └── CameraController.gd
│   ├── systems/
│   │   ├── SurvivalSystem.gd
│   │   ├── CombatSystem.gd
│   │   └── CraftingSystem.gd
│   └── utils/
│       └── Helpers.gd
├── assets/
│   ├── sprites/
│   │   ├── player/
│   │   ├── enemies/
│   │   └── tiles/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   ├── fonts/
│   └── shaders/
├── resources/
│   └── (reusable resources)
└── autoload/
    └── (singleton scripts)
```

### Naming Conventions

- **Classes:** PascalCase (`PlayerController`, `GameManager`)
- **Variables:** snake_case (`player_speed`, `jump_velocity`)
- **Functions:** snake_case (`move_player()`, `handle_input()`)
- **Constants:** UPPER_SNAKE_CASE (`MAX_SPEED`, `GRAVITY`)
- **Nodes:** PascalCase (`Player`, `Camera2D`)
- **Scenes:** PascalCase (`Player.tscn`, `Main.tscn`)
- **Files:** snake_case for scripts, PascalCase for scenes

---

## Player Controller

### PlayerController

```gdscript
class_name PlayerController
extends CharacterBody2D

# Movement Constants (Snappy/Responsive)
const WALK_SPEED: float = 200.0
const RUN_SPEED: float = 400.0
const JUMP_VELOCITY: float = -500.0  # Snappy jump (jumps ~2-3 tiles high)
const GRAVITY: float = 980.0
const ACCELERATION: float = 3000.0  # High acceleration for snappy feel
const FRICTION: float = 2500.0  # High friction for quick stops

# State
var is_running: bool = false
var is_jumping: bool = false
var is_on_ground: bool = true
var coyote_time: float = 0.0
var coyote_time_max: float = 0.15
var jump_buffer_time: float = 0.0
var jump_buffer_max: float = 0.1

# Components
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Functions
func _ready() -> void
func _physics_process(delta: float) -> void
func handle_input() -> void
func apply_gravity(delta: float) -> void
func handle_movement(delta: float) -> void
func handle_jump() -> void
func update_animations() -> void
func check_ground() -> bool
```

### Movement Algorithm

```gdscript
func _physics_process(delta: float) -> void:
    # Apply gravity
    apply_gravity(delta)
    
    # Handle input
    handle_input()
    
    # Handle movement
    handle_movement(delta)
    
    # Handle jump
    handle_jump()
    
    # Move and slide
    move_and_slide()
    
    # Update state
    is_on_ground = is_on_floor()
    update_animations()

func handle_input() -> void:
    # Get input direction
    var input_dir: float = Input.get_axis("move_left", "move_right")
    
    # Check run
    is_running = Input.is_action_pressed("run")
    
    # Calculate target speed
    var target_speed: float = RUN_SPEED if is_running else WALK_SPEED
    target_speed *= input_dir
    
    # Apply acceleration/friction
    if input_dir != 0.0:
        velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
    
    # Jump buffer
    if Input.is_action_just_pressed("jump"):
        jump_buffer_time = jump_buffer_max
    else:
        jump_buffer_time = max(0.0, jump_buffer_time - delta)
    
    # Coyote time
    if is_on_floor():
        coyote_time = coyote_time_max
    else:
        coyote_time = max(0.0, coyote_time - delta)

func apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y += GRAVITY * delta
    else:
        velocity.y = 0.0

func handle_jump() -> void:
    if jump_buffer_time > 0.0 and (is_on_floor() or coyote_time > 0.0):
        velocity.y = JUMP_VELOCITY
        jump_buffer_time = 0.0
        coyote_time = 0.0
        is_jumping = true

func handle_movement(delta: float) -> void:
    # Movement is handled in handle_input() via velocity.x
    # This function is called for consistency but movement logic is in handle_input()
    pass

func update_animations() -> void:
    if animation_player == null:
        return
    
    # Update sprite direction
    if sprite != null:
        if velocity.x < 0:
            sprite.flip_h = true
        elif velocity.x > 0:
            sprite.flip_h = false
    
    # Update animation based on state
    if is_on_ground:
        if abs(velocity.x) > 0.1:
            if is_running:
                animation_player.play("run")
            else:
                animation_player.play("walk")
        else:
            animation_player.play("idle")
    else:
        if velocity.y < 0:
            animation_player.play("jump")
        else:
            animation_player.play("fall")

func check_ground() -> bool:
    return is_on_floor()

func _ready() -> void:
    # Ensure components exist
    if sprite == null:
        sprite = get_node_or_null("Sprite2D")
    if collision_shape == null:
        collision_shape = get_node_or_null("CollisionShape2D")
    if animation_player == null:
        animation_player = get_node_or_null("AnimationPlayer")
    
    # Register with ReferenceManager
    if ReferenceManager:
        ReferenceManager.register_player(self)
```

---

## Input System

### InputMap Configuration

**Actions to Define:**
- `move_left` - Left movement (A, Left Arrow)
- `move_right` - Right movement (D, Right Arrow)
- `jump` - Jump action (Space, W, Up Arrow)
- `run` - Run/sprint (Left Shift)
- `interact` - Interact with objects (E)
- `attack` - Attack action (X, Left Mouse Button)
- `inventory` - Open inventory (Tab, I)
- `craft` - Open crafting menu (C)
- `build` - Enter build mode (B)
- `dig` - Dig/destroy terrain (Left Mouse Button)
- `zoom_in` - Zoom in (Mouse Wheel Up, =)
- `zoom_out` - Zoom out (Mouse Wheel Down, -)

**Default Mappings:**
- **Keyboard:**
  - Movement: WASD or Arrow Keys
  - Jump: Space, W, or Up Arrow
  - Run: Left Shift
  - Interact: E
  - Attack: X or Left Mouse Button
  - Inventory: Tab or I
  - Craft: C
  - Build: B
  - Zoom: Mouse Wheel or =/-
- **Controller:**
  - Movement: D-pad or Left Stick
  - Jump: A Button
  - Run: Left Trigger or Left Shoulder
  - Interact: X Button
  - Attack: Right Trigger or Right Shoulder
  - Inventory: Y Button
  - Craft: B Button
  - Build: Select Button

### InputManager

```gdscript
class_name InputManager
extends Node

# Input Actions
var actions: Dictionary = {}

# Remapping
var key_remaps: Dictionary = {}
var controller_remaps: Dictionary = {}

# Functions
func _ready() -> void
func initialize_input_map() -> void
func remap_action(action_name: String, event: InputEvent) -> void
func get_action_input(action_name: String) -> InputEvent
func is_action_pressed(action_name: String) -> bool
func is_action_just_pressed(action_name: String) -> bool
func get_axis(negative_action: String, positive_action: String) -> float
func save_input_settings() -> void
func load_input_settings() -> void
```

### InputManager Complete Implementation

```gdscript
class_name InputManager
extends Node

# Input Actions
var actions: Dictionary = {}

# Remapping
var key_remaps: Dictionary = {}
var controller_remaps: Dictionary = {}

# Config File Path
const INPUT_SETTINGS_PATH: String = "user://input_settings.cfg"

# Signals
signal action_remapped(action_name: String, event: InputEvent)

func _ready() -> void:
    initialize_input_map()
    load_input_settings()

func initialize_input_map() -> void:
    # Define default actions if they don't exist
    var default_actions: Dictionary = {
        "move_left": [KEY_A, KEY_LEFT],
        "move_right": [KEY_D, KEY_RIGHT],
        "jump": [KEY_SPACE, KEY_W, KEY_UP],
        "run": [KEY_SHIFT],
        "interact": [KEY_E],
        "attack": [KEY_X, MOUSE_BUTTON_LEFT],
        "inventory": [KEY_TAB, KEY_I],
        "craft": [KEY_C],
        "build": [KEY_B],
        "dig": [MOUSE_BUTTON_LEFT]
    }
    
    # Create actions in InputMap
    for action_name in default_actions.keys():
        if not InputMap.has_action(action_name):
            InputMap.add_action(action_name)
            # Add default key mappings
            for key in default_actions[action_name]:
                var event: InputEvent
                if key is int:  # Key constant
                    event = InputEventKey.new()
                    event.keycode = key
                elif key is String:  # Mouse button
                    event = InputEventMouseButton.new()
                    if key == "MOUSE_BUTTON_LEFT":
                        event.button_index = MOUSE_BUTTON_LEFT
                    elif key == "MOUSE_BUTTON_RIGHT":
                        event.button_index = MOUSE_BUTTON_RIGHT
                InputMap.action_add_event(action_name, event)

func remap_action(action_name: String, event: InputEvent) -> void:
    if not InputMap.has_action(action_name):
        push_error("Action '%s' does not exist in InputMap" % action_name)
        return
    
    # Remove old mappings
    InputMap.action_erase_events(action_name)
    
    # Add new mapping
    InputMap.action_add_event(action_name, event)
    
    # Store remap
    if event is InputEventKey:
        key_remaps[action_name] = event
    elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
        controller_remaps[action_name] = event
    
    # Save settings
    save_input_settings()
    
    # Emit signal
    action_remapped.emit(action_name, event)

func get_action_input(action_name: String) -> InputEvent:
    if not InputMap.has_action(action_name):
        push_error("Action '%s' does not exist" % action_name)
        return null
    
    var events: Array = InputMap.action_get_events(action_name)
    if events.size() > 0:
        return events[0]
    return null

func is_action_pressed(action_name: String) -> bool:
    if not InputMap.has_action(action_name):
        push_error("Action '%s' does not exist" % action_name)
        return false
    return Input.is_action_pressed(action_name)

func is_action_just_pressed(action_name: String) -> bool:
    if not InputMap.has_action(action_name):
        push_error("Action '%s' does not exist" % action_name)
        return false
    return Input.is_action_just_pressed(action_name)

func is_action_just_released(action_name: String) -> bool:
    if not InputMap.has_action(action_name):
        push_error("Action '%s' does not exist" % action_name)
        return false
    return Input.is_action_just_released(action_name)

func get_axis(negative_action: String, positive_action: String) -> float:
    return Input.get_axis(negative_action, positive_action)

func save_input_settings() -> void:
    var config: ConfigFile = ConfigFile.new()
    
    # Save key remaps
    for action_name in key_remaps.keys():
        var event: InputEventKey = key_remaps[action_name]
        config.set_value("key_remaps", action_name, event.keycode)
    
    # Save controller remaps
    for action_name in controller_remaps.keys():
        var event = controller_remaps[action_name]
        if event is InputEventJoypadButton:
            config.set_value("controller_remaps", action_name + "_button", event.button_index)
        elif event is InputEventJoypadMotion:
            config.set_value("controller_remaps", action_name + "_axis", event.axis)
    
    var err: Error = config.save(INPUT_SETTINGS_PATH)
    if err != OK:
        push_error("Failed to save input settings: %s" % error_string(err))

func load_input_settings() -> void:
    var config: ConfigFile = ConfigFile.new()
    var err: Error = config.load(INPUT_SETTINGS_PATH)
    
    if err != OK:
        # No saved settings, use defaults
        return
    
    # Load key remaps
    if config.has_section("key_remaps"):
        for action_name in config.get_section_keys("key_remaps"):
            var keycode: int = config.get_value("key_remaps", action_name)
            var event: InputEventKey = InputEventKey.new()
            event.keycode = keycode
            remap_action(action_name, event)
    
    # Load controller remaps
    if config.has_section("controller_remaps"):
        var processed_actions: Array = []
        for key in config.get_section_keys("controller_remaps"):
            var action_name: String = key.replace("_button", "").replace("_axis", "")
            if action_name in processed_actions:
                continue
            
            processed_actions.append(action_name)
            var event: InputEvent
            if key.ends_with("_button"):
                event = InputEventJoypadButton.new()
                event.button_index = config.get_value("controller_remaps", key)
            elif key.ends_with("_axis"):
                event = InputEventJoypadMotion.new()
                event.axis = config.get_value("controller_remaps", key)
            
            if event:
                remap_action(action_name, event)
```

---

## Camera System

### CameraController

```gdscript
class_name CameraController
extends Camera2D

# Target
@export var target: Node2D

# Smoothing
@export var smoothing_enabled: bool = true
@export var smoothing_speed: float = 5.0

# Deadzone (like Terraria) - camera doesn't move until player moves this distance
@export var deadzone_size: Vector2 = Vector2(50.0, 50.0)  # Terraria-style deadzone

# Limits
@export var limit_left: float = -1000000.0
@export var limit_right: float = 1000000.0
@export var limit_top: float = -1000000.0
@export var limit_bottom: float = 1000000.0

# Zoom
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_step: float = 0.1
@export var current_zoom: float = 1.0

# Functions
func _ready() -> void
func _process(delta: float) -> void
func follow_target(delta: float) -> void
func zoom_in() -> void
func zoom_out() -> void
func set_zoom(zoom_level: float) -> void
func update_limits(left: float, right: float, top: float, bottom: float) -> void
```

### Camera Follow Algorithm (Terraria-Style)

```gdscript
func _process(delta: float) -> void:
    # Handle zoom input (mouse wheel)
    handle_zoom_input()
    
    if target == null:
        return
    
    var target_pos: Vector2 = target.global_position
    var current_pos: Vector2 = global_position
    
    # Calculate distance from camera center
    var offset: Vector2 = target_pos - current_pos
    
    # Deadzone check
    if abs(offset.x) > deadzone_size.x or abs(offset.y) > deadzone_size.y:
        # Move camera
        if smoothing_enabled:
            global_position = global_position.lerp(target_pos, smoothing_speed * delta)
        else:
            global_position = target_pos
    
    # Clamp to limits
    global_position.x = clamp(global_position.x, limit_left, limit_right)
    global_position.y = clamp(global_position.y, limit_top, limit_bottom)

func handle_zoom_input() -> void:
    # Handle mouse wheel zoom
    var zoom_input: float = Input.get_axis("zoom_out", "zoom_in")
    if zoom_input != 0.0:
        set_zoom(current_zoom + (zoom_input * zoom_step))
    
    # Alternative: Direct mouse wheel handling
    # if Input.is_action_just_released("zoom_in"):
    #     zoom_in()
    # elif Input.is_action_just_released("zoom_out"):
    #     zoom_out()

func zoom_in() -> void:
    set_zoom(current_zoom - zoom_step)

func zoom_out() -> void:
    set_zoom(current_zoom + zoom_step)

func set_zoom(zoom_level: float) -> void:
    current_zoom = clamp(zoom_level, min_zoom, max_zoom)
    zoom = Vector2(current_zoom, current_zoom)

func _ready() -> void:
    # Set target to parent if not already set
    if target == null:
        target = get_parent() as Node2D
    
    # Set initial zoom
    zoom = Vector2(current_zoom, current_zoom)
    
    # Set initial limits
    limit_left = limit_left
    limit_right = limit_right
    limit_top = limit_top
    limit_bottom = limit_bottom
    
    # Register with ReferenceManager
    if ReferenceManager:
        ReferenceManager.register_camera(self)

func follow_target(delta: float) -> void:
    # This is called from _process, but kept as separate function for clarity
    _process(delta)

func update_limits(left: float, right: float, top: float, bottom: float) -> void:
    limit_left = left
    limit_right = right
    limit_top = top
    limit_bottom = bottom
```

---

## Game Managers (Autoload - Modular Architecture)

### GameManager

**Responsibilities:** Game state management + Scene transitions

```gdscript
class_name GameManager
extends Node

# Game State
enum GameState {
    MENU,
    PLAYING,
    PAUSED,
    INVENTORY,
    CRAFTING,
    BUILDING
}

var current_state: GameState = GameState.MENU

# Scene Management
var current_scene: String = ""

# Functions
func _ready() -> void
func change_scene(scene_path: String) -> void
func set_game_state(new_state: GameState) -> void
func get_game_state() -> GameState
```

### GameManager Complete Implementation

```gdscript
class_name GameManager
extends Node

# Game State
enum GameState {
    MENU,
    PLAYING,
    PAUSED,
    INVENTORY,
    CRAFTING,
    BUILDING
}

var current_state: GameState = GameState.MENU

# Scene Management
var current_scene: String = ""

# Signals
signal game_state_changed(new_state: GameState)
signal scene_changed(scene_path: String)

func _ready() -> void:
    # Configure viewport for pixel art
    configure_viewport()
    
    # Connect to PauseManager signals
    if PauseManager:
        PauseManager.game_paused.connect(_on_game_paused)
        PauseManager.game_unpaused.connect(_on_game_unpaused)

func configure_viewport() -> void:
    # Base resolution (Terraria-scale: 640x360)
    var base_size: Vector2i = Vector2i(640, 360)
    
    # Set window size
    DisplayServer.window_set_size(base_size)
    
    # Configure stretch (viewport mode with keep aspect and integer scaling)
    get_tree().set_screen_stretch(
        SceneTree.STRETCH_MODE_VIEWPORT,  # Render at base, scale to window
        SceneTree.STRETCH_ASPECT_KEEP,    # Maintain aspect ratio
        base_size,
        SceneTree.STRETCH_SCALE_MODE_INTEGER  # Integer scaling for pixel-perfect
    )

func change_scene(scene_path: String) -> void:
    if scene_path == current_scene:
        return
    
    # Fade out (optional - can be implemented later)
    # Transition effect (optional - can be implemented later)
    
    # Load new scene
    var new_scene: PackedScene = load(scene_path)
    if new_scene == null:
        push_error("Failed to load scene: %s" % scene_path)
        return
    
    get_tree().change_scene_to_packed(new_scene)
    current_scene = scene_path
    
    # Emit signal
    scene_changed.emit(scene_path)

func set_game_state(new_state: GameState) -> void:
    if current_state == new_state:
        return
    
    current_state = new_state
    
    # Handle state-specific logic
    match new_state:
        GameState.PLAYING:
            if PauseManager:
                PauseManager.unpause_game("gamestate")
        GameState.PAUSED:
            if PauseManager:
                PauseManager.pause_game("gamestate")
        GameState.INVENTORY, GameState.CRAFTING, GameState.BUILDING:
            if PauseManager:
                PauseManager.pause_game("ui")
    
    # Emit signal
    game_state_changed.emit(new_state)

func get_game_state() -> GameState:
    return current_state

func _on_game_paused(source: String) -> void:
    if current_state != GameState.PAUSED:
        set_game_state(GameState.PAUSED)

func _on_game_unpaused() -> void:
    if current_state == GameState.PAUSED:
        set_game_state(GameState.PLAYING)
```

### PauseManager

**Responsibilities:** Pause/unpause logic, pause state management

```gdscript
class_name PauseManager
extends Node

# Signals
signal game_paused(source: String)
signal game_unpaused()

# Pause State
var is_paused: bool = false
var pause_source: String = ""  # Track what caused pause (menu, inventory, etc.)

# Pause Layers (for nested pauses)
var pause_stack: Array[String] = []

# Functions
func _ready() -> void
func pause_game(source: String = "manual") -> void
func unpause_game(source: String = "") -> void
func toggle_pause() -> void
func is_game_paused() -> bool
func set_pause_layer(layer: String, paused: bool) -> void
```

### Pause Implementation

```gdscript
func pause_game(source: String = "manual") -> void:
    if is_paused:
        return
    
    is_paused = true
    pause_source = source
    pause_stack.append(source)
    
    # Pause game tree
    get_tree().paused = true
    
    # Emit signal
    game_paused.emit(source)

func unpause_game(source: String = "") -> void:
    if not is_paused:
        return
    
    # Remove from stack
    if source != "":
        pause_stack.erase(source)
    else:
        pause_stack.clear()
    
    # Unpause if stack empty
    if pause_stack.is_empty():
        is_paused = false
        pause_source = ""
        get_tree().paused = false
        game_unpaused.emit()

func toggle_pause() -> void:
    if is_paused:
        unpause_game()
    else:
        pause_game()

func is_game_paused() -> bool:
    return is_paused

func set_pause_layer(layer: String, paused: bool) -> void:
    if paused:
        if layer not in pause_stack:
            pause_stack.append(layer)
            if not is_paused:
                is_paused = true
                get_tree().paused = true
                game_paused.emit(layer)
    else:
        pause_stack.erase(layer)
        if pause_stack.is_empty() and is_paused:
            is_paused = false
            pause_source = ""
            get_tree().paused = false
            game_unpaused.emit()

func _ready() -> void:
    # Initialize pause state
    is_paused = false
    pause_stack.clear()
```

### SettingsManager

**Responsibilities:** Game settings management, persistence

```gdscript
class_name SettingsManager
extends Node

# Signals
signal settings_changed(category: String, key: String, value)
signal settings_loaded()
signal settings_saved()

# Settings Data
var settings: Dictionary = {
    "graphics": {},
    "audio": {},
    "controls": {},
    "gameplay": {},
    "accessibility": {}
}

# Config File Path
const SETTINGS_PATH: String = "user://settings.cfg"

# Functions
func _ready() -> void
func load_settings() -> void
func save_settings() -> void
func get_setting(category: String, key: String, default_value = null)
func set_setting(category: String, key: String, value) -> void
func reset_settings() -> void
```

### Settings Implementation

```gdscript
func load_settings() -> void:
    var config: ConfigFile = ConfigFile.new()
    var err: Error = config.load(SETTINGS_PATH)
    
    if err != OK:
        # Use defaults
        reset_settings()
        return
    
    # Load each category
    for category in settings.keys():
        if config.has_section(category):
            for key in config.get_section_keys(category):
                settings[category][key] = config.get_value(category, key)

func save_settings() -> void:
    var config: ConfigFile = ConfigFile.new()
    
    # Save each category
    for category in settings.keys():
        for key in settings[category]:
            config.set_value(category, key, settings[category][key])
    
    var err: Error = config.save(SETTINGS_PATH)
    if err != OK:
        push_error("Failed to save settings: %s" % error_string(err))
    else:
        settings_saved.emit()

func get_setting(category: String, key: String, default_value = null):
    if not settings.has(category):
        push_warning("Settings category '%s' does not exist" % category)
        return default_value
    
    if not settings[category].has(key):
        return default_value
    
    return settings[category][key]

func set_setting(category: String, key: String, value) -> void:
    if not settings.has(category):
        settings[category] = {}
    
    settings[category][key] = value
    settings_changed.emit(category, key, value)

func reset_settings() -> void:
    # Reset to default values
    settings = {
        "graphics": {
            "fullscreen": false,
            "vsync": true,
            "resolution": Vector2i(1280, 720)
        },
        "audio": {
            "master_volume": 1.0,
            "music_volume": 0.8,
            "sfx_volume": 1.0
        },
        "controls": {
            # Input remaps handled by InputManager
        },
        "gameplay": {
            "auto_save": true,
            "auto_save_interval": 300.0  # 5 minutes
        },
        "accessibility": {
            "subtitles": false,
            "high_contrast": false
        }
    }
    settings_loaded.emit()

func _ready() -> void:
    load_settings()
```

### ReferenceManager

**Responsibilities:** Global references to player, world, UI, etc.

```gdscript
class_name ReferenceManager
extends Node

# Signals
signal player_registered(player: PlayerController)
signal world_registered(world: Node2D)
signal camera_registered(camera: CameraController)

# Global References
var player: PlayerController = null
var world: Node2D = null
var ui: Control = null
var camera: CameraController = null
var hud: Control = null

# Functions
func _ready() -> void
func register_player(player_node: PlayerController) -> void
func register_world(world_node: Node2D) -> void
func register_ui(ui_node: Control) -> void
func register_camera(camera_node: CameraController) -> void
func register_hud(hud_node: Control) -> void
func get_player() -> PlayerController
func get_world() -> Node2D
func get_ui() -> Control
func get_camera() -> CameraController
func get_hud() -> Control
func clear_references() -> void
```

### Reference Management

```gdscript
func register_player(player_node: PlayerController) -> void:
    player = player_node
    player_registered.emit(player_node)

func get_player() -> PlayerController:
    return player

func register_world(world_node: Node2D) -> void:
    world = world_node
    world_registered.emit(world_node)

func register_ui(ui_node: Control) -> void:
    ui = ui_node

func register_hud(hud_node: Control) -> void:
    hud = hud_node

func get_world() -> Node2D:
    return world

func get_ui() -> Control:
    return ui

func get_camera() -> CameraController:
    return camera

func get_hud() -> Control:
    return hud

func clear_references() -> void:
    player = null
    world = null
    ui = null
    camera = null
    hud = null

func _ready() -> void:
    # Initialize references
    player = null
    world = null
    ui = null
    camera = null
    hud = null
```

### Manager Communication Pattern (Hybrid)

**Pattern:** Signals for events, direct calls for queries

**Signals (Event-Driven):**
- Use signals when managers need to notify others of state changes
- Other systems can connect/disconnect as needed
- Decoupled communication

**Direct Calls (Query-Based):**
- Use direct function calls for getting data/state
- Simple, synchronous, easy to trace
- For queries that need immediate results

**Signal Definitions:**

```gdscript
# GameManager signals
signal game_state_changed(new_state: GameState)
signal scene_changed(scene_path: String)

# PauseManager signals
signal game_paused(source: String)
signal game_unpaused()

# SettingsManager signals
signal settings_changed(category: String, key: String, value)
signal settings_loaded()
signal settings_saved()

# ReferenceManager signals
signal player_registered(player: PlayerController)
signal world_registered(world: Node2D)
signal camera_registered(camera: CameraController)
```

**Usage Examples:**

```gdscript
# Event-driven (signals)
# PauseManager emits signal when paused
PauseManager.game_paused.connect(_on_game_paused)

# Query-based (direct calls)
# Get current player reference
var player = ReferenceManager.get_player()

# Get setting value
var volume = SettingsManager.get_setting("audio", "master_volume", 1.0)

# Check pause state
if PauseManager.is_game_paused():
    # Handle paused state
    pass
```

**Communication Rules:**
1. **Events → Signals:** State changes, notifications (pause, scene change, settings changed)
2. **Queries → Direct Calls:** Getting data, checking state (get_player, get_setting, is_paused)
3. **Actions → Direct Calls:** Immediate actions that need to happen synchronously (pause_game, change_scene)

---

## Pixel Art Configuration

### Project Settings

**Display > Window:**
- **Size:** Base resolution: **640x360** (Terraria-scale, scales cleanly to 1280x720, 1920x1080, etc.)
- **Stretch Mode:** `viewport` (renders at base resolution, then scales - BEST for pixel art)
- **Stretch Aspect:** `keep` (maintains aspect ratio, may have black bars - BEST for pixel art)
- **Stretch Scale Mode:** `integer` (ensures pixel-perfect scaling by whole numbers)

**Rendering > Textures:**
- **Default Texture Filter:** `Nearest` (for pixel-perfect)

**Rendering > 2D:**
- **Snap 2D Transforms to Pixel:** Enabled
- **Snap 2D Vertices to Pixel:** Enabled

### Viewport Configuration

```gdscript
# In Main scene or GameManager
func configure_viewport() -> void:
    # Base resolution (Terraria-scale: 640x360)
    var base_size: Vector2i = Vector2i(640, 360)
    
    # Set window size
    DisplayServer.window_set_size(base_size)
    
    # Configure stretch (viewport mode with keep aspect and integer scaling)
    get_tree().set_screen_stretch(
        SceneTree.STRETCH_MODE_VIEWPORT,  # Render at base, scale to window
        SceneTree.STRETCH_ASPECT_KEEP,    # Maintain aspect ratio
        base_size,
        SceneTree.STRETCH_SCALE_MODE_INTEGER  # Integer scaling for pixel-perfect
    )
```

### Resolution Scaling Explanation

**Why 640x360:**
- Scales cleanly to common resolutions (2x = 1280x720, 3x = 1920x1080)
- Good balance between detail and performance
- Terraria-scale resolution
- Works perfectly with integer scaling

**Stretch Mode: `viewport`:**
- Renders game at base resolution (640x360)
- Scales the rendered image to fit window
- Preserves pixel art crispness
- Better than `2d` mode for pixel art

**Stretch Aspect: `keep`:**
- Maintains 16:9 aspect ratio
- May add black bars on non-16:9 screens
- Prevents distortion of pixel art
- Best choice for pixel-perfect rendering

**Integer Scaling:**
- Scales by whole numbers (2x, 3x, 4x)
- Prevents uneven pixel scaling
- Maintains pixel art integrity
- May leave small black borders on some resolutions (acceptable trade-off)

---

## System Architecture

### Component Hierarchy

```
Main (Node2D)
├── World (Node2D)
│   ├── Terrain (TileMap)
│   └── Entities (Node2D)
├── Player (CharacterBody2D)
│   ├── Sprite2D
│   ├── CollisionShape2D
│   ├── AnimationPlayer
│   └── CameraController (Camera2D)
└── UI (CanvasLayer)
    ├── HUD (Control)
    └── Menus (Control)

Autoload:
├── GameManager (Node) - Game state + scene transitions
├── InputManager (Node) - Input handling + remapping
├── PauseManager (Node) - Pause/unpause logic
├── SettingsManager (Node) - Settings management
└── ReferenceManager (Node) - Global references
```

### Initialization Flow

```
Game starts
├── GameManager._ready()
│   ├── Configure viewport
│   └── Load initial scene
├── InputManager._ready()
│   └── Initialize input map
├── SettingsManager._ready()
│   └── Load settings
├── Main scene loads
│   ├── Create World
│   │   └── ReferenceManager.register_world()
│   ├── Spawn Player
│   │   └── ReferenceManager.register_player()
│   └── Setup Camera
│       └── ReferenceManager.register_camera()
└── Game loop starts
```

---

## Integration Points

### Player with Camera

**Note:** Camera is added as a child node in the Player scene (see Scene Setup section). The camera script automatically sets the target in `_ready()`.

```gdscript
# CameraController automatically sets target in _ready()
# In PlayerController._ready(), camera is already set up as child node
# CameraController._ready() will:
# - Set target to parent (Player) if not already set
# - Register with ReferenceManager
# - Configure initial zoom and limits
```

### Input with Player

```gdscript
# PlayerController uses InputManager
func handle_input() -> void:
    var input_dir: float = InputManager.get_axis("move_left", "move_right")
    is_running = InputManager.is_action_pressed("run")
    
    if InputManager.is_action_just_pressed("jump"):
        jump_buffer_time = jump_buffer_max
```

---

## Setup Instructions

### Project Setup

1. **Create New Godot 4 Project:**
   - Open Godot 4.x
   - Create new project
   - Choose 2D project template

2. **Configure Project Settings:**
   - **Display > Window:**
     - Size: 640x360
     - Stretch Mode: `viewport`
     - Stretch Aspect: `keep`
     - Stretch Scale Mode: `integer`
   - **Rendering > Textures:**
     - Default Texture Filter: `Nearest`
   - **Rendering > 2D:**
     - Snap 2D Transforms to Pixel: Enabled
     - Snap 2D Vertices to Pixel: Enabled

3. **Create Directory Structure:**
   - Create folders: `scenes/`, `scripts/`, `assets/`, `resources/`, `autoload/`
   - Create subfolders as shown in Project Structure section

4. **Setup Autoload Singletons:**
   - **Project > Project Settings > Autoload:**
     - Add `scripts/managers/GameManager.gd` as `GameManager`
     - Add `scripts/managers/InputManager.gd` as `InputManager`
     - Add `scripts/managers/PauseManager.gd` as `PauseManager`
     - Add `scripts/managers/SettingsManager.gd` as `SettingsManager`
     - Add `scripts/managers/ReferenceManager.gd` as `ReferenceManager`
   - **Important:** Order matters - add in this order:
     1. GameManager
     2. InputManager
     3. SettingsManager
     4. PauseManager
     5. ReferenceManager

5. **Setup InputMap:**
   - **Project > Project Settings > Input Map:**
     - Add actions: `move_left`, `move_right`, `jump`, `run`, `interact`, `attack`, `inventory`, `craft`, `build`, `dig`
     - Assign default keys (InputManager will handle this if actions don't exist)

### Scene Setup

1. **Create Player Scene:**
   - Create new scene: `scenes/player/Player.tscn`
   - Add `CharacterBody2D` node (rename to "Player")
   - Add child nodes:
     - `Sprite2D` (for player sprite)
     - `CollisionShape2D` (for collision)
     - `AnimationPlayer` (for animations)
   - Attach script: `scripts/player/PlayerController.gd`
   - Set collision shape size/position

2. **Create Main Scene:**
   - Create new scene: `scenes/main/Main.tscn`
   - Add `Node2D` node (rename to "Main")
   - Add child nodes:
     - `Node2D` (rename to "World")
     - Instance Player scene
     - `CanvasLayer` (rename to "UI")
   - Set as main scene: **Project > Project Settings > Application > Run > Main Scene**

3. **Camera Setup:**
   - In Player scene, add `Camera2D` as child
   - Attach script: `scripts/camera/CameraController.gd`
   - Set `target` export to Player node
   - Configure deadzone, smoothing, limits in inspector

### Animation Setup

1. **Create AnimationPlayer Animations:**
   - In Player scene, select AnimationPlayer
   - Create animations: `idle`, `walk`, `run`, `jump`, `fall`
   - Set up sprite frames for each animation

**Animation Details:**

- **idle:**
  - Duration: 1.0 seconds
  - Loop: Enabled
  - Frames: 1-2 frames (idle pose, slight breathing)
  - Frame rate: 0.5 seconds per frame

- **walk:**
  - Duration: 0.6 seconds
  - Loop: Enabled
  - Frames: 4-6 frames (walk cycle)
  - Frame rate: 0.1 seconds per frame

- **run:**
  - Duration: 0.4 seconds
  - Loop: Enabled
  - Frames: 4-6 frames (run cycle, faster than walk)
  - Frame rate: 0.067 seconds per frame

- **jump:**
  - Duration: 0.3 seconds
  - Loop: Disabled
  - Frames: 2-3 frames (jump up animation)
  - Frame rate: 0.15 seconds per frame

- **fall:**
  - Duration: 0.2 seconds
  - Loop: Enabled (while falling)
  - Frames: 1-2 frames (falling pose)
  - Frame rate: 0.1 seconds per frame

**Animation Setup Steps:**

1. Select AnimationPlayer node
2. Click "Animation" dropdown → "New"
3. Name animation (e.g., "idle")
4. Set duration and loop settings
5. Select Sprite2D node in scene tree
6. Add track: "Sprite2D:frame" or "Sprite2D:texture"
7. Insert keyframes at desired times
8. Set frame values/textures for each keyframe
9. Repeat for all animations

---

## Scene File Structure

### Player Scene (`scenes/player/Player.tscn`)

**Exact Node Hierarchy:**

```
Player (CharacterBody2D)
├── Sprite2D
│   └── (Sprite texture assigned here)
├── CollisionShape2D
│   └── Shape: RectangleShape2D (size: 16x32 pixels)
├── AnimationPlayer
│   └── Animations: idle, walk, run, jump, fall
└── CameraController (Camera2D)
    └── Script: scripts/camera/CameraController.gd
```

**Node Properties:**

- **Player (CharacterBody2D):**
  - Script: `scripts/player/PlayerController.gd`
  - Collision Layer: 1 (Player)
  - Collision Mask: 2 (World) | 4 (Enemies) | 8 (Items)

- **Sprite2D:**
  - Texture: Player sprite (16x32 pixels recommended)
  - Filter: Nearest (for pixel art)
  - Centered: true

- **CollisionShape2D:**
  - Shape: RectangleShape2D
  - Size: Vector2(16, 32) - matches sprite size
  - Position: Vector2(0, 0) - centered

- **AnimationPlayer:**
  - Autoplay: "idle" (optional)
  - Animations: Created as described above

- **CameraController (Camera2D):**
  - Script: `scripts/camera/CameraController.gd`
  - Target: (set to Player node in script)
  - Current: true
  - Enabled: true

### Main Scene (`scenes/main/Main.tscn`)

**Exact Node Hierarchy:**

```
Main (Node2D)
├── World (Node2D)
│   ├── Terrain (TileMap) - Optional, for world generation
│   └── Entities (Node2D) - For enemies, items, etc.
├── Player (CharacterBody2D)
│   └── (Instance of scenes/player/Player.tscn)
└── UI (CanvasLayer)
    ├── HUD (Control)
    │   └── (HUD elements added here)
    └── Menus (Control)
        └── (Menu elements added here)
```

**Node Properties:**

- **Main (Node2D):**
  - No script needed (or minimal setup script)
  - Position: Vector2(0, 0)

- **World (Node2D):**
  - Position: Vector2(0, 0)
  - Used for world generation and entities

- **Player (CharacterBody2D):**
  - Instance of `scenes/player/Player.tscn`
  - Position: Vector2(320, 180) - center of 640x360 screen

- **UI (CanvasLayer):**
  - Layer: 100 (above game world)
  - Offset: Vector2(0, 0)

### Scene File Format (`.tscn`)

**Example Minimal Player.tscn Structure:**

```gdscript
[gd_scene load_steps=3 format=3 uid="uid://player"]

[ext_resource type="Script" path="res://scripts/player/PlayerController.gd" id="1"]
[ext_resource type="Texture2D" path="res://assets/sprites/player/player.png" id="2"]

[node name="Player" type="CharacterBody2D"]
script = ExtResource("1")
collision_layer = 1
collision_mask = 14

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2")
centered = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_1")

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]

[node name="CameraController" type="Camera2D" parent="."]
script = ExtResource("3")
current = true

[sub_resource type="RectangleShape2D" id="RectangleShape2D_1"]
size = Vector2(16, 32)
```

**Note:** Actual `.tscn` files are created in Godot editor. This is a reference structure.

---

## Collision Layers and Masks Setup

### Collision Layer Configuration

**Project Settings > Layer Names > 2D Physics:**

1. **Layer 1: Player**
   - Used for: Player character
   - Collision Mask: World (2), Enemies (4), Items (8)

2. **Layer 2: World**
   - Used for: Terrain, walls, platforms, static objects
   - Collision Mask: None (static, doesn't need to detect collisions)

3. **Layer 3: Enemies**
   - Used for: Enemy characters
   - Collision Mask: World (2), Player (1)

4. **Layer 4: Items**
   - Used for: Collectible items, pickups
   - Collision Mask: World (2), Player (1)

5. **Layer 5: Projectiles**
   - Used for: Bullets, arrows, thrown items
   - Collision Mask: World (2), Enemies (4), Player (1)

6. **Layer 6: Triggers**
   - Used for: Interaction zones, checkpoints
   - Collision Mask: None (uses Area2D, not physics)

**Setup Steps:**

1. **Project > Project Settings > Layer Names > 2D Physics**
2. Set layer names:
   - Layer 1: "Player"
   - Layer 2: "World"
   - Layer 3: "Enemies"
   - Layer 4: "Items"
   - Layer 5: "Projectiles"
   - Layer 6: "Triggers"

3. **In Player Scene:**
   - Select CharacterBody2D node
   - Inspector > Collision Layer: Check "Player" (Layer 1)
   - Inspector > Collision Mask: Check "World" (2), "Enemies" (4), "Items" (8)

4. **In World/Terrain Nodes:**
   - Select StaticBody2D or TileMap
   - Inspector > Collision Layer: Check "World" (Layer 2)
   - Inspector > Collision Mask: None (uncheck all)

**Collision Detection:**

- **Player vs World:** Player collides with terrain/platforms
- **Player vs Enemies:** Player collides with enemies (damage/knockback)
- **Player vs Items:** Player collides with items (pickup)
- **Enemies vs World:** Enemies collide with terrain
- **Projectiles vs World/Enemies:** Projectiles hit terrain and enemies

**Best Practices:**

- Use appropriate layers for each object type
- Set collision masks only for what needs detection
- Use Area2D for triggers/interactions (not physics collisions)
- Disable collision masks for static objects (performance)

---

## Default Values and Configuration

### PlayerController Defaults

```gdscript
# Movement Constants
const WALK_SPEED: float = 200.0
const RUN_SPEED: float = 400.0
const JUMP_VELOCITY: float = -500.0
const GRAVITY: float = 980.0
const ACCELERATION: float = 3000.0
const FRICTION: float = 2500.0

# Timing Constants
const COYOTE_TIME_MAX: float = 0.15
const JUMP_BUFFER_MAX: float = 0.1
```

### CameraController Defaults

```gdscript
# Deadzone
@export var deadzone_size: Vector2 = Vector2(50.0, 50.0)

# Smoothing
@export var smoothing_enabled: bool = true
@export var smoothing_speed: float = 5.0

# Zoom
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_step: float = 0.1
@export var current_zoom: float = 1.0

# Limits (unlimited by default)
@export var limit_left: float = -1000000.0
@export var limit_right: float = 1000000.0
@export var limit_top: float = -1000000.0
@export var limit_bottom: float = 1000000.0
```

### SettingsManager Defaults

```gdscript
# Default settings structure
{
    "graphics": {
        "fullscreen": false,
        "vsync": true,
        "resolution": Vector2i(1280, 720)
    },
    "audio": {
        "master_volume": 1.0,
        "music_volume": 0.8,
        "sfx_volume": 1.0
    },
    "gameplay": {
        "auto_save": true,
        "auto_save_interval": 300.0
    },
    "accessibility": {
        "subtitles": false,
        "high_contrast": false
    }
}
```

---

## Error Handling

### PlayerController Error Handling

- Check for null components in `_ready()`
- Handle missing sprite/animation player gracefully
- Validate collision shape exists before movement

### InputManager Error Handling

- Check if action exists before remapping
- Validate InputEvent type before processing
- Handle ConfigFile save/load errors
- Provide fallback defaults if settings file corrupted

### CameraController Error Handling

- Check if target exists before following
- Validate zoom limits before applying
- Handle null target gracefully

### Manager Error Handling

- Check if managers exist before accessing (null checks)
- Handle signal connection failures
- Validate scene paths before loading
- Handle ConfigFile errors with fallbacks

### Best Practices

- Use `push_error()` for errors
- Use `push_warning()` for warnings
- Return early on errors (fail fast)
- Provide fallback values where appropriate
- Log errors for debugging

---

## Performance Considerations

### PlayerController Performance

- **Physics Process:** Runs every frame - keep logic efficient
- **Animation Updates:** Only update when state changes
- **Ground Checks:** Use `is_on_floor()` which is optimized by Godot
- **Avoid:** Expensive calculations in `_physics_process()`

### CameraController Performance

- **Process vs Physics Process:** Use `_process()` (runs every frame, not physics frame)
- **Lerp Smoothing:** Efficient, but limit smoothing speed
- **Deadzone Check:** Simple distance calculation - very fast
- **Limit Clamping:** Use `clamp()` which is optimized

### InputManager Performance

- **Input Checking:** Use Godot's built-in Input system (optimized)
- **Remapping:** Only save when changed, not every frame
- **ConfigFile:** Load once at startup, save only when needed

### Manager Performance

- **Signal Connections:** Connect once in `_ready()`, not repeatedly
- **Reference Lookups:** Cache references, don't search tree repeatedly
- **State Checks:** Use simple boolean/enum checks

### General Optimization Tips

1. **Use Object Pooling:** For frequently created/destroyed objects
2. **Limit Physics Bodies:** Only use CharacterBody2D where needed
3. **Efficient Collision:** Use appropriate collision layers/masks
4. **Texture Streaming:** Load textures on demand for large games
5. **Scene Instancing:** Instance scenes efficiently, don't duplicate

### Performance Targets

- **Frame Rate:** 60 FPS minimum
- **Physics Rate:** 60 Hz (default)
- **Input Latency:** < 16ms (1 frame)
- **Memory:** Monitor for leaks, use profiler

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing foundation systems are listed here.

### Pixel Art Creation Tools

**Required for:** Creating player sprites, animations, and UI elements

**1. Pixelorama (Recommended)**
- **URL:** https://orama-interactive.itch.io/pixelorama
- **Description:** Free, open-source pixel art editor (made in Godot)
- **Use For:** Creating player sprites, walk/run/jump animations, UI elements
- **Why:** Free, open-source, integrates well with Godot workflow
- **Status:** Will be used for sprite creation

**Alternative: Aseprite**
- **URL:** https://www.aseprite.org
- **Description:** Professional pixel art editor
- **Use For:** If Pixelorama doesn't meet needs
- **Cost:** Paid (one-time purchase)
- **Status:** Backup option if needed

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **CharacterBody2D:** https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html
- **InputMap:** https://docs.godotengine.org/en/stable/classes/class_inputmap.html
- **Camera2D:** https://docs.godotengine.org/en/stable/classes/class_camera2d.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
- **Pixel Art Best Practices:** https://docs.godotengine.org/en/stable/tutorials/2d/pixel_perfect.html
- **Multiple Resolutions:** https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html
- **ConfigFile:** https://docs.godotengine.org/en/stable/classes/class_configfile.html
- **2D Movement Tutorial:** https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html
- **Input Examples:** https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing foundation systems. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [CharacterBody2D Documentation](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) - Player controller implementation
- [InputMap Documentation](https://docs.godotengine.org/en/stable/classes/class_inputmap.html) - Input system setup
- [Camera2D Documentation](https://docs.godotengine.org/en/stable/classes/class_camera2d.html) - Camera system implementation
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Manager setup
- [ConfigFile Documentation](https://docs.godotengine.org/en/stable/classes/class_configfile.html) - Settings persistence

### Pixel Art and Display

- [Pixel Art Best Practices](https://docs.godotengine.org/en/stable/tutorials/2d/pixel_perfect.html) - Pixel-perfect rendering setup
- [Multiple Resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html) - Viewport configuration

### Tutorials

- [Godot 4 2D Movement Tutorial](https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html) - CharacterBody2D movement patterns
- [Input Examples](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html) - Input handling patterns

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/getting_started/workflow/best_practices.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Testing Checklist

- [ ] Player moves left/right correctly
- [ ] Player runs when run button pressed
- [ ] Player jumps correctly
- [ ] Gravity applies correctly
- [ ] Collision detection works
- [ ] Camera follows player smoothly
- [ ] Camera deadzone works
- [ ] Camera zoom works
- [ ] Input remapping works
- [ ] Controller input works
- [ ] Keyboard input works
- [ ] Pixel art displays correctly
- [ ] Game scales to different resolutions
- [ ] GameManager initializes correctly
- [ ] Scene transitions work
- [ ] PauseManager pauses/unpauses correctly
- [ ] SettingsManager loads/saves settings
- [ ] ReferenceManager tracks references correctly
- [ ] Performance is acceptable (60+ FPS)

