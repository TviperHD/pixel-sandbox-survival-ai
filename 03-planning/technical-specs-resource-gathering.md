# Technical Specifications: Resource Gathering System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the resource gathering system that handles resource nodes, gathering mechanics, tool requirements, resource yields, respawn systems, and integration with world generation and inventory. This system integrates with InventoryManager, ItemDatabase, InteractionManager, WorldGenerator, and ProgressionManager.

---

## Research Notes

### Resource Gathering System Architecture Best Practices

**Research Findings:**
- Resource nodes use scene instances for world placement
- Gathering progress tracked over time (not instant)
- Tool requirements gate resource access
- Respawn systems maintain world resources
- Integration with world generation for procedural placement

**Sources:**
- [Godot 4 Scene System](https://docs.godotengine.org/en/stable/getting_started/step_by_step/scenes_and_nodes.html) - Scene instances
- [Godot 4 Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- General resource gathering system patterns

**Implementation Approach:**
- ResourceGatheringManager as autoload singleton
- ResourceNode as scene instances (Node2D)
- Gathering progress tracked in _process()
- Tool validation via ItemDatabase
- Respawn timers for resource regeneration
- Integration with InteractionManager for player interaction

**Why This Approach:**
- Singleton: centralized resource management
- Scene instances: easy to place in world
- Progress tracking: smooth gathering experience
- Tool validation: gates resource access appropriately
- Respawn: maintains world resources
- Integration: uses existing interaction system

### Gathering Mechanics Best Practices

**Research Findings:**
- Gathering takes time (not instant)
- Progress bars provide visual feedback
- Tool speed/yield multipliers reward better tools
- Gathering can be interrupted
- Multiple gatherers can't gather same node simultaneously

**Sources:**
- General gathering system patterns

**Implementation Approach:**
- Gathering progress tracked over time
- Progress bar UI for feedback
- Tool speed/yield multipliers from tool data
- Gathering state prevents multiple gatherers
- Interrupt handling for player movement

**Why This Approach:**
- Time-based: more engaging than instant
- Visual feedback: clear progress indication
- Tool multipliers: reward tool upgrades
- Single gatherer: prevents conflicts
- Interrupt handling: responsive controls

### Tool Requirements Best Practices

**Research Findings:**
- Tools gate resource access (pickaxe for ore, axe for wood)
- Tool tiers unlock better resources
- Some resources can be gathered by hand
- Tool durability affects gathering ability

**Sources:**
- General tool system patterns

**Implementation Approach:**
- Tool type requirements (pickaxe, axe, etc.)
- Tool tier requirements (minimum tier)
- Hand gathering option for basic resources
- Tool validation via ItemDatabase

**Why This Approach:**
- Tool types: clear resource gating
- Tool tiers: progression system
- Hand gathering: accessible early game
- ItemDatabase: consistent tool data

### Respawn System Best Practices

**Research Findings:**
- Resources respawn after depletion
- Respawn timers prevent immediate respawn
- Respawn chance allows some randomness
- Respawn maintains world resources

**Sources:**
- General respawn system patterns

**Implementation Approach:**
- Respawn timer tracks time since depletion
- Respawn chance for randomness
- Respawn restores resources
- Visual update on respawn

**Why This Approach:**
- Timer: prevents immediate respawn
- Chance: adds variety
- Restore: maintains world resources
- Visual: clear feedback

---

## Data Structures

### ResourceType

```gdscript
enum ResourceType {
    ORE,           # Metal ores (iron, copper, etc.)
    STONE,         # Stone, rocks
    WOOD,          # Trees, logs
    PLANT,         # Plants, herbs, crops
    CRYSTAL,       # Crystals, gems
    ORGANIC,       # Organic materials (bone, hide, etc.)
    LIQUID,        # Water, oil, etc.
    GAS,           # Gases (for future)
    CUSTOM         # Custom resource types
}
```

### ResourceNodeData

```gdscript
class_name ResourceNodeData
extends Resource

# Identification
@export var resource_id: String  # Unique identifier
@export var resource_name: String  # Display name
@export var resource_type: ResourceType
@export var item_id: String  # Item ID that is gathered (from ItemDatabase)

# Visual
@export var sprite: Texture2D  # World sprite
@export var depleted_sprite: Texture2D  # Sprite when depleted
@export var size: Vector2i = Vector2i(1, 1)  # Size in grid cells

# Gathering Properties
@export var base_yield: int = 1  # Base resources per gather
@export var yield_variance: int = 0  # Random variance (±)
@export var gather_time: float = 1.0  # Time to gather (seconds)
@export var gather_animation: String = ""  # Animation name

# Tool Requirements
@export var required_tool_type: String = ""  # "pickaxe", "axe", "hand", etc.
@export var min_tool_tier: int = 0  # Minimum tool tier required (0 = any)
@export var can_gather_by_hand: bool = false  # Can gather without tool

# Resource Properties
@export var max_resources: int = 10  # Maximum resources in node
@export var starting_resources: int = -1  # -1 = use max_resources
@export var respawn_time: float = 300.0  # Respawn time (seconds, 0 = no respawn)
@export var respawn_chance: float = 1.0  # Chance to respawn (0.0 to 1.0)

# Spawn Properties
@export var spawn_biomes: Array[String] = []  # Biome IDs where this can spawn
@export var spawn_chance: float = 0.1  # Chance per spawn attempt (0.0 to 1.0)
@export var min_depth: int = 0  # Minimum depth (0 = surface)
@export var max_depth: int = 1000  # Maximum depth
@export var spawn_cluster_size: int = 1  # How many spawn together
@export var cluster_radius: float = 32.0  # Radius of cluster

# Metadata
@export var description: String = ""
@export var rarity: int = 0  # 0 = common, higher = rarer
```

### ResourceNode (Scene Node)

```gdscript
class_name ResourceNode
extends Node2D

# Data
@export var node_data: ResourceNodeData
@export var node_id: String  # Unique instance ID

# State
var current_resources: int = 0
var is_depleted: bool = false
var is_gathering: bool = false
var gather_progress: float = 0.0
var current_gatherer: Node2D = null
var respawn_timer: float = 0.0

# Components
@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: ResourceNodeInteractable = $Interactable
@onready var progress_bar: ProgressBar = $ProgressBar  # Optional

# Signals
signal resources_depleted(node: ResourceNode)
signal resources_respawned(node: ResourceNode)
signal gathering_started(node: ResourceNode, gatherer: Node2D)
signal gathering_completed(node: ResourceNode, gatherer: Node2D, yield: int)

# Functions
func _ready() -> void
func _process(delta: float) -> void
func initialize(node_data: ResourceNodeData) -> void
func start_gathering(gatherer: Node2D) -> bool
func update_gathering(delta: float) -> void
func complete_gathering() -> void
func can_gather(gatherer: Node2D) -> bool
func get_yield() -> int
func deplete() -> void
func respawn() -> void
func update_visual() -> void
```

### GatheringTool

```gdscript
class_name GatheringTool
extends RefCounted

var tool_id: String
var tool_type: String  # "pickaxe", "axe", "shovel", etc.
var tool_tier: int = 0  # 0 = basic, higher = better
var gathering_speed_multiplier: float = 1.0  # Speed bonus
var yield_multiplier: float = 1.0  # Yield bonus
var can_gather_types: Array[ResourceType] = []  # What it can gather
```

---

## Core Classes

### ResourceGatheringManager (Autoload Singleton)

```gdscript
class_name ResourceGatheringManager
extends Node

# References
@export var inventory_manager: InventoryManager
@export var world_generator: WorldGenerator
@export var interaction_manager: InteractionManager

# Resource Registry
var resource_node_registry: Dictionary = {}  # resource_id -> ResourceNodeData
var active_nodes: Dictionary = {}  # node_id -> ResourceNode

# Settings
@export var auto_pickup_range: float = 64.0  # Auto-pickup range
@export var gather_sound: AudioStream = null
@export var depleted_sound: AudioStream = null

# Signals
signal resource_gathered(node_id: String, item_id: String, quantity: int)
signal node_depleted(node_id: String)
signal node_respawned(node_id: String)

# Functions
func _ready() -> void
func register_resource_type(node_data: ResourceNodeData) -> void
func spawn_resource_node(resource_id: String, position: Vector2, biome_id: String = "") -> ResourceNode
func gather_from_node(node: ResourceNode, gatherer: Node2D) -> int
func can_gather_from_node(node: ResourceNode, gatherer: Node2D) -> bool
func get_required_tool(node: ResourceNode) -> String
func get_tool_gathering_speed(tool_id: String) -> float
func get_tool_yield_multiplier(tool_id: String) -> float
func update_respawn_timers(delta: float) -> void
func respawn_node(node_id: String) -> void
```

### ResourceSpawner

```gdscript
class_name ResourceSpawner
extends RefCounted

var resource_gathering_manager: ResourceGatheringManager
var world_generator: WorldGenerator

func spawn_resources_in_chunk(chunk_key: Vector2i, biome_id: String) -> void:
    var chunk_data = world_generator.get_chunk(chunk_key)
    if chunk_data == null:
        return
    
    var biome_data = world_generator.get_biome(biome_id)
    if biome_data == null:
        return
    
    # Spawn resources based on biome
    for resource_id in resource_gathering_manager.resource_node_registry:
        var node_data = resource_gathering_manager.resource_node_registry[resource_id]
        
        # Check if resource can spawn in this biome
        if not node_data.spawn_biomes.is_empty():
            if not biome_id in node_data.spawn_biomes:
                continue
        
        # Check spawn chance
        if randf() > node_data.spawn_chance:
            continue
        
        # Spawn resource node(s)
        spawn_resource_cluster(node_data, chunk_key, biome_id)

func spawn_resource_cluster(node_data: ResourceNodeData, chunk_key: Vector2i, biome_id: String) -> void:
    var cluster_size = node_data.spawn_cluster_size
    var base_position = get_random_position_in_chunk(chunk_key)
    
    for i in range(cluster_size):
        var offset = Vector2(
            randf_range(-node_data.cluster_radius, node_data.cluster_radius),
            randf_range(-node_data.cluster_radius, node_data.cluster_radius)
        )
        var position = base_position + offset
        
        # Check depth
        var depth = world_generator.get_depth_at(position)
        if depth < node_data.min_depth or depth > node_data.max_depth:
            continue
        
        # Spawn node
        resource_gathering_manager.spawn_resource_node(node_data.resource_id, position, biome_id)
```

---

## System Architecture

### Component Hierarchy

```
ResourceGatheringManager (Autoload Singleton)
├── ResourceSpawner (utility)
├── ResourceNode (instances in world)
│   └── ResourceNodeInteractable (extends InteractableObject)
└── GatheringTool (data)
```

### Data Flow

1. **Resource Spawning:**
   - World generation → `ResourceSpawner.spawn_resources_in_chunk()` called
   - Checks biome, spawn chance, depth
   - Creates `ResourceNode` instances
   - Registers with `ResourceGatheringManager`

2. **Resource Gathering:**
   - Player interacts with resource node → `ResourceNodeInteractable.interact()` called
   - Validates tool requirements → `can_gather()` check
   - Starts gathering → `start_gathering()` called
   - Updates progress → `update_gathering()` called each frame
   - Completes gathering → `complete_gathering()` called
   - Adds resources to inventory → `InventoryManager.add_item_by_id()`

3. **Resource Depletion:**
   - Resources reach 0 → `deplete()` called
   - Node marked as depleted → Visual updated
   - Respawn timer started → `respawn_timer` set

4. **Resource Respawn:**
   - Respawn timer expires → `respawn()` called
   - Resources restored → `current_resources` reset
   - Visual updated → Sprite changed back

---

## Algorithms

### Gathering Algorithm

```gdscript
func start_gathering(gatherer: Node2D) -> bool:
    if is_depleted or current_resources <= 0:
        return false
    
    if not can_gather(gatherer):
        return false
    
    is_gathering = true
    current_gatherer = gatherer
    gather_progress = 0.0
    
    emit_signal("gathering_started", self, gatherer)
    return true

func update_gathering(delta: float) -> void:
    if not is_gathering:
        return
    
    # Get tool speed multiplier
    var tool_speed = 1.0
    if current_gatherer.has_method("get_equipped_tool"):
        var tool = current_gatherer.get_equipped_tool()
        if tool:
            tool_speed = ResourceGatheringManager.get_tool_gathering_speed(tool.tool_id)
    
    # Update progress
    var gather_time = node_data.gather_time / tool_speed
    gather_progress += delta / gather_time
    
    # Update progress bar if exists
    if progress_bar:
        progress_bar.value = gather_progress * 100.0
    
    # Check if complete
    if gather_progress >= 1.0:
        complete_gathering()

func complete_gathering() -> void:
    if not is_gathering:
        return
    
    # Calculate yield
    var yield_amount = get_yield()
    
    # Get tool yield multiplier
    var tool_yield_mult = 1.0
    if current_gatherer.has_method("get_equipped_tool"):
        var tool = current_gatherer.get_equipped_tool()
        if tool:
            tool_yield_mult = ResourceGatheringManager.get_tool_yield_multiplier(tool.tool_id)
    
    yield_amount = int(yield_amount * tool_yield_mult)
    
    # Add to inventory (via InventoryManager)
    var added = 0
    if InventoryManager:
        added = InventoryManager.add_item(node_data.item_id, yield_amount)
    else:
        push_warning("ResourceNode: InventoryManager not available")
        added = yield_amount  # Assume added if no manager
    
    # Update resources
    current_resources -= added
    
    # Award experience (via ProgressionManager)
    if ProgressionManager:
        ProgressionManager.gain_experience(2.0, ProgressionManager.ExperienceSource.COLLECT_RESOURCE)
    
    # Emit signal
    emit_signal("gathering_completed", self, current_gatherer, added)
    if ResourceGatheringManager:
        ResourceGatheringManager.emit_signal("resource_gathered", node_id, node_data.item_id, added)
    
    # Check if depleted
    if current_resources <= 0:
        deplete()
    
    # Reset gathering state
    is_gathering = false
    gather_progress = 0.0
    current_gatherer = null
```

### Tool Validation Algorithm

```gdscript
func can_gather(gatherer: Node2D) -> bool:
    # Check if node has resources
    if is_depleted or current_resources <= 0:
        return false
    
    # Check if already gathering
    if is_gathering and current_gatherer != gatherer:
        return false
    
    # Check tool requirements
    if node_data.can_gather_by_hand:
        return true  # Can gather by hand
    
    if node_data.required_tool_type.is_empty():
        return true  # No tool required
    
    # Check if gatherer has required tool
    if not gatherer.has_method("get_equipped_tool"):
        return false
    
    var tool = gatherer.get_equipped_tool()
    if tool == null:
        return false
    
    # Check tool type
    if tool.tool_type != node_data.required_tool_type:
        return false
    
    # Check tool tier
    if tool.tool_tier < node_data.min_tool_tier:
        return false
    
    # Check tool durability (if tool has durability)
    if tool.has_method("get_durability"):
        var durability = tool.get_durability()
        if durability != null and durability <= 0:
            return false  # Tool broken
    
    return true
```

### Yield Calculation Algorithm

```gdscript
func get_yield() -> int:
    var base_yield = node_data.base_yield
    
    # Add variance
    if node_data.yield_variance > 0:
        var variance = randi_range(-node_data.yield_variance, node_data.yield_variance)
        base_yield += variance
    
    # Clamp to available resources
    base_yield = min(base_yield, current_resources)
    
    # Ensure at least 1 if resources available
    if current_resources > 0 and base_yield < 1:
        base_yield = 1
    
    return base_yield
```

### Respawn Algorithm

```gdscript
func _process(delta: float) -> void:
    # Update respawn timer if depleted
    if is_depleted and node_data.respawn_time > 0:
        respawn_timer += delta
        
        if respawn_timer >= node_data.respawn_time:
            # Check respawn chance
            if randf() <= node_data.respawn_chance:
                respawn()
            else:
                # Reset timer for next attempt
                respawn_timer = 0.0

func respawn() -> void:
    current_resources = node_data.max_resources
    is_depleted = false
    respawn_timer = 0.0
    
    update_visual()
    emit_signal("resources_respawned", self)
    ResourceGatheringManager.emit_signal("node_respawned", node_id)
```

---

## Integration Points

### World Generation

**Usage:**
- World generation spawns resource nodes during chunk generation
- Uses biome data to determine which resources spawn
- Integrates with chunk loading/unloading

**Example:**
```gdscript
# In WorldGenerator
func generate_chunk(chunk_key: Vector2i) -> void:
    # ... terrain generation ...
    
    # Spawn resources
    var biome_id = get_biome_at_chunk(chunk_key)
    ResourceSpawner.spawn_resources_in_chunk(chunk_key, biome_id)
```

### Interaction System

**Usage:**
- Resource nodes use `ResourceNodeInteractable` (extends `InteractableObject`)
- Gathering triggered through interaction system
- Tool validation integrated with interaction

**Example:**
```gdscript
# ResourceNodeInteractable extends InteractableObject
func interact(player: Node2D) -> InteractionResult:
    var result = InteractionResult.new()
    
    if not resource_node.can_gather(player):
        result.success = false
        result.message = "Cannot gather (tool required or depleted)"
        return result
    
    resource_node.start_gathering(player)
    result.success = true
    result.message = "Gathering..."
    return result
```

### Inventory System

**Usage:**
- Gathered resources added to inventory
- Tool items checked for gathering capabilities
- Item pickup for gathered resources

**Example:**
```gdscript
# In ResourceNode.complete_gathering()
var added = InventoryManager.add_item_by_id(node_data.item_id, yield_amount)
```

### Item Database

**Usage:**
- Resource node data references item IDs
- Tool items have gathering properties
- Item data used for tool validation

**Example:**
```gdscript
# Tool item has gathering properties
var tool_item = ItemDatabase.get_item(tool_id)
if tool_item.metadata.has("gathering_tool"):
    var tool_data = tool_item.metadata["gathering_tool"]
    # Use tool_data for gathering speed/yield multipliers
```

---

## Save/Load System

### Resource Node Save

**Save Format:**
```gdscript
{
    "resource_nodes": {
        "node_001": {
            "node_id": "node_001",
            "resource_id": "iron_ore",
            "position": {"x": 100, "y": 200},
            "current_resources": 5,
            "is_depleted": false,
            "respawn_timer": 120.0
        }
    }
}
```

**Load Format:**
```gdscript
func load_resource_node(save_data: Dictionary) -> void:
    var node = ResourceNode.new()
    node.node_id = save_data.node_id
    node.node_data = ResourceGatheringManager.resource_node_registry[save_data.resource_id]
    node.current_resources = save_data.get("current_resources", node.node_data.max_resources)
    node.is_depleted = save_data.get("is_depleted", false)
    node.respawn_timer = save_data.get("respawn_timer", 0.0)
    node.global_position = Vector2(save_data.position.x, save_data.position.y)
    node.initialize(node.node_data)
```

---

## Performance Considerations

### Optimization Strategies

1. **Chunk-Based Management:**
   - Only update nodes in loaded chunks
   - Unload nodes when chunks unload

2. **Respawn Timer Optimization:**
   - Only update respawn timers for depleted nodes
   - Batch respawn checks (check every 10 seconds instead of every frame)

3. **Visual Updates:**
   - Only update visuals when state changes
   - Use object pooling for resource nodes

4. **Spatial Partitioning:**
   - Use spatial hash for node lookup
   - Only check nearby nodes for interactions

5. **Gathering Progress:**
   - Limit active gathering operations per player
   - Cancel gathering if player moves too far

---

## Testing Checklist

### Resource Spawning
- [ ] Resources spawn correctly in biomes
- [ ] Spawn chance works correctly
- [ ] Depth restrictions work correctly
- [ ] Cluster spawning works correctly
- [ ] Resources spawn during world generation

### Resource Gathering
- [ ] Gathering starts correctly
- [ ] Gathering progress updates correctly
- [ ] Gathering completes correctly
- [ ] Resources added to inventory correctly
- [ ] Yield calculation works correctly
- [ ] Tool speed multipliers work correctly
- [ ] Tool yield multipliers work correctly

### Tool Requirements
- [ ] Tool type validation works
- [ ] Tool tier validation works
- [ ] Hand gathering works (when allowed)
- [ ] Missing tool prevents gathering

### Resource Depletion
- [ ] Node depletes when resources reach 0
- [ ] Visual updates when depleted
- [ ] Gathering stops when depleted
- [ ] Signals emitted correctly

### Resource Respawn
- [ ] Respawn timer works correctly
- [ ] Respawn chance works correctly
- [ ] Resources restored on respawn
- [ ] Visual updates on respawn
- [ ] Signals emitted correctly

### Integration
- [ ] Works with world generation
- [ ] Works with interaction system
- [ ] Works with inventory system
- [ ] Works with item database
- [ ] Save/load works correctly

---

## Error Handling

### ResourceGatheringManager Error Handling

- **Missing System References:** Handle missing managers (InventoryManager, ItemDatabase) gracefully
- **Invalid Resource IDs:** Validate resource IDs before operations, return errors gracefully
- **Missing Tool Data:** Handle missing tool data gracefully, use defaults
- **Gathering Failures:** Handle gathering failures gracefully (inventory full, tool broken, etc.)

### Best Practices

- Use `push_error()` for critical errors (invalid resource ID, missing managers)
- Use `push_warning()` for non-critical issues (gathering failed, inventory full)
- Return false/null on errors (don't crash)
- Validate all data before operations
- Handle missing system managers gracefully

---

## Default Values and Configuration

### ResourceGatheringManager Defaults

```gdscript
auto_pickup_range = 64.0
gather_sound = null
depleted_sound = null
```

### ResourceNodeData Defaults

```gdscript
resource_id = ""
resource_name = ""
resource_type = ResourceType.CUSTOM
item_id = ""
sprite = null
depleted_sprite = null
size = Vector2i(1, 1)
base_yield = 1
yield_variance = 0
gather_time = 1.0
gather_animation = ""
required_tool_type = ""
min_tool_tier = 0
can_gather_by_hand = false
max_resources = 10
starting_resources = -1  # -1 = use max_resources
respawn_time = 300.0
respawn_chance = 1.0
spawn_biomes = []
spawn_chance = 0.1
min_depth = 0
max_depth = 1000
spawn_cluster_size = 1
cluster_radius = 32.0
description = ""
rarity = 0
```

### ResourceNode Defaults

```gdscript
node_data = null
node_id = ""
current_resources = 0
is_depleted = false
is_gathering = false
gather_progress = 0.0
current_gatherer = null
respawn_timer = 0.0
```

---

## Complete Implementation

### ResourceGatheringManager Complete Implementation

```gdscript
class_name ResourceGatheringManager
extends Node

# References
var inventory_manager: Node = null
var world_generator: Node = null
var interaction_manager: Node = null

# Resource Registry
var resource_node_registry: Dictionary = {}
var active_nodes: Dictionary = {}

# Settings
var auto_pickup_range: float = 64.0
var gather_sound: AudioStream = null
var depleted_sound: AudioStream = null

# Signals
signal resource_gathered(node_id: String, item_id: String, quantity: int)
signal node_depleted(node_id: String)
signal node_respawned(node_id: String)

func _ready() -> void:
    # Find managers
    inventory_manager = get_node_or_null("/root/InventoryManager")
    world_generator = get_node_or_null("/root/WorldGenerator")
    interaction_manager = get_node_or_null("/root/InteractionManager")
    
    # Load resource types
    load_resource_types()

func _process(delta: float) -> void:
    # Update respawn timers
    update_respawn_timers(delta)

func load_resource_types() -> void:
    # Load resource node data from resources directory
    var resource_dir = DirAccess.open("res://resources/resource_nodes/")
    if resource_dir:
        resource_dir.list_dir_begin()
        var file_name = resource_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var node_data = load("res://resources/resource_nodes/" + file_name) as ResourceNodeData
                if node_data:
                    register_resource_type(node_data)
            file_name = resource_dir.get_next()

func register_resource_type(node_data: ResourceNodeData) -> void:
    if node_data:
        resource_node_registry[node_data.resource_id] = node_data

func spawn_resource_node(resource_id: String, position: Vector2, biome_id: String = "") -> ResourceNode:
    var node_data = resource_node_registry.get(resource_id)
    if not node_data:
        push_error("ResourceGatheringManager: Resource type not found: " + resource_id)
        return null
    
    # Create resource node scene
    var node_scene = preload("res://scenes/world/ResourceNode.tscn")
    var node = node_scene.instantiate() as ResourceNode
    if not node:
        push_error("ResourceGatheringManager: Failed to instantiate ResourceNode scene")
        return null
    
    # Initialize node
    node.node_id = "resource_" + str(Time.get_ticks_msec()) + "_" + str(randi())
    node.global_position = position
    node.initialize(node_data)
    
    # Add to scene tree
    get_tree().current_scene.add_child(node)
    
    # Register node
    active_nodes[node.node_id] = node
    
    return node

func gather_from_node(node: ResourceNode, gatherer: Node2D) -> int:
    if not node:
        return 0
    
    if not can_gather_from_node(node, gatherer):
        return 0
    
    # Start gathering
    if node.start_gathering(gatherer):
        return 1  # Gathering started
    
    return 0

func can_gather_from_node(node: ResourceNode, gatherer: Node2D) -> bool:
    if not node:
        return false
    
    return node.can_gather(gatherer)

func get_required_tool(node: ResourceNode) -> String:
    if not node or not node.node_data:
        return ""
    
    return node.node_data.required_tool_type

func get_tool_gathering_speed(tool_id: String) -> float:
    if not ItemDatabase:
        return 1.0
    
    var tool_item = ItemDatabase.get_item_safe(tool_id)
    if not tool_item:
        return 1.0
    
    # Get gathering speed from tool metadata
    if tool_item.metadata.has("gathering_speed_multiplier"):
        return tool_item.metadata["gathering_speed_multiplier"]
    
    return 1.0

func get_tool_yield_multiplier(tool_id: String) -> float:
    if not ItemDatabase:
        return 1.0
    
    var tool_item = ItemDatabase.get_item_safe(tool_id)
    if not tool_item:
        return 1.0
    
    # Get yield multiplier from tool metadata
    if tool_item.metadata.has("gathering_yield_multiplier"):
        return tool_item.metadata["gathering_yield_multiplier"]
    
    return 1.0

func update_respawn_timers(delta: float) -> void:
    for node_id in active_nodes:
        var node = active_nodes[node_id]
        if node.is_depleted and node.respawn_time > 0.0:
            node.respawn_timer += delta
            
            if node.respawn_timer >= node.node_data.respawn_time:
                # Check respawn chance
                if randf() <= node.node_data.respawn_chance:
                    respawn_node(node_id)

func respawn_node(node_id: String) -> void:
    var node = active_nodes.get(node_id)
    if not node:
        return
    
    node.respawn()
    node_respawned.emit(node_id)
```

### ResourceNode Complete Implementation

```gdscript
class_name ResourceNode
extends Node2D

# Data
@export var node_data: ResourceNodeData = null
@export var node_id: String = ""

# State
var current_resources: int = 0
var is_depleted: bool = false
var is_gathering: bool = false
var gather_progress: float = 0.0
var current_gatherer: Node2D = null
var respawn_timer: float = 0.0

# Components
@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: ResourceNodeInteractable = $Interactable
@onready var progress_bar: ProgressBar = $ProgressBar

# Signals
signal resources_depleted(node: ResourceNode)
signal resources_respawned(node: ResourceNode)
signal gathering_started(node: ResourceNode, gatherer: Node2D)
signal gathering_completed(node: ResourceNode, gatherer: Node2D, yield: int)

func _ready() -> void:
    if node_data:
        initialize(node_data)

func _process(delta: float) -> void:
    if is_gathering:
        update_gathering(delta)

func initialize(data: ResourceNodeData) -> void:
    node_data = data
    
    # Set starting resources
    if node_data.starting_resources >= 0:
        current_resources = node_data.starting_resources
    else:
        current_resources = node_data.max_resources
    
    # Setup interactable
    if interactable:
        interactable.object_id = node_id
        interactable.interaction_type = InteractionType.RESOURCE_GATHER
        interactable.interaction_name = node_data.resource_name
    
    # Update visual
    update_visual()

func start_gathering(gatherer: Node2D) -> bool:
    if is_depleted or current_resources <= 0:
        return false
    
    if not can_gather(gatherer):
        return false
    
    is_gathering = true
    current_gatherer = gatherer
    gather_progress = 0.0
    
    gathering_started.emit(self, gatherer)
    return true

func update_gathering(delta: float) -> void:
    if not is_gathering:
        return
    
    # Get tool speed multiplier
    var tool_speed = 1.0
    if current_gatherer and current_gatherer.has_method("get_equipped_tool"):
        var tool = current_gatherer.get_equipped_tool()
        if tool and ResourceGatheringManager:
            tool_speed = ResourceGatheringManager.get_tool_gathering_speed(tool.tool_id)
    
    # Update progress
    var gather_time = node_data.gather_time / tool_speed
    gather_progress += delta / gather_time
    
    # Update progress bar
    if progress_bar:
        progress_bar.value = gather_progress * 100.0
    
    # Check if complete
    if gather_progress >= 1.0:
        complete_gathering()

func complete_gathering() -> void:
    if not is_gathering:
        return
    
    # Calculate yield
    var yield_amount = get_yield()
    
    # Get tool yield multiplier
    var tool_yield_mult = 1.0
    if current_gatherer and current_gatherer.has_method("get_equipped_tool"):
        var tool = current_gatherer.get_equipped_tool()
        if tool and ResourceGatheringManager:
            tool_yield_mult = ResourceGatheringManager.get_tool_yield_multiplier(tool.tool_id)
    
    yield_amount = int(yield_amount * tool_yield_mult)
    
    # Add to inventory
    var added = 0
    if InventoryManager:
        added = InventoryManager.add_item(node_data.item_id, yield_amount)
    else:
        push_warning("ResourceNode: InventoryManager not available")
        added = yield_amount
    
    # Award experience
    if ProgressionManager:
        ProgressionManager.gain_experience(2.0, ProgressionManager.ExperienceSource.COLLECT_RESOURCE)
    
    # Update resources
    current_resources -= added
    
    # Emit signal
    gathering_completed.emit(self, current_gatherer, added)
    if ResourceGatheringManager:
        ResourceGatheringManager.emit_signal("resource_gathered", node_id, node_data.item_id, added)
    
    # Check if depleted
    if current_resources <= 0:
        deplete()
    
    # Reset gathering state
    is_gathering = false
    gather_progress = 0.0
    current_gatherer = null

func can_gather(gatherer: Node2D) -> bool:
    if is_depleted or current_resources <= 0:
        return false
    
    if is_gathering and current_gatherer != gatherer:
        return false
    
    # Check tool requirements
    if node_data.can_gather_by_hand:
        return true
    
    if node_data.required_tool_type.is_empty():
        return true
    
    if not gatherer or not gatherer.has_method("get_equipped_tool"):
        return false
    
    var tool = gatherer.get_equipped_tool()
    if tool == null:
        return false
    
    # Check tool type (from tool metadata)
    var tool_type = tool.metadata.get("tool_type", "")
    if tool_type != node_data.required_tool_type:
        return false
    
    # Check tool tier (from tool metadata)
    var tool_tier = tool.metadata.get("tool_tier", 0)
    if tool_tier < node_data.min_tool_tier:
        return false
    
    # Check tool durability
    if tool.has_method("get_durability"):
        var durability = tool.get_durability()
        if durability != null and durability <= 0:
            return false
    
    return true

func get_yield() -> int:
    var base_yield = node_data.base_yield
    
    # Add variance
    if node_data.yield_variance > 0:
        var variance = randi_range(-node_data.yield_variance, node_data.yield_variance)
        base_yield += variance
    
    # Ensure minimum yield
    base_yield = max(base_yield, 1)
    
    # Clamp to available resources
    base_yield = min(base_yield, current_resources)
    
    return base_yield

func deplete() -> void:
    is_depleted = true
    current_resources = 0
    is_gathering = false
    gather_progress = 0.0
    current_gatherer = null
    
    # Start respawn timer
    if node_data.respawn_time > 0.0:
        respawn_timer = 0.0
    
    # Update visual
    update_visual()
    
    resources_depleted.emit(self)
    
    if ResourceGatheringManager:
        ResourceGatheringManager.emit_signal("node_depleted", node_id)

func respawn() -> void:
    is_depleted = false
    current_resources = node_data.max_resources
    respawn_timer = 0.0
    
    # Update visual
    update_visual()
    
    resources_respawned.emit(self)
    
    if ResourceGatheringManager:
        ResourceGatheringManager.emit_signal("node_respawned", node_id)

func update_visual() -> void:
    if not sprite or not node_data:
        return
    
    if is_depleted and node_data.depleted_sprite:
        sprite.texture = node_data.depleted_sprite
    else:
        sprite.texture = node_data.sprite
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── ResourceGatheringManager.gd
   └── scripts/
       └── world/
           └── ResourceNode.gd
   └── scenes/
       └── world/
           └── ResourceNode.tscn
   └── resources/
       └── resource_nodes/
           ├── iron_ore.tres
           ├── copper_ore.tres
           └── stone.tres
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/ResourceGatheringManager.gd` as `ResourceGatheringManager`
   - **Important:** Load after ItemDatabase and InventoryManager

3. **Create Resource Node Data:**
   - Create ResourceNodeData resources for each resource type
   - Set resource properties (yield, gather time, tool requirements, etc.)
   - Save as `.tres` files in `res://resources/resource_nodes/`

4. **Create Resource Node Scene:**
   - Create ResourceNode scene with Sprite2D, CollisionShape2D, and ResourceNodeInteractable
   - Configure scene structure
   - Save as `res://scenes/world/ResourceNode.tscn`

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. InventoryManager
4. **ResourceGatheringManager** (after ItemDatabase and InventoryManager)

### System Integration

**Resource Nodes Must:**
- Extend ResourceNode class
- Have ResourceNodeData resource assigned
- Have ResourceNodeInteractable component
- Be registered with ResourceGatheringManager

**Tools Must Have Metadata:**
```gdscript
# Tool item metadata
{
    "tool_type": "pickaxe",  # or "axe", "shovel", etc.
    "tool_tier": 1,
    "gathering_speed_multiplier": 1.5,
    "gathering_yield_multiplier": 1.2
}
```

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Resource Gathering System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Scene System:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/scenes_and_nodes.html
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Node2D:** https://docs.godotengine.org/en/stable/classes/class_node2d.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Resource Gathering System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Scene System Tutorial](https://docs.godotengine.org/en/stable/getting_started/step_by_step/scenes_and_nodes.html) - Scene instances
- [Signals Tutorial](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Node2D Documentation](https://docs.godotengine.org/en/stable/classes/class_node2d.html) - 2D node base class

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- ResourceNodeData is a Resource (can be created/edited in inspector)
- ResourceNode is a Node2D (can be added to scene tree)
- Resource properties configured via @export variables (editable in inspector)

**Visual Configuration:**
- Resource node data editable in inspector
- Resource node scene editable in editor
- Tool metadata editable in ItemDatabase

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Resource spawner tool (visual placement)
  - Resource node preview
  - Tool metadata editor

**Current Approach:**
- Uses Godot's native Resource and Scene systems (no custom tools needed)
- Resource nodes created as scenes (editable in editor)
- Resource data configured via resources (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

### Resource Node Registration

**Method:** Register resource types in `ResourceGatheringManager`

**Example:**
```gdscript
# In ResourceGatheringManager._ready()
var iron_ore_data = ResourceNodeData.new()
iron_ore_data.resource_id = "iron_ore"
iron_ore_data.resource_name = "Iron Ore"
iron_ore_data.item_id = "iron_ore"
iron_ore_data.required_tool_type = "pickaxe"
iron_ore_data.base_yield = 2
iron_ore_data.max_resources = 10
iron_ore_data.respawn_time = 300.0
register_resource_type(iron_ore_data)
```

### Tool Item Properties

**Metadata Structure:**
```gdscript
# Tool item metadata
{
    "gathering_tool": {
        "tool_type": "pickaxe",
        "tool_tier": 1,
        "gathering_speed_multiplier": 1.5,
        "yield_multiplier": 1.2,
        "can_gather_types": [ResourceType.ORE, ResourceType.STONE]
    }
}
```

---

## Future Enhancements

### Potential Additions

1. **Gathering Skills:**
   - Skill-based gathering speed/yield
   - Skill progression from gathering

2. **Gathering Animations:**
   - Player animation during gathering
   - Tool-specific animations

3. **Resource Quality:**
   - Quality levels (poor, normal, good, excellent)
   - Quality affects yield or item quality

4. **Gathering Events:**
   - Rare resource spawns
   - Gathering achievements
   - Gathering challenges

5. **Multi-Resource Nodes:**
   - Nodes that yield multiple resource types
   - Conditional resource yields

---

## Dependencies

### Required Systems
- Item Database System
- Inventory System
- Interaction System
- World Generation System

### Systems That Depend on This
- Crafting System (needs gathered resources)
- Building System (needs gathered resources)
- Quest System (gathering objectives)

---

## Notes

- Resource gathering is a core gameplay mechanic
- Tool requirements add depth and progression
- Respawn system ensures resources don't permanently deplete
- Integration with world generation ensures resources spawn appropriately
- Gathering system integrates with all relevant systems for seamless gameplay

