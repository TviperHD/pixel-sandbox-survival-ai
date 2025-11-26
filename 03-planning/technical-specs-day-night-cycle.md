# Technical Specifications: Day/Night Cycle System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the day/night cycle system with variable duration (biome/season dependent), full gameplay effects (visual + enemies + survival), and hybrid time display (visual indicators + optional clock). This system integrates with Survival System, World Generation, Enemy Spawning, Lighting System, and UI System.

---

## Research Notes

### Day/Night Cycle Best Practices

**Research Findings:**
- Variable day/night length creates dynamic gameplay
- Biome-dependent cycles add world-building depth
- Full gameplay effects (visual + enemies + survival) increase immersion
- Visual indicators are more immersive than text clocks
- Optional clock provides precision when needed

**Sources:**
- [Godot 4 Time Documentation](https://docs.godotengine.org/en/stable/classes/class_time.html) - Time management
- [Godot 4 Environment Documentation](https://docs.godotengine.org/en/stable/classes/class_environment.html) - Lighting and environment
- Terraria day/night cycle patterns - Industry standard approach

**Implementation Approach:**
- TimeManager singleton manages day/night cycle
- Variable duration based on biome/season
- Full effects: lighting, enemy spawns, survival stats
- Visual indicators (sun/moon position, sky color)
- Optional clock in HUD/settings

**Why This Approach:**
- Variable duration creates dynamic gameplay
- Full effects increase immersion
- Visual indicators are more engaging than text
- Optional clock provides precision when needed

### Lighting System Integration

**Research Findings:**
- Godot 4's CanvasModulate can tint entire scene
- Environment lighting changes create atmosphere
- Smooth transitions prevent jarring changes
- Per-biome lighting adds depth

**Sources:**
- [Godot 4 CanvasModulate Documentation](https://docs.godotengine.org/en/stable/classes/class_canvasmodulate.html) - Scene tinting
- [Godot 4 Environment Documentation](https://docs.godotengine.org/en/stable/classes/class_environment.html) - Environment settings

**Implementation Approach:**
- CanvasModulate for overall scene tint
- Environment lighting for atmosphere
- Smooth color transitions
- Per-biome lighting multipliers

**Why This Approach:**
- CanvasModulate is efficient for global tinting
- Environment lighting adds depth
- Smooth transitions feel natural
- Per-biome multipliers add variety

---

## Data Structures

### TimeOfDay

```gdscript
enum TimeOfDay {
    DAWN,       # 4:00 - 6:00
    DAY,        # 6:00 - 18:00
    DUSK,       # 18:00 - 20:00
    NIGHT       # 20:00 - 4:00
}
```

### DayNightCycleData

```gdscript
class_name DayNightCycleData
extends Resource

# Cycle Configuration
@export var biome_id: String  # Biome this cycle applies to
@export var season_id: String = ""  # Season (optional, empty = all seasons)

# Duration (in real seconds)
@export var day_duration: float = 600.0  # 10 minutes default
@export var night_duration: float = 300.0  # 5 minutes default
@export var dawn_duration: float = 60.0  # 1 minute
@export var dusk_duration: float = 60.0  # 1 minute

# Time Transitions
@export var dawn_start_time: float = 0.25  # 25% through cycle
@export var day_start_time: float = 0.30  # 30% through cycle
@export var dusk_start_time: float = 0.75  # 75% through cycle
@export var night_start_time: float = 0.80  # 80% through cycle

# Visual Settings
@export var day_color: Color = Color(1.0, 1.0, 1.0, 1.0)  # Full brightness
@export var night_color: Color = Color(0.3, 0.3, 0.5, 1.0)  # Dark blue tint
@export var dawn_color: Color = Color(1.0, 0.8, 0.6, 1.0)  # Warm orange
@export var dusk_color: Color = Color(1.0, 0.6, 0.4, 1.0)  # Red-orange

# Survival Effects
@export var night_temperature_modifier: float = -10.0  # Colder at night
@export var day_temperature_modifier: float = 5.0  # Warmer during day
@export var night_visibility_modifier: float = 0.5  # 50% visibility at night

# Enemy Spawn Modifiers
@export var night_enemy_spawn_multiplier: float = 1.5  # More enemies at night
@export var day_enemy_spawn_multiplier: float = 0.8  # Fewer enemies during day
```

### TimeState

```gdscript
class_name TimeState
extends RefCounted

var current_time: float = 0.0  # 0.0 to 1.0 (cycle progress)
var current_time_of_day: TimeOfDay = TimeOfDay.DAY
var day_number: int = 1
var total_time_elapsed: float = 0.0  # Total real seconds elapsed
var biome_id: String = ""
var season_id: String = ""

# Visual State
var current_color: Color = Color.WHITE
var sun_position: float = 0.0  # 0.0 (left) to 1.0 (right)
var moon_position: float = 0.0  # 0.0 (left) to 1.0 (right)

# Effects State
var temperature_modifier: float = 0.0
var visibility_modifier: float = 1.0
var enemy_spawn_multiplier: float = 1.0
```

---

## Core Classes

### TimeManager (Autoload Singleton)

```gdscript
class_name TimeManager
extends Node

# Time State
var time_state: TimeState = TimeState.new()
var current_cycle_data: DayNightCycleData = null

# Cycle Data Registry
var cycle_data_by_biome: Dictionary = {}  # biome_id -> DayNightCycleData
var cycle_data_by_season: Dictionary = {}  # season_id -> Dictionary[biome_id -> DayNightCycleData]

# Time Configuration
@export var time_scale: float = 1.0  # Time multiplier (1.0 = normal, 2.0 = 2x speed)
@export var pause_on_menu: bool = true  # Pause time when menu open
@export var show_clock: bool = false  # Show clock in HUD (optional)

# References
var world_generator: WorldGenerator
var survival_manager: SurvivalManager
var enemy_spawner: Node  # Enemy spawner system

# Visual Components
var canvas_modulate: CanvasModulate = null
var sky_background: ColorRect = null

# Signals
signal time_changed(time_state: TimeState)
signal time_of_day_changed(new_time: TimeOfDay)
signal day_passed(day_number: int)
signal cycle_progressed(progress: float)  # 0.0 to 1.0

# Initialization
func _ready() -> void
func initialize() -> void

# Time Management
func _process(delta: float) -> void
func update_time(delta: float) -> void
func set_time_scale(scale: float) -> void
func pause_time() -> void
func resume_time() -> void

# Time Queries
func get_current_time_of_day() -> TimeOfDay
func get_current_time() -> float  # 0.0 to 1.0
func get_day_number() -> int
func get_time_string() -> String  # "Day 5 - 2:30 PM"
func get_time_percent() -> float  # 0.0 to 1.0

# Cycle Management
func set_biome(biome_id: String) -> void
func set_season(season_id: String) -> void
func get_cycle_duration() -> float
func get_time_until_next_cycle() -> float

# Visual Updates
func update_lighting() -> void
func update_sky_color() -> void
func update_sun_moon_position() -> void

# Effects Application
func apply_survival_effects() -> void
func get_temperature_modifier() -> float
func get_visibility_modifier() -> float
func get_enemy_spawn_multiplier() -> float
```

---

## System Architecture

### Component Hierarchy

```
TimeManager (Autoload Singleton)
├── TimeState (RefCounted)
├── DayNightCycleData[] (Dictionary)
├── CanvasModulate (Node)
├── SkyBackground (ColorRect)
└── UI/TimeDisplay (Control)
    ├── VisualIndicator (Control)
    └── ClockDisplay (Label) [Optional]
```

### Data Flow

1. **Time Update:**
   ```
   _process(delta)
   ├── Calculate time delta (scaled)
   ├── Update time_state.current_time
   ├── Check for time_of_day change
   ├── Update visual indicators
   ├── Apply survival effects
   ├── Update enemy spawn rates
   └── Emit signals
   ```

2. **Biome Change:**
   ```
   Player enters new biome
   ├── TimeManager.set_biome(biome_id)
   ├── Load cycle_data for biome
   ├── Adjust cycle duration
   ├── Update visual settings
   └── Continue time progression
   ```

3. **Time of Day Change:**
   ```
   Time crosses threshold
   ├── Update time_of_day enum
   ├── Update lighting color
   ├── Update survival modifiers
   ├── Update enemy spawn rates
   ├── Emit time_of_day_changed signal
   └── Update UI indicators
   ```

---

## Algorithms

### Time Update Algorithm

```gdscript
func _process(delta: float) -> void:
    if GameManager and GameManager.is_paused:
        return
    
    if pause_on_menu and UIManager and UIManager.is_menu_open:
        return
    
    # Scale delta by time_scale
    var scaled_delta = delta * time_scale
    
    # Update time
    update_time(scaled_delta)

func update_time(delta: float) -> void:
    if current_cycle_data == null:
        return
    
    # Calculate total cycle duration
    var cycle_duration = get_cycle_duration()
    
    # Update current time (0.0 to 1.0)
    var time_increment = delta / cycle_duration
    time_state.current_time += time_increment
    time_state.total_time_elapsed += delta
    
    # Wrap around if past 1.0
    if time_state.current_time >= 1.0:
        time_state.current_time = fmod(time_state.current_time, 1.0)
        time_state.day_number += 1
        day_passed.emit(time_state.day_number)
    
    # Update time of day
    var old_time_of_day = time_state.current_time_of_day
    time_state.current_time_of_day = get_time_of_day_from_progress(time_state.current_time)
    
    if old_time_of_day != time_state.current_time_of_day:
        time_of_day_changed.emit(time_state.current_time_of_day)
    
    # Update visuals
    update_lighting()
    update_sky_color()
    update_sun_moon_position()
    
    # Apply effects
    apply_survival_effects()
    
    # Emit signals
    time_changed.emit(time_state)
    cycle_progressed.emit(time_state.current_time)

func get_time_of_day_from_progress(progress: float) -> TimeOfDay:
    if current_cycle_data == null:
        return TimeOfDay.DAY
    
    if progress < current_cycle_data.dawn_start_time:
        return TimeOfDay.NIGHT
    elif progress < current_cycle_data.day_start_time:
        return TimeOfDay.DAWN
    elif progress < current_cycle_data.dusk_start_time:
        return TimeOfDay.DAY
    elif progress < current_cycle_data.night_start_time:
        return TimeOfDay.DUSK
    else:
        return TimeOfDay.NIGHT
```

### Lighting Update Algorithm

```gdscript
func update_lighting() -> void:
    if current_cycle_data == null:
        return
    
    # Calculate color based on time of day
    var target_color: Color
    var time_of_day = time_state.current_time_of_day
    
    match time_of_day:
        TimeOfDay.DAWN:
            target_color = current_cycle_data.dawn_color
        TimeOfDay.DAY:
            target_color = current_cycle_data.day_color
        TimeOfDay.DUSK:
            target_color = current_cycle_data.dusk_color
        TimeOfDay.NIGHT:
            target_color = current_cycle_data.night_color
    
    # Smooth transition between colors
    if canvas_modulate:
        canvas_modulate.color = canvas_modulate.color.lerp(target_color, 0.05)  # Smooth transition
    
    # Update sky background
    if sky_background:
        sky_background.color = sky_background.color.lerp(target_color, 0.05)

func update_sun_moon_position() -> void:
    # Sun position: 0.0 (left/sunrise) to 1.0 (right/sunset)
    # Moon position: opposite of sun
    var progress = time_state.current_time
    
    # Sun: visible during day, moves left to right
    if progress >= current_cycle_data.day_start_time and progress <= current_cycle_data.dusk_start_time:
        # Sun is visible
        var day_progress = (progress - current_cycle_data.day_start_time) / (current_cycle_data.dusk_start_time - current_cycle_data.day_start_time)
        time_state.sun_position = day_progress  # 0.0 to 1.0
    else:
        time_state.sun_position = -1.0  # Not visible
    
    # Moon: visible during night, moves right to left
    if progress < current_cycle_data.day_start_time or progress > current_cycle_data.dusk_start_time:
        # Moon is visible
        var night_progress: float
        if progress < current_cycle_data.day_start_time:
            # Before dawn
            night_progress = progress / current_cycle_data.day_start_time
        else:
            # After dusk
            night_progress = (progress - current_cycle_data.dusk_start_time) / (1.0 - current_cycle_data.dusk_start_time)
        time_state.moon_position = 1.0 - night_progress  # Right to left
    else:
        time_state.moon_position = -1.0  # Not visible
```

### Survival Effects Algorithm

```gdscript
func apply_survival_effects() -> void:
    if current_cycle_data == null or survival_manager == null:
        return
    
    var time_of_day = time_state.current_time_of_day
    var temperature_modifier: float = 0.0
    var visibility_modifier: float = 1.0
    
    match time_of_day:
        TimeOfDay.DAWN:
            temperature_modifier = lerp(current_cycle_data.night_temperature_modifier, current_cycle_data.day_temperature_modifier, 0.5)
            visibility_modifier = lerp(current_cycle_data.night_visibility_modifier, 1.0, 0.5)
        TimeOfDay.DAY:
            temperature_modifier = current_cycle_data.day_temperature_modifier
            visibility_modifier = 1.0
        TimeOfDay.DUSK:
            temperature_modifier = lerp(current_cycle_data.day_temperature_modifier, current_cycle_data.night_temperature_modifier, 0.5)
            visibility_modifier = lerp(1.0, current_cycle_data.night_visibility_modifier, 0.5)
        TimeOfDay.NIGHT:
            temperature_modifier = current_cycle_data.night_temperature_modifier
            visibility_modifier = current_cycle_data.night_visibility_modifier
    
    # Store modifiers for other systems to query
    time_state.temperature_modifier = temperature_modifier
    time_state.visibility_modifier = visibility_modifier
    
    # Apply to survival manager
    if survival_manager:
        survival_manager.set_time_temperature_modifier(temperature_modifier)
        survival_manager.set_time_visibility_modifier(visibility_modifier)

func get_enemy_spawn_multiplier() -> float:
    if current_cycle_data == null:
        return 1.0
    
    var time_of_day = time_state.current_time_of_day
    
    match time_of_day:
        TimeOfDay.DAY:
            return current_cycle_data.day_enemy_spawn_multiplier
        TimeOfDay.NIGHT:
            return current_cycle_data.night_enemy_spawn_multiplier
        TimeOfDay.DAWN, TimeOfDay.DUSK:
            # Transition: average of day and night
            return (current_cycle_data.day_enemy_spawn_multiplier + current_cycle_data.night_enemy_spawn_multiplier) / 2.0
    
    return 1.0
```

### Biome Change Algorithm

```gdscript
func set_biome(biome_id: String) -> void:
    time_state.biome_id = biome_id
    
    # Load cycle data for biome
    if cycle_data_by_season.has(time_state.season_id):
        var season_data = cycle_data_by_season[time_state.season_id]
        if season_data.has(biome_id):
            current_cycle_data = season_data[biome_id]
        else:
            # Fallback to biome default
            current_cycle_data = cycle_data_by_biome.get(biome_id)
    else:
        # No season data, use biome default
        current_cycle_data = cycle_data_by_biome.get(biome_id)
    
    if current_cycle_data == null:
        # Fallback to default cycle
        current_cycle_data = get_default_cycle_data()
    
    # Update visuals immediately
    update_lighting()
    update_sky_color()

func get_cycle_duration() -> float:
    if current_cycle_data == null:
        return 600.0  # Default 10 minutes
    
    var time_of_day = time_state.current_time_of_day
    
    match time_of_day:
        TimeOfDay.DAWN:
            return current_cycle_data.dawn_duration
        TimeOfDay.DAY:
            return current_cycle_data.day_duration
        TimeOfDay.DUSK:
            return current_cycle_data.dusk_duration
        TimeOfDay.NIGHT:
            return current_cycle_data.night_duration
    
    return current_cycle_data.day_duration + current_cycle_data.night_duration
```

---

## Integration Points

### With Survival System

```gdscript
# Apply time-based modifiers
func set_time_temperature_modifier(modifier: float) -> void:
    # SurvivalManager applies this to temperature calculations
    time_temperature_modifier = modifier

func set_time_visibility_modifier(modifier: float) -> void:
    # SurvivalManager applies this to visibility calculations
    time_visibility_modifier = modifier
```

### With World Generation

```gdscript
# Get biome for cycle data
func get_current_biome() -> String:
    if world_generator:
        var player_pos = get_player_position()
        return world_generator.get_biome_at_position(player_pos)
    return ""

# Update cycle when biome changes
func on_biome_changed(new_biome_id: String) -> void:
    set_biome(new_biome_id)
```

### With Enemy Spawning

```gdscript
# Get spawn multiplier for current time
func get_enemy_spawn_multiplier() -> float:
    return time_state.enemy_spawn_multiplier

# Enemy spawner queries this before spawning
func should_spawn_enemy(enemy_type: String) -> bool:
    var time_of_day = time_state.current_time_of_day
    # Some enemies only spawn at night
    if enemy_type == "night_enemy" and time_of_day != TimeOfDay.NIGHT:
        return false
    return true
```

### With UI System

```gdscript
# Get time string for display
func get_time_string() -> String:
    var day = time_state.day_number
    var hours = int(time_state.current_time * 24.0)
    var minutes = int((time_state.current_time * 24.0 - hours) * 60.0)
    var period = "AM" if hours < 12 else "PM"
    var display_hours = hours % 12
    if display_hours == 0:
        display_hours = 12
    return "Day %d - %d:%02d %s" % [day, display_hours, minutes, period]

# Get visual indicator data
func get_visual_indicator_data() -> Dictionary:
    return {
        "sun_position": time_state.sun_position,
        "moon_position": time_state.moon_position,
        "sky_color": time_state.current_color,
        "time_of_day": time_state.current_time_of_day
    }
```

---

## Save/Load System

### Save Data Structure

```gdscript
var time_save_data: Dictionary = {
    "current_time": time_state.current_time,
    "day_number": time_state.day_number,
    "total_time_elapsed": time_state.total_time_elapsed,
    "biome_id": time_state.biome_id,
    "season_id": time_state.season_id,
    "time_scale": time_scale
}
```

### Load Data Structure

```gdscript
func load_time_data(data: Dictionary) -> void:
    if data.has("current_time"):
        time_state.current_time = data["current_time"]
    if data.has("day_number"):
        time_state.day_number = data["day_number"]
    if data.has("total_time_elapsed"):
        time_state.total_time_elapsed = data["total_time_elapsed"]
    if data.has("biome_id"):
        set_biome(data["biome_id"])
    if data.has("season_id"):
        set_season(data["season_id"])
    if data.has("time_scale"):
        set_time_scale(data["time_scale"])
    
    # Update visuals
    update_lighting()
    update_sky_color()
```

---

## Error Handling

### TimeManager Error Handling

- **Missing Cycle Data:** Fallback to default cycle data if biome data missing
- **Invalid Time Values:** Clamp time values to valid range (0.0 to 1.0)
- **Missing References:** Check references exist before using (survival_manager, world_generator)
- **Division by Zero:** Check cycle duration > 0 before dividing

### Best Practices

- Use `push_error()` for critical errors (missing cycle data, invalid time)
- Use `push_warning()` for non-critical issues (missing references)
- Return default values on errors (don't crash)
- Validate all inputs before operations
- Fallback to defaults when data missing

---

## Default Values and Configuration

### TimeManager Defaults

```gdscript
time_scale = 1.0
pause_on_menu = true
show_clock = false
```

### DayNightCycleData Defaults

```gdscript
day_duration = 600.0  # 10 minutes
night_duration = 300.0  # 5 minutes
dawn_duration = 60.0  # 1 minute
dusk_duration = 60.0  # 1 minute
dawn_start_time = 0.25
day_start_time = 0.30
dusk_start_time = 0.75
night_start_time = 0.80
day_color = Color(1.0, 1.0, 1.0, 1.0)
night_color = Color(0.3, 0.3, 0.5, 1.0)
dawn_color = Color(1.0, 0.8, 0.6, 1.0)
dusk_color = Color(1.0, 0.6, 0.4, 1.0)
night_temperature_modifier = -10.0
day_temperature_modifier = 5.0
night_visibility_modifier = 0.5
night_enemy_spawn_multiplier = 1.5
day_enemy_spawn_multiplier = 0.8
```

---

## Performance Considerations

### Optimization Strategies

1. **Time Updates:**
   - Update visuals only when time_of_day changes (not every frame)
   - Use lerp for smooth color transitions (cheaper than instant changes)
   - Cache cycle duration calculations

2. **Visual Updates:**
   - CanvasModulate is efficient for global tinting
   - Update sky color only when needed
   - Limit sun/moon position updates to visual refresh rate

3. **Effect Application:**
   - Apply survival effects only when time_of_day changes
   - Cache modifiers for other systems to query
   - Batch updates when possible

4. **Biome Changes:**
   - Load cycle data on biome change (not every frame)
   - Cache current cycle data
   - Preload common biome cycle data

---

## Testing Checklist

### Time System
- [ ] Time progresses correctly
- [ ] Day/night cycle completes correctly
- [ ] Day counter increments correctly
- [ ] Time wraps around correctly (1.0 -> 0.0)

### Visual System
- [ ] Lighting changes smoothly
- [ ] Sky color transitions correctly
- [ ] Sun/moon positions update correctly
- [ ] Visual indicators display correctly

### Survival Effects
- [ ] Temperature modifier applies correctly
- [ ] Visibility modifier applies correctly
- [ ] Effects change with time of day
- [ ] Effects integrate with Survival System

### Enemy Spawning
- [ ] Spawn multiplier applies correctly
- [ ] Night-only enemies spawn only at night
- [ ] Day enemies spawn correctly
- [ ] Spawn rates change with time of day

### Biome Integration
- [ ] Cycle duration changes with biome
- [ ] Visual settings change with biome
- [ ] Effects change with biome
- [ ] Smooth transition when changing biomes

### Integration
- [ ] Integrates with Survival System correctly
- [ ] Integrates with World Generation correctly
- [ ] Integrates with Enemy Spawning correctly
- [ ] Integrates with UI System correctly
- [ ] Save/load works correctly

---

## Complete Implementation

### TimeManager Initialization

```gdscript
func _ready() -> void:
    # Get references
    world_generator = get_node_or_null("/root/WorldGenerator")
    survival_manager = get_node_or_null("/root/SurvivalManager")
    
    # Create visual components
    setup_visual_components()
    
    # Initialize
    initialize()

func initialize() -> void:
    # Load cycle data
    load_all_cycle_data()
    
    # Set initial biome
    if world_generator:
        var initial_biome = world_generator.get_biome_at_position(Vector2.ZERO)
        set_biome(initial_biome)
    else:
        # Fallback to default
        current_cycle_data = get_default_cycle_data()
    
    # Initialize time state
    time_state.current_time = 0.3  # Start at day
    time_state.current_time_of_day = TimeOfDay.DAY
    time_state.day_number = 1
    
    # Update visuals
    update_lighting()
    update_sky_color()

func setup_visual_components() -> void:
    # Create CanvasModulate for scene tinting
    canvas_modulate = CanvasModulate.new()
    canvas_modulate.color = Color.WHITE
    get_tree().root.add_child(canvas_modulate)
    
    # Create sky background (optional, for sky rendering)
    sky_background = ColorRect.new()
    sky_background.color = Color.WHITE
    sky_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    # Sky background would be added to main scene, not here

func load_all_cycle_data() -> void:
    # Load biome cycle data
    var biome_dir = DirAccess.open("res://resources/day_night_cycles/biomes/")
    if biome_dir:
        biome_dir.list_dir_begin()
        var file_name = biome_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var cycle_data = load("res://resources/day_night_cycles/biomes/" + file_name) as DayNightCycleData
                if cycle_data:
                    cycle_data_by_biome[cycle_data.biome_id] = cycle_data
            file_name = biome_dir.get_next()
    
    # Load season cycle data (optional)
    var season_dir = DirAccess.open("res://resources/day_night_cycles/seasons/")
    if season_dir:
        season_dir.list_dir_begin()
        var file_name = season_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var season_data = load("res://resources/day_night_cycles/seasons/" + file_name)
                # Season data structure TBD
            file_name = season_dir.get_next()

func get_default_cycle_data() -> DayNightCycleData:
    # Create default cycle data
    var default_data = DayNightCycleData.new()
    default_data.biome_id = "default"
    # Use default values from DayNightCycleData defaults
    return default_data
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── resources/
   │   └── day_night_cycles/
   │       ├── biomes/
   │       │   └── (cycle data resource files)
   │       └── seasons/
   │           └── (season cycle data resource files)
   └── scripts/
       └── managers/
           └── TimeManager.gd
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/TimeManager.gd` as `TimeManager`
   - **Important:** Load after WorldGenerator and SurvivalManager

3. **Create Cycle Data Resources:**
   - Right-click in `res://resources/day_night_cycles/biomes/`
   - Select "New Resource" → "DayNightCycleData"
   - Fill in biome_id, durations, colors, modifiers, etc.
   - Save as `{biome_id}.tres`

4. **Setup Visual Components:**
   - CanvasModulate created automatically by TimeManager
   - Add sky background to main scene if desired
   - Configure UI time display in HUD scene

### Initialization Order

**Autoload Order:**
1. GameManager
2. WorldGenerator
3. SurvivalManager
4. **TimeManager** (after WorldGenerator and SurvivalManager)

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Day/Night Cycle System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Time:** https://docs.godotengine.org/en/stable/classes/class_time.html
- **CanvasModulate:** https://docs.godotengine.org/en/stable/classes/class_canvasmodulate.html
- **Environment:** https://docs.godotengine.org/en/stable/classes/class_environment.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Day/Night Cycle System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Time Documentation](https://docs.godotengine.org/en/stable/classes/class_time.html) - Time management
- [CanvasModulate Documentation](https://docs.godotengine.org/en/stable/classes/class_canvasmodulate.html) - Scene tinting
- [Environment Documentation](https://docs.godotengine.org/en/stable/classes/class_environment.html) - Environment settings
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- DayNightCycleData is a Resource (can be created/edited in inspector)
- Cycle properties editable in inspector
- Visual settings configurable in inspector

**Visual Configuration:**
- Color settings editable in inspector
- Duration settings configurable
- Modifier values editable

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Cycle preview (visualize day/night cycle)
  - Time slider for testing
  - Color picker for sky colors

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Cycle data created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Variable Duration:** Cycle duration changes based on biome/season
2. **Full Effects:** Visual, enemy spawns, and survival stats all affected
3. **Visual Indicators:** Sun/moon position and sky color always visible
4. **Optional Clock:** Clock can be enabled in HUD/settings
5. **Smooth Transitions:** Color and lighting transitions smoothly
6. **Biome Integration:** Different biomes have different cycle durations and colors
7. **Survival Integration:** Temperature and visibility modifiers applied to Survival System
8. **Enemy Spawning:** Spawn multipliers and night-only enemies supported

