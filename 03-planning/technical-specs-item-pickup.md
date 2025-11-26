# Technical Specifications: Item Pickup System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the item pickup system with auto-pickup range (base + upgrades), pull animation visual feedback, and currency having longer base range. This system integrates with Inventory System, Item Database, Player Controller, and UI System.

---

## Research Notes

### Item Pickup System Best Practices

**Research Findings:**
- Auto-pickup improves player experience (no manual clicking)
- Range-based pickup is standard in survival games
- Visual feedback (pull animation) is satisfying
- Upgradeable range rewards progression
- Currency should have longer range (more forgiving)

**Sources:**
- [Godot 4 Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Detection areas
- [Godot 4 Tween Documentation](https://docs.godotengine.org/en/stable/classes/class_tween.html) - Animations
- Terraria item pickup patterns - Industry standard approach

**Implementation Approach:**
- Area2D for pickup detection
- Tween for pull animation
- Range-based auto-pickup
- Upgradeable range via skills/items
- Currency has longer base range

**Why This Approach:**
- Area2D is efficient for detection
- Tween provides smooth animations
- Range-based pickup is intuitive
- Upgradeable range adds progression
- Currency longer range is player-friendly

### Pickup Animation Best Practices

**Research Findings:**
- Pull animation toward player is satisfying
- Smooth easing functions feel better
- Visual feedback improves feel
- Sound effects enhance pickup

**Sources:**
- [Godot 4 Tween Documentation](https://docs.godotengine.org/en/stable/classes/class_tween.html) - Animation system
- General game feel principles

**Implementation Approach:**
- Tween for smooth movement
- Ease-out easing for natural feel
- Configurable speed
- Sound effects on pickup

**Why This Approach:**
- Smooth animations feel polished
- Ease-out feels natural
- Configurable for tweaking
- Sound provides audio feedback

---

## Data Structures

### PickupableItem

```gdscript
class_name PickupableItem
extends Area2D

# Item Data
@export var item_data: ItemData  # Item to pickup
@export var quantity: int = 1  # Quantity (for stackable items)

# Pickup Configuration
@export var auto_pickup: bool = true  # Auto-pickup when in range
@export var pickup_range: float = 50.0  # Base pickup range (overridden for currency)
@export var pull_speed: float = 300.0  # Pixels per second pull speed
@export var pull_easing: Tween.EaseType = Tween.EASE_OUT
@export var pull_transition: Tween.TransitionType = Tween.TRANS_CUBIC

# Visual
@export var sprite: Sprite2D  # Item sprite
@export var glow_effect: Node2D  # Glow when in range (optional)
@export var pickup_sound: String = ""  # Sound ID for pickup

# State
var is_in_range: bool = false
var is_pulling: bool = false
var pull_tween: Tween = null
var player_ref: Node2D = null
```

### PickupRangeUpgrade

```gdscript
class_name PickupRangeUpgrade
extends Resource

@export var upgrade_id: String
@export var range_bonus: float = 10.0  # Additional range
@export var upgrade_type: UpgradeType = UpgradeType.SKILL

enum UpgradeType {
    SKILL,      # From skill tree
    ITEM,       # From equipment item
    PERMANENT   # Permanent upgrade
}
```

---

## Core Classes

### ItemPickupManager (Autoload Singleton)

```gdscript
class_name ItemPickupManager
extends Node

# Pickup Configuration
@export var base_pickup_range: float = 50.0  # Base range for items
@export var currency_base_range: float = 100.0  # Base range for currency (longer)
@export var pickup_check_interval: float = 0.1  # Check interval in seconds

# Range Upgrades
var range_upgrades: Array[PickupRangeUpgrade] = []
var total_range_bonus: float = 0.0

# References
var inventory_manager: InventoryManager
var item_database: ItemDatabase
var player: Node2D = null
var progression_manager: ProgressionManager  # For skill-based upgrades

# Active Pickups
var active_pickups: Array[PickupableItem] = []
var pickups_in_range: Array[PickupableItem] = []

# Signals
signal item_picked_up(item_data: ItemData, quantity: int)
signal pickup_range_changed(new_range: float)
signal currency_picked_up(currency_id: String, amount: int)

# Initialization
func _ready() -> void
func initialize() -> void

# Pickup Management
func register_pickup(pickup: PickupableItem) -> void
func unregister_pickup(pickup: PickupableItem) -> void
func _process(delta: float) -> void
func check_pickups() -> void

# Range Management
func get_pickup_range(item_data: ItemData) -> float
func get_currency_pickup_range() -> float
func add_range_upgrade(upgrade: PickupRangeUpgrade) -> void
func remove_range_upgrade(upgrade_id: String) -> void
func recalculate_range() -> void

# Pickup Operations
func pickup_item(pickup: PickupableItem) -> bool
func start_pull_animation(pickup: PickupableItem) -> void
func complete_pickup(pickup: PickupableItem) -> bool
```

---

## System Architecture

### Component Hierarchy

```
ItemPickupManager (Autoload Singleton)
├── PickupableItem[] (Array)
│   ├── Area2D (Detection)
│   ├── Sprite2D (Visual)
│   └── Tween (Animation)
└── UI/PickupIndicator (Control) [Optional]
```

### Data Flow

1. **Item Dropped:**
   ```
   Item dropped in world
   ├── Create PickupableItem node
   ├── Set item_data and quantity
   ├── Register with ItemPickupManager
   ├── Add to scene
   └── Start pickup detection
   ```

2. **Pickup Detection:**
   ```
   _process(delta)
   ├── Get player position
   ├── Check distance to all pickups
   ├── If in range: start pull animation
   ├── If close enough: pickup item
   └── Update visual indicators
   ```

3. **Pickup Animation:**
   ```
   Item in range
   ├── Start pull animation (Tween)
   ├── Move item toward player
   ├── When close enough: pickup
   ├── Add to inventory
   ├── Play sound effect
   └── Remove pickup node
   ```

---

## Algorithms

### Pickup Detection Algorithm

```gdscript
func _process(delta: float) -> void:
    if player == null:
        player = get_tree().get_first_node_in_group("player")
        if player == null:
            return
    
    # Check pickups periodically (not every frame for performance)
    var time_since_last_check = get_meta("last_check_time", 0.0)
    time_since_last_check += delta
    
    if time_since_last_check >= pickup_check_interval:
        check_pickups()
        set_meta("last_check_time", 0.0)
    else:
        set_meta("last_check_time", time_since_last_check)

func check_pickups() -> void:
    if player == null:
        return
    
    var player_pos = player.global_position
    pickups_in_range.clear()
    
    for pickup in active_pickups:
        if pickup == null or not is_instance_valid(pickup):
            continue
        
        var pickup_pos = pickup.global_position
        var distance = player_pos.distance_to(pickup_pos)
        var pickup_range = get_pickup_range(pickup.item_data)
        
        if distance <= pickup_range:
            if not pickup.is_in_range:
                # Just entered range
                pickup.is_in_range = true
                start_pull_animation(pickup)
            
            pickups_in_range.append(pickup)
            
            # Check if close enough to pickup
            var pickup_threshold = 10.0  # Pixels
            if distance <= pickup_threshold:
                complete_pickup(pickup)
        else:
            if pickup.is_in_range:
                # Left range
                pickup.is_in_range = false
                stop_pull_animation(pickup)
```

### Pull Animation Algorithm

```gdscript
func start_pull_animation(pickup: PickupableItem) -> void:
    if pickup.is_pulling or player == null:
        return
    
    pickup.is_pulling = true
    pickup.player_ref = player
    
    # Create tween for smooth movement
    if pickup.pull_tween:
        pickup.pull_tween.kill()
    
    pickup.pull_tween = create_tween()
    pickup.pull_tween.set_loops()  # Loop until picked up
    pickup.pull_tween.set_parallel(true)
    
    # Animate position toward player
    var start_pos = pickup.global_position
    var target_pos = player.global_position
    
    # Calculate duration based on distance and speed
    var distance = start_pos.distance_to(target_pos)
    var duration = distance / pickup.pull_speed
    
    # Tween position
    pickup.pull_tween.tween_method(
        func(pos: Vector2): pickup.global_position = pos,
        start_pos,
        target_pos,
        duration
    ).set_ease(pickup.pull_easing).set_trans(pickup.pull_transition)
    
    # Update target position continuously (player moves)
    pickup.pull_tween.tween_callback(update_pull_target).set_delay(0.1)

func update_pull_target() -> void:
    # This is called periodically to update target (player moves)
    # Would need to be implemented to continuously update target
    pass

func stop_pull_animation(pickup: PickupableItem) -> void:
    if pickup.pull_tween:
        pickup.pull_tween.kill()
        pickup.pull_tween = null
    pickup.is_pulling = false
```

### Pickup Range Calculation Algorithm

```gdscript
func get_pickup_range(item_data: ItemData) -> float:
    # Check if currency
    var is_currency = item_database.is_currency(item_data.item_id)
    
    # Base range
    var base_range = currency_base_range if is_currency else base_pickup_range
    
    # Add upgrades
    var total_range = base_range + total_range_bonus
    
    return total_range

func recalculate_range() -> void:
    total_range_bonus = 0.0
    
    for upgrade in range_upgrades:
        total_range_bonus += upgrade.range_bonus
    
    pickup_range_changed.emit(base_pickup_range + total_range_bonus)
```

### Complete Pickup Algorithm

```gdscript
func complete_pickup(pickup: PickupableItem) -> bool:
    if pickup == null or not is_instance_valid(pickup):
        return false
    
    if inventory_manager == null:
        push_error("ItemPickupManager: InventoryManager not available")
        return false
    
    # Stop animation
    stop_pull_animation(pickup)
    
    # Add item to inventory
    var added = false
    if pickup.quantity > 1:
        # Stackable item
        for i in range(pickup.quantity):
            var instance = item_database.create_item_instance(pickup.item_data.item_id)
            if inventory_manager.add_item(instance):
                added = true
            else:
                # Inventory full, drop remaining
                break
    else:
        # Single item
        var instance = item_database.create_item_instance(pickup.item_data.item_id)
        added = inventory_manager.add_item(instance)
    
    if added:
        # Play sound
        if pickup.pickup_sound != "" and AudioManager:
            AudioManager.play_sound(pickup.pickup_sound, pickup.global_position)
        
        # Emit signal
        if item_database.is_currency(pickup.item_data.item_id):
            currency_picked_up.emit(pickup.item_data.item_id, pickup.quantity)
        else:
            item_picked_up.emit(pickup.item_data, pickup.quantity)
        
        # Remove pickup
        unregister_pickup(pickup)
        pickup.queue_free()
        
        return true
    else:
        # Inventory full, stop pulling
        stop_pull_animation(pickup)
        return false
```

---

## Integration Points

### With Inventory System

```gdscript
# Add item to inventory
func add_item_to_inventory(item_instance: ItemData) -> bool:
    return inventory_manager.add_item(item_instance)

# Check if inventory has space
func can_add_item(item_id: String) -> bool:
    return inventory_manager.can_add_item(item_id)
```

### With Item Database

```gdscript
# Check if item is currency
func is_currency(item_id: String) -> bool:
    var item_data = item_database.get_item(item_id)
    if item_data == null:
        return false
    # Currency items would have a flag or specific type
    return item_data.item_type == ItemData.ItemType.CURRENCY

# Create item instance
func create_item_instance(item_id: String) -> ItemData:
    return item_database.create_item_instance(item_id)
```

### With Player Controller

```gdscript
# Get player position for range checks
func get_player_position() -> Vector2:
    if player:
        return player.global_position
    return Vector2.ZERO

# Player movement affects pull animation target
func update_pull_targets() -> void:
    # Update all active pull animations to target current player position
    for pickup in active_pickups:
        if pickup.is_pulling and pickup.pull_tween:
            # Update tween target (would need to recreate tween or use different approach)
            pass
```

### With Progression System

```gdscript
# Get range upgrades from skills
func update_range_from_skills() -> void:
    if progression_manager == null:
        return
    
    # Get skill-based range bonuses
    var skill_bonus = progression_manager.get_pickup_range_bonus()
    
    # Add skill upgrade
    var skill_upgrade = PickupRangeUpgrade.new()
    skill_upgrade.upgrade_id = "skill_bonus"
    skill_upgrade.range_bonus = skill_bonus
    skill_upgrade.upgrade_type = PickupRangeUpgrade.UpgradeType.SKILL
    
    # Remove old skill upgrade and add new
    remove_range_upgrade("skill_bonus")
    add_range_upgrade(skill_upgrade)
```

---

## Save/Load System

### Save Data Structure

```gdscript
var pickup_save_data: Dictionary = {
    "active_pickups": serialize_active_pickups(),
    "range_upgrades": serialize_range_upgrades()
}

func serialize_active_pickups() -> Array:
    var pickups_data: Array = []
    for pickup in active_pickups:
        if is_instance_valid(pickup):
            pickups_data.append({
                "item_id": pickup.item_data.item_id,
                "quantity": pickup.quantity,
                "position": {"x": pickup.global_position.x, "y": pickup.global_position.y}
            })
    return pickups_data

func serialize_range_upgrades() -> Array:
    var upgrades_data: Array = []
    for upgrade in range_upgrades:
        upgrades_data.append({
            "upgrade_id": upgrade.upgrade_id,
            "range_bonus": upgrade.range_bonus,
            "upgrade_type": upgrade.upgrade_type
        })
    return upgrades_data
```

### Load Data Structure

```gdscript
func load_pickup_data(data: Dictionary) -> void:
    if data.has("active_pickups"):
        load_active_pickups(data["active_pickups"])
    if data.has("range_upgrades"):
        load_range_upgrades(data["range_upgrades"])

func load_active_pickups(pickups_data: Array) -> void:
    for pickup_data in pickups_data:
        var item_id = pickup_data["item_id"]
        var quantity = pickup_data["quantity"]
        var pos = Vector2(pickup_data["position"]["x"], pickup_data["position"]["y"])
        spawn_pickup_item(item_id, quantity, pos)
```

---

## Error Handling

### ItemPickupManager Error Handling

- **Missing References:** Check references exist before using (inventory_manager, item_database, player)
- **Invalid Items:** Validate item exists in ItemDatabase before pickup
- **Inventory Full:** Handle inventory full gracefully (stop pulling, keep item in world)
- **Invalid Pickups:** Remove invalid pickups from active list

### Best Practices

- Use `push_error()` for critical errors (missing references, invalid items)
- Use `push_warning()` for non-critical issues (inventory full, pickup failed)
- Return false/null on errors (don't crash)
- Validate all inputs before operations
- Clean up invalid pickups automatically

---

## Default Values and Configuration

### ItemPickupManager Defaults

```gdscript
base_pickup_range = 50.0
currency_base_range = 100.0
pickup_check_interval = 0.1
```

### PickupableItem Defaults

```gdscript
quantity = 1
auto_pickup = true
pickup_range = 50.0  # Overridden by manager
pull_speed = 300.0
pull_easing = Tween.EASE_OUT
pull_transition = Tween.TRANS_CUBIC
```

---

## Performance Considerations

### Optimization Strategies

1. **Pickup Detection:**
   - Check pickups at intervals (not every frame)
   - Use spatial partitioning for large numbers of pickups
   - Limit active pickups checked per frame
   - Cull pickups outside viewport

2. **Animations:**
   - Limit active animations
   - Use object pooling for pickups
   - Reuse tweens when possible
   - Stop animations when pickup completes

3. **Range Calculations:**
   - Cache range calculations
   - Update range only when upgrades change
   - Use squared distance for comparisons (avoid sqrt)

4. **Memory Management:**
   - Remove pickups immediately after pickup
   - Clean up invalid pickups regularly
   - Limit active pickup count

---

## Testing Checklist

### Pickup System
- [ ] Items spawn correctly in world
- [ ] Pickup detection works correctly
- [ ] Range calculation works (base + upgrades)
- [ ] Currency has longer range
- [ ] Items pickup correctly

### Animation System
- [ ] Pull animation starts when in range
- [ ] Pull animation moves toward player
- [ ] Animation stops when out of range
- [ ] Animation completes when picked up
- [ ] Multiple items animate correctly

### Range Upgrades
- [ ] Range upgrades apply correctly
- [ ] Skill-based upgrades work
- [ ] Item-based upgrades work
- [ ] Range recalculates when upgrades change
- [ ] Multiple upgrades stack correctly

### Integration
- [ ] Integrates with Inventory System correctly
- [ ] Integrates with Item Database correctly
- [ ] Integrates with Player Controller correctly
- [ ] Integrates with Progression System correctly
- [ ] Save/load works correctly

---

## Complete Implementation

### ItemPickupManager Initialization

```gdscript
func _ready() -> void:
    # Get references
    inventory_manager = get_node_or_null("/root/InventoryManager")
    item_database = get_node_or_null("/root/ItemDatabase")
    progression_manager = get_node_or_null("/root/ProgressionManager")
    
    # Find player
    player = get_tree().get_first_node_in_group("player")
    
    # Initialize
    initialize()

func initialize() -> void:
    # Connect to progression system for skill updates
    if progression_manager:
        progression_manager.skill_purchased.connect(_on_skill_purchased)
    
    # Initialize range upgrades
    recalculate_range()

func _on_skill_purchased(skill: SkillNode) -> void:
    # Check if skill affects pickup range
    if skill.stat_bonuses.has("pickup_range"):
        update_range_from_skills()
```

### PickupableItem Scene Structure

```gdscript
# PickupableItem scene structure
# PickupableItem (Area2D)
# ├── Sprite2D (Item visual)
# ├── CollisionShape2D (Detection area)
# └── GlowEffect (Optional, Node2D)
#     └── Sprite2D (Glow sprite)
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scenes/
   │   └── items/
   │       └── PickupableItem.tscn
   └── scripts/
       ├── managers/
       │   └── ItemPickupManager.gd
       └── items/
           └── PickupableItem.gd
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/ItemPickupManager.gd` as `ItemPickupManager`
   - **Important:** Load after ItemDatabase and InventoryManager

3. **Create PickupableItem Scene:**
   - Create new scene with Area2D as root
   - Add Sprite2D child
   - Add CollisionShape2D child
   - Attach PickupableItem script
   - Save as `scenes/items/PickupableItem.tscn`

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. InventoryManager
4. ProgressionManager
5. **ItemPickupManager** (after all dependencies)

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Item Pickup System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Area2D:** https://docs.godotengine.org/en/stable/classes/class_area2d.html
- **Tween:** https://docs.godotengine.org/en/stable/classes/class_tween.html
- **CollisionShape2D:** https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Item Pickup System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Detection areas
- [Tween Documentation](https://docs.godotengine.org/en/stable/classes/class_tween.html) - Animation system
- [CollisionShape2D Documentation](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) - Collision shapes
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- PickupableItem is a scene (can be placed in editor)
- Pickup properties editable in inspector
- Range settings configurable

**Visual Configuration:**
- Sprite configurable in inspector
- Pickup range editable
- Animation settings configurable

**Editor Tools Needed:**
- **None Required:** Standard Godot scene system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Pickup range visualization (gizmo)
  - Animation preview
  - Range testing tool

**Current Approach:**
- Uses Godot's native scene system (no custom tools needed)
- PickupableItem created as scene (placeable in editor)
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Auto-Pickup Range:** Base range + upgrades, currency has longer base range
2. **Pull Animation:** Items move toward player when in range
3. **Range Upgrades:** Can upgrade range via skills/items
4. **Performance:** Check pickups at intervals, not every frame
5. **Visual Feedback:** Pull animation provides satisfying pickup feel
6. **Currency Priority:** Currency has longer range for better UX
7. **Inventory Integration:** Items added to inventory automatically
8. **Sound Effects:** Optional sound effects on pickup

