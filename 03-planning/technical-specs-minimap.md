# Technical Specifications: Minimap System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the minimap system supporting real-time world updates, fog of war with radius + line of sight exploration, configurable markers, separate minimap (HUD) and full map views, smart batching updates, and exploration data persistence. This system integrates with WorldGenerator, PixelPhysicsManager, BuildingManager, QuestManager, and UIManager for real-time map updates.

---

## Research Notes

### Minimap System Architecture Best Practices

**Research Findings:**
- SubViewport enables rendering minimap separately from main game
- TileMap efficient for terrain rendering
- Fog of war uses separate TileMap layer
- Smart batching reduces update overhead
- Exploration data stored per-chunk for efficiency

**Sources:**
- [Godot 4 SubViewport](https://docs.godotengine.org/en/stable/classes/class_subviewport.html) - Separate viewport rendering
- [Godot 4 TileMap](https://docs.godotengine.org/en/stable/classes/class_tilemap.html) - Tile-based rendering
- [Godot 4 Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html) - Camera for minimap view
- General minimap system design patterns

**Implementation Approach:**
- MinimapManager as autoload singleton
- SubViewport for minimap rendering
- TileMap for terrain and fog layers
- Smart batching for world changes
- Chunk-based exploration data
- Separate minimap (zoom only) and full map (zoom + pan)

**Why This Approach:**
- Singleton: centralized minimap management
- SubViewport: separate rendering context
- TileMap: efficient terrain rendering
- Smart batching: performance optimization
- Chunk-based: efficient exploration storage
- Separate views: different UI needs

### Fog of War Best Practices

**Research Findings:**
- Radius-based exploration reveals tiles around player
- Line of sight adds realistic exploration
- Fog TileMap layer overlays unexplored areas
- Exploration data persists across sessions

**Sources:**
- General fog of war implementation patterns

**Implementation Approach:**
- Base reveal radius around player
- Line of sight checks for obstacles
- Fog TileMap layer for visual overlay
- Exploration data saved per-chunk

**Why This Approach:**
- Radius-based: simple exploration mechanic
- Line of sight: realistic exploration
- Fog layer: clear visual feedback
- Per-chunk: efficient storage

### Real-Time Updates Best Practices

**Research Findings:**
- World changes batched for performance
- High-priority changes update immediately
- Low-priority changes batched every 0.1s
- Smart batching reduces update overhead

**Sources:**
- General update batching patterns

**Implementation Approach:**
- Priority-based update queue
- Immediate updates for high-priority changes
- Batched updates for low-priority changes
- Smart batching merges changes at same position

**Why This Approach:**
- Priority-based: important updates first
- Batching: reduces update overhead
- Smart merging: prevents redundant updates
- Configurable: adjustable batch interval

### Marker System Best Practices

**Research Findings:**
- Markers track important locations
- Marker visibility configurable per type
- Markers visible through fog if configured
- Marker updates batched for performance

**Sources:**
- General marker system patterns

**Implementation Approach:**
- MinimapMarker Resource for marker data
- Marker registry for active markers
- Visibility settings per marker type
- Batched marker updates

**Why This Approach:**
- Resource: easy to create/edit markers
- Registry: efficient marker lookup
- Visibility settings: user control
- Batched updates: performance optimization

---

## Data Structures

### MinimapMarkerType

```gdscript
enum MinimapMarkerType {
    PLAYER,          # Player position (always visible)
    QUEST_WAYPOINT,  # Quest objective waypoint
    NPC,             # NPC location
    STRUCTURE,       # Building/structure
    RESOURCE,        # Resource node
    CONTAINER,       # Storage container
    CUSTOM           # Custom marker
}
```

### MinimapMarker

```gdscript
class_name MinimapMarker
extends Resource

# Identification
@export var marker_id: String  # Unique identifier
@export var marker_type: MinimapMarkerType
@export var marker_name: String  # Display name

# Visual
@export var icon: Texture2D
@export var color: Color = Color.WHITE
@export var size: Vector2 = Vector2(8, 8)

# Position
var world_position: Vector2  # World coordinates
var map_position: Vector2  # Map coordinates (calculated)

# Visibility
@export var visible_in_fog: bool = true  # Visible even in unexplored areas
@export var always_visible: bool = false  # Always visible (like player)
@export var show_on_minimap: bool = true
@export var show_on_full_map: bool = true

# State
var is_active: bool = true
var update_frequency: float = 0.1  # Update every 0.1 seconds
var last_update_time: float = 0.0
```

### ExplorationData

```gdscript
class_name ExplorationData
extends Resource

# Explored tiles (chunk-based)
var explored_chunks: Dictionary = {}  # Vector2i (chunk_key) -> Dictionary (tile data)
var explored_tiles: Dictionary = {}  # Vector2i (tile_pos) -> bool

# Exploration radius
@export var base_reveal_radius: int = 5  # Base tiles revealed
@export var line_of_sight_enabled: bool = true

# Functions
func is_explored(tile_pos: Vector2i) -> bool
func mark_explored(tile_pos: Vector2i) -> void
func mark_chunk_explored(chunk_key: Vector2i) -> void
func get_explored_area() -> Rect2i
```

### MinimapSettings

```gdscript
class_name MinimapSettings
extends Resource

# Size
@export var size_preset: SizePreset = SizePreset.MEDIUM
@export var custom_size: Vector2 = Vector2(200, 200)

enum SizePreset {
    SMALL,   # 150x150
    MEDIUM,  # 200x200
    LARGE    # 300x300
}

# Position (normalized 0.0-1.0)
@export var position: Vector2 = Vector2(0.9, 0.1)  # Top-right default

# Zoom
@export var zoom_level: float = 1.0  # 0.5x to 2.0x
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

# Markers visibility
@export var show_quest_waypoints: bool = true
@export var show_npcs: bool = true
@export var show_structures: bool = true
@export var show_resources: bool = false
@export var show_containers: bool = false

# Fog of war
@export var fog_enabled: bool = true
@export var fog_color: Color = Color(0.1, 0.1, 0.1, 0.8)
```

### WorldChangeEvent

```gdscript
class_name WorldChangeEvent
extends RefCounted

var change_type: ChangeType
var position: Vector2i
var tile_data: Dictionary = {}
var priority: int = 50  # Higher = more important (immediate update)

enum ChangeType {
    BLOCK_PLACED,
    BLOCK_DESTROYED,
    TERRAIN_MODIFIED,
    STRUCTURE_BUILT,
    STRUCTURE_DESTROYED,
    PLAYER_MOVED  # Always immediate
}
```

---

## Core Classes

### MinimapManager (Autoload Singleton)

```gdscript
class_name MinimapManager
extends Node

# References
@export var world_generator: WorldGenerator
@export var pixel_physics_manager: PixelPhysicsManager
@export var building_manager: BuildingManager
@export var quest_manager: QuestManager

# Minimap Scene
var minimap_scene: PackedScene
var minimap_instance: Node2D = null

# SubViewport
var minimap_viewport: SubViewport = null
var minimap_camera: Camera2D = null

# TileMaps
var terrain_tilemap: TileMap = null
var fog_tilemap: TileMap = null

# Exploration
var exploration_data: ExplorationData
var reveal_radius: int = 5

# Markers
var active_markers: Dictionary = {}  # marker_id -> MinimapMarker
var marker_visibility: Dictionary = {}  # marker_type -> bool

# Update Queue
var world_changes: Array[WorldChangeEvent] = []
var batched_changes: Dictionary = {}  # position -> WorldChangeEvent
var update_timer: float = 0.0
var batch_interval: float = 0.1  # Batch minor changes every 0.1s

# Settings
var minimap_settings: MinimapSettings
var full_map_open: bool = false

# Signals
signal minimap_updated()
signal marker_added(marker_id: String, marker: MinimapMarker)
signal marker_removed(marker_id: String)
signal exploration_changed(tile_pos: Vector2i)
signal full_map_opened()
signal full_map_closed()

# Functions
func _ready() -> void
func _process(delta: float) -> void
func initialize_minimap() -> void
func update_minimap(delta: float) -> void
func process_world_changes() -> void
func queue_world_change(change: WorldChangeEvent) -> void
func update_terrain_tilemap() -> void
func update_fog_of_war(player_position: Vector2) -> void
func reveal_area(center: Vector2, radius: int) -> void
func check_line_of_sight(from: Vector2, to: Vector2) -> bool

# Markers
func add_marker(marker: MinimapMarker) -> void
func remove_marker(marker_id: String) -> void
func update_marker_position(marker_id: String, world_position: Vector2) -> void
func set_marker_visibility(marker_type: MinimapMarkerType, visible: bool) -> void
func get_markers_in_area(area: Rect2) -> Array[MinimapMarker]

# Full Map
func open_full_map() -> void
func close_full_map() -> void
func set_full_map_zoom(zoom: float) -> void
func pan_full_map(direction: Vector2) -> void

# Exploration
func mark_explored(position: Vector2) -> void
func is_explored(position: Vector2) -> bool
func get_exploration_data() -> ExplorationData

# Save/Load
func save_exploration_data() -> Dictionary
func load_exploration_data(data: Dictionary) -> void
```

### MinimapUI

```gdscript
class_name MinimapUI
extends Control

# UI Elements
@onready var minimap_texture: TextureRect
@onready var marker_container: Control
@onready var fog_overlay: ColorRect

# Settings
var minimap_settings: MinimapSettings
var minimap_manager: MinimapManager

# Zoom
var current_zoom: float = 1.0
var zoom_speed: float = 0.1

# Functions
func _ready() -> void
func _process(delta: float) -> void
func _input(event: InputEvent) -> void
func update_minimap_display() -> void
func update_markers() -> void
func update_fog_overlay() -> void
func set_size_preset(preset: MinimapSettings.SizePreset) -> void
func set_position(new_position: Vector2) -> void
func zoom_in() -> void
func zoom_out() -> void
func set_zoom(zoom_level: float) -> void
```

### FullMapUI

```gdscript
class_name FullMapUI
extends Control

# UI Elements
@onready var map_texture: TextureRect
@onready var marker_container: Control
@onready var fog_overlay: ColorRect
@onready var zoom_controls: Control
@onready var pan_area: Control

# State
var is_open: bool = false
var current_zoom: float = 1.0
var pan_offset: Vector2 = Vector2.ZERO
var zoom_speed: float = 0.1
var pan_speed: float = 10.0

# References
var minimap_manager: MinimapManager

# Functions
func _ready() -> void
func _process(delta: float) -> void
func _input(event: InputEvent) -> void
func open_map() -> void
func close_map() -> void
func update_map_display() -> void
func update_markers() -> void
func zoom_in() -> void
func zoom_out() -> void
func pan_map(direction: Vector2) -> void
func center_on_player() -> void
func set_zoom(zoom_level: float) -> void
```

---

## System Architecture

### Component Hierarchy

```
MinimapManager (Autoload Singleton)
├── MinimapScene (Node2D)
│   ├── SubViewport
│   │   ├── Camera2D
│   │   ├── TerrainTileMap
│   │   └── FogTileMap
│   └── MarkerContainer
├── MinimapUI (Control - in HUD)
│   ├── TextureRect (viewport texture)
│   ├── MarkerContainer
│   └── FogOverlay
└── FullMapUI (Control - separate screen)
    ├── TextureRect (viewport texture)
    ├── MarkerContainer
    ├── FogOverlay
    └── ZoomControls
```

### Data Flow

1. **World Update:**
   - World changes → `queue_world_change()` called
   - Check priority → Important changes update immediately, minor changes batched
   - Update TileMap → Sync terrain TileMap with world
   - Update Viewport → SubViewport renders updated world

2. **Exploration:**
   - Player moves → `mark_explored()` called
   - Calculate reveal area → Radius + line of sight check
   - Update fog → Remove fog tiles in revealed area
   - Update exploration data → Mark tiles as explored

3. **Marker Updates:**
   - Marker position changes → `update_marker_position()` called
   - Check visibility → Based on marker type and settings
   - Update display → Redraw markers on minimap/full map

4. **Full Map:**
   - Player presses M → `open_full_map()` called
   - Show full map UI → Display entire explored area
   - Allow zoom/pan → Player can navigate full map
   - Close → Return to minimap view

---

## Algorithms

### Reveal Area Algorithm (Radius + Line of Sight)

```gdscript
func reveal_area(center: Vector2, radius: int) -> void:
    var center_tile = world_to_map(center)
    
    # Reveal tiles in radius
    for x in range(-radius, radius + 1):
        for y in range(-radius, radius + 1):
            var tile_pos = center_tile + Vector2i(x, y)
            var world_pos = map_to_world(tile_pos)
            var distance = center.distance_to(world_pos)
            
            # Check if within radius
            if distance > radius:
                continue
            
            # Check line of sight if enabled
            if minimap_settings.line_of_sight_enabled:
                if not check_line_of_sight(center, world_pos):
                    continue
            
            # Mark as explored
            exploration_data.mark_explored(tile_pos)
            
            # Remove fog tile
            fog_tilemap.set_cell(0, tile_pos, -1)  # -1 removes tile
            
            emit_signal("exploration_changed", tile_pos)

func check_line_of_sight(from: Vector2, to: Vector2) -> bool:
    # Raycast from player to tile
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsRayQueryParameters2D.create(from, to)
    query.exclude = [player]  # Exclude player from raycast
    var result = space_state.intersect_ray(query)
    
    # If hit something, line of sight blocked
    return result.is_empty()
```

### Smart Batching Update Algorithm

```gdscript
func queue_world_change(change: WorldChangeEvent) -> void:
    # Check priority
    if change.priority >= 80:  # High priority (player moved, important events)
        # Update immediately
        apply_world_change(change)
    else:
        # Batch for later
        if not batched_changes.has(change.position):
            batched_changes[change.position] = change
        else:
            # Update existing change (keep highest priority)
            var existing = batched_changes[change.position]
            if change.priority > existing.priority:
                batched_changes[change.position] = change

func process_world_changes() -> void:
    # Process batched changes
    if batched_changes.is_empty():
        return
    
    # Apply all batched changes
    for position in batched_changes:
        var change = batched_changes[position]
        apply_world_change(change)
    
    # Clear batch
    batched_changes.clear()
    
    # Update TileMap
    update_terrain_tilemap()

func apply_world_change(change: WorldChangeEvent) -> void:
    match change.change_type:
        WorldChangeEvent.ChangeType.BLOCK_PLACED:
            terrain_tilemap.set_cell(0, change.position, get_tile_id(change.tile_data))
        
        WorldChangeEvent.ChangeType.BLOCK_DESTROYED:
            terrain_tilemap.set_cell(0, change.position, -1)
        
        WorldChangeEvent.ChangeType.TERRAIN_MODIFIED:
            terrain_tilemap.set_cell(0, change.position, get_tile_id(change.tile_data))
        
        _:
            pass
```

### Update Minimap Display Algorithm

```gdscript
func update_minimap_display() -> void:
    if minimap_viewport == null:
        return
    
    # Update camera to follow player
    if player:
        minimap_camera.global_position = player.global_position
        minimap_camera.zoom = Vector2(current_zoom, current_zoom)
    
    # Get viewport texture
    var texture = minimap_viewport.get_texture()
    if texture:
        minimap_texture.texture = texture
    
    # Update markers
    update_markers()
    
    # Update fog overlay
    update_fog_overlay()

func update_markers() -> void:
    # Clear existing marker sprites
    for child in marker_container.get_children():
        child.queue_free()
    
    # Get visible markers
    var visible_markers = get_visible_markers()
    
    # Create marker sprites
    for marker in visible_markers:
        if not should_show_marker(marker):
            continue
        
        var marker_sprite = Sprite2D.new()
        marker_sprite.texture = marker.icon
        marker_sprite.modulate = marker.color
        marker_sprite.scale = marker.size / marker.icon.get_size()
        
        # Convert world position to minimap position
        var map_pos = world_to_minimap_pos(marker.world_position)
        marker_sprite.position = map_pos
        
        marker_container.add_child(marker_sprite)

func should_show_marker(marker: MinimapMarker) -> bool:
    # Check if marker type is visible
    if not marker_visibility.get(marker.marker_type, true):
        return false
    
    # Check if in fog (if not visible in fog)
    if not marker.visible_in_fog:
        if not is_explored(marker.world_position):
            return false
    
    return true
```

---

## Integration Points

### World Generation

**Usage:**
- Minimap syncs with world generation
- Terrain TileMap populated from world data
- Chunk-based exploration tracking

**Example:**
```gdscript
# In WorldGenerator
func on_chunk_generated(chunk_key: Vector2i) -> void:
    # Notify minimap of new chunk
    MinimapManager.on_chunk_generated(chunk_key)
```

### Pixel Physics System

**Usage:**
- World destruction updates minimap
- Terrain changes reflected in real-time

**Example:**
```gdscript
# In PixelPhysicsManager
func destroy_pixel(position: Vector2) -> void:
    # ... destruction logic ...
    
    # Notify minimap
    var change = WorldChangeEvent.new()
    change.change_type = WorldChangeEvent.ChangeType.BLOCK_DESTROYED
    change.position = world_to_map(position)
    change.priority = 60
    MinimapManager.queue_world_change(change)
```

### Building System

**Usage:**
- Building placement/destruction updates minimap
- Structures shown as markers

**Example:**
```gdscript
# In BuildingManager
func place_building(position: Vector2) -> void:
    # ... placement logic ...
    
    # Update minimap
    var change = WorldChangeEvent.new()
    change.change_type = WorldChangeEvent.ChangeType.STRUCTURE_BUILT
    change.position = world_to_map(position)
    change.priority = 70
    MinimapManager.queue_world_change(change)
    
    # Add structure marker
    var marker = MinimapMarker.new()
    marker.marker_id = "structure_" + str(building_id)
    marker.marker_type = MinimapMarkerType.STRUCTURE
    marker.world_position = position
    MinimapManager.add_marker(marker)
```

### Quest System

**Usage:**
- Quest waypoints shown on minimap
- Waypoints visible through fog

**Example:**
```gdscript
# In QuestManager
func add_quest_waypoint(quest_id: String, position: Vector2) -> void:
    var marker = MinimapMarker.new()
    marker.marker_id = "quest_" + quest_id
    marker.marker_type = MinimapMarkerType.QUEST_WAYPOINT
    marker.world_position = position
    marker.visible_in_fog = true  # Always visible
    MinimapManager.add_marker(marker)
```

### Player Controller

**Usage:**
- Player position tracked on minimap
- Exploration updates as player moves

**Example:**
```gdscript
# In PlayerController
func _process(delta: float) -> void:
    # ... movement code ...
    
    # Update minimap exploration
    MinimapManager.mark_explored(global_position)
    
    # Update player marker (handled automatically by MinimapManager)
```

---

## Save/Load System

### Exploration Data Save

**Save Format:**
```gdscript
{
    "exploration_data": {
        "explored_chunks": {
            "0,0": {
                "tiles": [true, true, false, ...],  # Array of explored tiles
                "chunk_key": {"x": 0, "y": 0}
            }
        },
        "base_reveal_radius": 5,
        "line_of_sight_enabled": true
    },
    "minimap_settings": {
        "size_preset": 1,  # MEDIUM
        "position": {"x": 0.9, "y": 0.1},
        "zoom_level": 1.0,
        "show_quest_waypoints": true,
        "show_npcs": true,
        "show_structures": true
    }
}
```

**Load Format:**
```gdscript
func load_exploration_data(data: Dictionary) -> void:
    if data.has("exploration_data"):
        var exp_data = data.exploration_data
        
        # Load explored chunks
        for chunk_key_str in exp_data.explored_chunks:
            var chunk_data = exp_data.explored_chunks[chunk_key_str]
            var chunk_key = parse_chunk_key(chunk_key_str)
            
            # Mark chunk as explored
            exploration_data.mark_chunk_explored(chunk_key)
            
            # Load individual tiles if available
            if chunk_data.has("tiles"):
                var tiles = chunk_data.tiles
                var tile_index = 0
                for y in range(chunk_size):
                    for x in range(chunk_size):
                        if tile_index < tiles.size() and tiles[tile_index]:
                            var tile_pos = chunk_key * chunk_size + Vector2i(x, y)
                            exploration_data.mark_explored(tile_pos)
                        tile_index += 1
        
        # Load settings
        exploration_data.base_reveal_radius = exp_data.get("base_reveal_radius", 5)
        exploration_data.line_of_sight_enabled = exp_data.get("line_of_sight_enabled", true)
    
    # Load minimap settings
    if data.has("minimap_settings"):
        var settings_data = data.minimap_settings
        minimap_settings.size_preset = settings_data.get("size_preset", MinimapSettings.SizePreset.MEDIUM)
        minimap_settings.position = Vector2(settings_data.position.x, settings_data.position.y)
        minimap_settings.zoom_level = settings_data.get("zoom_level", 1.0)
        # ... load other settings
```

---

## Performance Considerations

### Optimization Strategies

1. **Chunk-Based Exploration:**
   - Track exploration by chunks, not individual tiles
   - Reduces memory usage for large worlds

2. **Smart Batching:**
   - Batch minor changes, update important changes immediately
   - Prevents performance spikes

3. **Viewport Optimization:**
   - Limit viewport update frequency
   - Only update when visible

4. **Marker Culling:**
   - Only render markers in visible area
   - Limit marker updates per frame

5. **Fog TileMap Optimization:**
   - Use efficient TileMap operations
   - Batch fog tile removals

6. **Line of Sight Caching:**
   - Cache line of sight results
   - Recalculate only when needed

---

## Testing Checklist

### Minimap Rendering
- [ ] Minimap displays correctly
- [ ] Terrain syncs with world
- [ ] Viewport renders correctly
- [ ] Camera follows player

### Fog of War
- [ ] Fog covers unexplored areas
- [ ] Fog reveals as player explores
- [ ] Radius-based revelation works
- [ ] Line of sight works correctly
- [ ] Fog persists correctly

### World Updates
- [ ] Immediate updates work (high priority)
- [ ] Batched updates work (low priority)
- [ ] Terrain changes reflect on minimap
- [ ] Building changes reflect on minimap
- [ ] Destruction changes reflect on minimap

### Markers
- [ ] Player marker always visible
- [ ] Quest waypoints visible
- [ ] NPC markers work
- [ ] Structure markers work
- [ ] Marker visibility toggles work
- [ ] Markers visible through fog

### Full Map
- [ ] Full map opens/closes correctly
- [ ] Zoom works on full map
- [ ] Pan works on full map
- [ ] Full map shows entire explored area
- [ ] Markers display on full map

### Exploration
- [ ] Exploration data saves correctly
- [ ] Exploration data loads correctly
- [ ] Explored areas persist across sessions
- [ ] Chunk-based exploration works

### Integration
- [ ] Works with world generation
- [ ] Works with pixel physics
- [ ] Works with building system
- [ ] Works with quest system
- [ ] Works with player controller

---

## Error Handling

### MinimapManager Error Handling

- **Missing World References:** Handle missing WorldGenerator/PixelPhysicsManager gracefully
- **Invalid Tile Positions:** Validate tile positions before operations
- **Missing Exploration Data:** Handle missing exploration data gracefully, create default
- **Viewport Creation Errors:** Handle viewport creation failures gracefully

### Best Practices

- Use `push_error()` for critical errors (missing world references, invalid positions)
- Use `push_warning()` for non-critical issues (missing exploration data, viewport issues)
- Return null/false on errors (don't crash)
- Validate all data before operations
- Handle missing system references gracefully

---

## Default Values and Configuration

### MinimapManager Defaults

```gdscript
reveal_radius = 5  # Base tiles revealed
batch_interval = 0.1  # Batch changes every 0.1 seconds
update_timer = 0.0
```

### MinimapSettings Defaults

```gdscript
size_preset = SizePreset.MEDIUM
custom_size = Vector2(200, 200)
position = Vector2(0.9, 0.1)  # Top-right
zoom_level = 1.0
min_zoom = 0.5
max_zoom = 2.0
show_quest_waypoints = true
show_npcs = true
show_structures = true
show_resources = false
show_containers = false
fog_enabled = true
fog_color = Color(0.1, 0.1, 0.1, 0.8)
```

### ExplorationData Defaults

```gdscript
base_reveal_radius = 5
line_of_sight_enabled = true
explored_chunks = {}
explored_tiles = {}
```

### MinimapMarker Defaults

```gdscript
marker_id = ""
marker_type = MinimapMarkerType.CUSTOM
marker_name = ""
icon = null
color = Color.WHITE
size = Vector2(8, 8)
world_position = Vector2.ZERO
map_position = Vector2.ZERO
visible_in_fog = true
always_visible = false
show_on_minimap = true
show_on_full_map = true
is_active = true
update_frequency = 0.1
last_update_time = 0.0
```

---

## Complete Implementation

### MinimapManager Complete Implementation

```gdscript
class_name MinimapManager
extends Node

# References
var world_generator: Node = null
var pixel_physics_manager: Node = null
var building_manager: Node = null
var quest_manager: Node = null

# Minimap Scene
var minimap_scene: PackedScene = null
var minimap_instance: Node2D = null

# SubViewport
var minimap_viewport: SubViewport = null
var minimap_camera: Camera2D = null

# TileMaps
var terrain_tilemap: TileMap = null
var fog_tilemap: TileMap = null

# Exploration
var exploration_data: ExplorationData = ExplorationData.new()
var reveal_radius: int = 5

# Markers
var active_markers: Dictionary = {}
var marker_visibility: Dictionary = {}

# Update Queue
var world_changes: Array[WorldChangeEvent] = []
var batched_changes: Dictionary = {}
var update_timer: float = 0.0
var batch_interval: float = 0.1

# Settings
var minimap_settings: MinimapSettings = MinimapSettings.new()
var full_map_open: bool = false

# Player Reference
var player: Node2D = null

# Signals
signal minimap_updated()
signal marker_added(marker_id: String, marker: MinimapMarker)
signal marker_removed(marker_id: String)
signal exploration_changed(tile_pos: Vector2i)
signal full_map_opened()
signal full_map_closed()

func _ready() -> void:
    # Find managers
    world_generator = get_node_or_null("/root/WorldGenerator")
    pixel_physics_manager = get_node_or_null("/root/PixelPhysicsManager")
    building_manager = get_node_or_null("/root/BuildingManager")
    quest_manager = get_node_or_null("/root/QuestManager")
    
    # Find player
    player = get_tree().get_first_node_in_group("player")
    
    # Initialize minimap
    initialize_minimap()
    
    # Load exploration data
    load_exploration_data()

func _process(delta: float) -> void:
    update_timer += delta
    
    # Process batched changes
    if update_timer >= batch_interval:
        update_timer = 0.0
        process_world_changes()
    
    # Update minimap display
    update_minimap_display()
    
    # Update exploration (if player moved)
    if player:
        update_exploration(player.global_position)

func initialize_minimap() -> void:
    # Create SubViewport
    minimap_viewport = SubViewport.new()
    minimap_viewport.size = Vector2i(1000, 1000)  # Large enough for world
    minimap_viewport.transparent_bg = true
    add_child(minimap_viewport)
    
    # Create minimap scene
    minimap_instance = Node2D.new()
    minimap_viewport.add_child(minimap_instance)
    
    # Create camera
    minimap_camera = Camera2D.new()
    minimap_instance.add_child(minimap_camera)
    
    # Create TileMaps
    terrain_tilemap = TileMap.new()
    minimap_instance.add_child(terrain_tilemap)
    
    fog_tilemap = TileMap.new()
    minimap_instance.add_child(fog_tilemap)
    
    # Setup fog layer
    fog_tilemap.z_index = 10  # Above terrain
    fog_tilemap.modulate = minimap_settings.fog_color

func update_exploration(center: Vector2) -> void:
    reveal_area(center, reveal_radius)

func reveal_area(center: Vector2, radius: int) -> void:
    var center_tile = world_to_map(center)
    
    for x in range(-radius, radius + 1):
        for y in range(-radius, radius + 1):
            var tile_pos = center_tile + Vector2i(x, y)
            var world_pos = map_to_world(tile_pos)
            var distance = center.distance_to(world_pos)
            
            if distance > radius:
                continue
            
            if minimap_settings.line_of_sight_enabled:
                if not check_line_of_sight(center, world_pos):
                    continue
            
            if not exploration_data.is_explored(tile_pos):
                exploration_data.mark_explored(tile_pos)
                fog_tilemap.set_cell(0, tile_pos, -1)
                exploration_changed.emit(tile_pos)

func check_line_of_sight(from: Vector2, to: Vector2) -> bool:
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsRayQueryParameters2D.create(from, to)
    if player:
        query.exclude = [player]
    var result = space_state.intersect_ray(query)
    return result.is_empty()

func queue_world_change(change: WorldChangeEvent) -> void:
    if change.priority >= 80:
        apply_world_change(change)
    else:
        if not batched_changes.has(change.position):
            batched_changes[change.position] = change
        else:
            var existing = batched_changes[change.position]
            if change.priority > existing.priority:
                batched_changes[change.position] = change

func process_world_changes() -> void:
    if batched_changes.is_empty():
        return
    
    for position in batched_changes:
        var change = batched_changes[position]
        apply_world_change(change)
    
    batched_changes.clear()
    update_terrain_tilemap()

func apply_world_change(change: WorldChangeEvent) -> void:
    match change.change_type:
        WorldChangeEvent.ChangeType.BLOCK_PLACED:
            terrain_tilemap.set_cell(0, change.position, get_tile_id(change.tile_data))
        
        WorldChangeEvent.ChangeType.BLOCK_DESTROYED:
            terrain_tilemap.set_cell(0, change.position, -1)
        
        WorldChangeEvent.ChangeType.TERRAIN_MODIFIED:
            terrain_tilemap.set_cell(0, change.position, get_tile_id(change.tile_data))
        
        _:
            pass

func update_terrain_tilemap() -> void:
    # Sync terrain TileMap with world
    if world_generator:
        # Update tiles from world generator
        pass
    
    minimap_updated.emit()

func update_minimap_display() -> void:
    if not player or not minimap_camera:
        return
    
    # Center camera on player
    minimap_camera.global_position = player.global_position
    
    # Update zoom
    minimap_camera.zoom = Vector2(minimap_settings.zoom_level, minimap_settings.zoom_level)

func add_marker(marker: MinimapMarker) -> void:
    active_markers[marker.marker_id] = marker
    marker_added.emit(marker.marker_id, marker)

func remove_marker(marker_id: String) -> void:
    if active_markers.has(marker_id):
        active_markers.erase(marker_id)
        marker_removed.emit(marker_id)

func update_marker_position(marker_id: String, new_position: Vector2) -> void:
    if not active_markers.has(marker_id):
        return
    
    var marker = active_markers[marker_id]
    marker.world_position = new_position
    marker.map_position = world_to_map(new_position)

func world_to_map(world_pos: Vector2) -> Vector2i:
    # Convert world position to tile coordinates
    if terrain_tilemap:
        return terrain_tilemap.local_to_map(world_pos)
    return Vector2i(int(world_pos.x / 16), int(world_pos.y / 16))  # Default tile size 16

func map_to_world(tile_pos: Vector2i) -> Vector2:
    # Convert tile coordinates to world position
    if terrain_tilemap:
        return terrain_tilemap.map_to_local(tile_pos)
    return Vector2(tile_pos.x * 16, tile_pos.y * 16)  # Default tile size 16

func get_tile_id(tile_data: Dictionary) -> int:
    # Get TileMap source ID from tile data
    return tile_data.get("tile_id", 0)

func set_zoom(zoom_level: float) -> void:
    minimap_settings.zoom_level = clamp(zoom_level, minimap_settings.min_zoom, minimap_settings.max_zoom)
    if minimap_camera:
        minimap_camera.zoom = Vector2(minimap_settings.zoom_level, minimap_settings.zoom_level)

func zoom_in() -> void:
    set_zoom(minimap_settings.zoom_level + 0.1)

func zoom_out() -> void:
    set_zoom(minimap_settings.zoom_level - 0.1)

func open_full_map() -> void:
    full_map_open = true
    full_map_opened.emit()

func close_full_map() -> void:
    full_map_open = false
    full_map_closed.emit()

func save_exploration_data() -> void:
    var save_file = FileAccess.open("user://exploration_data.json", FileAccess.WRITE)
    if save_file:
        var save_data = {
            "explored_chunks": exploration_data.explored_chunks,
            "explored_tiles": exploration_data.explored_tiles
        }
        save_file.store_string(JSON.stringify(save_data))
        save_file.close()

func load_exploration_data() -> void:
    if FileAccess.file_exists("user://exploration_data.json"):
        var save_file = FileAccess.open("user://exploration_data.json", FileAccess.READ)
        if save_file:
            var json = JSON.new()
            if json.parse(save_file.get_as_text()) == OK:
                var data = json.data as Dictionary
                exploration_data.explored_chunks = data.get("explored_chunks", {})
                exploration_data.explored_tiles = data.get("explored_tiles", {})
            save_file.close()
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── MinimapManager.gd
   └── scenes/
       └── ui/
           ├── MinimapUI.tscn
           └── FullMapUI.tscn
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/MinimapManager.gd` as `MinimapManager`
   - **Important:** Load after WorldGenerator and PixelPhysicsManager

3. **Create Minimap UI Scene:**
   - Create MinimapUI scene (Control node)
   - Add TextureRect for viewport texture
   - Add MarkerContainer for markers
   - Add FogOverlay for fog visualization
   - Connect to MinimapManager signals

4. **Create Full Map UI Scene:**
   - Create FullMapUI scene (Control node)
   - Add TextureRect for viewport texture
   - Add MarkerContainer for markers
   - Add FogOverlay for fog visualization
   - Add ZoomControls for zoom/pan
   - Connect to MinimapManager signals

### Initialization Order

**Autoload Order:**
1. GameManager
2. WorldGenerator, PixelPhysicsManager
3. **MinimapManager** (after world systems)
4. UIManager (for minimap UI display)

### System Integration

**Systems Must Call MinimapManager:**
```gdscript
# Example: World change
var change = WorldChangeEvent.new()
change.change_type = WorldChangeEvent.ChangeType.BLOCK_PLACED
change.position = tile_position
change.tile_data = {"tile_id": tile_id}
change.priority = 50
MinimapManager.queue_world_change(change)

# Example: Add quest waypoint
var marker = MinimapMarker.new()
marker.marker_id = "quest_waypoint_1"
marker.marker_type = MinimapMarkerType.QUEST_WAYPOINT
marker.world_position = quest_location
marker.icon = quest_icon
MinimapManager.add_marker(marker)
```

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Minimap System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **SubViewport:** https://docs.godotengine.org/en/stable/classes/class_subviewport.html
- **TileMap:** https://docs.godotengine.org/en/stable/classes/class_tilemap.html
- **Camera2D:** https://docs.godotengine.org/en/stable/classes/class_camera2d.html
- **PhysicsRayQueryParameters2D:** https://docs.godotengine.org/en/stable/classes/class_physicsrayqueryparameters2d.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Minimap System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [SubViewport Documentation](https://docs.godotengine.org/en/stable/classes/class_subviewport.html) - Separate viewport rendering
- [TileMap Documentation](https://docs.godotengine.org/en/stable/classes/class_tilemap.html) - Tile-based rendering
- [Camera2D Documentation](https://docs.godotengine.org/en/stable/classes/class_camera2d.html) - Camera for minimap view
- [PhysicsRayQueryParameters2D Documentation](https://docs.godotengine.org/en/stable/classes/class_physicsrayqueryparameters2d.html) - Line of sight checks

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- MinimapMarker is a Resource (can be created/edited in inspector)
- MinimapSettings is a Resource (can be configured in inspector)
- ExplorationData is a Resource (can be viewed/edited in inspector)

**Visual Configuration:**
- Marker properties editable in inspector
- Settings editable in inspector
- Exploration data viewable in inspector

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Minimap preview tool
  - Marker placement tool
  - Exploration data visualizer

**Current Approach:**
- Uses Godot's native systems (no custom tools needed)
- Markers/settings created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

### Minimap Scene Setup

**Structure:**
```
Minimap (Node2D)
├── SubViewport
│   ├── Camera2D
│   ├── TerrainTileMap
│   └── FogTileMap
└── MarkerContainer (Node2D)
```

**Viewport Configuration:**
```gdscript
# SubViewport settings
viewport.size = Vector2i(512, 512)  # Higher resolution for quality
viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
viewport.world_2d = get_tree().root.world_2d  # Share world
```

### Fog of War Shader (Optional)

**Shader for smooth fog edges:**
```glsl
shader_type canvas_item;

uniform vec4 fog_color : source_color = vec4(0.1, 0.1, 0.1, 0.8);
uniform float fog_edge_softness : hint_range(0.0, 1.0) = 0.2;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Check if in fog (alpha channel)
    if (color.a < 0.5) {
        COLOR = fog_color;
    } else {
        // Smooth edge
        float edge = smoothstep(0.5 - fog_edge_softness, 0.5 + fog_edge_softness, color.a);
        COLOR = mix(fog_color, color, edge);
    }
}
```

---

## Future Enhancements

### Potential Additions

1. **Map Annotations:**
   - Player can place custom markers
   - Notes on map

2. **Map Sharing:**
   - Share exploration data with other players (multiplayer)

3. **Biome Colors:**
   - Different colors for different biomes
   - Visual distinction

4. **Height Indicators:**
   - Show elevation on map
   - Depth visualization

5. **Fast Travel:**
   - Click on map to fast travel (if implemented)

---

## Dependencies

### Required Systems
- World Generation System (for terrain data)
- Player Controller (for player position)

### Systems That Depend on This
- Quest System (for waypoints)
- Building System (for structure markers)
- UI System (for minimap display)

---

## Notes

- Minimap system provides real-time world updates with fog of war
- Hybrid rendering approach balances performance and accuracy
- Smart batching ensures smooth updates without performance issues
- Configurable markers allow player customization
- Separate minimap and full map provide different navigation experiences
- Exploration data persistence maintains player progress

