# Technical Specifications: Debug/Development Tools System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the debug/development tools system with advanced console (command system with variables and scripting), comprehensive debug tools (scene inspector, object spawner, teleportation, visualizers, pathfinding debug, AI debug), comprehensive debug camera (free-fly, no clipping, speed control, follow targets, save positions, camera paths, recording, screenshot mode), comprehensive time control (pause, slow motion, fast forward, frame-by-frame, time scale control, rewind, time markers, time-based events debug), comprehensive scene inspector (live editing, property watching, search/filter), comprehensive debug logging (log viewer, search, export, remote logging), advanced test mode (test scripts, automated test runs, test reports), and comprehensive help/documentation. Console is always available, debug commands require settings toggle.

---

## Research Notes

### Debug Console Best Practices

**Research Findings:**
- Advanced console with command system and variables (CVars) is industry standard
- Scripting support enables complex debugging operations
- Command history and autocomplete improve usability
- Real-time parameter adjustment without recompilation speeds development
- Integration with scripting languages enhances flexibility

**Sources:**
- [Godot 4 Console Implementation](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html) - GDScript for console commands
- General game debug console best practices
- Quake-style console command systems

**Implementation Approach:**
- Advanced console with command registration system
- CVar system for runtime variable tweaking
- GDScript execution for scripting support
- Command history and autocomplete
- Syntax highlighting for better readability

**Why This Approach:**
- Industry-standard approach (Quake-style console)
- Enables rapid iteration without recompilation
- Scripting support enables complex operations
- User-friendly with history and autocomplete

### Debug Tools Best Practices

**Research Findings:**
- Debug camera essential for world inspection
- Time control crucial for debugging time-dependent systems
- Scene inspector enables runtime property editing
- Visualizations help understand complex systems
- Comprehensive tools reduce debugging time significantly

**Sources:**
- General game development debug tools best practices
- Unity/Unreal debug tool patterns

**Implementation Approach:**
- Comprehensive debug camera (free-fly, recording, paths)
- Comprehensive time control (pause, rewind, frame-by-frame)
- Comprehensive scene inspector (live editing, property watching)
- Comprehensive visualizations (all systems)
- All tools accessible from single console

**Why This Approach:**
- Reduces debugging time significantly
- Enables rapid iteration
- Helps understand complex systems
- Industry-standard toolset

---

## Data Structures

### ConsoleCommand

```gdscript
class_name ConsoleCommand
extends RefCounted

var command_name: String  # Command name (e.g., "spawn", "teleport")
var description: String = ""  # Command description
var category: String = "general"  # Command category
var parameters: Array[CommandParameter] = []  # Command parameters
var function: Callable  # Function to execute
var aliases: Array[String] = []  # Command aliases
var help_text: String = ""  # Detailed help text
var example: String = ""  # Usage example

class CommandParameter:
    var name: String
    var type: ParameterType
    var required: bool = true
    var default_value: Variant = null
    var description: String = ""
    
    enum ParameterType {
        STRING,
        INT,
        FLOAT,
        BOOL,
        VECTOR2,
        VECTOR3,
        NODE_PATH,
        OBJECT
    }
```

### ConsoleVariable (CVar)

```gdscript
class_name ConsoleVariable
extends RefCounted

var variable_name: String  # Variable name (e.g., "player_speed")
var value: Variant  # Current value
var default_value: Variant  # Default value
var type: VariableType  # Variable type
var category: String = "general"  # Variable category
var description: String = ""  # Variable description
var min_value: Variant = null  # Minimum value (if numeric)
var max_value: Variant = null  # Maximum value (if numeric)
var callback: Callable = Callable()  # Callback when value changes
var is_readonly: bool = false  # Is variable read-only

enum VariableType {
    STRING,
    INT,
    FLOAT,
    BOOL,
    VECTOR2,
    VECTOR3,
    COLOR
}
```

### DebugCameraState

```gdscript
class_name DebugCameraState
extends RefCounted

var position: Vector3 = Vector3.ZERO
var rotation: Vector3 = Vector3.ZERO
var fov: float = 75.0
var speed: float = 500.0
var follow_target: Node3D = null
var saved_name: String = ""  # Name for saved position
```

### TimeControlState

