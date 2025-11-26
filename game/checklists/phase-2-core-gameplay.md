# Phase 2: Core Gameplay Systems - Detailed Checklist

**Phase:** 2  
**Status:** Not Started  
**Dependencies:** Phase 1 Complete  
**Estimated Time:** 4-6 weeks

## Overview

This phase implements the core gameplay systems: survival mechanics, inventory management, interaction system, resource gathering, crafting, building, combat, and status effects. These systems form the core gameplay loop.

---

## System 3: Survival System

**Spec:** `technical-specs-survival.md`

### SurvivalManager Creation
- [ ] Create `scripts/managers/SurvivalManager.gd`
- [ ] Set up as autoload singleton
- [ ] Create `SurvivalStats` resource class
- [ ] Add class documentation

### Core Stats Implementation
- [ ] Implement health system:
  - [ ] current_health, max_health
  - [ ] health_regeneration_rate
  - [ ] `apply_damage(amount: float)` function
  - [ ] `heal(amount: float)` function
  - [ ] `update_health(delta: float)` function
- [ ] Implement hunger system:
  - [ ] current_hunger, max_hunger
  - [ ] hunger_depletion_rate
  - [ ] `update_hunger(delta: float)` function
  - [ ] `consume_food(item_id: String)` function
- [ ] Implement thirst system:
  - [ ] current_thirst, max_thirst
  - [ ] thirst_depletion_rate
  - [ ] `update_thirst(delta: float)` function
  - [ ] `consume_water(item_id: String)` function
- [ ] Implement temperature system:
  - [ ] current_temperature, min_temperature, max_temperature
  - [ ] `update_temperature(delta: float)` function
  - [ ] Environmental temperature effects
- [ ] Implement radiation system:
  - [ ] current_radiation, max_radiation
  - [ ] radiation_accumulation_rate
  - [ ] radiation_decay_rate
  - [ ] `update_radiation(delta: float)` function
- [ ] Implement oxygen/air quality system:
  - [ ] current_oxygen, max_oxygen
  - [ ] `update_oxygen(delta: float)` function
  - [ ] Environmental oxygen effects
- [ ] Implement sleep/rest system:
  - [ ] fatigue level
  - [ ] rest_rate
  - [ ] `rest()` function

### Update Loop
- [ ] Implement `update_survival_stats(delta: float)` function:
  - [ ] Update all stats
  - [ ] Check for death conditions
  - [ ] Emit stat change signals
- [ ] Set up update timer (every 0.1s)
- [ ] Test update loop performance

### EnvironmentManager Creation
- [ ] Create `scripts/managers/EnvironmentManager.gd`
- [ ] Implement environmental zone detection (Area2D)
- [ ] Implement temperature zones
- [ ] Implement radiation zones
- [ ] Implement oxygen zones
- [ ] Test environmental effects

### Status Effects Integration
- [ ] Integrate with StatusEffectManager (when created)
- [ ] Test status effects affect survival stats

### Signals
- [ ] Emit `health_changed` signal
- [ ] Emit `hunger_changed` signal
- [ ] Emit `thirst_changed` signal
- [ ] Emit `temperature_changed` signal
- [ ] Emit `radiation_changed` signal
- [ ] Emit `oxygen_changed` signal
- [ ] Emit `player_died` signal
- [ ] Test all signals work

### Testing
- [ ] Test health depletion
- [ ] Test hunger/thirst depletion
- [ ] Test temperature effects
- [ ] Test radiation accumulation
- [ ] Test environmental interactions
- [ ] Test food/water consumption
- [ ] Test death conditions

---

## System 4: Inventory System

**Spec:** `technical-specs-inventory.md`

### InventoryManager Creation
- [ ] Create `scripts/managers/InventoryManager.gd`
- [ ] Set up as autoload singleton
- [ ] Create `InventorySlot` data structure
- [ ] Add class documentation

### Core Inventory Functions
- [ ] Implement expandable inventory (starts 20 slots):
  - [ ] `slots: Array[InventorySlot] = []`
  - [ ] `max_slots: int = 20`
  - [ ] `expand_inventory(amount: int)` function
