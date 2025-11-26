# Technical Specifications: Survival Systems

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the survival mechanics system including health, hunger, thirst, temperature, radiation, oxygen/air quality, and sleep/rest systems. This system integrates with ItemDatabase for food/consumable data and InventoryManager for item consumption.

---

## Research Notes

### Survival System Architecture Best Practices

**Research Findings:**
- Resource-based stats (SurvivalStats extends Resource) provides serialization
- Timed updates (every 0.1s) balance accuracy and performance
- Signal-based stat changes keep UI synchronized
- Environmental zones (Area2D) efficient for zone detection
- Status effects should integrate with dedicated StatusEffectsManager

**Sources:**
- [Godot 4 Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data structures
- [Godot 4 Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Zone detection
- [Godot 4 Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Event-driven architecture
- [Godot 4 Performance Best Practices](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Optimization guidelines

**Implementation Approach:**
- SurvivalStats as Resource for serialization
- Update loop every 0.1 seconds (configurable)
- Signal emissions for stat changes (health_changed, hunger_changed, etc.)
- Area2D zones for environmental detection
- Integration with StatusEffectsManager for status effects

**Why This Approach:**
- Resource system provides save/load support
- Timed updates reduce CPU usage
- Signals decouple UI from logic
- Area2D efficient for zone detection
- StatusEffectsManager handles complex effect logic

### Food/Consumable Integration

**Research Findings:**
- Food items should be stored as ItemData in ItemDatabase
- Consumable effects stored in ItemData.use_effect dictionary
- Item consumption should use InventoryManager
- Food freshness/spoilage tracked per item instance

**Sources:**
- ItemDatabase specification (already completed)
- InventoryManager specification (already completed)

**Implementation Approach:**
- Get food data from ItemDatabase.get_item(item_id)
- Read effects from ItemData.use_effect dictionary
- Consume via InventoryManager.remove_item()
- Track freshness in item instance metadata

**Why This Approach:**
- Single source of truth (ItemDatabase)
- Consistent with inventory system
- Freshness tracking per item instance
- Easy to add/modify consumables via resources

### Environmental System Best Practices

**Research Findings:**
- Biome-based environmental data efficient
- Zone detection via Area2D or spatial queries
- Temperature interpolation for smooth transitions
- Environmental effects should be configurable per biome

**Sources:**
- General game development best practices
- [Godot 4 Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Zone detection

**Implementation Approach:**
- Biome data stored in resources
- Area2D zones for radiation/toxic/temperature zones
- Temperature interpolation between zones
- Biome-specific environmental parameters

**Why This Approach:**
- Biome system provides variety
- Area2D efficient for zone detection
- Interpolation prevents sudden changes
- Configurable per biome allows variety

### Status Effects Integration

**Research Findings:**
- Status effects should use dedicated StatusEffectsManager
- Effects should apply stat modifiers and damage over time
- Effect stacking rules should be configurable
- Visual effects should be managed separately

**Sources:**
- StatusEffects specification (already completed)

**Implementation Approach:**
- Integrate with StatusEffectsManager for effect management
- SurvivalManager triggers effects based on conditions
- StatusEffectsManager handles effect logic and stacking

**Why This Approach:**
- Centralized effect management
- Consistent effect system across game
- Complex effect logic handled by dedicated system

---

## Data Structures

### SurvivalStats

```gdscript
class_name SurvivalStats
extends Resource

# Core Stats
@export var health: float = 100.0
@export var max_health: float = 100.0
@export var hunger: float = 100.0
@export var max_hunger: float = 100.0
@export var thirst: float = 100.0
@export var max_thirst: float = 100.0
@export var temperature: float = 20.0  # Celsius
@export var ideal_temperature_min: float = 18.0
@export var ideal_temperature_max: float = 25.0
@export var radiation: float = 0.0
@export var max_radiation: float = 100.0
@export var oxygen: float = 100.0
@export var max_oxygen: float = 100.0
@export var fatigue: float = 0.0
@export var max_fatigue: float = 100.0

# Status Effects
@export var status_effects: Array[StatusEffect] = []

# Depletion Rates (per second)
@export var hunger_depletion_rate: float = 0.5
@export var thirst_depletion_rate: float = 1.0
@export var fatigue_gain_rate: float = 0.3

# Temperature Effects
@export var heat_damage_threshold: float = 40.0
@export var cold_damage_threshold: float = 5.0
@export var temperature_damage_rate: float = 2.0  # damage per second when extreme

# Radiation Effects
@export var radiation_damage_threshold: float = 50.0
@export var radiation_damage_rate: float = 1.0  # damage per second when above threshold

# Functions
func apply_damage(amount: float) -> void
func heal(amount: float) -> void
func consume_food(hunger_value: float, thirst_value: float = 0.0) -> void
func drink_water(amount: float) -> void
func add_status_effect(effect: StatusEffect) -> void
func remove_status_effect(effect_type: String) -> void
func update_stats(delta: float, environmental_temp: float, in_radiation_zone: bool, in_toxic_zone: bool) -> void
func is_alive() -> bool
func get_health_percentage() -> float
```

### StatusEffect

```gdscript
class_name StatusEffect
extends Resource

@export var effect_type: String  # "poison", "radiation_sickness", "heat_stroke", "hypothermia", "dehydration", "starvation"
@export var duration: float  # seconds
@export var damage_per_second: float = 0.0
@export var stat_modifier: Dictionary = {}  # {"health": -5, "speed": 0.5}
@export var visual_effect: String = ""  # particle effect name
```

**Note:** Food items are stored in ItemDatabase as ItemData with ItemType.CONSUMABLE. Effects are stored in ItemData.use_effect dictionary. This system uses ItemDatabase.get_item(item_id) to retrieve food data.

### WaterSource

```gdscript
class_name WaterSource
extends Resource

@export var water_quality: String  # "clean", "dirty", "toxic"
@export var water_amount: float = -1.0  # -1 = infinite
@export var contamination_level: float = 0.0  # 0.0 = clean, 1.0 = toxic
```

---

## Core Classes

### SurvivalManager (Autoload Singleton)

```gdscript
class_name SurvivalManager
extends Node

# References
var player_stats: SurvivalStats
var inventory_manager: InventoryManager
var environment_manager: EnvironmentManager
var status_effects_manager: StatusEffectsManager  # Reference to StatusEffectsManager

# Timers
var update_timer: float = 0.0
var update_interval: float = 0.1  # Update every 0.1 seconds

# Configuration
const DEFAULT_UPDATE_INTERVAL: float = 0.1
const MIN_STAT_VALUE: float = 0.0

# Signals
signal health_changed(current: float, max: float)
signal hunger_changed(current: float, max: float)
signal thirst_changed(current: float, max: float)
signal temperature_changed(temperature: float)
signal radiation_changed(current: float, max: float)
signal oxygen_changed(current: float, max: float)
signal fatigue_changed(current: float, max: float)
signal stat_depleted(stat_name: String)  # "hunger", "thirst", "health"
signal player_died(cause: String)  # "starvation", "dehydration", "radiation", etc.

# Initialization
func _ready() -> void
func initialize() -> void

# Stat Management
func apply_damage(amount: float, source: String = "") -> void
func heal(amount: float) -> void
func restore_hunger(amount: float) -> void
func restore_thirst(amount: float) -> void
func restore_oxygen(amount: float) -> void
func reduce_fatigue(amount: float) -> void
func add_radiation(amount: float) -> void
func reduce_radiation(amount: float) -> void

# Item Consumption (Using ItemDatabase)
func consume_item(item_id: String) -> bool
func consume_item_by_data(item_data: ItemData) -> bool
func drink_from_source(source: WaterSource) -> bool
func rest_at_bed(bed: Node) -> void

# Environmental Effects
func update_survival_stats(delta: float) -> void
func apply_environmental_effects(delta: float) -> void
func apply_temperature_effects(delta: float, env_temp: float) -> void
func apply_radiation_effects(delta: float, in_zone: bool, radiation_level: float = 0.0) -> void
func apply_oxygen_effects(delta: float, in_toxic_zone: bool, has_mask: bool) -> void
func apply_starvation_effects(delta: float) -> void
func apply_dehydration_effects(delta: float) -> void

# Status Checks
func check_death_conditions() -> bool
func is_alive() -> bool
func get_stat_display_data() -> Dictionary
func get_stat_percentage(stat_name: String) -> float
```

### EnvironmentManager

```gdscript
class_name EnvironmentManager
extends Node

# Environmental Data
var current_temperature: float = 20.0
var is_radiation_zone: bool = false
var radiation_level: float = 0.0
var is_toxic_zone: bool = false
var toxic_level: float = 0.0
var is_underwater: bool = false
var water_pressure: float = 0.0

# Biome Data
var current_biome: String = "wasteland"
var biome_data: Dictionary = {}

# Functions
func _ready() -> void
func update_environment(player_position: Vector2) -> void
func get_temperature_at_position(pos: Vector2) -> float
func check_radiation_zone(pos: Vector2) -> bool
func check_toxic_zone(pos: Vector2) -> bool
func check_underwater(pos: Vector2) -> bool
func get_environmental_data() -> Dictionary
```

---

## System Architecture

### Component Hierarchy

```
SurvivalManager (Node)
├── SurvivalStats (Resource)
├── EnvironmentManager (Node)
│   ├── BiomeDetector (Area2D)
│   ├── TemperatureZone (Area2D)
│   ├── RadiationZone (Area2D)
│   └── ToxicZone (Area2D)
├── StatusEffectManager (Node)
│   └── StatusEffect[] (Array)
└── UI/SurvivalHUD (Control)
    ├── HealthBar (ProgressBar)
    ├── HungerBar (ProgressBar)
    ├── ThirstBar (ProgressBar)
    ├── TemperatureIndicator (Control)
    ├── RadiationMeter (ProgressBar)
    └── StatusEffectDisplay (Control)
```

### Data Flow

1. **Update Loop:**
   ```
   SurvivalManager._process(delta)
   ├── EnvironmentManager.update_environment(player_pos)
   ├── update_survival_stats(delta)
   │   ├── apply_environmental_effects(delta)
   │   ├── apply_temperature_effects(delta, env_temp)
   │   ├── apply_radiation_effects(delta, in_zone)
   │   └── apply_oxygen_effects(delta, toxic_zone, has_mask)
   ├── update_status_effects(delta)
   └── check_death_conditions()
   ```

2. **Item Consumption:**
   ```
   Player consumes item
   ├── SurvivalManager.consume_item(item)
   ├── Validate item (is food? is fresh?)
   ├── Apply effects (hunger, thirst, health)
   ├── Remove from inventory
   └── Update UI
   ```

3. **Environmental Effects:**
   ```
   Player enters zone
   ├── EnvironmentManager detects zone
   ├── Update environmental flags
   ├── Apply effects to SurvivalStats
   └── Update UI indicators
   ```

---

## Algorithms

### Temperature Calculation

```gdscript
func apply_temperature_effects(delta: float, env_temp: float) -> void:
    var temp_diff: float = env_temp - player_stats.temperature
    var heat_transfer_rate: float = 0.5  # How fast temp changes
    
    # Update player temperature
    player_stats.temperature += temp_diff * heat_transfer_rate * delta
    
    # Check for damage thresholds
    if player_stats.temperature > player_stats.heat_damage_threshold:
        var damage: float = player_stats.temperature_damage_rate * delta
        player_stats.apply_damage(damage)
        if not has_status_effect("heat_stroke"):
            add_status_effect(create_status_effect("heat_stroke", 10.0))
    
    elif player_stats.temperature < player_stats.cold_damage_threshold:
        var damage: float = player_stats.temperature_damage_rate * delta
        player_stats.apply_damage(damage)
        if not has_status_effect("hypothermia"):
            add_status_effect(create_status_effect("hypothermia", 10.0))
```

### Hunger/Thirst Depletion

```gdscript
func update_survival_stats(delta: float) -> void:
    # Base depletion
    player_stats.hunger -= player_stats.hunger_depletion_rate * delta
    player_stats.thirst -= player_stats.thirst_depletion_rate * delta
    
    # Clamp values
    player_stats.hunger = clamp(player_stats.hunger, 0.0, player_stats.max_hunger)
    player_stats.thirst = clamp(player_stats.thirst, 0.0, player_stats.max_thirst)
    
    # Apply starvation effects
    if player_stats.hunger <= 0.0:
        player_stats.apply_damage(player_stats.starvation_damage_rate * delta)
        if not has_status_effect("starvation"):
            add_status_effect(create_status_effect("starvation", -1.0))
    
    # Apply dehydration effects
    if player_stats.thirst <= 0.0:
        player_stats.apply_damage(player_stats.dehydration_damage_rate * delta)
        if not has_status_effect("dehydration"):
            add_status_effect(create_status_effect("dehydration", -1.0))
```

### Status Effect System

```gdscript
func update_status_effects(delta: float) -> void:
    var effects_to_remove: Array[StatusEffect] = []
    
    for effect in player_stats.status_effects:
        effect.duration -= delta
        
        # Apply damage
        if effect.damage_per_second > 0.0:
            player_stats.apply_damage(effect.damage_per_second * delta)
        
        # Apply stat modifiers
        for stat_name in effect.stat_modifier:
            var modifier: float = effect.stat_modifier[stat_name]
            # Apply modifier to appropriate stat
        
        # Check if effect expired
        if effect.duration <= 0.0 and effect.duration != -1.0:
            effects_to_remove.append(effect)
    
    # Remove expired effects
    for effect in effects_to_remove:
        player_stats.status_effects.erase(effect)
        remove_visual_effect(effect.visual_effect)
```

---

## Integration Points

### Item Consumption Algorithm (Using ItemDatabase and InventoryManager)

```gdscript
func consume_item(item_id: String) -> bool:
    # Get item data from ItemDatabase
    var item_data = ItemDatabase.get_item(item_id)
    if item_data == null:
        push_error("SurvivalManager: Item not found: " + item_id)
        return false
    
    if item_data.item_type != ItemData.ItemType.CONSUMABLE:
        push_warning("SurvivalManager: Item is not consumable: " + item_id)
        return false
    
    return consume_item_by_data(item_data)

func consume_item_by_data(item_data: ItemData) -> bool:
    if item_data == null:
        return false
    
    # Check if player has item in inventory
    if not InventoryManager.has_item_quantity(item_data.item_id, 1):
        return false
    
    # Remove item from inventory
    var removed = InventoryManager.remove_item(item_data.item_id, 1)
    if removed < 1:
        return false
    
    # Apply effects from use_effect dictionary
    if item_data.use_effect.has("hunger"):
        restore_hunger(item_data.use_effect["hunger"])
    
    if item_data.use_effect.has("thirst"):
        restore_thirst(item_data.use_effect["thirst"])
    
    if item_data.use_effect.has("health"):
        heal(item_data.use_effect["health"])
    
    if item_data.use_effect.has("stamina"):
        # Restore stamina (if stamina system exists)
        if player_stats.has("stamina"):
            player_stats.stamina = min(player_stats.max_stamina, player_stats.stamina + item_data.use_effect["stamina"])
    
    # Apply status effects if specified
    if item_data.use_effect.has("status_effects") and StatusEffectsManager:
        var effects = item_data.use_effect["status_effects"] as Array
        for effect_data in effects:
            StatusEffectsManager.apply_effect(effect_data)
    
    return true
```

### With Player Controller

```gdscript
# Player controller needs to check survival stats
func can_perform_action(action_cost: float) -> bool:
    if survival_manager.player_stats.fatigue >= survival_manager.player_stats.max_fatigue:
        return false
    if survival_manager.player_stats.health <= 0.0:
        return false
    return true
```

### With World System

```gdscript
# EnvironmentManager queries world for zone data
func update_environment(player_position: Vector2) -> void:
    var chunk: Chunk = world_manager.get_chunk_at_position(player_position)
    current_temperature = chunk.get_temperature()
    is_radiation_zone = chunk.is_radiation_zone()
    radiation_level = chunk.get_radiation_level()
    is_toxic_zone = chunk.is_toxic_zone()
    toxic_level = chunk.get_toxic_level()
```

---

## UI Integration

### SurvivalHUD

```gdscript
class_name SurvivalHUD
extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var hunger_bar: ProgressBar = $HungerBar
@onready var thirst_bar: ProgressBar = $ThirstBar
@onready var temperature_indicator: Control = $TemperatureIndicator
@onready var radiation_meter: ProgressBar = $RadiationMeter
@onready var status_effects_container: VBoxContainer = $StatusEffectsContainer

var survival_manager: SurvivalManager

func _ready() -> void:
    survival_manager = get_node("/root/SurvivalManager")

func _process(delta: float) -> void:
    update_bars()
    update_temperature_indicator()
    update_status_effects()

func update_bars() -> void:
    var stats: SurvivalStats = survival_manager.player_stats
    health_bar.value = stats.get_health_percentage()
    hunger_bar.value = (stats.hunger / stats.max_hunger) * 100.0
    thirst_bar.value = (stats.thirst / stats.max_thirst) * 100.0
    radiation_meter.value = (stats.radiation / stats.max_radiation) * 100.0

func update_temperature_indicator() -> void:
    var temp: float = survival_manager.player_stats.temperature
    var color: Color
    if temp < 10.0:
        color = Color.CYAN  # Cold
    elif temp > 35.0:
        color = Color.RED  # Hot
    else:
        color = Color.WHITE  # Normal
    temperature_indicator.modulate = color
```

---

## Save/Load System

### Save Data Structure

```gdscript
var survival_save_data: Dictionary = {
    "health": player_stats.health,
    "max_health": player_stats.max_health,
    "hunger": player_stats.hunger,
    "thirst": player_stats.thirst,
    "temperature": player_stats.temperature,
    "radiation": player_stats.radiation,
    "oxygen": player_stats.oxygen,
    "fatigue": player_stats.fatigue,
    "status_effects": serialize_status_effects()
}

func serialize_status_effects() -> Array:
    var serialized: Array = []
    for effect in player_stats.status_effects:
        serialized.append({
            "type": effect.effect_type,
            "duration": effect.duration,
            "damage_per_second": effect.damage_per_second,
            "stat_modifier": effect.stat_modifier
        })
    return serialized
```

---

## Error Handling

### SurvivalManager Error Handling

- **Invalid Item IDs:** Check ItemDatabase before consumption, return errors gracefully
- **Missing Items:** Check InventoryManager before consumption, prevent consumption if not available
- **Invalid Stat Values:** Clamp stats to valid ranges (0.0 to max)
- **Death Conditions:** Handle death gracefully, emit signal, trigger death screen
- **Environmental Zones:** Handle missing zone data gracefully

### Best Practices

- Use `push_error()` for critical errors (invalid item_id, missing ItemDatabase)
- Use `push_warning()` for non-critical issues (low stats, missing items)
- Clamp all stat values to valid ranges
- Emit signals for stat changes (UI updates)
- Handle death via signal (don't crash)

---

## Default Values and Configuration

### SurvivalStats Defaults

```gdscript
# Core Stats
health = 100.0
max_health = 100.0
hunger = 100.0
max_hunger = 100.0
thirst = 100.0
max_thirst = 100.0
temperature = 20.0  # Celsius
ideal_temperature_min = 18.0
ideal_temperature_max = 25.0
radiation = 0.0
max_radiation = 100.0
oxygen = 100.0
max_oxygen = 100.0
fatigue = 0.0
max_fatigue = 100.0

# Depletion Rates (per second)
hunger_depletion_rate = 0.5
thirst_depletion_rate = 1.0
fatigue_gain_rate = 0.3

# Temperature Effects
heat_damage_threshold = 40.0
cold_damage_threshold = 5.0
temperature_damage_rate = 2.0

# Radiation Effects
radiation_damage_threshold = 50.0
radiation_damage_rate = 1.0

# Starvation/Dehydration
starvation_damage_rate = 1.0  # damage per second
dehydration_damage_rate = 2.0  # damage per second
```

### SurvivalManager Defaults

```gdscript
update_interval = 0.1  # Update every 0.1 seconds
MIN_STAT_VALUE = 0.0
```

### EnvironmentManager Defaults

```gdscript
current_temperature = 20.0
is_radiation_zone = false
radiation_level = 0.0
is_toxic_zone = false
toxic_level = 0.0
is_underwater = false
water_pressure = 0.0
current_biome = "wasteland"
```

---

## Performance Considerations

1. **Update Frequency:** Update survival stats every 0.1 seconds, not every frame
2. **Status Effects:** Limit maximum concurrent status effects
3. **UI Updates:** Only update UI when values change significantly (>1%)
4. **Environmental Checks:** Cache biome/zone data, only recalculate when player moves chunks
5. **Object Pooling:** Reuse status effect objects instead of creating new ones

---

## Testing Checklist

- [ ] Health depletion and restoration
- [ ] Hunger/thirst depletion over time
- [ ] Food consumption restores stats correctly
- [ ] Temperature effects apply correctly
- [ ] Radiation damage when in radiation zones
- [ ] Oxygen depletion underwater
- [ ] Status effects apply and expire correctly
- [ ] Death conditions trigger correctly
- [ ] UI updates reflect stat changes
- [ ] Save/load preserves all stats
- [ ] Performance is acceptable (60+ FPS)

### Integration
- [ ] Integrates with ItemDatabase correctly
- [ ] Integrates with InventoryManager correctly
- [ ] Integrates with StatusEffectsManager correctly
- [ ] Integrates with CombatManager (health) correctly

### Edge Cases
- [ ] Invalid item IDs handled
- [ ] Missing items handled
- [ ] Stat values clamped correctly
- [ ] Death conditions trigger correctly
- [ ] Environmental zone transitions smooth

---

## Complete Implementation

### SurvivalStats Complete Implementation

```gdscript
class_name SurvivalStats
extends Resource

# Core Stats
@export var health: float = 100.0
@export var max_health: float = 100.0
@export var hunger: float = 100.0
@export var max_hunger: float = 100.0
@export var thirst: float = 100.0
@export var max_thirst: float = 100.0
@export var temperature: float = 20.0
@export var ideal_temperature_min: float = 18.0
@export var ideal_temperature_max: float = 25.0
@export var radiation: float = 0.0
@export var max_radiation: float = 100.0
@export var oxygen: float = 100.0
@export var max_oxygen: float = 100.0
@export var fatigue: float = 0.0
@export var max_fatigue: float = 100.0

# Depletion Rates
@export var hunger_depletion_rate: float = 0.5
@export var thirst_depletion_rate: float = 1.0
@export var fatigue_gain_rate: float = 0.3

# Temperature Effects
@export var heat_damage_threshold: float = 40.0
@export var cold_damage_threshold: float = 5.0
@export var temperature_damage_rate: float = 2.0

# Radiation Effects
@export var radiation_damage_threshold: float = 50.0
@export var radiation_damage_rate: float = 1.0

# Starvation/Dehydration
@export var starvation_damage_rate: float = 1.0
@export var dehydration_damage_rate: float = 2.0

func apply_damage(amount: float) -> void:
    health = max(0.0, health - amount)
    health = min(health, max_health)

func heal(amount: float) -> void:
    health = min(max_health, health + amount)

func consume_food(hunger_value: float, thirst_value: float = 0.0) -> void:
    restore_hunger(hunger_value)
    restore_thirst(thirst_value)

func restore_hunger(amount: float) -> void:
    hunger = min(max_hunger, hunger + amount)

func restore_thirst(amount: float) -> void:
    thirst = min(max_thirst, thirst + amount)

func drink_water(amount: float) -> void:
    restore_thirst(amount)

func is_alive() -> bool:
    return health > 0.0

func get_health_percentage() -> float:
    if max_health <= 0.0:
        return 0.0
    return (health / max_health) * 100.0
```

### SurvivalManager Initialization

```gdscript
func _ready() -> void:
    # Wait for dependencies
    if ItemDatabase.items.is_empty():
        ItemDatabase.item_database_loaded.connect(_on_database_loaded)
    else:
        initialize()
    
    if InventoryManager == null:
        InventoryManager = get_node("/root/InventoryManager")
    
    if StatusEffectsManager:
        StatusEffectsManager = get_node("/root/StatusEffectsManager")

func _on_database_loaded() -> void:
    initialize()

func initialize() -> void:
    # Create SurvivalStats if not set
    if player_stats == null:
        player_stats = SurvivalStats.new()
    
    # Initialize environment manager if not set
    if environment_manager == null:
        environment_manager = EnvironmentManager.new()
        add_child(environment_manager)
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       ├── SurvivalManager.gd
   │       └── EnvironmentManager.gd
   └── resources/
       └── survival/
           └── (survival config resources if needed)
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/SurvivalManager.gd` as `SurvivalManager`
   - **Important:** Load after ItemDatabase, InventoryManager, StatusEffectsManager

3. **Create SurvivalStats Resource:**
   - Create SurvivalStats resource in code or as .tres file
   - Configure default values
   - Assign to SurvivalManager.player_stats

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. InventoryManager
4. StatusEffectsManager
5. **SurvivalManager** (after all dependencies)

### Consumable Item Setup

**Food ItemData Setup:**
1. Create ItemData resource with ItemType.CONSUMABLE
2. Set use_action (e.g., "eat", "drink")
3. Set use_effect dictionary:
   - `hunger`: Hunger restore value
   - `thirst`: Thirst restore value
   - `health`: Health restore value
   - `stamina`: Stamina restore value (optional)
   - `status_effects`: Array of status effects (optional)

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Survival System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Resource System:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **Area2D:** https://docs.godotengine.org/en/stable/classes/class_area2d.html
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Survival System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data structures
- [Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Zone detection
- [Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Event-driven architecture
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- SurvivalStats is a Resource class (editable in inspector)
- EnvironmentManager is a Node (can be added to scene)
- All stats configurable via Resource properties

**Visual Configuration:**
- SurvivalStats resources created in FileSystem, edited in Inspector
- Environmental zones placed visually in scene (Area2D nodes)

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Survival stats editor with live preview
  - Environmental zone visualizer
  - Biome editor
  - Status effect tester

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Stats configured via SurvivalStats resource
- Zones placed visually in scene
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Item Database Integration:** Uses `ItemDatabase.get_item(item_id)` for consumable data, reads effects from `ItemData.use_effect` dictionary
2. **Inventory Integration:** Uses `InventoryManager.remove_item()` for item consumption, `InventoryManager.has_item_quantity()` for checking
3. **Status Effects Integration:** Uses `StatusEffectsManager` for status effect management
4. **Update Frequency:** Updates every 0.1 seconds (configurable) for performance
5. **Environmental Zones:** Area2D nodes detect radiation/toxic/temperature zones
6. **Temperature System:** Interpolates between environmental temperature and player temperature
7. **Death System:** Emits `player_died` signal with cause, triggers death screen
8. **Stat Clamping:** All stats clamped to valid ranges (0.0 to max)
9. **Signal-Based Updates:** Signals emitted for all stat changes (UI synchronization)
10. **Performance:** Timed updates reduce CPU usage, environmental checks cached

---