```gdscript
class_name TimeControlState
extends RefCounted

var time_scale: float = 1.0  # Time scale multiplier
var is_paused: bool = false
var frame_step_mode: bool = false  # Frame-by-frame mode
var time_markers: Array[Dictionary] = []  # Time markers for debugging
var rewind_enabled: bool = false
var rewind_buffer_size: int = 300  # Frames to keep for rewind
```

### DebugVisualization

```gdscript
class_name DebugVisualization
extends RefCounted

var visualization_id: String  # Unique ID
var visualization_type: VisualizationType
var enabled: bool = false
var color: Color = Color.WHITE
var thickness: float = 1.0
var duration: float = 0.0  # 0 = permanent, >0 = temporary

enum VisualizationType {
    COLLISION_SHAPE,
    RAYCAST,
    PATHFINDING_PATH,
    AI_STATE,
    PHYSICS_FORCE,
    NETWORK_CONNECTION,
    CHUNK_BOUNDARY,
    SPAWN_ZONE,
    CUSTOM
}
```

### TestScript

```gdscript
class_name TestScript
extends RefCounted

var test_name: String  # Test name
var test_id: String  # Unique test ID
var test_category: String = "general"  # Test category
var script_path: String = ""  # Path to test script
var description: String = ""  # Test description
var timeout: float = 60.0  # Test timeout in seconds
var prerequisites: Array[String] = []  # Required tests to run first
```

### TestResult

```gdscript
class_name TestResult
extends RefCounted

var test_id: String
var test_name: String
var passed: bool = false
var execution_time: float = 0.0
var error_message: String = ""
var assertions_passed: int = 0
var assertions_failed: int = 0
var details: Dictionary = {}  # Additional test details
```

---

## Core Classes

### DebugConsole (Autoload Singleton)

```gdscript
class_name DebugConsole
extends Control

# Console State
var is_open: bool = false
var is_visible: bool = false
var debug_commands_enabled: bool = false  # Requires settings toggle

# Commands and Variables
var commands: Dictionary = {}  # command_name -> ConsoleCommand
var variables: Dictionary = {}  # variable_name -> ConsoleVariable
var command_history: Array[String] = []  # Command history
var history_index: int = -1  # Current history position
var max_history_size: int = 100

# UI Components
var input_line: LineEdit = null
var output_panel: RichTextLabel = null
var autocomplete_panel: VBoxContainer = null

# Autocomplete
var current_autocomplete: Array[String] = []
var autocomplete_index: int = -1

# Scripting
var script_executor: ScriptExecutor = null

# References
var scene_inspector: SceneInspector = null
var debug_camera: DebugCamera = null
var time_controller: TimeController = null
var visualization_manager: VisualizationManager = null
var test_runner: TestRunner = null

# Signals
signal command_executed(command_name: String, success: bool)
signal variable_changed(variable_name: String, old_value: Variant, new_value: Variant)
signal console_opened()
signal console_closed()

# Initialization
func _ready() -> void
func initialize() -> void

# Console Control
func open_console() -> void
func close_console() -> void
func toggle_console() -> void
func set_visible(visible: bool) -> void

# Command Management
func register_command(command: ConsoleCommand) -> bool
func unregister_command(command_name: String) -> bool
func execute_command(command_string: String) -> bool
func parse_command(command_string: String) -> Dictionary  # Returns {command: String, args: Array}
func get_command(command_name: String) -> ConsoleCommand
func get_commands_by_category(category: String) -> Array[ConsoleCommand]
func get_all_commands() -> Array[ConsoleCommand]

# Variable Management
func register_variable(variable: ConsoleVariable) -> bool
func set_variable(variable_name: String, value: Variant) -> bool
func get_variable(variable_name: String) -> Variant
func get_variable_object(variable_name: String) -> ConsoleVariable
func get_variables_by_category(category: String) -> Array[ConsoleVariable]

# Autocomplete
func update_autocomplete(input: String) -> void
func select_autocomplete(index: int) -> void
func get_autocomplete_suggestions(input: String) -> Array[String]

# Command History
func add_to_history(command: String) -> void
func get_history_previous() -> String
func get_history_next() -> String

# Help System
func show_help(command_name: String = "") -> void
func search_help(query: String) -> Array[Dictionary]  # Returns help entries
func get_command_help(command_name: String) -> String

# Scripting
func execute_script(script_path: String) -> bool
func execute_script_string(script_code: String) -> bool
```

### SceneInspector