- [ ] Implement `add_item(item_id: String, quantity: int = 1) -> bool`:
  - [ ] Check for existing stack
  - [ ] Auto-stack if possible
  - [ ] Find empty slot if needed
  - [ ] Handle inventory full
  - [ ] Return success/failure
- [ ] Implement `remove_item(item_id: String, quantity: int = 1) -> bool`
- [ ] Implement `has_item(item_id: String) -> bool`
- [ ] Implement `get_item_count(item_id: String) -> int`
- [ ] Test all core functions

### Item Stacking
- [ ] Implement stacking logic:
  - [ ] Check max_stack_size from ItemData
  - [ ] Auto-stack on add
  - [ ] Handle partial stacks
- [ ] Implement `split_stack(slot_index: int, quantity: int)` function
- [ ] Implement `merge_stack(from_slot: int, to_slot: int)` function
- [ ] Test stacking works correctly

### Inventory Management
- [ ] Implement `sort_inventory()` function:
  - [ ] Sort by type, then name
  - [ ] Keep empty slots at end
- [ ] Implement `search_inventory(query: String) -> Array[int]`:
  - [ ] Search item names, descriptions, tags
  - [ ] Return matching slot indices
- [ ] Implement `filter_inventory(filters: Dictionary) -> Array[int]`
- [ ] Test all management functions

### Hotbar System
- [ ] Create `scripts/managers/HotbarManager.gd`
- [ ] Implement hotbar (starts 8 slots, upgradeable):
  - [ ] `hotbar_slots: Array[int] = []`
  - [ ] `max_hotbar_slots: int = 8`
  - [ ] `upgrade_hotbar(amount: int)` function
- [ ] Implement hotbar selection:
  - [ ] Number key selection (1-8)
  - [ ] Mouse wheel scrolling
  - [ ] Visual selection indicator
- [ ] Test hotbar functionality

### Equipment System
- [ ] Create `scripts/managers/EquipmentManager.gd`
- [ ] Implement equipment slots:
  - [ ] Head, Chest, Legs, Feet slots
  - [ ] 3 Accessory slots
- [ ] Implement `equip_item(item_id: String, slot: EquipmentSlotType) -> bool`:
  - [ ] Validate item can be equipped
  - [ ] Unequip existing item if any
  - [ ] Apply stat bonuses
  - [ ] Update visuals
- [ ] Implement `unequip_item(slot: EquipmentSlotType) -> bool`
- [ ] Implement equipment stat bonuses
- [ ] Test equipment system

### Storage Containers
- [ ] Create `scripts/managers/ContainerManager.gd`
- [ ] Create `ContainerData` data structure
- [ ] Implement placeable containers:
  - [ ] Create container scene
  - [ ] Implement container placement
  - [ ] Implement container access
  - [ ] Variable container sizes
- [ ] Implement container save/load
- [ ] Test container system

### Auto-Pickup Integration
- [ ] Integrate with ItemPickupManager (when created)
- [ ] Test auto-pickup adds items to inventory

### Testing
- [ ] Test item addition/removal
- [ ] Test item stacking
- [ ] Test inventory sorting
- [ ] Test inventory search/filter
- [ ] Test hotbar selection
- [ ] Test equipment equipping/unequipping
- [ ] Test container placement/access

---

## System 5: Interaction System

**Spec:** `technical-specs-interaction.md`

### InteractionManager Creation
- [ ] Create `scripts/managers/InteractionManager.gd`
- [ ] Set up as autoload singleton
- [ ] Create `InteractionValidator` class
- [ ] Create `InteractableObject` base class
- [ ] Add class documentation

### Interaction Detection
- [ ] Implement `find_nearby_interactables(position: Vector2, range: float) -> Array[InteractableObject]`:
  - [ ] Use Area2D or distance check
  - [ ] Filter by interaction range
  - [ ] Return sorted by distance
- [ ] Implement `get_closest_interactable(position: Vector2) -> InteractableObject`:
  - [ ] Find all nearby
  - [ ] Return closest
- [ ] Test interaction detection

### Interaction Execution
- [ ] Implement `start_interaction(interactable: InteractableObject) -> bool`:
  - [ ] Validate interaction
  - [ ] Check prerequisites
  - [ ] Execute interaction
  - [ ] Return success/failure
