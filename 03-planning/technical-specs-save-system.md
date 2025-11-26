# Technical Specifications: Save System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the save system supporting multiple save slots and cloud saves. This system integrates with all game systems to collect and restore save data, including ItemDatabase for item instance serialization.

---

## Research Notes

### Save System Architecture Best Practices

**Research Findings:**
- JSON format is standard for save files (human-readable, easy to debug)
- Compression reduces file size significantly
- Encryption optional but recommended for production
- Versioning prevents save corruption from updates
- Async saving prevents game freezing
- Incremental saves improve performance

**Sources:**
- [Godot 4 File System](https://docs.godotengine.org/en/stable/tutorials/io/index.html) - File I/O operations
- [Godot 4 JSON Documentation](https://docs.godotengine.org/en/stable/classes/class_json.html) - JSON serialization
- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Godot 4 Performance Best Practices](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance optimization

**Implementation Approach:**
- JSON format for save files (readable, debuggable)
- Compression via GZIP (reduces file size)
- Optional encryption (XOR for basic, proper encryption for production)
- Version system for save compatibility
- Async saving via call_deferred or threads
- Incremental saves for large worlds

**Why This Approach:**
- JSON is standard and easy to work with
- Compression reduces storage and load times
- Encryption prevents save editing
- Versioning handles updates gracefully
- Async prevents UI freezing
- Incremental saves scale better

### Save Data Collection Best Practices

**Research Findings:**
- Each system should provide get_save_data() method
- Save data should be minimal (only what's needed)
- Item instances need special handling (durability, metadata)
- References should be serialized as IDs, not objects

**Sources:**
- General game development best practices
- ItemDatabase specification (already completed)

**Implementation Approach:**
- Each system implements get_save_data() -> Dictionary
- SaveManager collects data from all systems
- Item instances saved as {item_id, durability, metadata}
- References saved as IDs (item_id, recipe_id, etc.)

**Why This Approach:**
- Modular: each system manages its own save data
- Minimal: only save what's needed
- Item instances: track runtime modifications
- IDs: prevent circular references

### Cloud Save Integration

**Research Findings:**
- Cloud saves require authentication
- Sync should compare timestamps
- Conflict resolution needed (local vs cloud)
- Godot BaaS (Backend-as-a-Service) options available

**Sources:**
- [Godot Cloud Services](https://docs.godotengine.org/en/stable/tutorials/networking/index.html) - Networking and cloud
- General cloud save implementation patterns

**Implementation Approach:**
- Optional cloud save service
- HTTP requests for upload/download
- Timestamp comparison for sync
- Conflict resolution: newer wins or user choice

**Why This Approach:**
- Optional: doesn't require cloud for local saves
- HTTP: standard protocol
- Timestamps: simple conflict resolution
- User choice: allows manual conflict resolution

### Save File Format Best Practices

**Research Findings:**
- Version field essential for compatibility
- Metadata separate from game data
- Compression reduces file size
- Validation prevents corrupted saves

**Sources:**
- General save system patterns
- JSON best practices

**Implementation Approach:**
- Version field in save header
- Metadata (date, playtime, thumbnail) separate
- Compressed JSON for storage
- Validation before load

**Why This Approach:**
- Version: handles updates
- Metadata: quick access without full load
- Compression: reduces storage
- Validation: prevents crashes

---

## Data Structures

### SaveSlot

```gdscript
class_name SaveSlot
extends RefCounted

var slot_index: int
var save_name: String
var save_date: String
var play_time: float  # Seconds
var thumbnail: Image
var world_seed: int
var player_position: Vector2
var save_data: Dictionary = {}
```

### SaveData

```gdscript
class_name SaveData
extends RefCounted

# Metadata
var version: String = "1.0"
var save_date: String
var play_time: float

# Player Data
var player_data: Dictionary = {}

# World Data
var world_data: Dictionary = {}

# Systems Data
var survival_data: Dictionary = {}
var inventory_data: Dictionary = {}
var crafting_data: Dictionary = {}
var building_data: Dictionary = {}
var progression_data: Dictionary = {}

# Serialization
func to_json() -> String
func from_json(json_string: String) -> bool
func validate() -> bool
```

---

## Core Classes

### SaveManager (Autoload Singleton)

```gdscript
class_name SaveManager
extends Node

# Save Slots Configuration
@export var max_save_slots: int = 10
var save_slots: Array[SaveSlot] = []

# Current Save State
var current_save_slot: int = -1
var is_saving: bool = false
var is_loading: bool = false

# Autosave Configuration
@export var autosave_enabled: bool = true
@export var autosave_interval: float = 300.0  # 5 minutes
var autosave_timer: float = 0.0

# Cloud Save Configuration
@export var cloud_save_enabled: bool = false
var cloud_save_service: CloudSaveService = null

# File Configuration
var save_directory: String = "user://saves/"
var save_file_extension: String = ".save"
var save_version: String = "1.0"  # Current save version

# Version Support
var supported_versions: Array[String] = ["1.0"]  # All supported save versions
var version_handlers: Dictionary = {}  # version -> handler function

# Encryption Configuration
@export var encryption_enabled: bool = false
var encryption_key: String = ""  # Set at runtime

# Compression Configuration
@export var compression_enabled: bool = true

# Signals
signal save_started(slot_index: int)
signal save_completed(slot_index: int, success: bool)
signal load_started(slot_index: int)
signal load_completed(slot_index: int, success: bool)
signal autosave_triggered()
signal save_slot_updated(slot_index: int)

# Initialization
func _ready() -> void
func initialize() -> void

# Save Operations
func create_new_save(slot_index: int, save_name: String) -> bool
func save_game(slot_index: int, save_name: String = "") -> bool
func save_game_async(slot_index: int, save_name: String = "") -> void
func autosave() -> void

# Load Operations
func load_game(slot_index: int) -> bool
func load_game_async(slot_index: int) -> void

# Save Slot Management
func delete_save(slot_index: int) -> bool
func get_save_slots() -> Array[SaveSlot]
func get_save_slot(index: int) -> SaveSlot
func get_save_slot_metadata(slot_index: int) -> Dictionary
func slot_exists(slot_index: int) -> bool

# Data Collection/Application
func collect_save_data() -> SaveData
func apply_save_data(data: SaveData) -> bool

# File Operations
func save_to_file(slot_index: int, data: SaveData) -> bool
func load_from_file(slot_index: int) -> SaveData
func get_save_file_path(slot_index: int) -> String

# Cloud Operations
func save_to_cloud(slot_index: int) -> bool
func load_from_cloud(slot_index: int) -> bool

# Version Management
func can_load_version(version: String) -> bool
func register_version_handler(version: String, handler: Callable) -> void
func load_with_version_handler(data: Dictionary, version: String) -> bool
func sync_with_cloud() -> void

# Utility
func create_thumbnail() -> Image
func validate_save_data(data: SaveData) -> bool
func compress_data(data: String) -> PackedByteArray
func decompress_data(compressed: PackedByteArray) -> String
func encrypt_data(data: String) -> String
func decrypt_data(encrypted: String) -> String
```

### CloudSaveService

```gdscript
class_name CloudSaveService
extends RefCounted

var api_endpoint: String = ""
var api_key: String = ""
var user_id: String = ""
var is_authenticated: bool = false

func authenticate(user_id: String, api_key: String) -> bool
func upload_save(slot_index: int, save_data: SaveData) -> bool
func download_save(slot_index: int) -> SaveData
func list_cloud_saves() -> Array[Dictionary]
func delete_cloud_save(slot_index: int) -> bool
func sync_with_local() -> void
```

---

## System Architecture

### Component Hierarchy

```
SaveManager (Node)
├── SaveSlot[] (Array)
├── CloudSaveService (RefCounted)
└── UI/SaveLoadUI (Control)
    ├── SaveSlotList (ItemList)
    ├── SaveNameInput (LineEdit)
    └── CloudSyncButton (Button)
```

### Data Flow

1. **Save Process:**
   ```
   Player saves game
   ├── SaveManager.save_game(slot_index)
   ├── Collect save data from all systems
   ├── Create SaveData object
   ├── Serialize to JSON
   ├── Encrypt (optional)
   ├── Write to file
   ├── Create thumbnail
   ├── Update save slot metadata
   └── Upload to cloud (if enabled)
   ```

2. **Load Process:**
   ```
   Player loads game
   ├── SaveManager.load_game(slot_index)
   ├── Read save file
   ├── Decrypt (if encrypted)
   ├── Parse JSON
   ├── Validate save data
   ├── Apply data to all systems
   └── Restore game state
   ```

---

## Algorithms

### Data Collection Algorithm (Using All Systems)

```gdscript
func collect_save_data() -> SaveData:
    var save_data: SaveData = SaveData.new()
    
    # Set metadata
    save_data.version = save_version
    save_data.save_date = Time.get_datetime_string_from_system()
    save_data.play_time = GameManager.get_play_time() if GameManager else 0.0
    
    # Player data (from Player Controller)
    var player = get_tree().get_first_node_in_group("player")
    if player:
        save_data.player_data = {
            "position": {"x": player.global_position.x, "y": player.global_position.y},
            "rotation": player.rotation
        }
    
    # Survival data (from SurvivalManager)
    if SurvivalManager:
        save_data.survival_data = SurvivalManager.get_save_data()
    
    # Inventory data (from InventoryManager)
    if InventoryManager:
        save_data.inventory_data = InventoryManager.save_inventory()
    
    # Equipment data (from EquipmentManager)
    if EquipmentManager:
        save_data.equipment_data = EquipmentManager.get_save_data()
    
    # Crafting data (from CraftingManager)
    if CraftingManager:
        save_data.crafting_data = CraftingManager.get_save_data()
    
    # Building data (from BuildingManager)
    if BuildingManager:
        save_data.building_data = BuildingManager.get_save_data()
    
    # Combat data (from CombatManager)
    if CombatManager:
        save_data.combat_data = CombatManager.get_save_data()
    
    # Progression data (from ProgressionManager)
    if ProgressionManager:
        save_data.progression_data = ProgressionManager.get_save_data()
    
    # Quest data (from QuestManager)
    if QuestManager:
        save_data.quest_data = QuestManager.get_save_data()
    
    # World data (from WorldGenerator)
    if WorldGenerator:
        save_data.world_data = WorldGenerator.get_save_data()
    
    # Minimap data (from MinimapManager)
    if MinimapManager:
        save_data.minimap_data = MinimapManager.get_save_data()
    
    return save_data
```

### Save Game Algorithm

```gdscript
func save_game(slot_index: int, save_name: String = "") -> bool:
    if is_saving:
        push_warning("SaveManager: Already saving, cannot start new save")
        return false
    
    if slot_index < 0 or slot_index >= max_save_slots:
        push_error("SaveManager: Invalid slot index: " + str(slot_index))
        return false
    
    is_saving = true
    save_started.emit(slot_index)
    
    # Collect save data from all systems
    var save_data = collect_save_data()
    if save_data == null:
        push_error("SaveManager: Failed to collect save data")
        is_saving = false
        save_completed.emit(slot_index, false)
        return false
    
    # Validate save data
    if not validate_save_data(save_data):
        push_error("SaveManager: Save data validation failed")
        is_saving = false
        save_completed.emit(slot_index, false)
        return false
    
    # Create save slot if new
    if not slot_exists(slot_index):
        if save_name.is_empty():
            save_name = "Save " + str(slot_index + 1)
        create_new_save(slot_index, save_name)
    
    # Update save slot metadata
    var slot = get_save_slot(slot_index)
    slot.save_name = save_name if not save_name.is_empty() else slot.save_name
    slot.save_date = save_data.save_date
    slot.play_time = save_data.play_time
    slot.world_seed = save_data.world_data.get("seed", 0)
    slot.save_data = save_data
    
    # Create thumbnail
    slot.thumbnail = create_thumbnail()
    
    # Save to file
    var success = save_to_file(slot_index, save_data)
    
    if success:
        current_save_slot = slot_index
        save_slot_updated.emit(slot_index)
        
        # Upload to cloud if enabled
        if cloud_save_enabled:
            save_to_cloud(slot_index)
    else:
        push_error("SaveManager: Failed to save to file")
    
    is_saving = false
    save_completed.emit(slot_index, success)
    return success
```

### Load Game Algorithm

```gdscript
func load_game(slot_index: int) -> bool:
    if is_loading:
        push_warning("SaveManager: Already loading, cannot start new load")
        return false
    
    if slot_index < 0 or slot_index >= max_save_slots:
        push_error("SaveManager: Invalid slot index: " + str(slot_index))
        return false
    
    if not slot_exists(slot_index):
        push_error("SaveManager: Save slot does not exist: " + str(slot_index))
        return false
    
    is_loading = true
    load_started.emit(slot_index)
    
    # Load from file
    var save_data = load_from_file(slot_index)
    if save_data == null:
        push_error("SaveManager: Failed to load save file")
        is_loading = false
        load_completed.emit(slot_index, false)
        return false
    
    # Validate save data
    if not validate_save_data(save_data):
        push_error("SaveManager: Save data validation failed")
        is_loading = false
        load_completed.emit(slot_index, false)
        return false
    
    # Check version compatibility
    if save_data.version != save_version:
        push_warning("SaveManager: Save version mismatch: " + save_data.version + " vs " + save_version)
        # Support multiple save versions simultaneously
        # Each version handler knows how to load its own format
        if not can_load_version(save_data.version):
            push_error("SaveManager: Unsupported save version: " + save_data.version)
            return false
        
        # Use version-specific handler
        var success = load_with_version_handler(save_data.to_dictionary(), save_data.version)
        if success:
            current_save_slot = slot_index
        is_loading = false
        load_completed.emit(slot_index, success)
        return success
    
    # Apply save data to all systems (current version)
    var success = apply_save_data(save_data)
    
    if success:
        current_save_slot = slot_index
        GameManager.set_play_time(save_data.play_time) if GameManager else null
    else:
        push_error("SaveManager: Failed to apply save data")
    
    is_loading = false
    load_completed.emit(slot_index, success)
    return success
```

### Version Handling Algorithm

```gdscript
func can_load_version(version: String) -> bool:
    return version in supported_versions or version in version_handlers

func register_version_handler(version: String, handler: Callable) -> void:
    version_handlers[version] = handler
    if not version in supported_versions:
        supported_versions.append(version)

func load_with_version_handler(data: Dictionary, version: String) -> bool:
    if version in version_handlers:
        var handler = version_handlers[version]
        return handler.call(data)
    elif version in supported_versions:
        # Use default handler for supported versions
        return apply_save_data_from_dict(data, version)
    else:
        push_error("SaveManager: No handler for version: " + version)
        return false

func apply_save_data_from_dict(data: Dictionary, version: String) -> bool:
    # Convert dictionary to SaveData and apply
    # Each version handler can implement custom loading logic
    var save_data = SaveData.new()
    save_data.from_dictionary(data)
    return apply_save_data(save_data)
```

### Data Application Algorithm (Using All Systems)

```gdscript
func apply_save_data(data: SaveData) -> bool:
    # Validate
    if not validate_save_data(data):
        push_error("SaveManager: Invalid save data")
        return false
    
    # Apply player data
    var player = get_tree().get_first_node_in_group("player")
    if player and data.player_data.has("position"):
        var pos = data.player_data["position"]
        player.global_position = Vector2(pos.x, pos.y)
        if data.player_data.has("rotation"):
            player.rotation = data.player_data["rotation"]
    
    # Apply survival data
    if SurvivalManager and data.survival_data:
        SurvivalManager.load_inventory(data.survival_data)
    
    # Apply inventory data
    if InventoryManager and data.inventory_data:
        InventoryManager.load_inventory(data.inventory_data)
    
    # Apply equipment data
    if EquipmentManager and data.equipment_data:
        EquipmentManager.load_equipment(data.equipment_data)
    
    # Apply crafting data
    if CraftingManager and data.crafting_data:
        CraftingManager.load_crafting(data.crafting_data)
    
    # Apply building data
    if BuildingManager and data.building_data:
        BuildingManager.load_buildings(data.building_data)
    
    # Apply combat data
    if CombatManager and data.combat_data:
        CombatManager.load_combat(data.combat_data)
    
    # Apply progression data
    if ProgressionManager and data.progression_data:
        ProgressionManager.load_progression(data.progression_data)
    
    # Apply quest data
    if QuestManager and data.quest_data:
        QuestManager.load_quests(data.quest_data)
    
    # Apply world data
    if WorldGenerator and data.world_data:
        WorldGenerator.load_world(data.world_data)
    
    # Apply minimap data
    if MinimapManager and data.minimap_data:
        MinimapManager.load_minimap(data.minimap_data)
    
    return true
```

### Encryption

```gdscript
func encrypt_save_data(data: String, key: String) -> String:
    # Simple XOR encryption (for basic obfuscation)
    # For production, use proper encryption library
    var encrypted: PackedByteArray = []
    var key_bytes: PackedByteArray = key.to_utf8_buffer()
    
    for i in range(data.length()):
        var byte: int = data.unicode_at(i)
        var key_byte: int = key_bytes[i % key_bytes.size()]
        encrypted.append(byte ^ key_byte)
    
    return encrypted.get_string_from_utf8()

func decrypt_save_data(encrypted: String, key: String) -> String:
    # Same as encryption (XOR is symmetric)
    return encrypt_save_data(encrypted, key)
```

### Cloud Sync

```gdscript
func sync_with_cloud() -> void:
    if not cloud_save_enabled:
        return
    
    # Compare local and cloud saves
    var local_saves: Array[SaveSlot] = get_save_slots()
    var cloud_saves: Array[Dictionary] = cloud_save_service.list_cloud_saves()
    
    for local_save in local_saves:
        var cloud_save: Dictionary = find_cloud_save(local_save.slot_index, cloud_saves)
        
        if cloud_save.is_empty():
            # Upload local save
            cloud_save_service.upload_save(local_save.slot_index, local_save.save_data)
        else:
            # Compare timestamps
            var local_date: String = local_save.save_date
            var cloud_date: String = cloud_save.save_date
            
            if local_date > cloud_date:
                # Upload local (newer)
                cloud_save_service.upload_save(local_save.slot_index, local_save.save_data)
            elif cloud_date > local_date:
                # Download cloud (newer)
                var cloud_data: SaveData = cloud_save_service.download_save(local_save.slot_index)
                apply_save_data(cloud_data)
```

---

## Integration Points

### With All Systems

Each system needs:
```gdscript
func get_save_data() -> Dictionary:
    # Return system-specific save data
    pass

func apply_save_data(data: Dictionary) -> void:
    # Restore system state from save data
    pass
```

---

## File Structure

### Save File Format

```json
{
    "version": "1.0",
    "save_date": "2025-11-24T12:00:00Z",
    "play_time": 3600.0,
    "world_seed": 12345,
    "player_data": {
        "position": {"x": 100.0, "y": 200.0},
        "rotation": 0.0
    },
    "survival_data": {
        "health": 100.0,
        "hunger": 80.0,
        "thirst": 90.0
    },
    "inventory_data": {
        "items": [...]
    },
    "crafting_data": {
        "discovered_recipes": [...]
    },
    "building_data": {
        "placed_buildings": [...]
    },
    "world_data": {
        "generated_chunks": [...],
        "modified_chunks": [...]
    },
    "progression_data": {
        "unlocked_tech_nodes": [...],
        "skill_points": 10
    }
}
```

### File Operations Algorithm

```gdscript
func save_to_file(slot_index: int, data: SaveData) -> bool:
    # Serialize to JSON
    var json_string = data.to_json()
    if json_string.is_empty():
        push_error("SaveManager: Failed to serialize save data")
        return false
    
    # Compress if enabled
    var save_data: PackedByteArray
    if compression_enabled:
        save_data = compress_data(json_string)
    else:
        save_data = json_string.to_utf8_buffer()
    
    # Encrypt if enabled
    if encryption_enabled:
        var encrypted_string = encrypt_data(save_data.get_string_from_utf8())
        save_data = encrypted_string.to_utf8_buffer()
    
    # Ensure save directory exists
    var dir = DirAccess.open("user://")
    if dir == null:
        push_error("SaveManager: Cannot access user directory")
        return false
    
    if not dir.dir_exists(save_directory.trim_prefix("user://")):
        dir.make_dir_recursive(save_directory.trim_prefix("user://"))
    
    # Write to file
    var file_path = get_save_file_path(slot_index)
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file == null:
        push_error("SaveManager: Cannot open save file for writing: " + file_path)
        return false
    
    file.store_buffer(save_data)
    file.close()
    
    # Create backup
    var backup_path = file_path + ".backup"
    var backup_file = FileAccess.open(backup_path, FileAccess.WRITE)
    if backup_file:
        backup_file.store_buffer(save_data)
        backup_file.close()
    
    return true

func load_from_file(slot_index: int) -> SaveData:
    var file_path = get_save_file_path(slot_index)
    
    # Try main file first, then backup
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        # Try backup
        file = FileAccess.open(file_path + ".backup", FileAccess.READ)
        if file == null:
            push_error("SaveManager: Cannot open save file: " + file_path)
            return null
    
    var save_data = file.get_buffer(file.get_length())
    file.close()
    
    # Decrypt if enabled
    var decrypted_string: String
    if encryption_enabled:
        decrypted_string = decrypt_data(save_data.get_string_from_utf8())
    else:
        decrypted_string = save_data.get_string_from_utf8()
    
    # Decompress if enabled
    var json_string: String
    if compression_enabled:
        json_string = decompress_data(decrypted_string.to_utf8_buffer())
    else:
        json_string = decrypted_string
    
    # Parse JSON
    var json = JSON.new()
    var error = json.parse(json_string)
    if error != OK:
        push_error("SaveManager: Failed to parse JSON: " + json.get_error_message())
        return null
    
    # Create SaveData from JSON
    var save_data_obj = SaveData.new()
    if not save_data_obj.from_json(json_string):
        push_error("SaveManager: Failed to create SaveData from JSON")
        return null
    
    return save_data_obj
```

---

## Error Handling

### SaveManager Error Handling

- **Invalid Slot Indices:** Validate slot indices before operations, return errors gracefully
- **File Access Errors:** Handle file permission errors, return clear error messages
- **Corrupted Save Files:** Validate save data before applying, use backup if main file corrupted
- **Version Mismatches:** Handle save version differences, migrate if possible
- **Missing Systems:** Handle missing system managers gracefully (optional systems)

### Best Practices

- Use `push_error()` for critical errors (file access, corrupted data)
- Use `push_warning()` for non-critical issues (version mismatch, missing optional data)
- Return false/null on errors (don't crash)
- Validate all data before applying
- Use backup files for recovery
- Handle async operations gracefully

---

## Default Values and Configuration

### SaveManager Defaults

```gdscript
# Save Slots
max_save_slots = 10

# Autosave
autosave_enabled = true
autosave_interval = 300.0  # 5 minutes

# Cloud Save
cloud_save_enabled = false

# File Settings
save_directory = "user://saves/"
save_file_extension = ".save"
save_version = "1.0"

# Features
encryption_enabled = false
compression_enabled = true
```

### SaveData Defaults

```gdscript
version = "1.0"
save_date = ""
play_time = 0.0
player_data = {}
world_data = {}
survival_data = {}
inventory_data = {}
equipment_data = {}
crafting_data = {}
building_data = {}
combat_data = {}
progression_data = {}
quest_data = {}
minimap_data = {}
```

### SaveSlot Defaults

```gdscript
slot_index = -1
save_name = ""
save_date = ""
play_time = 0.0
thumbnail = null
world_seed = 0
save_data = {}
```

---

## Performance Considerations

### Optimization Strategies

1. **Async Saving:**
   - Use call_deferred for async operations
   - Save in background to prevent UI freezing
   - Show save indicator during async save

2. **Compression:**
   - GZIP compression reduces file size significantly
   - Faster load times for compressed files
   - Configurable compression level

3. **Incremental Saves:**
   - Only save changed chunks/data
   - Track modified data per system
   - Full save periodically, incremental between

4. **Validation:**
   - Validate before applying (prevents crashes)
   - Check version compatibility
   - Verify data structure integrity

5. **Backup System:**
   - Keep backup of previous save
   - Auto-recover from backup if main file corrupted
   - Limit backup count (e.g., keep last 3)

6. **File Management:**
   - Cache save slot metadata (don't load full files)
   - Lazy load save data (only when loading)
   - Clean up old backups periodically

---

## Testing Checklist

- [ ] Save game works correctly
- [ ] Load game restores state correctly
- [ ] Multiple save slots work
- [ ] Save slot metadata displays correctly
- [ ] Autosave works
- [ ] Cloud save uploads correctly
- [ ] Cloud save downloads correctly
- [ ] Cloud sync works correctly
- [ ] Save file validation works
- [ ] Encryption/decryption works
- [ ] Performance is acceptable

### Integration
- [ ] Collects data from all systems correctly
- [ ] Applies data to all systems correctly
- [ ] Item instances saved/loaded correctly (durability)
- [ ] References saved as IDs correctly

### Edge Cases
- [ ] Invalid slot indices handled
- [ ] Missing save files handled
- [ ] Corrupted save files handled (backup recovery)
- [ ] Version mismatches handled
- [ ] Missing systems handled gracefully
- [ ] Async save/load works correctly
- [ ] Cloud sync conflicts handled

---

## Complete Implementation

### SaveData Complete Implementation

```gdscript
class_name SaveData
extends RefCounted

var version: String = "1.0"
var save_date: String = ""
var play_time: float = 0.0

# System Data
var player_data: Dictionary = {}
var world_data: Dictionary = {}
var survival_data: Dictionary = {}
var inventory_data: Dictionary = {}
var equipment_data: Dictionary = {}
var crafting_data: Dictionary = {}
var building_data: Dictionary = {}
var combat_data: Dictionary = {}
var progression_data: Dictionary = {}
var quest_data: Dictionary = {}
var minimap_data: Dictionary = {}

func to_json() -> String:
    var dict = {
        "version": version,
        "save_date": save_date,
        "play_time": play_time,
        "player_data": player_data,
        "world_data": world_data,
        "survival_data": survival_data,
        "inventory_data": inventory_data,
        "equipment_data": equipment_data,
        "crafting_data": crafting_data,
        "building_data": building_data,
        "combat_data": combat_data,
        "progression_data": progression_data,
        "quest_data": quest_data,
        "minimap_data": minimap_data
    }
    
    var json = JSON.new()
    json.stringify(dict)
    return json.get_string()

func from_json(json_string: String) -> bool:
    var json = JSON.new()
    var error = json.parse(json_string)
    if error != OK:
        push_error("SaveData: JSON parse error: " + json.get_error_message())
        return false
    
    var dict = json.data as Dictionary
    if dict == null:
        return false
    
    version = dict.get("version", "1.0")
    save_date = dict.get("save_date", "")
    play_time = dict.get("play_time", 0.0)
    player_data = dict.get("player_data", {})
    world_data = dict.get("world_data", {})
    survival_data = dict.get("survival_data", {})
    inventory_data = dict.get("inventory_data", {})
    equipment_data = dict.get("equipment_data", {})
    crafting_data = dict.get("crafting_data", {})
    building_data = dict.get("building_data", {})
    combat_data = dict.get("combat_data", {})
    progression_data = dict.get("progression_data", {})
    quest_data = dict.get("quest_data", {})
    minimap_data = dict.get("minimap_data", {})
    
    return true

func validate() -> bool:
    if version.is_empty():
        return false
    if save_date.is_empty():
        return false
    # Add more validation as needed
    return true
```

### SaveManager Initialization

```gdscript
func _ready() -> void:
    initialize()

func initialize() -> void:
    # Ensure save directory exists
    var dir = DirAccess.open("user://")
    if dir:
        if not dir.dir_exists(save_directory.trim_prefix("user://")):
            dir.make_dir_recursive(save_directory.trim_prefix("user://"))
    
    # Load save slot metadata
    load_save_slot_metadata()
    
    # Initialize cloud save service if enabled
    if cloud_save_enabled:
        cloud_save_service = CloudSaveService.new()

func load_save_slot_metadata() -> void:
    save_slots.clear()
    for i in range(max_save_slots):
        var slot = SaveSlot.new()
        slot.slot_index = i
        
        if slot_exists(i):
            var metadata = get_save_slot_metadata(i)
            slot.save_name = metadata.get("save_name", "Save " + str(i + 1))
            slot.save_date = metadata.get("save_date", "")
            slot.play_time = metadata.get("play_time", 0.0)
            slot.world_seed = metadata.get("world_seed", 0)
        
        save_slots.append(slot)
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── SaveManager.gd
   └── scripts/
       └── save/
           ├── SaveData.gd
           ├── SaveSlot.gd
           └── CloudSaveService.gd
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/SaveManager.gd` as `SaveManager`
   - **Important:** Load after all systems that need to save

3. **Configure Save Settings:**
   - Set max_save_slots (default: 10)
   - Configure autosave settings
   - Enable/disable cloud saves
   - Set encryption key (if encryption enabled)

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. All other systems...
4. **SaveManager** (last, after all systems that save)

### System Integration

**Each System Must Implement:**
```gdscript
# In each system manager
func get_save_data() -> Dictionary:
    # Return system-specific save data
    return {}

func load_save_data(data: Dictionary) -> void:
    # Restore system state from save data
    pass
```

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Save System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **File System:** https://docs.godotengine.org/en/stable/tutorials/io/index.html
- **JSON:** https://docs.godotengine.org/en/stable/classes/class_json.html
- **FileAccess:** https://docs.godotengine.org/en/stable/classes/class_fileaccess.html
- **DirAccess:** https://docs.godotengine.org/en/stable/classes/class_diraccess.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Save System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [File System Tutorial](https://docs.godotengine.org/en/stable/tutorials/io/index.html) - File I/O operations
- [JSON Documentation](https://docs.godotengine.org/en/stable/classes/class_json.html) - JSON serialization
- [FileAccess Documentation](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html) - File operations
- [DirAccess Documentation](https://docs.godotengine.org/en/stable/classes/class_diraccess.html) - Directory operations
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- SaveManager is a Node (can be added to scene tree)
- SaveData and SaveSlot are RefCounted classes (lightweight)
- Configuration via @export variables (editable in inspector)

**Visual Configuration:**
- Save settings configured via @export variables in inspector
- Save slots managed programmatically

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Save slot browser/manager
  - Save file validator
  - Cloud save tester

**Current Approach:**
- Uses Godot's native file system (no custom tools needed)
- Save settings configured via code/export variables
- Fully functional without custom editor tools

---

## Implementation Notes

1. **System Integration:** Each system must implement get_save_data() and load_save_data() methods
2. **Item Instances:** Item instances saved as {item_id, durability, metadata} for runtime modifications
3. **References:** All references saved as IDs (item_id, recipe_id, etc.) to prevent circular references
4. **Version System:** Save version checked on load, migration system for version updates
5. **Compression:** GZIP compression reduces file size (configurable)
6. **Encryption:** Optional encryption prevents save editing (XOR for basic, proper encryption for production)
7. **Backup System:** Backup files created automatically, used for recovery if main file corrupted
8. **Async Operations:** Async save/load prevents UI freezing
9. **Cloud Saves:** Optional cloud save service for cross-device sync
10. **Validation:** Save data validated before applying to prevent crashes

---