```gdscript
class_name SceneInspector
extends Node

# Inspector State
var selected_node: Node = null
var inspector_open: bool = false

# Property Watching
var watched_properties: Dictionary = {}  # node_path.property -> watch_info
var property_history: Dictionary = {}  # node_path.property -> Array[values]

# Search
var search_query: String = ""
var search_results: Array[Node] = []

# Functions
func inspect_node(node: Node) -> void
func select_node(node_path: NodePath) -> void
func edit_property(node_path: NodePath, property: String, value: Variant) -> bool
func watch_property(node_path: NodePath, property: String) -> void
func unwatch_property(node_path: NodePath, property: String) -> void
func search_nodes(query: String) -> Array[Node]
func get_node_hierarchy(root: Node) -> Dictionary
func get_node_properties(node: Node) -> Dictionary
func copy_property(node_path: NodePath, property: String) -> Variant
func paste_property(node_path: NodePath, property: String, value: Variant) -> bool
```

### DebugCamera

```gdscript
class_name DebugCamera
extends Camera3D

# Camera State
var is_active: bool = false
var free_fly_mode: bool = true
var no_clip: bool = true
var speed: float = 500.0
var fast_speed: float = 2000.0
var slow_speed: float = 100.0

# Follow Target
var follow_target: Node3D = null
var follow_offset: Vector3 = Vector3.ZERO
var follow_smooth: float = 0.1

# Saved Positions
var saved_positions: Dictionary = {}  # name -> DebugCameraState

# Camera Paths
var camera_paths: Array[CameraPath] = []
var current_path: CameraPath = null
var path_playing: bool = false

# Recording
var is_recording: bool = false
var recording_frames: Array[Dictionary] = []

# Screenshot Mode
var screenshot_mode: bool = false
var screenshot_resolution: Vector2i = Vector2i(1920, 1080)

# Functions
func activate() -> void
func deactivate() -> void
func set_free_fly(enabled: bool) -> void
func set_no_clip(enabled: bool) -> void
func set_speed(new_speed: float) -> void
func save_position(name: String) -> void
func load_position(name: String) -> bool
func follow_node(node: Node3D, offset: Vector3 = Vector3.ZERO) -> void
func stop_following() -> void
func create_path(name: String) -> CameraPath
func play_path(path_name: String) -> void
func stop_path() -> void
func start_recording() -> void
func stop_recording() -> void
func take_screenshot(path: String = "") -> void
```

### TimeController

```gdscript
class_name TimeController
extends Node

# Time State
var time_scale: float = 1.0
var is_paused: bool = false
var frame_step_mode: bool = false
var frame_step_requested: bool = false

# Rewind
var rewind_enabled: bool = false
var rewind_buffer: Array[Dictionary] = []  # Game state snapshots
var max_rewind_frames: int = 300

# Time Markers
var time_markers: Array[Dictionary] = []  # {time: float, name: String, description: String}

# Functions
func set_time_scale(scale: float) -> void
func pause() -> void
func resume() -> void
func toggle_pause() -> void
func set_frame_step_mode(enabled: bool) -> void
func step_frame() -> void
func enable_rewind(enabled: bool) -> void
func rewind_to_frame(frame: int) -> bool
func add_time_marker(name: String, description: String = "") -> void
func jump_to_marker(marker_name: String) -> bool
func get_time_markers() -> Array[Dictionary]
```

### VisualizationManager

```gdscript
class_name VisualizationManager
extends Node

# Visualizations
var active_visualizations: Dictionary = {}  # visualization_id -> DebugVisualization
var visualization_nodes: Dictionary = {}  # visualization_id -> Node2D/Node3D

# Functions
func add_visualization(visualization: DebugVisualization) -> void
func remove_visualization(visualization_id: String) -> void
func toggle_visualization(visualization_id: String) -> void
func enable_visualization(visualization_id: String, enabled: bool) -> void
func clear_all_visualizations() -> void

# Specific Visualizations
func visualize_collision_shapes(enabled: bool) -> void
func visualize_raycasts(enabled: bool) -> void
func visualize_pathfinding(enabled: bool) -> void
func visualize_ai_state(enabled: bool) -> void
func visualize_physics_forces(enabled: bool) -> void
func visualize_network_connections(enabled: bool) -> void
func visualize_chunk_boundaries(enabled: bool) -> void
func visualize_spawn_zones(enabled: bool) -> void
```

