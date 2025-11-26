# Technical Specifications: Crafting System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the deep tech tree crafting system with recipe discovery (found, learned, unlocked). This system integrates with ItemDatabase for item validation and InventoryManager for ingredient consumption and result addition.

---

## Research Notes

### Crafting System Architecture Best Practices

**Research Findings:**
- Resource-based recipe system is standard in Godot (CraftingRecipe extends Resource)
- Recipe registry pattern centralizes recipe management
- Discovery system (found/learned/unlocked) provides progression
- Tech tree integration creates meaningful unlocks
- Signal-based updates keep UI synchronized

**Sources:**
- [Godot 4 Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data structures
- [Godot 4 Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines

**Implementation Approach:**
- Use Resource files (.tres) for CraftingRecipe and TechTreeNode
- RecipeRegistry singleton manages all recipes
- TechTreeManager handles tech tree unlocks
- Discovery types: "found" (world items), "learned" (NPCs), "unlocked" (tech tree)
- Signal emissions for recipe discovery and crafting completion

**Why This Approach:**
- Resource system provides editor support and serialization
- Centralized registry simplifies recipe lookup
- Discovery system creates progression and exploration rewards
- Tech tree integration ties crafting to progression system
- Signals decouple UI from logic

### Recipe Validation and Ingredient Checking

**Research Findings:**
- Ingredient validation should check ItemDatabase for item existence
- Quantity checking should use InventoryManager methods
- Prerequisites should be validated before crafting
- Station requirements should be checked

**Sources:**
- General game development best practices for crafting systems
- [Godot 4 Dictionary Documentation](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) - Dictionary operations

**Implementation Approach:**
- Validate ingredients via ItemDatabase.has_item(item_id)
- Check quantities via InventoryManager (count items across all slots)
- Validate prerequisites recursively
- Check crafting station type matches requirement

**Why This Approach:**
- ItemDatabase ensures items exist before validation
- InventoryManager provides accurate quantity counts
- Prerequisites prevent crafting before progression
- Station checks enforce crafting requirements

### Tech Tree System Best Practices

**Research Findings:**
- Tech tree nodes should unlock recipes, not create them
- Prerequisites create dependency chains
- Research time adds depth to unlocks
- Cost system (resources + skill points) balances progression

**Sources:**
- General tech tree system patterns from strategy games
- [Godot 4 Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based nodes

**Implementation Approach:**
- TechTreeNode unlocks recipes via recipe_id references
- Prerequisites checked recursively
- Research time tracked per node
- Costs deducted from inventory/skill points

**Why This Approach:**
- Recipe unlocking separates tech tree from recipe definitions
- Prerequisites create meaningful progression paths
- Research time adds strategic depth
- Cost system prevents instant unlocks

### Crafting Station System

**Research Findings:**
- Stations should filter available recipes by category
- Station types should have multipliers for crafting speed
- Fuel system adds resource management depth
- Stations should be placeable in world

**Sources:**
- General crafting station patterns from survival games
- [Godot 4 Node2D Documentation](https://docs.godotengine.org/en/stable/classes/class_node2d.html) - 2D node placement

**Implementation Approach:**
- CraftingStation extends Node2D (placeable in world)
- Categories filter recipes by station type
- Fuel system optional per station type
- Note: Crafting is instant (no time/progress required)

**Why This Approach:**
- Node2D allows world placement
- Category filtering organizes recipes
- Fuel system adds resource management
- Instant crafting provides responsive gameplay

---

## Data Structures

### CraftingRecipe

```gdscript
class_name CraftingRecipe
extends Resource

@export var recipe_id: String
@export var recipe_name: String
@export var category: String  # "tools", "weapons", "survival", "building"
@export var description: String

# Ingredients
@export var ingredients: Dictionary = {}  # item_id -> quantity

# Results
@export var results: Dictionary = {}  # item_id -> quantity

# Requirements
@export var required_tools: Array[String] = []  # Tool IDs needed
@export var crafting_station: String = ""  # Station ID or "" for hand-crafting
# Note: Crafting is instant (no time required)

# Discovery
@export var discovery_type: String  # "found", "learned", "unlocked"
@export var is_discovered: bool = false
@export var discovery_source: String = ""  # Where it was found/learned

# Tech Tree
@export var tech_tree_node: String = ""  # Tech node ID
@export var prerequisites: Array[String] = []  # Recipe IDs that must be unlocked first
```

**Note:** TechTreeManager and TechTreeNode are managed by Progression System. Crafting System uses Progression System's TechTreeManager to check if recipes are unlocked. See `technical-specs-progression.md` for Tech Tree details.

### CraftingStation

```gdscript
class_name CraftingStation
extends Node2D

@export var station_id: String
@export var station_name: String
@export var station_type: String  # "workbench", "forge", "chemistry", etc.
@export var available_categories: Array[String] = []
# Note: Crafting is instant, no speed multiplier needed
@export var fuel_required: bool = false
@export var current_fuel: float = 0.0
@export var max_fuel: float = 100.0
```

---

## Core Classes

### CraftingManager (Autoload Singleton)

```gdscript
class_name CraftingManager
extends Node

# References (set via autoload or scene)
var inventory_manager: InventoryManager
var progression_manager: ProgressionManager  # For TechTreeManager access
var recipe_registry: RecipeRegistry

# Current Crafting State (for reference only)
var last_crafted_recipe: CraftingRecipe = null  # Last recipe crafted (for UI feedback)

# Configuration
# Note: Crafting is instant (no progress/time required)

# Signals
signal recipe_discovered(recipe_id: String, discovery_type: String)
signal crafting_completed(recipe_id: String, quantity: int)
signal recipe_availability_changed(recipe_id: String, available: bool)

# Initialization
func _ready() -> void
func initialize() -> void

# Recipe Discovery
func discover_recipe(recipe_id: String, discovery_type: String, source: String = "") -> bool
func is_recipe_discovered(recipe_id: String) -> bool
func get_discovered_recipes() -> Array[CraftingRecipe]

# Recipe Queries
func get_available_recipes() -> Array[CraftingRecipe]  # Discovered + can craft
func get_craftable_recipes() -> Array[CraftingRecipe]  # Can craft right now
func get_recipes_by_category(category: String) -> Array[CraftingRecipe]
func get_recipes_by_station(station_type: String) -> Array[CraftingRecipe]
func search_recipes(query: String) -> Array[CraftingRecipe]

# Crafting Operations
func can_craft_recipe(recipe_id: String) -> bool
func can_craft_recipe_by_data(recipe: CraftingRecipe) -> bool
func craft_recipe(recipe_id: String, quantity: int = 1, station: CraftingStation = null) -> bool
func craft_recipe_by_data(recipe: CraftingRecipe, quantity: int = 1, station: CraftingStation = null) -> bool
```

### RecipeRegistry (Autoload Singleton)

```gdscript
class_name RecipeRegistry
extends Node

# Recipe Storage
var recipes: Dictionary = {}  # recipe_id -> CraftingRecipe
var recipes_by_category: Dictionary = {}  # category -> Array[CraftingRecipe]
var recipes_by_station: Dictionary = {}  # station_type -> Array[CraftingRecipe]

# Asset Paths
const RECIPES_PATH: String = "res://resources/recipes/"
const TECH_TREE_PATH: String = "res://resources/tech_tree/"

# Signals
signal recipe_registered(recipe_id: String, recipe: CraftingRecipe)

# Initialization
func _ready() -> void
func load_all_recipes() -> void

# Recipe Management
func register_recipe(recipe: CraftingRecipe) -> bool
func get_recipe(recipe_id: String) -> CraftingRecipe
func get_recipe_safe(recipe_id: String) -> CraftingRecipe  # Returns null if not found
func has_recipe(recipe_id: String) -> bool
func get_all_recipes() -> Array[CraftingRecipe]

# Recipe Queries
func get_recipes_by_category(category: String) -> Array[CraftingRecipe]
func get_recipes_by_station(station_type: String) -> Array[CraftingRecipe]
func search_recipes(query: String) -> Array[CraftingRecipe]  # Search by name, description
func filter_recipes(filters: Dictionary) -> Array[CraftingRecipe]  # Advanced filtering

# Validation
func validate_recipe(recipe: CraftingRecipe) -> bool  # Check ingredients/results exist in ItemDatabase
```

**Note:** TechTreeManager is managed by Progression System. Crafting System accesses it via `ProgressionManager.tech_tree_manager` or directly via autoload singleton `TechTreeManager` (if exposed as autoload). See `technical-specs-progression.md` for Tech Tree implementation details.

---

## System Architecture

### Component Hierarchy

```
CraftingManager (Node)
├── RecipeRegistry (Resource)
│   └── CraftingRecipe[] (Dictionary)
├── CraftingStation[] (Node2D)
└── UI/CraftingUI (Control)
    ├── RecipeList (ItemList)
    ├── IngredientDisplay (VBoxContainer)
    └── TechTreeView (Control)  # Uses Progression System's TechTreeManager
```

### Data Flow

1. **Recipe Discovery:**
   ```
   Player finds/learns recipe
   ├── CraftingManager.discover_recipe(recipe_id, type, source)
   ├── RecipeRegistry.get_recipe(recipe_id).is_discovered = true
   ├── Update UI to show new recipe
   └── Save discovery to player data
   ```

2. **Crafting Process (Instant):**
   ```
   Player crafts item
   ├── CraftingManager.craft_recipe(recipe_id, quantity, station)
   ├── Check can_craft_recipe()
   │   ├── Check ingredients available
   │   ├── Check tech tree unlock (via ProgressionManager.tech_tree_manager)
   │   └── Check station requirements
   ├── Remove ingredients from inventory
   ├── Add results to inventory (instant)
   └── Update UI
   ```

---

## Algorithms

### Recipe Availability Check (Using ItemDatabase and InventoryManager)

```gdscript
func can_craft_recipe(recipe_id: String) -> bool:
    var recipe = RecipeRegistry.get_recipe(recipe_id)
    if recipe == null:
        return false
    return can_craft_recipe_by_data(recipe)

func can_craft_recipe_by_data(recipe: CraftingRecipe) -> bool:
    if recipe == null:
        return false
    
    # Check if discovered
    if not recipe.is_discovered:
        return false
    
    # Check prerequisites (recipe prerequisites)
    for prereq_id in recipe.prerequisites:
        var prereq = RecipeRegistry.get_recipe(prereq_id)
        if prereq == null or not prereq.is_discovered:
            return false
    
    # Check ingredients (validate items exist and check quantities)
    for item_id in recipe.ingredients:
        # Validate item exists in ItemDatabase
        if not ItemDatabase.has_item(item_id):
            push_warning("CraftingManager: Recipe ingredient not found in ItemDatabase: " + item_id)
            return false
        
        var required: int = recipe.ingredients[item_id]
        if required <= 0:
            continue
        
        # Check quantity in inventory
        if not has_item_quantity(item_id, required):
            return false
    
    # Check tech tree unlock (via Progression System)
    if not recipe.tech_tree_node.is_empty():
        if progression_manager and progression_manager.tech_tree_manager:
            if not progression_manager.tech_tree_manager.is_node_researched(recipe.tech_tree_node):
                return false
        else:
            # Fallback: try direct autoload access
            var tech_tree_manager = get_node_or_null("/root/TechTreeManager")
            if tech_tree_manager and not tech_tree_manager.is_node_researched(recipe.tech_tree_node):
                return false
    
    # Check crafting station requirement
    if not recipe.crafting_station.is_empty():
        if current_station == null or current_station.station_type != recipe.crafting_station:
            return false
    
    return true

func has_item_quantity(item_id: String, quantity: int) -> bool:
    # Count items across all inventory slots
    var total_quantity: int = 0
    
    # Check inventory slots
    for slot in InventoryManager.inventory_slots:
        if not slot.is_empty and slot.item_data.item_id == item_id:
            total_quantity += slot.quantity
            if total_quantity >= quantity:
                return true
    
    # Check hotbar slots
    for slot in InventoryManager.hotbar_slots:
        if not slot.is_empty and slot.item_data.item_id == item_id:
            total_quantity += slot.quantity
            if total_quantity >= quantity:
                return true
    
    return false
```

**Note:** Tech Tree unlock/research algorithms are handled by Progression System's TechTreeManager. When a tech node is researched, it automatically unlocks associated recipes via signals. Crafting System listens for these signals to discover new recipes.

---

## Integration Points

### Crafting Process Algorithm (Instant - Using ItemDatabase and InventoryManager)

```gdscript
func craft_recipe(recipe_id: String, quantity: int = 1, station: CraftingStation = null) -> bool:
    var recipe = RecipeRegistry.get_recipe(recipe_id)
    if recipe == null:
        push_error("CraftingManager: Recipe not found: " + recipe_id)
        return false
    
    return craft_recipe_by_data(recipe, quantity, station)

func craft_recipe_by_data(recipe: CraftingRecipe, quantity: int = 1, station: CraftingStation = null) -> bool:
    if recipe == null or quantity <= 0:
        return false
    
    # Check if can craft (check ingredients for total quantity needed)
    # Verify we have enough ingredients for all quantities
    for item_id in recipe.ingredients:
        var required_per_craft: int = recipe.ingredients[item_id]
        var total_required: int = required_per_craft * quantity
        
        # Check if we have enough total quantity
        if not has_item_quantity(item_id, total_required):
            return false
    
    # Check tech tree unlock (only need to check once)
    if not recipe.tech_tree_node.is_empty():
        if progression_manager and progression_manager.tech_tree_manager:
            if not progression_manager.tech_tree_manager.is_node_researched(recipe.tech_tree_node):
                return false
        else:
            var tech_tree_manager = get_node_or_null("/root/TechTreeManager")
            if tech_tree_manager and not tech_tree_manager.is_node_researched(recipe.tech_tree_node):
                return false
    
    # Check station requirement
    if not recipe.crafting_station.is_empty():
        if station == null or station.station_type != recipe.crafting_station:
            return false
    
    # Remove ingredients from inventory (multiply by quantity)
    for item_id in recipe.ingredients:
        var required: int = recipe.ingredients[item_id] * quantity
        var removed = InventoryManager.remove_item(item_id, required)
        if removed < required:
            push_error("CraftingManager: Could not remove all ingredients for recipe: " + recipe.recipe_id)
            # Refund any removed ingredients
            for refund_item_id in recipe.ingredients:
                if refund_item_id == item_id:
                    continue
                var refund_quantity = recipe.ingredients[refund_item_id] * quantity
                var refunded = InventoryManager.remove_item(refund_item_id, refund_quantity)
                if refunded > 0:
                    # Add back refunded items
                    for i in range(refunded):
                        var refund_instance = ItemDatabase.create_item_instance(refund_item_id)
                        InventoryManager.add_item(refund_instance)
            return false
    
    # Add results to inventory (multiply by quantity)
    for item_id in recipe.results:
        var result_quantity: int = recipe.results[item_id] * quantity
        var item_data = ItemDatabase.get_item(item_id)
        if item_data:
            for i in range(result_quantity):
                var instance = ItemDatabase.create_item_instance(item_id)
                var added = InventoryManager.add_item(instance)
                if not added:
                    # If inventory full, drop item in world
                    push_warning("CraftingManager: Inventory full, dropping item: " + item_id)
                    drop_item_in_world(item_id, get_player_position())
    
    # Update last crafted reference
    last_crafted_recipe = recipe
    
    # Emit signal
    crafting_completed.emit(recipe.recipe_id, quantity)
    return true

# Helper Functions

func drop_item_in_world(item_id: String, position: Vector2) -> void:
    # Drop item in world at position (creates pickupable item entity)
    var item_data = ItemDatabase.get_item(item_id)
    if not item_data:
        push_error("CraftingManager: Cannot drop item, not found: " + item_id)
        return
    
    # Create item pickup entity (would integrate with item pickup system)
    # This is a placeholder - actual implementation depends on item pickup system
    var item_instance = ItemDatabase.create_item_instance(item_id)
    # TODO: Spawn item pickup entity at position
    push_print("CraftingManager: Dropped item " + item_id + " at " + str(position))

func get_player_position() -> Vector2:
    # Get player position for dropping items
    var player = get_tree().get_first_node_in_group("player")
    if player:
        return player.global_position
    return Vector2.ZERO
```

---

## Save/Load System

### Save Data

```gdscript
var crafting_save_data: Dictionary = {
    "discovered_recipes": get_discovered_recipe_ids()
    # Note: Tech tree data saved by Progression System
    # Note: Crafting is instant, no progress to save
}
```

---

## Error Handling

### CraftingManager Error Handling

- **Invalid Recipe IDs:** Check RecipeRegistry before operations, return errors gracefully
- **Missing Ingredients:** Validate all ingredients exist in ItemDatabase before crafting
- **Inventory Full:** Handle remaining items when adding results (drop or notify)
- **Invalid Station:** Check station type matches recipe requirement
- **Already Crafting:** Prevent starting new craft while one is in progress
- **Tech Tree Validation:** Check node exists before unlock/research operations

### Best Practices

- Use `push_error()` for critical errors (invalid recipe_id, missing ingredients)
- Use `push_warning()` for non-critical issues (inventory full, can't craft)
- Return false/null on errors (don't crash)
- Validate all inputs before operations
- Refund ingredients if crafting fails partway through

---

## Default Values and Configuration

### CraftingManager Defaults

```gdscript
# Queue limits
MAX_CRAFTING_QUEUE_SIZE = 10

# Default crafting time (if not specified in recipe)
# DEFAULT_CRAFTING_TIME removed - crafting is instant
```

### CraftingRecipe Defaults

```gdscript
# Discovery
discovery_type = "found"
is_discovered = false
discovery_source = ""

# Requirements
crafting_station = ""  # Empty = hand-crafting
# crafting_time removed - crafting is instant
required_tools = []

# Tech Tree
tech_tree_node = ""
prerequisites = []

# Ingredients/Results
ingredients = {}
results = {}
```

**Note:** TechTreeNode defaults are defined in Progression System specification.

### CraftingStation Defaults

```gdscript
# crafting_speed_multiplier removed - crafting is instant
fuel_required = false
current_fuel = 0.0
max_fuel = 100.0
available_categories = []
```

---

## Performance Considerations

### Optimization Strategies

1. **Recipe Registry:**
   - Load all recipes at startup (eager loading)
   - Cache discovered recipes list
   - Index recipes by category/station for fast queries

2. **Ingredient Checking:**
   - Cache ingredient availability checks
   - Limit checks per frame for UI updates
   - Use ItemDatabase for fast item lookups

3. **Tech Tree:**
   - Tech Tree managed by Progression System
   - Cache recipe availability checks (tech tree + ingredients)

---

## Testing Checklist

### Recipe System
- [ ] Recipes register correctly in RecipeRegistry
- [ ] Recipe discovery works (found, learned, unlocked)
- [ ] Recipe queries work (by category, station, search)
- [ ] Invalid recipe IDs handled gracefully
- [ ] Recipe validation checks ItemDatabase

### Ingredient System
- [ ] Ingredient checking validates ItemDatabase
- [ ] Quantity checking counts across inventory + hotbar
- [ ] Missing ingredients prevent crafting
- [ ] Partial ingredients handled correctly

### Crafting Process
- [ ] Crafting completes instantly
- [ ] Ingredients removed from inventory (correct quantities)
- [ ] Results added to inventory (correct quantities)
- [ ] Multiple quantity crafting works correctly
- [ ] Inventory full handling (drop remaining items)
- [ ] Station requirements checked correctly

### Tech Tree Integration
- [ ] Tech tree unlock check works (via Progression System)
- [ ] Recipe availability checks tech tree correctly
- [ ] Tech tree research completion unlocks recipes (via signals)
- [ ] Crafting System receives tech tree unlock signals

### Crafting Stations
- [ ] Stations filter recipes by category
- [ ] Station speed multiplier affects crafting time
- [ ] Fuel system works (if enabled)
- [ ] Station requirements enforced

### Integration
- [ ] Integrates with ItemDatabase correctly
- [ ] Integrates with InventoryManager correctly
- [ ] Integrates with TechTreeManager correctly
- [ ] Integrates with ProgressionManager (skill points)

### Save/Load
- [ ] Discovered recipes save/load correctly
- [ ] Tech tree state saves/loads correctly
- [ ] Current crafting state saves/loads correctly
- [ ] Research progress saves/loads correctly

### Edge Cases
- [ ] Invalid recipe IDs handled
- [ ] Missing ingredients handled
- [ ] Inventory full during result addition
- [ ] Already crafting prevents new craft
- [ ] Invalid station type rejected
- [ ] Tech tree node not found handled

---

## Complete Implementation

### RecipeRegistry Complete Implementation

```gdscript
class_name RecipeRegistry
extends Node

var recipes: Dictionary = {}
var recipes_by_category: Dictionary = {}
var recipes_by_station: Dictionary = {}

const RECIPES_PATH: String = "res://resources/recipes/"

signal recipe_registered(recipe_id: String, recipe: CraftingRecipe)

func _ready() -> void:
    load_all_recipes()

func load_all_recipes() -> void:
    var dir = DirAccess.open(RECIPES_PATH)
    if dir == null:
        push_error("RecipeRegistry: Cannot open recipes directory: " + RECIPES_PATH)
        return
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        if file_name.ends_with(".tres"):
            var recipe_path = RECIPES_PATH + file_name
            var recipe = load(recipe_path) as CraftingRecipe
            
            if recipe == null:
                push_warning("RecipeRegistry: Failed to load recipe: " + recipe_path)
            elif not validate_recipe(recipe):
                push_warning("RecipeRegistry: Recipe validation failed: " + recipe_path)
            else:
                register_recipe(recipe)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    print("RecipeRegistry: Loaded ", recipes.size(), " recipes")

func register_recipe(recipe: CraftingRecipe) -> bool:
    if recipe == null or recipe.recipe_id.is_empty():
        return false
    
    if recipes.has(recipe.recipe_id):
        push_warning("RecipeRegistry: Duplicate recipe_id: " + recipe.recipe_id)
        return false
    
    recipes[recipe.recipe_id] = recipe
    
    # Index by category
    if not recipes_by_category.has(recipe.category):
        recipes_by_category[recipe.category] = []
    recipes_by_category[recipe.category].append(recipe)
    
    # Index by station
    var station_type = recipe.crafting_station if not recipe.crafting_station.is_empty() else "hand"
    if not recipes_by_station.has(station_type):
        recipes_by_station[station_type] = []
    recipes_by_station[station_type].append(recipe)
    
    recipe_registered.emit(recipe.recipe_id, recipe)
    return true

func validate_recipe(recipe: CraftingRecipe) -> bool:
    # Validate all ingredients exist in ItemDatabase
    for item_id in recipe.ingredients:
        if not ItemDatabase.has_item(item_id):
            push_error("RecipeRegistry: Ingredient not found: " + item_id)
            return false
    
    # Validate all results exist in ItemDatabase
    for item_id in recipe.results:
        if not ItemDatabase.has_item(item_id):
            push_error("RecipeRegistry: Result item not found: " + item_id)
            return false
    
    return true
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── resources/
   │   ├── recipes/
   │   │   └── (recipe resource files)
   │   └── tech_tree/
   │       └── (tech tree node resource files)
   └── scripts/
       └── managers/
           ├── CraftingManager.gd
           ├── RecipeRegistry.gd
           └── TechTreeManager.gd
   ```

2. **Setup Autoload Singletons:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/RecipeRegistry.gd` as `RecipeRegistry`
   - Add `scripts/managers/TechTreeManager.gd` as `TechTreeManager`
   - Add `scripts/managers/CraftingManager.gd` as `CraftingManager`
   - **Important:** Load after ItemDatabase and InventoryManager

3. **Create Recipe Resources:**
   - Right-click in `res://resources/recipes/`
   - Select "New Resource" → "CraftingRecipe"
   - Fill in recipe_id, recipe_name, ingredients, results, etc.
   - Save as `{recipe_id}.tres`

4. **Create Tech Tree Node Resources:**
   - Right-click in `res://resources/tech_tree/`
   - Select "New Resource" → "TechTreeNode"
   - Fill in node_id, node_name, cost, unlocks_recipes, etc.
   - Save as `{node_id}.tres`

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. InventoryManager
4. ProgressionManager (for skill points)
5. **RecipeRegistry** (before CraftingManager)
6. **TechTreeManager** (before CraftingManager)
7. **CraftingManager** (after all dependencies)

### Recipe Creation Workflow

1. **Create CraftingRecipe Resource:**
   - Right-click in `res://resources/recipes/`
   - Select "New Resource" → "CraftingRecipe"
   - Fill in required fields:
     - `recipe_id`: Unique identifier
     - `recipe_name`: Display name
     - `category`: Recipe category
     - `ingredients`: Dictionary {item_id: quantity}
     - `results`: Dictionary {item_id: quantity}
   - Configure optional fields (crafting_station, crafting_time, etc.)
   - Save as `{recipe_id}.tres`

2. **Validate Recipe:**
   - Ensure all ingredient item_ids exist in ItemDatabase
   - Ensure all result item_ids exist in ItemDatabase
   - RecipeRegistry will validate on load

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Crafting System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Resource System:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
- **DirAccess:** https://docs.godotengine.org/en/stable/classes/class_diraccess.html
- **Dictionary:** https://docs.godotengine.org/en/stable/classes/class_dictionary.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Crafting System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data structures
- [Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup
- [DirAccess Documentation](https://docs.godotengine.org/en/stable/classes/class_diraccess.html) - Directory scanning
- [Dictionary Documentation](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) - Dictionary operations

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- CraftingRecipe and TechTreeNode are Resource classes (editable in inspector)
- CraftingStation extends Node2D (placeable in scene)
- All managers are Node-based (can be added to scene tree)
- Recipe and tech tree data created as resources in editor

**Visual Configuration:**
- Recipe resources created in FileSystem, edited in Inspector
- Tech tree node resources created in FileSystem, edited in Inspector
- CraftingStation nodes placed visually in scene

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Visual recipe editor with ingredient/result pickers
  - Tech tree visual editor (node graph)
  - Recipe browser/manager window
  - Recipe validation tool

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Recipes and tech tree nodes created as resources
- Stations placed in scene visually
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Item Database Integration:** Uses `ItemDatabase.has_item(item_id)` and `ItemDatabase.get_item(item_id)` for all item validation
2. **Inventory Integration:** Uses `InventoryManager.add_item()` and `InventoryManager.remove_item()` for ingredient consumption and result addition
3. **Progression Integration:** Uses `ProgressionManager` for skill point checking and spending
4. **Recipe Discovery:** Discovery types: "found" (world items), "learned" (NPCs), "unlocked" (tech tree)
5. **Tech Tree:** Tech tree nodes unlock recipes, recipes are separate resources
6. **Crafting Stations:** Stations filter recipes by category and affect crafting speed
7. **Queue System:** Crafting queue allows batch crafting (limited size)
8. **Research System:** Tech tree nodes can be researched (takes time) before unlocking recipes
9. **Validation:** All recipes validated on load (ingredients/results must exist in ItemDatabase)
10. **Signals:** Signal-based updates keep UI synchronized with crafting state

---

