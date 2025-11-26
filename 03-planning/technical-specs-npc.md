# Technical Specifications: NPC System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the NPC system that handles NPCs, their behavior, movement, interactions, dialogue, quest giving, state management, and integration with dialogue, quest, and interaction systems. This system integrates with DialogueManager, QuestManager, InteractionManager, and WorldGenerator.

---

## Research Notes

### NPC System Architecture Best Practices

**Research Findings:**
- NPCs use CharacterBody2D for physics-based movement
- Behavior systems control NPC movement patterns
- State management tracks NPC interactions and quests
- Integration with dialogue and quest systems enables rich NPC interactions
- Distance-based updates optimize performance

**Sources:**
- [Godot 4 CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) - Physics-based movement
- [Godot 4 Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Godot 4 Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Detection areas
- General NPC system design patterns

**Implementation Approach:**
- NPCManager as autoload singleton
- NPC as CharacterBody2D scene instances
- NPCData as Resource (NPC configuration)
- Behavior system via NPCBehavior utility class
- State management via NPCState
- Integration with InteractionManager for player interaction

**Why This Approach:**
- Singleton: centralized NPC management
- CharacterBody2D: physics-based movement
- Resources: easy to create/edit NPCs in editor
- Behavior system: flexible movement patterns
- State management: tracks NPC interactions
- Integration: uses existing interaction system

### NPC Behavior Best Practices

**Research Findings:**
- Multiple behavior types (static, patrol, wander, guard, flee)
- Behavior updates happen each frame for nearby NPCs
- Patrol paths defined by waypoints
- Wander uses random movement
- Guard behavior watches for threats

**Sources:**
- General NPC behavior patterns

**Implementation Approach:**
- Behavior types: STATIC, PATROL, WANDER, GUARD, FLEE, FOLLOW
- Behavior updates in _process() for nearby NPCs only
- Patrol paths as array of Vector2 waypoints
- Wander uses random target positions
- Guard combines patrol with threat detection

**Why This Approach:**
- Multiple types: flexible NPC behaviors
- Distance-based updates: performance optimization
- Waypoints: clear patrol paths
- Random movement: natural wandering
- Guard behavior: defensive NPCs

### NPC Interaction Best Practices

**Research Findings:**
- NPCs use InteractableObject for player interaction
- Dialogue selection based on quest state and NPC state
- Quest giving integrated with quest system
- State tracking for first meetings, quest completion, etc.

**Sources:**
- General interaction system patterns

**Implementation Approach:**
- NPCInteractable extends InteractableObject
- Dialogue selection via get_dialogue_id() method
- Quest giving via give_quest() method
- State data tracks interactions and quests

**Why This Approach:**
- InteractableObject: consistent interaction system
- Dynamic dialogue: quest/state-based dialogue selection
- Quest integration: seamless quest giving
- State tracking: remembers player interactions

### NPC State Management Best Practices

**Research Findings:**
- NPC state persists across sessions
- State tracks quests given/completed
- State tracks interaction history
- State enables dynamic dialogue and behavior

**Sources:**
- General state management patterns

**Implementation Approach:**
- NPCState tracks NPC runtime state
- State saved/loaded with game saves
- State data dictionary for custom state
- State affects dialogue and behavior

**Why This Approach:**
- Persistence: NPCs remember player
- Quest tracking: knows what quests given/completed
- Interaction history: remembers conversations
- Dynamic behavior: state affects NPC responses

---

## Data Structures

### NPCData

```gdscript
class_name NPCData
extends Resource

# Identification
@export var npc_id: String  # Unique identifier
@export var npc_name: String  # Display name
@export var npc_type: NPCType

enum NPCType {
    VENDOR,        # Can trade items
    QUEST_GIVER,   # Can give quests
    GUARD,         # Guard/combat NPC
    CIVILIAN,      # Regular NPC
    MERCHANT,      # Sells items
    CUSTOM         # Custom NPC type
}

# Visual
@export var sprite: Texture2D
@export var portrait: Texture2D
@export var size: Vector2 = Vector2(16, 16)

# Dialogue
@export var default_dialogue_id: String = ""  # Default dialogue
@export var dialogue_ids: Dictionary = {}  # condition -> dialogue_id

# Quest
@export var available_quests: Array[String] = []  # Quest IDs
@export var completed_quest_dialogue_id: String = ""  # Dialogue after quest completion

# Behavior
@export var behavior_type: BehaviorType
@export var movement_speed: float = 50.0
@export var patrol_path: Array[Vector2] = []  # Patrol waypoints
@export var idle_time: float = 2.0  # Time to idle at waypoint
@export var detection_range: float = 128.0  # Range to detect player

enum BehaviorType {
    STATIC,      # Doesn't move
    PATROL,      # Patrols along path
    WANDER,      # Wanders randomly
    FOLLOW,      # Follows player (if friendly)
    GUARD,       # Guards area
    FLEE,        # Flees from player/enemies
    CUSTOM       # Custom behavior
}

# State
@export var is_friendly: bool = true
@export var health: float = 100.0
@export var max_health: float = 100.0
@export var reputation: int = 0  # Reputation with player

# Metadata
@export var description: String = ""
@export var tags: Array[String] = []
```

### NPCState

```gdscript
class_name NPCState
extends RefCounted

var npc_id: String
var current_position: Vector2
var current_behavior: NPCData.BehaviorType
var current_dialogue_id: String = ""
var quests_given: Array[String] = []  # Quest IDs given to player
var quests_completed: Array[String] = []  # Quest IDs completed by player
var last_interaction_time: float = 0.0
var state_data: Dictionary = {}  # Custom state data
```

### NPC (Scene Node)

```gdscript
class_name NPC
extends CharacterBody2D

# Data
@export var npc_data: NPCData
@export var npc_id: String

# State
var current_state: NPCState
var current_behavior_state: String = "idle"  # "idle", "patrol", "wander", etc.
var current_patrol_index: int = 0
var patrol_timer: float = 0.0
var target_position: Vector2 = Vector2.ZERO
var is_interacting: bool = false

# Components
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interactable: NPCInteractable = $Interactable
@onready var detection_area: Area2D = $DetectionArea

# References
var dialogue_manager: DialogueManager
var quest_manager: QuestManager
var interaction_manager: InteractionManager

# Signals
signal npc_interacted(npc: NPC, player: Node2D)
signal npc_quest_given(npc: NPC, quest_id: String)
signal npc_state_changed(npc: NPC, new_state: String)

# Functions
func _ready() -> void
func _process(delta: float) -> void
func _physics_process(delta: float) -> void
func initialize(npc_data: NPCData) -> void
func update_behavior(delta: float) -> void
func update_patrol(delta: float) -> void
func update_wander(delta: float) -> void
func move_towards(target: Vector2, delta: float) -> void
func get_dialogue_id() -> String
func can_give_quest(quest_id: String) -> bool
func give_quest(quest_id: String) -> bool
func on_quest_completed(quest_id: String) -> void
func update_visual() -> void
```

---

## Core Classes

### NPCManager (Autoload Singleton)

```gdscript
class_name NPCManager
extends Node

# References
@export var dialogue_manager: DialogueManager
@export var quest_manager: QuestManager
@export var interaction_manager: InteractionManager
@export var world_generator: WorldGenerator

# NPC Registry
var npc_registry: Dictionary = {}  # npc_id -> NPCData
var active_npcs: Dictionary = {}  # npc_id -> NPC (scene node)
var npc_states: Dictionary = {}  # npc_id -> NPCState

# Settings
@export var npc_update_distance: float = 512.0  # Update NPCs within this distance
@export var npc_despawn_distance: float = 1024.0  # Despawn NPCs beyond this distance

# Signals
signal npc_spawned(npc_id: String, npc: NPC)
signal npc_despawned(npc_id: String)
signal npc_interacted(npc_id: String, player: Node2D)
signal npc_quest_given(npc_id: String, quest_id: String)

# Functions
func _ready() -> void
func _process(delta: float) -> void
func register_npc(npc_data: NPCData) -> void
func spawn_npc(npc_id: String, position: Vector2) -> NPC
func despawn_npc(npc_id: String) -> void
func get_npc(npc_id: String) -> NPC
func get_npc_data(npc_id: String) -> NPCData
func get_npc_state(npc_id: String) -> NPCState
func update_npc_behavior(npc: NPC, delta: float) -> void
func update_nearby_npcs(player_position: Vector2) -> void
func get_npcs_in_range(position: Vector2, range: float) -> Array[NPC]
func save_npc_states() -> Dictionary
func load_npc_states(save_data: Dictionary) -> void
```

### NPCBehavior

```gdscript
class_name NPCBehavior
extends RefCounted

static func update_behavior(npc: NPC, delta: float) -> void:
    match npc.npc_data.behavior_type:
        NPCData.BehaviorType.STATIC:
            update_static(npc, delta)
        
        NPCData.BehaviorType.PATROL:
            update_patrol(npc, delta)
        
        NPCData.BehaviorType.WANDER:
            update_wander(npc, delta)
        
        NPCData.BehaviorType.GUARD:
            update_guard(npc, delta)
        
        NPCData.BehaviorType.FLEE:
            update_flee(npc, delta)
        
        _:
            pass

static func update_static(npc: NPC, delta: float) -> void:
    # Static NPCs don't move
    pass

static func update_patrol(npc: NPC, delta: float) -> void:
    if npc.npc_data.patrol_path.is_empty():
        return
    
    # Check if reached current waypoint
    var distance = npc.global_position.distance_to(npc.target_position)
    if distance < 8.0:  # Close enough
        # Idle at waypoint
        npc.patrol_timer += delta
        if npc.patrol_timer >= npc.npc_data.idle_time:
            # Move to next waypoint
            npc.current_patrol_index = (npc.current_patrol_index + 1) % npc.npc_data.patrol_path.size()
            npc.target_position = npc.npc_data.patrol_path[npc.current_patrol_index]
            npc.patrol_timer = 0.0
    else:
        # Move towards waypoint
        npc.move_towards(npc.target_position, delta)

static func update_wander(npc: NPC, delta: float) -> void:
    # Random wandering behavior
    if npc.target_position == Vector2.ZERO or npc.global_position.distance_to(npc.target_position) < 8.0:
        # Pick new random position nearby
        var wander_range = 128.0
        npc.target_position = npc.global_position + Vector2(
            randf_range(-wander_range, wander_range),
            randf_range(-wander_range, wander_range)
        )
    
    npc.move_towards(npc.target_position, delta)

static func update_guard(npc: NPC, delta: float) -> void:
    # Guard behavior (patrols small area, watches for threats)
    update_patrol(npc, delta)
    # Additional guard logic (detect enemies, etc.)

static func update_flee(npc: NPC, delta: float) -> void:
    # Flee from player/enemies
    var player = get_tree().get_first_node_in_group("player")
    if player:
        var direction = (npc.global_position - player.global_position).normalized()
        npc.target_position = npc.global_position + direction * 64.0
        npc.move_towards(npc.target_position, delta)
```

---

## System Architecture

### Component Hierarchy

```
NPCManager (Autoload Singleton)
├── NPCBehavior (utility)
├── NPC (instances in world)
│   ├── NPCInteractable (extends InteractableObject)
│   ├── DetectionArea (Area2D)
│   └── Sprite2D
└── NPCState (data)
```

### Data Flow

1. **NPC Spawning:**
   - World generation → Spawn NPCs at designated locations
   - `NPCManager.spawn_npc()` called → Creates NPC scene node
   - NPC initialized → Sets up components and state
   - NPC registered → Added to active_npcs

2. **NPC Behavior:**
   - Each frame → `NPCManager.update_nearby_npcs()` called
   - For each nearby NPC → `NPCBehavior.update_behavior()` called
   - Behavior updates movement → NPC moves according to behavior type
   - State updated → NPC state reflects current behavior

3. **NPC Interaction:**
   - Player interacts → `NPCInteractable.interact()` called
   - Get dialogue ID → `NPC.get_dialogue_id()` called
   - Start dialogue → `DialogueManager.start_dialogue()` called
   - Show quest UI → If NPC can give quests

4. **NPC Quest Giving:**
   - Player interacts → Check available quests
   - Show quest UI → Display available quests
   - Player accepts → `NPC.give_quest()` called
   - Quest started → `QuestManager.start_quest()` called

---

## Algorithms

### NPC Spawning Algorithm

```gdscript
func spawn_npc(npc_id: String, position: Vector2) -> NPC:
    if not npc_registry.has(npc_id):
        push_error("NPCManager: NPC not found: " + npc_id)
        return null
    
    # Get NPC data
    var npc_data = npc_registry[npc_id]
    
    # Create NPC scene
    var npc_scene = preload("res://scenes/npc/NPC.tscn")
    var npc = npc_scene.instantiate() as NPC
    npc.npc_id = npc_id
    npc.npc_data = npc_data
    npc.global_position = position
    
    # Initialize NPC
    npc.initialize(npc_data)
    
    # Create NPC state
    var npc_state = NPCState.new()
    npc_state.npc_id = npc_id
    npc_state.current_position = position
    npc_state.current_behavior = npc_data.behavior_type
    npc.current_state = npc_state
    
    # Register NPC
    active_npcs[npc_id] = npc
    npc_states[npc_id] = npc_state
    
    # Add to scene
    get_tree().current_scene.add_child(npc)
    
    emit_signal("npc_spawned", npc_id, npc)
    return npc
```

### Get Dialogue ID Algorithm

```gdscript
func get_dialogue_id() -> String:
    if not npc_data:
        return ""
    
    # Check for quest-specific dialogue
    if npc_data.npc_type == NPCData.NPCType.QUEST_GIVER and QuestManager:
        # Check if player has completed quests
        for quest_id in npc_data.available_quests:
            if QuestManager.completed_quests.has(quest_id):
                var dialogue_key = "quest_completed_" + quest_id
                if npc_data.dialogue_ids.has(dialogue_key):
                    return npc_data.dialogue_ids[dialogue_key]
        
        # Check if player has active quests
        for quest_id in npc_data.available_quests:
            if QuestManager.active_quests.has(quest_id):
                var dialogue_key = "quest_active_" + quest_id
                if npc_data.dialogue_ids.has(dialogue_key):
                    return npc_data.dialogue_ids[dialogue_key]
    
    # Check for state-based dialogue
    if npc_data.dialogue_ids.has("first_meeting"):
        if not current_state.state_data.get("met_before", false):
            current_state.state_data["met_before"] = true
            return npc_data.dialogue_ids["first_meeting"]
    
    # Return default dialogue
    return npc_data.default_dialogue_id
```

### Give Quest Algorithm

```gdscript
func give_quest(quest_id: String) -> bool:
    if not can_give_quest(quest_id):
        return false
    
    # Start quest (via QuestManager)
    if QuestManager and QuestManager.start_quest(quest_id):
        # Track quest given
        current_state.quests_given.append(quest_id)
        
        # Update dialogue
        if npc_data.dialogue_ids.has("quest_given_" + quest_id):
            current_state.current_dialogue_id = npc_data.dialogue_ids["quest_given_" + quest_id]
        
        emit_signal("npc_quest_given", self, quest_id)
        if NPCManager:
            NPCManager.emit_signal("npc_quest_given", npc_id, quest_id)
        
        return true
    
    return false

func can_give_quest(quest_id: String) -> bool:
    if not npc_data:
        return false
    
    # Check if NPC has this quest
    if not quest_id in npc_data.available_quests:
        return false
    
    # Check if already given
    if quest_id in current_state.quests_given:
        return false
    
    # Check quest prerequisites (via QuestManager)
    if QuestManager:
        var quest = QuestManager.available_quests.get(quest_id)
        if quest:
            # Check prerequisites
            for prereq_id in quest.prerequisite_quests:
                if not QuestManager.completed_quests.has(prereq_id):
                    return false
    
    return true
```

### NPC Movement Algorithm

```gdscript
func move_towards(target: Vector2, delta: float) -> void:
    var direction = (target - global_position).normalized()
    var distance = global_position.distance_to(target)
    
    # Move towards target
    var move_distance = npc_data.movement_speed * delta
    if move_distance > distance:
        # Reached target
        global_position = target
        velocity = Vector2.ZERO
    else:
        # Move towards target
        velocity = direction * npc_data.movement_speed
        move_and_slide()
```

---

## Integration Points

### Interaction System

**Usage:**
- NPCs use `NPCInteractable` (extends `InteractableObject`)
- NPC interactions trigger dialogue and quest UI
- Interaction range and validation handled by interaction system

**Example:**
```gdscript
# NPCInteractable extends InteractableObject
func interact(player: Node2D) -> InteractionResult:
    var result = InteractionResult.new()
    result.success = true
    
    # Get dialogue ID
    var dialogue_id = npc.get_dialogue_id()
    if not dialogue_id.is_empty():
        DialogueManager.start_dialogue(dialogue_id, npc.npc_id)
        result.data["dialogue_started"] = true
    
    # Show quest UI if applicable
    if npc.npc_data.npc_type == NPCData.NPCType.QUEST_GIVER:
        QuestManager.show_quest_giver_ui(npc.npc_id)
        result.data["quest_ui_opened"] = true
    
    return result
```

### Dialogue System

**Usage:**
- NPCs have dialogue IDs
- Dialogue system uses NPC data for speaker information
- Dialogue can check NPC state

**Example:**
```gdscript
# In DialogueManager
func start_dialogue(dialogue_id: String, npc_id: String = "") -> void:
    # ... start dialogue ...
    
    # Get NPC data for speaker info
    if not npc_id.is_empty():
        var npc_data = NPCManager.get_npc_data(npc_id)
        if npc_data:
            dialogue_ui.update_speaker_name(npc_data.npc_name)
            dialogue_ui.update_portrait(npc_data.portrait)
```

### Quest System

**Usage:**
- NPCs can give quests
- Quest completion affects NPC dialogue
- NPCs track quest state

**Example:**
```gdscript
# In QuestManager
func on_quest_completed(quest_id: String) -> void:
    # Notify NPCs
    for npc_id in NPCManager.active_npcs:
        var npc = NPCManager.get_npc(npc_id)
        if npc and quest_id in npc.npc_data.available_quests:
            npc.on_quest_completed(quest_id)
```

### World Generation

**Usage:**
- NPCs spawn during world generation
- NPCs placed at designated locations (towns, structures)
- NPC spawning integrated with structure placement

**Example:**
```gdscript
# In WorldGenerator
func spawn_structure(structure_data: StructureData) -> void:
    # ... spawn structure ...
    
    # Spawn NPCs in structure
    if structure_data.has_npcs:
        for npc_spawn in structure_data.npc_spawns:
            NPCManager.spawn_npc(npc_spawn.npc_id, npc_spawn.position)
```

---

## Save/Load System

### NPC Save

**Save Format:**
```gdscript
{
    "npcs": {
        "npc_001": {
            "npc_id": "npc_001",
            "position": {"x": 100, "y": 200},
            "current_dialogue_id": "dialogue_001",
            "quests_given": ["quest_001"],
            "quests_completed": [],
            "state_data": {
                "met_before": true,
                "reputation": 10
            }
        }
    }
}
```

**Load Format:**
```gdscript
func load_npc_states(save_data: Dictionary) -> void:
    if save_data.has("npcs"):
        for npc_id in save_data.npcs:
            var npc_data = save_data.npcs[npc_id]
            
            # Get or spawn NPC
            var npc = get_npc(npc_id)
            if npc == null:
                # Spawn NPC at saved position
                var position = Vector2(npc_data.position.x, npc_data.position.y)
                npc = spawn_npc(npc_id, position)
            
            # Restore state
            if npc:
                npc.current_state.current_dialogue_id = npc_data.get("current_dialogue_id", "")
                npc.current_state.quests_given = npc_data.get("quests_given", [])
                npc.current_state.quests_completed = npc_data.get("quests_completed", [])
                npc.current_state.state_data = npc_data.get("state_data", {})
                npc.current_state.current_position = Vector2(npc_data.position.x, npc_data.position.y)
```

---

## Performance Considerations

### Optimization Strategies

1. **Distance-Based Updates:**
   - Only update NPCs within update distance
   - Despawn NPCs beyond despawn distance
   - Use spatial partitioning for NPC lookup

2. **Behavior Updates:**
   - Update behaviors less frequently (every 0.1s instead of every frame)
   - Skip behavior updates for static NPCs

3. **Pathfinding:**
   - Use simple pathfinding for NPCs (A* if needed)
   - Cache pathfinding results
   - Limit pathfinding to nearby NPCs

4. **State Management:**
   - Only save state for NPCs that have changed
   - Batch state updates

---

## Testing Checklist

### NPC Spawning
- [ ] NPCs spawn correctly
- [ ] NPCs initialize correctly
- [ ] NPCs register correctly
- [ ] NPCs despawn correctly

### NPC Behavior
- [ ] Static NPCs don't move
- [ ] Patrol NPCs follow patrol path
- [ ] Wander NPCs move randomly
- [ ] Guard NPCs guard area correctly
- [ ] Flee NPCs flee correctly

### NPC Interaction
- [ ] NPC interactions work correctly
- [ ] Dialogue starts correctly
- [ ] Quest UI shows correctly
- [ ] NPC state updates correctly

### NPC Quest Giving
- [ ] NPCs can give quests
- [ ] Quest prerequisites checked correctly
- [ ] Quest state tracked correctly
- [ ] Dialogue updates after quest completion

### Integration
- [ ] Works with interaction system
- [ ] Works with dialogue system
- [ ] Works with quest system
- [ ] Works with world generation
- [ ] Save/load works correctly

---

## Error Handling

### NPCManager Error Handling

- **Missing NPC Data:** Handle missing NPC IDs gracefully, return errors
- **Invalid NPC References:** Validate NPC references before operations
- **Missing System References:** Handle missing managers (QuestManager, DialogueManager) gracefully
- **NPC Spawning Errors:** Handle spawning failures gracefully

### Best Practices

- Use `push_error()` for critical errors (missing NPC data, invalid references)
- Use `push_warning()` for non-critical issues (missing managers, failed quest giving)
- Return false/null on errors (don't crash)
- Validate all data before operations
- Handle missing system managers gracefully

---

## Default Values and Configuration

### NPCManager Defaults

```gdscript
npc_update_distance = 512.0
npc_despawn_distance = 1024.0
```

### NPCData Defaults

```gdscript
npc_id = ""
npc_name = ""
npc_type = NPCType.CIVILIAN
sprite = null
portrait = null
size = Vector2(16, 16)
default_dialogue_id = ""
dialogue_ids = {}
available_quests = []
completed_quest_dialogue_id = ""
behavior_type = BehaviorType.STATIC
movement_speed = 50.0
patrol_path = []
idle_time = 2.0
detection_range = 128.0
is_friendly = true
health = 100.0
max_health = 100.0
reputation = 0
description = ""
tags = []
```

### NPCState Defaults

```gdscript
npc_id = ""
current_position = Vector2.ZERO
current_behavior = NPCData.BehaviorType.STATIC
current_dialogue_id = ""
quests_given = []
quests_completed = []
last_interaction_time = 0.0
state_data = {}
```

---

## Complete Implementation

### NPCManager Complete Implementation

```gdscript
class_name NPCManager
extends Node

# References
var dialogue_manager: Node = null
var quest_manager: Node = null
var interaction_manager: Node = null
var world_generator: Node = null

# NPC Registry
var npc_registry: Dictionary = {}
var active_npcs: Dictionary = {}
var npc_states: Dictionary = {}

# Settings
var npc_update_distance: float = 512.0
var npc_despawn_distance: float = 1024.0

# Signals
signal npc_spawned(npc_id: String, npc: NPC)
signal npc_despawned(npc_id: String)
signal npc_interacted(npc_id: String, player: Node2D)
signal npc_quest_given(npc_id: String, quest_id: String)

func _ready() -> void:
    # Find managers
    dialogue_manager = get_node_or_null("/root/DialogueManager")
    quest_manager = get_node_or_null("/root/QuestManager")
    interaction_manager = get_node_or_null("/root/InteractionManager")
    world_generator = get_node_or_null("/root/WorldGenerator")
    
    # Load NPC data
    load_npc_data()
    
    # Subscribe to quest completion signals
    if quest_manager:
        quest_manager.quest_completed.connect(_on_quest_completed)

func _process(delta: float) -> void:
    # Update nearby NPCs
    var player = get_tree().get_first_node_in_group("player")
    if player:
        update_nearby_npcs(player.global_position)

func load_npc_data() -> void:
    var npc_dir = DirAccess.open("res://resources/npcs/")
    if npc_dir:
        npc_dir.list_dir_begin()
        var file_name = npc_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var npc_data = load("res://resources/npcs/" + file_name) as NPCData
                if npc_data:
                    register_npc(npc_data)
            file_name = npc_dir.get_next()

func register_npc(npc_data: NPCData) -> void:
    if npc_data:
        npc_registry[npc_data.npc_id] = npc_data

func spawn_npc(npc_id: String, position: Vector2) -> NPC:
    if not npc_registry.has(npc_id):
        push_error("NPCManager: NPC not found: " + npc_id)
        return null
    
    var npc_data = npc_registry[npc_id]
    
    var npc_scene = preload("res://scenes/npc/NPC.tscn")
    var npc = npc_scene.instantiate() as NPC
    if not npc:
        push_error("NPCManager: Failed to instantiate NPC scene")
        return null
    
    npc.npc_id = npc_id
    npc.npc_data = npc_data
    npc.global_position = position
    
    npc.initialize(npc_data)
    
    var npc_state = NPCState.new()
    npc_state.npc_id = npc_id
    npc_state.current_position = position
    npc_state.current_behavior = npc_data.behavior_type
    npc.current_state = npc_state
    
    active_npcs[npc_id] = npc
    npc_states[npc_id] = npc_state
    
    get_tree().current_scene.add_child(npc)
    
    npc_spawned.emit(npc_id, npc)
    return npc

func despawn_npc(npc_id: String) -> void:
    var npc = active_npcs.get(npc_id)
    if npc:
        npc.queue_free()
        active_npcs.erase(npc_id)
        npc_despawned.emit(npc_id)

func get_npc(npc_id: String) -> NPC:
    return active_npcs.get(npc_id)

func get_npc_data(npc_id: String) -> NPCData:
    return npc_registry.get(npc_id)

func get_npc_state(npc_id: String) -> NPCState:
    return npc_states.get(npc_id)

func update_nearby_npcs(player_position: Vector2) -> void:
    for npc_id in active_npcs:
        var npc = active_npcs[npc_id]
        if not npc:
            continue
        
        var distance = player_position.distance_to(npc.global_position)
        
        # Update behavior if within range
        if distance <= npc_update_distance:
            NPCBehavior.update_behavior(npc, get_process_delta_time())
        
        # Despawn if too far
        if distance > npc_despawn_distance:
            despawn_npc(npc_id)

func get_npcs_in_range(position: Vector2, range: float) -> Array[NPC]:
    var npcs: Array[NPC] = []
    for npc_id in active_npcs:
        var npc = active_npcs[npc_id]
        if npc:
            var distance = position.distance_to(npc.global_position)
            if distance <= range:
                npcs.append(npc)
    return npcs

func save_npc_states() -> Dictionary:
    var save_data = {
        "npcs": {}
    }
    
    for npc_id in npc_states:
        var npc_state = npc_states[npc_id]
        var npc = active_npcs.get(npc_id)
        
        save_data["npcs"][npc_id] = {
            "npc_id": npc_id,
            "position": {
                "x": npc.global_position.x if npc else npc_state.current_position.x,
                "y": npc.global_position.y if npc else npc_state.current_position.y
            },
            "current_dialogue_id": npc_state.current_dialogue_id,
            "quests_given": npc_state.quests_given,
            "quests_completed": npc_state.quests_completed,
            "state_data": npc_state.state_data
        }
    
    return save_data

func load_npc_states(save_data: Dictionary) -> void:
    if save_data.has("npcs"):
        for npc_id in save_data["npcs"]:
            var npc_data = save_data["npcs"][npc_id]
            
            var npc = get_npc(npc_id)
            if npc == null:
                var position = Vector2(npc_data["position"]["x"], npc_data["position"]["y"])
                npc = spawn_npc(npc_id, position)
            
            if npc:
                npc.current_state.current_dialogue_id = npc_data.get("current_dialogue_id", "")
                npc.current_state.quests_given = npc_data.get("quests_given", [])
                npc.current_state.quests_completed = npc_data.get("quests_completed", [])
                npc.current_state.state_data = npc_data.get("state_data", {})
                npc.current_state.current_position = Vector2(npc_data["position"]["x"], npc_data["position"]["y"])

func _on_quest_completed(quest: QuestData) -> void:
    # Notify NPCs that quest was completed
    for npc_id in active_npcs:
        var npc = active_npcs[npc_id]
        if npc:
            npc.on_quest_completed(quest.quest_id)
```

### NPC Complete Implementation

```gdscript
class_name NPC
extends CharacterBody2D

# Data
@export var npc_data: NPCData = null
@export var npc_id: String = ""

# State
var current_state: NPCState = null
var current_behavior_state: String = "idle"
var current_patrol_index: int = 0
var patrol_timer: float = 0.0
var target_position: Vector2 = Vector2.ZERO
var is_interacting: bool = false

# Components
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interactable: NPCInteractable = $Interactable
@onready var detection_area: Area2D = $DetectionArea

# Signals
signal npc_interacted(npc: NPC, player: Node2D)
signal npc_quest_given(npc: NPC, quest_id: String)
signal npc_state_changed(npc: NPC, new_state: String)

func _ready() -> void:
    if npc_data:
        initialize(npc_data)

func _physics_process(delta: float) -> void:
    # Apply movement
    move_and_slide()

func initialize(data: NPCData) -> void:
    npc_data = data
    
    # Setup sprite
    if sprite and npc_data.sprite:
        sprite.texture = npc_data.sprite
    
    # Setup collision
    if collision_shape:
        var shape = RectangleShape2D.new()
        shape.size = npc_data.size
        collision_shape.shape = shape
    
    # Setup interactable
    if interactable:
        interactable.object_id = npc_id
        interactable.interaction_type = InteractionType.NPC_TALK
        interactable.interaction_name = npc_data.npc_name
        interactable.npc_id = npc_id
    
    # Setup detection area
    if detection_area:
        var detection_shape = CollisionShape2D.new()
        var circle_shape = CircleShape2D.new()
        circle_shape.radius = npc_data.detection_range
        detection_shape.shape = circle_shape
        detection_area.add_child(detection_shape)

func update_behavior(delta: float) -> void:
    if not npc_data:
        return
    
    NPCBehavior.update_behavior(self, delta)

func move_towards(target: Vector2, delta: float) -> void:
    var direction = (target - global_position).normalized()
    var distance = global_position.distance_to(target)
    
    var move_distance = npc_data.movement_speed * delta
    if move_distance > distance:
        global_position = target
        velocity = Vector2.ZERO
    else:
        velocity = direction * npc_data.movement_speed

func get_dialogue_id() -> String:
    if not npc_data:
        return ""
    
    if npc_data.npc_type == NPCData.NPCType.QUEST_GIVER and QuestManager:
        for quest_id in npc_data.available_quests:
            if QuestManager.completed_quests.has(quest_id):
                var dialogue_key = "quest_completed_" + quest_id
                if npc_data.dialogue_ids.has(dialogue_key):
                    return npc_data.dialogue_ids[dialogue_key]
        
        for quest_id in npc_data.available_quests:
            if QuestManager.active_quests.has(quest_id):
                var dialogue_key = "quest_active_" + quest_id
                if npc_data.dialogue_ids.has(dialogue_key):
                    return npc_data.dialogue_ids[dialogue_key]
    
    if npc_data.dialogue_ids.has("first_meeting"):
        if not current_state.state_data.get("met_before", false):
            current_state.state_data["met_before"] = true
            return npc_data.dialogue_ids["first_meeting"]
    
    return npc_data.default_dialogue_id

func can_give_quest(quest_id: String) -> bool:
    if not npc_data:
        return false
    
    if not quest_id in npc_data.available_quests:
        return false
    
    if quest_id in current_state.quests_given:
        return false
    
    if QuestManager:
        var quest = QuestManager.available_quests.get(quest_id)
        if quest:
            for prereq_id in quest.prerequisite_quests:
                if not QuestManager.completed_quests.has(prereq_id):
                    return false
    
    return true

func give_quest(quest_id: String) -> bool:
    if not can_give_quest(quest_id):
        return false
    
    if QuestManager and QuestManager.start_quest(quest_id):
        current_state.quests_given.append(quest_id)
        
        if npc_data.dialogue_ids.has("quest_given_" + quest_id):
            current_state.current_dialogue_id = npc_data.dialogue_ids["quest_given_" + quest_id]
        
        npc_quest_given.emit(self, quest_id)
        if NPCManager:
            NPCManager.emit_signal("npc_quest_given", npc_id, quest_id)
        
        return true
    
    return false

func on_quest_completed(quest_id: String) -> void:
    if quest_id in current_state.quests_given:
        current_state.quests_completed.append(quest_id)
        
        if npc_data.dialogue_ids.has("quest_completed_" + quest_id):
            current_state.current_dialogue_id = npc_data.dialogue_ids["quest_completed_" + quest_id]

func update_visual() -> void:
    if sprite and npc_data:
        sprite.texture = npc_data.sprite
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── NPCManager.gd
   └── scripts/
       └── npc/
           ├── NPC.gd
           └── NPCBehavior.gd
   └── scenes/
       └── npc/
           └── NPC.tscn
   └── resources/
       └── npcs/
           ├── npc_001.tres
           └── npc_002.tres
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/NPCManager.gd` as `NPCManager`
   - **Important:** Load after DialogueManager, QuestManager, and InteractionManager

3. **Create NPC Data:**
   - Create NPCData resources for each NPC
   - Configure NPC properties (name, type, behavior, dialogue, quests)
   - Save as `.tres` files in `res://resources/npcs/`

4. **Create NPC Scene:**
   - Create NPC scene with CharacterBody2D, Sprite2D, CollisionShape2D, NPCInteractable, and DetectionArea
   - Configure scene structure
   - Save as `res://scenes/npc/NPC.tscn`

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. DialogueManager, QuestManager, InteractionManager
4. **NPCManager** (after systems that NPCs depend on)

### System Integration

**NPCs Must:**
- Extend NPC class (CharacterBody2D)
- Have NPCData resource assigned
- Have NPCInteractable component
- Be registered with NPCManager

**NPCs Subscribe To:**
- QuestManager.quest_completed signal (for quest completion handling)

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing NPC System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **CharacterBody2D:** https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Area2D:** https://docs.godotengine.org/en/stable/classes/class_area2d.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing NPC System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [CharacterBody2D Documentation](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) - Physics-based movement
- [Signals Tutorial](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Detection areas

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- NPCData is a Resource (can be created/edited in inspector)
- NPC is a CharacterBody2D (can be added to scene tree)
- NPC properties configured via @export variables (editable in inspector)

**Visual Configuration:**
- NPC data editable in inspector
- NPC scene editable in editor
- Behavior properties configurable in inspector

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - NPC spawner tool (visual placement)
  - Patrol path editor
  - NPC behavior tester

**Current Approach:**
- Uses Godot's native CharacterBody2D and Resource systems (no custom tools needed)
- NPCs created as scenes (editable in editor)
- NPC data configured via resources (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

### NPC Scene Structure

**Recommended Structure:**
```
NPC (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── NPCInteractable (InteractableObject)
│   └── CollisionShape2D
├── DetectionArea (Area2D)
│   └── CollisionShape2D
└── AnimationPlayer (optional)
```

### NPC Registration

**Method:** Register NPCs in `NPCManager`

**Example:**
```gdscript
# In NPCManager._ready()
var npc_data = NPCData.new()
npc_data.npc_id = "merchant_001"
npc_data.npc_name = "Merchant"
npc_data.npc_type = NPCData.NPCType.MERCHANT
npc_data.default_dialogue_id = "merchant_greeting"
npc_data.behavior_type = NPCData.BehaviorType.STATIC
register_npc(npc_data)
```

---

## Future Enhancements

### Potential Additions

1. **NPC Combat:**
   - NPCs can fight enemies
   - NPCs can help player in combat

2. **NPC Relationships:**
   - Relationship system with player
   - NPCs remember player actions

3. **NPC Schedules:**
   - Day/night schedules
   - NPCs move to different locations

4. **NPC Trading:**
   - NPCs can buy/sell items
   - Dynamic pricing

5. **NPC AI:**
   - More complex behaviors
   - NPC-to-NPC interactions

---

## Dependencies

### Required Systems
- Interaction System
- Dialogue System
- Quest System
- World Generation System

### Systems That Depend on This
- Quest System (NPC quest givers)
- Dialogue System (NPC dialogue)

---

## Notes

- NPC system is essential for quests and world interaction
- NPC behaviors should be simple but effective
- NPC state management ensures persistent interactions
- Integration with other systems makes NPCs meaningful
- NPC system supports various NPC types and behaviors