### TestRunner

```gdscript
class_name TestRunner
extends Node

# Test Registry
var test_scripts: Dictionary = {}  # test_id -> TestScript
var test_results: Array[TestResult] = []

# Test Execution
var is_running: bool = false
var current_test: TestScript = null
var test_queue: Array[String] = []

# Functions
func register_test(test: TestScript) -> bool
func run_test(test_id: String) -> TestResult
func run_tests(test_ids: Array[String] = []) -> Array[TestResult]  # Empty = run all
func run_tests_by_category(category: String) -> Array[TestResult]
func generate_test_report(results: Array[TestResult]) -> Dictionary
func export_test_report(results: Array[TestResult], path: String) -> bool
```

### DebugLogger

```gdscript
class_name DebugLogger
extends Node

# Logging State
var logs: Array[Dictionary] = []  # Log entries
var max_logs: int = 10000
var log_levels: Array[String] = ["DEBUG", "INFO", "WARNING", "ERROR", "FATAL"]

# Filtering
var enabled_categories: Array[String] = []  # Empty = all enabled
var enabled_levels: Array[String] = []  # Empty = all enabled
var search_query: String = ""

# File Logging
var file_logging_enabled: bool = false
var log_file: FileAccess = null
var log_file_path: String = ""

# Remote Logging
var remote_logging_enabled: bool = false
var remote_logging_url: String = ""

# Functions
func log(message: String, level: String = "INFO", category: String = "general") -> void
func debug(message: String, category: String = "general") -> void
func info(message: String, category: String = "general") -> void
func warning(message: String, category: String = "general") -> void
func error(message: String, category: String = "general") -> void
func fatal(message: String, category: String = "general") -> void

func get_logs(filter: Dictionary = {}) -> Array[Dictionary]
func search_logs(query: String) -> Array[Dictionary]
func clear_logs() -> void
func export_logs(path: String, format: String = "txt") -> bool
func enable_file_logging(enabled: bool, file_path: String = "") -> void
func enable_remote_logging(enabled: bool, url: String = "") -> void
```

---

## System Architecture

### Component Hierarchy

```
DebugConsole (Autoload Singleton)
├── SceneInspector
├── DebugCamera
├── TimeController
├── VisualizationManager
├── TestRunner
├── DebugLogger
└── ScriptExecutor
```

### Data Flow

1. **Console Command Execution:**
   ```
   User types command
   ├── Parse command string
   ├── Check if command exists
   ├── Check if debug commands enabled (if debug command)
   ├── Validate parameters
   ├── Execute command function
   ├── Display result
   └── Add to history
   ```

2. **Variable Change:**
   ```
   User changes CVar
   ├── Validate new value
   ├── Update variable value
   ├── Execute callback (if set)
   ├── Update affected systems
   └── variable_changed.emit()
   ```

3. **Test Execution:**
   ```
   Run test
   ├── Load test script
   ├── Setup test environment
   ├── Execute test script
   ├── Collect results
   ├── Generate report
   └── Display results
   ```

---

## Algorithms

### Command Parsing Algorithm

