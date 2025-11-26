# Technical Specifications: Weather System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the weather system with hybrid weather types (normal + sci-fi, biome-dependent), full effects (visual + survival + pixel physics), and weather interactions with materials. This system integrates with Survival System, Pixel Physics System, World Generation, Day/Night Cycle, and UI System.

---

## Research Notes

### Weather System Architecture Best Practices

**Research Findings:**
- Weather affects atmosphere and gameplay
- Biome-dependent weather adds world-building depth
- Visual effects create immersion
- Survival effects add challenge
- Physics interactions create emergent gameplay

**Sources:**
- [Godot 4 Particle Systems](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html) - Particle effects
- [Godot 4 CanvasModulate Documentation](https://docs.godotengine.org/en/stable/classes/class_canvasmodulate.html) - Scene tinting
- General weather system patterns in survival games

**Implementation Approach:**
- WeatherManager singleton manages all weather
- Biome-dependent weather types
- Full effects: visual, survival, pixel physics
- Particle systems for weather effects
- Smooth transitions between weather types

**Why This Approach:**
- Biome-dependent weather adds depth
- Full effects create immersive experience
- Physics interactions create emergent gameplay
- Particle systems provide visual polish

### Weather Physics Integration

**Research Findings:**
- Weather can interact with pixel physics
- Rain fills water pools
- Acid rain damages materials
- Storms create wind effects
- Snow accumulates on surfaces

**Sources:**
- Pixel physics simulation patterns
- Material interaction systems

**Implementation Approach:**
- Weather particles interact with pixel grid
- Material-specific reactions (acid rain + materials)
- Accumulation effects (snow, water)
- Wind affects particle movement

**Why This Approach:**
- Creates emergent gameplay
- Adds depth to pixel physics
- Realistic weather interactions
- Engaging visual effects

---

## Data Structures

### WeatherType

```gdscript
enum WeatherType {
    CLEAR,          # No weather
    CLOUDY,         # Cloudy sky, no precipitation
    RAIN,           # Normal rain
    SNOW,           # Snow
    FOG,            # Fog (reduces visibility)
    STORM,          # Heavy rain + wind
    ACID_RAIN,      # Sci-Fi: Acid rain (damages materials)
    RADIATION_STORM, # Sci-Fi: Radiation storm (damages player)
    TOXIC_FOG,      # Sci-Fi: Toxic fog (damages player)
    ENERGY_STORM    # Sci-Fi: Energy storm (affects electronics)
}
```

### WeatherData

```gdscript
class_name WeatherData
extends Resource

# Weather Identification
@export var weather_id: String  # Unique identifier
@export var weather_type: WeatherType
@export var weather_name: String  # Display name

# Biome Availability
@export var allowed_biomes: Array[String] = []  # Biome IDs (empty = all biomes)
@export var forbidden_biomes: Array[String] = []  # Biome IDs where weather can't occur

# Visual Effects
@export var sky_color: Color = Color(0.7, 0.7, 0.8, 1.0)  # Sky tint
@export var overlay_color: Color = Color(1.0, 1.0, 1.0, 0.0)  # Overlay tint
@export var particle_texture: Texture2D  # Particle sprite
@export var particle_color: Color = Color.WHITE
@export var particle_density: float = 100.0  # Particles per second
@export var particle_speed: float = 200.0  # Pixels per second
@export var particle_gravity: float = 500.0  # Gravity for particles

# Survival Effects
@export var temperature_modifier: float = 0.0  # Temperature change
@export var visibility_modifier: float = 1.0  # Visibility multiplier (0.0 to 1.0)
@export var movement_speed_modifier: float = 1.0  # Movement speed multiplier
@export var damage_per_second: float = 0.0  # Damage to player per second
@export var damage_type: String = ""  # Damage type (radiation, toxic, etc.)

# Pixel Physics Effects
@export var affects_pixel_physics: bool = false
@export var material_interactions: Dictionary = {}  # material_id -> interaction_data
# Example: {"stone": {"damage": 0.1, "transform_to": "damaged_stone"}}
@export var fills_water: bool = false  # Rain fills water pools
@export var water_fill_rate: float = 0.1  # Water fill rate per second
@export var accumulates: bool = false  # Snow/acid accumulates
@export var accumulation_material_id: String = ""  # Material to accumulate

# Wind Effects
@export var wind_strength: float = 0.0  # Wind force (affects particles, player)
@export var wind_direction: float = 0.0  # Wind direction in radians
@export var wind_variation: float = 0.5  # Wind direction variation

# Duration
@export var min_duration: float = 60.0  # Minimum duration in seconds
@export var max_duration: float = 300.0  # Maximum duration in seconds
@export var transition_duration: float = 5.0  # Transition time between weather types

# Spawn Configuration
@export var spawn_chance: float = 0.1  # Chance to spawn (per check interval)
@export var spawn_interval: float = 300.0  # Check interval in seconds
```

### CurrentWeather

```gdscript
class_name CurrentWeather
extends RefCounted

var weather_data: WeatherData = null
var weather_type: WeatherType = WeatherType.CLEAR
var start_time: float = 0.0
var duration: float = 0.0
var remaining_time: float = 0.0
var intensity: float = 1.0  # 0.0 to 1.0 (for transitions)

# Visual State
var particle_system: GPUParticles2D = null
var overlay_modulate: ColorModulate = null

# Effects State
var temperature_modifier: float = 0.0
var visibility_modifier: float = 1.0
var movement_speed_modifier: float = 1.0
var damage_per_second: float = 0.0
```

---

## Core Classes

### WeatherManager (Autoload Singleton)

```gdscript
class_name WeatherManager
extends Node

# Weather Registry
var weather_database: Dictionary = {}  # weather_id -> WeatherData
var weather_by_biome: Dictionary = {}  # biome_id -> Array[WeatherData]

# Current Weather State
var current_weather: CurrentWeather = CurrentWeather.new()
var previous_weather: CurrentWeather = null
var transition_progress: float = 0.0  # 0.0 to 1.0

# Weather Configuration
@export var weather_update_interval: float = 1.0  # Update interval in seconds
@export var transition_smoothness: float = 0.1  # Transition lerp speed
@export var enable_physics_interactions: bool = true

# References
var world_generator: WorldGenerator
var survival_manager: SurvivalManager
var pixel_physics_manager: PixelPhysicsManager
var player: Node2D = null

# Visual Components
var weather_particles: GPUParticles2D = null
var weather_overlay: ColorRect = null
var weather_canvas_modulate: CanvasModulate = null

# Signals
signal weather_changed(new_weather: WeatherType, weather_data: WeatherData)
signal weather_transition_started(from_weather: WeatherType, to_weather: WeatherType)
signal weather_transition_completed(new_weather: WeatherType)
signal weather_intensity_changed(intensity: float)

# Initialization
func _ready() -> void
func initialize() -> void

# Weather Management
func _process(delta: float) -> void
func update_weather(delta: float) -> void
func set_weather(weather_id: String, duration: float = -1.0) -> bool
func set_weather_type(weather_type: WeatherType, duration: float = -1.0) -> bool
func clear_weather() -> void

# Weather Selection
func select_random_weather(biome_id: String) -> WeatherData
func get_available_weather(biome_id: String) -> Array[WeatherData]
func can_spawn_weather(weather_data: WeatherData, biome_id: String) -> bool

# Visual Updates
func update_particles() -> void
func update_overlay() -> void
func update_sky_color() -> void

# Effects Application
func apply_survival_effects(delta: float) -> void
func apply_physics_effects(delta: float) -> void
func get_temperature_modifier() -> float
func get_visibility_modifier() -> float
func get_movement_speed_modifier() -> float
func get_damage_per_second() -> float

# Wind Effects
func get_wind_strength() -> float
func get_wind_direction() -> float
func apply_wind_to_particle(particle: Node2D, delta: float) -> void
```

---

## System Architecture

### Component Hierarchy

```
WeatherManager (Autoload Singleton)
├── WeatherData[] (Dictionary)
├── CurrentWeather (RefCounted)
├── GPUParticles2D (Node2D)
├── ColorRect (Overlay)
├── CanvasModulate (Sky Tint)
└── UI/WeatherDisplay (Control)
    └── WeatherIcon (TextureRect)
```

### Data Flow

1. **Weather Update:**
   ```
   _process(delta)
   ├── Check if weather should change
   ├── Select new weather (if needed)
   ├── Transition from old to new weather
   ├── Update visual effects
   ├── Apply survival effects
   ├── Apply physics effects
   └── Emit signals
   ```

2. **Weather Transition:**
   ```
   Change weather
   ├── Start transition
   ├── Fade out old weather particles
   ├── Fade in new weather particles
   ├── Update sky color
   ├── Update overlay
   └── Complete transition
   ```

3. **Physics Interaction:**
   ```
   Weather affects pixel physics
   ├── Rain particles hit pixel grid
   ├── Check material interactions
   ├── Apply damage/transformations
   ├── Fill water pools (if rain)
   ├── Accumulate materials (if snow/acid)
   └── Update pixel grid
   ```

---

## Algorithms

### Weather Selection Algorithm

```gdscript
func select_random_weather(biome_id: String) -> WeatherData:
    var available_weather = get_available_weather(biome_id)
    if available_weather.is_empty():
        return null
    
    # Weighted random selection based on spawn_chance
    var total_weight: float = 0.0
    for weather in available_weather:
        total_weight += weather.spawn_chance
    
    var random_value = randf() * total_weight
    var current_weight: float = 0.0
    
    for weather in available_weather:
        current_weight += weather.spawn_chance
        if random_value <= current_weight:
            return weather
    
    # Fallback to first available
    return available_weather[0]

func get_available_weather(biome_id: String) -> Array[WeatherData]:
    var available: Array[WeatherData] = []
    
    # Get weather for biome
    var biome_weather = weather_by_biome.get(biome_id, [])
    
    for weather in biome_weather:
        if can_spawn_weather(weather, biome_id):
            available.append(weather)
    
    # Also check general weather (no biome restriction)
    for weather_id in weather_database:
        var weather = weather_database[weather_id]
        if weather.allowed_biomes.is_empty() and can_spawn_weather(weather, biome_id):
            if weather not in available:
                available.append(weather)
    
    return available

func can_spawn_weather(weather_data: WeatherData, biome_id: String) -> bool:
    # Check forbidden biomes
    if biome_id in weather_data.forbidden_biomes:
        return false
    
    # Check allowed biomes (empty = all allowed)
    if not weather_data.allowed_biomes.is_empty():
        if biome_id not in weather_data.allowed_biomes:
            return false
    
    return true
```

### Weather Transition Algorithm

```gdscript
func set_weather(weather_id: String, duration: float = -1.0) -> bool:
    if not weather_database.has(weather_id):
        push_error("WeatherManager: Weather not found: " + weather_id)
        return false
    
    var new_weather_data = weather_database[weather_id]
    return set_weather_by_data(new_weather_data, duration)

func set_weather_by_data(weather_data: WeatherData, duration: float = -1.0) -> bool:
    # Store previous weather
    previous_weather = current_weather.duplicate()
    
    # Set new weather
    current_weather.weather_data = weather_data
    current_weather.weather_type = weather_data.weather_type
    current_weather.start_time = Time.get_unix_time_from_system()
    current_weather.duration = duration if duration > 0.0 else randf_range(weather_data.min_duration, weather_data.max_duration)
    current_weather.remaining_time = current_weather.duration
    current_weather.intensity = 0.0  # Start at 0 for transition
    
    # Start transition
    transition_progress = 0.0
    weather_transition_started.emit(previous_weather.weather_type, current_weather.weather_type)
    
    # Update visuals
    setup_weather_visuals()
    
    weather_changed.emit(current_weather.weather_type, weather_data)
    return true

func update_weather(delta: float) -> void:
    if current_weather.weather_data == null:
        return
    
    # Update transition
    if transition_progress < 1.0:
        transition_progress += delta / current_weather.weather_data.transition_duration
        transition_progress = min(transition_progress, 1.0)
        current_weather.intensity = transition_progress
        
        if transition_progress >= 1.0:
            weather_transition_completed.emit(current_weather.weather_type)
    
    # Update remaining time
    current_weather.remaining_time -= delta
    
    # Check if weather should end
    if current_weather.remaining_time <= 0.0:
        # Select new weather
        var biome_id = get_current_biome()
        var new_weather = select_random_weather(biome_id)
        if new_weather:
            set_weather_by_data(new_weather)
        else:
            clear_weather()
    
    # Update visuals
    update_particles()
    update_overlay()
    update_sky_color()
    
    # Apply effects
    apply_survival_effects(delta)
    if enable_physics_interactions:
        apply_physics_effects(delta)
```

### Survival Effects Algorithm

```gdscript
func apply_survival_effects(delta: float) -> void:
    if current_weather.weather_data == null or survival_manager == null:
        return
    
    # Calculate modifiers with intensity (for transitions)
    var intensity = current_weather.intensity
    var temp_modifier = current_weather.weather_data.temperature_modifier * intensity
    var vis_modifier = lerp(1.0, current_weather.weather_data.visibility_modifier, intensity)
    var move_modifier = lerp(1.0, current_weather.weather_data.movement_speed_modifier, intensity)
    var damage = current_weather.weather_data.damage_per_second * intensity * delta
    
    # Store for queries
    current_weather.temperature_modifier = temp_modifier
    current_weather.visibility_modifier = vis_modifier
    current_weather.movement_speed_modifier = move_modifier
    current_weather.damage_per_second = damage / delta
    
    # Apply to survival manager
    if survival_manager:
        survival_manager.set_weather_temperature_modifier(temp_modifier)
        survival_manager.set_weather_visibility_modifier(vis_modifier)
        survival_manager.set_weather_movement_modifier(move_modifier)
    
    # Apply damage
    if damage > 0.0 and player:
        var damage_type = current_weather.weather_data.damage_type
        apply_weather_damage(damage, damage_type)

func apply_weather_damage(amount: float, damage_type: String) -> void:
    if CombatManager:
        CombatManager.apply_damage_to_player(amount, damage_type)
    elif SurvivalManager:
        SurvivalManager.take_damage(amount)
```

### Physics Effects Algorithm

```gdscript
func apply_physics_effects(delta: float) -> void:
    if current_weather.weather_data == null or not pixel_physics_manager:
        return
    
    if not current_weather.weather_data.affects_pixel_physics:
        return
    
    var intensity = current_weather.intensity
    
    # Rain fills water pools
    if current_weather.weather_data.fills_water:
        fill_water_pools(delta * intensity)
    
    # Material interactions (acid rain, etc.)
    if not current_weather.weather_data.material_interactions.is_empty():
        apply_material_interactions(delta * intensity)
    
    # Accumulation (snow, acid)
    if current_weather.weather_data.accumulates:
        accumulate_material(delta * intensity)

func fill_water_pools(delta: float) -> void:
    if not pixel_physics_manager:
        return
    
    # Find water cells and fill them
    var fill_rate = current_weather.weather_data.water_fill_rate * delta
    # This would integrate with PixelPhysicsManager to fill water cells
    pixel_physics_manager.fill_water_cells(fill_rate)

func apply_material_interactions(delta: float) -> void:
    if not pixel_physics_manager:
        return
    
    # Get weather particles hitting pixel grid
    var hit_positions = get_particle_hit_positions()
    
    for pos in hit_positions:
        var material = pixel_physics_manager.get_material_at(pos)
        if material == null:
            continue
        
        var material_id = material.material_id
        if current_weather.weather_data.material_interactions.has(material_id):
            var interaction = current_weather.weather_data.material_interactions[material_id]
            apply_material_interaction(pos, material, interaction, delta)

func apply_material_interaction(pos: Vector2, material: PixelMaterial, interaction: Dictionary, delta: float) -> void:
    # Apply damage
    if interaction.has("damage"):
        var damage = interaction["damage"] * delta
        pixel_physics_manager.damage_material_at(pos, damage)
    
    # Transform material
    if interaction.has("transform_to"):
        var new_material_id = interaction["transform_to"]
        var new_material = pixel_physics_manager.material_registry.get_material_by_name(new_material_id)
        if new_material:
            pixel_physics_manager.set_material_at(pos, new_material)

func accumulate_material(delta: float) -> void:
    if not pixel_physics_manager or current_weather.weather_data.accumulation_material_id.is_empty():
        return
    
    # Get accumulation material
    var acc_material = pixel_physics_manager.material_registry.get_material_by_name(
        current_weather.weather_data.accumulation_material_id
    )
    if acc_material == null:
        return
    
    # Accumulate on surfaces (top of solid materials)
    var accumulation_rate = delta * 0.1  # Configurable rate
    # This would integrate with PixelPhysicsManager to add material on surfaces
    pixel_physics_manager.accumulate_material_on_surfaces(acc_material, accumulation_rate)
```

### Particle System Algorithm

```gdscript
func setup_weather_visuals() -> void:
    if current_weather.weather_data == null:
        return
    
    # Create/update particle system
    if weather_particles == null:
        weather_particles = GPUParticles2D.new()
        add_child(weather_particles)
    
    # Configure particles
    var weather_data = current_weather.weather_data
    weather_particles.texture = weather_data.particle_texture
    weather_particles.amount = int(weather_data.particle_density * weather_data.max_duration)
    weather_particles.lifetime = weather_data.max_duration
    
    # Set emission
    var emission = weather_particles.process_material as ParticleProcessMaterial
    if emission == null:
        emission = ParticleProcessMaterial.new()
        weather_particles.process_material = emission
    
    # Configure emission
    emission.direction = Vector3(0, 1, 0)  # Down
    emission.initial_velocity_min = weather_data.particle_speed * 0.8
    emission.initial_velocity_max = weather_data.particle_speed * 1.2
    emission.gravity = Vector3(0, weather_data.particle_gravity, 0)
    
    # Set color
    weather_particles.modulate = weather_data.particle_color
    
    # Position particles (above viewport)
    var viewport_size = get_viewport().get_visible_rect().size
    weather_particles.position = Vector2(viewport_size.x / 2, -100)
    weather_particles.emission_rect_extents = Vector3(viewport_size.x, 0, 0)

func update_particles() -> void:
    if weather_particles == null or current_weather.weather_data == null:
        return
    
    # Update intensity (for transitions)
    weather_particles.amount = int(current_weather.weather_data.particle_density * current_weather.weather_data.max_duration * current_weather.intensity)
    
    # Apply wind to particles
    if current_weather.weather_data.wind_strength > 0.0:
        var emission = weather_particles.process_material as ParticleProcessMaterial
        if emission:
            var wind_dir = Vector3(cos(current_weather.weather_data.wind_direction), sin(current_weather.weather_data.wind_direction), 0)
            emission.gravity += wind_dir * current_weather.weather_data.wind_strength
```

---

## Integration Points

### With Survival System

```gdscript
# Apply weather modifiers
func set_weather_temperature_modifier(modifier: float) -> void:
    weather_temperature_modifier = modifier

func set_weather_visibility_modifier(modifier: float) -> void:
    weather_visibility_modifier = modifier

func set_weather_movement_modifier(modifier: float) -> void:
    weather_movement_modifier = modifier
```

### With Pixel Physics System

```gdscript
# Fill water cells
func fill_water_cells(rate: float) -> void:
    # Fill water cells in pixel grid
    var water_cells = get_water_cells()
    for cell_pos in water_cells:
        var cell = get_cell_at(cell_pos)
        if cell and cell.material.material_id == "water":
            cell.volume = min(cell.volume + rate, 1.0)

# Accumulate material on surfaces
func accumulate_material_on_surfaces(material: PixelMaterial, rate: float) -> void:
    # Find top surfaces of solid materials
    var surfaces = find_top_surfaces()
    for surface_pos in surfaces:
        var cell_above = get_cell_at(surface_pos + Vector2i(0, -1))
        if cell_above == null or cell_above.material == null:
            # Empty space above, accumulate material
            add_material_at(surface_pos + Vector2i(0, -1), material, rate)
```

### With World Generation

```gdscript
# Get current biome for weather selection
func get_current_biome() -> String:
    if world_generator and player:
        return world_generator.get_biome_at_position(player.global_position)
    return ""

# Update weather when biome changes
func on_biome_changed(new_biome_id: String) -> void:
    # Select appropriate weather for new biome
    var new_weather = select_random_weather(new_biome_id)
    if new_weather:
        set_weather_by_data(new_weather)
```

### With Day/Night Cycle

```gdscript
# Weather can change based on time of day
func on_time_of_day_changed(time_of_day: TimeOfDay) -> void:
    # Some weather more likely at certain times
    # Storms more likely at night, clear weather more likely during day
    var biome_id = get_current_biome()
    var available_weather = get_available_weather(biome_id)
    
    # Filter by time preference (if weather has time preference)
    # This would be configurable in WeatherData
```

---

## Save/Load System

### Save Data Structure

```gdscript
var weather_save_data: Dictionary = {
    "current_weather_id": current_weather.weather_data.weather_id if current_weather.weather_data else "",
    "remaining_time": current_weather.remaining_time,
    "intensity": current_weather.intensity,
    "transition_progress": transition_progress
}
```

### Load Data Structure

```gdscript
func load_weather_data(data: Dictionary) -> void:
    if data.has("current_weather_id") and not data["current_weather_id"].is_empty():
        var weather_id = data["current_weather_id"]
        if weather_database.has(weather_id):
            var weather_data = weather_database[weather_id]
            set_weather_by_data(weather_data, data.get("remaining_time", -1.0))
            current_weather.intensity = data.get("intensity", 1.0)
            transition_progress = data.get("transition_progress", 1.0)
```

---

## Error Handling

### WeatherManager Error Handling

- **Invalid Weather IDs:** Check weather exists before setting, return errors gracefully
- **Missing References:** Check references exist before using (survival_manager, pixel_physics_manager)
- **Invalid Durations:** Clamp durations to valid range
- **Missing Particle Textures:** Fallback to default particle texture

### Best Practices

- Use `push_error()` for critical errors (invalid weather_id, missing references)
- Use `push_warning()` for non-critical issues (missing textures, no available weather)
- Return false/null on errors (don't crash)
- Validate all inputs before operations
- Fallback to defaults when data missing

---

## Default Values and Configuration

### WeatherManager Defaults

```gdscript
weather_update_interval = 1.0
transition_smoothness = 0.1
enable_physics_interactions = true
```

### WeatherData Defaults

```gdscript
weather_type = WeatherType.CLEAR
sky_color = Color(0.7, 0.7, 0.8, 1.0)
overlay_color = Color(1.0, 1.0, 1.0, 0.0)
particle_density = 100.0
particle_speed = 200.0
particle_gravity = 500.0
temperature_modifier = 0.0
visibility_modifier = 1.0
movement_speed_modifier = 1.0
damage_per_second = 0.0
affects_pixel_physics = false
fills_water = false
water_fill_rate = 0.1
accumulates = false
wind_strength = 0.0
wind_direction = 0.0
wind_variation = 0.5
min_duration = 60.0
max_duration = 300.0
transition_duration = 5.0
spawn_chance = 0.1
spawn_interval = 300.0
```

---

## Performance Considerations

### Optimization Strategies

1. **Particle Systems:**
   - Limit particle count based on performance
   - Use GPU particles for better performance
   - Cull particles outside viewport
   - Reduce particle density on low-end devices

2. **Physics Interactions:**
   - Limit physics checks per frame
   - Batch material interactions
   - Use spatial partitioning for hit detection
   - Skip physics when weather intensity is low

3. **Visual Updates:**
   - Update particles only when weather changes
   - Use lerp for smooth transitions (cheaper than instant)
   - Cache weather data lookups
   - Limit overlay updates

4. **Weather Selection:**
   - Cache available weather per biome
   - Pre-calculate spawn chances
   - Limit weather checks to intervals (not every frame)

---

## Testing Checklist

### Weather System
- [ ] Weather spawns correctly
- [ ] Weather transitions smoothly
- [ ] Weather duration works correctly
- [ ] Weather selection respects biome restrictions
- [ ] Weather clears correctly

### Visual Effects
- [ ] Particles display correctly
- [ ] Sky color changes correctly
- [ ] Overlay displays correctly
- [ ] Transitions are smooth
- [ ] Wind affects particles correctly

### Survival Effects
- [ ] Temperature modifier applies correctly
- [ ] Visibility modifier applies correctly
- [ ] Movement speed modifier applies correctly
- [ ] Damage applies correctly
- [ ] Effects integrate with Survival System

### Physics Interactions
- [ ] Rain fills water pools correctly
- [ ] Material interactions work correctly
- [ ] Accumulation works correctly
- [ ] Acid rain damages materials correctly
- [ ] Physics effects integrate with Pixel Physics System

### Integration
- [ ] Integrates with Survival System correctly
- [ ] Integrates with Pixel Physics System correctly
- [ ] Integrates with World Generation correctly
- [ ] Integrates with Day/Night Cycle correctly
- [ ] Save/load works correctly

---

## Complete Implementation

### WeatherManager Initialization

```gdscript
func _ready() -> void:
    # Get references
    world_generator = get_node_or_null("/root/WorldGenerator")
    survival_manager = get_node_or_null("/root/SurvivalManager")
    pixel_physics_manager = get_node_or_null("/root/PixelPhysicsManager")
    player = get_tree().get_first_node_in_group("player")
    
    # Create visual components
    setup_visual_components()
    
    # Initialize
    initialize()

func initialize() -> void:
    # Load weather data
    load_all_weather_data()
    
    # Set initial weather (clear)
    clear_weather()
    
    # Start weather update timer
    # Weather will change based on spawn chances

func setup_visual_components() -> void:
    # Create overlay
    weather_overlay = ColorRect.new()
    weather_overlay.color = Color(1.0, 1.0, 1.0, 0.0)
    weather_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    # Overlay would be added to main scene, not here
    
    # Create canvas modulate for sky
    weather_canvas_modulate = CanvasModulate.new()
    weather_canvas_modulate.color = Color.WHITE
    # CanvasModulate would be added to scene tree

func load_all_weather_data() -> void:
    var weather_dir = DirAccess.open("res://resources/weather/")
    if weather_dir:
        weather_dir.list_dir_begin()
        var file_name = weather_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var weather_data = load("res://resources/weather/" + file_name) as WeatherData
                if weather_data:
                    weather_database[weather_data.weather_id] = weather_data
                    # Index by biome
                    for biome_id in weather_data.allowed_biomes:
                        if not weather_by_biome.has(biome_id):
                            weather_by_biome[biome_id] = []
                        weather_by_biome[biome_id].append(weather_data)
            file_name = weather_dir.get_next()
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── resources/
   │   └── weather/
   │       └── (weather data resource files)
   └── scripts/
       └── managers/
           └── WeatherManager.gd
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/WeatherManager.gd` as `WeatherManager`
   - **Important:** Load after WorldGenerator, SurvivalManager, and PixelPhysicsManager

3. **Create Weather Resources:**
   - Right-click in `res://resources/weather/`
   - Select "New Resource" → "WeatherData"
   - Fill in weather_id, weather_type, effects, etc.
   - Save as `{weather_id}.tres`

### Initialization Order

**Autoload Order:**
1. GameManager
2. WorldGenerator
3. SurvivalManager
4. PixelPhysicsManager
5. **WeatherManager** (after all dependencies)

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Weather System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **GPUParticles2D:** https://docs.godotengine.org/en/stable/classes/class_gpuparticles2d.html
- **ParticleProcessMaterial:** https://docs.godotengine.org/en/stable/classes/class_particleprocessmaterial.html
- **CanvasModulate:** https://docs.godotengine.org/en/stable/classes/class_canvasmodulate.html
- **ColorRect:** https://docs.godotengine.org/en/stable/classes/class_colorrect.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Weather System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [GPUParticles2D Documentation](https://docs.godotengine.org/en/stable/classes/class_gpuparticles2d.html) - Particle systems
- [ParticleProcessMaterial Documentation](https://docs.godotengine.org/en/stable/classes/class_particleprocessmaterial.html) - Particle configuration
- [CanvasModulate Documentation](https://docs.godotengine.org/en/stable/classes/class_canvasmodulate.html) - Scene tinting
- [ColorRect Documentation](https://docs.godotengine.org/en/stable/classes/class_colorrect.html) - Overlay rendering

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- WeatherData is a Resource (can be created/edited in inspector)
- Weather properties editable in inspector
- Visual settings configurable in inspector

**Visual Configuration:**
- Particle settings editable in inspector
- Color settings configurable
- Effect values editable

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Weather preview (visualize weather effects)
  - Particle system preview
  - Weather transition tester

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Weather data created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Biome-Dependent Weather:** Weather types vary by biome
2. **Full Effects:** Visual, survival, and pixel physics all affected
3. **Smooth Transitions:** Weather transitions smoothly between types
4. **Physics Interactions:** Weather interacts with pixel physics (rain fills water, acid damages materials)
5. **Particle Systems:** GPU particles for weather effects
6. **Wind Effects:** Wind affects particles and player movement
7. **Accumulation:** Some weather accumulates (snow, acid)
8. **Damage Types:** Weather can damage player (radiation, toxic, etc.)

