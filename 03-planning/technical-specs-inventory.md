# Technical Specifications: Inventory System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the expandable inventory system with hotbar, equipment slots, storage containers, and item management features. This system integrates with ItemDatabase for item data and provides core inventory management functionality.

---

## Research Notes

### Inventory System Architecture Best Practices

**Research Findings:**
- Godot 4's Resource system is ideal for inventory slot data structures
- Array-based slot management is standard and performant
- Signal-based updates are best practice for UI synchronization
- Separate managers (InventoryManager, EquipmentManager, ContainerManager) improve modularity
- Hotbar should reference inventory slots, not duplicate them

**Sources:**
- [Godot 4 Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication patterns
- [Godot 4 Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data structures
- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines

**Implementation Approach:**
- Use Resource classes for InventorySlot and EquipmentSlot
- Array-based slot storage for O(1) access
- Signal emissions for UI updates (inventory_changed, hotbar_changed, etc.)
- Separate managers for modularity
- Hotbar references inventory slots (shared, not duplicated)

**Why This Approach:**
- Resource system provides serialization and editor support
- Arrays are efficient for slot access
- Signals decouple UI from logic
- Modular managers allow independent testing and modification
- Shared hotbar/inventory slots prevent data duplication

### Item Stacking and Management

**Research Findings:**
- Stacking logic should check max_stack_size from ItemData
- Auto-stacking on pickup improves UX
- Split stack functionality is standard for inventory systems
- Quantity tracking per slot is essential

**Sources:**
- [Godot 4 Dictionary and Array Performance](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Data structure performance
- General game development best practices for inventory systems

**Implementation Approach:**
- Check item.is_stackable and item.max_stack_size from ItemDatabase
- Auto-stack when adding items (try existing stacks first, then empty slots)
- Split stack creates new slot with specified quantity
- Quantity stored per slot, not per item type

**Why This Approach:**
- Uses ItemDatabase as single source of truth for item properties
- Auto-stacking reduces manual management
- Split stack provides flexibility for crafting/trading
- Per-slot quantity allows partial stacks

### Equipment System Best Practices

**Research Findings:**
- Equipment slots should validate item type before equipping
- Stats should be calculated from equipped items
- Equipment changes should emit signals for UI/stats updates
- Unequipping should return item to inventory if space available

**Sources:**
- [Godot 4 Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Event-driven architecture
- General RPG equipment system patterns

**Implementation Approach:**
- Validate equipment_slot matches item.equipment_slot from ItemData
- Calculate stats by iterating equipped items
- Emit equipment_changed signal on equip/unequip
- Try to add unequipped item to inventory, drop if full

**Why This Approach:**
- Type validation prevents invalid equipment
- Signal-based updates keep systems decoupled
- Automatic inventory return improves UX
- Stat calculation from equipped items is standard pattern

### Container System Best Practices

**Research Findings:**
- Containers should be separate from player inventory
- Container data should persist with world state
- Transfer operations should validate space before moving
- Containers can have variable sizes (configurable per container type)

**Sources:**
- [Godot 4 Save System](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html) - Persistence patterns
- General storage container system patterns

**Implementation Approach:**
- Containers stored separately in ContainerManager
- Container data saved with world/level data
- Transfer functions check both source and destination space
- Container size configurable via ContainerData resource

**Why This Approach:**
- Separation prevents inventory/container conflicts
- Persistence maintains world state
- Validation prevents invalid transfers
- Configurable sizes allow variety (chests, barrels, etc.)

### Auto-Pickup and Performance

**Research Findings:**
- Spatial queries (Area2D, Physics queries) are efficient for pickup detection
- Limit pickup checks per frame to avoid performance issues
- Auto-stacking should happen during pickup, not after

**Sources:**
- [Godot 4 Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Spatial detection
- [Godot 4 Performance Best Practices](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Optimization guidelines

**Implementation Approach:**
- Use Area2D or Physics queries for pickup range detection
- Limit to ~10 items checked per frame
- Auto-stack during add_item() call
- Batch pickup operations when possible

**Why This Approach:**
- Spatial queries are efficient for range detection
- Frame limits prevent performance spikes
- Auto-stacking during pickup is seamless
- Batching reduces signal emissions

---

## Data Structures

**Note:** ItemData is defined in `technical-specs-item-database.md`. This system uses `ItemDatabase.get_item(item_id)` to retrieve item data. Item instances are created via `ItemDatabase.create_item_instance(item_id)` for runtime modifications.

### InventorySlot

```gdscript
class_name InventorySlot
extends Resource

var item_data: ItemData = null  # Reference to ItemData from ItemDatabase
var quantity: int = 0
var is_empty: bool = true

func add_item(item: ItemData, amount: int = 1) -> int
func remove_item(amount: int = 1) -> int
func clear() -> void
func can_stack_with(item: ItemData) -> bool
func get_remaining_space() -> int
```

### EquipmentSlot

```gdscript
class_name EquipmentSlot
extends Resource

var slot_type: SlotType
var equipped_item: ItemData = null
var is_empty: bool = true

enum SlotType {
    HEAD,
    CHEST,
    LEGS,
    FEET,
    ACCESSORY_1,
    ACCESSORY_2,
    ACCESSORY_3
}

func equip_item(item: ItemData) -> bool
func unequip_item() -> ItemData
func can_equip(item: ItemData) -> bool
```

### ContainerData

```gdscript
class_name ContainerData
extends Resource

@export var container_id: String
@export var container_name: String
@export var max_slots: int = 20  # Varies by container type
@export var container_type: String = "chest"  # "chest", "barrel", "crate", etc.
var slots: Array[InventorySlot] = []
var is_locked: bool = false
var world_position: Vector2  # Position in world (for persistence)

func add_item(item: ItemData, amount: int = 1) -> int
func remove_item(slot_index: int, amount: int = 1) -> int
func get_empty_slot() -> int
func sort_inventory() -> void
func can_add_item(item: ItemData, quantity: int = 1) -> bool
```

---

## Core Classes

### InventoryManager (Autoload Singleton)

```gdscript
class_name InventoryManager
extends Node

# Configuration (configurable via resource or constants)
const STARTING_INVENTORY_SIZE: int = 20
const STARTING_HOTBAR_SIZE: int = 8
const MAX_INVENTORY_SIZE: int = 200  # Maximum expandable size
const MAX_HOTBAR_SIZE: int = 20  # Maximum expandable hotbar
const PICKUP_RANGE: float = 64.0  # pixels
const MAX_PICKUP_CHECKS_PER_FRAME: int = 10  # Performance limit

# Inventory slots
var inventory_slots: Array[InventorySlot] = []
var hotbar_slots: Array[InventorySlot] = []
var current_inventory_size: int = STARTING_INVENTORY_SIZE
var current_hotbar_size: int = STARTING_HOTBAR_SIZE

# Equipment slots (managed by EquipmentManager)
var equipment_manager: EquipmentManager

# Active hotbar selection
var selected_hotbar_slot: int = 0

# Pickup queue (for performance)
var pickup_queue: Array[Dictionary] = []  # [{item_node, item_data, quantity}]

# Signals
signal inventory_changed()
signal hotbar_changed(slot_index: int)
signal item_picked_up(item_id: String, quantity: int)
signal inventory_full()
signal item_dropped(item_id: String, quantity: int, position: Vector2)
signal slot_changed(slot_index: int)
signal hotbar_selection_changed(index: int)

# Initialization
func _ready() -> void
func initialize_inventory() -> void
func initialize_hotbar() -> void

# Item Management
func add_item(item_id: String, quantity: int = 1) -> int  # Returns remaining quantity
func add_item_by_data(item_data: ItemData, quantity: int = 1) -> int
func remove_item(item_id: String, quantity: int = 1) -> bool
func remove_item_from_slot(slot_index: int, quantity: int = 1) -> bool
func can_add_item(item_id: String, quantity: int = 1) -> bool
func can_add_item_by_data(item_data: ItemData, quantity: int = 1) -> bool

# Slot Management
func find_item_slot(item_id: String) -> int  # Returns first slot with item, -1 if not found
func find_empty_slot() -> int  # Returns first empty slot index, -1 if full
func get_item_at_slot(slot_index: int) -> ItemData
func get_quantity_at_slot(slot_index: int) -> int
func swap_slots(slot_a: int, slot_b: int) -> void
func move_item_to_hotbar(inventory_slot: int, hotbar_slot: int) -> void
func move_item_from_hotbar(hotbar_slot: int, inventory_slot: int) -> void

# Inventory Operations
func sort_inventory() -> void
func search_inventory(search_term: String) -> Array[int]  # Returns array of matching slot indices
func filter_inventory(filter_type: ItemData.ItemType) -> Array[int]
func split_stack(slot_index: int, quantity: int) -> bool
func expand_inventory(additional_slots: int) -> void
func expand_hotbar(additional_slots: int) -> void

# Item Usage
func use_item(slot_index: int) -> void
func drop_item(slot_index: int, quantity: int = 1, position: Vector2 = Vector2.ZERO) -> void
func handle_inventory_full(item_id: String, quantity: int, position: Vector2) -> void

# Hotbar Management
func select_hotbar_slot(index: int) -> void
func scroll_hotbar(direction: int) -> void  # -1 for left, 1 for right
func get_selected_item() -> ItemData
func use_selected_item() -> void

# Auto-Pickup
func auto_pickup_items(position: Vector2) -> void
func process_pickup_queue() -> void  # Called each frame, processes limited items
```

**Note:** Hotbar functionality is integrated into InventoryManager. Hotbar slots are part of the main inventory system, not a separate manager. This simplifies management and prevents data duplication.

### EquipmentManager

```gdscript
class_name EquipmentManager
extends Node

var equipment_slots: Dictionary = {}  # EquipmentSlot.SlotType -> EquipmentSlot
var accessory_slots: Array[EquipmentSlot] = []
var accessory_slot_count: int = 3

signal equipment_changed(slot_type: EquipmentSlot.SlotType)
signal stats_changed()

# Initialization
func _ready() -> void
func initialize_equipment_slots() -> void

# Equipment Operations
func equip_item(item_id: String, slot_type: EquipmentSlot.SlotType) -> bool
func equip_item_by_data(item_data: ItemData, slot_type: EquipmentSlot.SlotType) -> bool
func unequip_item(slot_type: EquipmentSlot.SlotType) -> ItemData  # Returns unequipped item
func get_equipped_item(slot_type: EquipmentSlot.SlotType) -> ItemData

# Validation
func can_equip(item_id: String, slot_type: EquipmentSlot.SlotType) -> bool
func can_equip_by_data(item_data: ItemData, slot_type: EquipmentSlot.SlotType) -> bool

# Stats Calculation
func get_total_armor() -> int
func get_total_stats() -> Dictionary  # Returns all stat bonuses from equipment
func calculate_stat_bonus(stat_name: String) -> float  # Calculate bonus for specific stat
```

### ContainerManager

```gdscript
class_name ContainerManager
extends Node

var world_containers: Dictionary = {}  # container_id -> ContainerData
var open_container: ContainerData = null

signal container_opened(container: ContainerData)
signal container_closed()
signal container_changed(container: ContainerData)

func _ready() -> void
func register_container(container_id: String, container: ContainerData) -> void
func open_container(container_id: String) -> bool
func close_container() -> void
func add_item_to_container(container_id: String, item: ItemData, quantity: int = 1) -> int
func remove_item_from_container(container_id: String, slot_index: int, quantity: int = 1) -> bool
func transfer_item_to_inventory(container_id: String, slot_index: int, quantity: int = 1) -> bool
func transfer_item_to_container(container_id: String, item: ItemData, quantity: int = 1) -> bool
func sort_container(container_id: String) -> void
```

---

## System Architecture

### Component Hierarchy

```
InventoryManager (Autoload Singleton)
├── HotbarManager
├── EquipmentManager
└── ContainerManager
```

### Data Flow

1. **Item Pickup:**
   - Player walks near item → `auto_pickup_items()` called
   - Check if item can be added → `can_add_item()`
   - If yes: `add_item()` → emit `item_picked_up` signal
   - If no: `handle_inventory_full()` → drop item, show notification

2. **Item Management:**
   - Player opens inventory → UI queries `inventory_slots`
   - Player drags item → `swap_slots()` or `move_item_to_hotbar()`
   - Player uses item → `use_item()` → execute item's use action
   - Player drops item → `drop_item()` → spawn item in world

3. **Equipment:**
   - Player equips item → `EquipmentManager.equip_item()`
   - Update stats → emit `stats_changed` signal
   - Update visual appearance

4. **Storage Containers:**
   - Player interacts with container → `ContainerManager.open_container()`
   - Display container UI → show `container.slots`
   - Transfer items → `transfer_item_to_inventory()` or `transfer_item_to_container()`

---

## Algorithms

### Auto-Pickup Algorithm (Using ItemDatabase)

```gdscript
func auto_pickup_items(player_position: Vector2) -> void:
    # Get nearby item nodes (via Area2D or Physics query)
    var nearby_items = get_items_in_range(player_position, PICKUP_RANGE)
    
    # Process limited items per frame (performance)
    var processed = 0
    for item_node in nearby_items:
        if processed >= MAX_PICKUP_CHECKS_PER_FRAME:
            # Queue remaining items for next frame
            pickup_queue.append({
                "item_node": item_node,
                "position": item_node.global_position
            })
            continue
        
        var item_id = item_node.get_item_id()  # Item node should have item_id
        var quantity = item_node.get_quantity()
        
        if item_id.is_empty():
            push_warning("InventoryManager: Item node missing item_id")
            continue
        
        # Get item data from ItemDatabase
        var item_data = ItemDatabase.get_item(item_id)
        if item_data == null:
            push_warning("InventoryManager: Invalid item_id in pickup: " + item_id)
            continue
        
        # Try to add to inventory (auto-stacks)
        var remaining = add_item(item_id, quantity)
        
        if remaining > 0:
            # Couldn't fit all items
            item_node.set_quantity(remaining)
        else:
            # All items picked up
            item_node.queue_free()
            emit_signal("item_picked_up", item_id, quantity)
        
        processed += 1
    
    # Process pickup queue next frame
    if pickup_queue.size() > 0:
        call_deferred("process_pickup_queue")

func process_pickup_queue() -> void:
    # Process queued items (limited per frame)
    var processed = 0
    var remaining_queue: Array[Dictionary] = []
    
    for item_data in pickup_queue:
        if processed >= MAX_PICKUP_CHECKS_PER_FRAME:
            remaining_queue.append(item_data)
            continue
        
        var item_node = item_data.item_node
        var item_id = item_node.get_item_id()
        var quantity = item_node.get_quantity()
        
        var remaining = add_item(item_id, quantity)
        
        if remaining > 0:
            item_node.set_quantity(remaining)
        else:
            item_node.queue_free()
            emit_signal("item_picked_up", item_id, quantity)
        
        processed += 1
    
    pickup_queue = remaining_queue
    
    # Continue processing if queue not empty
    if pickup_queue.size() > 0:
        call_deferred("process_pickup_queue")
```

### Add Item Algorithm (Using ItemDatabase)

```gdscript
func add_item(item_id: String, quantity: int = 1) -> int:
    # Get item data from ItemDatabase
    var item_data = ItemDatabase.get_item(item_id)
    if item_data == null:
        push_error("InventoryManager: Invalid item_id: " + item_id)
        return quantity  # Return full quantity as remaining
    
    return add_item_by_data(item_data, quantity)

func add_item_by_data(item_data: ItemData, quantity: int = 1) -> int:
    if quantity <= 0:
        return 0
    
    var remaining = quantity
    
    # First, try to stack with existing items (auto-stack)
    if item_data.is_stackable:
        for i in range(inventory_slots.size()):
            var slot = inventory_slots[i]
            if not slot.is_empty and slot.item_data.item_id == item_data.item_id:
                var remaining_space = slot.get_remaining_space()
                if remaining_space > 0:
                    var can_add = min(remaining, remaining_space)
                    slot.quantity += can_add
                    slot.is_empty = false
                    remaining -= can_add
                    emit_signal("slot_changed", i)
                    if remaining <= 0:
                        break
    
    # Then, try to fill empty slots
    while remaining > 0:
        var empty_slot = find_empty_slot()
        if empty_slot == -1:
            # Inventory full
            emit_signal("inventory_full")
            break
        
        # Create item instance for this slot (for durability tracking)
        var item_instance = ItemDatabase.create_item_instance(item_data.item_id)
        var stack_size = min(remaining, item_data.max_stack_size)
        
        inventory_slots[empty_slot].item_data = item_instance
        inventory_slots[empty_slot].quantity = stack_size
        inventory_slots[empty_slot].is_empty = false
        remaining -= stack_size
        
        emit_signal("slot_changed", empty_slot)
    
    if remaining < quantity:  # Some items were added
        emit_signal("inventory_changed")
    
    return remaining
```

### Sort Inventory Algorithm

```gdscript
func sort_inventory() -> void:
    # Collect all non-empty slots
    var items: Array[Dictionary] = []
    for i in range(inventory_slots.size()):
        var slot = inventory_slots[i]
        if not slot.is_empty:
            items.append({
                "item": slot.item_data,
                "quantity": slot.quantity,
                "original_index": i
            })
    
    # Sort by item type, then by name
    items.sort_custom(func(a, b):
        if a.item.item_type != b.item.item_type:
            return a.item.item_type < b.item.item_type
        return a.item.item_name < b.item.item_name
    )
    
    # Clear all slots
    for slot in inventory_slots:
        slot.clear()
    
    # Re-add sorted items, stacking where possible
    for item_data in items:
        add_item(item_data.item, item_data.quantity)
    
    emit_signal("inventory_changed")
```

### Search/Filter Algorithm

```gdscript
func search_inventory(search_term: String) -> Array[int]:
    var matching_slots: Array[int] = []
    var term_lower = search_term.to_lower()
    
    for i in range(inventory_slots.size()):
        var slot = inventory_slots[i]
        if not slot.is_empty:
            var item_name = slot.item_data.item_name.to_lower()
            var description = slot.item_data.description.to_lower()
            
            if term_lower in item_name or term_lower in description:
                matching_slots.append(i)
    
    return matching_slots

func filter_inventory(filter_type: ItemData.ItemType) -> Array[int]:
    var matching_slots: Array[int] = []
    
    for i in range(inventory_slots.size()):
        var slot = inventory_slots[i]
        if not slot.is_empty and slot.item_data.item_type == filter_type:
            matching_slots.append(i)
    
    return matching_slots
```

### Split Stack Algorithm

```gdscript
func split_stack(slot_index: int, quantity: int) -> bool:
    var slot = inventory_slots[slot_index]
    
    if slot.is_empty or slot.quantity <= quantity:
        return false
    
    # Find empty slot
    var empty_slot = find_empty_slot()
    if empty_slot == -1:
        return false
    
    # Move quantity to new slot
    var new_slot = inventory_slots[empty_slot]
    new_slot.item_data = slot.item_data
    new_slot.quantity = quantity
    new_slot.is_empty = false
    
    # Reduce original slot
    slot.quantity -= quantity
    
    emit_signal("inventory_changed")
    return true
```

---

## Integration Points

### With Player Controller
- Hotbar selection via number keys (1-8)
- Quick-use items from hotbar
- Item pickup range detection

### With UI System
- Inventory UI displays `inventory_slots`
- Hotbar UI displays `hotbar_slots`
- Equipment UI displays `equipment_slots`
- Container UI displays `container.slots`
- Tooltip system reads `ItemData`

### With Crafting System
- Consume items from inventory
- Add crafted items to inventory
- Check if player has required materials

### With Building System
- Consume building materials from inventory
- Place items from hotbar

### With Combat System
- Equip weapons from inventory
- Use consumables from hotbar
- Drop items on death (if configured)

### With Save System
- Save inventory state
- Save equipment state
- Save container states

---

## Save/Load System

### Inventory Save Data

```gdscript
class_name InventorySaveData
extends Resource

var inventory_slots_data: Array[Dictionary] = []
var hotbar_slots_data: Array[Dictionary] = []
var equipment_slots_data: Dictionary = {}
var accessory_slots_data: Array[Dictionary] = []
var current_inventory_size: int = 20
var current_hotbar_size: int = 8
var selected_hotbar_slot: int = 0

# Slot data format:
# {
#     "item_id": "wood",
#     "quantity": 50,
#     "durability": 100
# }
```

### Save Function

```gdscript
func save_inventory() -> Dictionary:
    var save_data = {
        "inventory_slots": [],
        "hotbar_slots": [],
        "equipment_slots": {},
        "accessory_slots": [],
        "current_inventory_size": current_inventory_size,
        "current_hotbar_size": current_hotbar_size,
        "selected_hotbar_slot": selected_hotbar_slot
    }
    
    # Save inventory slots
    for slot in inventory_slots:
        if not slot.is_empty:
            save_data.inventory_slots.append({
                "item_id": slot.item_data.item_id,
                "quantity": slot.quantity,
                "durability": slot.item_data.current_durability
            })
        else:
            save_data.inventory_slots.append(null)
    
    # Save hotbar slots (similar)
    # Save equipment slots (similar)
    # Save accessory slots (similar)
    
    return save_data
```

### Load Function (Using ItemDatabase)

```gdscript
func load_inventory(save_data: Dictionary) -> void:
    current_inventory_size = save_data.get("current_inventory_size", STARTING_INVENTORY_SIZE)
    current_hotbar_size = save_data.get("current_hotbar_size", STARTING_HOTBAR_SIZE)
    selected_hotbar_slot = save_data.get("selected_hotbar_slot", 0)
    
    # Clamp sizes to valid ranges
    current_inventory_size = clamp(current_inventory_size, STARTING_INVENTORY_SIZE, MAX_INVENTORY_SIZE)
    current_hotbar_size = clamp(current_hotbar_size, STARTING_HOTBAR_SIZE, MAX_HOTBAR_SIZE)
    
    # Initialize slots
    initialize_inventory()
    initialize_hotbar()
    
    # Load inventory slots
    var slots_data = save_data.get("inventory_slots", [])
    for i in range(min(slots_data.size(), inventory_slots.size())):
        if slots_data[i] != null and slots_data[i] is Dictionary:
            var item_id = slots_data[i].get("item_id", "")
            var quantity = slots_data[i].get("quantity", 1)
            var durability = slots_data[i].get("durability", -1)
            
            # Get item data from ItemDatabase
            var base_item = ItemDatabase.get_item(item_id)
            if base_item != null:
                # Create item instance with durability
                var item_instance = ItemDatabase.create_item_with_durability(item_id, durability)
                if item_instance == null:
                    item_instance = ItemDatabase.create_item_instance(item_id)
                    if durability > 0 and item_instance.durability > 0:
                        item_instance.current_durability = durability
                
                inventory_slots[i].item_data = item_instance
                inventory_slots[i].quantity = quantity
                inventory_slots[i].is_empty = false
    
    # Load hotbar slots
    var hotbar_data = save_data.get("hotbar_slots", [])
    for i in range(min(hotbar_data.size(), hotbar_slots.size())):
        if hotbar_data[i] != null and hotbar_data[i] is Dictionary:
            var item_id = hotbar_data[i].get("item_id", "")
            var quantity = hotbar_data[i].get("quantity", 1)
            var durability = hotbar_data[i].get("durability", -1)
            
            var base_item = ItemDatabase.get_item(item_id)
            if base_item != null:
                var item_instance = ItemDatabase.create_item_with_durability(item_id, durability)
                if item_instance == null:
                    item_instance = ItemDatabase.create_item_instance(item_id)
                    if durability > 0 and item_instance.durability > 0:
                        item_instance.current_durability = durability
                
                hotbar_slots[i].item_data = item_instance
                hotbar_slots[i].quantity = quantity
                hotbar_slots[i].is_empty = false
    
    # Load equipment (handled by EquipmentManager)
    if equipment_manager:
        equipment_manager.load_equipment(save_data.get("equipment_slots", {}))
    
    emit_signal("inventory_changed")
    emit_signal("hotbar_changed", selected_hotbar_slot)
```

---

## Error Handling

### InventoryManager Error Handling

- **Invalid Item IDs:** Check ItemDatabase before operations, return errors gracefully
- **Full Inventory:** Emit signal, handle via drop/notification/reject based on config
- **Invalid Slot Indices:** Validate indices before access, return null/empty on error
- **Stack Overflow:** Clamp quantities to max_stack_size, handle overflow gracefully
- **Equipment Validation:** Check item type matches slot type before equipping
- **Container Not Found:** Return false/null when container doesn't exist

### Best Practices

- Use `push_error()` for critical errors (invalid item_id, corrupted save data)
- Use `push_warning()` for non-critical issues (inventory full, can't stack)
- Return null/false/empty arrays on errors (don't crash)
- Validate all inputs before operations
- Log errors for debugging

---

## Default Values and Configuration

### InventoryManager Defaults

```gdscript
# Starting sizes
STARTING_INVENTORY_SIZE = 20
STARTING_HOTBAR_SIZE = 8

# Maximum sizes
MAX_INVENTORY_SIZE = 200
MAX_HOTBAR_SIZE = 20

# Pickup settings
PICKUP_RANGE = 64.0  # pixels
MAX_PICKUP_CHECKS_PER_FRAME = 10

# Equipment defaults
ACCESSORY_SLOT_COUNT = 3
```

### InventorySlot Defaults

```gdscript
item_data = null
quantity = 0
is_empty = true
```

### EquipmentSlot Defaults

```gdscript
equipped_item = null
is_empty = true
```

### ContainerData Defaults

```gdscript
max_slots = 20
container_type = "chest"
is_locked = false
slots = []  # Empty array
```

---

## Performance Considerations

### Optimization Strategies

1. **Slot Array Management:**
   - Pre-allocate slot arrays to avoid resizing
   - Use object pooling for frequently created/destroyed items

2. **Search/Filter:**
   - Cache search results when possible
   - Limit search to visible slots in UI

3. **Auto-Pickup:**
   - Use spatial partitioning for item detection
   - Limit pickup checks per frame (e.g., 10 items max)

4. **UI Updates:**
   - Only update changed slots, not entire inventory
   - Use dirty flags to track changes

5. **Container Management:**
   - Unload containers that are far from player
   - Use lazy loading for container data

---

## Testing Checklist

### Inventory Management
- [ ] Add items to inventory
- [ ] Remove items from inventory
- [ ] Stack items correctly (max 99)
- [ ] Non-stackable items don't stack
- [ ] Inventory expands correctly
- [ ] Sort inventory works
- [ ] Search/filter works
- [ ] Split stack works
- [ ] Drop item works
- [ ] Quick-use items works

### Hotbar
- [ ] Hotbar displays correctly
- [ ] Select hotbar slot (number keys)
- [ ] Scroll hotbar (mouse wheel)
- [ ] Move items to/from hotbar
- [ ] Hotbar expands correctly
- [ ] Use item from hotbar

### Equipment
- [ ] Equip armor (Head, Chest, Legs, Feet)
- [ ] Equip accessories (3 slots)
- [ ] Unequip items
- [ ] Stats update when equipping
- [ ] Can't equip wrong item type

### Containers
- [ ] Open container
- [ ] Close container
- [ ] Add items to container
- [ ] Remove items from container
- [ ] Transfer items between inventory and container
- [ ] Container size varies by type
- [ ] Containers accessed individually

### Pickup System
- [ ] Auto-pickup works
- [ ] Items stack automatically when picked up
- [ ] Inventory full handling (drop, notification, reject)
- [ ] Pickup range works correctly

### Save/Load
- [ ] Save inventory state
- [ ] Load inventory state
- [ ] Equipment saves correctly
- [ ] Container states save correctly
- [ ] Hotbar selection saves

### Edge Cases
- [ ] Inventory full edge cases
- [ ] Stack size limits
- [ ] Empty slot handling
- [ ] Invalid item data
- [ ] Container not found
- [ ] Equipment slot conflicts

---

## Complete Implementation

### InventorySlot Complete Implementation

```gdscript
class_name InventorySlot
extends Resource

var item_data: ItemData = null
var quantity: int = 0
var is_empty: bool = true

func add_item(item: ItemData, amount: int = 1) -> int:
    if item == null or amount <= 0:
        return amount
    
    if is_empty:
        item_data = item
        quantity = min(amount, item.max_stack_size)
        is_empty = false
        return max(0, amount - item.max_stack_size)
    
    if can_stack_with(item):
        var remaining_space = get_remaining_space()
        var can_add = min(amount, remaining_space)
        quantity += can_add
        return max(0, amount - can_add)
    
    return amount  # Can't stack

func remove_item(amount: int = 1) -> int:
    if is_empty or amount <= 0:
        return 0
    
    var removed = min(amount, quantity)
    quantity -= removed
    
    if quantity <= 0:
        clear()
    
    return removed

func clear() -> void:
    item_data = null
    quantity = 0
    is_empty = true

func can_stack_with(item: ItemData) -> bool:
    if is_empty or item == null:
        return false
    if item_data.item_id != item.item_id:
        return false
    if not item.is_stackable:
        return false
    return quantity < item.max_stack_size

func get_remaining_space() -> int:
    if is_empty or item_data == null:
        return 0
    return max(0, item_data.max_stack_size - quantity)
```

### InventoryManager Initialization

```gdscript
func _ready() -> void:
    # Wait for ItemDatabase to load
    if ItemDatabase.items.is_empty():
        ItemDatabase.item_database_loaded.connect(_on_database_loaded)
    else:
        initialize_inventory()
        initialize_hotbar()
        if equipment_manager == null:
            equipment_manager = EquipmentManager.new()
            add_child(equipment_manager)
            equipment_manager.initialize_equipment_slots()

func _on_database_loaded() -> void:
    initialize_inventory()
    initialize_hotbar()
    if equipment_manager == null:
        equipment_manager = EquipmentManager.new()
        add_child(equipment_manager)
        equipment_manager.initialize_equipment_slots()

func initialize_inventory() -> void:
    inventory_slots.clear()
    for i in range(current_inventory_size):
        inventory_slots.append(InventorySlot.new())

func initialize_hotbar() -> void:
    hotbar_slots.clear()
    for i in range(current_hotbar_size):
        hotbar_slots.append(InventorySlot.new())
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       ├── InventoryManager.gd
   │       ├── EquipmentManager.gd
   │       └── ContainerManager.gd
   └── resources/
       └── inventory/
           └── (container resources if needed)
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/InventoryManager.gd` as `InventoryManager`
   - **Important:** Load after ItemDatabase, before systems that use inventory

3. **Create EquipmentManager:**
   - EquipmentManager should be a child node of InventoryManager
   - Or create as separate autoload (recommended: child node)

4. **Create ContainerManager:**
   - ContainerManager should be a child node of InventoryManager
   - Or create as separate autoload (recommended: child node)

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase (must be before InventoryManager)
3. **InventoryManager** (before systems that use inventory)
4. Other systems (Crafting, Combat, Building, etc.)

### UI Integration

1. **Subscribe to Signals:**
   ```gdscript
   # In InventoryUI
   func _ready() -> void:
       InventoryManager.inventory_changed.connect(_on_inventory_changed)
       InventoryManager.hotbar_changed.connect(_on_hotbar_changed)
       InventoryManager.slot_changed.connect(_on_slot_changed)
   ```

2. **Display Inventory:**
   - Query `InventoryManager.inventory_slots` for slot data
   - Query `InventoryManager.hotbar_slots` for hotbar data
   - Update UI when signals are emitted

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Inventory System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Resource System:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
- **Array Documentation:** https://docs.godotengine.org/en/stable/classes/class_array.html
- **Dictionary Documentation:** https://docs.godotengine.org/en/stable/classes/class_dictionary.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Inventory System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data structures
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup
- [Array Documentation](https://docs.godotengine.org/en/stable/classes/class_array.html) - Array operations
- [Dictionary Documentation](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) - Dictionary operations

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- InventorySlot and EquipmentSlot are Resource classes (editable in inspector)
- ContainerData is a Resource class (can be created in editor)
- All managers are Node-based (can be added to scene tree)
- Configuration values are constants (can be made @export for editor tweaking)

**Visual Configuration:**
- ContainerData resources can be created in FileSystem
- Container properties editable in Inspector
- InventoryManager settings can be exposed as @export variables

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Visual inventory slot editor
  - Container placement tool
  - Inventory testing/debugging window
  - Bulk item addition tool for testing

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Containers created as resources, placed in world via scene
- All configuration done via code constants or @export variables
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Item Database Integration:** Uses `ItemDatabase.get_item(item_id)` for all item lookups
2. **Item Instances:** Creates item instances via `ItemDatabase.create_item_instance()` for runtime modifications (durability)
3. **UI Integration:** Inventory UI should subscribe to `inventory_changed`, `hotbar_changed`, and `slot_changed` signals
4. **Drag and Drop:** Implement drag-and-drop in UI layer, call `swap_slots()` or `move_item_to_hotbar()` on drop
5. **Notifications:** Use UI notification system for "Inventory Full" messages
6. **Tooltips:** Tooltip system should read from `ItemData` for display
7. **Durability:** Track durability per item instance (created via ItemDatabase), not per item type
8. **Hotbar:** Hotbar slots are separate from inventory slots but managed by same system
9. **Equipment:** EquipmentManager handles all equipment operations, emits signals for stats updates
10. **Containers:** ContainerManager handles world containers, separate from player inventory
11. **Initialization:** InventoryManager waits for ItemDatabase to load before initializing
12. **Performance:** Auto-pickup limited to MAX_PICKUP_CHECKS_PER_FRAME items per frame

---

## Future Enhancements

- Quick-stack to containers
- Favorites/bookmarks for items
- Inventory presets/loadouts
- Auto-organize on pickup option
- Item comparison tooltips
- Container linking/network system (future consideration)

