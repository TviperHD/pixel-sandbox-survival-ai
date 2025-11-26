# Technical Specifications: Tutorial/Onboarding System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the tutorial/onboarding system with progressive/contextual tutorials (unlock as systems become relevant), hybrid format (text + visual indicators + interactive elements), hybrid triggers (automatic + contextual prompts), hybrid skipping (individual + all disable), hybrid tracking (completion + progress + replay), hybrid hints (contextual + help menu), and hybrid content delivery (single-step + multi-step). This system integrates with all game systems to provide contextual guidance.

---

## Research Notes

### Tutorial System Architecture Best Practices

**Research Findings:**
- Progressive tutorials reduce overwhelm
- Contextual tutorials appear when relevant
- Hybrid formats (text + visual + interactive) are most effective
- Skippable tutorials respect player agency
- Progress tracking prevents repetition
- Hints system helps players who get stuck

**Sources:**
- [Godot 4 UI System](https://docs.godotengine.org/en/stable/tutorials/ui/index.html) - UI implementation
- [Godot 4 Control Nodes](https://docs.godotengine.org/en/stable/classes/class_control.html) - UI controls
- General tutorial system patterns in games

**Implementation Approach:**
- TutorialManager singleton manages all tutorials
- Progressive unlocking based on game state
- Hybrid format support (text, visual, interactive)
- Automatic triggers + contextual prompts
- Skippable with settings option
- Progress tracking with replay support
- Hints system separate from tutorials

**Why This Approach:**
- Progressive tutorials reduce overwhelm
- Contextual triggers appear when relevant
- Hybrid formats accommodate different learning styles
- Skippable respects player agency
- Progress tracking prevents repetition
- Hints provide ongoing support

### Tutorial Trigger Best Practices

**Research Findings:**
- Automatic triggers for first-time encounters
- Contextual prompts detect when player is stuck
- Player actions can trigger tutorials
- System events can trigger tutorials

**Sources:**
- General tutorial trigger patterns
- Player behavior analysis techniques

**Implementation Approach:**
- Automatic triggers on first system encounter
- Contextual prompts based on player behavior
- Action-based triggers (player attempts action)
- Event-based triggers (system events)

**Why This Approach:**
- Automatic ensures critical tutorials aren't missed
- Contextual helps when player is stuck
- Action-based provides timely guidance
- Event-based covers system interactions

---

## Data Structures

### TutorialType

```gdscript
enum TutorialType {
    SINGLE_STEP,    # Simple tutorial, one step
    MULTI_STEP,     # Complex tutorial, multiple steps
    INTERACTIVE,    # Player must perform actions
    INFORMATIONAL   # Just information, no interaction required
}
```

### TutorialTrigger

```gdscript
enum TutorialTrigger {
    AUTOMATIC,          # Trigger automatically on first encounter
    CONTEXTUAL,         # Trigger when player seems stuck
    ACTION_BASED,       # Trigger when player attempts action
    EVENT_BASED,        # Trigger on system event
    MANUAL              # Player activates from menu
}
```

### TutorialStep

```gdscript
class_name TutorialStep
extends Resource

# Step Identification
@export var step_id: String  # Unique step ID
@export var step_name: String  # Display name
@export var step_order: int = 0  # Order in multi-step tutorial

# Content
@export var title: String = ""  # Step title
@export var description: String = ""  # Step description/text
@export var image: Texture2D  # Optional image
@export var video: String = ""  # Optional video path

# Visual Indicators
@export var highlight_target: String = ""  # Node path to highlight
@export var highlight_type: HighlightType = HighlightType.NONE
@export var arrow_target: String = ""  # Node path for arrow
@export var arrow_position: Vector2 = Vector2.ZERO  # Arrow position offset

enum HighlightType {
    NONE,           # No highlight
    GLOW,           # Glow effect
    PULSE,          # Pulse animation
    OUTLINE,        # Outline highlight
    OVERLAY         # Overlay highlight
}

# Interactive Requirements
@export var requires_action: bool = false  # Player must perform action
@export var action_type: String = ""  # Action ID to perform
@export var action_target: String = ""  # Target for action
@export var completion_condition: String = ""  # Custom condition script

# Navigation
@export var can_skip: bool = true  # Can skip this step
@export var auto_advance: bool = false  # Auto-advance when complete
@export var next_step_id: String = ""  # Next step (empty = end)
```

### TutorialData

```gdscript
class_name TutorialData
extends Resource

# Tutorial Identification
@export var tutorial_id: String  # Unique tutorial ID
@export var tutorial_name: String  # Display name
@export var tutorial_type: TutorialType = TutorialType.SINGLE_STEP

# Trigger Configuration
@export var trigger_type: TutorialTrigger = TutorialTrigger.AUTOMATIC
@export var trigger_condition: String = ""  # Condition script for trigger
@export var trigger_system: String = ""  # System that triggers (e.g., "inventory", "crafting")
@export var trigger_action: String = ""  # Action that triggers (e.g., "open_inventory")

# Prerequisites
@export var prerequisite_tutorials: Array[String] = []  # Tutorial IDs that must be completed
@export var prerequisite_systems: Array[String] = []  # Systems that must be unlocked

# Steps
@export var steps: Array[TutorialStep] = []  # Tutorial steps

# Visual Configuration
@export var ui_style: String = "default"  # UI style preset
@export var position: Vector2 = Vector2.ZERO  # Position on screen
@export var size: Vector2 = Vector2(400, 300)  # Size of tutorial UI

# Completion
@export var completion_reward: Dictionary = {}  # Optional reward on completion
@export var completion_message: String = ""  # Message shown on completion
```

### TutorialProgress

```gdscript
class_name TutorialProgress
extends RefCounted

var tutorial_id: String
var is_completed: bool = false
var current_step: int = 0  # Current step index
var steps_completed: Array[int] = []  # Completed step indices
var started_time: float = 0.0
var completed_time: float = 0.0
var times_viewed: int = 0
```

### HintData

```gdscript
class_name HintData
extends Resource

# Hint Identification
@export var hint_id: String  # Unique hint ID
@export var hint_name: String  # Display name
@export var hint_text: String  # Hint text

# Context
@export var context: String = ""  # When to show (e.g., "inventory_full", "low_health")
@export var context_condition: String = ""  # Custom condition script
@export var priority: int = 0  # Higher priority shown first

# Visual
@export var icon: Texture2D  # Optional icon
@export var highlight_target: String = ""  # Node path to highlight
@export var duration: float = 5.0  # How long to show (0 = until dismissed)
```

---

## Core Classes

### TutorialManager (Autoload Singleton)

```gdscript
class_name TutorialManager
extends Node

# Tutorial Registry
var tutorials: Dictionary = {}  # tutorial_id -> TutorialData
var tutorial_progress: Dictionary = {}  # tutorial_id -> TutorialProgress

# Active Tutorial State
var active_tutorial: TutorialData = null
var active_step: TutorialStep = null
var active_step_index: int = -1
var is_tutorial_active: bool = false

# Hints System
var hints: Dictionary = {}  # hint_id -> HintData
var active_hints: Array[HintData] = []
var contextual_hint_check_interval: float = 2.0

# Configuration
@export var tutorials_enabled: bool = true  # Master toggle
@export var skip_all_tutorials: bool = false  # Skip all tutorials setting
@export var hints_enabled: bool = true  # Hints system enabled
@export var contextual_hints_enabled: bool = true  # Contextual hints enabled

# References
var ui_manager: UIManager
var player: Node2D = null

# Visual Components
var tutorial_ui: Control = null
var hint_ui: Control = null
var highlight_overlay: Control = null

# Signals
signal tutorial_started(tutorial_id: String)
signal tutorial_step_started(tutorial_id: String, step_id: String)
signal tutorial_step_completed(tutorial_id: String, step_id: String)
signal tutorial_completed(tutorial_id: String)
signal tutorial_skipped(tutorial_id: String)
signal hint_shown(hint_id: String)
signal hint_dismissed(hint_id: String)

# Initialization
func _ready() -> void
func initialize() -> void

# Tutorial Management
func register_tutorial(tutorial_data: TutorialData) -> bool
func start_tutorial(tutorial_id: String, force: bool = false) -> bool
func skip_tutorial(tutorial_id: String) -> void
func skip_current_tutorial() -> void
func complete_tutorial(tutorial_id: String) -> void

# Tutorial Progress
func get_tutorial_progress(tutorial_id: String) -> TutorialProgress
func is_tutorial_completed(tutorial_id: String) -> bool
func get_completed_tutorials() -> Array[String]
func replay_tutorial(tutorial_id: String) -> bool

# Tutorial Steps
func start_step(step_index: int) -> void
func complete_step(step_index: int) -> void
func skip_step(step_index: int) -> void
func next_step() -> void
func previous_step() -> void

# Tutorial Triggers
func _process(delta: float) -> void
func check_tutorial_triggers() -> void
func check_automatic_triggers() -> void
func check_contextual_triggers() -> void
func check_action_triggers(action: String) -> void
func check_event_triggers(event: String) -> void

# Hints Management
func register_hint(hint_data: HintData) -> bool
func show_hint(hint_id: String) -> bool
func show_contextual_hint(context: String) -> bool
func dismiss_hint(hint_id: String) -> void
func get_help_menu_hints() -> Array[HintData]

# Visual Effects
func highlight_element(node_path: String, highlight_type: TutorialStep.HighlightType) -> void
func clear_highlight() -> void
func show_arrow(target_path: String, position: Vector2) -> void
func hide_arrow() -> void
```

---

## System Architecture

### Component Hierarchy

```
TutorialManager (Autoload Singleton)
├── TutorialData[] (Dictionary)
│   ├── TutorialStep[] (Array)
│   └── TutorialProgress (RefCounted)
├── HintData[] (Dictionary)
├── TutorialUI (Control)
│   ├── TutorialWindow (Control)
│   ├── StepContent (Control)
│   └── NavigationButtons (Control)
├── HintUI (Control)
│   └── HintDisplay (Control)
└── HighlightOverlay (Control)
    └── HighlightEffect (Node2D)
```

### Data Flow

1. **Tutorial Trigger:**
   ```
   System event or player action
   ├── TutorialManager checks triggers
   ├── Check if tutorial should show (not completed, prerequisites met)
   ├── Check if tutorials enabled
   ├── Start tutorial
   ├── Show tutorial UI
   └── tutorial_started.emit()
   ```

2. **Tutorial Step:**
   ```
   Step starts
   ├── Display step content (text, image, etc.)
   ├── Highlight target element (if specified)
   ├── Show arrow (if specified)
   ├── Wait for completion condition
   ├── Complete step
   ├── Advance to next step or complete tutorial
   └── tutorial_step_completed.emit()
   ```

3. **Contextual Hint:**
   ```
   Player seems stuck
   ├── Check contextual conditions
   ├── Find relevant hint
   ├── Show hint UI
   ├── Highlight relevant element
   ├── Auto-dismiss after duration
   └── hint_shown.emit()
   ```

---

## Algorithms

### Tutorial Trigger Algorithm

```gdscript
func _process(delta: float) -> void:
    if not tutorials_enabled or skip_all_tutorials:
        return
    
    if is_tutorial_active:
        return  # Don't trigger new tutorials while one is active
    
    # Check triggers periodically
    var time_since_last_check = get_meta("last_trigger_check", 0.0)
    time_since_last_check += delta
    
    if time_since_last_check >= 1.0:  # Check every second
        check_tutorial_triggers()
        set_meta("last_trigger_check", 0.0)
    else:
        set_meta("last_trigger_check", time_since_last_check)

func check_tutorial_triggers() -> void:
    check_automatic_triggers()
    
    if contextual_hints_enabled:
        check_contextual_triggers()

func check_automatic_triggers() -> void:
    for tutorial_id in tutorials:
        var tutorial = tutorials[tutorial_id]
        
        # Skip if already completed
        if is_tutorial_completed(tutorial_id):
            continue
        
        # Skip if prerequisites not met
        if not check_prerequisites(tutorial):
            continue
        
        # Check trigger type
        match tutorial.trigger_type:
            TutorialTrigger.AUTOMATIC:
                if check_automatic_condition(tutorial):
                    start_tutorial(tutorial_id)
                    return  # Only start one at a time
            
            TutorialTrigger.CONTEXTUAL:
                # Handled in check_contextual_triggers()
                pass
            
            TutorialTrigger.ACTION_BASED:
                # Handled when action occurs
                pass
            
            TutorialTrigger.EVENT_BASED:
                # Handled when event occurs
                pass

func check_automatic_condition(tutorial: TutorialData) -> bool:
    # Check if system is being used for first time
    if tutorial.trigger_system != "":
        var system_unlocked = check_system_unlocked(tutorial.trigger_system)
        var system_used = check_system_used(tutorial.trigger_system)
        
        # Trigger if system unlocked but not used yet
        return system_unlocked and not system_used
    
    # Check custom condition
    if tutorial.trigger_condition != "":
        return evaluate_condition(tutorial.trigger_condition)
    
    return false

func check_contextual_triggers() -> void:
    # Check if player seems stuck
    var stuck_conditions = detect_stuck_conditions()
    
    for condition in stuck_conditions:
        # Find relevant tutorial
        var tutorial = find_tutorial_for_context(condition)
        if tutorial:
            start_tutorial(tutorial.tutorial_id)
            return

func detect_stuck_conditions() -> Array[String]:
    var conditions: Array[String] = []
    
    # Check various stuck conditions
    if player:
        # Player hasn't moved in a while
        if player.get_meta("last_movement_time", 0.0) < Time.get_unix_time_from_system() - 30.0:
            conditions.append("player_stuck")
        
        # Player repeatedly failing action
        if player.get_meta("failed_action_count", 0) > 3:
            conditions.append("action_failed")
        
        # Player inventory full
        if InventoryManager and InventoryManager.is_inventory_full():
            conditions.append("inventory_full")
        
        # Player low health
        if SurvivalManager and SurvivalManager.get_health() < 0.3:
            conditions.append("low_health")
    
    return conditions
```

### Tutorial Step Algorithm

```gdscript
func start_step(step_index: int) -> void:
    if active_tutorial == null:
        return
    
    if step_index < 0 or step_index >= active_tutorial.steps.size():
        return
    
    active_step_index = step_index
    active_step = active_tutorial.steps[step_index]
    
    # Update progress
    var progress = get_tutorial_progress(active_tutorial.tutorial_id)
    progress.current_step = step_index
    
    # Show step UI
    show_step_ui(active_step)
    
    # Highlight target element
    if active_step.highlight_target != "":
        highlight_element(active_step.highlight_target, active_step.highlight_type)
    
    # Show arrow
    if active_step.arrow_target != "":
        show_arrow(active_step.arrow_target, active_step.arrow_position)
    
    # Emit signal
    tutorial_step_started.emit(active_tutorial.tutorial_id, active_step.step_id)
    
    # Check if interactive
    if active_step.requires_action:
        wait_for_action(active_step.action_type, active_step.action_target)
    elif active_step.auto_advance:
        # Auto-advance after delay
        await get_tree().create_timer(2.0).timeout
        next_step()

func complete_step(step_index: int) -> void:
    if active_tutorial == null:
        return
    
    var step = active_tutorial.steps[step_index]
    var progress = get_tutorial_progress(active_tutorial.tutorial_id)
    
    # Mark step as completed
    if step_index not in progress.steps_completed:
        progress.steps_completed.append(step_index)
    
    # Clear highlights
    clear_highlight()
    hide_arrow()
    
    # Emit signal
    tutorial_step_completed.emit(active_tutorial.tutorial_id, step.step_id)
    
    # Check if tutorial complete
    if step_index >= active_tutorial.steps.size() - 1:
        complete_tutorial(active_tutorial.tutorial_id)
    else:
        # Auto-advance if enabled
        if step.auto_advance:
            next_step()

func next_step() -> void:
    if active_tutorial == null:
        return
    
    var next_index = active_step_index + 1
    if next_index < active_tutorial.steps.size():
        start_step(next_index)
    else:
        complete_tutorial(active_tutorial.tutorial_id)
```

### Contextual Hint Algorithm

```gdscript
func show_contextual_hint(context: String) -> bool:
    if not hints_enabled or not contextual_hints_enabled:
        return false
    
    # Find hint for context
    var hint = find_hint_for_context(context)
    if hint == null:
        return false
    
    # Check if hint already shown recently
    if hint.get_meta("last_shown_time", 0.0) > Time.get_unix_time_from_system() - 60.0:
        return false  # Don't show same hint too frequently
    
    # Show hint
    show_hint(hint.hint_id)
    hint.set_meta("last_shown_time", Time.get_unix_time_from_system())
    
    return true

func find_hint_for_context(context: String) -> HintData:
    var best_hint: HintData = null
    var best_priority: int = -1
    
    for hint_id in hints:
        var hint = hints[hint_id]
        
        # Check if context matches
        if hint.context == context or evaluate_hint_condition(hint, context):
            if hint.priority > best_priority:
                best_hint = hint
                best_priority = hint.priority
    
    return best_hint

func evaluate_hint_condition(hint: HintData, context: String) -> bool:
    if hint.context_condition == "":
        return false
    
    # Evaluate custom condition script
    # This would use a script evaluator or custom logic
    return false  # Placeholder
```

### Highlight Effect Algorithm

```gdscript
func highlight_element(node_path: String, highlight_type: TutorialStep.HighlightType) -> void:
    var target_node = get_node_or_null(node_path)
    if target_node == null:
        return
    
    # Create highlight overlay
    if highlight_overlay == null:
        highlight_overlay = Control.new()
        highlight_overlay.name = "TutorialHighlightOverlay"
        highlight_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
        get_tree().root.add_child(highlight_overlay)
    
    # Clear existing highlights
    clear_highlight()
    
    # Create highlight effect based on type
    match highlight_type:
        TutorialStep.HighlightType.GLOW:
            create_glow_effect(target_node)
        TutorialStep.HighlightType.PULSE:
            create_pulse_effect(target_node)
        TutorialStep.HighlightType.OUTLINE:
            create_outline_effect(target_node)
        TutorialStep.HighlightType.OVERLAY:
            create_overlay_effect(target_node)

func create_glow_effect(target: Node) -> void:
    # Create glow sprite/effect around target
    var glow = Sprite2D.new()
    glow.texture = preload("res://assets/ui/tutorial_glow.png")
    glow.modulate = Color(1.0, 1.0, 0.0, 0.5)  # Yellow glow
    glow.position = target.global_position
    highlight_overlay.add_child(glow)
    
    # Animate glow
    var tween = create_tween()
    tween.set_loops()
    tween.tween_property(glow, "modulate:a", 0.3, 0.5)
    tween.tween_property(glow, "modulate:a", 0.7, 0.5)

func create_pulse_effect(target: Node) -> void:
    # Create pulsing effect
    var pulse = Sprite2D.new()
    pulse.texture = preload("res://assets/ui/tutorial_pulse.png")
    pulse.position = target.global_position
    highlight_overlay.add_child(pulse)
    
    # Animate pulse
    var tween = create_tween()
    tween.set_loops()
    tween.tween_property(pulse, "scale", Vector2(1.2, 1.2), 0.5)
    tween.tween_property(pulse, "scale", Vector2(1.0, 1.0), 0.5)
```

---

## Integration Points

### With All Game Systems

```gdscript
# Tutorial triggers on system events
func on_system_event(system_name: String, event_name: String) -> void:
    # Check for tutorial triggers
    tutorial_manager.check_action_triggers(event_name)
    tutorial_manager.check_event_triggers(system_name + "_" + event_name)

# Examples:
# - Inventory opened → trigger inventory tutorial
# - Crafting station used → trigger crafting tutorial
# - First enemy encountered → trigger combat tutorial
```

### With UI System

```gdscript
# Tutorial UI integration
func show_tutorial_ui(tutorial_data: TutorialData) -> void:
    # Create tutorial UI overlay
    var tutorial_window = preload("res://scenes/ui/TutorialWindow.tscn").instantiate()
    ui_manager.add_ui_overlay(tutorial_window)
    tutorial_window.setup_tutorial(tutorial_data)

# Hint UI integration
func show_hint_ui(hint_data: HintData) -> void:
    # Create hint UI
    var hint_display = preload("res://scenes/ui/HintDisplay.tscn").instantiate()
    ui_manager.add_hint_overlay(hint_display)
    hint_display.setup_hint(hint_data)
```

### With Settings System

```gdscript
# Tutorial settings
func load_tutorial_settings() -> void:
    tutorials_enabled = SettingsManager.get_setting("tutorials_enabled", true)
    skip_all_tutorials = SettingsManager.get_setting("skip_all_tutorials", false)
    hints_enabled = SettingsManager.get_setting("hints_enabled", true)
    contextual_hints_enabled = SettingsManager.get_setting("contextual_hints_enabled", true)

func save_tutorial_settings() -> void:
    SettingsManager.set_setting("tutorials_enabled", tutorials_enabled)
    SettingsManager.set_setting("skip_all_tutorials", skip_all_tutorials)
    SettingsManager.set_setting("hints_enabled", hints_enabled)
    SettingsManager.set_setting("contextual_hints_enabled", contextual_hints_enabled)
```

---

## Save/Load System

### Save Data Structure

```gdscript
var tutorial_save_data: Dictionary = {
    "tutorial_progress": serialize_tutorial_progress(),
    "settings": serialize_tutorial_settings()
}

func serialize_tutorial_progress() -> Dictionary:
    var progress_data: Dictionary = {}
    for tutorial_id in tutorial_progress:
        var progress = tutorial_progress[tutorial_id]
        progress_data[tutorial_id] = {
            "is_completed": progress.is_completed,
            "current_step": progress.current_step,
            "steps_completed": progress.steps_completed,
            "started_time": progress.started_time,
            "completed_time": progress.completed_time,
            "times_viewed": progress.times_viewed
        }
    return progress_data

func serialize_tutorial_settings() -> Dictionary:
    return {
        "tutorials_enabled": tutorials_enabled,
        "skip_all_tutorials": skip_all_tutorials,
        "hints_enabled": hints_enabled,
        "contextual_hints_enabled": contextual_hints_enabled
    }
```

### Load Data Structure

```gdscript
func load_tutorial_data(data: Dictionary) -> void:
    if data.has("tutorial_progress"):
        load_tutorial_progress(data["tutorial_progress"])
    if data.has("settings"):
        load_tutorial_settings(data["settings"])

func load_tutorial_progress(progress_data: Dictionary) -> void:
    for tutorial_id in progress_data:
        var data = progress_data[tutorial_id]
        var progress = TutorialProgress.new()
        progress.tutorial_id = tutorial_id
        progress.is_completed = data.get("is_completed", false)
        progress.current_step = data.get("current_step", 0)
        progress.steps_completed = data.get("steps_completed", [])
        progress.started_time = data.get("started_time", 0.0)
        progress.completed_time = data.get("completed_time", 0.0)
        progress.times_viewed = data.get("times_viewed", 0)
        tutorial_progress[tutorial_id] = progress
```

---

## Error Handling

### TutorialManager Error Handling

- **Invalid Tutorial IDs:** Check tutorial exists before operations, return errors gracefully
- **Missing References:** Check references exist before using (ui_manager, player)
- **Invalid Node Paths:** Validate node paths before highlighting
- **Missing Prerequisites:** Check prerequisites before starting tutorial

### Best Practices

- Use `push_error()` for critical errors (invalid tutorial_id, missing references)
- Use `push_warning()` for non-critical issues (missing node paths, prerequisites not met)
- Return false/null on errors (don't crash)
- Validate all inputs before operations
- Fallback to defaults when data missing

---

## Default Values and Configuration

### TutorialManager Defaults

```gdscript
tutorials_enabled = true
skip_all_tutorials = false
hints_enabled = true
contextual_hints_enabled = true
contextual_hint_check_interval = 2.0
```

### TutorialData Defaults

```gdscript
tutorial_type = TutorialType.SINGLE_STEP
trigger_type = TutorialTrigger.AUTOMATIC
ui_style = "default"
position = Vector2.ZERO
size = Vector2(400, 300)
```

### TutorialStep Defaults

```gdscript
step_order = 0
highlight_type = HighlightType.NONE
requires_action = false
can_skip = true
auto_advance = false
```

---

## Performance Considerations

### Optimization Strategies

1. **Trigger Checks:**
   - Check triggers at intervals (not every frame)
   - Cache trigger conditions
   - Limit active tutorials (one at a time)
   - Skip checks when tutorials disabled

2. **Visual Effects:**
   - Limit active highlights
   - Use efficient highlight effects
   - Reuse highlight nodes when possible
   - Clean up effects when done

3. **UI Updates:**
   - Update UI only when needed
   - Cache UI elements
   - Use object pooling for hints
   - Limit active hints

4. **Memory Management:**
   - Unload completed tutorials
   - Limit history size
   - Clean up UI elements
   - Remove unused highlights

---

## Testing Checklist

### Tutorial System
- [ ] Tutorials register correctly
- [ ] Tutorials trigger correctly (automatic, contextual, action-based, event-based)
- [ ] Tutorial steps progress correctly
- [ ] Tutorial completion works
- [ ] Tutorial skipping works (individual + all)
- [ ] Tutorial replay works

### Progress Tracking
- [ ] Progress saves correctly
- [ ] Progress loads correctly
- [ ] Multi-step progress tracks correctly
- [ ] Completed tutorials don't retrigger

### Visual Effects
- [ ] Highlights display correctly
- [ ] Arrows display correctly
- [ ] Effects clear correctly
- [ ] Multiple highlight types work

### Hints System
- [ ] Hints register correctly
- [ ] Contextual hints trigger correctly
- [ ] Help menu displays hints correctly
- [ ] Hints dismiss correctly

### Integration
- [ ] Integrates with all game systems correctly
- [ ] Integrates with UI System correctly
- [ ] Integrates with Settings System correctly
- [ ] Save/load works correctly

---

## Complete Implementation

### TutorialManager Initialization

```gdscript
func _ready() -> void:
    # Get references
    ui_manager = get_node_or_null("/root/UIManager")
    player = get_tree().get_first_node_in_group("player")
    
    # Initialize
    initialize()

func initialize() -> void:
    # Load tutorials
    load_all_tutorials()
    
    # Load hints
    load_all_hints()
    
    # Load settings
    load_tutorial_settings()
    
    # Load progress
    # Progress loaded from save system

func load_all_tutorials() -> void:
    var tutorial_dir = DirAccess.open("res://resources/tutorials/")
    if tutorial_dir:
        tutorial_dir.list_dir_begin()
        var file_name = tutorial_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var tutorial_data = load("res://resources/tutorials/" + file_name) as TutorialData
                if tutorial_data:
                    register_tutorial(tutorial_data)
            file_name = tutorial_dir.get_next()

func load_all_hints() -> void:
    var hint_dir = DirAccess.open("res://resources/hints/")
    if hint_dir:
        hint_dir.list_dir_begin()
        var file_name = hint_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var hint_data = load("res://resources/hints/" + file_name) as HintData
                if hint_data:
                    register_hint(hint_data)
            file_name = hint_dir.get_next()
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── resources/
   │   ├── tutorials/
   │   │   └── (tutorial data resource files)
   │   └── hints/
   │       └── (hint data resource files)
   ├── scenes/
   │   └── ui/
   │       ├── TutorialWindow.tscn
   │       └── HintDisplay.tscn
   └── scripts/
       └── managers/
           └── TutorialManager.gd
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/TutorialManager.gd` as `TutorialManager`
   - **Important:** Load after UIManager and other game systems

3. **Create Tutorial Resources:**
   - Right-click in `res://resources/tutorials/`
   - Select "New Resource" → "TutorialData"
   - Fill in tutorial_id, steps, triggers, etc.
   - Save as `{tutorial_id}.tres`

4. **Create Hint Resources:**
   - Right-click in `res://resources/hints/`
   - Select "New Resource" → "HintData"
   - Fill in hint_id, hint_text, context, etc.
   - Save as `{hint_id}.tres`

### Initialization Order

**Autoload Order:**
1. GameManager
2. UIManager
3. All other game systems
4. **TutorialManager** (after all dependencies)

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Tutorial/Onboarding System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Control Nodes:** https://docs.godotengine.org/en/stable/classes/class_control.html
- **UI System:** https://docs.godotengine.org/en/stable/tutorials/ui/index.html
- **Tween:** https://docs.godotengine.org/en/stable/classes/class_tween.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Tutorial/Onboarding System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Control Nodes Documentation](https://docs.godotengine.org/en/stable/classes/class_control.html) - UI controls
- [UI System Tutorial](https://docs.godotengine.org/en/stable/tutorials/ui/index.html) - UI implementation
- [Tween Documentation](https://docs.godotengine.org/en/stable/classes/class_tween.html) - Animation system
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- TutorialData is a Resource (can be created/edited in inspector)
- TutorialStep is a Resource (can be created/edited in inspector)
- HintData is a Resource (can be created/edited in inspector)
- Tutorial properties editable in inspector

**Visual Configuration:**
- Step content editable in inspector
- Visual indicators configurable
- Trigger conditions configurable

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Tutorial preview (visualize tutorial flow)
  - Step editor (visual step creation)
  - Trigger tester (test tutorial triggers)
  - Highlight preview (preview highlight effects)

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Tutorials created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Progressive Tutorials:** Tutorials unlock as systems become relevant
2. **Hybrid Format:** Mix of text, visual indicators, and interactive elements
3. **Hybrid Triggers:** Automatic + contextual prompts
4. **Skippable:** Can skip individual tutorials or disable all
5. **Progress Tracking:** Tracks completion and progress within multi-step tutorials
6. **Replay Support:** Completed tutorials can be replayed from menu
7. **Hints System:** Separate hints system with contextual hints + help menu
8. **Hybrid Content:** Single-step for simple systems, multi-step for complex systems