- [ ] Implement interaction prompts UI
- [ ] Implement interaction feedback
- [ ] Test interaction execution

### Specific Interaction Types
- [ ] Implement NPC interactions:
  - [ ] Extend InteractableObject
  - [ ] Open dialogue
  - [ ] Show interaction prompt
- [ ] Implement container interactions:
  - [ ] Open container UI
  - [ ] Transfer items
- [ ] Implement resource node interactions:
  - [ ] Start gathering
  - [ ] Show gathering progress
- [ ] Implement building interactions:
  - [ ] Open building menu
  - [ ] Show building options
- [ ] Implement environmental interactions:
  - [ ] Trigger environmental effects
  - [ ] Show interaction prompts
- [ ] Test each interaction type

### Testing
- [ ] Test interaction detection
- [ ] Test interaction prompts
- [ ] Test interaction feedback
- [ ] Test all interaction types

---

## System 6: Resource Gathering System

**Spec:** `technical-specs-resource-gathering.md`

### ResourceGatheringManager Creation
- [ ] Create `scripts/managers/ResourceGatheringManager.gd`
- [ ] Set up as autoload singleton
- [ ] Create `ResourceSpawner` class
- [ ] Create `ResourceNode` class
- [ ] Create `ResourceNodeData` resource
- [ ] Add class documentation

### Resource Node System
- [ ] Implement resource node registration
- [ ] Implement resource node spawning
- [ ] Implement resource node data loading
- [ ] Test resource node system

### Gathering Mechanics
- [ ] Implement `gather_resource(node: ResourceNode, tool: ItemData) -> bool`:
  - [ ] Validate tool requirements
  - [ ] Calculate gathering time
  - [ ] Calculate yield
  - [ ] Consume resources from node
  - [ ] Add items to inventory
  - [ ] Return success/failure
- [ ] Implement tool requirements validation
- [ ] Implement gathering time calculation
- [ ] Implement yield calculation (base + variance)
- [ ] Test gathering mechanics

### Resource Respawn
- [ ] Implement resource respawn system:
  - [ ] Track respawn timers
  - [ ] Check respawn chance
  - [ ] Restore resources on respawn
  - [ ] Update visuals
- [ ] Test resource respawn

### World Generation Integration
- [ ] Integrate with WorldGenerator
- [ ] Implement resource spawning during world generation
- [ ] Test resource distribution

### Testing
- [ ] Test resource gathering
- [ ] Test tool requirements
- [ ] Test resource respawn
- [ ] Test resource yield

---

## System 7: Crafting System

**Spec:** `technical-specs-crafting.md`

### CraftingManager Creation
- [ ] Create `scripts/managers/CraftingManager.gd`
- [ ] Set up as autoload singleton
- [ ] Create `RecipeRegistry` class
- [ ] Create `CraftingRecipe` resource
- [ ] Create `CraftingStation` resource
- [ ] Add class documentation

### Recipe System
- [ ] Implement recipe registration
- [ ] Implement recipe loading from resources
- [ ] Implement recipe discovery system:
  - [ ] Found recipes (from items/notes)
  - [ ] Learned recipes (from NPCs)
  - [ ] Unlocked recipes (from tech tree)
- [ ] Test recipe system

### Crafting Functions
- [ ] Implement `craft_recipe(recipe_id: String, quantity: int = 1) -> bool`:
  - [ ] Get recipe data
  - [ ] Check recipe availability
  - [ ] Validate ingredients
  - [ ] Consume ingredients
  - [ ] Create result items
  - [ ] Add to inventory (or drop if full)
  - [ ] Return success/failure
- [ ] Implement `craft_recipe_by_data(recipe: CraftingRecipe, quantity: int = 1) -> bool`
- [ ] Implement ingredient validation
- [ ] Implement ingredient consumption
- [ ] Implement ingredient refund on failure
- [ ] Implement inventory full handling (drop items)
- [ ] Test instant crafting

### Tech Tree Integration
- [ ] Integrate with ProgressionManager.tech_tree_manager
- [ ] Check if recipes unlocked via tech tree
- [ ] Test tech tree integration

### Testing
- [ ] Test recipe crafting
- [ ] Test ingredient validation
- [ ] Test recipe discovery
- [ ] Test tech tree integration
- [ ] Test inventory full handling

