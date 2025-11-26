# Technical Specifications: Building System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the building system with grid/freeform toggle, complex structure design, and future automation support. This system integrates with ItemDatabase for building piece data and InventoryManager for material consumption.

---

## Research Notes

### Building System Architecture Best Practices

**Research Findings:**
- Grid-based placement is standard for building systems
- Freeform placement provides flexibility for advanced builders
- Preview system improves UX (show placement before confirming)
- Collision detection via PhysicsShapeQueryParameters2D is efficient
- Building pieces should be stored as resources for editor support
- Material consumption should validate before placement

**Sources:**
- [Godot 4 PhysicsShapeQueryParameters2D](https://docs.godotengine.org/en/stable/classes/class_physicsshapequeryparameters2d.html) - Collision detection
- [Godot 4 Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data structures
- [Godot 4 Node2D Documentation](https://docs.godotengine.org/en/stable/classes/class_node2d.html) - 2D node placement
- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines

**Implementation Approach:**
- BuildingPiece as Resource for editor support
- Grid snapping via world_to_grid/grid_to_world conversion
- Freeform placement allows precise positioning
- Preview node shows placement before confirmation
- Collision detection via PhysicsShapeQueryParameters2D
- Material validation before placement

**Why This Approach:**
- Resource system provides editor support
- Grid snapping standard for building games
- Freeform option provides flexibility
- Preview improves user experience
- Physics queries efficient for collision detection

### Building Piece Integration

**Research Findings:**
- Building pieces should be stored as ItemData in ItemDatabase
- Building piece data stored in ItemData.metadata
- Material requirements stored in ItemData.metadata
- Building pieces can be placed from inventory or building palette

**Sources:**
- ItemDatabase specification (already completed)
- InventoryManager specification (already completed)

**Implementation Approach:**
- Get building piece data from ItemDatabase.get_item(piece_id)
- Read building-specific data from ItemData.metadata
- Check ItemData.building_piece flag
- Material requirements from ItemData.metadata["materials"]
- Consume materials via InventoryManager.remove_item()

**Why This Approach:**
- Single source of truth (ItemDatabase)
- Consistent with inventory system
- Easy to add/modify building pieces via resources
- Material consumption integrated with inventory

### Grid vs Freeform Placement

**Research Findings:**
- Grid mode improves alignment and structure
- Freeform mode allows creative building
- Toggle between modes provides flexibility
- Grid size should be configurable (typically 16px for pixel art)

**Sources:**
- General building system patterns from survival games
- Pixel art grid alignment best practices

**Implementation Approach:**
- Grid mode: snap to grid_size (16px default)
- Freeform mode: precise placement (no snapping)
- Toggle via UI or keybind
- Preview shows placement in both modes

**Why This Approach:**
- Grid mode standard for building games
- Freeform provides advanced options
- Toggle gives players choice
- Configurable grid size supports different art styles

### Structural Integrity System

**Research Findings:**
- Structural integrity adds realism but is optional
- Foundation checking prevents floating structures
- Connection checking ensures stability
- Support checking prevents unsupported pieces

**Sources:**
- General building system patterns
- Physics-based building systems

**Implementation Approach:**
- Optional structural integrity calculation
- Foundation pieces required for structures
- Connection points for piece attachment
- Support checking for vertical structures

**Why This Approach:**
- Adds depth without complexity
- Optional allows simpler building
- Foundation system prevents exploits
- Support system adds realism

---

## Data Structures

**Note:** Building pieces are stored in ItemDatabase as ItemData with ItemType.BUILDING and building_piece=true. Building-specific data is stored in ItemData.metadata. This system uses ItemDatabase.get_item(piece_id) to retrieve building piece data.

### BuildingPieceData (Helper Class)

```gdscript
class_name BuildingPieceData
extends RefCounted

# Reference to ItemData from ItemDatabase
var item_data: ItemData
var piece_id: String
var piece_name: String
var category: String
var size: Vector2i
var sprite: Texture2D
var collision_shape: Shape2D
var health: float
var max_health: float
var can_connect: bool
var connection_points: Array[Vector2]
var placement_rules: Dictionary
var materials: Dictionary  # material_id -> quantity

# Create from ItemData
static func from_item_data(item_data: ItemData) -> BuildingPieceData:
    var piece = BuildingPieceData.new()
    piece.item_data = item_data
    piece.piece_id = item_data.item_id
    piece.piece_name = item_data.item_name
    
    # Extract building data from metadata
    if item_data.metadata.has("category"):
        piece.category = item_data.metadata["category"]
    if item_data.metadata.has("size"):
        piece.size = item_data.metadata["size"] as Vector2i
    if item_data.metadata.has("sprite_path"):
        piece.sprite = load(item_data.metadata["sprite_path"]) as Texture2D
    if item_data.metadata.has("collision_shape_path"):
        piece.collision_shape = load(item_data.metadata["collision_shape_path"]) as Shape2D
    if item_data.metadata.has("health"):
        piece.health = item_data.metadata["health"]
        piece.max_health = piece.health
    if item_data.metadata.has("can_connect"):
        piece.can_connect = item_data.metadata["can_connect"]
    if item_data.metadata.has("connection_points"):
        piece.connection_points = item_data.metadata["connection_points"] as Array[Vector2]
    if item_data.metadata.has("placement_rules"):
        piece.placement_rules = item_data.metadata["placement_rules"] as Dictionary
    if item_data.metadata.has("materials"):
        piece.materials = item_data.metadata["materials"] as Dictionary
    
    return piece
```

### PlacedBuilding

```gdscript
class_name PlacedBuilding
extends Node2D

@export var piece: BuildingPiece
@export var grid_position: Vector2i
@export var world_position: Vector2
@export var rotation: float = 0.0
@export var is_grid_mode: bool = true
@export var health: float
@export var owner_id: String = ""  # For multiplayer
```

### BuildingStructure

```gdscript
class_name BuildingStructure
extends RefCounted

var pieces: Array[PlacedBuilding] = []
var structure_id: String
var bounds: Rect2i  # Bounding box in grid coordinates
var is_complete: bool = false
var structural_integrity: float = 100.0  # Optional
```

---

## Core Classes

### BuildingManager (Autoload Singleton)

```gdscript
class_name BuildingManager
extends Node

# Mode Configuration
@export var grid_mode: bool = true
@export var grid_size: float = 16.0  # Pixels per grid cell
@export var return_materials_on_removal: bool = true  # Return materials when removing

# References
var inventory_manager: InventoryManager
var pixel_physics_manager: PixelPhysicsManager  # Optional, for pixel physics integration

# Building Data
var placed_buildings: Dictionary = {}  # Vector2i (grid) or Vector2 (freeform) -> PlacedBuilding
var building_structures: Array[BuildingStructure] = []  # Grouped buildings

# Current Building State
var selected_piece_id: String = ""
var selected_piece_data: BuildingPieceData = null
var preview_building: Node2D = null
var is_building: bool = false

# Building Validator
var validator: BuildingValidator

# Configuration
const DEFAULT_GRID_SIZE: float = 16.0
const MAX_BUILDING_DISTANCE: float = 200.0  # Max distance for placement

# Signals
signal building_placed(piece_id: String, position: Vector2)
signal building_removed(piece_id: String, position: Vector2)
signal building_mode_changed(is_building: bool)
signal grid_mode_toggled(enabled: bool)
signal placement_validated(can_place: bool, reason: String)

# Initialization
func _ready() -> void
func initialize() -> void

# Building Mode
func toggle_building_mode() -> void
func enter_building_mode() -> void
func exit_building_mode() -> void

# Piece Selection
func select_building_piece(piece_id: String) -> bool
func deselect_piece() -> void
func get_available_pieces() -> Array[String]  # Returns piece IDs from ItemDatabase

# Placement
func place_building(world_pos: Vector2) -> bool
func remove_building(world_pos: Vector2) -> bool
func can_place_at(world_pos: Vector2, piece_id: String) -> bool
func get_building_at(world_pos: Vector2) -> PlacedBuilding

# Grid System
func toggle_grid_mode() -> void
func world_to_grid(world_pos: Vector2) -> Vector2i
func grid_to_world(grid_pos: Vector2i) -> Vector2
func snap_to_grid(world_pos: Vector2) -> Vector2

# Preview System
func update_preview(world_pos: Vector2) -> void
func show_preview() -> void
func hide_preview() -> void

# Validation
func validate_placement(world_pos: Vector2, piece_id: String) -> Dictionary

# Structure Management
func create_structure(pieces: Array[PlacedBuilding]) -> BuildingStructure
func calculate_structural_integrity(structure: BuildingStructure) -> float  # Optional

# Material Management
func refund_building_materials(piece_data: BuildingPieceData) -> void
```

### BuildingValidator

```gdscript
class_name BuildingValidator
extends RefCounted

var building_manager: BuildingManager

func validate_placement(world_pos: Vector2, piece_id: String, grid_mode: bool) -> Dictionary:
    var result: Dictionary = {
        "can_place": false,
        "reason": "",
        "snapped_position": world_pos
    }
    
    # Get building piece data
    var piece_data = building_manager.get_building_piece_data(piece_id)
    if piece_data == null:
        result.reason = "Invalid building piece"
        return result
    
    # Grid snapping
    if grid_mode:
        result.snapped_position = building_manager.snap_to_grid(world_pos)
    else:
        result.snapped_position = world_pos
    
    # Check collision
    if check_collision(result.snapped_position, piece_data):
        result.reason = "Collision detected"
        return result
    
    # Check support (if needed)
    if piece_data.placement_rules.has("needs_support"):
        if not check_support(result.snapped_position, piece_data):
            result.reason = "No support"
            return result
    
    # Check materials (delegated to BuildingManager)
    if not building_manager.check_materials(piece_data):
        result.reason = "Insufficient materials"
        return result
    
    # Check distance (if max distance enabled)
    if building_manager.MAX_BUILDING_DISTANCE > 0.0:
        var player_pos = building_manager.player.global_position if building_manager.player else Vector2.ZERO
        var distance = result.snapped_position.distance_to(player_pos)
        if distance > building_manager.MAX_BUILDING_DISTANCE:
            result.reason = "Too far away"
            return result
    
    result.can_place = true
    return result

func check_collision(pos: Vector2, piece_data: BuildingPieceData) -> bool:
    if piece_data.collision_shape == null:
        return false  # No collision shape, can place
    
    # Check if position is clear
    var space_state: PhysicsDirectSpaceState2D = building_manager.get_world_2d().direct_space_state
    var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
    query.shape = piece_data.collision_shape
    query.transform.origin = pos
    query.collision_mask = 0b1  # Building collision layer
    var results: Array = space_state.intersect_shape(query)
    return results.size() > 0

func check_support(pos: Vector2, piece_data: BuildingPieceData) -> bool:
    # Check if there's a foundation or support piece below
    var support_pos = pos + Vector2(0, building_manager.grid_size)
    var building_below = building_manager.get_building_at(support_pos)
    return building_below != null
```

---

## System Architecture

### Component Hierarchy

```
BuildingManager (Node)
├── BuildingPieceRegistry (Resource)
│   └── BuildingPiece[] (Dictionary)
├── BuildingValidator
├── PreviewRenderer (Node2D)
└── UI/BuildingUI (Control)
    ├── PieceSelector (ItemList)
    ├── GridToggle (CheckBox)
    └── MaterialDisplay (Label)
```

### Data Flow

1. **Placement:**
   ```
   Player places building
   ├── BuildingManager.place_building(world_pos)
   ├── BuildingValidator.validate_placement()
   ├── Check materials in inventory
   ├── Remove materials
   ├── Create PlacedBuilding node
   ├── Add to placed_buildings dictionary
   └── Update pixel physics grid
   ```

2. **Removal:**
   ```
   Player removes building
   ├── BuildingManager.remove_building(world_pos)
   ├── Get PlacedBuilding at position
   ├── Return materials to inventory (optional)
   ├── Remove from placed_buildings
   ├── Remove node from scene
   └── Update pixel physics grid
   ```

---

## Algorithms

### Grid Snapping

```gdscript
func world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(world_pos.x / grid_size),
        int(world_pos.y / grid_size)
    )

func grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(
        grid_pos.x * grid_size + grid_size / 2.0,
        grid_pos.y * grid_size + grid_size / 2.0
    )
```

### Freeform Placement

```gdscript
func place_freeform(world_pos: Vector2, piece: BuildingPiece) -> bool:
    # No snapping, precise placement
    var validation: Dictionary = validate_placement(world_pos, piece, false)
    if not validation.can_place:
        return false
    
    var placed: PlacedBuilding = create_building_piece(piece, world_pos, false)
    placed_buildings[world_pos] = placed
    add_child(placed)
    return true
```

### Structure Integrity (Optional)

```gdscript
func calculate_structural_integrity(structure: BuildingStructure) -> float:
    var integrity: float = 100.0
    
    # Check foundation
    var foundation_pieces: int = count_foundation_pieces(structure)
    if foundation_pieces == 0:
        integrity -= 50.0
    
    # Check connections
    var disconnected_pieces: int = count_disconnected_pieces(structure)
    integrity -= disconnected_pieces * 10.0
    
    # Check support
    var unsupported_pieces: int = count_unsupported_pieces(structure)
    integrity -= unsupported_pieces * 5.0
    
    return clamp(integrity, 0.0, 100.0)
```

---

## Integration Points

### With Pixel Physics

```gdscript
func place_building(world_pos: Vector2) -> bool:
    # ... validation ...
    
    # Update pixel physics grid
    var grid_pos: Vector2i = world_to_grid(world_pos)
    var material: PixelMaterial = pixel_physics_manager.material_registry.get_material(piece.material_id)
    pixel_physics_manager.add_material(world_pos, material)
    
    return true
```

### Placement Algorithm (Using ItemDatabase and InventoryManager)

```gdscript
func place_building(world_pos: Vector2) -> bool:
    if selected_piece_id.is_empty():
        return false
    
    # Get building piece data
    var piece_data = get_building_piece_data(selected_piece_id)
    if piece_data == null:
        push_error("BuildingManager: Invalid piece_id: " + selected_piece_id)
        return false
    
    # Validate placement
    var validation = validate_placement(world_pos, selected_piece_id)
    if not validation.can_place:
        push_warning("BuildingManager: Cannot place building: " + validation.reason)
        placement_validated.emit(false, validation.reason)
        return false
    
    # Check materials
    if not check_materials(piece_data):
        push_warning("BuildingManager: Insufficient materials")
        placement_validated.emit(false, "Insufficient materials")
        return false
    
    # Consume materials
    if not consume_materials(piece_data):
        push_error("BuildingManager: Failed to consume materials")
        return false
    
    # Snap position if grid mode
    var final_position = world_pos
    if grid_mode:
        final_position = snap_to_grid(world_pos)
    
    # Create placed building
    var placed = create_placed_building(piece_data, final_position)
    if placed == null:
        push_error("BuildingManager: Failed to create building")
        # Refund materials to inventory
        refund_building_materials(piece_data)
        return false
    
    # Add to dictionary
    var key = Vector2i(world_to_grid(final_position)) if grid_mode else final_position
    placed_buildings[key] = placed
    add_child(placed)
    
    # Update pixel physics (if integrated)
    if pixel_physics_manager:
        update_pixel_physics(final_position, piece_data)
    
    building_placed.emit(selected_piece_id, final_position)
    placement_validated.emit(true, "")
    return true

func check_materials(piece_data: BuildingPieceData) -> bool:
    if piece_data.materials.is_empty():
        return true  # No materials required
    
    for material_id in piece_data.materials:
        var quantity: int = piece_data.materials[material_id]
        if not InventoryManager.has_item_quantity(material_id, quantity):
            return false
    return true

func consume_materials(piece_data: BuildingPieceData) -> bool:
    if piece_data.materials.is_empty():
        return true
    
    for material_id in piece_data.materials:
        var quantity: int = piece_data.materials[material_id]
        var removed = InventoryManager.remove_item(material_id, quantity)
        if removed < quantity:
            push_error("BuildingManager: Failed to consume material: " + material_id)
            return false
    return true

func refund_building_materials(piece_data: BuildingPieceData) -> void:
    if piece_data.materials.is_empty():
        return
    
    if not InventoryManager:
        push_warning("BuildingManager: Cannot refund materials, InventoryManager not available")
        return
    
    # Refund all materials to inventory
    for material_id in piece_data.materials:
        var quantity: int = piece_data.materials[material_id]
        var item_data = ItemDatabase.get_item(material_id)
        if item_data:
            for i in range(quantity):
                var instance = ItemDatabase.create_item_instance(material_id)
                InventoryManager.add_item(instance)

func get_building_piece_data(piece_id: String) -> BuildingPieceData:
    var item_data = ItemDatabase.get_item(piece_id)
    if item_data == null:
        return null
    
    if not item_data.building_piece:
        push_warning("BuildingManager: Item is not a building piece: " + piece_id)
        return null
    
    return BuildingPieceData.from_item_data(item_data)
```

---

## Save/Load System

### Save Data

```gdscript
var building_save_data: Dictionary = {
    "placed_buildings": serialize_buildings(),
    "grid_mode": grid_mode,
    "grid_size": grid_size
}

func serialize_buildings() -> Array:
    var serialized: Array = []
    for pos in placed_buildings:
        var building: PlacedBuilding = placed_buildings[pos]
        serialized.append({
            "piece_id": building.piece.piece_id,
            "grid_position": building.grid_position,
            "world_position": building.world_position,
            "rotation": building.rotation,
            "is_grid_mode": building.is_grid_mode,
            "health": building.health
        })
    return serialized
```

---

## Error Handling

### BuildingManager Error Handling

- **Invalid Piece IDs:** Check ItemDatabase before operations, return errors gracefully
- **Missing Materials:** Check InventoryManager before placement, prevent placement if insufficient
- **Collision Detection:** Handle collision queries gracefully, return clear error messages
- **Invalid Positions:** Validate world positions before operations
- **Building Removal:** Handle missing buildings gracefully

### Best Practices

- Use `push_error()` for critical errors (invalid piece_id, missing ItemDatabase)
- Use `push_warning()` for non-critical issues (insufficient materials, collision)
- Return false/null on errors (don't crash)
- Validate all inputs before operations
- Refund materials if placement fails partway through

---

## Default Values and Configuration

### BuildingManager Defaults

```gdscript
# Grid Settings
grid_mode = true
grid_size = 16.0  # pixels

# Building Settings
return_materials_on_removal = true
MAX_BUILDING_DISTANCE = 200.0  # pixels, 0 = unlimited

# Default piece data
DEFAULT_HEALTH = 100.0
DEFAULT_MAX_HEALTH = 100.0
```

### BuildingPieceData Defaults

```gdscript
size = Vector2i(1, 1)
health = 100.0
max_health = 100.0
can_connect = true
connection_points = []
placement_rules = {}
materials = {}
```

### PlacedBuilding Defaults

```gdscript
rotation = 0.0
is_grid_mode = true
health = 100.0
owner_id = ""
```

---

## Performance Considerations

### Optimization Strategies

1. **Building Dictionary:**
   - Use Vector2i keys for grid mode (efficient)
   - Use Vector2 keys for freeform mode
   - Limit building count per chunk if needed

2. **Collision Detection:**
   - Cache collision queries when possible
   - Limit collision checks per frame
   - Use spatial partitioning for large building counts

3. **Preview System:**
   - Update preview only when mouse moves
   - Use simple preview sprite (not full building)
   - Hide preview when not in building mode

4. **Structure Integrity:**
   - Calculate integrity only when needed (optional)
   - Cache integrity calculations
   - Update integrity only when structure changes

---

## Testing Checklist

- [ ] Grid mode snaps correctly
- [ ] Freeform mode places precisely
- [ ] Toggle between modes works
- [ ] Placement validation works
- [ ] Materials are consumed correctly
- [ ] Buildings persist correctly
- [ ] Removal returns materials (if enabled)
- [ ] Collision detection works
- [ ] Preview shows correctly
- [ ] Save/load preserves buildings

### Integration
- [ ] Integrates with ItemDatabase correctly
- [ ] Integrates with InventoryManager correctly
- [ ] Material consumption works correctly
- [ ] Material return on removal works (if enabled)
- [ ] Pixel physics integration works (if enabled)

### Edge Cases
- [ ] Invalid piece IDs handled
- [ ] Missing materials handled
- [ ] Collision detection handles edge cases
- [ ] Grid/freeform toggle works correctly
- [ ] Building removal handles missing buildings
- [ ] Preview updates correctly in both modes

---

## Complete Implementation

### BuildingManager Initialization

```gdscript
func _ready() -> void:
    # Wait for dependencies
    if ItemDatabase.items.is_empty():
        ItemDatabase.item_database_loaded.connect(_on_database_loaded)
    else:
        initialize()
    
    if InventoryManager == null:
        InventoryManager = get_node("/root/InventoryManager")

func _on_database_loaded() -> void:
    initialize()

func initialize() -> void:
    # Create validator
    validator = BuildingValidator.new()
    validator.building_manager = self
    
    # Initialize preview (hidden)
    preview_building = Node2D.new()
    preview_building.name = "PreviewBuilding"
    preview_building.visible = false
    add_child(preview_building)
```

### Grid System Implementation

```gdscript
func world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(world_pos.x / grid_size),
        int(world_pos.y / grid_size)
    )

func grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(
        grid_pos.x * grid_size + grid_size / 2.0,
        grid_pos.y * grid_size + grid_size / 2.0
    )

func snap_to_grid(world_pos: Vector2) -> Vector2:
    var grid_pos = world_to_grid(world_pos)
    return grid_to_world(grid_pos)
```

### Piece Selection Implementation

```gdscript
func select_building_piece(piece_id: String) -> bool:
    # Get piece data from ItemDatabase
    var piece_data = get_building_piece_data(piece_id)
    if piece_data == null:
        return false
    
    selected_piece_id = piece_id
    selected_piece_data = piece_data
    
    # Enter building mode
    enter_building_mode()
    
    return true

func get_available_pieces() -> Array[String]:
    # Get all building pieces from ItemDatabase
    var pieces = ItemDatabase.get_items_by_type(ItemData.ItemType.BUILDING)
    var piece_ids: Array[String] = []
    
    for item_data in pieces:
        if item_data.building_piece:
            piece_ids.append(item_data.item_id)
    
    return piece_ids
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── BuildingManager.gd
   ├── scripts/
   │   └── building/
   │       ├── BuildingPieceData.gd
   │       ├── BuildingValidator.gd
   │       └── PlacedBuilding.gd
   └── scenes/
       └── buildings/
           └── (building piece scenes)
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/BuildingManager.gd` as `BuildingManager`
   - **Important:** Load after ItemDatabase, InventoryManager

3. **Create Building Piece Items:**
   - Create ItemData resources with ItemType.BUILDING
   - Set building_piece = true
   - Add building-specific metadata:
     - `category`: Building category
     - `size`: Vector2i grid size
     - `sprite_path`: Path to sprite texture
     - `collision_shape_path`: Path to collision shape
     - `health`: Building health
     - `materials`: Dictionary {material_id: quantity}
     - `placement_rules`: Dictionary with placement rules
   - Save in `res://resources/items/`

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. InventoryManager
4. **BuildingManager** (after dependencies)

### Building Piece Configuration

**Building ItemData Setup:**
1. Create ItemData resource with ItemType.BUILDING
2. Set `building_piece = true`
3. Add metadata:
   - `category`: "wall", "floor", "door", "furniture", etc.
   - `size`: Vector2i(1, 1) for 1x1, Vector2i(2, 2) for 2x2, etc.
   - `sprite_path`: "res://assets/sprites/buildings/{piece_id}.png"
   - `collision_shape_path`: "res://resources/collision/{piece_id}.tres"
   - `health`: 100.0 (default)
   - `materials`: {"wood": 5, "nails": 2} (example)
   - `placement_rules`: {"needs_support": true} (optional)

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Building System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **PhysicsShapeQueryParameters2D:** https://docs.godotengine.org/en/stable/classes/class_physicsshapequeryparameters2d.html
- **Node2D:** https://docs.godotengine.org/en/stable/classes/class_node2d.html
- **Resource System:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Building System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [PhysicsShapeQueryParameters2D](https://docs.godotengine.org/en/stable/classes/class_physicsshapequeryparameters2d.html) - Collision detection
- [Node2D Documentation](https://docs.godotengine.org/en/stable/classes/class_node2d.html) - 2D node placement
- [Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data structures
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- BuildingPieceData is a RefCounted class (lightweight helper)
- PlacedBuilding extends Node2D (placeable in scene)
- BuildingManager is a Node (can be added to scene tree)
- Building pieces configured via ItemData resources

**Visual Configuration:**
- Building pieces created as ItemData resources in editor
- Building scenes can be created visually
- PlacedBuilding nodes can be placed in scene

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Visual building piece editor
  - Building palette browser
  - Placement preview tool
  - Structural integrity visualizer

**Current Approach:**
- Uses Godot's native systems (no custom tools needed)
- Building pieces configured via ItemData resources
- Buildings placed via BuildingManager
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Item Database Integration:** Uses `ItemDatabase.get_item(piece_id)` for building piece data, reads building-specific data from `ItemData.metadata`
2. **Inventory Integration:** Uses `InventoryManager.remove_item()` for material consumption, `InventoryManager.has_item_quantity()` for checking
3. **Grid System:** Grid snapping via world_to_grid/grid_to_world conversion, configurable grid_size (16px default)
4. **Freeform Mode:** Allows precise placement without snapping
5. **Preview System:** Shows placement preview before confirming, updates on mouse movement
6. **Collision Detection:** Uses PhysicsShapeQueryParameters2D for efficient collision checking
7. **Material Consumption:** Materials consumed before placement, refunded if placement fails
8. **Material Return:** Optional return of materials when removing buildings
9. **Structural Integrity:** Optional system for foundation/support checking
10. **Pixel Physics Integration:** Optional integration with pixel physics system

---

