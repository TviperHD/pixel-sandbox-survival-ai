# Technical Specifications: Interaction System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the unified interaction system that handles player interactions with NPCs, containers, resource nodes, building pieces, environmental objects, and other interactable entities. Provides interaction detection, prompts, validation, and feedback. This system integrates with all game systems for interaction handling.

---

## Research Notes

### Interaction System Architecture Best Practices

**Research Findings:**
- Unified interaction system simplifies interaction handling
- Area2D nodes detect player proximity efficiently
- Signal-based communication keeps systems decoupled
- Interaction prompts improve UX (show what can be interacted with)
- Validation prevents invalid interactions

**Sources:**
- [Godot 4 Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Area detection
- [Godot 4 Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Godot 4 Input System](https://docs.godotengine.org/en/stable/tutorials/inputs/index.html) - Input handling
- General interaction system design patterns

**Implementation Approach:**
- InteractionManager as autoload singleton
- InteractableObject base class (Area2D) for all interactables
- Area2D body_entered/body_exited for detection
- Signal-based communication for interaction events
- InteractionValidator for validation logic
- Visual prompts for interaction feedback

**Why This Approach:**
- Singleton: centralized interaction management
- Area2D: efficient proximity detection
- Base class: consistent interaction interface
- Signals: decoupled system communication
- Validator: reusable validation logic
- Prompts: clear user feedback

### Interaction Detection Best Practices

**Research Findings:**
- Area2D provides efficient proximity detection
- Distance-based sorting finds closest interactable
- Range checking prevents interactions from too far away
- Multiple interactables handled via priority/closest

**Sources:**
- [Godot 4 Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html)
- General proximity detection patterns

**Implementation Approach:**
- Area2D with CollisionShape2D for detection range
- body_entered/body_exited signals for player proximity
- Distance calculation for closest interactable
- Range validation before interaction

**Why This Approach:**
- Area2D: built-in proximity detection
- Signals: efficient event handling
- Distance: accurate closest detection
- Range: prevents invalid interactions

### Interaction Validation Best Practices

**Research Findings:**
- Multiple validation checks (range, items, quests, cooldown)
- Clear error messages for failed validations
- Reusable validation logic via static methods
- Validation prevents invalid interactions

**Sources:**
- General validation patterns

**Implementation Approach:**
- InteractionValidator static class
- Multiple validation checks (range, items, quests, cooldown, one-time)
- Clear reason messages for failures
- Integration with InventoryManager, QuestManager

**Why This Approach:**
- Static class: reusable validation logic
- Multiple checks: comprehensive validation
- Clear messages: better UX
- Integration: uses existing systems

### Interaction Prompts Best Practices

**Research Findings:**
- Visual prompts improve UX (show what can be interacted with)
- Prompts positioned above interactable objects
- Dynamic prompts based on interaction type
- Hide/show prompts based on proximity

**Sources:**
- General UI/UX best practices

**Implementation Approach:**
- InteractionPrompt resource for prompt data
- Visual prompt UI element
- Position above interactable (offset)
- Show/hide based on proximity

**Why This Approach:**
- Visual feedback: clear user guidance
- Positioned prompts: easy to see
- Dynamic: adapts to interaction type
- Proximity-based: only shows when relevant

---

## Data Structures

### InteractionType

```gdscript
enum InteractionType {
    NPC_TALK,           # Talk to NPC
    NPC_TRADE,          # Trade with NPC
    NPC_QUEST,          # Accept/turn in quest
    CONTAINER_OPEN,     # Open storage container
    RESOURCE_GATHER,    # Gather from resource node
    BUILDING_INTERACT,  # Interact with placed building
    DOOR_OPEN_CLOSE,    # Open/close door
    CRAFTING_STATION,   # Use crafting station
    ENVIRONMENTAL,      # Environmental interaction (buttons, levers, etc.)
    ITEM_PICKUP,        # Pick up item from ground
    CUSTOM              # Custom interaction type
}
```

### InteractionPrompt

```gdscript
class_name InteractionPrompt
extends Resource

var interaction_type: InteractionType
var prompt_text: String  # "Press E to interact"
var action_text: String  # "Open", "Talk", "Gather", etc.
var icon: Texture2D = null
var is_available: bool = true
var unavailable_reason: String = ""
```

### InteractableObject (Base Class)

```gdscript
class_name InteractableObject
extends Area2D

# Identification
@export var object_id: String
@export var interaction_type: InteractionType
@export var interaction_name: String  # Display name

# Interaction Properties
@export var interaction_range: float = 64.0  # Detection range (pixels)
@export var requires_item: String = ""  # Item ID required to interact (empty = none)
@export var requires_quest: String = ""  # Quest ID required (empty = none)
@export var is_one_time: bool = false  # Can only interact once
@export var cooldown_time: float = 0.0  # Cooldown between interactions (seconds)

# State
var has_interacted: bool = false
var last_interaction_time: float = 0.0
var is_player_in_range: bool = false
var current_player: Node2D = null

# Components
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var prompt_marker: Node2D = $PromptMarker  # Visual marker for interaction

# Signals
signal interaction_started(object: InteractableObject, player: Node2D)
signal interaction_completed(object: InteractableObject, player: Node2D)
signal player_entered_range(player: Node2D)
signal player_exited_range(player: Node2D)

# Functions
func _ready() -> void
func _process(delta: float) -> void
func _on_body_entered(body: Node2D) -> void
func _on_body_exited(body: Node2D) -> void
func can_interact(player: Node2D) -> bool
func interact(player: Node2D) -> void
func get_interaction_prompt() -> InteractionPrompt
func show_prompt() -> void
func hide_prompt() -> void
func update_prompt_position() -> void
```

### InteractionResult

```gdscript
class_name InteractionResult
extends Resource

var success: bool = false
var message: String = ""
var data: Dictionary = {}  # Additional data (items received, quest started, etc.)
var should_close_ui: bool = false
```

---

## Core Classes

### InteractionManager (Autoload Singleton)

```gdscript
class_name InteractionManager
extends Node

# References
@export var player: Node2D
@export var ui_manager: UIManager

# Interaction State
var nearby_interactables: Array[InteractableObject] = []
var current_interactable: InteractableObject = null
var interaction_prompt_ui: Control = null
var is_interacting: bool = false

# Settings
@export var default_interaction_key: String = "interact"  # InputMap action
@export var show_prompts: bool = true
@export var prompt_offset: Vector2 = Vector2(0, -32)  # Offset above object

# Signals
signal interaction_detected(interactable: InteractableObject)
signal interaction_lost(interactable: InteractableObject)
signal interaction_started(interactable: InteractableObject)
signal interaction_completed(interactable: InteractableObject, result: InteractionResult)

# Functions
func _ready() -> void
func _process(delta: float) -> void
func _input(event: InputEvent) -> void
func register_interactable(interactable: InteractableObject) -> void
func unregister_interactable(interactable: InteractableObject) -> void
func find_nearby_interactables(player_position: Vector2, range: float = 128.0) -> Array[InteractableObject]
func get_closest_interactable(player_position: Vector2) -> InteractableObject
func start_interaction(interactable: InteractableObject) -> InteractionResult
func can_interact_with(interactable: InteractableObject) -> bool
func update_interaction_prompt() -> void
func show_interaction_prompt(interactable: InteractableObject) -> void
func hide_interaction_prompt() -> void
```

### InteractionValidator

```gdscript
class_name InteractionValidator
extends RefCounted

static func validate_interaction(interactable: InteractableObject, player: Node2D) -> Dictionary:
    var result: Dictionary = {
        "can_interact": false,
        "reason": ""
    }
    
    # Check if already interacted (one-time interactions)
    if interactable.is_one_time and interactable.has_interacted:
        result.reason = "Already interacted"
        return result
    
    # Check cooldown
    var current_time = Time.get_ticks_msec() / 1000.0
    if current_time - interactable.last_interaction_time < interactable.cooldown_time:
        result.reason = "On cooldown"
        return result
    
    # Check required item (via InventoryManager)
    if not interactable.requires_item.is_empty():
        if InventoryManager:
            if InventoryManager.get_item_count(interactable.requires_item) == 0:
                result.reason = "Required item missing: " + interactable.requires_item
                return result
        else:
            result.reason = "Inventory system not available"
            return result
    
    # Check required quest (via QuestManager)
    if not interactable.requires_quest.is_empty():
        if QuestManager:
            if not QuestManager.active_quests.has(interactable.requires_quest):
                result.reason = "Required quest not active"
                return result
        else:
            result.reason = "Quest system not available"
            return result
    
    # Check range
    var distance = interactable.global_position.distance_to(player.global_position)
    if distance > interactable.interaction_range:
        result.reason = "Too far away"
        return result
    
    result.can_interact = true
    return result
```

---

## System Architecture

### Component Hierarchy

```
InteractionManager (Autoload Singleton)
├── InteractionValidator (static utility)
├── InteractionPromptUI (UI element)
└── InteractableObject (instances in world)
    ├── NPCInteractable (extends InteractableObject)
    ├── ContainerInteractable (extends InteractableObject)
    ├── ResourceNodeInteractable (extends InteractableObject)
    ├── BuildingInteractable (extends InteractableObject)
    └── EnvironmentalInteractable (extends InteractableObject)
```

### Data Flow

1. **Interaction Detection:**
   - Player moves near interactable → `InteractableObject._on_body_entered()` called
   - Interactable registers with `InteractionManager`
   - `InteractionManager` finds closest interactable → Shows prompt
   - Player presses interact key → `InteractionManager.start_interaction()` called

2. **Interaction Validation:**
   - `InteractionValidator.validate_interaction()` checks:
     - Range
     - Required items
     - Required quests
     - Cooldown
     - One-time restrictions
   - If valid → Proceed with interaction
   - If invalid → Show reason, don't interact

3. **Interaction Execution:**
   - `InteractableObject.interact()` called
   - Specific interaction logic executed (NPC dialogue, container open, resource gather, etc.)
   - `InteractionResult` returned
   - UI updated based on result
   - Signals emitted

4. **Interaction Completion:**
   - Interaction finished → `interaction_completed` signal emitted
   - UI closed (if applicable)
   - Cooldown started
   - State updated

---

## Algorithms

### Find Nearby Interactables Algorithm

```gdscript
func find_nearby_interactables(player_position: Vector2, range: float = 128.0) -> Array[InteractableObject]:
    var nearby: Array[InteractableObject] = []
    
    # Get all registered interactables
    var all_interactables = get_tree().get_nodes_in_group("interactables")
    
    for node in all_interactables:
        if not node is InteractableObject:
            continue
        
        var interactable = node as InteractableObject
        var distance = player_position.distance_to(interactable.global_position)
        
        if distance <= range:
            nearby.append(interactable)
    
    # Sort by distance (closest first)
    nearby.sort_custom(func(a, b): return player_position.distance_to(a.global_position) < player_position.distance_to(b.global_position))
    
    return nearby
```

### Get Closest Interactable Algorithm

```gdscript
func get_closest_interactable(player_position: Vector2) -> InteractableObject:
    var nearby = find_nearby_interactables(player_position)
    
    if nearby.is_empty():
        return null
    
    # Return closest valid interactable
    for interactable in nearby:
        if can_interact_with(interactable):
            return interactable
    
    return null
```

### Start Interaction Algorithm

```gdscript
func start_interaction(interactable: InteractableObject) -> InteractionResult:
    if interactable == null:
        return InteractionResult.new()  # Empty result (failed)
    
    # Validate interaction
    var validation = InteractionValidator.validate_interaction(interactable, player)
    if not validation.can_interact:
        var result = InteractionResult.new()
        result.success = false
        result.message = validation.reason
        return result
    
    # Start interaction
    is_interacting = true
    current_interactable = interactable
    
    emit_signal("interaction_started", interactable)
    interactable.emit_signal("interaction_started", interactable, player)
    
    # Execute interaction
    var result = interactable.interact(player)
    
    # Update state
    interactable.has_interacted = true
    interactable.last_interaction_time = Time.get_ticks_msec() / 1000.0
    
    # Complete interaction
    is_interacting = false
    emit_signal("interaction_completed", interactable, result)
    interactable.emit_signal("interaction_completed", interactable, player)
    
    # Hide prompt
    hide_interaction_prompt()
    
    return result
```

---

## Specific Interaction Types

### NPC Interaction

```gdscript
class_name NPCInteractable
extends InteractableObject

@export var npc_id: String
@export var dialogue_id: String = ""
@export var can_trade: bool = false
@export var can_give_quests: bool = false

var npc_data: NPCData = null
var dialogue_manager: DialogueManager = null

func _ready() -> void:
    super._ready()
    interaction_type = InteractionType.NPC_TALK
    npc_data = NPCManager.get_npc(npc_id)
    dialogue_manager = DialogueManager

func interact(player: Node2D) -> InteractionResult:
    var result = InteractionResult.new()
    result.success = true
    
    # Start dialogue
    if not dialogue_id.is_empty():
        dialogue_manager.start_dialogue(dialogue_id, npc_id)
        result.data["dialogue_started"] = true
    
    # Show trade UI (if applicable)
    if can_trade:
        UIManager.open_trade_ui(npc_id)
        result.data["trade_opened"] = true
    
    # Show quest UI (if applicable)
    if can_give_quests:
        QuestManager.show_quest_giver_ui(npc_id)
        result.data["quest_ui_opened"] = true
    
    return result
```

### Container Interaction

```gdscript
class_name ContainerInteractable
extends InteractableObject

@export var container_id: String
@export var container_type: String = "chest"

var container_data: ContainerData = null

func _ready() -> void:
    super._ready()
    interaction_type = InteractionType.CONTAINER_OPEN
    container_data = ContainerManager.get_container(container_id)

func interact(player: Node2D) -> InteractionResult:
    var result = InteractionResult.new()
    result.success = true
    
    # Open container UI
    ContainerManager.open_container(container_id)
    result.data["container_opened"] = true
    
    return result
```

### Resource Node Interaction

```gdscript
class_name ResourceNodeInteractable
extends InteractableObject

@export var resource_type: String  # "ore", "tree", "plant", etc.
@export var resource_id: String
@export var required_tool: String = ""  # Tool ID required (empty = hand)
@export var gather_time: float = 1.0  # Time to gather (seconds)
@export var resources_per_gather: int = 1
@export var max_resources: int = 10
@export var respawn_time: float = 300.0  # Respawn time (seconds)

var current_resources: int = max_resources
var is_gathering: bool = false
var gather_timer: float = 0.0

func _ready() -> void:
    super._ready()
    interaction_type = InteractionType.RESOURCE_GATHER

func interact(player: Node2D) -> InteractionResult:
    var result = InteractionResult.new()
    
    # Check if node has resources
    if current_resources <= 0:
        result.success = false
        result.message = "Resource depleted"
        return result
    
    # Check required tool
    if not required_tool.is_empty():
        if not InventoryManager.has_item_equipped(required_tool):
            result.success = false
            result.message = "Required tool: " + required_tool
            return result
    
    # Start gathering
    is_gathering = true
    gather_timer = gather_time
    
    # Gather resources (called after gather_time)
    call_deferred("complete_gathering", player)
    
    result.success = true
    result.message = "Gathering..."
    return result

func complete_gathering(player: Node2D) -> void:
    if current_resources <= 0:
        return
    
    # Add resources to inventory
    var item_data = ItemDatabase.get_item(resource_id)
    if item_data:
        var gathered = InventoryManager.add_item_by_id(resource_id, resources_per_gather)
        current_resources -= gathered
    
    # Check if depleted
    if current_resources <= 0:
        # Start respawn timer
        get_tree().create_timer(respawn_time).timeout.connect(_on_respawn)
    
    is_gathering = false
    gather_timer = 0.0

func _on_respawn() -> void:
    current_resources = max_resources
```

### Building Interaction

```gdscript
class_name BuildingInteractable
extends InteractableObject

@export var building_id: String
@export var building_type: String  # "door", "crafting_station", "furniture", etc.

var building_data: PlacedBuilding = null

func _ready() -> void:
    super._ready()
    interaction_type = InteractionType.BUILDING_INTERACT
    building_data = BuildingManager.get_building(building_id)

func interact(player: Node2D) -> InteractionResult:
    var result = InteractionResult.new()
    result.success = true
    
    # Handle different building types
    match building_type:
        "door":
            # Toggle door open/close
            building_data.toggle_door()
            result.message = "Door toggled"
        
        "crafting_station":
            # Open crafting UI
            CraftingManager.open_crafting_station(building_id)
            result.data["crafting_opened"] = true
        
        "furniture":
            # Use furniture (rest, sit, etc.)
            building_data.use_furniture(player)
            result.message = "Using furniture"
    
    return result
```

---

## Integration Points

### Player Controller

**Usage:**
- Player controller calls `InteractionManager` to check for interactions
- Handles input for interaction key
- Updates interaction prompts based on player position

**Example:**
```gdscript
# In PlayerController
func _process(delta: float) -> void:
    # ... movement code ...
    
    # Check for interactions
    if Input.is_action_just_pressed("interact"):
        var closest = InteractionManager.get_closest_interactable(global_position)
        if closest:
            InteractionManager.start_interaction(closest)
```

### Inventory System

**Usage:**
- Container interactions open inventory UI
- Item pickup uses interaction system
- Required items checked before interaction

**Example:**
```gdscript
# Item pickup uses interaction
class_name ItemPickupInteractable
extends InteractableObject

@export var item_id: String
@export var quantity: int = 1

func interact(player: Node2D) -> InteractionResult:
    var result = InteractionResult.new()
    var added = InventoryManager.add_item_by_id(item_id, quantity)
    
    if added > 0:
        result.success = true
        result.message = "Picked up " + str(added) + "x " + ItemDatabase.get_item(item_id).item_name
        queue_free()  # Remove from world
    else:
        result.success = false
        result.message = "Inventory full"
    
    return result
```

### Quest System

**Usage:**
- Quest objectives use interaction system
- NPC interactions trigger quest dialogue
- Environmental triggers use interaction

**Example:**
```gdscript
# Quest objective interaction
func on_interaction_completed(interactable: InteractableObject, result: InteractionResult):
    if interactable.interaction_type == InteractionType.INTERACT_OBJECT:
        QuestManager.update_objective(ObjectiveType.INTERACT_OBJECT, {
            "object_id": interactable.object_id
        })
```

### Building System

**Usage:**
- Placed buildings become interactable
- Doors, crafting stations, furniture use interaction system

**Example:**
```gdscript
# In BuildingManager
func place_building(world_pos: Vector2) -> bool:
    # ... placement code ...
    
    # Create interactable if needed
    if piece.can_interact:
        var interactable = BuildingInteractable.new()
        interactable.building_id = placed_building.id
        interactable.building_type = piece.interaction_type
        interactable.global_position = world_pos
        add_child(interactable)
```

### Resource Gathering System

**Usage:**
- Resource nodes use interaction system
- Gathering mechanics integrated with interaction

**Example:**
```gdscript
# Resource gathering uses interaction
func gather_resource(node_id: String) -> void:
    var node = ResourceManager.get_node(node_id)
    if node:
        var interactable = node.get_node("Interactable") as ResourceNodeInteractable
        if interactable:
            InteractionManager.start_interaction(interactable)
```

---

## Save/Load System

### Interaction Save

**Save Format:**
```gdscript
{
    "interactables": {
        "npc_001": {
            "object_id": "npc_001",
            "has_interacted": false,
            "last_interaction_time": 0.0,
            "state": {}  # Custom state data
        },
        "resource_node_001": {
            "object_id": "resource_node_001",
            "current_resources": 5,
            "respawn_timer": 120.0
        }
    }
}
```

**Load Format:**
```gdscript
func load_interactable_state(save_data: Dictionary) -> void:
    for object_id in save_data.interactables:
        var interactable = get_interactable_by_id(object_id)
        if interactable:
            var data = save_data.interactables[object_id]
            interactable.has_interacted = data.get("has_interacted", false)
            interactable.last_interaction_time = data.get("last_interaction_time", 0.0)
            
            # Load custom state
            if interactable is ResourceNodeInteractable:
                interactable.current_resources = data.get("current_resources", interactable.max_resources)
```

---

## Performance Considerations

### Optimization Strategies

1. **Spatial Partitioning:**
   - Use spatial hash or quadtree for interactable lookup
   - Only check interactables in nearby chunks

2. **Range Culling:**
   - Only check interactables within interaction range
   - Use Area2D collision detection (already efficient)

3. **Prompt Updates:**
   - Update prompts only when player moves significantly
   - Limit prompt updates to once per frame max

4. **Interaction Validation:**
   - Cache validation results when possible
   - Only validate when player position changes

5. **Group Management:**
   - Use Godot's node groups for efficient lookup
   - Register/unregister interactables efficiently

---

## Testing Checklist

### Interaction Detection
- [ ] Interactables detected when player is in range
- [ ] Closest interactable selected correctly
- [ ] Multiple interactables prioritized correctly
- [ ] Interactables outside range not detected

### Interaction Validation
- [ ] Range validation works correctly
- [ ] Required item validation works
- [ ] Required quest validation works
- [ ] Cooldown validation works
- [ ] One-time interaction validation works

### Interaction Execution
- [ ] NPC interactions start dialogue
- [ ] Container interactions open container UI
- [ ] Resource node interactions gather resources
- [ ] Building interactions work correctly
- [ ] Custom interactions execute correctly

### UI Integration
- [ ] Interaction prompts show/hide correctly
- [ ] Prompt text updates correctly
- [ ] Prompt position updates correctly
- [ ] Prompt shows unavailable reason when needed

### Edge Cases
- [ ] Handles null interactables gracefully
- [ ] Handles player leaving range during interaction
- [ ] Handles multiple rapid interactions
- [ ] Handles interactable destruction during interaction

---

## Error Handling

### InteractionManager Error Handling

- **Missing Player Reference:** Handle missing player gracefully, return null/empty results
- **Invalid Interactable Objects:** Validate interactables before operations, return errors gracefully
- **Missing System References:** Handle missing managers (InventoryManager, QuestManager) gracefully
- **Interaction Failures:** Return InteractionResult with success=false and reason message

### Best Practices

- Use `push_error()` for critical errors (invalid interactable, missing player)
- Use `push_warning()` for non-critical issues (interaction unavailable, validation failed)
- Return InteractionResult with success=false on errors (don't crash)
- Validate all data before operations
- Handle missing system managers gracefully

---

## Default Values and Configuration

### InteractionManager Defaults

```gdscript
default_interaction_key = "interact"  # InputMap action
show_prompts = true
prompt_offset = Vector2(0, -32)  # Offset above object
default_interaction_range = 128.0
```

### InteractableObject Defaults

```gdscript
object_id = ""
interaction_type = InteractionType.CUSTOM
interaction_name = ""
interaction_range = 64.0
requires_item = ""
requires_quest = ""
is_one_time = false
cooldown_time = 0.0
has_interacted = false
last_interaction_time = 0.0
is_player_in_range = false
current_player = null
```

### InteractionPrompt Defaults

```gdscript
interaction_type = InteractionType.CUSTOM
prompt_text = "Press E to interact"
action_text = "Interact"
icon = null
is_available = true
unavailable_reason = ""
```

---

## Complete Implementation

### InteractionManager Complete Implementation

```gdscript
class_name InteractionManager
extends Node

# References
var player: Node2D = null
var ui_manager: Node = null

# Interaction State
var nearby_interactables: Array[InteractableObject] = []
var current_interactable: InteractableObject = null
var interaction_prompt_ui: Control = null
var is_interacting: bool = false

# Settings
var default_interaction_key: String = "interact"
var show_prompts: bool = true
var prompt_offset: Vector2 = Vector2(0, -32)
var default_interaction_range: float = 128.0

# Signals
signal interaction_detected(interactable: InteractableObject)
signal interaction_lost(interactable: InteractableObject)
signal interaction_started(interactable: InteractableObject)
signal interaction_completed(interactable: InteractableObject, result: InteractionResult)

func _ready() -> void:
    # Find player
    player = get_tree().get_first_node_in_group("player")
    if not player:
        push_warning("InteractionManager: Player not found in 'player' group")
    
    # Find UI manager
    ui_manager = get_node_or_null("/root/UIManager")
    
    # Create prompt UI
    create_interaction_prompt_ui()

func _process(delta: float) -> void:
    if not player:
        return
    
    # Find nearby interactables
    var nearby = find_nearby_interactables(player.global_position, default_interaction_range)
    
    # Update nearby list
    nearby_interactables = nearby
    
    # Get closest interactable
    var closest = get_closest_interactable(player.global_position)
    
    # Update current interactable
    if closest != current_interactable:
        if current_interactable:
            interaction_lost.emit(current_interactable)
        current_interactable = closest
        if closest:
            interaction_detected.emit(closest)
    
    # Update prompt
    update_interaction_prompt()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed(default_interaction_key):
        if current_interactable and not is_interacting:
            start_interaction(current_interactable)

func register_interactable(interactable: InteractableObject) -> void:
    if interactable:
        interactable.add_to_group("interactables")

func unregister_interactable(interactable: InteractableObject) -> void:
    if interactable:
        interactable.remove_from_group("interactables")
        if interactable == current_interactable:
            current_interactable = null
            hide_interaction_prompt()

func find_nearby_interactables(player_position: Vector2, range: float = 128.0) -> Array[InteractableObject]:
    var nearby: Array[InteractableObject] = []
    
    var all_interactables = get_tree().get_nodes_in_group("interactables")
    
    for node in all_interactables:
        if not node is InteractableObject:
            continue
        
        var interactable = node as InteractableObject
        var distance = player_position.distance_to(interactable.global_position)
        
        if distance <= range:
            nearby.append(interactable)
    
    # Sort by distance (closest first)
    nearby.sort_custom(func(a, b): return player_position.distance_to(a.global_position) < player_position.distance_to(b.global_position))
    
    return nearby

func get_closest_interactable(player_position: Vector2) -> InteractableObject:
    var nearby = find_nearby_interactables(player_position)
    
    if nearby.is_empty():
        return null
    
    # Return closest valid interactable
    for interactable in nearby:
        if can_interact_with(interactable):
            return interactable
    
    return null

func can_interact_with(interactable: InteractableObject) -> bool:
    if not interactable:
        return false
    
    var validation = InteractionValidator.validate_interaction(interactable, player)
    return validation.can_interact

func start_interaction(interactable: InteractableObject) -> InteractionResult:
    if interactable == null:
        var result = InteractionResult.new()
        result.success = false
        result.message = "No interactable object"
        return result
    
    # Validate interaction
    var validation = InteractionValidator.validate_interaction(interactable, player)
    if not validation.can_interact:
        var result = InteractionResult.new()
        result.success = false
        result.message = validation.reason
        
        # Show error notification
        if NotificationManager:
            var notification = NotificationData.new()
            notification.message = validation.reason
            notification.type = NotificationData.NotificationType.WARNING
            NotificationManager.show_notification(notification)
        
        return result
    
    # Start interaction
    is_interacting = true
    current_interactable = interactable
    
    interaction_started.emit(interactable)
    interactable.emit_signal("interaction_started", interactable, player)
    
    # Execute interaction
    var result = interactable.interact(player)
    
    # Update state
    if interactable.is_one_time:
        interactable.has_interacted = true
    
    interactable.last_interaction_time = Time.get_ticks_msec() / 1000.0
    
    # Complete interaction
    is_interacting = false
    interaction_completed.emit(interactable, result)
    interactable.emit_signal("interaction_completed", interactable, player)
    
    # Hide prompt
    hide_interaction_prompt()
    
    return result

func update_interaction_prompt() -> void:
    if not show_prompts:
        hide_interaction_prompt()
        return
    
    if current_interactable:
        show_interaction_prompt(current_interactable)
    else:
        hide_interaction_prompt()

func show_interaction_prompt(interactable: InteractableObject) -> void:
    if not interaction_prompt_ui:
        return
    
    var prompt = interactable.get_interaction_prompt()
    if prompt.is_available:
        interaction_prompt_ui.set_visible(true)
        interaction_prompt_ui.set_text(prompt.prompt_text)
        
        # Position above interactable
        var screen_pos = get_viewport().get_camera_2d().get_screen_center_position()
        var world_pos = interactable.global_position + prompt_offset
        var viewport_pos = get_viewport().get_camera_2d().to_screen_coordinate(world_pos)
        interaction_prompt_ui.set_position(viewport_pos)
    else:
        hide_interaction_prompt()

func hide_interaction_prompt() -> void:
    if interaction_prompt_ui:
        interaction_prompt_ui.set_visible(false)

func create_interaction_prompt_ui() -> void:
    # Create prompt UI element (simplified)
    interaction_prompt_ui = Label.new()
    interaction_prompt_ui.name = "InteractionPrompt"
    interaction_prompt_ui.set_anchors_preset(Control.PRESET_CENTER_TOP)
    interaction_prompt_ui.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    interaction_prompt_ui.add_theme_color_override("font_color", Color.WHITE)
    interaction_prompt_ui.add_theme_color_override("font_outline_color", Color.BLACK)
    interaction_prompt_ui.add_theme_constant_override("outline_size", 2)
    get_tree().root.add_child(interaction_prompt_ui)
    interaction_prompt_ui.set_visible(false)

func get_interactable_by_id(object_id: String) -> InteractableObject:
    var all_interactables = get_tree().get_nodes_in_group("interactables")
    for node in all_interactables:
        if node is InteractableObject:
            var interactable = node as InteractableObject
            if interactable.object_id == object_id:
                return interactable
    return null
```

### InteractableObject Complete Implementation

```gdscript
class_name InteractableObject
extends Area2D

# Identification
@export var object_id: String = ""
@export var interaction_type: InteractionType = InteractionType.CUSTOM
@export var interaction_name: String = ""

# Interaction Properties
@export var interaction_range: float = 64.0
@export var requires_item: String = ""
@export var requires_quest: String = ""
@export var is_one_time: bool = false
@export var cooldown_time: float = 0.0

# State
var has_interacted: bool = false
var last_interaction_time: float = 0.0
var is_player_in_range: bool = false
var current_player: Node2D = null

# Components
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var prompt_marker: Node2D = $PromptMarker

# Signals
signal interaction_started(object: InteractableObject, player: Node2D)
signal interaction_completed(object: InteractableObject, player: Node2D)
signal player_entered_range(player: Node2D)
signal player_exited_range(player: Node2D)

func _ready() -> void:
    # Add to interactables group
    add_to_group("interactables")
    
    # Register with InteractionManager
    if InteractionManager:
        InteractionManager.register_interactable(self)
    
    # Connect area signals
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    
    # Setup collision shape if not set
    if not collision_shape:
        collision_shape = CollisionShape2D.new()
        add_child(collision_shape)
        var circle_shape = CircleShape2D.new()
        circle_shape.radius = interaction_range
        collision_shape.shape = circle_shape

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        is_player_in_range = true
        current_player = body
        player_entered_range.emit(body)

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        is_player_in_range = false
        current_player = null
        player_exited_range.emit(body)

func can_interact(player: Node2D) -> bool:
    if not player:
        return false
    
    var validation = InteractionValidator.validate_interaction(self, player)
    return validation.can_interact

func interact(player: Node2D) -> InteractionResult:
    var result = InteractionResult.new()
    result.success = true
    result.message = "Interaction completed"
    return result

func get_interaction_prompt() -> InteractionPrompt:
    var prompt = InteractionPrompt.new()
    prompt.interaction_type = interaction_type
    prompt.prompt_text = "Press E to " + get_action_text()
    prompt.action_text = get_action_text()
    prompt.is_available = can_interact(current_player)
    
    if not prompt.is_available:
        var validation = InteractionValidator.validate_interaction(self, current_player)
        prompt.unavailable_reason = validation.reason
    
    return prompt

func get_action_text() -> String:
    match interaction_type:
        InteractionType.NPC_TALK:
            return "Talk"
        InteractionType.CONTAINER_OPEN:
            return "Open"
        InteractionType.RESOURCE_GATHER:
            return "Gather"
        InteractionType.BUILDING_INTERACT:
            return "Interact"
        InteractionType.DOOR_OPEN_CLOSE:
            return "Open/Close"
        InteractionType.CRAFTING_STATION:
            return "Use"
        InteractionType.ITEM_PICKUP:
            return "Pick Up"
        _:
            return "Interact"

func show_prompt() -> void:
    if prompt_marker:
        prompt_marker.set_visible(true)

func hide_prompt() -> void:
    if prompt_marker:
        prompt_marker.set_visible(false)

func update_prompt_position() -> void:
    # Update prompt marker position if needed
    pass
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── InteractionManager.gd
   └── scripts/
       └── interactables/
           ├── InteractableObject.gd
           ├── NPCInteractable.gd
           ├── ContainerInteractable.gd
           ├── ResourceNodeInteractable.gd
           └── BuildingInteractable.gd
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/InteractionManager.gd` as `InteractionManager`
   - **Important:** Load after systems that interactables depend on (InventoryManager, QuestManager, etc.)

3. **Setup Input Action:**
   - **Project > Project Settings > Input Map:**
   - Add action: `interact`
   - Assign key: `E` (or preferred key)

4. **Create Interactable Scenes:**
   - Create scenes for each interactable type
   - Extend InteractableObject base class
   - Configure interaction properties in inspector

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. InventoryManager, QuestManager, NPCManager, etc.
4. **InteractionManager** (after systems that interactables depend on)

### System Integration

**Interactables Must:**
- Extend InteractableObject base class
- Add to "interactables" group
- Implement `interact()` method
- Configure interaction properties in inspector

**Systems Must Emit Signals:**
```gdscript
# Example: NPCManager
signal npc_interacted(npc_id: String)

# Example: ContainerManager
signal container_opened(container_id: String)
```

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Interaction System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Area2D:** https://docs.godotengine.org/en/stable/classes/class_area2d.html
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Input System:** https://docs.godotengine.org/en/stable/tutorials/inputs/index.html
- **Node Groups:** https://docs.godotengine.org/en/stable/tutorials/scripting/groups.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Interaction System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Area detection
- [Signals Tutorial](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Input System Tutorial](https://docs.godotengine.org/en/stable/tutorials/inputs/index.html) - Input handling
- [Node Groups Tutorial](https://docs.godotengine.org/en/stable/tutorials/scripting/groups.html) - Group management

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- InteractableObject is a Node (can be added to scene tree)
- Interaction properties configured via @export variables (editable in inspector)
- Interaction types selectable via enum in inspector

**Visual Configuration:**
- Interaction range visualized via CollisionShape2D
- Prompt marker position configurable
- Interaction properties editable in inspector

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Interaction range visualizer
  - Interaction type picker
  - Interaction validation tester

**Current Approach:**
- Uses Godot's native Area2D system (no custom tools needed)
- Interactables created as scenes (editable in editor)
- Interaction properties configured via inspector
- Fully functional without custom editor tools

---

## Implementation Notes

### Interaction Key Binding

**Default:** E key (configurable in InputMap)

**InputMap Action:** `interact`

**Remapping:** Supported through InputManager

### Interaction Prompt UI

**Position:** Above interactable object (configurable offset)

**Style:** 
- Background panel (semi-transparent)
- Icon (optional)
- Text: "Press [KEY] to [ACTION]"
- Unavailable state (grayed out with reason)

### Interactable Registration

**Method:** Add to "interactables" node group

**Example:**
```gdscript
func _ready() -> void:
    add_to_group("interactables")
    InteractionManager.register_interactable(self)
```

---

## Future Enhancements

### Potential Additions

1. **Interaction Chains:**
   - Sequential interactions
   - Interaction dependencies

2. **Context-Sensitive Interactions:**
   - Different interactions based on player state
   - Time-of-day dependent interactions

3. **Multi-Player Interactions:**
   - Shared interactions
   - Interaction permissions

4. **Interaction Animations:**
   - Player animation during interaction
   - Object animation feedback

5. **Voice/Text Commands:**
   - Voice interaction support
   - Text command system

---

## Dependencies

### Required Systems
- Input System (for interaction key)
- UI System (for prompts and interaction UIs)

### Systems That Depend on This
- NPC System
- Container System
- Resource Gathering System
- Building System
- Quest System
- Inventory System (item pickup)

---

## Notes

- Interaction system is a foundational system used by many other systems
- All interactables should extend `InteractableObject` base class
- Interaction prompts are managed centrally by `InteractionManager`
- Interaction validation ensures consistent behavior across all interaction types
- Interaction system integrates with save/load for persistent state