---

## System 8: Building System

**Spec:** `technical-specs-building.md`

### BuildingManager Creation
- [ ] Create `scripts/managers/BuildingManager.gd`
- [ ] Set up as autoload singleton
- [ ] Create `BuildingValidator` class
- [ ] Create `BuildingPiece` resource
- [ ] Create `PlacedBuilding` data structure
- [ ] Add class documentation

### Building Piece System
- [ ] Implement building piece registration
- [ ] Implement building piece loading
- [ ] Test building piece system

### Placement Functions
- [ ] Implement `place_building(piece_id: String, position: Vector2, grid_snap: bool = true) -> PlacedBuilding`:
  - [ ] Get building piece data
  - [ ] Validate placement position
  - [ ] Check material requirements
  - [ ] Consume materials from inventory
  - [ ] Create placed building
  - [ ] Add to world
  - [ ] Return placed building (or null on failure)
- [ ] Implement `remove_building(building: PlacedBuilding) -> bool`:
  - [ ] Remove from world
  - [ ] Refund materials (optional)
  - [ ] Return success/failure
- [ ] Test placement functions

### Placement Validation
- [ ] Implement grid snapping
- [ ] Implement freeform placement
- [ ] Implement placement validation:
  - [ ] Check if position is valid
  - [ ] Check for collisions
  - [ ] Check material requirements
  - [ ] Check prerequisites
- [ ] Test placement validation

### Material Management
- [ ] Implement material consumption
- [ ] Implement material refund on placement failure
- [ ] Test material management

### Structural Integrity (Optional)
- [ ] Implement structural integrity system (if enabled)
- [ ] Test structural integrity

### Pixel Physics Integration
- [ ] Integrate with PixelPhysicsManager
- [ ] Test building interacts with pixel physics

### Testing
- [ ] Test building placement
- [ ] Test placement validation
- [ ] Test material consumption
- [ ] Test structural integrity (if implemented)

---

## System 9: Combat System

**Spec:** `technical-specs-combat.md`

### CombatManager Creation
- [ ] Create `scripts/managers/CombatManager.gd`
- [ ] Set up as autoload singleton
- [ ] Create `WeaponData` resource
- [ ] Create `AttackData` data structure
- [ ] Create `CombatStats` data structure
- [ ] Add class documentation

### Weapon System
- [ ] Implement weapon types:
  - [ ] Melee weapons
  - [ ] Ranged weapons
  - [ ] Energy weapons
- [ ] Implement weapon equipping
- [ ] Implement weapon data loading
- [ ] Test weapon system

### Attack Functions
- [ ] Implement `perform_melee_attack(weapon: WeaponData, attacker: Node2D) -> AttackData`:
  - [ ] Calculate attack arc/range
  - [ ] Detect hit targets (Area2D)
  - [ ] Calculate damage
  - [ ] Apply damage
  - [ ] Return attack data
- [ ] Implement `perform_ranged_attack(weapon: WeaponData, attacker: Node2D, target: Vector2) -> AttackData`:
  - [ ] Create projectile
  - [ ] Fire projectile
  - [ ] Handle hit detection
  - [ ] Return attack data
- [ ] Implement `perform_energy_attack(weapon: WeaponData, attacker: Node2D, target: Vector2) -> AttackData`:
  - [ ] Create energy beam/projectile
  - [ ] Handle continuous damage
  - [ ] Return attack data
- [ ] Test all attack types

### Damage Calculation
- [ ] Implement damage calculation:
  - [ ] Base damage from weapon
  - [ ] Apply attacker stats
  - [ ] Apply target armor/resistance
  - [ ] Calculate critical hits
  - [ ] Apply final damage
- [ ] Test damage calculation

### Projectile System
- [ ] Create `scripts/projectiles/Projectile.gd` class
- [ ] Implement projectile movement
- [ ] Implement projectile hit detection
- [ ] Implement projectile pooling (for performance)
- [ ] Test projectile system

### Armor System
- [ ] Implement armor calculation
- [ ] Implement resistance calculation
- [ ] Test armor system

### Combat Stats
- [ ] Implement combat stats:
  - [ ] Attack, Defense
  - [ ] Critical chance, Critical multiplier
  - [ ] Attack speed
  - [ ] Range