```gdscript
func parse_command(command_string: String) -> Dictionary:
    # Trim whitespace
    command_string = command_string.strip_edges()
    if command_string.is_empty():
        return {"command": "", "args": []}
    
    # Split by spaces (handle quoted strings)
    var parts: Array[String] = []
    var current_part: String = ""
    var in_quotes: bool = false
    
    for i in range(command_string.length()):
        var char = command_string[i]
        
        if char == '"':
            in_quotes = not in_quotes
        elif char == ' ' and not in_quotes:
            if not current_part.is_empty():
                parts.append(current_part)
                current_part = ""
        else:
            current_part += char
    
    if not current_part.is_empty():
        parts.append(current_part)
    
    if parts.is_empty():
        return {"command": "", "args": []}
    
    var command = parts[0]
    var args = parts.slice(1)
    
    return {"command": command, "args": args}

func execute_command(command_string: String) -> bool:
    var parsed = parse_command(command_string)
    var command_name = parsed["command"]
    var args = parsed["args"]
    
    if command_name.is_empty():
        return false
    
    # Check if command exists
    if not commands.has(command_name):
        # Check aliases
        for cmd_name in commands:
            var cmd = commands[cmd_name]
            if command_name in cmd.aliases:
                command_name = cmd_name
                break
        
        if not commands.has(command_name):
            output_error("Unknown command: " + command_name)
            return false
    
    var command = commands[command_name]
    
    # Check if debug command requires debug mode
    if command.category == "debug" and not debug_commands_enabled:
        output_error("Debug commands are disabled. Enable in settings.")
        return false
    
    # Validate parameters
    if not validate_parameters(command, args):
        output_error("Invalid parameters for command: " + command_name)
        show_help(command_name)
        return false
    
    # Execute command
    var result = command.function.callv(args)
    
    # Display result
    if result != null:
        output_info(str(result))
    
    command_executed.emit(command_name, true)
    return true

func validate_parameters(command: ConsoleCommand, args: Array[String]) -> bool:
    var required_params = 0
    for param in command.parameters:
        if param.required:
            required_params += 1
    
    if args.size() < required_params:
        return false
    
    # Type validation
    for i in range(min(args.size(), command.parameters.size())):
        var arg = args[i]
        var param = command.parameters[i]
        
        match param.type:
            ConsoleCommand.CommandParameter.ParameterType.INT:
                if not arg.is_valid_int():
                    return false
            ConsoleCommand.CommandParameter.ParameterType.FLOAT:
                if not arg.is_valid_float():
                    return false
            ConsoleCommand.CommandParameter.ParameterType.BOOL:
                if arg not in ["true", "false", "1", "0"]:
                    return false
            # Add more type validations as needed
    
    return true
```

### Autocomplete Algorithm

```gdscript
func update_autocomplete(input: String) -> void:
    if input.is_empty():
        autocomplete_panel.visible = false
        return
    
    var suggestions: Array[String] = []
    
    # Check if input looks like a command
    var parts = input.split(" ", false)
    if parts.size() == 1:
        # Command autocomplete
        var prefix = parts[0].to_lower()
        for cmd_name in commands:
            if cmd_name.to_lower().begins_with(prefix):
                suggestions.append(cmd_name)
    else:
        # Parameter autocomplete (command-specific)
        var command_name = parts[0].to_lower()
        if commands.has(command_name):
            var command = commands[command_name]
            # Command-specific autocomplete logic
            # (e.g., node paths, item IDs, etc.)
    
    # Also check variables
    for var_name in variables:
        if var_name.to_lower().begins_with(input.to_lower()):
            suggestions.append("$" + var_name)  # $ prefix for variables
    
    current_autocomplete = suggestions
    autocomplete_index = -1
    
    if suggestions.size() > 0:
        display_autocomplete(suggestions)
    else:
        autocomplete_panel.visible = false

func display_autocomplete(suggestions: Array[String]) -> void:
    autocomplete_panel.visible = true
    
    # Clear existing items
    for child in autocomplete_panel.get_children():
        child.queue_free()
    
    # Display suggestions (limit to 10)
    var display_count = min(suggestions.size(), 10)
    for i in range(display_count):
        var label = Label.new()
        label.text = suggestions[i]
        autocomplete_panel.add_child(label)
```

### Scene Inspector Property Editing Algorithm

```gdscript
func edit_property(node_path: NodePath, property: String, value: Variant) -> bool:
    var node = get_node_or_null(node_path)
    if node == null:
        return false
    
    # Check if property exists
    if not node.has(property):
        return false
    
    # Get current value
    var current_value = node.get(property)
    var current_type = typeof(current_value)
    var new_type = typeof(value)
    
    # Type conversion if needed
    if current_type != new_type:
        value = convert_value(value, current_type)
        if value == null:
            return false
    
    # Validate value (if numeric, check min/max)
    if current_type == TYPE_INT or current_type == TYPE_FLOAT:
        var property_info = node.get_property_list()
        for prop_info in property_info:
            if prop_info["name"] == property:
                if prop_info.has("hint") and prop_info["hint"] == PROPERTY_HINT_RANGE:
                    var range_values = prop_info["hint_string"].split(",")
                    if range_values.size() >= 2:
                        var min_val = float(range_values[0])
                        var max_val = float(range_values[1])
                        value = clamp(value, min_val, max_val)
                break
    
    # Set property
    node.set(property, value)
    
    # If watching, update history
    var watch_key = str(node_path) + "." + property
    if watched_properties.has(watch_key):
        if not property_history.has(watch_key):
            property_history[watch_key] = []
        property_history[watch_key].append({
            "value": value,
            "time": Time.get_ticks_msec()
        })
        # Limit history size
        if property_history[watch_key].size() > 100:
            property_history[watch_key].pop_front()
    
    return true
```

