# Technical Specifications: Combat System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the combat system supporting mixed combat (fast + tactical), multiple weapon types (melee, ranged, energy), and boss fights. This system integrates with ItemDatabase for weapon data and InventoryManager for weapon equipping.

---

## Research Notes

### Combat System Architecture Best Practices

**Research Findings:**
- Area2D/PhysicsBody2D are standard for hit detection in 2D
- Raycasting (PhysicsRayQueryParameters2D) efficient for ranged attacks
- Signal-based damage events keep systems decoupled
- Projectile pooling improves performance
- Invulnerability frames prevent damage spam
- Armor/resistance formulas balance combat

**Sources:**
- [Godot 4 Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Hit detection
- [Godot 4 PhysicsRayQueryParameters2D](https://docs.godotengine.org/en/stable/classes/class_physicsrayqueryparameters2d.html) - Raycasting
- [Godot 4 Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Event-driven architecture
- [Godot 4 Performance Best Practices](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Optimization guidelines

**Implementation Approach:**
- Use Area2D for melee hit detection (arc/range)
- Use PhysicsRayQueryParameters2D for ranged attacks
- Signal-based damage events (damage_applied, entity_died)
- Projectile pooling for performance
- Invulnerability frames via time tracking
- Armor formula: damage * (1 - armor / (armor + 100))

**Why This Approach:**
- Area2D provides efficient hit detection
- Raycasting accurate for ranged attacks
- Signals decouple combat from other systems
- Pooling reduces object creation overhead
- Invulnerability prevents unfair damage
- Armor formula provides diminishing returns

### Weapon System Integration

**Research Findings:**
- Weapons should be stored as ItemData in ItemDatabase
- Weapon equipping should use InventoryManager equipment system
- Weapon stats should come from ItemData (damage, attack_speed, etc.)
- Runtime weapon instances needed for durability tracking

**Sources:**
- ItemDatabase specification (already completed)
- InventoryManager specification (already completed)

**Implementation Approach:**
- Get weapon data from ItemDatabase.get_item(weapon_id)
- Create weapon instance via ItemDatabase.create_item_instance() for durability
- Equip via InventoryManager.equip_item() or EquipmentManager
- Read weapon stats from ItemData (damage, attack_speed, range, etc.)

**Why This Approach:**
- Single source of truth (ItemDatabase)
- Consistent with inventory system
- Durability tracking per weapon instance
- Easy to add/modify weapons via resources

### Damage Calculation Best Practices

**Research Findings:**
- Armor should provide diminishing returns
- Resistance should be multiplicative
- Minimum damage prevents invincibility
- Critical hits add excitement

**Sources:**
- General game design best practices
- Common armor formulas from RPGs

**Implementation Approach:**
- Armor: damage * (1 - armor / (armor + 100))
- Resistance: damage * (1 - resistance)
- Minimum damage: max(1.0, final_damage)
- Critical: base_damage * critical_multiplier (if roll succeeds)

**Why This Approach:**
- Diminishing returns prevent armor stacking issues
- Multiplicative resistance balances multiple resistances
- Minimum damage ensures progress
- Critical hits add variance

### Projectile System Best Practices

**Research Findings:**
- Object pooling essential for performance
- Area2D for collision detection
- Lifetime prevents infinite projectiles
- Owner tracking prevents self-damage

**Sources:**
- [Godot 4 Object Pooling](https://docs.godotengine.org/en/stable/tutorials/performance/using_object_pooling.html) - Performance optimization
- [Godot 4 Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Collision detection

**Implementation Approach:**
- ProjectilePool manages projectile instances
- Reuse projectiles instead of creating/destroying
- Area2D for collision detection
- Lifetime timer auto-returns to pool
- Owner field prevents self-collision

**Why This Approach:**
- Pooling reduces GC pressure
- Area2D efficient for 2D collisions
- Lifetime prevents memory leaks
- Owner tracking prevents bugs

---

## Data Structures

**Note:** Weapon data is stored in ItemDatabase as ItemData with ItemType.WEAPON. This system uses ItemDatabase.get_item(weapon_id) to retrieve weapon data. Weapon instances are created via ItemDatabase.create_item_instance() for durability tracking.

### WeaponData (Helper Class)

```gdscript
class_name WeaponData
extends RefCounted

# Reference to ItemData from ItemDatabase
var item_data: ItemData
var weapon_id: String
var weapon_type: String  # "melee", "ranged", "energy"
var damage: float
var attack_speed: float  # Attacks per second
var range: float
var knockback: float
var stamina_cost: float
var ammo_type: String = ""  # For ranged weapons
var energy_cost: float = 0.0  # For energy weapons
var projectile_scene: PackedScene  # For ranged/energy
var attack_animation: String

# Create from ItemData
static func from_item_data(item_data: ItemData) -> WeaponData:
    var weapon = WeaponData.new()
    weapon.item_data = item_data
    weapon.weapon_id = item_data.item_id
    # Extract weapon stats from ItemData.metadata or use defaults
    weapon.damage = item_data.damage
    weapon.attack_speed = item_data.attack_speed
    weapon.range = item_data.range
    # Additional stats from metadata
    if item_data.metadata.has("weapon_type"):
        weapon.weapon_type = item_data.metadata["weapon_type"]
    if item_data.metadata.has("knockback"):
        weapon.knockback = item_data.metadata["knockback"]
    if item_data.metadata.has("stamina_cost"):
        weapon.stamina_cost = item_data.metadata["stamina_cost"]
    if item_data.metadata.has("ammo_type"):
        weapon.ammo_type = item_data.metadata["ammo_type"]
    if item_data.metadata.has("energy_cost"):
        weapon.energy_cost = item_data.metadata["energy_cost"]
    if item_data.metadata.has("projectile_scene"):
        weapon.projectile_scene = load(item_data.metadata["projectile_scene"]) as PackedScene
    if item_data.metadata.has("attack_animation"):
        weapon.attack_animation = item_data.metadata["attack_animation"]
    return weapon
```

### AttackData

```gdscript
class_name AttackData
extends RefCounted

var attacker: Node2D
var damage: float
var damage_type: String  # "physical", "energy", "fire", etc.
var knockback: float
var direction: Vector2
var source_position: Vector2
var hit_entities: Array[Node2D] = []
```

### CombatStats

```gdscript
class_name CombatStats
extends Resource

@export var health: float = 100.0
@export var max_health: float = 100.0
@export var armor: float = 0.0
@export var damage_resistance: Dictionary = {}  # damage_type -> resistance (0.0-1.0)
@export var stamina: float = 100.0
@export var max_stamina: float = 100.0
@export var stamina_regen_rate: float = 10.0
@export var invulnerability_time: float = 0.5  # Seconds after taking damage
@export var last_damage_time: float = 0.0
```

---

## Core Classes

### CombatManager (Autoload Singleton)

```gdscript
class_name CombatManager
extends Node

# References
var player: CharacterBody2D  # Player controller
var inventory_manager: InventoryManager
var equipment_manager: EquipmentManager

# Combat State
var current_weapon_data: WeaponData = null
var current_weapon_item: ItemData = null  # ItemData instance (for durability)
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var last_attack_time: float = 0.0

# Projectile Pool
var projectile_pool: ProjectilePool

# Configuration
const MIN_DAMAGE: float = 1.0
const CRITICAL_CHANCE: float = 0.1  # 10% base critical chance
const CRITICAL_MULTIPLIER: float = 2.0

# Signals
signal weapon_equipped(weapon_id: String)
signal weapon_unequipped()
signal attack_performed(weapon_id: String, target_position: Vector2)
signal damage_applied(target: Node2D, damage: float, damage_type: String)
signal entity_died(entity: Node2D)
signal critical_hit(target: Node2D, damage: float)

# Initialization
func _ready() -> void
func initialize() -> void

# Weapon Management
func equip_weapon(weapon_id: String) -> bool
func equip_weapon_by_item(item_data: ItemData) -> bool
func unequip_weapon() -> void
func get_current_weapon() -> WeaponData

# Attack System
func attack(target_position: Vector2) -> bool
func can_attack() -> bool
func perform_melee_attack(target_pos: Vector2) -> void
func perform_ranged_attack(target_pos: Vector2) -> void
func perform_energy_attack(target_pos: Vector2) -> void

# Damage System
func apply_damage(target: Node2D, attack_data: AttackData) -> void
func calculate_damage(base_damage: float, damage_type: String, target: Node2D) -> float
func calculate_critical_damage(base_damage: float) -> float
func check_critical_hit() -> bool

# Hit Detection
func check_melee_hit(attack_data: AttackData) -> Array[Node2D]
func check_ranged_hit(start_pos: Vector2, end_pos: Vector2) -> Array[Node2D]

# Combat Updates
func _process(delta: float) -> void
func update_attack_cooldown(delta: float) -> void
```

### Projectile

```gdscript
class_name Projectile
extends Area2D

@export var damage: float
@export var speed: float
@export var lifetime: float = 5.0
@export var damage_type: String
@export var knockback: float = 0.0

var direction: Vector2
var owner: Node2D

func _ready() -> void
func _process(delta: float) -> void
func _on_body_entered(body: Node2D) -> void
func explode() -> void
```

### BossAI

```gdscript
class_name BossAI
extends EnemyAI

@export var boss_name: String
@export var phases: Array[BossPhase] = []
@export var current_phase: int = 0
@export var phase_transition_health: Array[float] = []  # Health thresholds

var phase_timer: float = 0.0
var special_attacks: Array[String] = []

func _ready() -> void
func _process(delta: float) -> void
func update_boss_phase() -> void
func execute_special_attack(attack_name: String) -> void
func transition_to_phase(phase_index: int) -> void
```

### BossPhase

```gdscript
class_name BossPhase
extends Resource

@export var phase_name: String
@export var health_threshold: float  # 0.0-1.0
@export var attack_patterns: Array[String] = []
@export var movement_pattern: String
@export var special_abilities: Array[String] = []
@export var phase_duration: float = -1.0  # -1 = until health threshold
```

---

## System Architecture

### Component Hierarchy

```
CombatManager (Node)
├── Weapon[] (Array)
├── CombatStats (Resource)
├── ProjectilePool (Node)
│   └── Projectile[] (Array)
└── UI/CombatUI (Control)
    ├── HealthBar (ProgressBar)
    ├── StaminaBar (ProgressBar)
    ├── WeaponDisplay (Label)
    └── AmmoDisplay (Label)
```

### Data Flow

1. **Attack Flow:**
   ```
   Player attacks
   ├── CombatManager.attack(target_pos)
   ├── Check stamina/ammo/energy
   ├── Create AttackData
   ├── Perform attack based on weapon type
   ├── Check hits (raycast or area)
   ├── Apply damage to hit entities
   └── Apply knockback/effects
   ```

2. **Damage Application:**
   ```
   Apply damage
   ├── Calculate final damage (armor, resistance)
   ├── Apply to target CombatStats
   ├── Check invulnerability
   ├── Trigger damage effects
   ├── Check death
   └── Update UI
   ```

---

## Algorithms

### Weapon Equipping (Using ItemDatabase)

```gdscript
func equip_weapon(weapon_id: String) -> bool:
    # Get weapon data from ItemDatabase
    var item_data = ItemDatabase.get_item(weapon_id)
    if item_data == null:
        push_error("CombatManager: Weapon not found: " + weapon_id)
        return false
    
    if item_data.item_type != ItemData.ItemType.WEAPON:
        push_error("CombatManager: Item is not a weapon: " + weapon_id)
        return false
    
    return equip_weapon_by_item(item_data)

func equip_weapon_by_item(item_data: ItemData) -> bool:
    if item_data == null:
        return false
    
    # Unequip current weapon first
    if current_weapon_item != null:
        unequip_weapon()
    
    # Create weapon instance for durability tracking
    current_weapon_item = ItemDatabase.create_item_instance(item_data.item_id)
    if current_weapon_item == null:
        push_error("CombatManager: Failed to create weapon instance: " + item_data.item_id)
        return false
    
    # Create WeaponData from ItemData
    current_weapon_data = WeaponData.from_item_data(current_weapon_item)
    
    # Equip via EquipmentManager (if using equipment system)
    if EquipmentManager:
        EquipmentManager.equip_item_by_data(current_weapon_item, EquipmentSlot.SlotType.ACCESSORY)
    
    weapon_equipped.emit(current_weapon_data.weapon_id)
    return true
```

### Melee Attack Algorithm (Using ItemDatabase)

```gdscript
func perform_melee_attack(target_pos: Vector2) -> void:
    if current_weapon_data == null or current_weapon_data.weapon_type != "melee":
        return
    
    # Check cooldown
    if not can_attack():
        return
    
    # Check stamina
    if player.combat_stats.stamina < current_weapon_data.stamina_cost:
        return
    
    var attack_data: AttackData = AttackData.new()
    attack_data.attacker = player
    attack_data.damage = current_weapon_data.damage
    attack_data.damage_type = "physical"
    attack_data.knockback = current_weapon_data.knockback
    attack_data.direction = (target_pos - player.global_position).normalized()
    attack_data.source_position = player.global_position
    
    # Check hits in arc/range
    var hit_entities: Array[Node2D] = check_melee_hit(attack_data)
    
    for entity in hit_entities:
        apply_damage(entity, attack_data)
    
    # Play animation
    if not current_weapon_data.attack_animation.is_empty():
        player.play_animation(current_weapon_data.attack_animation)
    
    # Consume stamina
    player.combat_stats.stamina -= current_weapon_data.stamina_cost
    
    # Update cooldown
    attack_cooldown = 1.0 / current_weapon_data.attack_speed
    last_attack_time = Time.get_ticks_msec() / 1000.0
    
    # Reduce weapon durability
    if current_weapon_item.durability > 0:
        current_weapon_item.current_durability -= 1
        if current_weapon_item.current_durability <= 0:
            push_warning("CombatManager: Weapon broke: " + current_weapon_data.weapon_id)
            unequip_weapon()
    
    attack_performed.emit(current_weapon_data.weapon_id, target_pos)
```

### Ranged Attack Algorithm (Using ItemDatabase and InventoryManager)

```gdscript
func perform_ranged_attack(target_pos: Vector2) -> void:
    if current_weapon_data == null or current_weapon_data.weapon_type != "ranged":
        return
    
    # Check cooldown
    if not can_attack():
        return
    
    # Check ammo
    if current_weapon_data.ammo_type.is_empty():
        push_warning("CombatManager: Ranged weapon missing ammo_type")
        return
    
    # Check if player has ammo
    if not InventoryManager.has_item_quantity(current_weapon_data.ammo_type, 1):
        return
    
    # Consume ammo
    var removed = InventoryManager.remove_item(current_weapon_data.ammo_type, 1)
    if removed < 1:
        return
    
    # Spawn projectile from pool
    var projectile: Projectile = projectile_pool.get_projectile()
    if projectile == null:
        push_error("CombatManager: Projectile pool exhausted")
        return
    
    projectile.global_position = player.global_position
    projectile.direction = (target_pos - player.global_position).normalized()
    projectile.damage = current_weapon_data.damage
    projectile.damage_type = "physical"
    projectile.owner = player
    projectile.speed = 500.0  # Default speed, can be in metadata
    add_child(projectile)
    
    # Consume stamina
    player.combat_stats.stamina -= current_weapon_data.stamina_cost
    
    # Update cooldown
    attack_cooldown = 1.0 / current_weapon_data.attack_speed
    last_attack_time = Time.get_ticks_msec() / 1000.0
    
    # Reduce weapon durability
    if current_weapon_item.durability > 0:
        current_weapon_item.current_durability -= 1
        if current_weapon_item.current_durability <= 0:
            push_warning("CombatManager: Weapon broke: " + current_weapon_data.weapon_id)
            unequip_weapon()
    
    attack_performed.emit(current_weapon_data.weapon_id, target_pos)
```

### Damage Calculation Algorithm

```gdscript
func calculate_damage(base_damage: float, damage_type: String, target: Node2D) -> float:
    var final_damage: float = base_damage
    
    # Check for critical hit
    if check_critical_hit():
        final_damage = calculate_critical_damage(final_damage)
        critical_hit.emit(target, final_damage)
    
    # Apply armor (for physical damage)
    if damage_type == "physical":
        var combat_stats = target.get("combat_stats")
        if combat_stats != null:
            var armor: float = combat_stats.armor
            var armor_reduction: float = armor / (armor + 100.0)
            final_damage *= (1.0 - armor_reduction)
    
    # Apply resistance
    var combat_stats = target.get("combat_stats")
    if combat_stats != null and combat_stats.damage_resistance.has(damage_type):
        var resistance: float = combat_stats.damage_resistance[damage_type]
        final_damage *= (1.0 - resistance)
    
    # Apply minimum damage
    return max(MIN_DAMAGE, final_damage)

func check_critical_hit() -> bool:
    return randf() < CRITICAL_CHANCE

func calculate_critical_damage(base_damage: float) -> float:
    return base_damage * CRITICAL_MULTIPLIER
```

### Boss Phase Transition

```gdscript
func update_boss_phase() -> void:
    var health_percentage: float = combat_stats.health / combat_stats.max_health
    
    # Check if should transition
    for i in range(phase_transition_health.size()):
        if health_percentage <= phase_transition_health[i] and current_phase < i:
            transition_to_phase(i)
            break

func transition_to_phase(phase_index: int) -> void:
    current_phase = phase_index
    var phase: BossPhase = phases[phase_index]
    
    # Update attack patterns
    attack_patterns = phase.attack_patterns
    
    # Trigger phase transition effects
    play_phase_transition_animation()
    spawn_phase_transition_effects()
    
    # Update AI behavior
    update_ai_for_phase(phase)
```

---

## Integration Points

### With Survival System

```gdscript
func apply_damage(target: Node2D, attack_data: AttackData) -> void:
    # Check invulnerability
    var current_time: float = Time.get_ticks_msec() / 1000.0
    if current_time - target.combat_stats.last_damage_time < target.combat_stats.invulnerability_time:
        return
    
    # Calculate damage
    var final_damage: float = calculate_damage(attack_data.damage, attack_data.damage_type, target)
    
    # Apply to survival stats
    target.survival_manager.player_stats.apply_damage(final_damage)
    target.combat_stats.last_damage_time = current_time
    
    # Apply knockback
    if attack_data.knockback > 0.0:
        apply_knockback(target, attack_data.direction, attack_data.knockback)
    
    # Check death
    if target.combat_stats.health <= 0.0:
        handle_death(target)
```

---

## Save/Load System

### Save Data

```gdscript
var combat_save_data: Dictionary = {
    "equipped_weapon": current_weapon.weapon_id if current_weapon else "",
    "combat_stats": {
        "health": combat_stats.health,
        "max_health": combat_stats.max_health,
        "armor": combat_stats.armor,
        "stamina": combat_stats.stamina,
        "max_stamina": combat_stats.max_stamina,
        "damage_resistance": combat_stats.damage_resistance
    }
}
```

---

## Error Handling

### CombatManager Error Handling

- **Invalid Weapon IDs:** Check ItemDatabase before equipping, return errors gracefully
- **Missing Ammo:** Check InventoryManager before ranged attacks, prevent attack if no ammo
- **Invalid Targets:** Validate target exists and has combat_stats before applying damage
- **Projectile Pool Exhausted:** Handle gracefully, limit concurrent projectiles
- **Weapon Durability:** Check durability before attacks, unequip when broken
- **Stamina/Energy:** Check resources before attacks, prevent attack if insufficient

### Best Practices

- Use `push_error()` for critical errors (invalid weapon_id, missing ItemDatabase)
- Use `push_warning()` for non-critical issues (no ammo, low stamina)
- Return false/null on errors (don't crash)
- Validate all inputs before operations
- Handle edge cases (null weapons, invalid targets)

---

## Default Values and Configuration

### CombatManager Defaults

```gdscript
# Damage
MIN_DAMAGE = 1.0

# Critical Hits
CRITICAL_CHANCE = 0.1  # 10%
CRITICAL_MULTIPLIER = 2.0

# Attack Cooldown
DEFAULT_ATTACK_SPEED = 1.0  # Attacks per second
```

### CombatStats Defaults

```gdscript
health = 100.0
max_health = 100.0
armor = 0.0
damage_resistance = {}
stamina = 100.0
max_stamina = 100.0
stamina_regen_rate = 10.0
invulnerability_time = 0.5
last_damage_time = 0.0
```

### Projectile Defaults

```gdscript
speed = 500.0
lifetime = 5.0
damage_type = "physical"
knockback = 0.0
```

### BossPhase Defaults

```gdscript
health_threshold = 0.0
attack_patterns = []
movement_pattern = ""
special_abilities = []
phase_duration = -1.0  # -1 = until health threshold
```

---

## Performance Considerations

### Optimization Strategies

1. **Projectile Pooling:**
   - Pre-allocate projectile pool (e.g., 50 projectiles)
   - Reuse projectiles instead of creating/destroying
   - Limit concurrent projectiles

2. **Hit Detection:**
   - Use Area2D for melee (efficient)
   - Use PhysicsRayQueryParameters2D for ranged (accurate)
   - Limit hit checks per frame

3. **Damage Calculation:**
   - Cache damage calculations when possible
   - Batch damage applications
   - Limit damage events per frame

4. **Boss AI:**
   - Update boss AI less frequently (every 0.1s instead of every frame)
   - Cache phase transitions
   - Limit special attack frequency

---

## Testing Checklist

### Weapon System
- [ ] Weapon equipping uses ItemDatabase correctly
- [ ] Weapon unequipping works
- [ ] Weapon durability decreases on use
- [ ] Weapon breaks when durability reaches 0
- [ ] Invalid weapon IDs handled gracefully

### Melee Combat
- [ ] Melee attacks work correctly
- [ ] Hit detection finds targets in range
- [ ] Damage applies correctly
- [ ] Knockback works correctly
- [ ] Stamina consumption works
- [ ] Attack cooldown works
- [ ] Attack animations play

### Ranged Combat
- [ ] Ranged attacks spawn projectiles
- [ ] Ammo consumption works (uses InventoryManager)
- [ ] Projectile pooling works
- [ ] Projectiles hit targets correctly
- [ ] Projectile lifetime works
- [ ] No ammo prevents attack

### Energy Weapons
- [ ] Energy weapons consume energy
- [ ] Energy cost checked before attack
- [ ] Energy attacks spawn projectiles/effects

### Damage System
- [ ] Damage calculation applies armor correctly
- [ ] Damage calculation applies resistance correctly
- [ ] Critical hits work correctly
- [ ] Minimum damage enforced
- [ ] Invulnerability frames work
- [ ] Damage signals emit correctly

### Boss System
- [ ] Boss phases transition correctly
- [ ] Phase health thresholds work
- [ ] Special attacks execute correctly
- [ ] Boss AI updates correctly

### Integration
- [ ] Integrates with ItemDatabase correctly
- [ ] Integrates with InventoryManager correctly
- [ ] Integrates with EquipmentManager correctly
- [ ] Integrates with Survival System (health)

### Performance
- [ ] Performance is acceptable (60+ FPS)
- [ ] Projectile pooling reduces GC
- [ ] Hit detection efficient
- [ ] No memory leaks

### Edge Cases
- [ ] Null weapon handled
- [ ] Invalid target handled
- [ ] Missing ammo handled
- [ ] Insufficient stamina handled
- [ ] Projectile pool exhausted handled

---

## Complete Implementation

### ProjectilePool Complete Implementation

```gdscript
class_name ProjectilePool
extends Node

var projectile_scene: PackedScene
var pool_size: int = 50
var active_projectiles: Array[Projectile] = []
var inactive_projectiles: Array[Projectile] = []

func _ready() -> void:
    initialize_pool()

func initialize_pool() -> void:
    if projectile_scene == null:
        push_error("ProjectilePool: projectile_scene not set")
        return
    
    for i in range(pool_size):
        var projectile = projectile_scene.instantiate() as Projectile
        if projectile == null:
            push_error("ProjectilePool: Failed to instantiate projectile")
            continue
        projectile.set_process(false)
        projectile.visible = false
        inactive_projectiles.append(projectile)

func get_projectile() -> Projectile:
    if inactive_projectiles.size() > 0:
        var projectile = inactive_projectiles.pop_back()
        active_projectiles.append(projectile)
        projectile.set_process(true)
        projectile.visible = true
        return projectile
    
    # Pool exhausted, create new one (or return null)
    push_warning("ProjectilePool: Pool exhausted")
    return null

func return_projectile(projectile: Projectile) -> void:
    if projectile == null:
        return
    
    var index = active_projectiles.find(projectile)
    if index >= 0:
        active_projectiles.remove_at(index)
        inactive_projectiles.append(projectile)
        projectile.set_process(false)
        projectile.visible = false
        projectile.queue_free()  # Or reset state
```

### CombatManager Initialization

```gdscript
func _ready() -> void:
    # Wait for dependencies
    if ItemDatabase.items.is_empty():
        ItemDatabase.item_database_loaded.connect(_on_database_loaded)
    else:
        initialize()
    
    if InventoryManager == null:
        InventoryManager = get_node("/root/InventoryManager")
    
    if EquipmentManager == null:
        EquipmentManager = get_node("/root/EquipmentManager")

func _on_database_loaded() -> void:
    initialize()

func initialize() -> void:
    # Initialize projectile pool
    if projectile_pool == null:
        projectile_pool = ProjectilePool.new()
        add_child(projectile_pool)
        # Set projectile scene from default or config
        projectile_pool.projectile_scene = preload("res://scenes/projectiles/default_projectile.tscn")
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── CombatManager.gd
   ├── scripts/
   │   └── combat/
   │       ├── WeaponData.gd
   │       ├── AttackData.gd
   │       ├── Projectile.gd
   │       └── ProjectilePool.gd
   └── scenes/
       └── projectiles/
           └── default_projectile.tscn
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/CombatManager.gd` as `CombatManager`
   - **Important:** Load after ItemDatabase, InventoryManager, EquipmentManager

3. **Create Weapon Items:**
   - Create ItemData resources with ItemType.WEAPON
   - Set damage, attack_speed, range in ItemData
   - Add weapon-specific metadata (weapon_type, knockback, stamina_cost, etc.)
   - Save in `res://resources/items/`

4. **Create Projectile Scene:**
   - Create Area2D scene for projectiles
   - Add Projectile script
   - Configure collision layers/masks
   - Save as `res://scenes/projectiles/default_projectile.tscn`

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. InventoryManager
4. EquipmentManager
5. **CombatManager** (after all dependencies)

### Weapon Configuration

**Weapon ItemData Setup:**
1. Create ItemData resource with ItemType.WEAPON
2. Set base stats:
   - `damage`: Base damage value
   - `attack_speed`: Attacks per second
   - `range`: Attack range
3. Add metadata:
   - `weapon_type`: "melee", "ranged", or "energy"
   - `knockback`: Knockback force
   - `stamina_cost`: Stamina per attack
   - `ammo_type`: Ammo item_id (for ranged)
   - `energy_cost`: Energy per attack (for energy)
   - `projectile_scene`: Path to projectile scene
   - `attack_animation`: Animation name

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Combat System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Area2D:** https://docs.godotengine.org/en/stable/classes/class_area2d.html
- **PhysicsRayQueryParameters2D:** https://docs.godotengine.org/en/stable/classes/class_physicsrayqueryparameters2d.html
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Object Pooling:** https://docs.godotengine.org/en/stable/tutorials/performance/using_object_pooling.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Combat System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Hit detection
- [PhysicsRayQueryParameters2D](https://docs.godotengine.org/en/stable/classes/class_physicsrayqueryparameters2d.html) - Raycasting
- [Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Event-driven architecture
- [Object Pooling](https://docs.godotengine.org/en/stable/tutorials/performance/using_object_pooling.html) - Performance optimization
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- WeaponData and AttackData are RefCounted classes (lightweight)
- CombatStats is a Resource class (editable in inspector)
- BossPhase is a Resource class (editable in inspector)
- ProjectilePool is a Node (can be added to scene)

**Visual Configuration:**
- Weapon items created as ItemData resources in editor
- Boss phases created as BossPhase resources
- Projectile scenes created visually in scene editor

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Weapon stats editor with preview
  - Boss phase editor (visual timeline)
  - Damage calculation tester
  - Hit detection visualizer

**Current Approach:**
- Uses Godot's native systems (no custom tools needed)
- Weapons configured via ItemData resources
- Boss phases configured via BossPhase resources
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Item Database Integration:** Uses `ItemDatabase.get_item(weapon_id)` for weapon data, `ItemDatabase.create_item_instance()` for durability tracking
2. **Inventory Integration:** Uses `InventoryManager.remove_item()` for ammo consumption, `InventoryManager.has_item_quantity()` for ammo checking
3. **Equipment Integration:** Uses `EquipmentManager.equip_item()` for weapon equipping
4. **Weapon Data:** WeaponData helper class extracts stats from ItemData.metadata
5. **Projectile Pooling:** ProjectilePool manages projectile instances for performance
6. **Hit Detection:** Area2D for melee, PhysicsRayQueryParameters2D for ranged
7. **Damage Calculation:** Armor formula: damage * (1 - armor / (armor + 100)), resistance multiplicative
8. **Critical Hits:** 10% base chance, 2.0x multiplier (configurable)
9. **Invulnerability:** Time-based invulnerability frames prevent damage spam
10. **Boss Phases:** Health threshold-based phase transitions with special attacks

---

