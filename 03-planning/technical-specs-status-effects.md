# Technical Specifications: Status Effects System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the comprehensive status effects system supporting buffs, debuffs, per-effect-type stacking rules, combat effects, multiple curing methods, effect interactions, stat modifiers, and full source tracking. This system integrates with CombatManager, SurvivalManager, InventoryManager, and all systems that apply or are affected by status effects.

---

## Research Notes

### Status Effects System Architecture Best Practices

**Research Findings:**
- Status effects use instance-based system for runtime tracking
- Stacking rules determine how effects interact when reapplied
- Stat modifiers calculated from all active effects
- Source tracking enables effect removal by source
- Effect interactions enable cancelling conflicting effects

**Sources:**
- [Godot 4 Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Godot 4 Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data storage
- General status effect system patterns

**Implementation Approach:**
- StatusEffectManager as autoload singleton
- StatusEffect as Resource (effect configuration)
- StatusEffectInstance for runtime tracking
- Stacking rules per effect type
- Hybrid stat modifier calculation (flat + percentage)
- Source tracking for all effects

**Why This Approach:**
- Singleton: centralized effect management
- Resources: easy to create/edit effects in editor
- Instances: track runtime state per target
- Stacking rules: flexible effect interactions
- Hybrid calculation: supports both flat and percentage modifiers
- Source tracking: enables source-based removal

### Stacking Rules Best Practices

**Research Findings:**
- Multiple stacking rules needed (refresh, extend, stack, replace)
- Stacking rules prevent effect spam
- Stack intensity allows effect scaling
- Replace if stronger prevents weaker effects overriding stronger ones

**Sources:**
- General stacking system patterns

**Implementation Approach:**
- StackingRule enum: REFRESH_DURATION, EXTEND_DURATION, STACK_INTENSITY, REPLACE_IF_STRONGER
- Per-effect stacking configuration
- Stack count tracking for intensity stacking
- Max stacks limit prevents infinite stacking

**Why This Approach:**
- Multiple rules: flexible effect design
- Per-effect: each effect has its own stacking behavior
- Stack count: tracks intensity for stacking effects
- Max stacks: prevents overpowered stacking

### Stat Modifier Calculation Best Practices

**Research Findings:**
- Flat and percentage modifiers calculated separately
- Percentage modifiers apply to base + flat modifiers
- Multiple effects combine additively (flat) and multiplicatively (percentage)
- Stat modifiers affect all stats (health, speed, damage, etc.)

**Sources:**
- General stat modifier calculation patterns

**Implementation Approach:**
- Separate flat and percentage modifiers
- Calculate: (base + flat_sum) * (1 + percentage_sum)
- All stats modifiable via stat_modifiers dictionary
- Modifier types dictionary specifies flat vs percentage

**Why This Approach:**
- Separate calculation: correct modifier math
- All stats: flexible effect design
- Dictionary: easy to configure
- Type specification: clear modifier behavior

### Effect Interactions Best Practices

**Research Findings:**
- Effects can cancel other effects
- Effect interactions enable strategic gameplay
- Source tracking enables removing effects by source
- Multiple curing methods (items, actions, time)

**Sources:**
- General effect interaction patterns

**Implementation Approach:**
- cancels_effects array: effects this cancels
- cancelled_by_effects array: effects that cancel this
- Source tracking: track source type and ID
- Cure items/actions: multiple curing methods

**Why This Approach:**
- Cancellation: strategic effect interactions
- Source tracking: enables source-based removal
- Multiple cures: flexible curing options
- Arrays: easy to configure interactions

---

## Data Structures

### EffectCategory

```gdscript
enum EffectCategory {
    BUFF,      # Positive effects
    DEBUFF     # Negative effects
}
```

### StackingRule

```gdscript
enum StackingRule {
    REFRESH_DURATION,  # New application resets timer to full duration
    EXTEND_DURATION,   # New application adds to remaining duration (capped)
    STACK_INTENSITY,   # Multiple instances stack, combine effects
    REPLACE_IF_STRONGER # Replace only if new effect is stronger
}
```

### EffectSourceType

```gdscript
enum EffectSourceType {
    WEAPON,        # Applied by weapon/attack
    ENEMY,         # Applied by enemy
    ITEM,          # Applied by consumable item
    ENVIRONMENTAL, # Applied by environment (radiation, poison gas, etc.)
    PLAYER_ACTION, # Applied by player action (resting, eating, etc.)
    OTHER          # Other sources
}
```

### StatusEffect

```gdscript
class_name StatusEffect
extends Resource

# Identification
@export var effect_id: String  # Unique identifier
@export var effect_name: String  # Display name
@export var effect_type: String  # "poison", "burn", "speed_boost", etc.
@export var category: EffectCategory
@export var description: String = ""

# Duration
@export var duration: float = -1.0  # -1 = permanent until removed
@export var max_duration: float = -1.0  # Max duration when extending (-1 = no cap)

# Stacking
@export var stacking_rule: StackingRule = StackingRule.REFRESH_DURATION
@export var max_stacks: int = 1  # Maximum stacks (for STACK_INTENSITY)
@export var stack_intensity_multiplier: float = 1.0  # Intensity per stack

# Damage Over Time
@export var damage_per_second: float = 0.0
@export var damage_type: String = "physical"  # "physical", "fire", "poison", etc.

# Stat Modifiers (all stats modifiable)
@export var stat_modifiers: Dictionary = {}  # stat_name -> modifier_value
# Examples:
# {"speed": 10.0} - flat bonus
# {"speed": 0.2} - percentage bonus (20%)
# {"damage": -5.0} - flat reduction
# {"max_health": 0.1} - percentage increase (10%)

# Modifier Types
@export var modifier_types: Dictionary = {}  # stat_name -> "flat" or "percentage"

# Visual/Audio
@export var icon: Texture2D = null
@export var visual_effect: String = ""  # Particle effect name
@export var color_tint: Color = Color.WHITE  # Color overlay
@export var sound_effect: AudioStream = null  # Sound when applied

# Interactions
@export var cancels_effects: Array[String] = []  # Effect IDs this cancels
@export var cancelled_by_effects: Array[String] = []  # Effect IDs that cancel this

# Curing
@export var cure_items: Array[String] = []  # Item IDs that cure this
@export var cure_actions: Array[String] = []  # Actions that cure this ("rest", "water", etc.)

# Source Tracking (Runtime)
var source_type: EffectSourceType = EffectSourceType.OTHER
var source_id: String = ""  # Weapon ID, enemy ID, item ID, etc.
var source_name: String = ""  # Display name of source

# Runtime State
var remaining_duration: float = 0.0
var stack_count: int = 1
var applied_time: float = 0.0
var is_active: bool = true

# Functions
func apply_modifier(stat_name: String, base_value: float) -> float
func get_total_damage_per_second() -> float
func can_stack_with(other: StatusEffect) -> bool
func merge_with(other: StatusEffect) -> void
func is_expired() -> bool
func get_time_remaining() -> float
```

### StatusEffectInstance

```gdscript
class_name StatusEffectInstance
extends RefCounted

var effect_data: StatusEffect
var target: Node2D  # Entity with the effect
var remaining_duration: float
var stack_count: int = 1
var applied_time: float
var source_type: EffectSourceType
var source_id: String
var source_name: String

func _init(effect: StatusEffect, target_entity: Node2D):
    effect_data = effect
    target = target_entity
    remaining_duration = effect.duration
    applied_time = Time.get_ticks_msec() / 1000.0

func update(delta: float) -> void
func apply_stat_modifiers() -> void
func apply_damage(delta: float) -> void
func can_stack_with(other: StatusEffectInstance) -> bool
func merge_with(other: StatusEffectInstance) -> void
func is_expired() -> bool
func remove() -> void
```

---

## Core Classes

### StatusEffectManager (Autoload Singleton)

```gdscript
class_name StatusEffectManager
extends Node

# References
@export var survival_manager: SurvivalManager
@export var combat_manager: CombatManager
@export var inventory_manager: InventoryManager

# Effect Registry
var effect_registry: Dictionary = {}  # effect_id -> StatusEffect

# Active Effects (by target)
var active_effects: Dictionary = {}  # target_id -> Array[StatusEffectInstance]

# Settings
@export var update_interval: float = 0.1  # Update every 0.1 seconds

# Signals
signal effect_applied(target: Node2D, effect: StatusEffect, instance: StatusEffectInstance)
signal effect_removed(target: Node2D, effect: StatusEffect, instance: StatusEffectInstance)
signal effect_expired(target: Node2D, effect: StatusEffect, instance: StatusEffectInstance)
signal effect_stacked(target: Node2D, effect: StatusEffect, new_stack_count: int)

# Functions
func _ready() -> void
func _process(delta: float) -> void
func register_effect(effect: StatusEffect) -> void
func apply_effect(target: Node2D, effect_id: String, source_type: EffectSourceType, source_id: String = "", source_name: String = "") -> StatusEffectInstance
func remove_effect(target: Node2D, effect_id: String) -> bool
func remove_effect_by_source(target: Node2D, source_type: EffectSourceType, source_id: String) -> void
func has_effect(target: Node2D, effect_id: String) -> bool
func get_effect_instance(target: Node2D, effect_id: String) -> StatusEffectInstance
func get_all_effects(target: Node2D) -> Array[StatusEffectInstance]
func get_effects_by_category(target: Node2D, category: EffectCategory) -> Array[StatusEffectInstance]
func cure_effect(target: Node2D, effect_id: String, cure_method: String) -> bool
func update_effects(target: Node2D, delta: float) -> void
func calculate_stat_modifier(target: Node2D, stat_name: String, base_value: float) -> float
func check_effect_interactions(target: Node2D, new_effect: StatusEffect) -> void
```

### StatusEffectApplier

```gdscript
class_name StatusEffectApplier
extends RefCounted

static func apply_effect_from_weapon(target: Node2D, weapon_id: String, effect_id: String, chance: float = 1.0) -> bool:
    if randf() > chance:
        return false
    
    var weapon_data = ItemDatabase.get_item(weapon_id)
    if weapon_data == null:
        return false
    
    var effect = StatusEffectManager.effect_registry.get(effect_id)
    if effect == null:
        return false
    
    var instance = StatusEffectManager.apply_effect(
        target,
        effect_id,
        EffectSourceType.WEAPON,
        weapon_id,
        weapon_data.item_name
    )
    
    return instance != null

static func apply_effect_from_enemy(target: Node2D, enemy_id: String, effect_id: String) -> bool:
    var effect = StatusEffectManager.effect_registry.get(effect_id)
    if effect == null:
        return false
    
    var enemy = EnemyManager.get_enemy(enemy_id)
    var enemy_name = enemy.enemy_name if enemy else enemy_id
    
    var instance = StatusEffectManager.apply_effect(
        target,
        effect_id,
        EffectSourceType.ENEMY,
        enemy_id,
        enemy_name
    )
    
    return instance != null

static func apply_effect_from_item(target: Node2D, item_id: String, effect_id: String) -> bool:
    var item_data = ItemDatabase.get_item(item_id)
    if item_data == null:
        return false
    
    var effect = StatusEffectManager.effect_registry.get(effect_id)
    if effect == null:
        return false
    
    var instance = StatusEffectManager.apply_effect(
        target,
        effect_id,
        EffectSourceType.ITEM,
        item_id,
        item_data.item_name
    )
    
    return instance != null
```

---

## System Architecture

### Component Hierarchy

```
StatusEffectManager (Autoload Singleton)
├── StatusEffectApplier (utility)
├── StatusEffectInstance (runtime data)
└── StatusEffect (resource data)
```

### Data Flow

1. **Effect Application:**
   - Source applies effect → `StatusEffectManager.apply_effect()` called
   - Check for existing effect → Check stacking rules
   - Apply or merge → Create new instance or merge with existing
   - Check interactions → Cancel conflicting effects
   - Apply to target → Add to active_effects
   - Emit signal → `effect_applied` signal

2. **Effect Update:**
   - Each frame → `StatusEffectManager._process(delta)` called
   - For each target → `update_effects(target, delta)` called
   - Update duration → Decrease remaining_duration
   - Apply damage → Apply DoT damage
   - Apply modifiers → Calculate stat modifiers
   - Check expiration → Remove expired effects

3. **Effect Removal:**
   - Duration expires → `remove_effect()` called
   - Cured by item/action → `cure_effect()` called
   - Cancelled by interaction → `check_effect_interactions()` removes
   - Removed → Clean up instance, emit signal

---

## Algorithms

### Apply Effect Algorithm

```gdscript
func apply_effect(target: Node2D, effect_id: String, source_type: EffectSourceType, source_id: String = "", source_name: String = "") -> StatusEffectInstance:
    # Get effect data
    if not effect_registry.has(effect_id):
        push_error("StatusEffectManager: Effect not found: " + effect_id)
        return null
    
    var effect_data = effect_registry[effect_id]
    
    # Get target ID
    var target_id = get_target_id(target)
    if target_id.is_empty():
        return null
    
    # Check for existing effect
    var existing_instance = get_effect_instance(target, effect_id)
    
    if existing_instance != null:
        # Handle stacking based on rule
        return handle_stacking(target, existing_instance, effect_data, source_type, source_id, source_name)
    else:
        # Check interactions (cancel conflicting effects)
        check_effect_interactions(target, effect_data)
        
        # Create new instance
        var instance = StatusEffectInstance.new(effect_data, target)
        instance.source_type = source_type
        instance.source_id = source_id
        instance.source_name = source_name
        
        # Add to active effects
        if not active_effects.has(target_id):
            active_effects[target_id] = []
        active_effects[target_id].append(instance)
        
        # Apply visual/audio effects
        apply_visual_effects(target, effect_data)
        play_sound_effect(effect_data.sound_effect)
        
        emit_signal("effect_applied", target, effect_data, instance)
        return instance
```

### Stacking Handler Algorithm

```gdscript
func handle_stacking(target: Node2D, existing: StatusEffectInstance, new_effect: StatusEffect, source_type: EffectSourceType, source_id: String, source_name: String) -> StatusEffectInstance:
    match new_effect.stacking_rule:
        StackingRule.REFRESH_DURATION:
            # Reset duration to full
            existing.remaining_duration = new_effect.duration
            existing.applied_time = Time.get_ticks_msec() / 1000.0
            return existing
        
        StackingRule.EXTEND_DURATION:
            # Add to remaining duration (capped at max)
            var new_duration = existing.remaining_duration + new_effect.duration
            if new_effect.max_duration > 0:
                new_duration = min(new_duration, new_effect.max_duration)
            existing.remaining_duration = new_duration
            return existing
        
        StackingRule.STACK_INTENSITY:
            # Stack if under max stacks
            if existing.stack_count < new_effect.max_stacks:
                existing.stack_count += 1
                emit_signal("effect_stacked", target, new_effect, existing.stack_count)
            return existing
        
        StackingRule.REPLACE_IF_STRONGER:
            # Compare strength (damage or modifier value)
            var existing_strength = existing.effect_data.damage_per_second
            var new_strength = new_effect.damage_per_second
            
            if new_strength > existing_strength:
                # Remove old, apply new
                remove_effect(target, existing.effect_data.effect_id)
                return apply_effect(target, new_effect.effect_id, source_type, source_id, source_name)
            else:
                # Keep existing
                return existing
    
    return existing
```

### Stat Modifier Calculation Algorithm

```gdscript
func calculate_stat_modifier(target: Node2D, stat_name: String, base_value: float) -> float:
    var target_id = get_target_id(target)
    if not active_effects.has(target_id):
        return base_value
    
    var effects = active_effects[target_id]
    var buffs: Array[StatusEffectInstance] = []
    var debuffs: Array[StatusEffectInstance] = []
    
    # Separate buffs and debuffs
    for instance in effects:
        if instance.effect_data.stat_modifiers.has(stat_name):
            if instance.effect_data.category == EffectCategory.BUFF:
                buffs.append(instance)
            else:
                debuffs.append(instance)
    
    var result = base_value
    
    # Apply buffs (additive)
    var total_buff = 0.0
    var total_buff_percent = 0.0
    
    for instance in buffs:
        var modifier = instance.effect_data.stat_modifiers[stat_name]
        var modifier_type = instance.effect_data.modifier_types.get(stat_name, "flat")
        
        if modifier_type == "flat":
            total_buff += modifier * instance.stack_count
        else:  # percentage
            total_buff_percent += modifier * instance.stack_count
    
    result += total_buff
    result *= (1.0 + total_buff_percent)
    
    # Apply debuffs (multiplicative)
    for instance in debuffs:
        var modifier = instance.effect_data.stat_modifiers[stat_name]
        var modifier_type = instance.effect_data.modifier_types.get(stat_name, "flat")
        
        if modifier_type == "flat":
            result -= modifier * instance.stack_count
        else:  # percentage
            result *= (1.0 - modifier * instance.stack_count)
    
    return max(0.0, result)  # Ensure non-negative
```

### Effect Interaction Check Algorithm

```gdscript
func check_effect_interactions(target: Node2D, new_effect: StatusEffect) -> void:
    var target_id = get_target_id(target)
    if not active_effects.has(target_id):
        return
    
    var effects_to_remove: Array[StatusEffectInstance] = []
    
    # Check if new effect cancels existing effects
    for cancel_id in new_effect.cancels_effects:
        var instance = get_effect_instance(target, cancel_id)
        if instance:
            effects_to_remove.append(instance)
    
    # Check if existing effects cancel new effect
    for instance in active_effects[target_id]:
        if new_effect.effect_id in instance.effect_data.cancels_effects:
            # New effect is cancelled, don't apply
            return
    
    # Remove cancelled effects
    for instance in effects_to_remove:
        remove_effect(target, instance.effect_data.effect_id)
```

### Update Effects Algorithm (Integrates with CombatManager and SurvivalManager)

```gdscript
func update_effects(target: Node2D, delta: float) -> void:
    var target_id = get_target_id(target)
    if not active_effects.has(target_id):
        return
    
    var effects = active_effects[target_id]
    var effects_to_remove: Array[StatusEffectInstance] = []
    
    for instance in effects:
        if not instance.is_active:
            continue
        
        # Update duration
        if instance.effect_data.duration > 0:
            instance.remaining_duration -= delta
            if instance.remaining_duration <= 0:
                effects_to_remove.append(instance)
                continue
        
        # Apply damage over time (via CombatManager or SurvivalManager)
        if instance.effect_data.damage_per_second > 0:
            var total_damage = instance.effect_data.damage_per_second * instance.stack_count * delta
            
            # Apply damage based on target type
            if target.is_in_group("player"):
                # Apply to player via SurvivalManager
                if SurvivalManager:
                    SurvivalManager.take_damage(total_damage, instance.effect_data.damage_type)
            elif target.is_in_group("enemy"):
                # Apply to enemy via CombatManager
                if CombatManager:
                    CombatManager.apply_damage(target, total_damage, instance.effect_data.damage_type)
    
    # Remove expired effects
    for instance in effects_to_remove:
        remove_effect(target, instance.effect_data.effect_id)
```

### Cure Effect Algorithm

```gdscript
func cure_effect(target: Node2D, effect_id: String, cure_method: String) -> bool:
    var instance = get_effect_instance(target, effect_id)
    if instance == null:
        return false
    
    var effect_data = instance.effect_data
    
    # Check if cure method is valid
    var can_cure = false
    
    if cure_method.begins_with("item_"):
        var item_id = cure_method.substr(5)  # Remove "item_" prefix
        can_cure = item_id in effect_data.cure_items
    else:
        can_cure = cure_method in effect_data.cure_actions
    
    if not can_cure:
        return false
    
    # Remove effect
    remove_effect(target, effect_id)
    return true
```

### Effect Update Process Algorithm

```gdscript
func _process(delta: float) -> void:
    # Update all active effects
    for target_id in active_effects:
        var target = get_target_by_id(target_id)
        if target:
            update_effects(target, delta)
```

---

## Integration Points

### Combat System

**Usage:**
- Weapons apply effects on hit (with chance)
- Enemies apply effects with attacks
- Effects modify combat stats (damage, speed, defense)

**Example:**
```gdscript
# In CombatManager
func apply_damage(target: Node2D, attack_data: AttackData) -> void:
    # ... apply damage ...
    
    # Apply weapon effects
    if current_weapon.has_status_effect:
        var chance = current_weapon.effect_chance
        StatusEffectApplier.apply_effect_from_weapon(
            target,
            current_weapon.weapon_id,
            current_weapon.status_effect_id,
            chance
        )
```

### Survival System

**Usage:**
- Environmental effects (radiation, poison gas)
- Food/water effects (poison from spoiled food)
- Status effects modify survival stats

**Example:**
```gdscript
# In SurvivalManager
func apply_environmental_effect(effect_id: String) -> void:
    StatusEffectApplier.apply_effect_from_environmental(
        player,
        effect_id,
        EffectSourceType.ENVIRONMENTAL,
        "radiation_zone",
        "Radiation Zone"
    )
```

### Inventory System

**Usage:**
- Consumable items apply effects
- Cure items remove effects
- Effect items tracked in inventory

**Example:**
```gdscript
# In InventoryManager
func use_item(item_id: String) -> void:
    var item_data = ItemDatabase.get_item(item_id)
    
    # Check if item applies effect
    if item_data.metadata.has("applies_effect"):
        var effect_id = item_data.metadata["applies_effect"]
        StatusEffectApplier.apply_effect_from_item(player, item_id, effect_id)
    
    # Check if item cures effect
    if item_data.metadata.has("cures_effect"):
        var effect_id = item_data.metadata["cures_effect"]
        StatusEffectManager.cure_effect(player, effect_id, "item_" + item_id)
```

---

## Save/Load System

### Status Effect Save

**Save Format:**
```gdscript
{
    "status_effects": {
        "player": [
            {
                "effect_id": "poison",
                "remaining_duration": 45.5,
                "stack_count": 1,
                "applied_time": 1234.5,
                "source_type": 1,  # EffectSourceType.ENEMY
                "source_id": "spider_001",
                "source_name": "Venomous Spider"
            }
        ]
    }
}
```

**Load Format:**
```gdscript
func load_status_effects(save_data: Dictionary) -> void:
    if save_data.has("status_effects"):
        for target_id in save_data.status_effects:
            var target = get_target_by_id(target_id)
            if target == null:
                continue
            
            var effects_data = save_data.status_effects[target_id]
            for effect_data in effects_data:
                var effect = effect_registry.get(effect_data.effect_id)
                if effect == null:
                    continue
                
                var instance = StatusEffectInstance.new(effect, target)
                instance.remaining_duration = effect_data.get("remaining_duration", effect.duration)
                instance.stack_count = effect_data.get("stack_count", 1)
                instance.applied_time = effect_data.get("applied_time", Time.get_ticks_msec() / 1000.0)
                instance.source_type = effect_data.get("source_type", EffectSourceType.OTHER)
                instance.source_id = effect_data.get("source_id", "")
                instance.source_name = effect_data.get("source_name", "")
                
                if not active_effects.has(target_id):
                    active_effects[target_id] = []
                active_effects[target_id].append(instance)
```

---

## Performance Considerations

### Optimization Strategies

1. **Update Frequency:**
   - Update effects every 0.1 seconds instead of every frame
   - Batch updates for multiple targets

2. **Effect Lookup:**
   - Use dictionary for O(1) effect lookup
   - Cache effect instances per target

3. **Stat Calculation:**
   - Cache stat modifiers when effects don't change
   - Recalculate only when effects added/removed

4. **Visual Effects:**
   - Limit active particle effects
   - Use object pooling for visual effects

5. **Memory Management:**
   - Remove expired effects immediately
   - Clean up unused effect instances

---

## Testing Checklist

### Effect Application
- [ ] Effects apply correctly
- [ ] Source tracking works correctly
- [ ] Visual/audio effects play correctly
- [ ] Effects register correctly

### Stacking Rules
- [ ] Refresh duration works correctly
- [ ] Extend duration works correctly
- [ ] Stack intensity works correctly
- [ ] Replace if stronger works correctly

### Stat Modifiers
- [ ] Flat modifiers work correctly
- [ ] Percentage modifiers work correctly
- [ ] Buffs add together correctly
- [ ] Debuffs multiply correctly
- [ ] Multiple stat modifiers work correctly

### Effect Interactions
- [ ] Effect cancellations work correctly
- [ ] Interaction pairs work correctly
- [ ] No circular cancellation issues

### Curing
- [ ] Cure items work correctly
- [ ] Cure actions work correctly
- [ ] Invalid cure methods rejected correctly

### Duration
- [ ] Effects expire correctly
- [ ] Permanent effects don't expire
- [ ] Duration updates correctly

### Integration
- [ ] Works with combat system
- [ ] Works with survival system
- [ ] Works with inventory system
- [ ] Save/load works correctly

---

## Error Handling

### StatusEffectManager Error Handling

- **Missing Effect Data:** Handle missing effect IDs gracefully, return errors
- **Invalid Target References:** Validate target references before operations
- **Missing System References:** Handle missing managers (CombatManager, SurvivalManager) gracefully
- **Effect Application Errors:** Handle effect application failures gracefully

### Best Practices

- Use `push_error()` for critical errors (missing effect data, invalid targets)
- Use `push_warning()` for non-critical issues (missing managers, failed applications)
- Return false/null on errors (don't crash)
- Validate all data before operations
- Handle missing system managers gracefully

---

## Default Values and Configuration

### StatusEffectManager Defaults

```gdscript
update_interval = 0.1  # Update every 0.1 seconds
```

### StatusEffect Defaults

```gdscript
effect_id = ""
effect_name = ""
effect_type = ""
category = EffectCategory.DEBUFF
description = ""
duration = -1.0  # -1 = permanent
max_duration = -1.0  # -1 = no cap
stacking_rule = StackingRule.REFRESH_DURATION
max_stacks = 1
stack_intensity_multiplier = 1.0
damage_per_second = 0.0
damage_type = "physical"
stat_modifiers = {}
modifier_types = {}
icon = null
visual_effect = ""
color_tint = Color.WHITE
sound_effect = null
cancels_effects = []
cancelled_by_effects = []
cure_items = []
cure_actions = []
```

### StatusEffectInstance Defaults

```gdscript
effect_data = null
target = null
remaining_duration = 0.0
stack_count = 1
applied_time = 0.0
source_type = EffectSourceType.OTHER
source_id = ""
source_name = ""
```

---

## Complete Implementation

### StatusEffectManager Complete Implementation

```gdscript
class_name StatusEffectManager
extends Node

# References
var survival_manager: Node = null
var combat_manager: Node = null
var inventory_manager: Node = null

# Effect Registry
var effect_registry: Dictionary = {}

# Active Effects (by target)
var active_effects: Dictionary = {}  # target_id -> Array[StatusEffectInstance]

# Settings
var update_interval: float = 0.1
var update_timer: float = 0.0

# Signals
signal effect_applied(target: Node2D, effect: StatusEffect, instance: StatusEffectInstance)
signal effect_removed(target: Node2D, effect: StatusEffect, instance: StatusEffectInstance)
signal effect_expired(target: Node2D, effect: StatusEffect, instance: StatusEffectInstance)
signal effect_stacked(target: Node2D, effect: StatusEffect, new_stack_count: int)

func _ready() -> void:
    # Find managers
    survival_manager = get_node_or_null("/root/SurvivalManager")
    combat_manager = get_node_or_null("/root/CombatManager")
    inventory_manager = get_node_or_null("/root/InventoryManager")
    
    # Load effects
    load_effects()

func _process(delta: float) -> void:
    update_timer += delta
    if update_timer >= update_interval:
        update_timer = 0.0
        update_all_effects(update_interval)

func load_effects() -> void:
    var effect_dir = DirAccess.open("res://resources/status_effects/")
    if effect_dir:
        effect_dir.list_dir_begin()
        var file_name = effect_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var effect = load("res://resources/status_effects/" + file_name) as StatusEffect
                if effect:
                    register_effect(effect)
            file_name = effect_dir.get_next()

func register_effect(effect: StatusEffect) -> void:
    if effect:
        effect_registry[effect.effect_id] = effect

func apply_effect(target: Node2D, effect_id: String, source_type: EffectSourceType, source_id: String = "", source_name: String = "") -> StatusEffectInstance:
    if not effect_registry.has(effect_id):
        push_error("StatusEffectManager: Effect not found: " + effect_id)
        return null
    
    var effect_data = effect_registry[effect_id]
    
    var target_id = get_target_id(target)
    if target_id.is_empty():
        return null
    
    var existing_instance = get_effect_instance(target, effect_id)
    
    if existing_instance != null:
        return handle_stacking(target, existing_instance, effect_data, source_type, source_id, source_name)
    else:
        check_effect_interactions(target, effect_data)
        
        var instance = StatusEffectInstance.new(effect_data, target)
        instance.source_type = source_type
        instance.source_id = source_id
        instance.source_name = source_name
        
        if not active_effects.has(target_id):
            active_effects[target_id] = []
        active_effects[target_id].append(instance)
        
        apply_visual_effects(target, effect_data)
        if effect_data.sound_effect and AudioManager:
            AudioManager.play_sound_stream(effect_data.sound_effect)
        
        effect_applied.emit(target, effect_data, instance)
        return instance

func remove_effect(target: Node2D, effect_id: String) -> bool:
    var target_id = get_target_id(target)
    if not active_effects.has(target_id):
        return false
    
    var effects = active_effects[target_id]
    for i in range(effects.size()):
        if effects[i].effect_data.effect_id == effect_id:
            var instance = effects[i]
            effects.remove_at(i)
            
            remove_visual_effects(target, instance.effect_data)
            effect_removed.emit(target, instance.effect_data, instance)
            return true
    
    return false

func remove_effect_by_source(target: Node2D, source_type: EffectSourceType, source_id: String) -> void:
    var target_id = get_target_id(target)
    if not active_effects.has(target_id):
        return
    
    var effects = active_effects[target_id]
    var effects_to_remove: Array[StatusEffectInstance] = []
    
    for instance in effects:
        if instance.source_type == source_type and instance.source_id == source_id:
            effects_to_remove.append(instance)
    
    for instance in effects_to_remove:
        remove_effect(target, instance.effect_data.effect_id)

func has_effect(target: Node2D, effect_id: String) -> bool:
    return get_effect_instance(target, effect_id) != null

func get_effect_instance(target: Node2D, effect_id: String) -> StatusEffectInstance:
    var target_id = get_target_id(target)
    if not active_effects.has(target_id):
        return null
    
    var effects = active_effects[target_id]
    for instance in effects:
        if instance.effect_data.effect_id == effect_id:
            return instance
    
    return null

func get_all_effects(target: Node2D) -> Array[StatusEffectInstance]:
    var target_id = get_target_id(target)
    if not active_effects.has(target_id):
        return []
    
    return active_effects[target_id].duplicate()

func get_effects_by_category(target: Node2D, category: EffectCategory) -> Array[StatusEffectInstance]:
    var all_effects = get_all_effects(target)
    var filtered: Array[StatusEffectInstance] = []
    
    for instance in all_effects:
        if instance.effect_data.category == category:
            filtered.append(instance)
    
    return filtered

func cure_effect(target: Node2D, effect_id: String, cure_method: String) -> bool:
    var instance = get_effect_instance(target, effect_id)
    if instance == null:
        return false
    
    var effect_data = instance.effect_data
    
    var can_cure = false
    
    if cure_method.begins_with("item_"):
        var item_id = cure_method.substr(5)
        can_cure = item_id in effect_data.cure_items
    else:
        can_cure = cure_method in effect_data.cure_actions
    
    if not can_cure:
        return false
    
    remove_effect(target, effect_id)
    return true

func update_all_effects(delta: float) -> void:
    for target_id in active_effects:
        var target = get_target_by_id(target_id)
        if target:
            update_effects(target, delta)

func update_effects(target: Node2D, delta: float) -> void:
    var target_id = get_target_id(target)
    if not active_effects.has(target_id):
        return
    
    var effects = active_effects[target_id]
    var effects_to_remove: Array[StatusEffectInstance] = []
    
    for instance in effects:
        if not instance.is_active:
            continue
        
        if instance.effect_data.duration > 0:
            instance.remaining_duration -= delta
            if instance.remaining_duration <= 0:
                effects_to_remove.append(instance)
                continue
        
        if instance.effect_data.damage_per_second > 0:
            var total_damage = instance.effect_data.damage_per_second * instance.stack_count * delta
            
            if target.is_in_group("player"):
                if SurvivalManager:
                    SurvivalManager.take_damage(total_damage, instance.effect_data.damage_type)
            elif target.is_in_group("enemy"):
                if CombatManager:
                    CombatManager.apply_damage(target, total_damage, instance.effect_data.damage_type)
    
    for instance in effects_to_remove:
        remove_effect(target, instance.effect_data.effect_id)
        effect_expired.emit(target, instance.effect_data, instance)

func calculate_stat_modifier(target: Node2D, stat_name: String, base_value: float) -> float:
    var target_id = get_target_id(target)
    if not active_effects.has(target_id):
        return base_value
    
    var effects = active_effects[target_id]
    var buffs: Array[StatusEffectInstance] = []
    var debuffs: Array[StatusEffectInstance] = []
    
    for instance in effects:
        if instance.effect_data.stat_modifiers.has(stat_name):
            if instance.effect_data.category == EffectCategory.BUFF:
                buffs.append(instance)
            else:
                debuffs.append(instance)
    
    var result = base_value
    
    # Apply buffs
    var total_buff = 0.0
    var total_buff_percent = 0.0
    
    for instance in buffs:
        var modifier = instance.effect_data.stat_modifiers[stat_name]
        var modifier_type = instance.effect_data.modifier_types.get(stat_name, "flat")
        
        if modifier_type == "flat":
            total_buff += modifier * instance.stack_count
        else:
            total_buff_percent += modifier * instance.stack_count
    
    result += total_buff
    result *= (1.0 + total_buff_percent)
    
    # Apply debuffs
    for instance in debuffs:
        var modifier = instance.effect_data.stat_modifiers[stat_name]
        var modifier_type = instance.effect_data.modifier_types.get(stat_name, "flat")
        
        if modifier_type == "flat":
            result -= modifier * instance.stack_count
        else:
            result *= (1.0 - modifier * instance.stack_count)
    
    return max(0.0, result)

func check_effect_interactions(target: Node2D, new_effect: StatusEffect) -> void:
    var target_id = get_target_id(target)
    if not active_effects.has(target_id):
        return
    
    var effects_to_remove: Array[StatusEffectInstance] = []
    
    for cancel_id in new_effect.cancels_effects:
        var instance = get_effect_instance(target, cancel_id)
        if instance:
            effects_to_remove.append(instance)
    
    for instance in active_effects[target_id]:
        if new_effect.effect_id in instance.effect_data.cancelled_by_effects:
            return  # New effect is cancelled
    
    for instance in effects_to_remove:
        remove_effect(target, instance.effect_data.effect_id)

func handle_stacking(target: Node2D, existing: StatusEffectInstance, new_effect: StatusEffect, source_type: EffectSourceType, source_id: String, source_name: String) -> StatusEffectInstance:
    match new_effect.stacking_rule:
        StackingRule.REFRESH_DURATION:
            existing.remaining_duration = new_effect.duration
            existing.applied_time = Time.get_ticks_msec() / 1000.0
            return existing
        
        StackingRule.EXTEND_DURATION:
            var new_duration = existing.remaining_duration + new_effect.duration
            if new_effect.max_duration > 0:
                new_duration = min(new_duration, new_effect.max_duration)
            existing.remaining_duration = new_duration
            return existing
        
        StackingRule.STACK_INTENSITY:
            if existing.stack_count < new_effect.max_stacks:
                existing.stack_count += 1
                effect_stacked.emit(target, new_effect, existing.stack_count)
            return existing
        
        StackingRule.REPLACE_IF_STRONGER:
            var existing_strength = existing.effect_data.damage_per_second
            var new_strength = new_effect.damage_per_second
            
            if new_strength > existing_strength:
                remove_effect(target, existing.effect_data.effect_id)
                return apply_effect(target, new_effect.effect_id, source_type, source_id, source_name)
            else:
                return existing
    
    return existing

func get_target_id(target: Node2D) -> String:
    if target.is_in_group("player"):
        return "player"
    elif target.has_method("get_instance_id"):
        return str(target.get_instance_id())
    else:
        return ""

func get_target_by_id(target_id: String) -> Node2D:
    if target_id == "player":
        return get_tree().get_first_node_in_group("player")
    else:
        # Find by instance ID (for enemies, etc.)
        return null  # Implement based on target type

func apply_visual_effects(target: Node2D, effect: StatusEffect) -> void:
    # Apply visual effects (particles, color tint, etc.)
    if effect.visual_effect != "":
        # Spawn particle effect
        pass
    
    if effect.color_tint != Color.WHITE:
        # Apply color tint to target sprite
        pass

func remove_visual_effects(target: Node2D, effect: StatusEffect) -> void:
    # Remove visual effects
    pass
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── StatusEffectManager.gd
   └── scripts/
       └── status_effects/
           ├── StatusEffect.gd
           ├── StatusEffectInstance.gd
           └── StatusEffectApplier.gd
   └── resources/
       └── status_effects/
           ├── poison.tres
           ├── burn.tres
           └── speed_boost.tres
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/StatusEffectManager.gd` as `StatusEffectManager`
   - **Important:** Load after CombatManager and SurvivalManager

3. **Create Status Effect Resources:**
   - Create StatusEffect resources for each effect type
   - Configure effect properties (duration, stacking, modifiers, etc.)
   - Save as `.tres` files in `res://resources/status_effects/`

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. CombatManager, SurvivalManager
4. **StatusEffectManager** (after systems that apply/are affected by effects)

### System Integration

**Systems Must Call StatusEffectManager:**
```gdscript
# Example: CombatManager
func apply_weapon_effect(target: Node2D, weapon_id: String, effect_id: String, chance: float):
    StatusEffectApplier.apply_effect_from_weapon(target, weapon_id, effect_id, chance)

# Example: SurvivalManager
func apply_environmental_effect(effect_id: String):
    StatusEffectManager.apply_effect(player, effect_id, EffectSourceType.ENVIRONMENTAL, "environment", "Environment")

# Example: InventoryManager
func use_item(item_id: String):
    if item_data.metadata.has("applies_effect"):
        var effect_id = item_data.metadata["applies_effect"]
        StatusEffectApplier.apply_effect_from_item(player, item_id, effect_id)
```

**Systems Must Query Stat Modifiers:**
```gdscript
# Example: Get modified speed
var base_speed = 200.0
var modified_speed = StatusEffectManager.calculate_stat_modifier(player, "speed", base_speed)
```

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Status Effects System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Resources:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Status Effects System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Signals Tutorial](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Resources Tutorial](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data storage
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- StatusEffect is a Resource (can be created/edited in inspector)
- Effect properties configured via @export variables (editable in inspector)
- Stat modifiers configured via Dictionary (editable in inspector)

**Visual Configuration:**
- Effect properties editable in inspector
- Stat modifiers editable in inspector (Dictionary)
- Modifier types editable in inspector (Dictionary)

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Effect editor with visual stat modifier configuration
  - Effect interaction visualizer
  - Effect tester

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Effects created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

### Effect Registration

**Method:** Register effects in `StatusEffectManager`

**Example:**
```gdscript
# In StatusEffectManager._ready()
var poison_effect = StatusEffect.new()
poison_effect.effect_id = "poison"
poison_effect.effect_name = "Poison"
poison_effect.category = EffectCategory.DEBUFF
poison_effect.duration = 60.0
poison_effect.damage_per_second = 2.0
poison_effect.stacking_rule = StackingRule.EXTEND_DURATION
poison_effect.max_duration = 120.0
poison_effect.cancelled_by_effects = ["antidote"]
poison_effect.cure_items = ["antidote_potion"]
register_effect(poison_effect)
```

### Weapon Effect Configuration

**Metadata Structure:**
```gdscript
# Weapon item metadata
{
    "status_effect": {
        "effect_id": "poison",
        "chance": 0.3,  # 30% chance
        "on_hit": true
    }
}
```

---

## Future Enhancements

### Potential Additions

1. **Effect Combinations:**
   - Combining effects creates new effects
   - Synergy bonuses

2. **Effect Resistance:**
   - Resistance stats reduce effect duration/damage
   - Immunity to certain effects

3. **Effect Amplification:**
   - Some effects amplify others
   - Effect chains

4. **Visual Indicators:**
   - More detailed visual effects
   - Effect icons on entities

5. **Effect Tooltips:**
   - Detailed effect information
   - Source information display

---

## Dependencies

### Required Systems
- Item Database System (for effect data)
- Combat System (for weapon effects)
- Survival System (for environmental effects)
- Inventory System (for cure items)

### Systems That Depend on This
- Combat System (stat modifiers)
- Survival System (survival stat modifiers)
- UI System (effect display)

---

## Notes

- Status effects system is comprehensive and flexible
- Per-effect-type stacking rules allow fine-tuned control
- Full source tracking enables debugging and UI display
- Hybrid stat modifier system balances power and prevents abuse
- Effect interactions add strategic depth
- Multiple curing methods provide player agency