### Test Execution Algorithm

```gdscript
func run_test(test_id: String) -> TestResult:
    if not test_scripts.has(test_id):
        var result = TestResult.new()
        result.test_id = test_id
        result.passed = false
        result.error_message = "Test not found: " + test_id
        return result
    
    var test = test_scripts[test_id]
    var result = TestResult.new()
    result.test_id = test_id
    result.test_name = test.test_name
    
    # Check prerequisites
    for prereq_id in test.prerequisites:
        if not test_scripts.has(prereq_id):
            result.passed = false
            result.error_message = "Prerequisite test not found: " + prereq_id
            return result
        
        # Run prerequisite if not already run
        var prereq_result = run_test(prereq_id)
        if not prereq_result.passed:
            result.passed = false
            result.error_message = "Prerequisite test failed: " + prereq_id
            return result
    
    # Load and execute test script
    var start_time = Time.get_ticks_msec()
    
    if test.script_path.is_empty():
        result.passed = false
        result.error_message = "Test script path is empty"
        return result
    
    var script = load(test.script_path) as GDScript
    if script == null:
        result.passed = false
        result.error_message = "Failed to load test script"
        return result
    
    # Create test instance
    var test_instance = script.new()
    if test_instance == null:
        result.passed = false
        result.error_message = "Failed to instantiate test script"
        return result
    
    # Execute test
    if test_instance.has_method("run_test"):
        var test_passed = test_instance.run_test()
        result.passed = test_passed
        
        # Collect assertion results
        if test_instance.has_method("get_assertion_results"):
            var assertion_results = test_instance.get_assertion_results()
            result.assertions_passed = assertion_results.get("passed", 0)
            result.assertions_failed = assertion_results.get("failed", 0)
    else:
        result.passed = false
        result.error_message = "Test script missing run_test() method"
    
    var end_time = Time.get_ticks_msec()
    result.execution_time = (end_time - start_time) / 1000.0
    
    # Cleanup
    test_instance.queue_free()
    
    return result
```

---

## Integration Points

### With All Game Systems

```gdscript
# All systems can register debug commands
func register_system_commands(system_name: String) -> void:
    # Example: Register spawn command
    var spawn_command = ConsoleCommand.new()
    spawn_command.command_name = "spawn"
    spawn_command.description = "Spawn an item or entity"
    spawn_command.category = "world"
    spawn_command.parameters = [
        ConsoleCommand.CommandParameter.new("type", ConsoleCommand.CommandParameter.ParameterType.STRING, true),
        ConsoleCommand.CommandParameter.new("quantity", ConsoleCommand.CommandParameter.ParameterType.INT, false, 1)
    ]
    spawn_command.function = spawn_item_command
    spawn_command.help_text = "Spawns an item or entity in the world.\nUsage: spawn <type> [quantity]"
    spawn_command.example = "spawn iron_ore 10"
    debug_console.register_command(spawn_command)

func spawn_item_command(args: Array[String]) -> Variant:
    if args.size() < 1:
        return "Error: Missing item type"
    
    var item_type = args[0]
    var quantity = int(args[1]) if args.size() > 1 else 1
    
    # Spawn logic
    # ...
    
    return "Spawned " + str(quantity) + "x " + item_type
```

### With Settings System

```gdscript
# Debug commands enabled setting
func load_debug_settings() -> void:
    debug_commands_enabled = SettingsManager.get_setting("debug_commands_enabled", false)

func save_debug_settings() -> void:
    SettingsManager.set_setting("debug_commands_enabled", debug_commands_enabled)
```

---

## Save/Load System

### Save Data Structure

```gdscript
var debug_tools_save_data: Dictionary = {
    "console_history": command_history,
    "saved_camera_positions": serialize_camera_positions(),
    "saved_variables": serialize_variables(),
    "time_markers": serialize_time_markers()
}

func serialize_camera_positions() -> Dictionary:
    var positions_data: Dictionary = {}
    for name in debug_camera.saved_positions:
        var state = debug_camera.saved_positions[name]
        positions_data[name] = {
            "position": {"x": state.position.x, "y": state.position.y, "z": state.position.z},
            "rotation": {"x": state.rotation.x, "y": state.rotation.y, "z": state.rotation.z},
            "fov": state.fov
        }
    return positions_data

func serialize_variables() -> Dictionary:
    var variables_data: Dictionary = {}
    for var_name in variables:
        var cvar = variables[var_name]
        variables_data[var_name] = {
            "value": cvar.value,
            "category": cvar.category
        }
    return variables_data
```