- [ ] Test combat stats

### Status Effects Integration
- [ ] Integrate with StatusEffectManager
- [ ] Apply status effects on hit
- [ ] Test status effect integration

### Boss System
- [ ] Create `scripts/enemies/BossAI.gd` class
- [ ] Create `BossPhase` data structure
- [ ] Implement boss phase system
- [ ] Implement boss attack patterns
- [ ] Test boss fights

### Testing
- [ ] Test melee combat
- [ ] Test ranged combat
- [ ] Test energy weapons
- [ ] Test damage calculation
- [ ] Test armor system
- [ ] Test boss fights

---

## System 10: Status Effects System

**Spec:** `technical-specs-status-effects.md`

### StatusEffectManager Creation
- [ ] Create `scripts/managers/StatusEffectManager.gd`
- [ ] Set up as autoload singleton
- [ ] Create `StatusEffectApplier` class
- [ ] Create `StatusEffect` resource
- [ ] Create `StatusEffectInstance` data structure
- [ ] Add class documentation

### Effect Application
- [ ] Implement `apply_effect(effect_id: String, target: Node, source: Dictionary) -> bool`:
  - [ ] Get effect data
  - [ ] Check stacking rules
  - [ ] Create effect instance
  - [ ] Add to target's effects
  - [ ] Apply stat modifiers
  - [ ] Start effect timer
  - [ ] Return success/failure
- [ ] Test effect application

### Stacking Rules
- [ ] Implement per-effect stacking rules:
  - [ ] Refresh (reset duration)
  - [ ] Extend (add to duration)
  - [ ] Stack (add new instance)
  - [ ] Replace (remove old, add new)
- [ ] Test all stacking rules

### Stat Modifiers
- [ ] Implement stat modifier calculation:
  - [ ] Additive buffs
  - [ ] Multiplicative debuffs
  - [ ] Apply to all stats
- [ ] Test stat modifiers

### Effect Management
- [ ] Implement `update_effects(delta: float)` function:
  - [ ] Update all active effects
  - [ ] Decrease duration
  - [ ] Remove expired effects
- [ ] Implement `remove_effect(effect_id: String, target: Node) -> bool`
- [ ] Implement `cure_effect(effect_id: String, target: Node) -> bool`
- [ ] Test effect management

### Effect Interactions
- [ ] Implement effect interaction checks:
  - [ ] Specific cancellation pairs
  - [ ] Effect synergies
- [ ] Test effect interactions

### Source Tracking
- [ ] Implement source tracking:
  - [ ] Source type (weapon, item, environment, etc.)
  - [ ] Source ID
- [ ] Test source tracking

### Integration
- [ ] Integrate with Combat System
- [ ] Integrate with Survival System
- [ ] Test integration

### Testing
- [ ] Test effect application
- [ ] Test stacking rules
- [ ] Test stat modifiers
- [ ] Test effect interactions
- [ ] Test effect curing

---

## Integration Testing

### System Integration
- [ ] Test Survival + Inventory integration
- [ ] Test Inventory + Crafting integration
- [ ] Test Crafting + Building integration
- [ ] Test Combat + Status Effects integration
- [ ] Test all systems work together

### Gameplay Loop Testing
- [ ] Test complete gameplay loop:
  - [ ] Gather resources
  - [ ] Craft items
  - [ ] Build structures
  - [ ] Fight enemies
  - [ ] Manage survival stats
- [ ] Test gameplay feels good

### Performance Testing
- [ ] Test performance with all systems active
- [ ] Profile bottlenecks
- [ ] Optimize if needed
- [ ] Verify 60+ FPS target

---

## Completion Criteria

- [ ] All core gameplay systems implemented
- [ ] All systems tested individually
- [ ] All systems integrated and working together
- [ ] Gameplay loop functional
- [ ] Performance targets met
- [ ] Code documented
- [ ] Ready for Phase 3

---

## Next Phase

After completing Phase 2, proceed to **Phase 3: World & Environment Systems** where you'll implement:
- Pixel Physics System
- World Generation System
- Day/Night Cycle System
- Weather System

---

**Last Updated:** 2025-11-25  
**Status:** Ready to Start

