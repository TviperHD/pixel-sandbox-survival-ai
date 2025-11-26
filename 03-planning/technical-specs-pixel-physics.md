# Technical Specifications: Pixel Physics System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the pixel-level physics simulation system, including material simulation, destruction, liquid/powder physics, and chemical reactions. This system integrates with WorldGenerator, BuildingManager, CombatManager, and MinimapManager for real-time pixel physics simulation.

---

## Research Notes

### Pixel Physics System Architecture Best Practices

**Research Findings:**
- Pixel-based physics requires efficient grid system
- Chunking essential for large worlds
- Material simulation uses cellular automata principles
- Destruction uses radius-based removal
- Liquid/powder physics uses gravity and flow algorithms

**Sources:**
- [Noita Pixel Physics](https://noitagame.com/) - Inspiration for pixel physics
- [Cellular Automata](https://en.wikipedia.org/wiki/Cellular_automaton) - Material simulation principles
- [Godot 4 Performance](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance optimization
- General pixel physics implementation patterns

**Implementation Approach:**
- PixelPhysicsManager as autoload singleton
- PixelGrid for cell-based storage
- Chunking for large world support
- Material registry for material definitions
- PixelRenderer for efficient rendering
- Multithreading for physics updates

**Why This Approach:**
- Singleton: centralized physics management
- Grid system: efficient cell access
- Chunking: handles large worlds efficiently
- Material registry: easy material configuration
- PixelRenderer: optimized rendering
- Multithreading: performance optimization

### Material Simulation Best Practices

**Research Findings:**
- Materials have properties (density, friction, viscosity)
- State changes (solid/liquid/gas) based on temperature
- Flow algorithms for liquids/powders
- Chemical reactions between materials

**Sources:**
- General material simulation patterns

**Implementation Approach:**
- PixelMaterial Resource for material data
- State-based material behavior
- Temperature-based state changes
- Flow algorithms for liquids/powders
- Reaction system for chemical interactions

**Why This Approach:**
- Resource: easy to create/edit materials
- State-based: clear material behavior
- Temperature: realistic state changes
- Flow algorithms: realistic liquid/powder behavior
- Reactions: complex material interactions

### Destruction System Best Practices

**Research Findings:**
- Radius-based destruction removes cells
- Force affects destruction radius
- Destruction triggers physics updates
- Debris particles optional

**Sources:**
- General destruction system patterns

**Implementation Approach:**
- Radius-based cell removal
- Force affects destruction area
- Immediate physics update after destruction
- Optional particle effects

**Why This Approach:**
- Radius-based: simple destruction mechanic
- Force scaling: varied destruction effects
- Immediate update: responsive destruction
- Particles: visual feedback

### Chunking System Best Practices

**Research Findings:**
- Chunking reduces memory usage
- Only active chunks updated
- Chunks loaded/unloaded dynamically
- Chunk size balances performance and memory

**Sources:**
- General chunking patterns

**Implementation Approach:**
- Chunk-based cell storage
- Active chunk tracking
- Dynamic chunk loading/unloading
- Configurable chunk size

**Why This Approach:**
- Chunk storage: efficient memory usage
- Active tracking: only update visible chunks
- Dynamic loading: handles large worlds
- Configurable: optimize per project

---

## Data Structures

### PixelMaterial

```gdscript
class_name PixelMaterial
extends Resource

@export var material_id: int
@export var material_name: String
@export var material_type: String  # "solid", "liquid", "powder", "gas"
@export var density: float
@export var friction: float
@export var restitution: float  # bounciness
@export var viscosity: float  # for liquids
@export var flow_rate: float  # for liquids/powders
@export var color: Color
@export var is_flammable: bool = false
@export var burn_rate: float = 0.0
@export var melting_point: float = -1.0  # -1 = doesn't melt
@export var freezing_point: float = -1.0  # -1 = doesn't freeze
@export var hardness: float = 1.0  # resistance to destruction
@export var conductivity: float = 0.0  # electrical/thermal
```

### PixelCell

```gdscript
class_name PixelCell
extends RefCounted

var material: PixelMaterial
var position: Vector2i
var velocity: Vector2 = Vector2.ZERO
var temperature: float = 20.0
var pressure: float = 1.0
var state: String = "solid"  # "solid", "liquid", "gas"
var lifetime: float = -1.0  # -1 = permanent
var age: float = 0.0
var is_active: bool = true
var neighbors: Array[PixelCell] = []
```

### PixelGrid

```gdscript
class_name PixelGrid
extends RefCounted

var grid_size: Vector2i
var cell_size: float = 1.0  # Size of each pixel in world units
var cells: Dictionary = {}  # Vector2i -> PixelCell
var active_cells: Array[PixelCell] = []
var material_registry: Dictionary = {}  # material_id -> PixelMaterial

# Chunking
var chunk_size: Vector2i = Vector2i(64, 64)
var chunks: Dictionary = {}  # Vector2i -> ChunkData

# Functions
func get_cell_at(pos: Vector2i) -> PixelCell
func set_cell_at(pos: Vector2i, material: PixelMaterial) -> void
func remove_cell_at(pos: Vector2i) -> void
func get_neighbors(pos: Vector2i) -> Array[PixelCell]
func update_physics(delta: float) -> void
func apply_destruction(pos: Vector2i, radius: float, force: float) -> void
func get_chunk_key(pos: Vector2i) -> Vector2i
func load_chunk(chunk_key: Vector2i) -> void
func unload_chunk(chunk_key: Vector2i) -> void
```

### ChunkData

```gdscript
class_name ChunkData
extends RefCounted

var chunk_key: Vector2i
var cells: Dictionary = {}  # Local coordinates -> PixelCell
var is_loaded: bool = false
var is_dirty: bool = false  # Needs rendering update
var last_update_time: float = 0.0
```

### ChemicalReaction

```gdscript
class_name ChemicalReaction
extends Resource

# Reaction Identification
@export var reaction_id: String  # Unique identifier
@export var reaction_name: String  # Display name

# Reactants (materials that react)
@export var material_1_id: String  # First material ID
@export var material_2_id: String  # Second material ID (can be same as material_1 for self-reactions)

# Reaction Conditions (highly configurable)
@export var min_temperature: float = -273.15  # Minimum temperature required (-273.15 = no minimum)
@export var max_temperature: float = 10000.0  # Maximum temperature allowed (10000 = no maximum)
@export var min_pressure: float = 0.0  # Minimum pressure required
@export var max_pressure: float = 1000000.0  # Maximum pressure allowed
@export var requires_catalyst: bool = false  # Requires catalyst material
@export var catalyst_material_id: String = ""  # Catalyst material ID
@export var catalyst_consumed: bool = false  # Whether catalyst is consumed

# Reaction Results (highly configurable)
@export var result_material_id: String = ""  # Result material ID (empty = no material change)
@export var result_material_2_id: String = ""  # Second result material (for complex reactions)
@export var result_quantities: Dictionary = {}  # material_id -> quantity (for multi-product reactions)
@export var consume_first: bool = true  # Whether first material is consumed
@export var consume_second: bool = true  # Whether second material is consumed
@export var consume_ratio: Vector2 = Vector2(1.0, 1.0)  # Ratio of materials consumed (1.0 = all, 0.5 = half)

# Reaction Effects (highly configurable)
@export var heat_produced: float = 0.0  # Heat produced by reaction
@export var heat_consumed: float = 0.0  # Heat consumed by reaction
@export var pressure_change: float = 0.0  # Pressure change
@export var is_explosive: bool = false  # Creates explosion
@export var explosion_radius: float = 0.0  # Explosion radius
@export var explosion_force: float = 0.0  # Explosion force
@export var creates_gas: bool = false  # Creates gas material
@export var gas_material_id: String = ""  # Gas material ID
@export var gas_volume: float = 0.0  # Gas volume produced

# Reaction Rate (highly configurable)
@export var reaction_rate: float = 1.0  # Base reaction rate (1.0 = instant, 0.1 = slow)
@export var rate_temperature_factor: float = 0.0  # How temperature affects rate (0 = no effect)
@export var rate_pressure_factor: float = 0.0  # How pressure affects rate (0 = no effect)
@export var requires_contact_time: float = 0.0  # Time materials must be in contact (0 = instant)

# Custom Conditions (highly configurable)
@export var custom_conditions: Dictionary = {}  # Custom condition checks (e.g., {"nearby_material": "fire", "distance": 5})
@export var custom_effects: Dictionary = {}  # Custom effects (e.g., {"spawn_particle": "smoke", "play_sound": "sizzle"})

# Reaction State (Runtime)
var contact_time: float = 0.0  # Time materials have been in contact
var reaction_progress: float = 0.0  # 0.0 to 1.0 (for gradual reactions)
```

---

## Core Classes

### PixelPhysicsManager

```gdscript
class_name PixelPhysicsManager
extends Node

# Grid
@export var grid: PixelGrid
@export var world_size: Vector2i = Vector2i(1000, 1000)
@export var cell_size: float = 1.0

# Performance
@export var max_updates_per_frame: int = 1000
@export var update_radius: float = 500.0  # Only update cells within radius
@export var use_multithreading: bool = true

# Materials
var material_registry: MaterialRegistry

# Rendering
var pixel_renderer: PixelRenderer

# Functions
func _ready() -> void
func _process(delta: float) -> void
func initialize_grid(size: Vector2i) -> void
func update_physics(delta: float) -> void
func apply_destruction(world_pos: Vector2, radius: float, force: float) -> void
func add_material(world_pos: Vector2, material: PixelMaterial) -> void
func remove_material(world_pos: Vector2) -> void
func get_material_at(world_pos: Vector2) -> PixelMaterial
func update_chunks_around_position(pos: Vector2) -> void
```

### MaterialRegistry

```gdscript
class_name MaterialRegistry
extends Resource

var materials: Dictionary = {}  # material_id -> PixelMaterial
var reactions: Dictionary = {}  # "material1_id,material2_id" -> ChemicalReaction
var reactions_by_material: Dictionary = {}  # material_id -> Array[ChemicalReaction]

func register_material(material: PixelMaterial) -> void
func get_material(id: int) -> PixelMaterial
func get_material_by_name(name: String) -> PixelMaterial
func create_default_materials() -> void

# Reaction Management (highly configurable)
func register_reaction(reaction: ChemicalReaction) -> void
func get_reaction(material1_id: String, material2_id: String) -> ChemicalReaction
func get_reactions_for_material(material_id: String) -> Array[ChemicalReaction]
func has_reaction(material1_id: String, material2_id: String) -> bool
func load_reactions() -> void  # Load from resources/reactions/
```

### PixelRenderer

```gdscript
class_name PixelRenderer
extends Node2D

var grid: PixelGrid
var texture: ImageTexture
var image: Image
var needs_update: bool = true

func _ready() -> void
func _process(delta: float) -> void
func update_texture() -> void
func render_chunk(chunk_key: Vector2i) -> void
func mark_dirty(pos: Vector2i) -> void
```

---

## System Architecture

### Component Hierarchy

```
PixelPhysicsManager (Node)
├── PixelGrid (RefCounted)
│   ├── ChunkData[] (Dictionary)
│   └── PixelCell[] (Dictionary)
├── MaterialRegistry (Resource)
│   └── PixelMaterial[] (Dictionary)
├── PixelRenderer (Node2D)
│   └── ImageTexture
└── PhysicsUpdater (Node)
    └── ThreadPool (for multithreading)
```

### Data Flow

1. **Initialization:**
   ```
   PixelPhysicsManager._ready()
   ├── Create PixelGrid
   ├── Initialize MaterialRegistry
   ├── Create default materials
   ├── Generate initial world
   └── Setup PixelRenderer
   ```

2. **Update Loop:**
   ```
   PixelPhysicsManager._process(delta)
   ├── Get active chunks around player
   ├── For each active chunk:
   │   ├── Update liquid physics
   │   ├── Update powder physics
   │   ├── Update gas physics
   │   ├── Check chemical reactions
   │   └── Update temperatures
   ├── Apply destruction (if any)
   └── Update renderer for dirty chunks
   ```

3. **Destruction:**
   ```
   Player destroys terrain
   ├── PixelPhysicsManager.apply_destruction(pos, radius, force)
   ├── Calculate affected cells
   ├── Remove/damage cells based on material hardness
   ├── Spawn particles/debris
   └── Mark chunks as dirty
   ```

---

## Algorithms

### Liquid Physics (Water Simulation)

```gdscript
func update_liquid_physics(cell: PixelCell, delta: float) -> void:
    if cell.material.material_type != "liquid":
        return
    
    var pos: Vector2i = cell.position
    var below: PixelCell = get_cell_at(Vector2i(pos.x, pos.y + 1))
    
    # Gravity
    if below == null or below.material.material_type == "gas":
        # Fall down
        move_cell(cell, Vector2i(pos.x, pos.y + 1))
    elif below.material.material_type == "liquid" and cell.material.density < below.material.density:
        # Swap with less dense liquid
        swap_cells(cell, below)
    else:
        # Flow sideways
        var left: PixelCell = get_cell_at(Vector2i(pos.x - 1, pos.y))
        var right: PixelCell = get_cell_at(Vector2i(pos.x + 1, pos.y))
        
        if left == null or (left.material.material_type == "gas"):
            move_cell(cell, Vector2i(pos.x - 1, pos.y))
        elif right == null or (right.material.material_type == "gas"):
            move_cell(cell, Vector2i(pos.x + 1, pos.y))
        else:
            # Pressure calculation
            var pressure_diff: float = calculate_pressure_difference(cell, left, right)
            if abs(pressure_diff) > 0.1:
                var flow_direction: int = 1 if pressure_diff > 0 else -1
                var target_pos: Vector2i = Vector2i(pos.x + flow_direction, pos.y)
                var target: PixelCell = get_cell_at(target_pos)
                if target == null or target.material.material_type == "gas":
                    move_cell(cell, target_pos)
```

### Powder Physics (Sand Simulation)

```gdscript
func update_powder_physics(cell: PixelCell, delta: float) -> void:
    if cell.material.material_type != "powder":
        return
    
    var pos: Vector2i = cell.position
    var below: PixelCell = get_cell_at(Vector2i(pos.x, pos.y + 1))
    
    # Fall down
    if below == null or below.material.material_type == "gas" or below.material.material_type == "liquid":
        move_cell(cell, Vector2i(pos.x, pos.y + 1))
    else:
        # Check diagonal fall
        var left_below: PixelCell = get_cell_at(Vector2i(pos.x - 1, pos.y + 1))
        var right_below: PixelCell = get_cell_at(Vector2i(pos.x + 1, pos.y + 1))
        
        var fall_direction: int = 0
        if left_below == null or left_below.material.material_type == "gas":
            fall_direction = -1
        elif right_below == null or right_below.material.material_type == "gas":
            fall_direction = 1
        
        if fall_direction != 0:
            move_cell(cell, Vector2i(pos.x + fall_direction, pos.y + 1))
```

### Destruction Algorithm

```gdscript
func apply_destruction(world_pos: Vector2, radius: float, force: float) -> void:
    var grid_pos: Vector2i = world_to_grid(world_pos)
    var radius_cells: int = int(radius / cell_size)
    
    for x in range(grid_pos.x - radius_cells, grid_pos.x + radius_cells + 1):
        for y in range(grid_pos.y - radius_cells, grid_pos.y + radius_cells + 1):
            var check_pos: Vector2i = Vector2i(x, y)
            var distance: float = grid_pos.distance_to(check_pos) * cell_size
            
            if distance <= radius:
                var cell: PixelCell = grid.get_cell_at(check_pos)
                if cell != null:
                    # Calculate destruction based on distance and material hardness
                    var destruction_factor: float = 1.0 - (distance / radius)
                    var destruction_chance: float = (force * destruction_factor) / cell.material.hardness
                    
                    if randf() < destruction_chance:
                        # Remove cell
                        grid.remove_cell_at(check_pos)
                        
                        # Spawn particles
                        spawn_destruction_particles(check_pos, cell.material)
                        
                        # Mark chunk as dirty
                        var chunk_key: Vector2i = grid.get_chunk_key(check_pos)
                        mark_chunk_dirty(chunk_key)
```

### Chemical Reactions

```gdscript
func check_chemical_reactions(cell: PixelCell, delta: float) -> void:
    var neighbors: Array[PixelCell] = grid.get_neighbors(cell.position)
    
    for neighbor in neighbors:
        # Check both directions (material1+material2 and material2+material1)
        var reaction: ChemicalReaction = material_registry.get_reaction(
            cell.material.material_id,
            neighbor.material.material_id
        )
        
        if reaction == null:
            # Try reverse order
            reaction = material_registry.get_reaction(
                neighbor.material.material_id,
                cell.material.material_id
            )
        
        if reaction != null:
            # Update contact time for gradual reactions
            if reaction.requires_contact_time > 0.0:
                reaction.contact_time += delta
                if reaction.contact_time < reaction.requires_contact_time:
                    continue  # Not enough contact time yet
            
            # Check reaction conditions (highly configurable)
            if check_reaction_conditions(reaction, cell, neighbor):
                execute_reaction(reaction, cell, neighbor, delta)

func check_reaction_conditions(reaction: ChemicalReaction, cell1: PixelCell, cell2: PixelCell) -> bool:
    # Temperature check
    var avg_temp = (cell1.temperature + cell2.temperature) / 2.0
    if avg_temp < reaction.min_temperature or avg_temp > reaction.max_temperature:
        return false
    
    # Pressure check
    var avg_pressure = (cell1.pressure + cell2.pressure) / 2.0
    if avg_pressure < reaction.min_pressure or avg_pressure > reaction.max_pressure:
        return false
    
    # Catalyst check
    if reaction.requires_catalyst:
        var has_catalyst = check_catalyst_present(cell1.position, reaction.catalyst_material_id)
        if not has_catalyst:
            return false
    
    # Custom conditions check (highly configurable)
    for condition_key in reaction.custom_conditions:
        if not check_custom_condition(condition_key, reaction.custom_conditions[condition_key], cell1, cell2):
            return false
    
    return true

func execute_reaction(reaction: ChemicalReaction, cell1: PixelCell, cell2: PixelCell, delta: float) -> void:
    # Calculate reaction progress (for gradual reactions)
    var progress_delta = reaction.reaction_rate * delta
    if reaction.rate_temperature_factor > 0.0:
        var temp_factor = (cell1.temperature + cell2.temperature) / 2.0 * reaction.rate_temperature_factor
        progress_delta *= (1.0 + temp_factor)
    if reaction.rate_pressure_factor > 0.0:
        var pressure_factor = (cell1.pressure + cell2.pressure) / 2.0 * reaction.rate_pressure_factor
        progress_delta *= (1.0 + pressure_factor)
    
    reaction.reaction_progress += progress_delta
    
    if reaction.reaction_progress < 1.0:
        return  # Reaction not complete yet
    
    # Apply results (highly configurable)
    if not reaction.result_material_id.is_empty():
        var result_material = material_registry.get_material_by_name(reaction.result_material_id)
        if result_material:
            if reaction.consume_first:
                cell1.material = result_material
            if reaction.consume_second:
                cell2.material = result_material
    
    # Multi-product reactions
    if not reaction.result_quantities.is_empty():
        for material_id in reaction.result_quantities:
            var quantity = reaction.result_quantities[material_id]
            spawn_material(cell1.position, material_id, quantity)
    
    # Apply heat effects
    if reaction.heat_produced > 0.0:
        cell1.temperature += reaction.heat_produced
        spread_heat(cell1.position, reaction.heat_produced)
    if reaction.heat_consumed > 0.0:
        cell1.temperature = max(cell1.temperature - reaction.heat_consumed, -273.15)
    
    # Apply pressure effects
    if reaction.pressure_change != 0.0:
        cell1.pressure += reaction.pressure_change
        cell2.pressure += reaction.pressure_change
    
    # Explosion effect
    if reaction.is_explosive:
        create_explosion(cell1.position, reaction.explosion_radius, reaction.explosion_force)
    
    # Gas production
    if reaction.creates_gas and not reaction.gas_material_id.is_empty():
        spawn_material(cell1.position, reaction.gas_material_id, reaction.gas_volume)
    
    # Custom effects (highly configurable)
    for effect_key in reaction.custom_effects:
        execute_custom_effect(effect_key, reaction.custom_effects[effect_key], cell1, cell2)
    
    # Reset reaction progress
    reaction.reaction_progress = 0.0
    reaction.contact_time = 0.0

func check_catalyst_present(position: Vector2i, catalyst_material_id: String) -> bool:
    # Check if catalyst material is present nearby (within 3 cells)
    var neighbors = grid.get_neighbors(position)
    for neighbor in neighbors:
        if neighbor.material.material_id == catalyst_material_id:
            return true
    return false

func check_custom_condition(condition_key: String, condition_value: Variant, cell1: PixelCell, cell2: PixelCell) -> bool:
    # Highly configurable custom condition checking
    match condition_key:
        "nearby_material":
            # Check if specific material is nearby
            var material_id = condition_value.get("material_id", "")
            var distance = condition_value.get("distance", 5)
            return check_nearby_material(cell1.position, material_id, distance)
        "min_temperature_difference":
            # Check if temperature difference meets threshold
            var threshold = float(condition_value)
            return abs(cell1.temperature - cell2.temperature) >= threshold
        "pressure_gradient":
            # Check if pressure gradient meets threshold
            var threshold = float(condition_value)
            return abs(cell1.pressure - cell2.pressure) >= threshold
        "time_of_day":
            # Check time of day (if GameManager available)
            if GameManager:
                var required_time = condition_value.get("time", "")
                return GameManager.get_time_of_day() == required_time
        _:
            push_warning("PixelPhysicsManager: Unknown custom condition: " + condition_key)
            return false
    return false

func execute_custom_effect(effect_key: String, effect_value: Variant, cell1: PixelCell, cell2: PixelCell) -> void:
    # Highly configurable custom effect execution
    match effect_key:
        "spawn_particle":
            # Spawn particle effect
            var particle_type = str(effect_value)
            spawn_particle_effect(cell1.position, particle_type)
        "play_sound":
            # Play sound effect
            var sound_id = str(effect_value)
            if AudioManager:
                AudioManager.play_sound(sound_id, cell1.position)
        "trigger_event":
            # Trigger custom game event
            var event_id = str(effect_value)
            if GameManager:
                GameManager.trigger_event(event_id, {"position": cell1.position})
        "modify_stat":
            # Modify player stat (if player nearby)
            var stat_name = effect_value.get("stat", "")
            var modifier = effect_value.get("value", 0.0)
            if SurvivalManager and is_player_nearby(cell1.position, 5.0):
                SurvivalManager.modify_stat(stat_name, modifier)
        _:
            push_warning("PixelPhysicsManager: Unknown custom effect: " + effect_key)

func spawn_material(position: Vector2i, material_id: String, quantity: float) -> void:
    # Spawn material at position (for multi-product reactions)
    var material = material_registry.get_material_by_name(material_id)
    if not material:
        push_warning("PixelPhysicsManager: Material not found: " + material_id)
        return
    
    # Spawn quantity of material (for gases, create multiple cells)
    var cells_to_spawn = int(ceil(quantity))
    for i in range(cells_to_spawn):
        # Find nearby empty cell or create new cell
        var spawn_pos = find_nearby_empty_cell(position, i * 2)
        if spawn_pos != Vector2i(-1, -1):
            var cell = PixelCell.new()
            cell.material = material
            cell.position = spawn_pos
            cell.temperature = 20.0
            cell.pressure = 1.0
            grid.set_cell_at(spawn_pos, cell)

func spread_heat(position: Vector2i, heat_amount: float) -> void:
    # Spread heat to neighboring cells
    var neighbors = grid.get_neighbors(position)
    var heat_per_neighbor = heat_amount / max(neighbors.size(), 1.0)
    
    for neighbor in neighbors:
        neighbor.temperature += heat_per_neighbor * 0.5  # 50% of heat spreads
        # Clamp temperature to reasonable range
        neighbor.temperature = clamp(neighbor.temperature, -273.15, 10000.0)

func create_explosion(position: Vector2i, radius: float, force: float) -> void:
    # Create explosion effect (destruction + force)
    var world_pos = Vector2(grid_to_world(position))
    apply_destruction(world_pos, radius, force)
    
    # Apply force to nearby cells
    var cells_in_radius = grid.get_cells_in_radius(position, radius)
    for cell in cells_in_radius:
        var direction = (Vector2(cell.position) - Vector2(position)).normalized()
        var distance = Vector2(cell.position).distance_to(Vector2(position))
        var force_at_distance = force * (1.0 - (distance / radius))  # Force decreases with distance
        cell.velocity += direction * force_at_distance

func check_nearby_material(position: Vector2i, material_id: String, distance: int) -> bool:
    # Check if material exists within distance
    for y in range(position.y - distance, position.y + distance + 1):
        for x in range(position.x - distance, position.x + distance + 1):
            var check_pos = Vector2i(x, y)
            var cell = grid.get_cell_at(check_pos)
            if cell and cell.material.material_id == material_id:
                return true
    return false

func find_nearby_empty_cell(position: Vector2i, offset: int) -> Vector2i:
    # Find nearby empty cell for material spawning
    for radius in range(offset, offset + 10):
        for y in range(position.y - radius, position.y + radius + 1):
            for x in range(position.x - radius, position.x + radius + 1):
                var check_pos = Vector2i(x, y)
                var cell = grid.get_cell_at(check_pos)
                if cell == null or cell.material == null:
                    return check_pos
    return Vector2i(-1, -1)

func is_player_nearby(position: Vector2i, distance: float) -> bool:
    # Check if player is nearby
    if player:
        var player_pos = world_to_grid(player.global_position)
        return Vector2(position).distance_to(Vector2(player_pos)) <= distance
    return false

func spawn_particle_effect(position: Vector2i, particle_type: String) -> void:
    # Spawn particle effect (if particle system available)
    # This would integrate with a particle system
    push_print("PixelPhysicsManager: Spawn particle effect: " + particle_type + " at " + str(position))
```

---

## Material Definitions

### Default Materials

```gdscript
func create_default_materials() -> void:
    # Solids
    register_material(create_material("dirt", "solid", 1.5, Color(0.4, 0.3, 0.2), 0.5))
    register_material(create_material("stone", "solid", 2.5, Color(0.5, 0.5, 0.5), 2.0))
    register_material(create_material("metal", "solid", 7.8, Color(0.7, 0.7, 0.8), 5.0))
    
    # Liquids
    register_material(create_material("water", "liquid", 1.0, Color(0.2, 0.4, 0.8), 0.0, 1.0))
    register_material(create_material("lava", "liquid", 3.0, Color(0.8, 0.2, 0.1), 0.0, 0.5, 1000.0))
    register_material(create_material("oil", "liquid", 0.9, Color(0.2, 0.2, 0.1), 0.0, 0.8, true))
    
    # Powders
    register_material(create_material("sand", "powder", 1.6, Color(0.9, 0.8, 0.6), 0.0))
    register_material(create_material("snow", "powder", 0.5, Color(0.95, 0.95, 1.0), 0.0))
    
    # Gases
    register_material(create_material("air", "gas", 0.001, Color(0.5, 0.7, 1.0, 0.1), 0.0))
    register_material(create_material("steam", "gas", 0.0006, Color(0.9, 0.9, 0.9, 0.3), 0.0))
```

---

## Performance Optimization

### Chunking System

```gdscript
func update_chunks_around_position(pos: Vector2) -> void:
    var grid_pos: Vector2i = world_to_grid(pos)
    var center_chunk: Vector2i = grid.get_chunk_key(grid_pos)
    var load_radius: int = 2  # Load 2 chunks in each direction
    
    # Unload distant chunks
    for chunk_key in chunks.keys():
        var distance: float = center_chunk.distance_to(chunk_key)
        if distance > load_radius + 1:
            unload_chunk(chunk_key)
    
    # Load nearby chunks
    for x in range(center_chunk.x - load_radius, center_chunk.x + load_radius + 1):
        for y in range(center_chunk.y - load_radius, center_chunk.y + load_radius + 1):
            var chunk_key: Vector2i = Vector2i(x, y)
            if not chunks.has(chunk_key):
                load_chunk(chunk_key)
```

### Spatial Partitioning

```gdscript
func get_active_cells_in_radius(center: Vector2, radius: float) -> Array[PixelCell]:
    var active: Array[PixelCell] = []
    var grid_center: Vector2i = world_to_grid(center)
    var radius_cells: int = int(radius / cell_size)
    
    for x in range(grid_center.x - radius_cells, grid_center.x + radius_cells + 1):
        for y in range(grid_center.y - radius_cells, grid_center.y + radius_cells + 1):
            var pos: Vector2i = Vector2i(x, y)
            var cell: PixelCell = grid.get_cell_at(pos)
            if cell != null and cell.is_active:
                var distance: float = grid_center.distance_to(pos) * cell_size
                if distance <= radius:
                    active.append(cell)
    
    return active
```

### Multithreading

```gdscript
func update_physics_multithreaded(delta: float) -> void:
    var chunks_to_update: Array = get_active_chunks()
    var chunk_count: int = chunks_to_update.size()
    var threads_per_chunk: int = max(1, chunk_count / 4)  # Use 4 threads
    
    # Divide chunks among threads
    var thread_chunks: Array[Array] = []
    for i in range(4):
        thread_chunks.append([])
    
    for i in range(chunk_count):
        thread_chunks[i % 4].append(chunks_to_update[i])
    
    # Update chunks in parallel
    # (Implementation depends on Godot's threading API)
```

---

## Integration Points

### With World System

```gdscript
# World queries pixel grid for collision
func check_collision(world_pos: Vector2) -> bool:
    var grid_pos: Vector2i = world_to_grid(world_pos)
    var cell: PixelCell = pixel_physics_manager.grid.get_cell_at(grid_pos)
    return cell != null and cell.material.material_type == "solid"
```

### With Rendering System

```gdscript
# Renderer gets pixel data
func get_pixel_data_for_chunk(chunk_key: Vector2i) -> Image:
    var chunk: ChunkData = grid.chunks[chunk_key]
    var image: Image = Image.create(chunk_size.x, chunk_size.y, false, Image.FORMAT_RGBA8)
    
    for local_pos in chunk.cells:
        var cell: PixelCell = chunk.cells[local_pos]
        var world_pos: Vector2i = chunk_key * chunk_size + local_pos
        image.set_pixelv(local_pos, cell.material.color)
    
    return image
```

---

## Save/Load System

### Save Data Structure

```gdscript
var physics_save_data: Dictionary = {
    "grid_size": grid.grid_size,
    "cell_size": grid.cell_size,
    "chunks": serialize_chunks(),
    "materials": serialize_materials()
}

func serialize_chunks() -> Dictionary:
    var serialized: Dictionary = {}
    for chunk_key in grid.chunks:
        var chunk: ChunkData = grid.chunks[chunk_key]
        serialized[chunk_key] = {
            "cells": serialize_chunk_cells(chunk)
        }
    return serialized
```

---

## Testing Checklist

- [ ] Materials register correctly
- [ ] Grid initialization works
- [ ] Liquid physics flows correctly
- [ ] Powder physics falls correctly
- [ ] Destruction removes cells correctly
- [ ] Chemical reactions trigger correctly
- [ ] Chunk loading/unloading works
- [ ] Performance is acceptable (60+ FPS)
- [ ] Rendering updates correctly
- [ ] Save/load preserves grid state

---

## Error Handling

### PixelPhysicsManager Error Handling

- **Missing Grid References:** Handle missing grid gracefully, create default
- **Invalid Material IDs:** Validate material IDs before operations
- **Out of Bounds Positions:** Validate positions before grid operations
- **Chunk Loading Errors:** Handle chunk loading failures gracefully

### Best Practices

- Use `push_error()` for critical errors (missing grid, invalid materials)
- Use `push_warning()` for non-critical issues (out of bounds, chunk errors)
- Return null/false on errors (don't crash)
- Validate all data before operations
- Handle missing system references gracefully

---

## Default Values and Configuration

### PixelPhysicsManager Defaults

```gdscript
world_size = Vector2i(1000, 1000)
cell_size = 1.0
max_updates_per_frame = 1000
update_radius = 500.0
use_multithreading = true
```

### PixelGrid Defaults

```gdscript
grid_size = Vector2i(1000, 1000)
cell_size = 1.0
chunk_size = Vector2i(64, 64)
cells = {}
active_cells = []
material_registry = {}
chunks = {}
```

### PixelMaterial Defaults

```gdscript
material_id = 0
material_name = ""
material_type = "solid"
density = 1.0
friction = 0.5
restitution = 0.0
viscosity = 0.0
flow_rate = 1.0
color = Color.WHITE
is_flammable = false
burn_rate = 0.0
melting_point = -1.0
freezing_point = -1.0
hardness = 1.0
conductivity = 0.0
```

### PixelCell Defaults

```gdscript
material = null
position = Vector2i.ZERO
velocity = Vector2.ZERO
temperature = 20.0
pressure = 1.0
state = "solid"
lifetime = -1.0
age = 0.0
is_active = true
neighbors = []
```

---

## Complete Implementation

### PixelPhysicsManager Complete Implementation

```gdscript
class_name PixelPhysicsManager
extends Node

# Grid
var grid: PixelGrid = PixelGrid.new()
var world_size: Vector2i = Vector2i(1000, 1000)
var cell_size: float = 1.0

# Performance
var max_updates_per_frame: int = 1000
var update_radius: float = 500.0
var use_multithreading: bool = true

# Materials
var material_registry: MaterialRegistry = MaterialRegistry.new()

# Rendering
var pixel_renderer: PixelRenderer = null

# Player Reference
var player: Node2D = null

func _ready() -> void:
    # Find player
    player = get_tree().get_first_node_in_group("player")
    
    # Initialize grid
    initialize_grid(world_size)
    
    # Create default materials
    material_registry.create_default_materials()
    
    # Setup renderer
    pixel_renderer = PixelRenderer.new()
    pixel_renderer.grid = grid
    add_child(pixel_renderer)

func _process(delta: float) -> void:
    # Update physics
    update_physics(delta)
    
    # Update chunks around player
    if player:
        update_chunks_around_position(player.global_position)

func initialize_grid(size: Vector2i) -> void:
    grid.grid_size = size
    grid.cell_size = cell_size
    grid.chunk_size = Vector2i(64, 64)
    grid.material_registry = material_registry

func update_physics(delta: float) -> void:
    if use_multithreading:
        update_physics_multithreaded(delta)
    else:
        grid.update_physics(delta)
    
    # Update renderer
    if pixel_renderer:
        pixel_renderer.update_texture()

func apply_destruction(world_pos: Vector2, radius: float, force: float) -> void:
    var grid_pos = world_to_grid(world_pos)
    grid.apply_destruction(grid_pos, radius, force)
    
    # Mark renderer dirty
    if pixel_renderer:
        pixel_renderer.mark_dirty(grid_pos)

func add_material(world_pos: Vector2, material: PixelMaterial) -> void:
    var grid_pos = world_to_grid(world_pos)
    grid.set_cell_at(grid_pos, material)
    
    # Mark renderer dirty
    if pixel_renderer:
        pixel_renderer.mark_dirty(grid_pos)

func remove_material(world_pos: Vector2) -> void:
    var grid_pos = world_to_grid(world_pos)
    grid.remove_cell_at(grid_pos)
    
    # Mark renderer dirty
    if pixel_renderer:
        pixel_renderer.mark_dirty(grid_pos)

func get_material_at(world_pos: Vector2) -> PixelMaterial:
    var grid_pos = world_to_grid(world_pos)
    var cell = grid.get_cell_at(grid_pos)
    if cell:
        return cell.material
    return null

func update_chunks_around_position(pos: Vector2) -> void:
    var grid_pos = world_to_grid(pos)
    var center_chunk = grid.get_chunk_key(grid_pos)
    var load_radius = 2
    
    # Unload distant chunks
    for chunk_key in grid.chunks.keys():
        var distance = center_chunk.distance_to(chunk_key)
        if distance > load_radius + 1:
            grid.unload_chunk(chunk_key)
    
    # Load nearby chunks
    for x in range(center_chunk.x - load_radius, center_chunk.x + load_radius + 1):
        for y in range(center_chunk.y - load_radius, center_chunk.y + load_radius + 1):
            var chunk_key = Vector2i(x, y)
            if not grid.chunks.has(chunk_key):
                grid.load_chunk(chunk_key)

func world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(int(world_pos.x / cell_size), int(world_pos.y / cell_size))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(grid_pos.x * cell_size, grid_pos.y * cell_size)

func update_physics_multithreaded(delta: float) -> void:
    # Simplified: update in batches
    var active_chunks = get_active_chunks()
    var chunk_count = active_chunks.size()
    var chunks_per_batch = max(1, chunk_count / 4)
    
    var batch_start = 0
    while batch_start < chunk_count:
        var batch_end = min(batch_start + chunks_per_batch, chunk_count)
        for i in range(batch_start, batch_end):
            var chunk_key = active_chunks[i]
            update_chunk_physics(chunk_key, delta)
        batch_start = batch_end

func get_active_chunks() -> Array:
    var active: Array = []
    if player:
        var player_chunk = grid.get_chunk_key(world_to_grid(player.global_position))
        var load_radius = 2
        
        for x in range(player_chunk.x - load_radius, player_chunk.x + load_radius + 1):
            for y in range(player_chunk.y - load_radius, player_chunk.y + load_radius + 1):
                var chunk_key = Vector2i(x, y)
                if grid.chunks.has(chunk_key):
                    active.append(chunk_key)
    
    return active

func update_chunk_physics(chunk_key: Vector2i, delta: float) -> void:
    var chunk = grid.chunks.get(chunk_key)
    if not chunk:
        return
    
    for cell_pos in chunk.cells:
        var cell = chunk.cells[cell_pos]
        if cell and cell.is_active:
            update_cell_physics(cell, delta)

func update_cell_physics(cell: PixelCell, delta: float) -> void:
    # Update based on material type
    match cell.material.material_type:
        "liquid":
            update_liquid_physics(cell, delta)
        "powder":
            update_powder_physics(cell, delta)
        "gas":
            update_gas_physics(cell, delta)
        _:
            pass  # Solids don't move
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── PixelPhysicsManager.gd
   └── scripts/
       └── pixel_physics/
           ├── PixelGrid.gd
           ├── PixelCell.gd
           ├── PixelMaterial.gd
           ├── MaterialRegistry.gd
           └── PixelRenderer.gd
   └── resources/
       └── materials/
           ├── water.tres
           ├── sand.tres
           └── stone.tres
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/PixelPhysicsManager.gd` as `PixelPhysicsManager`
   - **Important:** Load after WorldGenerator

3. **Create Material Resources:**
   - Create PixelMaterial resources for each material type
   - Configure material properties (density, friction, viscosity, etc.)
   - Save as `.tres` files in `res://resources/materials/`

### Initialization Order

**Autoload Order:**
1. GameManager
2. WorldGenerator
3. **PixelPhysicsManager** (after world generation)
4. BuildingManager, CombatManager (use pixel physics)

### System Integration

**Systems Must Call PixelPhysicsManager:**
```gdscript
# Example: Apply destruction
PixelPhysicsManager.apply_destruction(explosion_position, explosion_radius, explosion_force)

# Example: Add material
var water_material = MaterialRegistry.get_material_by_name("water")
PixelPhysicsManager.add_material(water_position, water_material)

# Example: Remove material
PixelPhysicsManager.remove_material(dig_position)
```

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Pixel Physics System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations
- [Multithreading](https://docs.godotengine.org/en/stable/tutorials/threads/index.html) - Threading support
- [Image and ImageTexture](https://docs.godotengine.org/en/stable/classes/class_image.html) - Pixel rendering

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Pixel Physics System. All links are to official Godot 4 documentation or relevant resources.

### Core Systems Documentation

- [Performance Optimization Tutorial](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations
- [Threading Tutorial](https://docs.godotengine.org/en/stable/tutorials/threads/index.html) - Multithreading support
- [Image Documentation](https://docs.godotengine.org/en/stable/classes/class_image.html) - Pixel rendering

### Inspiration

- [Noita](https://noitagame.com/) - Pixel physics inspiration

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines

---

## Editor Support

**Editor-Friendly Design:**
- PixelMaterial is a Resource (can be created/edited in inspector)
- MaterialRegistry is a Resource (can be configured in inspector)
- Material properties editable via @export variables

**Visual Configuration:**
- Material properties editable in inspector
- Material registry viewable in inspector
- Grid settings configurable in inspector

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Material editor with visual preview
  - Grid visualizer
  - Physics simulator

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Materials created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