### Load Data Structure

```gdscript
func load_debug_tools_data(data: Dictionary) -> void:
    if data.has("console_history"):
        command_history = data["console_history"]
    if data.has("saved_camera_positions"):
        load_camera_positions(data["saved_camera_positions"])
    if data.has("saved_variables"):
        load_variables(data["saved_variables"])
    if data.has("time_markers"):
        load_time_markers(data["time_markers"])
```

---

## Error Handling

### DebugConsole Error Handling

- **Invalid Commands:** Show error message, suggest similar commands
- **Invalid Parameters:** Show error message, display command help
- **Script Execution Errors:** Catch and display script errors
- **Variable Validation:** Validate variable values before setting

### Best Practices

- Use `push_error()` for critical errors (script execution failures)
- Use `push_warning()` for non-critical issues (invalid parameters)
- Return false/null on errors (don't crash)
- Validate all inputs before operations
- Provide helpful error messages with suggestions

---

## Default Values and Configuration

### DebugConsole Defaults

```gdscript
max_history_size = 100
debug_commands_enabled = false  # Must be enabled in settings
```

### DebugCamera Defaults

```gdscript
speed = 500.0
fast_speed = 2000.0
slow_speed = 100.0
fov = 75.0
```

### TimeController Defaults

```gdscript
time_scale = 1.0
max_rewind_frames = 300
```

---

## Performance Considerations

### Optimization Strategies

1. **Console Rendering:**
   - Limit output panel text (scroll old text out)
   - Use RichTextLabel efficiently
   - Limit autocomplete suggestions (max 10)

2. **Visualizations:**
   - Disable when not visible
   - Use efficient drawing (immediate mode)
   - Limit visualization count

3. **Scene Inspector:**
   - Lazy load node properties
   - Cache property lists
   - Limit property history size

4. **Test Execution:**
   - Run tests asynchronously if possible
   - Limit test execution time
   - Clean up test instances promptly

---

## Testing Checklist

### Debug Console
- [ ] Console opens/closes correctly
- [ ] Commands register correctly
- [ ] Command execution works
- [ ] Parameter validation works
- [ ] Autocomplete works
- [ ] Command history works
- [ ] Help system works

### Debug Tools
- [ ] Scene inspector works
- [ ] Debug camera works
- [ ] Time control works
- [ ] Visualizations work
- [ ] Test runner works
- [ ] Debug logger works

### Integration
- [ ] Integrates with all game systems correctly
- [ ] Settings integration works
- [ ] Save/load works correctly

---

## Complete Implementation

### DebugConsole Initialization

```gdscript
func _ready() -> void:
    # Initialize components
    scene_inspector = SceneInspector.new()
    debug_camera = DebugCamera.new()
    time_controller = TimeController.new()
    visualization_manager = VisualizationManager.new()
    test_runner = TestRunner.new()
    script_executor = ScriptExecutor.new()
    
    add_child(scene_inspector)
    add_child(debug_camera)
    add_child(time_controller)
    add_child(visualization_manager)
    add_child(test_runner)
    add_child(script_executor)
    
    # Setup UI
    setup_ui()
    
    # Initialize
    initialize()

func initialize() -> void:
    # Load settings
    load_debug_settings()
    
    # Register default commands
    register_default_commands()
    
    # Register default variables
    register_default_variables()
    
    # Setup input
    setup_input()

func register_default_commands() -> void:
    # Help command
    var help_cmd = ConsoleCommand.new()
    help_cmd.command_name = "help"
    help_cmd.description = "Show help for commands"
    help_cmd.category = "general"
    help_cmd.parameters = [
        ConsoleCommand.CommandParameter.new("command", ConsoleCommand.CommandParameter.ParameterType.STRING, false)
    ]
    help_cmd.function = help_command
    help_cmd.help_text = "Shows help for commands. Use 'help <command>' for specific command help."
    help_cmd.example = "help spawn"
    register_command(help_cmd)
    
    # Clear command
    var clear_cmd = ConsoleCommand.new()
    clear_cmd.command_name = "clear"
    clear_cmd.description = "Clear console output"
    clear_cmd.category = "general"
    clear_cmd.function = clear_command
    register_command(clear_cmd)
    
    # Register system-specific commands
    register_world_commands()
    register_player_commands()
    register_item_commands()
    register_debug_commands()

func register_default_variables() -> void:
    # Player speed CVar
    var player_speed_var = ConsoleVariable.new()
    player_speed_var.variable_name = "player_speed"
    player_speed_var.value = 200.0
    player_speed_var.default_value = 200.0
    player_speed_var.type = ConsoleVariable.VariableType.FLOAT
    player_speed_var.category = "player"
    player_speed_var.description = "Player movement speed"
    player_speed_var.min_value = 50.0
    player_speed_var.max_value = 1000.0
    player_speed_var.callback = update_player_speed
    register_variable(player_speed_var)
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   ├── managers/
   │   │   └── DebugConsole.gd
   │   └── debug/
   │       ├── SceneInspector.gd
   │       ├── DebugCamera.gd
   │       ├── TimeController.gd
   │       ├── VisualizationManager.gd
   │       ├── TestRunner.gd
   │       └── DebugLogger.gd
   └── scenes/
       └── ui/
           └── DebugConsole.tscn
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/DebugConsole.gd` as `DebugConsole`
   - **Important:** Load early (can be first or second)

3. **Create Console UI Scene:**
   - Create new scene with Control as root
   - Add LineEdit for input
   - Add RichTextLabel for output
   - Add VBoxContainer for autocomplete
   - Attach DebugConsole script
   - Save as `scenes/ui/DebugConsole.tscn`

### Initialization Order

**Autoload Order:**
1. **DebugConsole** (early, can debug other systems)
2. GameManager
3. All other systems

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Debug/Development Tools System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **GDScript:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html
- **Input System:** https://docs.godotengine.org/en/stable/tutorials/inputs/index.html
- **Scene Tree:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/scene_tree.html
- **RichTextLabel:** https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Debug/Development Tools System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [GDScript Documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html) - Scripting for console commands
- [Input System](https://docs.godotengine.org/en/stable/tutorials/inputs/index.html) - Input handling
- [Scene Tree](https://docs.godotengine.org/en/stable/getting_started/step_by_step/scene_tree.html) - Scene inspection
- [RichTextLabel](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html) - Console output display

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- Console commands can be registered from any script
- CVars can be registered from any script
- Test scripts are GDScript files (editable in editor)

**Visual Configuration:**
- Console UI editable in scene editor
- Command registration via code (flexible)

**Editor Tools Needed:**
- **None Required:** Standard Godot scene system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Command browser/editor
  - CVar editor
  - Test script editor
  - Debug visualization preview

**Current Approach:**
- Uses Godot's native scene system (no custom tools needed)
- Console UI created as scene (editable in editor)
- Commands/CVars registered via code (flexible)
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Advanced Console:** Full command system with variables (CVars) and scripting support
2. **No Cheat Menu:** Everything accessible through console
3. **Comprehensive Debug Tools:** Scene inspector, object spawner, teleportation, visualizers, pathfinding debug, AI debug
4. **Always Available Console:** Console always accessible via keybind
5. **Settings Toggle:** Debug commands require settings toggle to enable
6. **Comprehensive Visualizations:** Collision shapes, raycasts, pathfinding paths, AI state, physics forces, network connections, chunk boundaries, spawn zones
7. **Comprehensive Debug Camera:** Free-fly, no clipping, speed control, follow targets, save positions, camera paths, recording, screenshot mode
8. **Comprehensive Time Control:** Pause, slow motion, fast forward, frame-by-frame, time scale control, rewind, time markers, time-based events debug
9. **Comprehensive Scene Inspector:** Live editing, property watching, search/filter, node selection, property history
10. **Comprehensive Debug Logging:** Log viewer, search, export, remote logging, file logging, categories, filtering
11. **Single Console:** All tools accessible from one console interface
12. **Advanced Console Features:** Command history, autocomplete, syntax highlighting
13. **Advanced Test Mode:** Test scripts, automated test runs, test reports
14. **Comprehensive Help:** List commands, descriptions, command syntax, examples, searchable

