# Technical Specifications: Item Database System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the centralized Item Database system that manages all item definitions, provides item lookup functionality, and handles item asset management. This system is a foundational dependency used by Inventory, Crafting, Progression, Combat, Building, and other systems.

---

## Research Notes

### Resource System Best Practices

**Research Findings:**
- Godot's Resource system is ideal for item data management
- Resources are lightweight, efficient, and load quickly
- Custom Resource classes with `@export` variables provide type safety and editor integration
- Resources can be edited visually in Godot editor
- Resource files (.tres) are the recommended approach for item databases

**Sources:**
- [Godot 4 Custom Resources Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Official Resource documentation
- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - Official best practices

**Implementation Approach:**
- Use Resource files (.tres) for all item data
- Create ItemData resource class with @export variables
- Load items from `res://resources/items/` directory
- Use Resource.duplicate() for runtime item instances

**Why This Approach:**
- Resources are Godot-native and optimized
- Editor-friendly for content creation
- Type-safe and extensible
- Standard practice for data-driven systems

### Loading Strategy Best Practices

**Research Findings:**
- Eager loading (load all at startup) is standard for autoload singletons
- Resources load quickly (<1ms per resource typically)
- Hybrid approach (eager common + lazy others) balances startup time and performance
- Dictionary lookups are O(1) after loading

**Sources:**
- [Godot 4 Performance Best Practices](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance optimization guide
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton initialization patterns

**Implementation Approach:**
- Hybrid loading: Eager load common item types (MATERIALS, WEAPONS, CONSUMABLES)
- Lazy load other types on first access
- Use CommonItemsConfig resource for configuration
- Cache loaded items immediately

**Why This Approach:**
- Balances startup time and runtime performance
- Common items available immediately
- Rare items loaded only when needed
- Configurable and flexible

### Search and Filter Optimization

**Research Findings:**
- Linear search is acceptable for small databases (<1000 items)
- Index-based search scales better for large databases
- Caching search results improves repeated queries
- Hybrid approach (indexes + caching) provides best performance

**Sources:**
- [Godot 4 Performance Best Practices](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance optimization guide
- [Dictionary Documentation](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) - Dictionary performance characteristics

**Implementation Approach:**
- Build search indexes (name index, tag index, category index)
- Cache frequent search queries
- Invalidate cache on item registration
- Use indexes for fast filtering

**Why This Approach:**
- Scales well to large item databases
- Fast repeated searches
- Good balance of memory and performance

### Asset Loading Best Practices

**Research Findings:**
- Icons are small and frequently accessed (UI)
- World sprites are larger and less common
- Hybrid loading (preload icons, lazy world sprites) balances memory and performance
- Texture atlases can be used for optimization

**Sources:**
- [Godot 4 Performance Best Practices](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance optimization guide
- [Texture Loading](https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html) - Texture and resource loading

**Implementation Approach:**
- Preload item icons when items are loaded (needed for UI)
- Lazy load world sprites on first access (only when dropped)
- Consider texture atlases for many small icons

**Why This Approach:**
- Icons needed immediately for inventory UI
- World sprites only needed when items are dropped
- Efficient memory usage
- Good performance balance

---

## Data Structures

### CommonItemsConfig (Resource)

**Purpose:** Configuration resource for hybrid loading strategy (eager common items + lazy others)

```gdscript
class_name CommonItemsConfig
extends Resource

# Item types to load eagerly (at startup)
@export var eager_load_types: Array[ItemData.ItemType] = [
    ItemData.ItemType.MATERIAL,
    ItemData.ItemType.WEAPON,
    ItemData.ItemType.CONSUMABLE
]

# Additional specific items to load eagerly (override/add)
@export var additional_eager_items: Array[String] = []

# Item types to load lazily (on first access)
@export var lazy_load_types: Array[ItemData.ItemType] = [
    ItemData.ItemType.QUEST_ITEM,
    ItemData.ItemType.OTHER
]

# Exclude specific items from eager loading (even if type matches)
@export var exclude_from_eager: Array[String] = []
```

**Location:** `res://resources/config/common_items_config.tres`

**Usage:** Created in Godot editor, assigned to ItemDatabase

### ItemData (Resource)

```gdscript
class_name ItemData
extends Resource

# Identification
@export var item_id: String  # Unique identifier (e.g., "iron_ore", "steel_sword")
@export var item_name: String  # Display name
@export var description: String  # Item description/tooltip

# Visual
@export var icon: Texture2D  # Inventory icon
@export var world_sprite: Texture2D  # Sprite when dropped in world (optional)
@export var sprite_scale: Vector2 = Vector2(1.0, 1.0)  # Scale for world sprite

# Stacking
@export var max_stack_size: int = 1  # 99 for stackable items, 1 for non-stackable
@export var is_stackable: bool = false

# Type Classification
@export var item_type: ItemType
@export var item_category: String = ""  # Sub-category (e.g., "metal", "food", "weapon_melee")

enum ItemType {
    MATERIAL,      # Raw materials, crafting ingredients
    TOOL,          # Tools for gathering/building
    WEAPON,        # Combat weapons
    ARMOR,         # Armor pieces
    CONSUMABLE,    # Food, potions, etc.
    BUILDING,      # Building pieces/blocks
    ACCESSORY,     # Accessories (rings, amulets, etc.)
    QUEST_ITEM,    # Quest-specific items
    OTHER          # Miscellaneous
}

# Durability (for tools, weapons, armor)
@export var durability: int = -1  # -1 means no durability, >0 means has durability
@export var current_durability: int = -1  # Runtime value (not saved in resource)

# Use Actions
@export var use_action: String = ""  # Action ID for quick-use items (e.g., "eat", "drink", "heal")
@export var use_effect: Dictionary = {}  # Effect data (e.g., {"health": 20, "hunger": 10})

# Crafting/Building
@export var crafting_material: bool = false  # Can be used in crafting
@export var building_piece: bool = false  # Can be placed as building piece
@export var building_piece_id: String = ""  # ID of building piece if applicable

# Combat Stats (for weapons/armor)
@export var damage: int = 0  # Base damage (weapons)
@export var defense: int = 0  # Defense value (armor)
@export var attack_speed: float = 1.0  # Attack speed multiplier
@export var range: float = 0.0  # Attack range (for ranged weapons)

# Equipment Slots (for armor/accessories)
@export var equipment_slot: EquipmentSlotType = EquipmentSlotType.NONE

enum EquipmentSlotType {
    NONE,
    HEAD,
    CHEST,
    LEGS,
    FEET,
    ACCESSORY
}

# Value/Economy
@export var base_value: int = 0  # Base sell/buy value
@export var rarity: int = 0  # 0 = common, higher = rarer (for sorting/filtering)

# Metadata
@export var tags: Array[String] = []  # Searchable tags (e.g., ["metal", "ore", "crafting"])
@export var metadata: Dictionary = {}  # Additional custom data
```

---

## Core Classes

### ItemDatabase (Autoload Singleton)

```gdscript
class_name ItemDatabase
extends Node

# Configuration
@export var common_items_config: CommonItemsConfig  # Assigned in editor or loaded

# Item Storage
var items: Dictionary = {}  # item_id -> ItemData (all loaded items)
var items_by_type: Dictionary = {}  # ItemType -> Array[ItemData]
var items_by_category: Dictionary = {}  # category -> Array[ItemData]

# Lazy Loading Tracking
var lazy_loaded_items: Dictionary = {}  # item_id -> bool (tracks lazy-loaded items)
var pending_lazy_items: Array[String] = []  # Items that should be lazy-loaded

# Search Indexes (for performance)
var name_index: Dictionary = {}  # lowercase_name -> Array[ItemData]
var tag_index: Dictionary = {}  # tag -> Array[ItemData]
var search_cache: Dictionary = {}  # query -> Array[ItemData] (cached results)

# Asset Paths
const ITEMS_PATH: String = "res://resources/items/"
const ITEM_ICONS_PATH: String = "res://assets/sprites/items/icons/"
const ITEM_WORLD_SPRITES_PATH: String = "res://assets/sprites/items/world/"

# Config Path
const COMMON_ITEMS_CONFIG_PATH: String = "res://resources/config/common_items_config.tres"

# Signals
signal item_registered(item_id: String, item_data: ItemData)
signal item_database_loaded()
signal item_lazy_loaded(item_id: String, item_data: ItemData)

# Initialization
func _ready() -> void
func load_config() -> void
func load_all_items() -> void
func load_eager_items() -> void
func register_item(item_data: ItemData, eager: bool = false) -> bool
func unregister_item(item_id: String) -> bool

# Item Lookup (with lazy loading)
func get_item(item_id: String) -> ItemData
func get_item_safe(item_id: String) -> ItemData  # Returns null if not found instead of error
func has_item(item_id: String) -> bool
func get_all_items() -> Array[ItemData]
func get_items_by_type(item_type: ItemType) -> Array[ItemData]
func get_items_by_category(category: String) -> Array[ItemData]

# Lazy Loading
func load_item_lazy(item_id: String) -> ItemData
func is_eager_item(item_data: ItemData) -> bool

# Item Queries (optimized with indexes and caching)
func search_items(query: String) -> Array[ItemData]  # Search by name, description, tags
func filter_items(filters: Dictionary) -> Array[ItemData]  # Advanced filtering
func get_items_with_tag(tag: String) -> Array[ItemData]

# Item Creation (Runtime)
func create_item_instance(item_id: String) -> ItemData  # Creates a deep copy for runtime use
func create_item_with_durability(item_id: String, durability_value: int) -> ItemData

# Index Management
func build_search_indexes() -> void
func invalidate_search_cache() -> void

# Validation
func validate_item(item_id: String) -> bool
func validate_item_data(item_data: ItemData) -> bool
```

---

## System Architecture

### Component Hierarchy

```
ItemDatabase (Autoload Singleton)
├── ItemLoader (loads .tres resource files)
├── ItemRegistry (manages item storage)
└── ItemQuery (handles searches/filters)
```

### Data Flow

1. **Initialization:**
   - Game starts → `ItemDatabase._ready()` called
   - `load_all_items()` scans `res://resources/items/` directory
   - Loads all `.tres` ItemData resource files
   - Registers each item in `items` dictionary
   - Organizes items by type and category
   - Emits `item_database_loaded` signal

2. **Item Lookup:**
   - System needs item → calls `ItemDatabase.get_item(item_id)`
   - Returns ItemData resource (shared reference)
   - For runtime modifications, use `create_item_instance()` to get a copy

3. **Item Registration:**
   - New item created → `register_item(item_data)` called
   - Validates item data
   - Adds to `items` dictionary
   - Updates type/category indexes
   - Emits `item_registered` signal

4. **Item Queries:**
   - UI needs filtered items → calls `search_items()` or `filter_items()`
   - Returns array of matching ItemData resources
   - Used for inventory search, crafting recipe browser, etc.

---

## Algorithms

### Configuration Loading Algorithm

```gdscript
func load_config() -> void:
    # Try to load config from path
    if ResourceLoader.exists(COMMON_ITEMS_CONFIG_PATH):
        common_items_config = load(COMMON_ITEMS_CONFIG_PATH) as CommonItemsConfig
    
    # If config doesn't exist, create default
    if common_items_config == null:
        common_items_config = CommonItemsConfig.new()
        # Set default eager types
        common_items_config.eager_load_types = [
            ItemData.ItemType.MATERIAL,
            ItemData.ItemType.WEAPON,
            ItemData.ItemType.CONSUMABLE
        ]
        common_items_config.lazy_load_types = [
            ItemData.ItemType.QUEST_ITEM,
            ItemData.ItemType.OTHER
        ]
        push_warning("ItemDatabase: Using default config. Create common_items_config.tres for customization.")
```

### Hybrid Loading Algorithm

```gdscript
func load_all_items() -> void:
    # Load configuration first
    load_config()
    
    # Scan all item files
    var dir = DirAccess.open(ITEMS_PATH)
    if dir == null:
        push_error("ItemDatabase: Cannot open items directory: " + ITEMS_PATH)
        return
    
    var eager_items: Array[String] = []
    var lazy_items: Array[String] = []
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        if file_name.ends_with(".tres"):
            var item_path = ITEMS_PATH + file_name
            var item_data = load(item_path) as ItemData
            
            if item_data == null:
                push_warning("ItemDatabase: Failed to load item: " + item_path)
            elif not validate_item_data(item_data):
                push_warning("ItemDatabase: Item validation failed: " + item_path)
            else:
                # Determine if item should be eager or lazy loaded
                if is_eager_item(item_data):
                    eager_items.append(item_data.item_id)
                    register_item(item_data, true)
                else:
                    lazy_items.append(item_data.item_id)
                    pending_lazy_items.append(item_data.item_id)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    
    # Preload icons for eager items
    preload_item_icons(eager_items)
    
    # Build search indexes
    build_search_indexes()
    
    emit_signal("item_database_loaded")
    print("ItemDatabase: Loaded ", items.size(), " items eagerly, ", pending_lazy_items.size(), " items lazy")

func is_eager_item(item_data: ItemData) -> bool:
    if common_items_config == null:
        return true  # Default to eager if no config
    
    # Check if item is in exclude list
    if item_data.item_id in common_items_config.exclude_from_eager:
        return false
    
    # Check if item is in additional eager list
    if item_data.item_id in common_items_config.additional_eager_items:
        return true
    
    # Check if item type is in eager types
    return item_data.item_type in common_items_config.eager_load_types

func load_eager_items() -> void:
    # This is called from load_all_items() - items are already loaded
    # This function exists for potential async loading in future
    pass
```

### Lazy Loading Algorithm

```gdscript
func load_item_lazy(item_id: String) -> ItemData:
    # Check if already loaded
    if items.has(item_id):
        return items[item_id]
    
    # Check if item exists in pending list
    if item_id not in pending_lazy_items:
        push_warning("ItemDatabase: Item not found in pending lazy items: " + item_id)
        return null
    
    # Load item resource
    var item_path = ITEMS_PATH + item_id + ".tres"
    if not ResourceLoader.exists(item_path):
        push_error("ItemDatabase: Lazy item file not found: " + item_path)
        pending_lazy_items.erase(item_id)
        return null
    
    var item_data = load(item_path) as ItemData
    
    if item_data == null:
        push_error("ItemDatabase: Failed to lazy load item: " + item_path)
        pending_lazy_items.erase(item_id)
        return null
    
    if not validate_item_data(item_data):
        push_warning("ItemDatabase: Lazy item validation failed: " + item_path)
        pending_lazy_items.erase(item_id)
        return null
    
    # Register item
    register_item(item_data, false)
    
    # Load icon (needed for UI)
    if item_data.icon == null:
        load_item_icon(item_data)
    
    # Update indexes
    update_indexes_for_item(item_data)
    
    # Mark as lazy loaded
    lazy_loaded_items[item_id] = true
    pending_lazy_items.erase(item_id)
    
    # Emit signal
    item_lazy_loaded.emit(item_id, item_data)
    
    return item_data

func get_item(item_id: String) -> ItemData:
    # Check if already loaded
    if items.has(item_id):
        return items[item_id]
    
    # Try lazy loading
    return load_item_lazy(item_id)
```

### Item Registration Algorithm

```gdscript
func register_item(item_data: ItemData, eager: bool = false) -> bool:
    if not validate_item_data(item_data):
        return false
    
    var item_id = item_data.item_id
    
    # Check for duplicates
    if items.has(item_id):
        push_warning("ItemDatabase: Duplicate item_id: " + item_id)
        return false
    
    # Register in main dictionary
    items[item_id] = item_data
    
    # Register by type
    if not items_by_type.has(item_data.item_type):
        items_by_type[item_data.item_type] = []
    items_by_type[item_data.item_type].append(item_data)
    
    # Register by category
    if not item_data.item_category.is_empty():
        if not items_by_category.has(item_data.item_category):
            items_by_category[item_data.item_category] = []
        items_by_category[item_data.item_category].append(item_data)
    
    # Update search indexes (if not lazy loading)
    if eager or lazy_loaded_items.has(item_id):
        update_indexes_for_item(item_data)
    
    # Invalidate search cache (new item added)
    invalidate_search_cache()
    
    emit_signal("item_registered", item_id, item_data)
    return true

func update_indexes_for_item(item_data: ItemData) -> void:
    # Add to name index
    var name_lower = item_data.item_name.to_lower()
    if not name_index.has(name_lower):
        name_index[name_lower] = []
    name_index[name_lower].append(item_data)
    
    # Add to tag index
    for tag in item_data.tags:
        var tag_lower = tag.to_lower()
        if not tag_index.has(tag_lower):
            tag_index[tag_lower] = []
        tag_index[tag_lower].append(item_data)
```

### Item Search Algorithm (Optimized with Indexes and Caching)

```gdscript
func search_items(query: String) -> Array[ItemData]:
    if query.is_empty():
        return []
    
    # Check cache first
    if search_cache.has(query):
        return search_cache[query]
    
    var query_lower = query.to_lower()
    var results: Array[ItemData] = []
    var found_items: Dictionary = {}  # item_id -> ItemData (to avoid duplicates)
    
    # Search in name index (fast)
    for name_key in name_index.keys():
        if name_key.contains(query_lower):
            for item in name_index[name_key]:
                found_items[item.item_id] = item
    
    # Search in tag index (fast)
    for tag_key in tag_index.keys():
        if tag_key.contains(query_lower):
            for item in tag_index[tag_key]:
                found_items[item.item_id] = item
    
    # Search in descriptions (slower, but needed for full-text search)
    for item_id in items:
        var item = items[item_id]
        if item.description.to_lower().contains(query_lower):
            found_items[item_id] = item
    
    # Convert to array
    for item_id in found_items:
        results.append(found_items[item_id])
    
    # Cache result (limit cache size)
    if search_cache.size() > 100:
        # Remove oldest entries (simple FIFO)
        var oldest_key = search_cache.keys()[0]
        search_cache.erase(oldest_key)
    
    search_cache[query] = results
    return results

func invalidate_search_cache() -> void:
    search_cache.clear()
```

### Item Filtering Algorithm (Optimized)

```gdscript
func filter_items(filters: Dictionary) -> Array[ItemData]:
    var results: Array[ItemData] = []
    
    # Use type index if filtering by type (faster)
    var items_to_check: Array[ItemData] = []
    if filters.has("type"):
        var filter_type = filters.type as ItemData.ItemType
        if items_by_type.has(filter_type):
            items_to_check = items_by_type[filter_type]
        else:
            return []  # No items of this type
    else:
        # Check all items
        for item_id in items:
            items_to_check.append(items[item_id])
    
    # Filter items
    for item in items_to_check:
        var matches = true
        
        # Filter by category
        if filters.has("category"):
            if item.item_category != filters.category:
                matches = false
                continue
        
        # Filter by tags
        if filters.has("tags"):
            var required_tags = filters.tags as Array[String]
            for tag in required_tags:
                if not item.tags.has(tag):
                    matches = false
                    break
        
        # Filter by stackable
        if filters.has("stackable"):
            if item.is_stackable != filters.stackable:
                matches = false
                continue
        
        # Filter by min/max value
        if filters.has("min_value"):
            if item.base_value < filters.min_value:
                matches = false
                continue
        
        if filters.has("max_value"):
            if item.base_value > filters.max_value:
                matches = false
                continue
        
        if matches:
            results.append(item)
    
    return results

func get_items_with_tag(tag: String) -> Array[ItemData]:
    var tag_lower = tag.to_lower()
    if tag_index.has(tag_lower):
        return tag_index[tag_lower].duplicate()
    return []
```

### Index Building Algorithm

```gdscript
func build_search_indexes() -> void:
    name_index.clear()
    tag_index.clear()
    
    for item_id in items:
        var item = items[item_id]
        update_indexes_for_item(item)
```

---

## Integration Points

### Inventory System

**Usage:**
- `InventoryManager` calls `ItemDatabase.get_item(item_id)` when loading saved inventory
- Creates item instances for inventory slots
- Validates items before adding to inventory

**Example:**
```gdscript
# In InventoryManager
func add_item_by_id(item_id: String, quantity: int = 1) -> int:
    var item_data = ItemDatabase.get_item(item_id)
    if item_data == null:
        push_error("InventoryManager: Invalid item_id: " + item_id)
        return 0
    
    # Create instance for inventory slot (to allow durability modifications)
    var item_instance = ItemDatabase.create_item_instance(item_id)
    return add_item(item_instance, quantity)
```

### Crafting System

**Usage:**
- `CraftingManager` validates recipe ingredients using `ItemDatabase.has_item()`
- Gets item data for recipe results
- Queries items by category for recipe browser

**Example:**
```gdscript
# In CraftingManager
func validate_recipe(recipe: CraftingRecipe) -> bool:
    for ingredient_id in recipe.ingredients:
        if not ItemDatabase.has_item(ingredient_id):
            return false
    return true

func get_craftable_items(category: String) -> Array[ItemData]:
    return ItemDatabase.get_items_by_category(category)
```

### Progression System

**Usage:**
- Achievement rewards reference items by ID
- Tech tree unlocks may reference items
- Uses `ItemDatabase.get_item()` to get reward items

**Example:**
```gdscript
# In ProgressionManager
func grant_achievement_reward(achievement: Achievement):
    for reward in achievement.rewards:
        if reward.type == "item":
            var item_data = ItemDatabase.get_item(reward.item_id)
            InventoryManager.add_item_by_id(reward.item_id, reward.quantity)
```

### Combat System

**Usage:**
- Weapon data loaded from ItemDatabase
- Armor stats retrieved from ItemData
- Ammunition items validated

**Example:**
```gdscript
# In CombatManager
func equip_weapon(item_id: String):
    var weapon_data = ItemDatabase.get_item(item_id)
    if weapon_data.item_type != ItemData.ItemType.WEAPON:
        return false
    
    current_weapon = weapon_data
    player_damage = weapon_data.damage
    return true
```

### Building System

**Usage:**
- Building pieces loaded from ItemDatabase
- Validates items can be placed as building pieces
- Gets building piece data

**Example:**
```gdscript
# In BuildingManager
func can_place_building_piece(item_id: String) -> bool:
    var item_data = ItemDatabase.get_item(item_id)
    return item_data != null and item_data.building_piece
```

---

## Save/Load System

### Item Database Save

**Note:** ItemDatabase itself doesn't need to be saved (it's loaded from resources). However, runtime item instances (with modified durability) need to be saved.

**Save Format:**
```gdscript
# In SaveSystem
{
    "items": {
        "iron_sword": {
            "item_id": "iron_sword",
            "durability": 45,  # Current durability (if modified)
            "metadata": {}  # Any runtime metadata
        }
    }
}
```

**Load Format:**
```gdscript
# In SaveSystem
func load_item_instance(item_save_data: Dictionary) -> ItemData:
    var item_id = item_save_data.get("item_id", "")
    var item_data = ItemDatabase.create_item_instance(item_id)
    
    if item_data.durability > 0:
        item_data.current_durability = item_save_data.get("durability", item_data.durability)
    
    # Restore metadata if needed
    if item_save_data.has("metadata"):
        item_data.metadata = item_save_data.metadata
    
    return item_data
```

---

### Asset Loading Algorithms

```gdscript
func preload_item_icons(item_ids: Array[String]) -> void:
    # Preload icons for eager-loaded items (needed for UI)
    for item_id in item_ids:
        if items.has(item_id):
            var item = items[item_id]
            if item.icon == null:
                load_item_icon(item)

func load_item_icon(item_data: ItemData) -> void:
    # Load icon if not already loaded
    if item_data.icon != null:
        return
    
    var icon_path = ITEM_ICONS_PATH + item_data.item_id + ".png"
    if ResourceLoader.exists(icon_path):
        item_data.icon = load(icon_path) as Texture2D
    else:
        push_warning("ItemDatabase: Icon not found: " + icon_path)
        # Could load default/placeholder icon here

func load_item_world_sprite(item_data: ItemData) -> void:
    # Lazy load world sprite (only when item is dropped)
    if item_data.world_sprite != null:
        return
    
    var sprite_path = ITEM_WORLD_SPRITES_PATH + item_data.item_id + ".png"
    if ResourceLoader.exists(sprite_path):
        item_data.world_sprite = load(sprite_path) as Texture2D
    else:
        # Use icon as fallback
        if item_data.icon != null:
            item_data.world_sprite = item_data.icon
        else:
            push_warning("ItemDatabase: World sprite not found: " + sprite_path)
```

### Item Instance Creation (Deep Copy)

```gdscript
func create_item_instance(item_id: String) -> ItemData:
    # Get base item data
    var base_item = get_item(item_id)
    if base_item == null:
        push_error("ItemDatabase: Cannot create instance of unknown item: " + item_id)
        return null
    
    # Create deep copy for runtime modifications
    var instance = base_item.duplicate(true)  # true = deep copy
    
    # Initialize runtime-specific fields
    if instance.durability > 0:
        instance.current_durability = instance.durability
    
    return instance

func create_item_with_durability(item_id: String, durability_value: int) -> ItemData:
    var instance = create_item_instance(item_id)
    if instance == null:
        return null
    
    if instance.durability > 0:
        instance.current_durability = clamp(durability_value, 0, instance.durability)
    
    return instance
```

### Validation Algorithms (Hybrid: Strict Required, Lenient Optional)

```gdscript
func validate_item_data(item_data: ItemData) -> bool:
    # Strict validation for required fields
    if item_data.item_id.is_empty():
        push_error("ItemDatabase: Item missing required field: item_id")
        return false
    
    if item_data.item_name.is_empty():
        push_error("ItemDatabase: Item missing required field: item_name")
        return false
    
    # Lenient validation for optional fields (use defaults)
    if item_data.description.is_empty():
        push_warning("ItemDatabase: Item missing optional field: description (item_id: " + item_data.item_id + ")")
        item_data.description = "No description available."
    
    if item_data.icon == null:
        push_warning("ItemDatabase: Item missing optional field: icon (item_id: " + item_data.item_id + ")")
        # Icon will be loaded lazily if needed
    
    # Validate stackable consistency
    if item_data.is_stackable and item_data.max_stack_size <= 1:
        push_warning("ItemDatabase: Stackable item has max_stack_size <= 1 (item_id: " + item_data.item_id + ")")
        item_data.max_stack_size = 99  # Default for stackable
    
    if not item_data.is_stackable and item_data.max_stack_size > 1:
        push_warning("ItemDatabase: Non-stackable item has max_stack_size > 1 (item_id: " + item_data.item_id + ")")
        item_data.max_stack_size = 1  # Default for non-stackable
    
    # Validate durability
    if item_data.durability > 0 and item_data.current_durability < 0:
        item_data.current_durability = item_data.durability  # Initialize to max
    
    return true

func validate_item(item_id: String) -> bool:
    return items.has(item_id) or pending_lazy_items.has(item_id)
```

---

## Error Handling

### ItemDatabase Error Handling

- **Directory Access:** Check if items directory exists before scanning
- **Resource Loading:** Handle missing/corrupted resource files gracefully
- **Item Validation:** Strict validation for required fields, warnings for optional
- **Duplicate Items:** Warn and skip duplicate item_ids
- **Lazy Loading:** Handle missing lazy items gracefully
- **Index Building:** Handle empty indexes gracefully

### Best Practices

- Use `push_error()` for critical errors (missing required data)
- Use `push_warning()` for non-critical issues (missing optional data)
- Return null/empty arrays on errors (don't crash)
- Log errors for debugging
- Provide fallback values where appropriate

---

## Default Values and Configuration

### CommonItemsConfig Defaults

```gdscript
# Default eager load types
eager_load_types = [
    ItemData.ItemType.MATERIAL,
    ItemData.ItemType.WEAPON,
    ItemData.ItemType.CONSUMABLE
]

# Default lazy load types
lazy_load_types = [
    ItemData.ItemType.QUEST_ITEM,
    ItemData.ItemType.OTHER
]

# Empty arrays by default
additional_eager_items = []
exclude_from_eager = []
```

### ItemData Defaults

```gdscript
# Stacking defaults
max_stack_size = 1
is_stackable = false

# Durability defaults
durability = -1  # No durability
current_durability = -1  # Runtime value

# Combat defaults
damage = 0
defense = 0
attack_speed = 1.0
range = 0.0

# Value defaults
base_value = 0
rarity = 0

# Equipment defaults
equipment_slot = EquipmentSlotType.NONE

# Empty defaults
tags = []
metadata = {}
item_category = ""
description = ""  # Will use default if empty
```

### Search Cache Limits

```gdscript
# Maximum cached search queries
const MAX_CACHE_SIZE: int = 100
```

---

## Performance Considerations

### Optimization Strategies

1. **Hybrid Loading:**
   - Eager load common items (MATERIALS, WEAPONS, CONSUMABLES) at startup
   - Lazy load rare items (QUEST_ITEM, OTHER) on first access
   - Configurable via CommonItemsConfig resource

2. **Indexing:**
   - Name index for fast name searches
   - Tag index for fast tag-based queries
   - Type and category indexes for filtering
   - Indexes updated when items are registered

3. **Caching:**
   - Search results cached (up to 100 queries)
   - Cache invalidated when items are registered
   - O(1) dictionary lookups for item access

4. **Memory Management:**
   - ItemData resources are shared references (not duplicated)
   - Use `create_item_instance()` only when runtime modifications needed
   - Icons preloaded for eager items, world sprites lazy loaded
   - Clear caches if memory becomes an issue

5. **Asset Loading:**
   - Icons preloaded for eager items (needed for UI)
   - World sprites lazy loaded (only when dropped)
   - Consider texture atlases for many small icons (future optimization)

---

## Testing Checklist

### Item Database Functionality
- [ ] All items load correctly from resources directory
- [ ] Item registration works correctly
- [ ] Duplicate item_ids are rejected
- [ ] Item lookup returns correct items
- [ ] Item lookup handles invalid IDs gracefully
- [ ] Items are indexed correctly by type
- [ ] Items are indexed correctly by category
- [ ] CommonItemsConfig loads correctly
- [ ] Default config created if config missing

### Hybrid Loading
- [ ] Eager items load at startup
- [ ] Lazy items load on first access
- [ ] CommonItemsConfig determines eager/lazy correctly
- [ ] Additional eager items override type-based loading
- [ ] Excluded items are not loaded eagerly
- [ ] Lazy loading triggers correctly
- [ ] Icons preload for eager items
- [ ] World sprites lazy load correctly

### Search Indexes and Caching
- [ ] Name index builds correctly
- [ ] Tag index builds correctly
- [ ] Search uses indexes (fast)
- [ ] Search cache stores results
- [ ] Cache invalidates on item registration
- [ ] Cache size limit enforced (100 queries)
- [ ] Indexes update when items registered

### Item Queries
- [ ] Search finds items by name
- [ ] Search finds items by description
- [ ] Search finds items by tags
- [ ] Search uses indexes for performance
- [ ] Search cache improves repeated queries
- [ ] Filter by type works correctly
- [ ] Filter by category works correctly
- [ ] Filter by multiple criteria works correctly
- [ ] Filter uses type index when filtering by type
- [ ] Empty queries return empty arrays
- [ ] get_items_with_tag uses tag index

### Item Instances
- [ ] create_item_instance creates deep copy
- [ ] Instance modifications don't affect original
- [ ] Durability initialized correctly
- [ ] create_item_with_durability sets durability correctly

### Validation
- [ ] Required fields validated strictly (item_id, item_name)
- [ ] Optional fields use defaults (description, icon)
- [ ] Stackable consistency validated
- [ ] Durability initialized correctly
- [ ] Validation errors logged appropriately

### Integration
- [ ] Inventory system can load items
- [ ] Inventory system creates item instances correctly
- [ ] Crafting system can validate items
- [ ] Crafting system queries items by category
- [ ] Combat system can get weapon/armor data
- [ ] Building system can get building piece data
- [ ] Progression system can grant item rewards
- [ ] All systems handle lazy-loaded items correctly

### Performance
- [ ] Eager loading completes quickly (<1 second for 1000 items)
- [ ] Lazy loading is fast (<10ms per item)
- [ ] Item lookup is fast (<0.1ms)
- [ ] Search performance is acceptable (<10ms for 1000 items with indexes)
- [ ] Filter performance is acceptable (<5ms for 1000 items)
- [ ] Memory usage is reasonable
- [ ] Indexes don't use excessive memory

### Edge Cases
- [ ] Handles missing item files gracefully
- [ ] Handles corrupted item files gracefully
- [ ] Handles items with missing required fields
- [ ] Handles items with missing optional fields (uses defaults)
- [ ] Handles runtime item registration
- [ ] Handles item unregistration
- [ ] Handles missing CommonItemsConfig (uses defaults)
- [ ] Handles invalid item types in config
- [ ] Handles lazy loading of non-existent items
- [ ] Handles duplicate item_ids in config

---

## File Structure

### Item Resource Files

**Location:** `res://resources/items/`

**Naming Convention:** `{item_id}.tres` (e.g., `iron_ore.tres`, `steel_sword.tres`)

**Example Item Resource:**
```gdscript
# res://resources/items/iron_ore.tres
[gd_resource type="Resource" script_class="ItemData" load_steps=2 format=3]

[ext_resource type="Texture2D" path="res://assets/sprites/items/icons/iron_ore.png" id="1"]

[resource]
item_id = "iron_ore"
item_name = "Iron Ore"
description = "Raw iron ore that can be smelted into iron ingots."
icon = ExtResource("1")
max_stack_size = 99
is_stackable = true
item_type = 0
item_category = "ore"
base_value = 5
tags = ["metal", "ore", "crafting", "material"]
```

### Asset Organization

```
res://
├── resources/
│   └── items/
│       ├── iron_ore.tres
│       ├── steel_sword.tres
│       └── ...
└── assets/
    └── sprites/
        └── items/
            ├── icons/
            │   ├── iron_ore.png
            │   ├── steel_sword.png
            │   └── ...
            └── world/
                ├── iron_ore.png
                ├── steel_sword.png
                └── ...
```

---

## Implementation Notes

### Initialization Order

**Autoload Order (Project Settings > Autoload):**
1. GameManager (first)
2. InputManager
3. SettingsManager
4. PauseManager
5. ReferenceManager
6. **ItemDatabase** (before systems that use items)
7. Other systems (Inventory, Crafting, etc.)

**Why:** ItemDatabase must be loaded before Inventory, Crafting, Combat, Building, and other systems that depend on it.

**Initialization Flow:**
1. Game starts → Autoload singletons initialize in order
2. ItemDatabase._ready() called
3. load_all_items() scans directory
4. Eager items loaded and registered
5. Icons preloaded for eager items
6. Search indexes built
7. item_database_loaded signal emitted
8. Other systems can now safely access ItemDatabase

**Waiting for Database:**
```gdscript
# In systems that depend on ItemDatabase
func _ready() -> void:
    if ItemDatabase.items.is_empty():
        # Wait for database to load
        ItemDatabase.item_database_loaded.connect(_on_database_loaded)
    else:
        # Database already loaded
        initialize()

func _on_database_loaded() -> void:
    initialize()
```

### Item ID Naming Convention

**Recommended Format:** `{category}_{name}` (e.g., `ore_iron`, `weapon_sword_steel`, `food_bread`)

**Examples:**
- `ore_iron`
- `ingot_steel`
- `weapon_sword_iron`
- `armor_chest_leather`
- `food_bread`
- `tool_pickaxe_iron`
- `building_wall_stone`

### Item Resource Creation Workflow

1. Create ItemData resource in Godot editor
2. Fill in all required fields
3. Set unique `item_id`
4. Assign icon texture
5. Save as `.tres` file in `res://resources/items/`
6. ItemDatabase will automatically load it on next game start

### Editor Support

**Editor-Friendly Design:**
- All item data created as Resource files (.tres) in Godot editor
- Visual resource editor for ItemData (built-in Godot feature)
- CommonItemsConfig resource editable in editor
- No custom editor plugins required

**Visual Item Creation:**
- Items created via "New Resource" → "ItemData" in FileSystem
- All fields editable in Inspector panel
- Icon textures assigned via drag-and-drop in Inspector
- No code editing required for item creation

**Editor Tools Needed:**
- **None Required:** Godot's built-in Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Item browser/manager window
  - Bulk item import/export
  - Item validation warnings in editor
  - Visual item preview

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Items created and edited entirely in Godot editor
- Fully visual workflow (no code for item creation)

---

## Future Enhancements

### Potential Additions

1. **Item Variants:**
   - Support for item variants (e.g., different colored versions)
   - Variant system for procedural items

2. **Item Modifiers:**
   - Runtime item modifiers (enchantments, upgrades)
   - Modifier system integration

3. **Item Sets:**
   - Set bonuses for equipping multiple items from a set
   - Set tracking system

4. **Dynamic Items:**
   - Procedurally generated items
   - Runtime item creation with custom stats

5. **Item Localization:**
   - Multi-language support
   - Localized names and descriptions

---

## Dependencies

### Required Systems
- None (foundational system)

### Systems That Depend on This
- Inventory System
- Crafting System
- Combat System
- Building System
- Progression System
- Quest System (for item rewards)
- Save System (for item instances)

---

## Complete Implementation

### ItemDatabase Complete Implementation

```gdscript
class_name ItemDatabase
extends Node

# Configuration
@export var common_items_config: CommonItemsConfig

# Item Storage
var items: Dictionary = {}
var items_by_type: Dictionary = {}
var items_by_category: Dictionary = {}

# Lazy Loading Tracking
var lazy_loaded_items: Dictionary = {}
var pending_lazy_items: Array[String] = []

# Search Indexes
var name_index: Dictionary = {}
var tag_index: Dictionary = {}
var search_cache: Dictionary = {}

# Asset Paths
const ITEMS_PATH: String = "res://resources/items/"
const ITEM_ICONS_PATH: String = "res://assets/sprites/items/icons/"
const ITEM_WORLD_SPRITES_PATH: String = "res://assets/sprites/items/world/"
const COMMON_ITEMS_CONFIG_PATH: String = "res://resources/config/common_items_config.tres"

# Signals
signal item_registered(item_id: String, item_data: ItemData)
signal item_database_loaded()
signal item_lazy_loaded(item_id: String, item_data: ItemData)

func _ready() -> void:
    load_all_items()

# All functions implemented above in Algorithms section
# (load_config, load_all_items, register_item, get_item, etc.)
```

### Helper Functions

```gdscript
func get_item_safe(item_id: String) -> ItemData:
    var item = get_item(item_id)
    if item == null:
        push_warning("ItemDatabase: Item not found: " + item_id)
    return item

func has_item(item_id: String) -> bool:
    return items.has(item_id) or pending_lazy_items.has(item_id)

func get_all_items() -> Array[ItemData]:
    var all_items: Array[ItemData] = []
    for item_id in items:
        all_items.append(items[item_id])
    return all_items

func get_items_by_type(item_type: ItemData.ItemType) -> Array[ItemData]:
    if items_by_type.has(item_type):
        return items_by_type[item_type].duplicate()
    return []

func get_items_by_category(category: String) -> Array[ItemData]:
    if items_by_category.has(category):
        return items_by_category[category].duplicate()
    return []

func unregister_item(item_id: String) -> bool:
    if not items.has(item_id):
        return false
    
    var item = items[item_id]
    
    # Remove from main dictionary
    items.erase(item_id)
    
    # Remove from type index
    if items_by_type.has(item.item_type):
        items_by_type[item.item_type].erase(item)
    
    # Remove from category index
    if not item.item_category.is_empty() and items_by_category.has(item.item_category):
        items_by_category[item.item_category].erase(item)
    
    # Remove from search indexes
    var name_lower = item.item_name.to_lower()
    if name_index.has(name_lower):
        name_index[name_lower].erase(item)
    
    for tag in item.tags:
        var tag_lower = tag.to_lower()
        if tag_index.has(tag_lower):
            tag_index[tag_lower].erase(item)
    
    # Invalidate cache
    invalidate_search_cache()
    
    return true
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── resources/
   │   ├── items/
   │   │   └── (item resource files)
   │   └── config/
   │       └── common_items_config.tres
   └── assets/
       └── sprites/
           └── items/
               ├── icons/
               │   └── (icon PNG files)
               └── world/
                   └── (world sprite PNG files)
   ```

2. **Create CommonItemsConfig Resource:**
   - Right-click in `res://resources/config/`
   - Select "New Resource"
   - Choose "CommonItemsConfig"
   - Configure eager_load_types, additional_eager_items, etc.
   - Save as `common_items_config.tres`

3. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/ItemDatabase.gd` as `ItemDatabase`
   - **Important:** Load after GameManager, before systems that use items

4. **Create Item Resources:**
   - Right-click in `res://resources/items/`
   - Select "New Resource"
   - Choose "ItemData"
   - Fill in all fields (item_id, item_name, etc.)
   - Save as `{item_id}.tres` (e.g., `iron_ore.tres`)

### Item Resource Creation Workflow

1. **Create ItemData Resource:**
   - Right-click in `res://resources/items/`
   - Select "New Resource" → "ItemData"
   - Fill in required fields:
     - `item_id`: Unique identifier (e.g., "iron_ore")
     - `item_name`: Display name (e.g., "Iron Ore")
   - Fill in optional fields as needed
   - Assign icon texture (or leave null for auto-load)
   - Save as `{item_id}.tres`

2. **Create Icon Asset:**
   - Create icon sprite (16x16 or 32x32 pixels recommended)
   - Save as PNG in `res://assets/sprites/items/icons/`
   - Name: `{item_id}.png`
   - Assign to ItemData resource's `icon` field

3. **Create World Sprite (Optional):**
   - Create world sprite (larger, for dropped items)
   - Save as PNG in `res://assets/sprites/items/world/`
   - Name: `{item_id}.png`
   - Assign to ItemData resource's `world_sprite` field

### Configuration Setup

**CommonItemsConfig Setup:**
1. Create CommonItemsConfig resource in `res://resources/config/`
2. Set `eager_load_types` array:
   - Add ItemData.ItemType.MATERIAL
   - Add ItemData.ItemType.WEAPON
   - Add ItemData.ItemType.CONSUMABLE
3. Optionally add specific items to `additional_eager_items`
4. Optionally exclude items from eager loading in `exclude_from_eager`
5. Save as `common_items_config.tres`

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Item Database system are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Resource System:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
- **DirAccess:** https://docs.godotengine.org/en/stable/classes/class_diraccess.html
- **ResourceLoader:** https://docs.godotengine.org/en/stable/classes/class_resourceloader.html
- **Dictionary:** https://docs.godotengine.org/en/stable/classes/class_dictionary.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Item Database system. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Resource System Documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource class and custom resources
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup
- [DirAccess Documentation](https://docs.godotengine.org/en/stable/classes/class_diraccess.html) - Directory scanning
- [ResourceLoader Documentation](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html) - Resource loading

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Notes

- ItemDatabase is a singleton that should be initialized early in the game lifecycle
- Item resources are shared references - use `create_item_instance()` for runtime modifications (deep copy)
- Item IDs must be unique and follow naming conventions
- All item assets should be organized in the specified directory structure
- Hybrid loading: Common items loaded eagerly, rare items loaded lazily
- Search indexes and caching optimize query performance
- Icons preloaded for eager items, world sprites lazy loaded

