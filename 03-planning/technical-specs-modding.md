# Technical Specifications: Modding Support System

**Date:** 2025-01-27  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the comprehensive modding support system, including hybrid mod distribution (manual installation, in-game browser, Steam Workshop), full modding capabilities (content + scripts + assets + UI mods + shaders + core system extensions), multiple scripting languages (GDScript + C# + optional visual scripting), dependency-based load order with manual overrides, priority-based conflict resolution, sandboxed security with permission system, semantic versioning, TOML metadata format, and comprehensive validation. All features are designed to be highly configurable, modular, and meet industry modding standards.

---

## Research Notes

### Mod Distribution Best Practices

**Research Findings:**
- Multiple distribution methods increase mod accessibility
- Manual installation for advanced users
- In-game browser for easy discovery and installation
- Steam Workshop integration for Steam users
- Hybrid approach provides maximum flexibility

**Sources:**
- General modding platform best practices
- Industry standard for mod distribution

**Implementation Approach:**
- Support manual installation (file system)
- In-game mod browser with download/install
- Steam Workshop integration (optional)
- All methods work together seamlessly

**Why This Approach:**
- Flexible (users choose preferred method)
- Accessible (easy for beginners, powerful for advanced)
- Industry standard (most games support multiple methods)
- Future-proof (can add more methods later)

### Mod Scripting Language Best Practices

**Research Findings:**
- GDScript is native to Godot, easy to learn, no dependencies
- C# is more powerful, requires .NET runtime, better for advanced modders
- Visual scripting is accessible for non-programmers
- Multiple languages provide flexibility

**Sources:**
- [Generalist Programmer - Game Scripting Languages Guide](https://generalistprogrammer.com/tutorials/game-scripting-languages-complete-comparison-guide-2025/) - Scripting language best practices
- Godot documentation on GDScript and C# support

**Implementation Approach:**
- GDScript as primary (native, easy)
- C# as optional (powerful, advanced)
- Visual scripting as optional (accessible, simple mods)
- All languages supported simultaneously

**Why This Approach:**
- Flexible (GDScript for most, C# for advanced)
- Accessible (visual scripting for non-programmers)
- Industry practice (many games support multiple languages)
- Future-proof (can add more languages later)

### Mod Load Order Best Practices

**Research Findings:**
- Dependency-based loading ensures mods load in correct order
- Topological sort resolves dependencies automatically
- Manual overrides needed for conflicts
- Circular dependencies must be detected and prevented

**Sources:**
- [Luanti Mod Dependency Management](https://docs.luanti.org/for-creators/mod-dependency-management/) - Dependency management
- [Game Forge Base - Dependency Mapping](https://gameforgebase.com/blog/mechanical-gears-assembly-ef49711637/) - Dependency visualization

**Implementation Approach:**
- Dependency-based loading with topological sort
- Manual overrides for user control
- Circular dependency detection
- Load order visualization

**Why This Approach:**
- Automatic (dependencies handled automatically)
- Flexible (manual overrides for conflicts)
- Industry standard (Skyrim, Minecraft use this)
- Prevents errors (missing dependencies caught)

### Mod Conflict Resolution Best Practices

**Research Findings:**
- Priority system allows fine control over conflicts
- Conflict detection warns users about issues
- User resolution provides manual control
- Patch mods resolve complex conflicts

**Sources:**
- [Meegle - Mod Conflict Detection Tool](https://www.meegle.com/en_us/advanced-templates/game_review/mod_conflict_detection_tool) - Conflict detection
- General modding platform best practices

**Implementation Approach:**
- Priority system (mods have priority values)
- Conflict detection (automatic detection and warnings)
- User resolution (manual priority adjustment)
- Patch mods (compatibility patches)

**Why This Approach:**
- Automatic (priority system handles most conflicts)
- User control (manual priority adjustment)
- Conflict awareness (detection and warnings)
- Industry standard (Skyrim, Minecraft use this)
- Extensible (patch mods for complex conflicts)

### Mod Security Best Practices

**Research Findings:**
- Sandboxing prevents malicious code execution
- Permission system allows needed functionality
- Trusted mods balance security and functionality
- Cryptographic verification ensures mod integrity

**Sources:**
- [Stage Four Security - Mods and User-Generated Content](https://stagefoursecurity.com/blog/2025/05/13/mods-and-user-generated-content/) - Mod security
- [Game Forge Base - Cryptographic Verification](https://gameforgebase.com/blog/antique-lock-mechanism-416111298) - Mod verification

**Implementation Approach:**
- Sandboxed environment (restricted execution)
- Permission system (mods request permissions)
- Trusted mods (elevated permissions)
- Cryptographic verification (hash/signature checking)

**Why This Approach:**
- Security (sandbox prevents malicious code)
- Flexible (permissions allow needed functionality)
- User control (users approve permissions)
- Industry practice (many games use this approach)
- Trusted mods (balance security and functionality)

### Mod Versioning Best Practices

**Research Findings:**
- Semantic versioning (MAJOR.MINOR.PATCH) is industry standard
- Version compatibility prevents conflicts
- Update checking keeps mods current
- Dependency version ranges manage compatibility

**Sources:**
- [Modrinth - Version Number Recommendations](https://support.modrinth.com/en/articles/8793369-version-number-recommendations) - Semantic versioning
- [Polymod - Best Practices](https://polymod.io/docs/best-practices/) - Versioning and compatibility

**Implementation Approach:**
- Semantic versioning (MAJOR.MINOR.PATCH)
- Version compatibility (mods declare compatible game versions)
- Update checking (automatic update notifications)
- Dependency version ranges (flexible dependency management)

**Why This Approach:**
- Clear versioning (semantic versioning is standard)
- Compatibility management (version ranges prevent conflicts)
- User-friendly (update checking keeps mods current)
- Industry standard (used by major modding platforms)
- Flexible (supports complex dependency scenarios)

### Mod Metadata Format Best Practices

**Research Findings:**
- TOML is human-readable, supports comments, easy to parse
- Used by modding platforms (Modrinth uses TOML)
- Better than JSON (supports comments, more readable)
- Better than YAML (less error-prone, simpler syntax)

**Sources:**
- Modrinth uses TOML for mod metadata
- General configuration file format best practices

**Implementation Approach:**
- TOML format for mod metadata
- Human-readable with comments
- Easy to parse programmatically
- Supports all required metadata fields

**Why This Approach:**
- Better than JSON (supports comments, more readable)
- Better than YAML (less error-prone, simpler syntax)
- Industry adoption (Modrinth, Cargo use TOML)
- Modder-friendly (easier to write and maintain)

### Mod Validation Best Practices

**Research Findings:**
- Comprehensive validation prevents errors and security issues
- Metadata validation ensures correct format
- File structure validation prevents issues
- Dependency validation prevents missing dependencies
- Script validation prevents errors
- Asset validation prevents broken assets
- Security checks prevent malicious code

**Sources:**
- [Polymod - Best Practices](https://polymod.io/docs/best-practices/) - Mod validation
- General modding platform validation practices

**Implementation Approach:**
- Comprehensive validation (all aspects)
- Metadata validation (format, required fields)
- File structure validation (directory structure, paths)
- Dependency validation (existence, versions, circular)
- Script validation (syntax, dangerous calls)
- Asset validation (formats, sizes, references)
- Security checks (malicious patterns, unauthorized access)

**Why This Approach:**
- Prevents errors (catch issues early)
- Security (prevents malicious mods)
- User experience (clear error messages)
- Industry standard (major platforms use comprehensive validation)
- Maintainable (validated mods are more reliable)

---

## Data Structures

### ModMetadata (Resource)

```gdscript
class_name ModMetadata
extends Resource

# Basic Information
@export var mod_id: String  # Unique identifier (e.g., "my-awesome-mod")
@export var mod_name: String  # Display name
@export var mod_version: String  # Semantic version (e.g., "1.0.0")
@export var author: String  # Mod author name
@export var description: String  # Mod description
@export var tags: Array[String] = []  # Mod tags (e.g., ["content", "items", "quests"])

# Compatibility
@export var game_version_min: String = "1.0.0"  # Minimum game version
@export var game_version_max: String = ""  # Maximum game version (empty = no limit)
@export var api_version: String = "1.0.0"  # Required API version

# Dependencies
@export var dependencies: Array[ModDependency] = []  # Required dependencies
@export var optional_dependencies: Array[ModDependency] = []  # Optional dependencies
@export var conflicts: Array[String] = []  # Conflicting mod IDs

# Load Order
@export var load_after: Array[String] = []  # Load after these mods
@export var load_before: Array[String] = []  # Load before these mods
@export var priority: int = 0  # Load order priority (-100 to 100)

# Permissions
@export var permissions: Array[ModPermission] = []  # Required permissions
@export var is_trusted: bool = false  # Trusted mod (elevated permissions)

# Distribution
@export var distribution_url: String = ""  # Mod distribution URL
@export var update_url: String = ""  # Update check URL
@export var source_url: String = ""  # Source code URL

# Files
@export var main_script: String = ""  # Main mod script path
@export var asset_paths: Array[String] = []  # Asset file paths
@export var data_files: Array[String] = []  # Data file paths
```

### ModDependency (Resource)

```gdscript
class_name ModDependency
extends Resource

@export var mod_id: String  # Dependency mod ID
@export var version_min: String = ""  # Minimum version (empty = any)
@export var version_max: String = ""  # Maximum version (empty = any)
@export var is_optional: bool = false  # Optional dependency
```

### ModPermission (Enum)

```gdscript
enum ModPermission {
	FILE_READ,        # Read files from mod directory
	FILE_WRITE,       # Write files to mod directory
	NETWORK_ACCESS,   # Network access
	SYSTEM_CALLS,     # System calls (restricted)
	UI_MODIFICATION,  # UI modification
	SHADER_ACCESS,    # Shader access
	CORE_SYSTEM_EXT   # Core system extension
}
```

### ModLoadOrder (Resource)

```gdscript
class_name ModLoadOrder
extends Resource

@export var mod_load_order: Array[String] = []  # Ordered list of mod IDs
@export var manual_overrides: Dictionary = {}  # mod_id -> priority override
@export var disabled_mods: Array[String] = []  # Disabled mod IDs
```

### ModConflict (Resource)

```gdscript
class_name ModConflict
extends Resource

@export var conflict_type: ConflictType
@export var mod1_id: String
@export var mod2_id: String
@export var resource_path: String  # Conflicting resource
@export var resolution: ConflictResolution = ConflictResolution.NONE

enum ConflictType {
	RESOURCE_OVERRIDE,  # Same resource modified by both mods
	DEPENDENCY_CONFLICT,  # Dependency conflict
	API_CONFLICT,  # API version conflict
	PERMISSION_CONFLICT  # Permission conflict
}

enum ConflictResolution {
	NONE,  # No resolution
	PRIORITY,  # Resolved by priority
	PATCH,  # Resolved by patch mod
	MANUAL  # Manual resolution required
}
```

### ModValidationResult (Resource)

```gdscript
class_name ModValidationResult
extends Resource

@export var is_valid: bool = false
@export var errors: Array[String] = []
@export var warnings: Array[String] = []
@export var validation_steps: Dictionary = {}  # step -> result
```

### ModSettings (Resource)

```gdscript
class_name ModSettings
extends Resource

# Mod Directories
@export var mod_directory: String = "user://mods/"  # Mod installation directory
@export var enabled_mods: Array[String] = []  # Enabled mod IDs
@export var disabled_mods: Array[String] = []  # Disabled mod IDs

# Load Order
@export var load_order: ModLoadOrder

# Security
@export var sandbox_enabled: bool = true
@export var permission_prompt_enabled: bool = true
@export var trusted_mods: Array[String] = []  # Trusted mod IDs

# Distribution
@export var in_game_browser_enabled: bool = true
@export var steam_workshop_enabled: bool = false
@export var update_check_enabled: bool = true
@export var auto_update_enabled: bool = false  # Auto-update trusted mods only

# Validation
@export var validation_enabled: bool = true
@export var strict_validation: bool = false  # Strict validation mode
```

---

## Core Classes

### ModManager (Autoload Singleton)

```gdscript
class_name ModManager
extends Node

# Settings
var mod_settings: ModSettings
var loaded_mods: Dictionary = {}  # mod_id -> ModInstance
var mod_metadata: Dictionary = {}  # mod_id -> ModMetadata
var mod_load_order: ModLoadOrder

# Components
var mod_loader: ModLoader
var mod_validator: ModValidator
var mod_security: ModSecurity
var mod_distribution: ModDistribution
var mod_conflict_resolver: ModConflictResolver

# Signals
signal mod_loaded(mod_id: String, mod_metadata: ModMetadata)
signal mod_unloaded(mod_id: String)
signal mod_enabled(mod_id: String)
signal mod_disabled(mod_id: String)
signal mod_conflict_detected(conflict: ModConflict)
signal mod_validation_complete(mod_id: String, result: ModValidationResult)

# Initialization
func _ready() -> void
func load_mod_settings() -> void
func save_mod_settings() -> void
func initialize_mod_system() -> void

# Mod Loading
func load_mod(mod_path: String) -> ModValidationResult
func unload_mod(mod_id: String) -> void
func reload_mod(mod_id: String) -> void
func load_all_mods() -> void

# Mod Management
func enable_mod(mod_id: String) -> void
func disable_mod(mod_id: String) -> void
func is_mod_enabled(mod_id: String) -> bool
func get_mod_metadata(mod_id: String) -> ModMetadata
func get_loaded_mods() -> Array[String]

# Load Order
func calculate_load_order() -> Array[String]
func set_mod_priority(mod_id: String, priority: int) -> void
func get_mod_priority(mod_id: String) -> int
func add_load_order_override(mod_id: String, after_mod_id: String) -> void

# Dependencies
func check_dependencies(mod_id: String) -> Dictionary  # Returns missing/conflicting dependencies
func resolve_dependencies() -> bool
func detect_circular_dependencies() -> Array[Array]  # Returns circular dependency chains

# Conflicts
func detect_conflicts() -> Array[ModConflict]
func resolve_conflict(conflict: ModConflict, resolution: ModConflict.ConflictResolution) -> void
func get_conflicts_for_mod(mod_id: String) -> Array[ModConflict]

# Validation
func validate_mod(mod_path: String) -> ModValidationResult
func validate_all_mods() -> Dictionary  # mod_id -> ModValidationResult

# Security
func request_permission(mod_id: String, permission: ModPermission) -> bool
func grant_permission(mod_id: String, permission: ModPermission) -> void
func revoke_permission(mod_id: String, permission: ModPermission) -> void
func is_mod_trusted(mod_id: String) -> bool
func set_mod_trusted(mod_id: String, trusted: bool) -> void

# Distribution
func install_mod_from_file(file_path: String) -> ModValidationResult
func install_mod_from_url(url: String) -> ModValidationResult
func uninstall_mod(mod_id: String) -> void
func check_for_updates() -> Dictionary  # mod_id -> update_available
func update_mod(mod_id: String) -> void
```

### ModLoader

```gdscript
class_name ModLoader
extends Node

var mod_manager: ModManager

func _init(manager: ModManager) -> void
func load_mod(mod_path: String) -> ModInstance
func unload_mod(mod_instance: ModInstance) -> void
func load_mod_metadata(mod_path: String) -> ModMetadata
func load_mod_scripts(mod_instance: ModInstance) -> void
func load_mod_assets(mod_instance: ModInstance) -> void
func load_mod_data(mod_instance: ModInstance) -> void
func execute_mod_init(mod_instance: ModInstance) -> void
func execute_mod_ready(mod_instance: ModInstance) -> void
```

### ModValidator

```gdscript
class_name ModValidator
extends Node

var mod_manager: ModManager

func _init(manager: ModManager) -> void
func validate_mod(mod_path: String) -> ModValidationResult
func validate_metadata(metadata: ModMetadata) -> Array[String]  # Returns errors
func validate_file_structure(mod_path: String) -> Array[String]  # Returns errors
func validate_dependencies(metadata: ModMetadata) -> Array[String]  # Returns errors
func validate_scripts(mod_path: String, metadata: ModMetadata) -> Array[String]  # Returns errors
func validate_assets(mod_path: String, metadata: ModMetadata) -> Array[String]  # Returns errors
func validate_security(mod_path: String, metadata: ModMetadata) -> Array[String]  # Returns errors
func detect_circular_dependencies(dependencies: Dictionary) -> Array[Array]  # Returns circular chains
```

### ModSecurity

```gdscript
class_name ModSecurity
extends Node

var mod_manager: ModManager
var sandbox_enabled: bool = true
var mod_permissions: Dictionary = {}  # mod_id -> Array[ModPermission]

func _init(manager: ModManager) -> void
func request_permission(mod_id: String, permission: ModPermission) -> bool
func grant_permission(mod_id: String, permission: ModPermission) -> void
func revoke_permission(mod_id: String, permission: ModPermission) -> void
func has_permission(mod_id: String, permission: ModPermission) -> bool
func check_permission(mod_id: String, permission: ModPermission) -> bool
func sandbox_mod_execution(mod_id: String, script: GDScript) -> void
func validate_file_access(mod_id: String, file_path: String, access_type: String) -> bool
func validate_network_access(mod_id: String, url: String) -> bool
func validate_system_call(mod_id: String, call_name: String) -> bool
```

### ModConflictResolver

```gdscript
class_name ModConflictResolver
extends Node

var mod_manager: ModManager

func _init(manager: ModManager) -> void
func detect_conflicts() -> Array[ModConflict]
func resolve_by_priority(conflict: ModConflict) -> void
func resolve_by_patch(conflict: ModConflict, patch_mod_id: String) -> void
func resolve_manually(conflict: ModConflict, resolution: ModConflict.ConflictResolution) -> void
func get_conflict_resolution(conflict: ModConflict) -> ModConflict.ConflictResolution
func suggest_resolution(conflict: ModConflict) -> ModConflict.ConflictResolution
```

### ModDistribution

```gdscript
class_name ModDistribution
extends Node

var mod_manager: ModManager
var in_game_browser: ModBrowser
var steam_workshop: SteamWorkshopIntegration

func _init(manager: ModManager) -> void
func install_mod_from_file(file_path: String) -> ModValidationResult
func install_mod_from_url(url: String) -> ModValidationResult
func download_mod(mod_id: String, url: String) -> ModValidationResult
func check_for_updates() -> Dictionary  # mod_id -> update_available
func update_mod(mod_id: String) -> void
func uninstall_mod(mod_id: String) -> void
```

### ModBrowser

```gdscript
class_name ModBrowser
extends Control

var mod_manager: ModManager
var mod_list: Array[ModMetadata] = []
var search_query: String = ""
var filter_tags: Array[String] = []

func _init(manager: ModManager) -> void
func refresh_mod_list() -> void
func search_mods(query: String) -> void
func filter_mods(tags: Array[String]) -> void
func install_mod(mod_id: String) -> void
func uninstall_mod(mod_id: String) -> void
func open_mod_details(mod_id: String) -> void
```

### ModInstance

```gdscript
class_name ModInstance
extends RefCounted

var mod_id: String
var mod_metadata: ModMetadata
var mod_path: String
var is_enabled: bool = true
var is_loaded: bool = false

# Scripts
var scripts: Array[GDScript] = []
var csharp_scripts: Array[CSharpScript] = []

# Assets
var assets: Dictionary = {}  # path -> Resource

# Data
var data: Dictionary = {}

# Runtime
var mod_node: Node  # Mod's main node (if any)
```

---

## System Architecture

### Component Hierarchy

```
ModManager (Autoload Singleton)
├── ModLoader
│   ├── Script Loader (GDScript)
│   ├── Script Loader (C#)
│   ├── Script Loader (Visual Scripting)
│   ├── Asset Loader
│   └── Data Loader
├── ModValidator
│   ├── Metadata Validator
│   ├── File Structure Validator
│   ├── Dependency Validator
│   ├── Script Validator
│   ├── Asset Validator
│   └── Security Validator
├── ModSecurity
│   ├── Sandbox Manager
│   ├── Permission Manager
│   └── Trust Manager
├── ModConflictResolver
│   ├── Conflict Detector
│   ├── Priority Resolver
│   └── Patch Resolver
└── ModDistribution
    ├── ModBrowser (In-Game)
    ├── SteamWorkshopIntegration (Optional)
    └── Update Checker
```

### Data Flow

1. **Mod Installation:**
   - User installs mod (file/URL/browser)
   - `ModDistribution.install_mod()` → Validates mod
   - `ModValidator.validate_mod()` → Comprehensive validation
   - `ModLoader.load_mod()` → Loads mod files
   - `ModManager.load_mod()` → Registers mod

2. **Mod Loading:**
   - `ModManager.load_all_mods()` → Calculates load order
   - `ModConflictResolver.detect_conflicts()` → Detects conflicts
   - Loads mods in dependency order
   - Executes mod initialization scripts
   - Emits `mod_loaded` signals

3. **Mod Execution:**
   - Mods run in sandboxed environment
   - `ModSecurity` checks permissions
   - Mods access game APIs through ModManager
   - Conflicts resolved by priority/patch

### Integration Points

- **All Game Systems:** Mods can extend/modify all game systems through ModManager API
- **Item Database:** Mods can add/modify items
- **Quest System:** Mods can add/modify quests
- **NPC System:** Mods can add/modify NPCs
- **Crafting System:** Mods can add/modify recipes
- **Building System:** Mods can add/modify building pieces
- **Combat System:** Mods can add/modify weapons/enemies
- **UI System:** Mods can modify UI
- **Rendering System:** Mods can add shaders
- **Save System:** Mods can add save data

---

## Algorithms

### Calculate Load Order (Topological Sort)

```gdscript
func calculate_load_order() -> Array[String]:
	var graph: Dictionary = {}  # mod_id -> Array[dependency_ids]
	var in_degree: Dictionary = {}  # mod_id -> in_degree_count
	var queue: Array[String] = []
	var result: Array[String] = []
	
	# Build graph and calculate in-degrees
	for mod_id in mod_metadata:
		graph[mod_id] = []
		in_degree[mod_id] = 0
		
		var metadata = mod_metadata[mod_id]
		for dependency in metadata.dependencies:
			if mod_metadata.has(dependency.mod_id):
				graph[dependency.mod_id].append(mod_id)
				in_degree[mod_id] += 1
		
		# Add load_after dependencies
		for after_mod_id in metadata.load_after:
			if mod_metadata.has(after_mod_id):
				graph[after_mod_id].append(mod_id)
				in_degree[mod_id] += 1
	
	# Find mods with no dependencies
	for mod_id in in_degree:
		if in_degree[mod_id] == 0:
			queue.append(mod_id)
	
	# Topological sort
	while queue.size() > 0:
		# Sort by priority (higher priority first)
		queue.sort_custom(func(a, b): return get_mod_priority(a) > get_mod_priority(b))
		
		var mod_id = queue.pop_front()
		result.append(mod_id)
		
		# Process dependents
		for dependent_id in graph[mod_id]:
			in_degree[dependent_id] -= 1
			if in_degree[dependent_id] == 0:
				queue.append(dependent_id)
	
	# Check for circular dependencies
	if result.size() < mod_metadata.size():
		var circular = detect_circular_dependencies()
		push_error("Circular dependencies detected: " + str(circular))
		return []
	
	return result
```

### Detect Conflicts

```gdscript
func detect_conflicts() -> Array[ModConflict]:
	var conflicts: Array[ModConflict] = []
	var resource_map: Dictionary = {}  # resource_path -> Array[mod_ids]
	
	# Build resource map
	for mod_id in loaded_mods:
		var mod_instance = loaded_mods[mod_id]
		var metadata = mod_instance.mod_metadata
		
		# Check asset paths
		for asset_path in metadata.asset_paths:
			if not resource_map.has(asset_path):
				resource_map[asset_path] = []
			resource_map[asset_path].append(mod_id)
		
		# Check data files
		for data_file in metadata.data_files:
			if not resource_map.has(data_file):
				resource_map[data_file] = []
			resource_map[data_file].append(mod_id)
	
	# Detect conflicts
	for resource_path in resource_map:
		var mod_ids = resource_map[resource_path]
		if mod_ids.size() > 1:
			# Multiple mods modify same resource
			for i in range(mod_ids.size()):
				for j in range(i + 1, mod_ids.size()):
					var conflict = ModConflict.new()
					conflict.conflict_type = ModConflict.ConflictType.RESOURCE_OVERRIDE
					conflict.mod1_id = mod_ids[i]
					conflict.mod2_id = mod_ids[j]
					conflict.resource_path = resource_path
					conflict.resolution = suggest_resolution(conflict)
					conflicts.append(conflict)
	
	return conflicts
```

### Resolve Conflict by Priority

```gdscript
func resolve_by_priority(conflict: ModConflict) -> void:
	var mod1_priority = get_mod_priority(conflict.mod1_id)
	var mod2_priority = get_mod_priority(conflict.mod2_id)
	
	if mod1_priority > mod2_priority:
		# Mod1 wins, disable mod2's resource
		disable_mod_resource(conflict.mod2_id, conflict.resource_path)
		conflict.resolution = ModConflict.ConflictResolution.PRIORITY
	elif mod2_priority > mod1_priority:
		# Mod2 wins, disable mod1's resource
		disable_mod_resource(conflict.mod1_id, conflict.resource_path)
		conflict.resolution = ModConflict.ConflictResolution.PRIORITY
	else:
		# Same priority, use load order
		var load_order = calculate_load_order()
		var mod1_index = load_order.find(conflict.mod1_id)
		var mod2_index = load_order.find(conflict.mod2_id)
		
		if mod1_index > mod2_index:
			# Mod1 loads later, wins
			disable_mod_resource(conflict.mod2_id, conflict.resource_path)
		else:
			# Mod2 loads later, wins
			disable_mod_resource(conflict.mod1_id, conflict.resource_path)
		
		conflict.resolution = ModConflict.ConflictResolution.PRIORITY
```

### Validate Mod

```gdscript
func validate_mod(mod_path: String) -> ModValidationResult:
	var result = ModValidationResult.new()
	result.is_valid = true
	
	# Load metadata
	var metadata_path = mod_path + "/mod.toml"
	if not FileAccess.file_exists(metadata_path):
		result.errors.append("Missing mod.toml file")
		result.is_valid = false
		return result
	
	var metadata = load_mod_metadata(mod_path)
	if metadata == null:
		result.errors.append("Failed to load mod.toml")
		result.is_valid = false
		return result
	
	# Validate metadata
	var metadata_errors = validate_metadata(metadata)
	result.errors.append_array(metadata_errors)
	result.validation_steps["metadata"] = metadata_errors.size() == 0
	
	# Validate file structure
	var structure_errors = validate_file_structure(mod_path)
	result.errors.append_array(structure_errors)
	result.validation_steps["file_structure"] = structure_errors.size() == 0
	
	# Validate dependencies
	var dependency_errors = validate_dependencies(metadata)
	result.errors.append_array(dependency_errors)
	result.validation_steps["dependencies"] = dependency_errors.size() == 0
	
	# Validate scripts
	var script_errors = validate_scripts(mod_path, metadata)
	result.errors.append_array(script_errors)
	result.validation_steps["scripts"] = script_errors.size() == 0
	
	# Validate assets
	var asset_errors = validate_assets(mod_path, metadata)
	result.errors.append_array(asset_errors)
	result.validation_steps["assets"] = asset_errors.size() == 0
	
	# Validate security
	var security_errors = validate_security(mod_path, metadata)
	result.errors.append_array(security_errors)
	result.validation_steps["security"] = security_errors.size() == 0
	
	# Check if valid
	result.is_valid = result.errors.size() == 0
	
	return result
```

### Request Permission

```gdscript
func request_permission(mod_id: String, permission: ModPermission) -> bool:
	# Check if mod is trusted
	if is_mod_trusted(mod_id):
		# Trusted mods get all permissions
		grant_permission(mod_id, permission)
		return true
	
	# Check if permission already granted
	if has_permission(mod_id, permission):
		return true
	
	# Check sandbox restrictions
	if sandbox_enabled:
		match permission:
			ModPermission.FILE_READ:
				# File read allowed in mod directory only
				return true
			ModPermission.FILE_WRITE:
				# File write allowed in mod directory only
				return true
			ModPermission.NETWORK_ACCESS:
				# Network access requires explicit permission
				if permission_prompt_enabled:
					return prompt_user_for_permission(mod_id, permission)
				return false
			ModPermission.SYSTEM_CALLS:
				# System calls blocked in sandbox
				return false
			ModPermission.UI_MODIFICATION:
				# UI modification allowed
				return true
			ModPermission.SHADER_ACCESS:
				# Shader access allowed
				return true
			ModPermission.CORE_SYSTEM_EXT:
				# Core system extension requires trusted mod
				return false
	
	# Grant permission if allowed
	grant_permission(mod_id, permission)
	return true
```

---

## Integration Points

### Game Systems Integration

- **Item Database:** Mods can register new items via `ItemDatabase.register_item()`
- **Quest System:** Mods can add quests via `QuestManager.add_quest()`
- **NPC System:** Mods can add NPCs via `NPCManager.register_npc()`
- **Crafting System:** Mods can add recipes via `CraftingManager.register_recipe()`
- **Building System:** Mods can add building pieces via `BuildingManager.register_building_piece()`
- **Combat System:** Mods can add weapons/enemies via `CombatManager.register_weapon()`
- **UI System:** Mods can modify UI via `UIManager.register_ui_modification()`
- **Rendering System:** Mods can add shaders via `RenderingManager.register_shader()`
- **Save System:** Mods can add save data via `SaveManager.register_mod_data()`

### Mod API

Mods access game systems through ModManager API:

```gdscript
# Example mod script
extends Node

func _ready():
	# Register new item
	var item_data = ItemData.new()
	item_data.item_id = "mod_iron_sword"
	item_data.item_name = "Modded Iron Sword"
	ItemDatabase.register_item(item_data)
	
	# Register new recipe
	var recipe = CraftingRecipe.new()
	recipe.recipe_id = "mod_iron_sword_recipe"
	recipe.result_item_id = "mod_iron_sword"
	CraftingManager.register_recipe(recipe)
```

---

## Save/Load System

### Mod Save Data

```gdscript
var mod_save_data = {
	"mod_settings": {
		"mod_directory": "user://mods/",
		"enabled_mods": ["mod-a", "mod-b"],
		"disabled_mods": ["mod-c"],
		"sandbox_enabled": true,
		"permission_prompt_enabled": true,
		"trusted_mods": ["mod-a"],
		"in_game_browser_enabled": true,
		"update_check_enabled": true
	},
	"load_order": {
		"mod_load_order": ["mod-a", "mod-b", "mod-c"],
		"manual_overrides": {},
		"disabled_mods": ["mod-c"]
	},
	"mod_data": {
		"mod-a": {
			"custom_data": {}
		}
	}
}
```

### Save/Load Functions

```gdscript
func save_mod_settings() -> void:
	var save_data = {
		"mod_settings": serialize_mod_settings(),
		"load_order": serialize_load_order(),
		"mod_data": serialize_mod_data()
	}
	
	var config = ConfigFile.new()
	config.set_value("modding", "settings", save_data)
	config.save("user://mod_settings.cfg")

func load_mod_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://mod_settings.cfg")
	if err != OK:
		mod_settings = ModSettings.new()
		return
	
	var save_data = config.get_value("modding", "settings", {})
	if save_data.has("mod_settings"):
		deserialize_mod_settings(save_data.mod_settings)
	if save_data.has("load_order"):
		deserialize_load_order(save_data.load_order)
	if save_data.has("mod_data"):
		deserialize_mod_data(save_data.mod_data)
```

---

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading:**
   - Load mods on demand
   - Load assets when needed
   - Defer script execution until required

2. **Caching:**
   - Cache mod metadata
   - Cache validation results
   - Cache loaded assets

3. **Batch Operations:**
   - Batch mod loading
   - Batch conflict detection
   - Batch validation

4. **Conditional Processing:**
   - Skip disabled mods
   - Skip validation for trusted mods
   - Skip security checks for trusted mods

5. **Memory Management:**
   - Unload unused mods
   - Unload unused assets
   - Clean up mod instances

---

## Testing Checklist

### Mod Loading
- [ ] Mods load correctly from file system
- [ ] Mods load correctly from URL
- [ ] Mods load correctly from in-game browser
- [ ] Mods load correctly from Steam Workshop
- [ ] Load order is correct (dependency-based)
- [ ] Circular dependencies are detected
- [ ] Missing dependencies are detected

### Mod Validation
- [ ] Metadata validation works correctly
- [ ] File structure validation works correctly
- [ ] Dependency validation works correctly
- [ ] Script validation works correctly
- [ ] Asset validation works correctly
- [ ] Security validation works correctly
- [ ] Validation errors are clear and helpful

### Mod Conflicts
- [ ] Conflicts are detected correctly
- [ ] Priority-based resolution works
- [ ] Patch mods resolve conflicts
- [ ] Manual resolution works
- [ ] Conflict warnings are displayed

### Mod Security
- [ ] Sandboxing works correctly
- [ ] Permission system works correctly
- [ ] Trusted mods get elevated permissions
- [ ] Malicious code is prevented
- [ ] File access is restricted correctly
- [ ] Network access is restricted correctly

### Mod Distribution
- [ ] Manual installation works
- [ ] In-game browser works
- [ ] Steam Workshop integration works (if enabled)
- [ ] Update checking works
- [ ] Auto-update works (for trusted mods)

### Mod Scripting
- [ ] GDScript mods work correctly
- [ ] C# mods work correctly
- [ ] Visual scripting mods work correctly
- [ ] Mods can access game APIs
- [ ] Mods can modify game systems

### Integration
- [ ] Mods integrate with Item Database
- [ ] Mods integrate with Quest System
- [ ] Mods integrate with NPC System
- [ ] Mods integrate with Crafting System
- [ ] Mods integrate with Building System
- [ ] Mods integrate with Combat System
- [ ] Mods integrate with UI System
- [ ] Mods integrate with Save System

---

## Error Handling

### Default Values

```gdscript
# Default mod settings
var default_mod_settings = ModSettings.new()
default_mod_settings.mod_directory = "user://mods/"
default_mod_settings.sandbox_enabled = true
default_mod_settings.permission_prompt_enabled = true
default_mod_settings.validation_enabled = true
```

### Error Handling Functions

```gdscript
func handle_mod_error(error_message: String, mod_id: String) -> void:
	push_error("Mod Error [" + mod_id + "]: " + error_message)
	
	# Disable mod if critical error
	if error_message.contains("CRITICAL"):
		disable_mod(mod_id)
		push_error("Mod disabled due to critical error: " + mod_id)

func validate_mod_path(mod_path: String) -> bool:
	if not DirAccess.dir_exists_absolute(mod_path):
		push_error("Mod directory does not exist: " + mod_path)
		return false
	
	# Check for directory traversal
	if ".." in mod_path or mod_path.begins_with("/"):
		push_error("Invalid mod path (directory traversal detected): " + mod_path)
		return false
	
	return true
```

---

## Default Values and Configuration

### Mod Directory Structure

```
user://mods/
├── mod-a/
│   ├── mod.toml
│   ├── scripts/
│   ├── assets/
│   └── data/
├── mod-b/
│   ├── mod.toml
│   └── ...
```

### Mod Metadata Format (TOML)

```toml
[mod]
id = "my-awesome-mod"
name = "My Awesome Mod"
version = "1.0.0"
author = "ModderName"
description = "A cool mod that does things"
tags = ["content", "items", "quests"]

[compatibility]
game_version_min = "1.0.0"
game_version_max = ""
api_version = "1.0.0"

[dependencies]
required = [
    { id = "mod-a", version_min = "1.0.0", version_max = "2.0.0" }
]
optional = [
    { id = "mod-b" }
]

[load_order]
load_after = ["mod-a"]
load_before = ["mod-c"]
priority = 0

[permissions]
required = ["FILE_READ", "FILE_WRITE", "UI_MODIFICATION"]

[distribution]
update_url = "https://example.com/mods/my-mod/updates"
source_url = "https://github.com/modder/my-mod"

[files]
main_script = "scripts/main.gd"
assets = ["assets/textures/", "assets/sounds/"]
data = ["data/items.json", "data/quests.json"]
```

---

## Complete Implementation

### ModManager Implementation

```gdscript
extends Node

var mod_settings: ModSettings
var loaded_mods: Dictionary = {}
var mod_metadata: Dictionary = {}
var mod_load_order: ModLoadOrder

var mod_loader: ModLoader
var mod_validator: ModValidator
var mod_security: ModSecurity
var mod_distribution: ModDistribution
var mod_conflict_resolver: ModConflictResolver

signal mod_loaded(mod_id: String, mod_metadata: ModMetadata)
signal mod_unloaded(mod_id: String)
signal mod_enabled(mod_id: String)
signal mod_disabled(mod_id: String)
signal mod_conflict_detected(conflict: ModConflict)
signal mod_validation_complete(mod_id: String, result: ModValidationResult)

func _ready() -> void:
	mod_settings = ModSettings.new()
	load_mod_settings()
	
	mod_load_order = ModLoadOrder.new()
	
	# Initialize components
	mod_loader = ModLoader.new(self)
	mod_validator = ModValidator.new(self)
	mod_security = ModSecurity.new(self)
	mod_distribution = ModDistribution.new(self)
	mod_conflict_resolver = ModConflictResolver.new(self)
	
	add_child(mod_loader)
	add_child(mod_validator)
	add_child(mod_security)
	add_child(mod_distribution)
	add_child(mod_conflict_resolver)
	
	# Initialize mod system
	initialize_mod_system()

func initialize_mod_system() -> void:
	# Create mod directory if it doesn't exist
	if not DirAccess.dir_exists_absolute(mod_settings.mod_directory):
		DirAccess.make_dir_recursive_absolute(mod_settings.mod_directory)
	
	# Load all mods
	load_all_mods()

func load_all_mods() -> void:
	# Scan mod directory
	var mod_dirs = scan_mod_directory()
	
	# Load metadata for all mods
	for mod_dir in mod_dirs:
		var metadata = mod_loader.load_mod_metadata(mod_dir)
		if metadata != null:
			mod_metadata[metadata.mod_id] = metadata
	
	# Calculate load order
	var load_order = calculate_load_order()
	
	# Detect conflicts
	var conflicts = mod_conflict_resolver.detect_conflicts()
	for conflict in conflicts:
		mod_conflict_detected.emit(conflict)
	
	# Load mods in order
	for mod_id in load_order:
		if mod_id in mod_settings.enabled_mods:
			load_mod_by_id(mod_id)

func load_mod_by_id(mod_id: String) -> void:
	if not mod_metadata.has(mod_id):
		push_error("Mod not found: " + mod_id)
		return
	
	var metadata = mod_metadata[mod_id]
	var mod_path = mod_settings.mod_directory + mod_id + "/"
	
	# Validate mod
	var validation_result = mod_validator.validate_mod(mod_path)
	if not validation_result.is_valid:
		push_error("Mod validation failed: " + mod_id)
		for error in validation_result.errors:
			push_error("  - " + error)
		return
	
	mod_validation_complete.emit(mod_id, validation_result)
	
	# Load mod
	var mod_instance = mod_loader.load_mod(mod_path)
	if mod_instance != null:
		loaded_mods[mod_id] = mod_instance
		mod_loaded.emit(mod_id, metadata)
```

---

## Setup Instructions

### 1. Create ModManager Autoload

1. Create `ModManager` script
2. Add to Autoload in Project Settings
3. Set as singleton

### 2. Create Mod Directory Structure

1. Create `user://mods/` directory
2. Create subdirectories for each mod
3. Each mod needs `mod.toml` file

### 3. Create Mod API

1. Expose game system APIs through ModManager
2. Create mod API documentation
3. Provide example mods

### 4. Integrate with Game Systems

1. Make systems moddable (expose APIs)
2. Add mod hooks to systems
3. Test mod integration

### 5. Optional: Set Up Steam Workshop

1. Configure Steam Workshop integration
2. Set up Steam API keys
3. Test Workshop upload/download

---

## Tools and Resources

### Godot Features Used

- **GDScript:** Native scripting language
- **C#:** Optional scripting language (requires .NET)
- **Resource System:** Mod metadata as resources
- **File System:** Mod file access
- **Scene System:** Mod scene loading

### External Tools (Optional)

- **Steam Workshop SDK:** For Steam Workshop integration
- **TOML Parser:** For parsing mod.toml files (Godot may need custom parser)

### References

- [Polymod - Best Practices](https://polymod.io/docs/best-practices/) - Modding best practices
- [Modrinth Documentation](https://docs.modrinth.com/) - Modding platform best practices
- [Godot Modding Community](https://github.com/godot-extended-libraries) - Godot modding resources
- [Semantic Versioning](https://semver.org/) - Version numbering standard
- [TOML Specification](https://toml.io/) - TOML format specification

---

## Editor Support

### Mod Development Tools

- **Mod Template:** Create mod template in editor
- **Mod Validator:** Validate mods in editor
- **Mod Browser:** Browse installed mods in editor
- **Mod Debugger:** Debug mod scripts in editor

### Mod Metadata Editor

- **Visual Editor:** Edit mod.toml visually
- **Validation:** Real-time validation feedback
- **Dependency Visualization:** Visualize mod dependencies

---

## Implementation Notes

### Modularity

- Each component (ModLoader, ModValidator, etc.) is separate
- Components can be enabled/disabled independently
- Mod API is extensible

### Configurability

- All settings exposed as resources (editable in editor)
- Settings can be changed at runtime
- Per-mod configuration supported

### Performance

- Lazy loading of mods
- Caching of validation results
- Batch operations for efficiency

### Extensibility

- Easy to add new mod types
- Easy to add new validation rules
- Easy to add new distribution methods
- Easy to add new scripting languages

---

