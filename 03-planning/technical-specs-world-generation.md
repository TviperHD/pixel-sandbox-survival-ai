# Technical Specifications: World Generation

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for procedural world generation including terrain, biomes, structures, resources, and chunk-based loading. This system integrates with PixelPhysicsManager, BuildingManager, ResourceGatheringManager, NPCManager, and MinimapManager for world generation and management.

---

## Research Notes

### World Generation System Architecture Best Practices

**Research Findings:**
- Procedural generation uses noise functions (Perlin, Simplex)
- Chunk-based loading essential for large worlds
- Biome system organizes terrain types
- Structure placement uses noise-based probability
- Resource distribution uses biome-based spawning

**Sources:**
- [Godot 4 FastNoiseLite](https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html) - Noise generation
- [Procedural Generation](https://en.wikipedia.org/wiki/Procedural_generation) - General principles
- [Terraria World Generation](https://terraria.fandom.com/wiki/World_Generation) - Inspiration
- General procedural generation patterns

**Implementation Approach:**
- WorldGenerator as autoload singleton
- FastNoiseLite for noise generation
- Chunk-based world storage
- Biome registry for biome definitions
- Structure templates for structure placement
- ChunkManager for dynamic loading/unloading

**Why This Approach:**
- Singleton: centralized world generation
- FastNoiseLite: efficient noise generation
- Chunk-based: handles large worlds efficiently
- Biome registry: easy biome configuration
- Structure templates: reusable structure definitions
- ChunkManager: efficient memory management

### Noise Generation Best Practices

**Research Findings:**
- Multiple noise layers create varied terrain
- Different noise types for different features
- Noise parameters affect generation quality
- Seed ensures reproducible worlds

**Sources:**
- [FastNoiseLite Documentation](https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html)

**Implementation Approach:**
- Terrain noise for height maps
- Biome noise for biome distribution
- Cave noise for cave generation
- Structure noise for structure placement
- Configurable noise parameters

**Why This Approach:**
- Multiple layers: varied terrain features
- Different types: appropriate noise for each feature
- Configurable: easy to tune generation
- Seed-based: reproducible worlds

### Chunk Management Best Practices

**Research Findings:**
- Chunk loading/unloading based on player position
- Load radius determines active chunks
- Unload distance prevents memory issues
- Chunk generation on-demand

**Sources:**
- General chunking patterns

**Implementation Approach:**
- ChunkManager tracks loaded chunks
- Load radius around player
- Unload distance for cleanup
- On-demand generation

**Why This Approach:**
- Position-based: efficient chunk management
- Load radius: only load visible chunks
- Unload distance: prevent memory issues
- On-demand: generate only when needed

### Biome System Best Practices

**Research Findings:**
- Biomes defined by temperature/humidity
- Biome noise determines distribution
- Each biome has unique properties
- Biome transitions smooth

**Sources:**
- General biome system patterns

**Implementation Approach:**
- BiomeData Resource for biome definitions
- Temperature/humidity ranges
- Biome noise for distribution
- Smooth transitions between biomes

**Why This Approach:**
- Resource: easy to create/edit biomes
- Temperature/humidity: realistic biome distribution
- Noise-based: smooth transitions
- Configurable: easy to add new biomes

---

## Data Structures

### BiomeData

```gdscript
class_name BiomeData
extends Resource

@export var biome_id: String
@export var biome_name: String
@export var temperature_range: Vector2  # min, max
@export var humidity_range: Vector2
@export var base_terrain: String  # "grass", "sand", "snow", etc.
@export var terrain_noise: FastNoiseLite
@export var resource_spawns: Dictionary = {}  # resource_id -> spawn_chance
@export var enemy_spawns: Dictionary = {}  # enemy_id -> spawn_chance
@export var structures: Array[String] = []  # Structure IDs that can spawn
@export var color_palette: Array[Color] = []
```

### ChunkData

```gdscript
class_name ChunkData
extends RefCounted

var chunk_key: Vector2i
var chunk_size: int = 64  # Cells per chunk
var terrain_data: Array[Array] = []  # 2D array of terrain types
var biome_data: Array[Array] = []  # 2D array of biome IDs
var structures: Array[StructureData] = []
var resources: Array[ResourceSpawn] = []
var is_generated: bool = false
var is_loaded: bool = false
```

### StructureTemplate

```gdscript
class_name StructureTemplate
extends Resource

# Identification
@export var structure_id: String
@export var structure_name: String
@export var structure_type: String  # "ruin", "facility", "bunker", etc.

# Spawn Configuration
@export var spawn_chance: float = 0.1  # Probability of spawning (0.0 to 1.0)
@export var min_spawn_distance: float = 100.0  # Minimum distance between structures
@export var max_spawn_distance: float = 1000.0  # Maximum distance from spawn

# Size Configuration
@export var min_size: Vector2i = Vector2i(10, 10)
@export var max_size: Vector2i = Vector2i(50, 50)
@export var use_procedural_size: bool = true  # Randomize size between min/max

# Procedural Generation Configuration
@export var use_procedural_generation: bool = true  # Use procedural generation with template
@export var generation_rules: Dictionary = {}  # Custom generation rules
@export var room_count: int = 1  # Number of rooms (for multi-room structures)
@export var room_size_range: Vector2i = Vector2i(5, 5)  # Min/max room size
@export var corridor_chance: float = 0.5  # Chance of corridors between rooms
@export var wall_material_id: String = "stone"  # Material for walls
@export var floor_material_id: String = "concrete"  # Material for floors

# Template-Based Configuration (if not procedural)
@export var template_layout: Array[Array] = []  # 2D array defining structure layout (0=empty, 1=wall, 2=floor, etc.)
@export var template_size: Vector2i = Vector2i(10, 10)  # Size of template layout

# Loot Configuration
@export var loot_spawns: Array[Dictionary] = []  # [{position: Vector2i, item_id: String, quantity: int}]
@export var loot_spawn_chance: float = 0.3  # Chance of spawning loot
@export var loot_tables: Array[String] = []  # Loot table IDs

# Enemy Configuration
@export var enemy_spawns: Array[Dictionary] = []  # [{position: Vector2i, enemy_id: String}]
@export var enemy_spawn_chance: float = 0.5  # Chance of spawning enemies
@export var enemy_tables: Array[String] = []  # Enemy spawn table IDs

# Placement Requirements
@export var requires_flat_terrain: bool = true  # Must be on flat terrain
@export var min_terrain_height: float = 0.0  # Minimum terrain height
@export var max_terrain_height: float = 1000.0  # Maximum terrain height
@export var allowed_biomes: Array[String] = []  # Biome IDs where structure can spawn (empty = all)
```

### StructureData

```gdscript
class_name StructureData
extends RefCounted

var structure_id: String
var position: Vector2i
var rotation: float = 0.0
var structure_type: String  # "ruin", "facility", "bunker", etc.
var size: Vector2i  # Actual size of structure
var layout: Array[Array] = []  # Generated layout (for procedural structures)
var loot_spawns: Array[Vector2i] = []
var enemy_spawns: Array[Vector2i] = []
var is_procedural: bool = false  # Whether structure was procedurally generated
```

### ResourceSpawn

```gdscript
class_name ResourceSpawn
extends RefCounted

var resource_id: String
var position: Vector2i
var quantity: int = 1
var is_collected: bool = false
```

---

## Core Classes

### WorldGenerator

```gdscript
class_name WorldGenerator
extends Node

# Generation Parameters
@export var world_seed: int = 0
@export var chunk_size: int = 64
@export var world_size_chunks: Vector2i = Vector2i(100, 100)

# Noise Generators
var terrain_noise: FastNoiseLite
var biome_noise: FastNoiseLite
var cave_noise: FastNoiseLite
var structure_noise: FastNoiseLite

# Biome Registry
var biome_registry: Dictionary = {}  # biome_id -> BiomeData

# Chunk Management
var chunks: Dictionary = {}  # Vector2i -> ChunkData
var loaded_chunks: Array[Vector2i] = []

# Functions
func _ready() -> void
func initialize_generators() -> void
func generate_chunk(chunk_key: Vector2i) -> ChunkData
func generate_terrain(chunk: ChunkData) -> void
func generate_biomes(chunk: ChunkData) -> void
func generate_caves(chunk: ChunkData) -> void
func generate_structures(chunk: ChunkData) -> void
func generate_resources(chunk: ChunkData) -> void
func get_chunk_at_world_position(world_pos: Vector2) -> Vector2i
func load_chunk(chunk_key: Vector2i) -> void
func unload_chunk(chunk_key: Vector2i) -> void
```

### ChunkManager

```gdscript
class_name ChunkManager
extends Node

@export var load_radius: int = 3  # Chunks to load around player
@export var unload_distance: int = 5  # Unload chunks beyond this

var world_generator: WorldGenerator
var player_position: Vector2

func _ready() -> void
func _process(delta: float) -> void
func update_chunks_around_player(pos: Vector2) -> void
func get_chunks_in_radius(center: Vector2i, radius: int) -> Array[Vector2i]
func should_load_chunk(chunk_key: Vector2i, player_chunk: Vector2i) -> bool
func should_unload_chunk(chunk_key: Vector2i, player_chunk: Vector2i) -> bool
```

---

## System Architecture

### Component Hierarchy

```
WorldGenerator (Node)
├── FastNoiseLite[] (Noise generators)
├── BiomeRegistry (Resource)
│   └── BiomeData[] (Dictionary)
├── ChunkManager (Node)
│   └── ChunkData[] (Dictionary)
└── StructureTemplates (Resource)
    └── StructureTemplate[] (Array)
```

### Data Flow

1. **Chunk Generation:**
   ```
   Generate chunk
   ├── WorldGenerator.generate_chunk(chunk_key)
   ├── Generate terrain (height map)
   ├── Generate biomes
   ├── Generate caves
   ├── Generate structures
   ├── Generate resources
   └── Mark as generated
   ```

2. **Chunk Loading:**
   ```
   Player moves
   ├── ChunkManager.update_chunks_around_player(pos)
   ├── Calculate player chunk
   ├── Load chunks in radius
   ├── Unload distant chunks
   └── Generate new chunks if needed
   ```

---

## Algorithms

### Terrain Generation

```gdscript
func generate_terrain(chunk: ChunkData) -> void:
    var world_start: Vector2i = chunk.chunk_key * chunk_size
    
    for x in range(chunk_size):
        for y in range(chunk_size):
            var world_pos: Vector2i = world_start + Vector2i(x, y)
            var noise_value: float = terrain_noise.get_noise_2d(world_pos.x, world_pos.y)
            
            # Convert noise to height
            var height: float = (noise_value + 1.0) * 0.5  # 0.0 to 1.0
            height = height * max_height
            
            # Determine terrain type based on height
            var terrain_type: String = get_terrain_type(height, world_pos)
            chunk.terrain_data[y][x] = terrain_type
```

### Biome Generation

```gdscript
func generate_biomes(chunk: ChunkData) -> void:
    var world_start: Vector2i = chunk.chunk_key * chunk_size
    
    for x in range(chunk_size):
        for y in range(chunk_size):
            var world_pos: Vector2i = world_start + Vector2i(x, y)
            
            # Get biome noise
            var biome_noise_value: float = biome_noise.get_noise_2d(world_pos.x, world_pos.y)
            
            # Get temperature and humidity
            var temperature: float = get_temperature_at(world_pos)
            var humidity: float = get_humidity_at(world_pos)
            
            # Determine biome
            var biome_id: String = determine_biome(biome_noise_value, temperature, humidity)
            chunk.biome_data[y][x] = biome_id
```

### Structure Placement (Procedural Generation with Templates)

```gdscript
func generate_structures(chunk: ChunkData) -> void:
    var biome: BiomeData = get_biome_at_chunk(chunk.chunk_key)
    if biome == null:
        return
    
    for structure_id in biome.structures:
        var structure_template: StructureTemplate = get_structure_template(structure_id)
        if structure_template == null:
            continue
        
        # Check biome compatibility
        if not structure_template.allowed_biomes.is_empty():
            if not biome.biome_id in structure_template.allowed_biomes:
                continue
        
        var spawn_chance: float = structure_template.spawn_chance
        
        # Check spawn chance
        if randf() < spawn_chance:
            # Find valid position
            var position: Vector2i = find_structure_position(chunk, structure_template)
            if position != Vector2i(-1, -1):
                # Create structure using procedural generation with template
                var structure: StructureData = create_structure_from_template(structure_template, position)
                chunk.structures.append(structure)

func create_structure_from_template(template: StructureTemplate, position: Vector2i) -> StructureData:
    var structure = StructureData.new()
    structure.structure_id = template.structure_id
    structure.position = position
    structure.structure_type = template.structure_type
    structure.is_procedural = template.use_procedural_generation
    
    # Determine size
    if template.use_procedural_size:
        var size_x = randi_range(template.min_size.x, template.max_size.x)
        var size_y = randi_range(template.min_size.y, template.max_size.y)
        structure.size = Vector2i(size_x, size_y)
    else:
        structure.size = template.template_size
    
    # Generate structure layout
    if template.use_procedural_generation:
        structure.layout = generate_procedural_layout(template, structure.size)
    else:
        structure.layout = template.template_layout
    
    # Place structure in world
    place_structure_layout(structure, template)
    
    # Generate loot spawns
    generate_structure_loot(structure, template)
    
    # Generate enemy spawns
    generate_structure_enemies(structure, template)
    
    return structure

func generate_procedural_layout(template: StructureTemplate, size: Vector2i) -> Array[Array]:
    var layout: Array[Array] = []
    
    # Initialize layout with walls
    for y in range(size.y):
        var row: Array = []
        for x in range(size.x):
            row.append(1)  # 1 = wall
        layout.append(row)
    
    # Generate rooms
    var rooms: Array[Rect2i] = []
    for i in range(template.room_count):
        var room_size_x = randi_range(template.room_size_range.x, template.room_size_range.y)
        var room_size_y = randi_range(template.room_size_range.x, template.room_size_range.y)
        var room_x = randi_range(1, size.x - room_size_x - 1)
        var room_y = randi_range(1, size.y - room_size_y - 1)
        var room = Rect2i(room_x, room_y, room_size_x, room_size_y)
        rooms.append(room)
        
        # Fill room with floor
        for y in range(room.position.y, room.position.y + room.size.y):
            for x in range(room.position.x, room.position.x + room.size.x):
                layout[y][x] = 2  # 2 = floor
    
    # Connect rooms with corridors (if enabled)
    if template.corridor_chance > 0.0 and rooms.size() > 1:
        for i in range(rooms.size() - 1):
            if randf() < template.corridor_chance:
                connect_rooms(layout, rooms[i], rooms[i + 1])
    
    return layout

func place_structure_layout(structure: StructureData, template: StructureTemplate) -> void:
    # Place structure blocks in world using BuildingManager or PixelPhysicsManager
    for y in range(structure.layout.size()):
        for x in range(structure.layout[y].size()):
            var cell_type = structure.layout[y][x]
            var world_pos = Vector2(structure.position.x + x, structure.position.y + y)
            
            if cell_type == 1:  # Wall
                place_material(world_pos, template.wall_material_id)
            elif cell_type == 2:  # Floor
                place_material(world_pos, template.floor_material_id)
```

### Cave Generation

```gdscript
func generate_caves(chunk: ChunkData) -> void:
    var world_start: Vector2i = chunk.chunk_key * chunk_size
    
    for x in range(chunk_size):
        for y in range(chunk_size):
            var world_pos: Vector2i = world_start + Vector2i(x, y)
            var cave_noise_value: float = cave_noise.get_noise_2d(world_pos.x, world_pos.y)
            
            # Threshold for cave
            if cave_noise_value < -0.3:  # Adjust threshold
                # Create cave (remove terrain)
                chunk.terrain_data[y][x] = "air"
                
                # Spawn cave resources
                if randf() < 0.1:  # 10% chance
                    spawn_cave_resource(chunk, world_pos)
```

---

## Integration Points

### With Pixel Physics

```gdscript
func generate_chunk(chunk: ChunkData) -> void:
    # ... generate terrain ...
    
    # Update pixel physics grid
    for x in range(chunk_size):
        for y in range(chunk_size):
            var world_pos: Vector2 = chunk_to_world_position(chunk.chunk_key, Vector2i(x, y))
            var terrain_type: String = chunk.terrain_data[y][x]
            var material: PixelMaterial = get_material_for_terrain(terrain_type)
            pixel_physics_manager.add_material(world_pos, material)
```

### With Survival System

```gdscript
func get_temperature_at(world_pos: Vector2) -> float:
    var chunk_key: Vector2i = get_chunk_at_world_position(world_pos)
    var chunk: ChunkData = chunks[chunk_key]
    var biome: BiomeData = get_biome_at_position(world_pos)
    return biome.temperature_range.x + (biome.temperature_range.y - biome.temperature_range.x) * 0.5
```

---

## Save/Load System

### Save Data

```gdscript
var world_save_data: Dictionary = {
    "seed": world_seed,
    "generated_chunks": serialize_generated_chunks(),
    "modified_chunks": serialize_modified_chunks()  # Player-modified terrain
}

func serialize_generated_chunks() -> Array:
    var serialized: Array = []
    for chunk_key in chunks:
        if chunks[chunk_key].is_generated:
            serialized.append(chunk_key)
    return serialized
```

---

## Performance Considerations

1. **Chunk Loading:** Load chunks asynchronously
2. **Generation:** Generate chunks in background threads
3. **Caching:** Cache noise values for chunks
4. **LOD:** Use lower detail for distant chunks
5. **Culling:** Only render visible chunks

---

## Testing Checklist

- [ ] Terrain generates correctly
- [ ] Biomes distribute correctly
- [ ] Structures spawn correctly
- [ ] Resources spawn correctly
- [ ] Caves generate correctly
- [ ] Chunk loading/unloading works
- [ ] Performance is acceptable (60+ FPS)
- [ ] Save/load preserves world state
- [ ] Modified terrain persists
- [ ] Seeded generation is consistent

---

## Error Handling

### WorldGenerator Error Handling

- **Missing Biome Data:** Handle missing biome definitions gracefully
- **Invalid Chunk Keys:** Validate chunk keys before operations
- **Noise Generation Errors:** Handle noise generation failures gracefully
- **Structure Placement Errors:** Handle structure placement failures gracefully

### Best Practices

- Use `push_error()` for critical errors (missing biomes, invalid chunks)
- Use `push_warning()` for non-critical issues (structure placement failures)
- Return null/false on errors (don't crash)
- Validate all data before operations
- Handle missing system references gracefully

---

## Default Values and Configuration

### WorldGenerator Defaults

```gdscript
world_seed = 0
chunk_size = 64
world_size_chunks = Vector2i(100, 100)
```

### ChunkManager Defaults

```gdscript
load_radius = 3
unload_distance = 5
```

### BiomeData Defaults

```gdscript
biome_id = ""
biome_name = ""
temperature_range = Vector2(0.0, 1.0)
humidity_range = Vector2(0.0, 1.0)
base_terrain = "grass"
terrain_noise = null
resource_spawns = {}
enemy_spawns = {}
structures = []
color_palette = []
```

### ChunkData Defaults

```gdscript
chunk_key = Vector2i.ZERO
chunk_size = 64
terrain_data = []
biome_data = []
structures = []
resources = []
is_generated = false
is_loaded = false
```

---

## Complete Implementation

### WorldGenerator Complete Implementation

```gdscript
class_name WorldGenerator
extends Node

# Generation Parameters
var world_seed: int = 0
var chunk_size: int = 64
var world_size_chunks: Vector2i = Vector2i(100, 100)

# Noise Generators
var terrain_noise: FastNoiseLite = FastNoiseLite.new()
var biome_noise: FastNoiseLite = FastNoiseLite.new()
var cave_noise: FastNoiseLite = FastNoiseLite.new()
var structure_noise: FastNoiseLite = FastNoiseLite.new()

# Biome Registry
var biome_registry: Dictionary = {}

# Chunk Management
var chunks: Dictionary = {}
var loaded_chunks: Array[Vector2i] = []

# Chunk Manager
var chunk_manager: ChunkManager = null

# Player Reference
var player: Node2D = null

func _ready() -> void:
    # Find player
    player = get_tree().get_first_node_in_group("player")
    
    # Initialize generators
    initialize_generators()
    
    # Load biomes
    load_biomes()
    
    # Create chunk manager
    chunk_manager = ChunkManager.new()
    chunk_manager.world_generator = self
    add_child(chunk_manager)

func initialize_generators() -> void:
    # Setup terrain noise
    terrain_noise.seed = world_seed
    terrain_noise.noise_type = FastNoiseLite.TYPE_PERLIN
    terrain_noise.frequency = 0.01
    
    # Setup biome noise
    biome_noise.seed = world_seed + 1
    biome_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    biome_noise.frequency = 0.005
    
    # Setup cave noise
    cave_noise.seed = world_seed + 2
    cave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
    cave_noise.frequency = 0.02
    
    # Setup structure noise
    structure_noise.seed = world_seed + 3
    structure_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    structure_noise.frequency = 0.001

func load_biomes() -> void:
    var biome_dir = DirAccess.open("res://resources/biomes/")
    if biome_dir:
        biome_dir.list_dir_begin()
        var file_name = biome_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var biome = load("res://resources/biomes/" + file_name) as BiomeData
                if biome:
                    biome_registry[biome.biome_id] = biome
            file_name = biome_dir.get_next()

func generate_chunk(chunk_key: Vector2i) -> ChunkData:
    if chunks.has(chunk_key):
        return chunks[chunk_key]
    
    var chunk = ChunkData.new()
    chunk.chunk_key = chunk_key
    chunk.chunk_size = chunk_size
    
    # Initialize arrays
    chunk.terrain_data = []
    chunk.biome_data = []
    for y in range(chunk_size):
        chunk.terrain_data.append([])
        chunk.biome_data.append([])
        for x in range(chunk_size):
            chunk.terrain_data[y].append("")
            chunk.biome_data[y].append("")
    
    # Generate components
    generate_terrain(chunk)
    generate_biomes(chunk)
    generate_caves(chunk)
    generate_structures(chunk)
    generate_resources(chunk)
    
    chunk.is_generated = true
    chunks[chunk_key] = chunk
    
    return chunk

func generate_terrain(chunk: ChunkData) -> void:
    var world_start = chunk.chunk_key * chunk_size
    
    for x in range(chunk_size):
        for y in range(chunk_size):
            var world_pos = world_start + Vector2i(x, y)
            var noise_value = terrain_noise.get_noise_2d(world_pos.x, world_pos.y)
            
            var height = (noise_value + 1.0) * 0.5
            var terrain_type = get_terrain_type(height, world_pos)
            chunk.terrain_data[y][x] = terrain_type

func generate_biomes(chunk: ChunkData) -> void:
    var world_start = chunk.chunk_key * chunk_size
    
    for x in range(chunk_size):
        for y in range(chunk_size):
            var world_pos = world_start + Vector2i(x, y)
            var biome_noise_value = biome_noise.get_noise_2d(world_pos.x, world_pos.y)
            
            var temperature = get_temperature_at(world_pos)
            var humidity = get_humidity_at(world_pos)
            
            var biome_id = determine_biome(biome_noise_value, temperature, humidity)
            chunk.biome_data[y][x] = biome_id

func generate_caves(chunk: ChunkData) -> void:
    var world_start = chunk.chunk_key * chunk_size
    
    for x in range(chunk_size):
        for y in range(chunk_size):
            var world_pos = world_start + Vector2i(x, y)
            var cave_noise_value = cave_noise.get_noise_2d(world_pos.x, world_pos.y)
            
            if cave_noise_value < -0.3:
                chunk.terrain_data[y][x] = "air"
                if randf() < 0.1:
                    spawn_cave_resource(chunk, world_pos)

func generate_structures(chunk: ChunkData) -> void:
    var biome = get_biome_at_chunk(chunk.chunk_key)
    if not biome:
        return
    
    for structure_id in biome.structures:
        var structure_template = get_structure_template(structure_id)
        if not structure_template:
            continue
        
        # Check biome compatibility
        if not structure_template.allowed_biomes.is_empty():
            if not biome.biome_id in structure_template.allowed_biomes:
                continue
        
        if randf() < structure_template.spawn_chance:
            var position = find_structure_position(chunk, structure_template)
            if position != Vector2i(-1, -1):
                # Use procedural generation with template
                var structure = create_structure_from_template(structure_template, position)
                chunk.structures.append(structure)

func generate_resources(chunk: ChunkData) -> void:
    var biome = get_biome_at_chunk(chunk.chunk_key)
    if not biome:
        return
    
    for resource_id in biome.resource_spawns:
        var spawn_chance = biome.resource_spawns[resource_id]
        if randf() < spawn_chance:
            var position = find_resource_position(chunk)
            if position != Vector2i(-1, -1):
                var resource = ResourceSpawn.new()
                resource.resource_id = resource_id
                resource.position = position
                chunk.resources.append(resource)

func get_chunk_at_world_position(world_pos: Vector2) -> Vector2i:
    return Vector2i(int(world_pos.x / chunk_size), int(world_pos.y / chunk_size))

func load_chunk(chunk_key: Vector2i) -> void:
    if chunks.has(chunk_key):
        chunks[chunk_key].is_loaded = true
        loaded_chunks.append(chunk_key)
    else:
        var chunk = generate_chunk(chunk_key)
        chunk.is_loaded = true
        loaded_chunks.append(chunk_key)

func unload_chunk(chunk_key: Vector2i) -> void:
    if chunks.has(chunk_key):
        chunks[chunk_key].is_loaded = false
        loaded_chunks.erase(chunk_key)

func get_terrain_type(height: float, world_pos: Vector2i) -> String:
    if height < 0.2:
        return "water"
    elif height < 0.4:
        return "sand"
    elif height < 0.7:
        return "grass"
    elif height < 0.9:
        return "stone"
    else:
        return "snow"

func determine_biome(biome_noise: float, temperature: float, humidity: float) -> String:
    # Find matching biome
    for biome_id in biome_registry:
        var biome = biome_registry[biome_id]
        if temperature >= biome.temperature_range.x and temperature <= biome.temperature_range.y:
            if humidity >= biome.humidity_range.x and humidity <= biome.humidity_range.y:
                return biome_id
    
    return "default"

func get_temperature_at(world_pos: Vector2i) -> float:
    # Temperature based on Y position (height)
    return clamp(world_pos.y / 1000.0, 0.0, 1.0)

func get_humidity_at(world_pos: Vector2i) -> float:
    # Humidity based on noise
    return (biome_noise.get_noise_2d(world_pos.x, world_pos.y) + 1.0) * 0.5

func get_biome_at_chunk(chunk_key: Vector2i) -> BiomeData:
    var center_pos = chunk_key * chunk_size + Vector2i(chunk_size / 2, chunk_size / 2)
    var biome_id = determine_biome(
        biome_noise.get_noise_2d(center_pos.x, center_pos.y),
        get_temperature_at(center_pos),
        get_humidity_at(center_pos)
    )
    return biome_registry.get(biome_id)

func get_structure_template(structure_id: String):
    # Load structure template
    var template_path = "res://resources/structures/" + structure_id + ".tres"
    if ResourceLoader.exists(template_path):
        return load(template_path)
    return null

func find_structure_position(chunk: ChunkData, template) -> Vector2i:
    # Find valid position for structure
    for attempt in range(10):
        var x = randi() % chunk_size
        var y = randi() % chunk_size
        var world_start = chunk.chunk_key * chunk_size
        var world_pos = world_start + Vector2i(x, y)
        
        if is_valid_structure_position(world_pos, template):
            return world_pos
    
    return Vector2i(-1, -1)

func is_valid_structure_position(world_pos: Vector2i, template) -> bool:
    # Check if position is valid for structure
    return true  # Implement validation logic

func create_structure_from_template(template: StructureTemplate, position: Vector2i) -> StructureData:
    var structure = StructureData.new()
    structure.structure_id = template.structure_id
    structure.position = position
    structure.structure_type = template.structure_type
    structure.is_procedural = template.use_procedural_generation
    
    # Determine size
    if template.use_procedural_size:
        var size_x = randi_range(template.min_size.x, template.max_size.x)
        var size_y = randi_range(template.min_size.y, template.max_size.y)
        structure.size = Vector2i(size_x, size_y)
    else:
        structure.size = template.template_size
    
    # Generate structure layout
    if template.use_procedural_generation:
        structure.layout = generate_procedural_layout(template, structure.size)
    else:
        structure.layout = template.template_layout
    
    # Place structure in world
    place_structure_layout(structure, template)
    
    # Generate loot spawns
    generate_structure_loot(structure, template)
    
    # Generate enemy spawns
    generate_structure_enemies(structure, template)
    
    return structure

func generate_procedural_layout(template: StructureTemplate, size: Vector2i) -> Array[Array]:
    var layout: Array[Array] = []
    
    # Initialize layout with walls
    for y in range(size.y):
        var row: Array = []
        for x in range(size.x):
            row.append(1)  # 1 = wall
        layout.append(row)
    
    # Generate rooms
    var rooms: Array[Rect2i] = []
    for i in range(template.room_count):
        var room_size_x = randi_range(template.room_size_range.x, template.room_size_range.y)
        var room_size_y = randi_range(template.room_size_range.x, template.room_size_range.y)
        var room_x = randi_range(1, size.x - room_size_x - 1)
        var room_y = randi_range(1, size.y - room_size_y - 1)
        var room = Rect2i(room_x, room_y, room_size_x, room_size_y)
        rooms.append(room)
        
        # Fill room with floor
        for y in range(room.position.y, room.position.y + room.size.y):
            for x in range(room.position.x, room.position.x + room.size.x):
                layout[y][x] = 2  # 2 = floor
    
    # Connect rooms with corridors (if enabled)
    if template.corridor_chance > 0.0 and rooms.size() > 1:
        for i in range(rooms.size() - 1):
            if randf() < template.corridor_chance:
                connect_rooms(layout, rooms[i], rooms[i + 1])
    
    return layout

func place_structure_layout(structure: StructureData, template: StructureTemplate) -> void:
    # Place structure blocks in world using BuildingManager or PixelPhysicsManager
    for y in range(structure.layout.size()):
        for x in range(structure.layout[y].size()):
            var cell_type = structure.layout[y][x]
            var world_pos = Vector2(structure.position.x + x, structure.position.y + y)
            
            if cell_type == 1:  # Wall
                place_material(world_pos, template.wall_material_id)
            elif cell_type == 2:  # Floor
                place_material(world_pos, template.floor_material_id)

func generate_structure_loot(structure: StructureData, template: StructureTemplate) -> void:
    # Generate loot spawns based on template configuration
    if randf() < template.loot_spawn_chance:
        # Use predefined loot spawns or generate procedurally
        for loot_spawn in template.loot_spawns:
            structure.loot_spawns.append(loot_spawn.get("position", Vector2i.ZERO))

func generate_structure_enemies(structure: StructureData, template: StructureTemplate) -> void:
    # Generate enemy spawns based on template configuration
    if randf() < template.enemy_spawn_chance:
        # Use predefined enemy spawns or generate procedurally
        for enemy_spawn in template.enemy_spawns:
            structure.enemy_spawns.append(enemy_spawn.get("position", Vector2i.ZERO))

func connect_rooms(layout: Array[Array], room1: Rect2i, room2: Rect2i) -> void:
    # Connect two rooms with a corridor
    # Find center points of rooms
    var center1 = Vector2i(room1.position.x + room1.size.x / 2, room1.position.y + room1.size.y / 2)
    var center2 = Vector2i(room2.position.x + room2.size.x / 2, room2.position.y + room2.size.y / 2)
    
    # Create L-shaped corridor (horizontal then vertical, or vertical then horizontal)
    var use_horizontal_first = randf() < 0.5
    
    if use_horizontal_first:
        # Horizontal first
        var start_x = min(center1.x, center2.x)
        var end_x = max(center1.x, center2.x)
        var y = center1.y
        
        for x in range(start_x, end_x + 1):
            if x >= 0 and x < layout[0].size() and y >= 0 and y < layout.size():
                layout[y][x] = 2  # Floor
        
        # Then vertical
        var start_y = min(center1.y, center2.y)
        var end_y = max(center1.y, center2.y)
        var x = center2.x
        
        for y in range(start_y, end_y + 1):
            if x >= 0 and x < layout[0].size() and y >= 0 and y < layout.size():
                layout[y][x] = 2  # Floor
    else:
        # Vertical first
        var start_y = min(center1.y, center2.y)
        var end_y = max(center1.y, center2.y)
        var x = center1.x
        
        for y in range(start_y, end_y + 1):
            if x >= 0 and x < layout[0].size() and y >= 0 and y < layout.size():
                layout[y][x] = 2  # Floor
        
        # Then horizontal
        var start_x = min(center1.x, center2.x)
        var end_x = max(center1.x, center2.x)
        var y = center2.y
        
        for x in range(start_x, end_x + 1):
            if x >= 0 and x < layout[0].size() and y >= 0 and y < layout.size():
                layout[y][x] = 2  # Floor

func place_material(world_pos: Vector2, material_id: String) -> void:
    # Place material in world using PixelPhysicsManager or BuildingManager
    if PixelPhysicsManager:
        var material = PixelPhysicsManager.material_registry.get_material_by_name(material_id)
        if material:
            PixelPhysicsManager.add_material(world_pos, material)
    elif BuildingManager:
        # Fallback: use BuildingManager if pixel physics not available
        # This would place a building piece instead
        push_warning("WorldGenerator: PixelPhysicsManager not available, cannot place material: " + material_id)

func find_resource_position(chunk: ChunkData) -> Vector2i:
    # Find valid position for resource
    for attempt in range(20):
        var x = randi() % chunk_size
        var y = randi() % chunk_size
        var world_start = chunk.chunk_key * chunk_size
        var world_pos = world_start + Vector2i(x, y)
        
        if chunk.terrain_data[y][x] != "air":
            return world_pos
    
    return Vector2i(-1, -1)

func spawn_cave_resource(chunk: ChunkData, world_pos: Vector2i) -> void:
    var resource = ResourceSpawn.new()
    resource.resource_id = "cave_ore"
    resource.position = world_pos
    chunk.resources.append(resource)
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── WorldGenerator.gd
   └── scripts/
       └── world/
           └── ChunkManager.gd
   └── resources/
       ├── biomes/
       └── structures/
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/WorldGenerator.gd` as `WorldGenerator`
   - **Important:** Load early (before systems that need world)

3. **Create Biome Resources:**
   - Create BiomeData resources for each biome
   - Configure biome properties (temperature, humidity, terrain, resources)
   - Save as `.tres` files in `res://resources/biomes/`

4. **Create Structure Templates:**
   - Create StructureTemplate resources for each structure
   - Configure structure properties (spawn chance, size, loot)
   - Save as `.tres` files in `res://resources/structures/`

### Initialization Order

**Autoload Order:**
1. GameManager
2. **WorldGenerator** (early, before systems that need world)
3. PixelPhysicsManager, BuildingManager (use world data)

### System Integration

**Systems Must Call WorldGenerator:**
```gdscript
# Example: Get terrain type
var terrain_type = WorldGenerator.get_terrain_type_at(world_position)

# Example: Get biome
var biome = WorldGenerator.get_biome_at(world_position)

# Example: Check if chunk loaded
var chunk_key = WorldGenerator.get_chunk_at_world_position(world_position)
var is_loaded = WorldGenerator.is_chunk_loaded(chunk_key)
```

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing World Generation System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- [FastNoiseLite](https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html) - Noise generation
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing World Generation System. All links are to official Godot 4 documentation or relevant resources.

### Core Systems Documentation

- [FastNoiseLite Documentation](https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html) - Noise generation
- [Performance Optimization Tutorial](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

### Inspiration

- [Terraria World Generation](https://terraria.fandom.com/wiki/World_Generation) - World generation inspiration

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines

---

## Editor Support

**Editor-Friendly Design:**
- BiomeData is a Resource (can be created/edited in inspector)
- StructureTemplate is a Resource (can be created/edited in inspector)
- World generation parameters configurable via @export variables

**Visual Configuration:**
- Biome properties editable in inspector
- Structure template properties editable in inspector
- World generation settings configurable in inspector

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Biome visualizer
  - Structure placement tool
  - World preview tool

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Biomes/structures created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

