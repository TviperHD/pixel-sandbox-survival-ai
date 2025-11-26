# Technical Specifications: Dialogue System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the dialogue system supporting dialogue trees, branching conversations, conditional dialogue, dialogue variables, integration with NPCs and quests, and speech bubble UI. This system integrates with NPCManager, QuestManager, InventoryManager, ProgressionManager, and UIManager.

---

## Research Notes

### Dialogue System Architecture Best Practices

**Research Findings:**
- Dialogue trees use node-based structure for branching conversations
- Conditional nodes enable dynamic dialogue based on game state
- Action nodes execute game events during dialogue
- Variables track dialogue state across conversations
- Speech bubbles provide immersive dialogue presentation

**Sources:**
- [Godot 4 Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Godot 4 Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data storage
- General dialogue system design patterns

**Implementation Approach:**
- DialogueManager as autoload singleton
- DialogueData as Resource (dialogue tree)
- DialogueNode as Resource (individual nodes)
- Node types: TEXT, CHOICE, CONDITIONAL, ACTION, END
- Variable system for dialogue state
- Integration with all game systems via actions/conditions

**Why This Approach:**
- Singleton: centralized dialogue management
- Resources: easy to create/edit dialogues in editor
- Node types: flexible dialogue structure
- Variables: track dialogue state
- Integration: connects dialogue to game systems

### Dialogue Tree Best Practices

**Research Findings:**
- Tree structure allows branching conversations
- Node IDs link nodes together
- Start node defines dialogue entry point
- End node terminates dialogue
- Conditional branches enable dynamic dialogue

**Sources:**
- General dialogue tree patterns

**Implementation Approach:**
- DialogueData contains node dictionary (node_id -> DialogueNode)
- Start node ID defines entry point
- Next node IDs link nodes together
- Conditional nodes branch based on conditions
- Choice nodes branch based on player selection

**Why This Approach:**
- Dictionary: efficient node lookup
- Node IDs: clear node relationships
- Start node: clear entry point
- Branching: flexible conversation flow

### Conditional Dialogue Best Practices

**Research Findings:**
- Conditions check game state (quests, items, level, etc.)
- Multiple conditions can be combined (AND/OR)
- Conditions enable dynamic dialogue based on player progress
- Variables track dialogue-specific state

**Sources:**
- General conditional system patterns

**Implementation Approach:**
- DialogueCondition resource for conditions
- Condition types: VARIABLE, QUEST_STATUS, ITEM_OWNED, LEVEL, etc.
- Comparison types: EQUALS, GREATER_THAN, etc.
- Evaluate conditions at runtime
- Branch to appropriate node based on conditions

**Why This Approach:**
- Multiple types: flexible condition checking
- Comparisons: precise condition evaluation
- Runtime evaluation: dynamic dialogue
- Branching: appropriate dialogue flow

### Dialogue Actions Best Practices

**Research Findings:**
- Actions execute game events during dialogue
- Actions can modify game state (give items, start quests, etc.)
- Actions enable dialogue to affect gameplay
- Multiple actions can execute per node

**Sources:**
- General action system patterns

**Implementation Approach:**
- DialogueAction resource for actions
- Action types: SET_VARIABLE, START_QUEST, GIVE_ITEM, etc.
- Parameters dictionary for action-specific data
- Execute actions when processing ACTION nodes
- Integration with all game systems

**Why This Approach:**
- Multiple types: flexible action execution
- Parameters: configurable actions
- Integration: connects dialogue to gameplay
- Multiple actions: complex dialogue effects

---

## Data Structures

### DialogueNode

```gdscript
class_name DialogueNode
extends Resource

# Identification
@export var node_id: String  # Unique identifier
@export var node_type: DialogueNodeType

enum DialogueNodeType {
    TEXT,        # Simple text dialogue
    CHOICE,      # Player choice node
    CONDITIONAL, # Conditional branch node
    ACTION,      # Execute action node
    END          # End dialogue node
}

# Text Content (for TEXT nodes)
@export var speaker: String = ""  # NPC name or "" for player
@export var text: String = ""
@export var portrait: Texture2D = null
@export var voice_line: AudioStream = null

# Choices (for CHOICE nodes)
@export var choices: Array[DialogueChoice] = []

# Conditions (for CONDITIONAL nodes)
@export var conditions: Array[DialogueCondition] = []
@export var else_node_id: String = ""  # Node to go to if conditions fail

# Actions (for ACTION nodes)
@export var actions: Array[DialogueAction] = []

# Navigation
@export var next_node_id: String = ""  # Next node (for TEXT nodes)
@export var default_next_node_id: String = ""  # Default next node (for CHOICE/CONDITIONAL)

# Metadata
@export var tags: Array[String] = []  # Tags for filtering/searching
```

### DialogueChoice

```gdscript
class_name DialogueChoice
extends Resource

@export var choice_text: String
@export var next_node_id: String = ""  # Node to go to when selected
@export var conditions: Array[DialogueCondition] = []  # Conditions to show this choice
@export var actions: Array[DialogueAction] = []  # Actions when selected
@export var is_available: bool = true  # Runtime availability
```

### DialogueCondition

```gdscript
class_name DialogueCondition
extends Resource

@export var condition_type: ConditionType
@export var variable_name: String = ""
@export var comparison: ComparisonType
@export var value: Variant  # Value to compare against

enum ConditionType {
    VARIABLE,        # Check dialogue variable
    QUEST_STATUS,    # Check quest status
    QUEST_OBJECTIVE, # Check quest objective
    ITEM_OWNED,      # Check if player has item
    LEVEL,           # Check player level
    REPUTATION,      # Check reputation with NPC/faction
    CUSTOM          # Custom condition (scripted)
}

enum ComparisonType {
    EQUALS,
    NOT_EQUALS,
    GREATER_THAN,
    LESS_THAN,
    GREATER_OR_EQUAL,
    LESS_OR_EQUAL,
    CONTAINS
}

func evaluate() -> bool:
    match condition_type:
        ConditionType.VARIABLE:
            if DialogueManager:
                var var_value = DialogueManager.get_variable(variable_name)
                return compare_values(var_value, value, comparison)
            return false
        
        ConditionType.QUEST_STATUS:
            if QuestManager:
                var quest = QuestManager.active_quests.get(variable_name)
                if quest:
                    var quest_status = quest.status
                    return compare_values(quest_status, value, comparison)
                # Check completed quests
                quest = QuestManager.completed_quests.get(variable_name)
                if quest:
                    return compare_values(QuestStatus.COMPLETED, value, comparison)
            return false
        
        ConditionType.QUEST_OBJECTIVE:
            if QuestManager:
                var quest = QuestManager.active_quests.get(variable_name)
                if quest:
                    # variable_name contains quest_id, value should contain objective_id or check all objectives
                    # For now, check if any objective matches (can be refined)
                    for objective in quest.objectives:
                        if objective.objective_id == str(value) or value == true:
                            return compare_values(objective.is_completed, value, comparison)
            return false
        
        ConditionType.ITEM_OWNED:
            if InventoryManager:
                var item_count = InventoryManager.get_item_count(variable_name)
                return compare_values(item_count, value, comparison)
            return false
        
        ConditionType.LEVEL:
            if ProgressionManager:
                var player_level = ProgressionManager.get_level()
                return compare_values(player_level, value, comparison)
            return false
        
        ConditionType.REPUTATION:
            # Reputation system (when implemented)
            # if ReputationManager:
            #     var reputation = ReputationManager.get_reputation(variable_name)
            #     return compare_values(reputation, value, comparison)
            return false
        
        _:
            return false

func compare_values(a: Variant, b: Variant, comp: ComparisonType) -> bool:
    match comp:
        ComparisonType.EQUALS:
            return a == b
        ComparisonType.NOT_EQUALS:
            return a != b
        ComparisonType.GREATER_THAN:
            return a > b
        ComparisonType.LESS_THAN:
            return a < b
        ComparisonType.GREATER_OR_EQUAL:
            return a >= b
        ComparisonType.LESS_OR_EQUAL:
            return a <= b
        ComparisonType.CONTAINS:
            if a is Array:
                return b in a
            return false
    return false
```

### DialogueAction

```gdscript
class_name DialogueAction
extends Resource

@export var action_type: ActionType
@export var parameters: Dictionary = {}  # Action-specific parameters

enum ActionType {
    SET_VARIABLE,      # Set dialogue variable
    START_QUEST,        # Start quest
    COMPLETE_QUEST,     # Complete quest
    UPDATE_OBJECTIVE,   # Update quest objective
    GIVE_ITEM,         # Give item to player
    TAKE_ITEM,         # Take item from player
    CHANGE_REPUTATION,  # Change reputation
    PLAY_SOUND,         # Play sound effect
    PLAY_MUSIC,         # Play music
    SHOW_CUTSCENE,     # Show cutscene
    TELEPORT,          # Teleport player
    CUSTOM             # Custom action (scripted)
}

func execute() -> void:
    match action_type:
        ActionType.SET_VARIABLE:
            if DialogueManager:
                DialogueManager.set_variable(parameters.get("variable_name", ""), parameters.get("value"))
        
        ActionType.START_QUEST:
            if QuestManager:
                QuestManager.start_quest(parameters.get("quest_id", ""))
        
        ActionType.COMPLETE_QUEST:
            if QuestManager:
                QuestManager.complete_quest(parameters.get("quest_id", ""))
        
        ActionType.UPDATE_OBJECTIVE:
            if QuestManager:
                var quest_id = parameters.get("quest_id", "")
                var objective_id = parameters.get("objective_id", "")
                var progress = parameters.get("progress", 1)
                QuestManager.update_objective(quest_id, objective_id, progress)
        
        ActionType.GIVE_ITEM:
            if InventoryManager:
                var item_id = parameters.get("item_id", "")
                var quantity = parameters.get("quantity", 1)
                InventoryManager.add_item(item_id, quantity)
        
        ActionType.TAKE_ITEM:
            if InventoryManager:
                var item_id = parameters.get("item_id", "")
                var quantity = parameters.get("quantity", 1)
                InventoryManager.remove_item(item_id, quantity)
        
        ActionType.CHANGE_REPUTATION:
            # Reputation system (when implemented)
            # if ReputationManager:
            #     var npc_id = parameters.get("npc_id", "")
            #     var amount = parameters.get("amount", 0)
            #     ReputationManager.change_reputation(npc_id, amount)
            pass
        
        ActionType.PLAY_SOUND:
            if AudioManager:
                var sound_path = parameters.get("sound_path", "")
                AudioManager.play_sound(sound_path)
        
        ActionType.PLAY_MUSIC:
            if AudioManager:
                var music_path = parameters.get("music_path", "")
                AudioManager.play_music(music_path)
        
        ActionType.TELEPORT:
            var player = get_tree().get_first_node_in_group("player")
            if player:
                var position = parameters.get("position", Vector2.ZERO)
                player.global_position = position
        
        _:
            pass  # Handle other action types
```

### DialogueData

```gdscript
class_name DialogueData
extends Resource

# Identification
@export var dialogue_id: String  # Unique identifier
@export var dialogue_name: String  # Display name
@export var npc_id: String = ""  # Associated NPC (if any)

# Dialogue Tree
@export var nodes: Dictionary = {}  # node_id -> DialogueNode
@export var start_node_id: String = ""  # Starting node

# Variables
@export var variables: Dictionary = {}  # variable_name -> value (default values)

# Metadata
@export var description: String = ""
@export var tags: Array[String] = []
```

---

## Core Classes

### DialogueManager (Autoload Singleton)

```gdscript
class_name DialogueManager
extends Node

# References
@export var ui_manager: UIManager
@export var quest_manager: QuestManager
@export var inventory_manager: InventoryManager

# Dialogue Registry
var dialogue_registry: Dictionary = {}  # dialogue_id -> DialogueData

# Current Dialogue State
var current_dialogue: DialogueData = null
var current_node: DialogueNode = null
var dialogue_history: Array[String] = []  # History of node IDs visited
var dialogue_variables: Dictionary = {}  # Runtime dialogue variables

# UI
var dialogue_ui: DialogueUI = null

# Signals
signal dialogue_started(dialogue_id: String, npc_id: String)
signal dialogue_ended(dialogue_id: String)
signal dialogue_node_changed(node_id: String)
signal dialogue_choice_selected(choice_index: int)
signal dialogue_variable_changed(variable_name: String, value: Variant)

# Functions
func _ready() -> void
func register_dialogue(dialogue_data: DialogueData) -> void
func start_dialogue(dialogue_id: String, npc_id: String = "") -> bool
func end_dialogue() -> void
func go_to_node(node_id: String) -> void
func process_node(node: DialogueNode) -> void
func display_text_node(node: DialogueNode) -> void
func display_choice_node(node: DialogueNode) -> void
func process_conditional_node(node: DialogueNode) -> void
func process_action_node(node: DialogueNode) -> void
func on_choice_selected(choice_index: int) -> void
func on_continue_pressed() -> void

# Variable Management
func set_variable(variable_name: String, value: Variant) -> void
func get_variable(variable_name: String) -> Variant
func has_variable(variable_name: String) -> bool
func clear_variables() -> void

# Dialogue Queries
func get_dialogue(dialogue_id: String) -> DialogueData
func has_dialogue(dialogue_id: String) -> bool
func get_dialogues_for_npc(npc_id: String) -> Array[DialogueData]
```

### DialogueUI

```gdscript
class_name DialogueUI
extends Control

# UI Elements
@onready var speech_bubble: Panel
@onready var dialogue_text: RichTextLabel
@onready var speaker_name: Label
@onready var portrait: TextureRect
@onready var choice_container: VBoxContainer
@onready var continue_button: Button

# State
var is_visible: bool = false
var current_speaker: String = ""
var typing_speed: float = 0.05  # Seconds per character
var is_typing: bool = false

# Functions
func _ready() -> void
func show_dialogue() -> void
func hide_dialogue() -> void
func display_text(text: String, speaker: String, portrait: Texture2D = null) -> void
func display_choices(choices: Array[DialogueChoice]) -> void
func clear_choices() -> void
func type_text(text: String) -> void
func skip_typing() -> void
func update_portrait(portrait: Texture2D) -> void
func update_speaker_name(name: String) -> void
```

---

## System Architecture

### Component Hierarchy

```
DialogueManager (Autoload Singleton)
├── DialogueUI (UI element)
├── DialogueData (resources)
│   └── DialogueNode (nodes in tree)
└── DialogueVariable (runtime state)
```

### Data Flow

1. **Dialogue Start:**
   - NPC interaction → `DialogueManager.start_dialogue(dialogue_id)` called
   - Load dialogue data → Get `DialogueData` from registry
   - Initialize variables → Set default variables
   - Go to start node → `go_to_node(start_node_id)`
   - Display UI → Show dialogue UI

2. **Node Processing:**
   - Process node type → `process_node(node)` called
   - TEXT node → Display text, wait for continue
   - CHOICE node → Display choices, wait for selection
   - CONDITIONAL node → Evaluate conditions, branch to appropriate node
   - ACTION node → Execute actions, continue to next node
   - END node → End dialogue

3. **Dialogue Navigation:**
   - Player continues → `on_continue_pressed()` → Go to `next_node_id`
   - Player selects choice → `on_choice_selected()` → Go to choice's `next_node_id`
   - Conditional branch → Evaluate conditions → Go to appropriate node

4. **Dialogue End:**
   - END node reached → `end_dialogue()` called
   - Hide UI → Hide dialogue UI
   - Clear state → Clear current dialogue/node
   - Emit signal → `dialogue_ended` signal

---

## Algorithms

### Start Dialogue Algorithm

```gdscript
func start_dialogue(dialogue_id: String, npc_id: String = "") -> bool:
    # Get dialogue data
    if not has_dialogue(dialogue_id):
        push_error("DialogueManager: Dialogue not found: " + dialogue_id)
        return false
    
    var dialogue_data = get_dialogue(dialogue_id)
    
    # Initialize dialogue state
    current_dialogue = dialogue_data
    dialogue_history.clear()
    
    # Initialize variables (merge defaults with runtime)
    dialogue_variables.clear()
    for var_name in dialogue_data.variables:
        dialogue_variables[var_name] = dialogue_data.variables[var_name]
    
    # Go to start node
    if dialogue_data.start_node_id.is_empty():
        push_error("DialogueManager: No start node in dialogue: " + dialogue_id)
        return false
    
    # Show UI
    if dialogue_ui:
        dialogue_ui.show_dialogue()
    
    # Start dialogue
    emit_signal("dialogue_started", dialogue_id, npc_id)
    go_to_node(dialogue_data.start_node_id)
    
    return true
```

### Process Node Algorithm

```gdscript
func process_node(node: DialogueNode) -> void:
    if node == null:
        push_error("DialogueManager: Null node")
        return
    
    current_node = node
    dialogue_history.append(node.node_id)
    
    emit_signal("dialogue_node_changed", node.node_id)
    
    match node.node_type:
        DialogueNode.DialogueNodeType.TEXT:
            display_text_node(node)
        
        DialogueNode.DialogueNodeType.CHOICE:
            display_choice_node(node)
        
        DialogueNode.DialogueNodeType.CONDITIONAL:
            process_conditional_node(node)
        
        DialogueNode.DialogueNodeType.ACTION:
            process_action_node(node)
        
        DialogueNode.DialogueNodeType.END:
            end_dialogue()
```

### Conditional Node Processing Algorithm

```gdscript
func process_conditional_node(node: DialogueNode) -> void:
    # Evaluate all conditions
    var all_conditions_met = true
    
    for condition in node.conditions:
        if not condition.evaluate():
            all_conditions_met = false
            break
    
    # Branch based on result
    if all_conditions_met:
        # Conditions met, go to next node
        if not node.next_node_id.is_empty():
            go_to_node(node.next_node_id)
        else:
            # No next node, end dialogue
            end_dialogue()
    else:
        # Conditions not met, go to else node
        if not node.else_node_id.is_empty():
            go_to_node(node.else_node_id)
        elif not node.default_next_node_id.is_empty():
            go_to_node(node.default_next_node_id)
        else:
            # No else node, end dialogue
            end_dialogue()
```

### Choice Selection Algorithm

```gdscript
func on_choice_selected(choice_index: int) -> void:
    if current_node == null or current_node.node_type != DialogueNode.DialogueNodeType.CHOICE:
        return
    
    if choice_index < 0 or choice_index >= current_node.choices.size():
        return
    
    var choice = current_node.choices[choice_index]
    
    # Check if choice is available
    if not choice.is_available:
        return
    
    # Execute choice actions
    for action in choice.actions:
        action.execute()
    
    emit_signal("dialogue_choice_selected", choice_index)
    
    # Go to next node
    if not choice.next_node_id.is_empty():
        go_to_node(choice.next_node_id)
    else:
        end_dialogue()
```

---

## Integration Points

### NPC System

**Usage:**
- NPCs have associated dialogue IDs
- NPC interactions start dialogue
- Dialogue can check NPC state/reputation

**Example:**
```gdscript
# In NPCInteractable
func interact(player: Node2D) -> InteractionResult:
    var result = InteractionResult.new()
    
    # Start dialogue
    if not dialogue_id.is_empty():
        DialogueManager.start_dialogue(dialogue_id, npc_id)
        result.success = true
        result.data["dialogue_started"] = true
    
    return result
```

### Quest System

**Usage:**
- Dialogue can start/complete quests
- Dialogue can check quest status
- Quest state affects dialogue options

**Example:**
```gdscript
# Dialogue condition checks quest status
var condition = DialogueCondition.new()
condition.condition_type = DialogueCondition.ConditionType.QUEST_STATUS
condition.variable_name = "quest_001"
condition.comparison = DialogueCondition.ComparisonType.EQUALS
condition.value = QuestStatus.COMPLETED

# Dialogue action starts quest
var action = DialogueAction.new()
action.action_type = DialogueAction.ActionType.START_QUEST
action.parameters = {"quest_id": "quest_001"}
```

### Inventory System

**Usage:**
- Dialogue can give/take items
- Dialogue can check if player has items
- Item conditions affect dialogue options

**Example:**
```gdscript
# Dialogue condition checks item
var condition = DialogueCondition.new()
condition.condition_type = DialogueCondition.ConditionType.ITEM_OWNED
condition.variable_name = "iron_ore"
condition.comparison = DialogueCondition.ComparisonType.GREATER_OR_EQUAL
condition.value = 10

# Dialogue action gives item
var action = DialogueAction.new()
action.action_type = DialogueAction.ActionType.GIVE_ITEM
action.parameters = {"item_id": "iron_sword", "quantity": 1}
```

### Progression System

**Usage:**
- Dialogue can check player level
- Dialogue can grant experience
- Level affects dialogue options

**Example:**
```gdscript
# Dialogue condition checks level
var condition = DialogueCondition.new()
condition.condition_type = DialogueCondition.ConditionType.LEVEL
condition.comparison = DialogueCondition.ComparisonType.GREATER_OR_EQUAL
condition.value = 5
```

---

## Save/Load System

### Dialogue Save

**Save Format:**
```gdscript
{
    "dialogue_state": {
        "current_dialogue_id": "",
        "dialogue_variables": {
            "met_npc": true,
            "quest_started": false
        },
        "dialogue_history": ["node_001", "node_002"]
    }
}
```

**Load Format:**
```gdscript
func load_dialogue_state(save_data: Dictionary) -> void:
    if save_data.has("dialogue_state"):
        var state = save_data.dialogue_state
        
        # Restore variables
        if state.has("dialogue_variables"):
            dialogue_variables = state.dialogue_variables
        
        # Restore history
        if state.has("dialogue_history"):
            dialogue_history = state.dialogue_history
```

---

## Performance Considerations

### Optimization Strategies

1. **Dialogue Loading:**
   - Load dialogues on-demand (when needed)
   - Cache frequently used dialogues
   - Unload unused dialogues

2. **Condition Evaluation:**
   - Cache condition results when possible
   - Only re-evaluate when relevant state changes

3. **UI Updates:**
   - Limit text typing speed
   - Skip typing animation if player presses continue quickly
   - Batch UI updates

4. **Variable Management:**
   - Use efficient data structures for variables
   - Clear unused variables periodically

---

## Testing Checklist

### Dialogue Flow
- [ ] Dialogue starts correctly
- [ ] Text nodes display correctly
- [ ] Choice nodes display correctly
- [ ] Conditional nodes branch correctly
- [ ] Action nodes execute correctly
- [ ] Dialogue ends correctly
- [ ] Dialogue history tracks correctly

### Conditions
- [ ] Variable conditions work
- [ ] Quest status conditions work
- [ ] Item owned conditions work
- [ ] Level conditions work
- [ ] Reputation conditions work
- [ ] Custom conditions work

### Actions
- [ ] Set variable action works
- [ ] Start quest action works
- [ ] Complete quest action works
- [ ] Give item action works
- [ ] Take item action works
- [ ] Change reputation action works
- [ ] Custom actions work

### Integration
- [ ] Works with NPC system
- [ ] Works with quest system
- [ ] Works with inventory system
- [ ] Works with progression system
- [ ] Save/load works correctly

---

## Error Handling

### DialogueManager Error Handling

- **Missing Dialogue Data:** Handle missing dialogue IDs gracefully, return errors
- **Invalid Node IDs:** Validate node IDs before navigation, return errors gracefully
- **Missing System References:** Handle missing managers (QuestManager, InventoryManager) gracefully
- **Dialogue Execution Errors:** Handle action/condition execution failures gracefully

### Best Practices

- Use `push_error()` for critical errors (missing dialogue, invalid node ID)
- Use `push_warning()` for non-critical issues (missing managers, failed conditions)
- Return false/null on errors (don't crash)
- Validate all data before operations
- Handle missing system managers gracefully

---

## Default Values and Configuration

### DialogueManager Defaults

```gdscript
typing_speed = 0.05  # Seconds per character
auto_advance = false
auto_advance_delay = 2.0  # Seconds
```

### DialogueNode Defaults

```gdscript
node_id = ""
node_type = DialogueNodeType.TEXT
speaker = ""
text = ""
portrait = null
voice_line = null
choices = []
conditions = []
else_node_id = ""
actions = []
next_node_id = ""
default_next_node_id = ""
tags = []
```

### DialogueData Defaults

```gdscript
dialogue_id = ""
dialogue_name = ""
npc_id = ""
nodes = {}
start_node_id = ""
variables = {}
description = ""
tags = []
```

### DialogueChoice Defaults

```gdscript
choice_text = ""
next_node_id = ""
conditions = []
actions = []
is_available = true
```

---

## Complete Implementation

### DialogueManager Complete Implementation

```gdscript
class_name DialogueManager
extends Node

# References
var ui_manager: Node = null
var quest_manager: Node = null
var inventory_manager: Node = null

# Dialogue Registry
var dialogue_registry: Dictionary = {}

# Current Dialogue State
var current_dialogue: DialogueData = null
var current_node: DialogueNode = null
var dialogue_history: Array[String] = []
var dialogue_variables: Dictionary = {}

# UI
var dialogue_ui: DialogueUI = null

# Settings
var typing_speed: float = 0.05
var auto_advance: bool = false
var auto_advance_delay: float = 2.0

# Signals
signal dialogue_started(dialogue_id: String, npc_id: String)
signal dialogue_ended(dialogue_id: String)
signal dialogue_node_changed(node_id: String)
signal dialogue_choice_selected(choice_index: int)
signal dialogue_variable_changed(variable_name: String, value: Variant)

func _ready() -> void:
    # Find managers
    ui_manager = get_node_or_null("/root/UIManager")
    quest_manager = get_node_or_null("/root/QuestManager")
    inventory_manager = get_node_or_null("/root/InventoryManager")
    
    # Load dialogues
    load_dialogues()
    
    # Create dialogue UI
    create_dialogue_ui()

func load_dialogues() -> void:
    var dialogue_dir = DirAccess.open("res://resources/dialogues/")
    if dialogue_dir:
        dialogue_dir.list_dir_begin()
        var file_name = dialogue_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var dialogue_data = load("res://resources/dialogues/" + file_name) as DialogueData
                if dialogue_data:
                    register_dialogue(dialogue_data)
            file_name = dialogue_dir.get_next()

func register_dialogue(dialogue_data: DialogueData) -> void:
    if dialogue_data:
        dialogue_registry[dialogue_data.dialogue_id] = dialogue_data

func start_dialogue(dialogue_id: String, npc_id: String = "") -> bool:
    if not has_dialogue(dialogue_id):
        push_error("DialogueManager: Dialogue not found: " + dialogue_id)
        return false
    
    var dialogue_data = get_dialogue(dialogue_id)
    
    # Initialize dialogue state
    current_dialogue = dialogue_data
    dialogue_history.clear()
    
    # Initialize variables (merge defaults with runtime)
    dialogue_variables.clear()
    for var_name in dialogue_data.variables:
        dialogue_variables[var_name] = dialogue_data.variables[var_name]
    
    # Go to start node
    if dialogue_data.start_node_id.is_empty():
        push_error("DialogueManager: No start node in dialogue: " + dialogue_id)
        return false
    
    # Show UI
    if dialogue_ui:
        dialogue_ui.show_dialogue()
    
    # Start dialogue
    dialogue_started.emit(dialogue_id, npc_id)
    go_to_node(dialogue_data.start_node_id)
    
    return true

func end_dialogue() -> void:
    var dialogue_id = current_dialogue.dialogue_id if current_dialogue else ""
    
    # Hide UI
    if dialogue_ui:
        dialogue_ui.hide_dialogue()
    
    # Clear state
    current_dialogue = null
    current_node = null
    dialogue_history.clear()
    
    # Emit signal
    dialogue_ended.emit(dialogue_id)

func go_to_node(node_id: String) -> void:
    if not current_dialogue:
        return
    
    var node = current_dialogue.nodes.get(node_id)
    if not node:
        push_error("DialogueManager: Node not found: " + node_id)
        end_dialogue()
        return
    
    current_node = node
    dialogue_history.append(node_id)
    dialogue_node_changed.emit(node_id)
    
    # Process node
    process_node(node)

func process_node(node: DialogueNode) -> void:
    if node == null:
        return
    
    match node.node_type:
        DialogueNode.DialogueNodeType.TEXT:
            display_text_node(node)
        
        DialogueNode.DialogueNodeType.CHOICE:
            display_choice_node(node)
        
        DialogueNode.DialogueNodeType.CONDITIONAL:
            process_conditional_node(node)
        
        DialogueNode.DialogueNodeType.ACTION:
            process_action_node(node)
        
        DialogueNode.DialogueNodeType.END:
            end_dialogue()

func display_text_node(node: DialogueNode) -> void:
    if dialogue_ui:
        dialogue_ui.display_text(node.text, node.speaker, node.portrait)
    
    # Play voice line if available
    if node.voice_line and AudioManager:
        AudioManager.play_sound_stream(node.voice_line)

func display_choice_node(node: DialogueNode) -> void:
    if dialogue_ui:
        # Filter available choices
        var available_choices: Array[DialogueChoice] = []
        for choice in node.choices:
            # Check conditions
            var is_available = true
            for condition in choice.conditions:
                if not condition.evaluate():
                    is_available = false
                    break
            
            if is_available:
                available_choices.append(choice)
        
        dialogue_ui.display_choices(available_choices)

func process_conditional_node(node: DialogueNode) -> void:
    # Evaluate conditions
    var conditions_met = true
    for condition in node.conditions:
        if not condition.evaluate():
            conditions_met = false
            break
    
    # Navigate based on conditions
    if conditions_met:
        if not node.next_node_id.is_empty():
            go_to_node(node.next_node_id)
    else:
        if not node.else_node_id.is_empty():
            go_to_node(node.else_node_id)
        elif not node.default_next_node_id.is_empty():
            go_to_node(node.default_next_node_id)
        else:
            end_dialogue()

func process_action_node(node: DialogueNode) -> void:
    # Execute all actions
    for action in node.actions:
        action.execute()
    
    # Continue to next node
    if not node.next_node_id.is_empty():
        go_to_node(node.next_node_id)
    else:
        end_dialogue()

func on_choice_selected(choice_index: int) -> void:
    if not current_node or current_node.node_type != DialogueNode.DialogueNodeType.CHOICE:
        return
    
    if choice_index < 0 or choice_index >= current_node.choices.size():
        return
    
    var choice = current_node.choices[choice_index]
    
    # Execute choice actions
    for action in choice.actions:
        action.execute()
    
    # Navigate to choice's next node
    if not choice.next_node_id.is_empty():
        go_to_node(choice.next_node_id)
    else:
        end_dialogue()
    
    dialogue_choice_selected.emit(choice_index)

func on_continue_pressed() -> void:
    if not current_node:
        return
    
    # If text node, go to next node
    if current_node.node_type == DialogueNode.DialogueNodeType.TEXT:
        if not current_node.next_node_id.is_empty():
            go_to_node(current_node.next_node_id)
        else:
            end_dialogue()

func set_variable(variable_name: String, value: Variant) -> void:
    dialogue_variables[variable_name] = value
    dialogue_variable_changed.emit(variable_name, value)

func get_variable(variable_name: String) -> Variant:
    return dialogue_variables.get(variable_name, null)

func has_variable(variable_name: String) -> bool:
    return dialogue_variables.has(variable_name)

func clear_variables() -> void:
    dialogue_variables.clear()

func get_dialogue(dialogue_id: String) -> DialogueData:
    return dialogue_registry.get(dialogue_id)

func has_dialogue(dialogue_id: String) -> bool:
    return dialogue_registry.has(dialogue_id)

func get_dialogues_for_npc(npc_id: String) -> Array[DialogueData]:
    var dialogues: Array[DialogueData] = []
    for dialogue_id in dialogue_registry:
        var dialogue = dialogue_registry[dialogue_id]
        if dialogue.npc_id == npc_id:
            dialogues.append(dialogue)
    return dialogues

func create_dialogue_ui() -> void:
    var ui_scene = preload("res://scenes/ui/DialogueUI.tscn")
    if ui_scene:
        dialogue_ui = ui_scene.instantiate() as DialogueUI
        if dialogue_ui:
            get_tree().root.add_child(dialogue_ui)
            dialogue_ui.set_visible(false)
            
            # Connect signals
            dialogue_ui.continue_pressed.connect(on_continue_pressed)
            dialogue_ui.choice_selected.connect(on_choice_selected)
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── DialogueManager.gd
   └── scripts/
       └── dialogue/
           ├── DialogueNode.gd
           ├── DialogueChoice.gd
           ├── DialogueCondition.gd
           ├── DialogueAction.gd
           └── DialogueData.gd
   └── scenes/
       └── ui/
           └── DialogueUI.tscn
   └── resources/
       └── dialogues/
           ├── npc_001_intro.tres
           └── npc_001_quest.tres
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/DialogueManager.gd` as `DialogueManager`
   - **Important:** Load after systems that dialogue uses (QuestManager, InventoryManager, etc.)

3. **Create Dialogue Resources:**
   - Create DialogueData resources for each dialogue
   - Add DialogueNode resources to dialogue tree
   - Configure node connections, conditions, and actions
   - Save as `.tres` files in `res://resources/dialogues/`

4. **Create Dialogue UI Scene:**
   - Create DialogueUI scene with speech bubble, text label, portrait, and choice buttons
   - Configure UI layout
   - Save as `res://scenes/ui/DialogueUI.tscn`

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. QuestManager, InventoryManager, ProgressionManager
4. **DialogueManager** (after systems that dialogue uses)

### System Integration

**Dialogue Conditions Must:**
- Extend DialogueCondition resource
- Implement `evaluate()` method
- Check game state via system managers

**Dialogue Actions Must:**
- Extend DialogueAction resource
- Implement `execute()` method
- Modify game state via system managers

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Dialogue System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Resources:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **RichTextLabel:** https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Dialogue System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Signals Tutorial](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Resources Tutorial](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data storage
- [RichTextLabel Documentation](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html) - Rich text display

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- DialogueData is a Resource (can be created/edited in inspector)
- DialogueNode is a Resource (can be added to DialogueData)
- DialogueChoice, DialogueCondition, DialogueAction are Resources (editable in inspector)

**Visual Configuration:**
- Dialogue properties editable in inspector
- Node connections configurable in inspector
- Conditions and actions editable in inspector

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Dialogue tree visualizer/editor
  - Node connection editor
  - Condition/action editor with validation

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Dialogues created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

### Dialogue File Format

**Recommended:** JSON or Godot Resource files (.tres)

**JSON Example:**
```json
{
    "dialogue_id": "npc_001_greeting",
    "dialogue_name": "NPC Greeting",
    "npc_id": "npc_001",
    "start_node_id": "node_001",
    "variables": {
        "met_before": false
    },
    "nodes": {
        "node_001": {
            "node_id": "node_001",
            "node_type": "TEXT",
            "speaker": "NPC",
            "text": "Hello! Welcome to our town.",
            "next_node_id": "node_002"
        },
        "node_002": {
            "node_id": "node_002",
            "node_type": "CHOICE",
            "choices": [
                {
                    "choice_text": "Tell me about this place",
                    "next_node_id": "node_003"
                },
                {
                    "choice_text": "Do you have any quests?",
                    "next_node_id": "node_004"
                }
            ]
        }
    }
}
```

### Dialogue Editor

**Recommendation:** Create a visual dialogue editor or use a tool like:
- Dialogic (Godot plugin)
- Custom editor in Godot
- External tool with JSON export

---

## Future Enhancements

### Potential Additions

1. **Voice Acting:**
   - Voice line playback
   - Lip sync animation

2. **Dialogue Animations:**
   - Character animations during dialogue
   - Portrait animations

3. **Dialogue Effects:**
   - Text effects (shake, fade, etc.)
   - Sound effects for dialogue

4. **Dialogue Localization:**
   - Multi-language support
   - Text replacement system

5. **Dialogue Analytics:**
   - Track dialogue choices
   - Player behavior analysis

---

## Dependencies

### Required Systems
- UI System (for dialogue UI)
- Quest System (for quest conditions/actions)
- Inventory System (for item conditions/actions)
- Progression System (for level conditions)

### Systems That Depend on This
- NPC System
- Quest System (dialogue objectives)

---

## Notes

- Dialogue system is a core system for NPC interactions and quests
- Dialogue trees support complex branching conversations
- Conditions and actions make dialogues dynamic and interactive
- Dialogue variables allow persistent state across conversations
- Integration with other systems makes dialogues meaningful and impactful

