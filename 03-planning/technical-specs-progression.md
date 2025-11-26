# Technical Specifications: Progression System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the progression system including experience/leveling, skill tree, tech tree, achievements, and character progression. Supports multiple progression paths with skill points, research, and milestone tracking. This system integrates with all game systems for experience gain and achievement tracking.

---

## Research Notes

### Progression System Architecture Best Practices

**Research Findings:**
- Experience systems typically use exponential curves for leveling
- Skill trees use prerequisite chains to gate progression
- Tech trees unlock content (recipes, items) rather than stats
- Achievements track player milestones and provide rewards
- Respec systems allow skill point reallocation (with cost)

**Sources:**
- [Godot 4 Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Godot 4 Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data storage
- General progression system design patterns

**Implementation Approach:**
- ProgressionManager as autoload singleton
- Experience curve: exponential (base * multiplier^level)
- Skill tree: prerequisite chains, stat bonuses, ability unlocks
- Tech tree: research time + level requirement, unlocks recipes
- Achievements: event tracking, progress tracking, cosmetic rewards
- Respec: cost-based skill point refund

**Why This Approach:**
- Singleton: single source of truth for progression state
- Exponential curve: balanced progression scaling
- Prerequisites: prevent sequence breaking
- Research time: adds strategic element
- Event tracking: efficient achievement updates
- Respec cost: prevents abuse while allowing flexibility

### Experience System Best Practices

**Research Findings:**
- Experience from all activities (combat, crafting, building, exploring, quests, survival)
- Experience multipliers from skills/passives
- Level up awards skill points (1 per level)
- Experience curve prevents leveling too fast

**Sources:**
- General RPG progression patterns
- Experience curve mathematics

**Implementation Approach:**
- Subscribe to system events (enemy_killed, item_crafted, etc.)
- Award experience based on source
- Apply multipliers from skills
- Check level up after each experience gain
- Award skill point on level up

**Why This Approach:**
- All activities: encourages diverse gameplay
- Multipliers: reward skill investment
- Skill points: clear progression reward
- Curve: balanced progression pace

### Skill Tree Best Practices

**Research Findings:**
- Skills organized by category (combat, survival, crafting, etc.)
- Prerequisites prevent skipping ahead
- Skills provide stat bonuses, ability unlocks, passive effects
- Skill respec allows reallocation (with cost)

**Sources:**
- General skill tree design patterns

**Implementation Approach:**
- Skill categories: Combat, Survival, Crafting, Movement, Passive, Utility
- Prerequisites: array of skill IDs
- Effects: stat bonuses, ability unlocks, passive effects, multipliers
- Respec: refund skill points, apply cost

**Why This Approach:**
- Categories: organized progression paths
- Prerequisites: maintain progression order
- Effects: meaningful character growth
- Respec: allows experimentation

### Tech Tree Best Practices

**Research Findings:**
- Tech trees unlock content (recipes, building pieces, equipment)
- Research requires time + level requirement
- Prerequisites maintain unlock order
- Research progress tracked over time

**Sources:**
- General tech tree design patterns

**Implementation Approach:**
- Tech nodes unlock recipes (via CraftingManager)
- Research time: configurable seconds
- Level requirement: gates early unlocks
- Prerequisites: maintain unlock order
- Research progress: tracked in _process()

**Why This Approach:**
- Content unlock: gates progression appropriately
- Research time: adds strategic element
- Level requirement: prevents early unlocks
- Prerequisites: maintains progression order

### Achievement System Best Practices

**Research Findings:**
- Achievements track milestones (kill count, craft count, survive days, etc.)
- Progress tracked incrementally
- Rewards are cosmetic items
- Achievements unlock when target reached

**Sources:**
- General achievement system patterns

**Implementation Approach:**
- Event tracking: subscribe to system events
- Progress tracking: increment achievement progress
- Unlock check: check on progress update
- Cosmetic rewards: give cosmetic items on unlock

**Why This Approach:**
- Event tracking: efficient progress updates
- Incremental: accurate progress tracking
- Cosmetic rewards: non-gameplay affecting rewards
- Unlock check: automatic achievement completion

---

## Data Structures

### ExperienceSource

```gdscript
enum ExperienceSource {
    KILL_ENEMY,
    CRAFT_ITEM,
    BUILD_STRUCTURE,
    EXPLORE_AREA,
    COMPLETE_QUEST,
    SURVIVE_TIME,
    DISCOVER_RECIPE,
    DISCOVER_LOCATION,
    COLLECT_RESOURCE,
    CUSTOM
}
```

### SkillCategory

```gdscript
enum SkillCategory {
    COMBAT,
    SURVIVAL,
    CRAFTING,
    MOVEMENT,
    PASSIVE,
    UTILITY
}
```

### SkillNode

```gdscript
class_name SkillNode
extends Resource

@export var skill_id: String
@export var skill_name: String
@export var description: String
@export var category: SkillCategory
@export var icon: Texture2D

# Requirements
@export var skill_points_cost: int = 1
@export var level_requirement: int = 0
@export var prerequisites: Array[String] = []  # Skill IDs

# Effects
@export var stat_bonuses: Dictionary = {}  # stat_name -> bonus_value
@export var ability_unlocks: Array[String] = []  # Ability IDs
@export var passive_effects: Array[String] = []  # Passive effect IDs
@export var multiplier_bonuses: Dictionary = {}  # stat_name -> multiplier (e.g., "damage": 1.1 for 10% increase)

# State
@export var is_unlocked: bool = false
@export var is_purchased: bool = false
@export var purchase_order: int = 0  # Order in which skill was purchased
```

### TechTreeNode

```gdscript
class_name TechTreeNode
extends Resource

@export var node_id: String
@export var node_name: String
@export var description: String
@export var category: String  # "combat", "survival", "crafting", "building"
@export var icon: Texture2D

# Unlock Requirements
@export var level_requirement: int = 0  # Player level needed
@export var cost: Dictionary = {}  # resource_id -> quantity (resources needed to research)
@export var research_time_seconds: float = 0.0  # Time to research in seconds
@export var prerequisites: Array[String] = []  # Node IDs (other tech nodes that must be researched first)

# Unlocks
@export var unlocks_recipes: Array[String] = []  # Recipe IDs (crafting recipes)
@export var unlocks_building_pieces: Array[String] = []  # Building piece IDs
@export var unlocks_equipment: Array[String] = []  # Equipment IDs
@export var unlocks_abilities: Array[String] = []  # Ability IDs (optional)
@export var stat_bonuses: Dictionary = {}  # stat_name -> bonus_value (optional stat bonuses)

# Note: Runtime state (is_unlocked, is_researched, research_progress) is tracked in TechTreeManager, not in the Resource
# Resources are data definitions, runtime state belongs in managers
```

### AchievementData

```gdscript
class_name AchievementData
extends Resource

@export var achievement_id: String
@export var achievement_name: String
@export var description: String
@export var category: AchievementCategory
@export var icon: Texture2D

# Tracking
@export var tracking_type: TrackingType
@export var target_value: int = 1
@export var current_value: int = 0
@export var target_id: String = ""  # Item ID, enemy ID, etc.

# Rewards
@export var reward_cosmetic_items: Array[String] = []  # Cosmetic item IDs

# State
@export var is_unlocked: bool = false
@export var unlock_date: String = ""

enum AchievementCategory {
    COMBAT,
    SURVIVAL,
    CRAFTING,
    BUILDING,
    EXPLORATION,
    QUEST,
    MILESTONE,
    COLLECTION
}

enum TrackingType {
    KILL_COUNT,           # Kill X enemies
    CRAFT_COUNT,          # Craft X items
    SURVIVE_DAYS,         # Survive X days
    EXPLORE_BIOMES,       # Explore X biomes
    BUILD_COUNT,          # Build X structures
    COLLECT_COUNT,        # Collect X items
    QUEST_COMPLETE,       # Complete X quests
    DISTANCE_TRAVELED,    # Travel X distance
    LEVEL_REACHED,        # Reach level X
    CUSTOM
}
```

### PlayerLevel

```gdscript
class_name PlayerLevel
extends Resource

var current_level: int = 1
var current_experience: float = 0.0
var experience_to_next_level: float = 100.0
var total_experience: float = 0.0
var skill_points_available: int = 0
var skill_points_spent: int = 0

# Experience curve
var base_experience: float = 100.0
var experience_multiplier: float = 1.2  # Each level requires 20% more XP

func get_experience_for_level(level: int) -> float:
    return base_experience * pow(experience_multiplier, level - 1)
```

### ProgressionStats

```gdscript
class_name ProgressionStats
extends Resource

# Level and Experience
var level: int = 1
var experience: float = 0.0
var experience_to_next: float = 100.0
var total_experience: float = 0.0

# Skill Points
var skill_points_available: int = 0
var skill_points_spent: int = 0

# Stats from Skills
var stat_bonuses: Dictionary = {}  # stat_name -> total_bonus
var ability_unlocks: Array[String] = []
var passive_effects: Array[String] = []

# Research Progress
var researched_tech_nodes: Array[String] = []
var researching_node: String = ""
var research_progress: float = 0.0

# Achievements
var unlocked_achievements: Array[String] = []
var achievement_progress: Dictionary = {}  # achievement_id -> current_value
```

---

## Core Classes

### ProgressionManager

```gdscript
class_name ProgressionManager
extends Node

# Level System
var player_level: PlayerLevel
var experience_sources: Dictionary = {}  # ExperienceSource -> XP value

# Skill Tree
var skill_tree: Dictionary = {}  # skill_id -> SkillNode
var unlocked_skills: Dictionary = {}  # skill_id -> SkillNode
var purchased_skills: Dictionary = {}  # skill_id -> SkillNode

# Tech Tree
var tech_tree_manager: TechTreeManager  # TechTreeManager instance
var tech_tree: Dictionary = {}  # node_id -> TechTreeNode (backwards compatibility)
var unlocked_tech_nodes: Dictionary = {}  # node_id -> TechTreeNode (backwards compatibility)
var researched_tech_nodes: Dictionary = {}  # node_id -> TechTreeNode (backwards compatibility)
var currently_researching: TechTreeNode = null
var research_timer: float = 0.0

# Achievements
var achievement_database: Dictionary = {}  # achievement_id -> AchievementData
var unlocked_achievements: Dictionary = {}  # achievement_id -> AchievementData
var achievement_progress: Dictionary = {}  # achievement_id -> current_value

# Respec
var respec_cost: Dictionary = {}  # resource_id -> quantity
var respec_enabled: bool = true

# Signals
signal level_up(new_level: int)
signal experience_gained(amount: float, source: ExperienceSource)
signal skill_purchased(skill: SkillNode)
signal skill_unlocked(skill: SkillNode)
signal tech_node_unlocked(node: TechTreeNode)
signal tech_node_researched(node: TechTreeNode)
signal research_progressed(node: TechTreeNode, progress: float)
signal achievement_unlocked(achievement: AchievementData)
signal achievement_progressed(achievement: AchievementData, progress: int)

# Functions
func _ready() -> void
func _process(delta: float) -> void
func load_progression_data() -> void
func gain_experience(amount: float, source: ExperienceSource) -> void
func check_level_up() -> void
func level_up() -> void
func get_experience_for_level(level: int) -> float
func purchase_skill(skill_id: String) -> bool
func unlock_skill(skill_id: String) -> void
func can_purchase_skill(skill_id: String) -> bool
func check_skill_prerequisites(skill: SkillNode) -> bool
func start_research(node_id: String) -> bool
func update_research(delta: float) -> void
func complete_research(node: TechTreeNode) -> void
func can_research_node(node_id: String) -> bool
func check_tech_prerequisites(node: TechTreeNode) -> bool
func unlock_tech_node(node_id: String) -> void
func update_achievement_progress(achievement_id: String, progress: int) -> void
func check_achievement_unlock(achievement_id: String) -> void
func unlock_achievement(achievement: AchievementData) -> void
func respec_skills() -> bool
func get_total_stat_bonuses() -> Dictionary
func get_unlocked_abilities() -> Array[String]
func get_unlocked_passives() -> Array[String]
```

### SkillTreeManager

```gdscript
class_name SkillTreeManager
extends Node

var skill_tree_data: Dictionary = {}
var skill_categories: Dictionary = {}  # SkillCategory -> Array[SkillNode]

signal skill_tree_updated()

func _ready() -> void
func load_skill_tree() -> void
func get_skills_by_category(category: SkillCategory) -> Array[SkillNode]
func get_skill_by_id(skill_id: String) -> SkillNode
func get_available_skills() -> Array[SkillNode]
func get_purchased_skills() -> Array[SkillNode]
func visualize_skill_tree() -> void
```

### TechTreeManager

```gdscript
class_name TechTreeManager
extends Node

var tech_tree_data: Dictionary = {}  # node_id -> TechTreeNode
var tech_categories: Dictionary = {}  # category -> Array[TechTreeNode]
var unlocked_nodes: Array[String] = []  # Runtime: unlocked node IDs
var researched_nodes: Array[String] = []  # Runtime: researched node IDs
var research_in_progress: Dictionary = {}  # Runtime: node_id -> research_start_time

signal tech_tree_updated()
signal node_unlocked(node_id: String)
signal node_researched(node_id: String)

func _ready() -> void
func load_tech_tree() -> void
func get_nodes_by_category(category: String) -> Array[TechTreeNode]
func get_node_by_id(node_id: String) -> TechTreeNode
func get_available_nodes() -> Array[TechTreeNode]
func get_researched_nodes() -> Array[TechTreeNode]
func is_node_unlocked(node_id: String) -> bool
func is_node_researched(node_id: String) -> bool
func visualize_tech_tree() -> void
```

### AchievementManager

```gdscript
class_name AchievementManager
extends Node

var achievement_database: Dictionary = {}
var achievement_categories: Dictionary = {}  # AchievementCategory -> Array[AchievementData]

signal achievement_unlocked(achievement: AchievementData)
signal achievement_progressed(achievement: AchievementData)

func _ready() -> void
func load_achievements() -> void
func get_achievements_by_category(category: AchievementCategory) -> Array[AchievementData]
func get_achievement_by_id(achievement_id: String) -> AchievementData
func get_unlocked_achievements() -> Array[AchievementData]
func get_locked_achievements() -> Array[AchievementData]
func track_event(event_type: TrackingType, data: Dictionary) -> void
```

---

## System Architecture

### Component Hierarchy

```
ProgressionManager (Autoload Singleton)
├── SkillTreeManager
├── TechTreeManager
└── AchievementManager
```

### Data Flow

1. **Experience Gain:**
   - Game event occurs (enemy killed, item crafted, etc.) → `gain_experience()` called
   - Add experience to current level → Check if level up → `level_up()` if threshold reached
   - Award skill point → Update UI

2. **Skill Purchase:**
   - Player selects skill → `can_purchase_skill()` checks prerequisites and available points
   - If valid → `purchase_skill()` → Deduct skill points → Apply skill effects → Update stats

3. **Tech Research:**
   - Player selects tech node → `can_research_node()` checks prerequisites and level
   - If valid → `start_research()` → Begin research timer → `update_research()` each frame
   - When timer complete → `complete_research()` → Unlock recipes → Update UI

4. **Achievement Tracking:**
   - Game event occurs → `AchievementManager.track_event()` → Update achievement progress
   - Check if achievement complete → `unlock_achievement()` → Give rewards → Show notification

---

## Algorithms

### Experience Gain Algorithm

```gdscript
func gain_experience(amount: float, source: ExperienceSource) -> void:
    # Apply any multipliers from skills/passives
    var multiplier = get_experience_multiplier(source)
    var final_amount = amount * multiplier
    
    # Add to current experience
    player_level.current_experience += final_amount
    player_level.total_experience += final_amount
    
    emit_signal("experience_gained", final_amount, source)
    
    # Check for level up
    check_level_up()

func check_level_up() -> void:
    while player_level.current_experience >= player_level.experience_to_next_level:
        level_up()

func level_up() -> void:
    # Deduct experience cost
    player_level.current_experience -= player_level.experience_to_next_level
    
    # Increase level
    player_level.current_level += 1
    
    # Award skill point (1 per level)
    player_level.skill_points_available += 1
    
    # Calculate next level requirement
    player_level.experience_to_next_level = get_experience_for_level(player_level.current_level + 1)
    
    emit_signal("level_up", player_level.current_level)
    
    # Check achievements
    if AchievementManager:
        AchievementManager.track_event(TrackingType.LEVEL_REACHED, {"level": player_level.current_level})
    
    # Show notification
    if NotificationManager:
        var notification = NotificationData.new()
        notification.message = "Level Up! Level " + str(player_level.current_level)
        notification.type = NotificationData.NotificationType.SUCCESS
        NotificationManager.show_notification(notification)
```

### Skill Purchase Algorithm

```gdscript
func purchase_skill(skill_id: String) -> bool:
    var skill = skill_tree.get(skill_id)
    if not skill:
        return false
    
    # Check if already purchased
    if skill.is_purchased:
        return false
    
    # Check prerequisites
    if not can_purchase_skill(skill_id):
        return false
    
    # Check available skill points
    if player_level.skill_points_available < skill.skill_points_cost:
        return false
    
    # Purchase skill
    skill.is_purchased = true
    skill.purchase_order = purchased_skills.size()
    player_level.skill_points_available -= skill.skill_points_cost
    player_level.skill_points_spent += skill.skill_points_cost
    
    # Add to purchased skills
    purchased_skills[skill_id] = skill
    
    # Apply skill effects
    apply_skill_effects(skill)
    
    # Unlock dependent skills
    unlock_dependent_skills(skill_id)
    
    emit_signal("skill_purchased", skill)
    return true

func can_purchase_skill(skill_id: String) -> bool:
    var skill = skill_tree.get(skill_id)
    if not skill:
        return false
    
    # Check level requirement
    if player_level.current_level < skill.level_requirement:
        return false
    
    # Check prerequisites
    for prereq_id in skill.prerequisites:
        var prereq = purchased_skills.get(prereq_id)
        if not prereq or not prereq.is_purchased:
            return false
    
    return true

func apply_skill_effects(skill: SkillNode) -> void:
    # Apply stat bonuses
    for stat_name in skill.stat_bonuses:
        var bonus = skill.stat_bonuses[stat_name]
        if not player_level.stat_bonuses.has(stat_name):
            player_level.stat_bonuses[stat_name] = 0.0
        player_level.stat_bonuses[stat_name] += bonus
    
    # Unlock abilities
    for ability_id in skill.ability_unlocks:
        if ability_id not in player_level.ability_unlocks:
            player_level.ability_unlocks.append(ability_id)
    
    # Apply passive effects
    for passive_id in skill.passive_effects:
        if passive_id not in player_level.passive_effects:
            player_level.passive_effects.append(passive_id)
    
    # Apply multipliers
    for stat_name in skill.multiplier_bonuses:
        var multiplier = skill.multiplier_bonuses[stat_name]
        # Store multiplier separately for calculation
        if not player_level.multiplier_bonuses.has(stat_name):
            player_level.multiplier_bonuses[stat_name] = 1.0
        player_level.multiplier_bonuses[stat_name] *= multiplier
```

### Tech Research Algorithm

```gdscript
func start_research(node_id: String) -> bool:
    var node = tech_tree.get(node_id)
    if not node:
        return false
    
    # Check if already researched
    if node.is_researched:
        return false
    
    # Check prerequisites
    if not can_research_node(node_id):
        return false
    
    # Check if already researching something
    if currently_researching != null:
        return false
    
    # Start research
    currently_researching = node
    node.is_unlocked = true
    node.research_start_time = Time.get_ticks_msec() / 1000.0
    research_timer = 0.0
    
    emit_signal("tech_node_unlocked", node)
    return true

func update_research(delta: float) -> void:
    if currently_researching == null:
        return
    
    # Update research progress
    research_timer += delta
    var progress = research_timer / currently_researching.research_time_seconds
    currently_researching.research_progress = min(progress, 1.0)
    
    emit_signal("research_progressed", currently_researching, progress)
    
    # Check if research complete
    if research_timer >= currently_researching.research_time_seconds:
        complete_research(currently_researching)

func complete_research(node: TechTreeNode) -> void:
    node.is_researched = true
    node.research_progress = 1.0
    
    # Unlock recipes via CraftingManager
    if CraftingManager:
        for recipe_id in node.unlocks_recipes:
            CraftingManager.discover_recipe(recipe_id)
    
    # Add to researched nodes
    researched_tech_nodes[node.node_id] = node
    
    # Unlock dependent nodes
    unlock_dependent_tech_nodes(node.node_id)
    
    # Clear current research
    currently_researching = null
    research_timer = 0.0
    
    emit_signal("tech_node_researched", node)
    
    # Show notification
    if NotificationManager:
        var notification = NotificationData.new()
        notification.message = "Research Complete: " + node.node_name
        notification.type = NotificationData.NotificationType.SUCCESS
        NotificationManager.show_notification(notification)
```

### Achievement Tracking Algorithm

```gdscript
func track_event(event_type: TrackingType, data: Dictionary) -> void:
    # Find all achievements that track this event type
    for achievement_id in achievement_database:
        var achievement = achievement_database[achievement_id]
        
        if achievement.tracking_type != event_type:
            continue
        
        if achievement.is_unlocked:
            continue
        
        # Update progress based on event type
        match event_type:
            TrackingType.KILL_COUNT:
                if achievement.target_id.is_empty() or achievement.target_id == data.get("enemy_id"):
                    update_achievement_progress(achievement_id, 1)
            
            TrackingType.CRAFT_COUNT:
                if achievement.target_id.is_empty() or achievement.target_id == data.get("item_id"):
                    update_achievement_progress(achievement_id, 1)
            
            TrackingType.SURVIVE_DAYS:
                update_achievement_progress(achievement_id, data.get("days", 0))
            
            TrackingType.EXPLORE_BIOMES:
                if achievement.target_id.is_empty() or achievement.target_id == data.get("biome_id"):
                    update_achievement_progress(achievement_id, 1)
            
            TrackingType.BUILD_COUNT:
                if achievement.target_id.is_empty() or achievement.target_id == data.get("structure_id"):
                    update_achievement_progress(achievement_id, 1)
            
            TrackingType.LEVEL_REACHED:
                if data.get("level", 0) >= achievement.target_value:
                    update_achievement_progress(achievement_id, achievement.target_value)

func update_achievement_progress(achievement_id: String, progress: int) -> void:
    var achievement = achievement_database.get(achievement_id)
    if not achievement:
        return
    
    # Update current value
    if not achievement_progress.has(achievement_id):
        achievement_progress[achievement_id] = 0
    
    achievement_progress[achievement_id] += progress
    achievement.current_value = achievement_progress[achievement_id]
    
    emit_signal("achievement_progressed", achievement, achievement.current_value)
    
    # Check if achievement complete
    if achievement.current_value >= achievement.target_value:
        check_achievement_unlock(achievement_id)

func check_achievement_unlock(achievement_id: String) -> void:
    var achievement = achievement_database.get(achievement_id)
    if not achievement or achievement.is_unlocked:
        return
    
    if achievement.current_value >= achievement.target_value:
        unlock_achievement(achievement)

func unlock_achievement(achievement: AchievementData) -> void:
    achievement.is_unlocked = true
    achievement.unlock_date = Time.get_datetime_string_from_system()
    
    unlocked_achievements[achievement.achievement_id] = achievement
    
    # Give rewards
    give_achievement_rewards(achievement)
    
    # Show notification
    if NotificationManager:
        var notification = NotificationData.new()
        notification.message = "Achievement Unlocked: " + achievement.achievement_name
        notification.type = NotificationData.NotificationType.ACHIEVEMENT
        NotificationManager.show_notification(notification)
    
    emit_signal("achievement_unlocked", achievement)

func give_achievement_rewards(achievement: AchievementData) -> void:
    # Give cosmetic items (via InventoryManager when cosmetic system implemented)
    if InventoryManager:
        for cosmetic_item_id in achievement.reward_cosmetic_items:
            InventoryManager.add_item(cosmetic_item_id, 1)
```

### Experience Gain Integration (Integrates with All Systems)

```gdscript
func _ready() -> void:
    # Subscribe to CombatManager signals
    if CombatManager:
        CombatManager.enemy_killed.connect(_on_enemy_killed)
    
    # Subscribe to CraftingManager signals
    if CraftingManager:
        CraftingManager.item_crafted.connect(_on_item_crafted)
        CraftingManager.recipe_discovered.connect(_on_recipe_discovered)
    
    # Subscribe to BuildingManager signals
    if BuildingManager:
        BuildingManager.building_placed.connect(_on_building_placed)
    
    # Subscribe to QuestManager signals
    if QuestManager:
        QuestManager.quest_completed.connect(_on_quest_completed)
    
    # Subscribe to SurvivalManager signals
    if SurvivalManager:
        SurvivalManager.day_passed.connect(_on_day_passed)
    
    # Subscribe to MinimapManager signals (when implemented)
    # MinimapManager.area_explored.connect(_on_area_explored)
    
    # Subscribe to ResourceGatheringManager signals (when implemented)
    # ResourceGatheringManager.resource_collected.connect(_on_resource_collected)

func _on_enemy_killed(enemy_id: String, enemy_type: String) -> void:
    # Get XP value from experience sources
    var xp_amount = experience_sources.get(ExperienceSource.KILL_ENEMY, 10.0)
    gain_experience(xp_amount, ExperienceSource.KILL_ENEMY)
    
    # Track achievement
    if AchievementManager:
        AchievementManager.track_event(TrackingType.KILL_COUNT, {"enemy_id": enemy_id, "enemy_type": enemy_type})

func _on_item_crafted(item_id: String) -> void:
    var xp_amount = experience_sources.get(ExperienceSource.CRAFT_ITEM, 5.0)
    gain_experience(xp_amount, ExperienceSource.CRAFT_ITEM)
    
    # Track achievement
    if AchievementManager:
        AchievementManager.track_event(TrackingType.CRAFT_COUNT, {"item_id": item_id})

func _on_recipe_discovered(recipe_id: String) -> void:
    var xp_amount = experience_sources.get(ExperienceSource.DISCOVER_RECIPE, 15.0)
    gain_experience(xp_amount, ExperienceSource.DISCOVER_RECIPE)

func _on_building_placed(building_id: String) -> void:
    var xp_amount = experience_sources.get(ExperienceSource.BUILD_STRUCTURE, 3.0)
    gain_experience(xp_amount, ExperienceSource.BUILD_STRUCTURE)
    
    # Track achievement
    if AchievementManager:
        AchievementManager.track_event(TrackingType.BUILD_COUNT, {"structure_id": building_id})

func _on_quest_completed(quest: QuestData) -> void:
    # Quest rewards include XP, but also award base XP for completion
    var xp_amount = experience_sources.get(ExperienceSource.COMPLETE_QUEST, 50.0)
    gain_experience(xp_amount, ExperienceSource.COMPLETE_QUEST)
    
    # Track achievement
    if AchievementManager:
        AchievementManager.track_event(TrackingType.QUEST_COMPLETE, {"quest_id": quest.quest_id})

func _on_day_passed(day: int) -> void:
    var xp_amount = experience_sources.get(ExperienceSource.SURVIVE_TIME, 20.0)
    gain_experience(xp_amount, ExperienceSource.SURVIVE_TIME)
    
    # Track achievement
    if AchievementManager:
        AchievementManager.track_event(TrackingType.SURVIVE_DAYS, {"days": day})
    for cosmetic_id in achievement.reward_cosmetic_items:
        InventoryManager.add_item(ItemDatabase.get_item(cosmetic_id), 1)
```

### Respec Algorithm

```gdscript
func respec_skills() -> bool:
    if not respec_enabled:
        return false
    
    # Check if player can afford respec cost
    if not InventoryManager.has_items(respec_cost):
        return false
    
    # Deduct respec cost
    for item_id in respec_cost:
        var quantity = respec_cost[item_id]
        InventoryManager.remove_item(ItemDatabase.get_item(item_id), quantity)
    
    # Refund all skill points
    var total_refunded = player_level.skill_points_spent
    player_level.skill_points_available += total_refunded
    player_level.skill_points_spent = 0
    
    # Remove all skill effects
    for skill_id in purchased_skills:
        var skill = purchased_skills[skill_id]
        remove_skill_effects(skill)
        skill.is_purchased = false
    
    # Clear purchased skills
    purchased_skills.clear()
    
    # Reset stat bonuses
    player_level.stat_bonuses.clear()
    player_level.ability_unlocks.clear()
    player_level.passive_effects.clear()
    player_level.multiplier_bonuses.clear()
    
    # Re-unlock skills that don't have prerequisites
    for skill_id in skill_tree:
        var skill = skill_tree[skill_id]
        if skill.prerequisites.is_empty() and skill.level_requirement <= player_level.current_level:
            skill.is_unlocked = true
    
    return true

func remove_skill_effects(skill: SkillNode) -> void:
    # Remove stat bonuses
    for stat_name in skill.stat_bonuses:
        var bonus = skill.stat_bonuses[stat_name]
        if player_level.stat_bonuses.has(stat_name):
            player_level.stat_bonuses[stat_name] -= bonus
    
    # Remove abilities (only if no other skill provides them)
    for ability_id in skill.ability_unlocks:
        var has_other_source = false
        for other_skill_id in purchased_skills:
            if other_skill_id == skill.skill_id:
                continue
            var other_skill = purchased_skills[other_skill_id]
            if ability_id in other_skill.ability_unlocks:
                has_other_source = true
                break
        
        if not has_other_source:
            player_level.ability_unlocks.erase(ability_id)
    
    # Remove multipliers
    for stat_name in skill.multiplier_bonuses:
        var multiplier = skill.multiplier_bonuses[stat_name]
        if player_level.multiplier_bonuses.has(stat_name):
            player_level.multiplier_bonuses[stat_name] /= multiplier
```

---

## Integration Points

### With Combat System
- Track enemy kills for experience and achievements
- Apply combat skill bonuses
- Unlock combat abilities

### With Crafting System
- Track crafting for experience and achievements
- Unlock recipes through tech tree
- Apply crafting skill bonuses

### With Building System
- Track building for experience and achievements
- Unlock building pieces through tech tree
- Apply building skill bonuses

### With Survival System
- Track survival time for experience and achievements
- Apply survival skill bonuses
- Unlock survival abilities

### With Quest System
- Give experience rewards from quests
- Track quest completion for achievements
- Unlock quests through progression

### With Inventory System
- Check respec cost items
- Give achievement cosmetic rewards

### With UI System
- Display skill tree UI
- Display tech tree UI
- Display achievement list
- Show level up notifications
- Show achievement unlock notifications

### With Save System
- Save level and experience
- Save skill purchases
- Save tech research progress
- Save achievement progress

---

## Save/Load System

### Progression Save Data

```gdscript
class_name ProgressionSaveData
extends Resource

var level: int = 1
var experience: float = 0.0
var experience_to_next: float = 100.0
var total_experience: float = 0.0
var skill_points_available: int = 0
var skill_points_spent: int = 0
var purchased_skills: Array[String] = []
var researched_tech_nodes: Array[String] = []
var currently_researching_node: String = ""
var research_progress: float = 0.0
var research_start_time: float = 0.0
var unlocked_achievements: Array[String] = []
var achievement_progress: Dictionary = {}
```

### Save Function

```gdscript
func save_progression_data() -> Dictionary:
    var save_data = {
        "level": player_level.current_level,
        "experience": player_level.current_experience,
        "experience_to_next": player_level.experience_to_next_level,
        "total_experience": player_level.total_experience,
        "skill_points_available": player_level.skill_points_available,
        "skill_points_spent": player_level.skill_points_spent,
        "purchased_skills": [],
        "researched_tech_nodes": [],
        "currently_researching_node": "",
        "research_progress": 0.0,
        "research_start_time": 0.0,
        "unlocked_achievements": [],
        "achievement_progress": {}
    }
    
    # Save purchased skills
    for skill_id in purchased_skills:
        save_data.purchased_skills.append(skill_id)
    
    # Save researched tech nodes
    for node_id in researched_tech_nodes:
        save_data.researched_tech_nodes.append(node_id)
    
    # Save current research
    if currently_researching:
        save_data.currently_researching_node = currently_researching.node_id
        save_data.research_progress = currently_researching.research_progress
        save_data.research_start_time = currently_researching.research_start_time
    
    # Save unlocked achievements
    for achievement_id in unlocked_achievements:
        save_data.unlocked_achievements.append(achievement_id)
    
    # Save achievement progress
    save_data.achievement_progress = achievement_progress.duplicate()
    
    return save_data
```

### Load Function

```gdscript
func load_progression_data(save_data: Dictionary) -> void:
    # Load level and experience
    player_level.current_level = save_data.get("level", 1)
    player_level.current_experience = save_data.get("experience", 0.0)
    player_level.experience_to_next_level = save_data.get("experience_to_next", 100.0)
    player_level.total_experience = save_data.get("total_experience", 0.0)
    player_level.skill_points_available = save_data.get("skill_points_available", 0)
    player_level.skill_points_spent = save_data.get("skill_points_spent", 0)
    
    # Load purchased skills
    purchased_skills.clear()
    for skill_id in save_data.get("purchased_skills", []):
        var skill = skill_tree.get(skill_id)
        if skill:
            skill.is_purchased = true
            purchased_skills[skill_id] = skill
            apply_skill_effects(skill)
    
    # Load researched tech nodes
    researched_tech_nodes.clear()
    for node_id in save_data.get("researched_tech_nodes", []):
        var node = tech_tree.get(node_id)
        if node:
            node.is_researched = true
            researched_tech_nodes[node_id] = node
            # Unlock recipes
            for recipe_id in node.unlocks_recipes:
                CraftingSystem.unlock_recipe(recipe_id)
    
    # Load current research
    var researching_id = save_data.get("currently_researching_node", "")
    if researching_id != "":
        var node = tech_tree.get(researching_id)
        if node:
            currently_researching = node
            research_timer = save_data.get("research_progress", 0.0) * node.research_time_seconds
            node.research_progress = save_data.get("research_progress", 0.0)
    
    # Load achievements
    unlocked_achievements.clear()
    for achievement_id in save_data.get("unlocked_achievements", []):
        var achievement = achievement_database.get(achievement_id)
        if achievement:
            achievement.is_unlocked = true
            unlocked_achievements[achievement_id] = achievement
    
    # Load achievement progress
    achievement_progress = save_data.get("achievement_progress", {}).duplicate()
    for achievement_id in achievement_progress:
        var achievement = achievement_database.get(achievement_id)
        if achievement:
            achievement.current_value = achievement_progress[achievement_id]
```

---

## Performance Considerations

### Optimization Strategies

1. **Experience Tracking:**
   - Batch experience gains when possible
   - Cache experience multipliers
   - Limit level up checks to once per frame

2. **Skill Tree:**
   - Cache prerequisite checks
   - Only update affected skills when purchasing
   - Use dirty flags for stat recalculation

3. **Tech Research:**
   - Only update research timer for active research
   - Cache research completion checks
   - Batch recipe unlocks

4. **Achievement Tracking:**
   - Only check achievements on relevant events
   - Cache achievement lookups
   - Batch achievement progress updates

5. **UI Updates:**
   - Only update changed UI elements
   - Use signals for efficient updates
   - Limit UI refresh rate

---

## Testing Checklist

### Level System
- [ ] Experience gained from all sources
- [ ] Level up works correctly
- [ ] Skill point awarded on level up (1 per level)
- [ ] Experience curve works correctly
- [ ] Level up notifications show

### Skill Tree
- [ ] Skills can be purchased with skill points
- [ ] Prerequisites block purchase
- [ ] Level requirements block purchase
- [ ] Skill effects apply correctly
- [ ] Stat bonuses accumulate
- [ ] Abilities unlock correctly
- [ ] Passive effects apply
- [ ] Dependent skills unlock

### Tech Tree
- [ ] Tech nodes unlock when prerequisites met
- [ ] Level requirement blocks research
- [ ] Research timer works correctly
- [ ] Research completes correctly
- [ ] Recipes unlock when research completes
- [ ] Only one research at a time
- [ ] Research progress saves/loads

### Achievements
- [ ] All achievement types track correctly
- [ ] Achievement progress updates
- [ ] Achievements unlock when complete
- [ ] Cosmetic rewards given
- [ ] Achievement notifications show
- [ ] Achievement progress saves/loads

### Respec
- [ ] Respec costs items correctly
- [ ] All skill points refunded
- [ ] All skill effects removed
- [ ] Skills reset correctly
- [ ] Can repurchase skills after respec

### Integration
- [ ] Experience from combat works
- [ ] Experience from crafting works
- [ ] Experience from building works
- [ ] Experience from quests works
- [ ] Skill bonuses apply to gameplay
- [ ] Tech unlocks recipes correctly
- [ ] Achievements track from all systems

---

## Error Handling

### ProgressionManager Error Handling

- **Invalid Skill/Tech IDs:** Validate IDs before operations, return errors gracefully
- **Missing Resources:** Handle missing skill/tech/achievement resources gracefully
- **Insufficient Skill Points:** Handle skill purchase failures gracefully
- **Research Conflicts:** Handle multiple research attempts gracefully
- **Achievement Tracking Errors:** Handle invalid achievement updates gracefully

### Best Practices

- Use `push_error()` for critical errors (invalid IDs, missing resources)
- Use `push_warning()` for non-critical issues (insufficient points, already purchased)
- Return false/null on errors (don't crash)
- Validate all data before operations
- Handle missing system managers gracefully

---

## Default Values and Configuration

### ProgressionManager Defaults

```gdscript
# Experience Sources (XP amounts)
experience_sources = {
    ExperienceSource.KILL_ENEMY: 10.0,
    ExperienceSource.CRAFT_ITEM: 5.0,
    ExperienceSource.BUILD_STRUCTURE: 3.0,
    ExperienceSource.EXPLORE_AREA: 15.0,
    ExperienceSource.COMPLETE_QUEST: 50.0,
    ExperienceSource.SURVIVE_TIME: 20.0,
    ExperienceSource.DISCOVER_RECIPE: 15.0,
    ExperienceSource.DISCOVER_LOCATION: 25.0,
    ExperienceSource.COLLECT_RESOURCE: 2.0
}

# Respec Configuration
respec_enabled = true
respec_cost = {}  # Configure per save file
```

### PlayerLevel Defaults

```gdscript
current_level = 1
current_experience = 0.0
experience_to_next_level = 100.0
total_experience = 0.0
skill_points_available = 0
skill_points_spent = 0
base_experience = 100.0
experience_multiplier = 1.2  # 20% increase per level
```

### SkillNode Defaults

```gdscript
skill_id = ""
skill_name = ""
description = ""
category = SkillCategory.PASSIVE
icon = null
skill_points_cost = 1
level_requirement = 0
prerequisites = []
stat_bonuses = {}
ability_unlocks = []
passive_effects = []
multiplier_bonuses = {}
is_unlocked = false
is_purchased = false
purchase_order = 0
```

### TechTreeNode Defaults

```gdscript
node_id = ""
node_name = ""
description = ""
category = ""
icon = null
level_requirement = 0
research_time_seconds = 0.0
prerequisites = []
unlocks_recipes = []
is_unlocked = false
is_researched = false
research_progress = 0.0
research_start_time = 0.0
```

### AchievementData Defaults

```gdscript
achievement_id = ""
achievement_name = ""
description = ""
category = AchievementCategory.MILESTONE
icon = null
tracking_type = TrackingType.CUSTOM
target_value = 1
current_value = 0
target_id = ""
reward_cosmetic_items = []
is_unlocked = false
unlock_date = ""
```

---

## Complete Implementation

### ProgressionManager Complete Implementation

```gdscript
class_name ProgressionManager
extends Node

# Level System
var player_level: PlayerLevel = PlayerLevel.new()
var experience_sources: Dictionary = {
    ExperienceSource.KILL_ENEMY: 10.0,
    ExperienceSource.CRAFT_ITEM: 5.0,
    ExperienceSource.BUILD_STRUCTURE: 3.0,
    ExperienceSource.EXPLORE_AREA: 15.0,
    ExperienceSource.COMPLETE_QUEST: 50.0,
    ExperienceSource.SURVIVE_TIME: 20.0,
    ExperienceSource.DISCOVER_RECIPE: 15.0,
    ExperienceSource.DISCOVER_LOCATION: 25.0,
    ExperienceSource.COLLECT_RESOURCE: 2.0
}

# Skill Tree
var skill_tree: Dictionary = {}
var unlocked_skills: Dictionary = {}
var purchased_skills: Dictionary = {}

# Tech Tree
var tech_tree: Dictionary = {}
var unlocked_tech_nodes: Dictionary = {}
var researched_tech_nodes: Dictionary = {}
var currently_researching: TechTreeNode = null
var research_timer: float = 0.0

# Achievements
var achievement_database: Dictionary = {}
var unlocked_achievements: Dictionary = {}
var achievement_progress: Dictionary = {}

# Respec
var respec_cost: Dictionary = {}
var respec_enabled: bool = true

# Signals
signal level_up(new_level: int)
signal experience_gained(amount: float, source: ExperienceSource)
signal skill_purchased(skill: SkillNode)
signal skill_unlocked(skill: SkillNode)
signal tech_node_unlocked(node: TechTreeNode)
signal tech_node_researched(node: TechTreeNode)
signal research_progressed(node: TechTreeNode, progress: float)
signal achievement_unlocked(achievement: AchievementData)
signal achievement_progressed(achievement: AchievementData, progress: int)

func _ready() -> void:
    load_progression_data()
    
    # Subscribe to system signals
    if CombatManager:
        CombatManager.enemy_killed.connect(_on_enemy_killed)
    
    if CraftingManager:
        CraftingManager.item_crafted.connect(_on_item_crafted)
        CraftingManager.recipe_discovered.connect(_on_recipe_discovered)
    
    if BuildingManager:
        BuildingManager.building_placed.connect(_on_building_placed)
    
    if QuestManager:
        QuestManager.quest_completed.connect(_on_quest_completed)
    
    if SurvivalManager:
        SurvivalManager.day_passed.connect(_on_day_passed)

func _process(delta: float) -> void:
    # Update research progress
    update_research(delta)

func gain_experience(amount: float, source: ExperienceSource) -> void:
    # Apply multipliers from skills/passives
    var multiplier = get_experience_multiplier(source)
    var final_amount = amount * multiplier
    
    # Add to current experience
    player_level.current_experience += final_amount
    player_level.total_experience += final_amount
    
    experience_gained.emit(final_amount, source)
    
    # Check for level up
    check_level_up()

func check_level_up() -> void:
    while player_level.current_experience >= player_level.experience_to_next_level:
        level_up()

func level_up() -> void:
    # Deduct experience cost
    player_level.current_experience -= player_level.experience_to_next_level
    
    # Increase level
    player_level.current_level += 1
    
    # Award skill point (1 per level)
    player_level.skill_points_available += 1
    
    # Calculate next level requirement
    player_level.experience_to_next_level = get_experience_for_level(player_level.current_level + 1)
    
    level_up.emit(player_level.current_level)
    
    # Check achievements
    if AchievementManager:
        AchievementManager.track_event(TrackingType.LEVEL_REACHED, {"level": player_level.current_level})
    
    # Show notification
    if NotificationManager:
        var notification = NotificationData.new()
        notification.message = "Level Up! Level " + str(player_level.current_level)
        notification.type = NotificationData.NotificationType.SUCCESS
        NotificationManager.show_notification(notification)

func get_experience_for_level(level: int) -> float:
    return player_level.base_experience * pow(player_level.experience_multiplier, level - 1)

func get_experience_multiplier(source: ExperienceSource) -> float:
    # Get multipliers from purchased skills
    var multiplier = 1.0
    
    for skill_id in purchased_skills:
        var skill = purchased_skills[skill_id]
        if skill.multiplier_bonuses.has("experience_" + ExperienceSource.keys()[source].to_lower()):
            multiplier *= skill.multiplier_bonuses["experience_" + ExperienceSource.keys()[source].to_lower()]
    
    return multiplier

func purchase_skill(skill_id: String) -> bool:
    var skill = skill_tree.get(skill_id)
    if not skill:
        push_warning("ProgressionManager: Skill not found: " + skill_id)
        return false
    
    if skill.is_purchased:
        push_warning("ProgressionManager: Skill already purchased: " + skill_id)
        return false
    
    if not can_purchase_skill(skill_id):
        return false
    
    if player_level.skill_points_available < skill.skill_points_cost:
        push_warning("ProgressionManager: Insufficient skill points")
        return false
    
    # Purchase skill
    skill.is_purchased = true
    skill.purchase_order = purchased_skills.size()
    player_level.skill_points_available -= skill.skill_points_cost
    player_level.skill_points_spent += skill.skill_points_cost
    
    purchased_skills[skill_id] = skill
    
    # Apply skill effects
    apply_skill_effects(skill)
    
    # Unlock dependent skills
    unlock_dependent_skills(skill_id)
    
    skill_purchased.emit(skill)
    return true

func can_purchase_skill(skill_id: String) -> bool:
    var skill = skill_tree.get(skill_id)
    if not skill:
        return false
    
    if player_level.current_level < skill.level_requirement:
        return false
    
    for prereq_id in skill.prerequisites:
        var prereq = purchased_skills.get(prereq_id)
        if not prereq or not prereq.is_purchased:
            return false
    
    return true

func apply_skill_effects(skill: SkillNode) -> void:
    # Apply stat bonuses
    for stat_name in skill.stat_bonuses:
        var bonus = skill.stat_bonuses[stat_name]
        if not player_level.stat_bonuses.has(stat_name):
            player_level.stat_bonuses[stat_name] = 0.0
        player_level.stat_bonuses[stat_name] += bonus
    
    # Unlock abilities
    for ability_id in skill.ability_unlocks:
        if ability_id not in player_level.ability_unlocks:
            player_level.ability_unlocks.append(ability_id)
    
    # Apply passive effects
    for passive_id in skill.passive_effects:
        if passive_id not in player_level.passive_effects:
            player_level.passive_effects.append(passive_id)
    
    # Apply multipliers
    for stat_name in skill.multiplier_bonuses:
        var multiplier = skill.multiplier_bonuses[stat_name]
        if not player_level.multiplier_bonuses.has(stat_name):
            player_level.multiplier_bonuses[stat_name] = 1.0
        player_level.multiplier_bonuses[stat_name] *= multiplier

func unlock_dependent_skills(skill_id: String) -> void:
    for other_skill_id in skill_tree:
        var other_skill = skill_tree[other_skill_id]
        if skill_id in other_skill.prerequisites:
            if check_skill_prerequisites(other_skill):
                unlock_skill(other_skill_id)

func unlock_skill(skill_id: String) -> void:
    var skill = skill_tree.get(skill_id)
    if not skill or skill.is_unlocked:
        return
    
    skill.is_unlocked = true
    unlocked_skills[skill_id] = skill
    skill_unlocked.emit(skill)

func check_skill_prerequisites(skill: SkillNode) -> bool:
    for prereq_id in skill.prerequisites:
        var prereq = purchased_skills.get(prereq_id)
        if not prereq or not prereq.is_purchased:
            return false
    return true

func start_research(node_id: String) -> bool:
    var node = tech_tree.get(node_id)
    if not node:
        push_warning("ProgressionManager: Tech node not found: " + node_id)
        return false
    
    if node.is_researched:
        push_warning("ProgressionManager: Tech node already researched: " + node_id)
        return false
    
    if not can_research_node(node_id):
        return false
    
    if currently_researching != null:
        push_warning("ProgressionManager: Already researching: " + currently_researching.node_id)
        return false
    
    currently_researching = node
    node.is_unlocked = true
    node.research_start_time = Time.get_ticks_msec() / 1000.0
    research_timer = 0.0
    
    tech_node_unlocked.emit(node)
    return true

func update_research(delta: float) -> void:
    if currently_researching == null:
        return
    
    research_timer += delta
    var progress = research_timer / currently_researching.research_time_seconds
    currently_researching.research_progress = min(progress, 1.0)
    
    research_progressed.emit(currently_researching, progress)
    
    if research_timer >= currently_researching.research_time_seconds:
        complete_research(currently_researching)

func complete_research(node: TechTreeNode) -> void:
    node.is_researched = true
    node.research_progress = 1.0
    
    if CraftingManager:
        for recipe_id in node.unlocks_recipes:
            CraftingManager.discover_recipe(recipe_id)
    
    researched_tech_nodes[node.node_id] = node
    
    unlock_dependent_tech_nodes(node.node_id)
    
    currently_researching = null
    research_timer = 0.0
    
    tech_node_researched.emit(node)
    
    if NotificationManager:
        var notification = NotificationData.new()
        notification.message = "Research Complete: " + node.node_name
        notification.type = NotificationData.NotificationType.SUCCESS
        NotificationManager.show_notification(notification)

func can_research_node(node_id: String) -> bool:
    var node = tech_tree.get(node_id)
    if not node:
        return false
    
    if player_level.current_level < node.level_requirement:
        return false
    
    return check_tech_prerequisites(node)

func check_tech_prerequisites(node: TechTreeNode) -> bool:
    for prereq_id in node.prerequisites:
        var prereq = researched_tech_nodes.get(prereq_id)
        if not prereq or not prereq.is_researched:
            return false
    return true

func unlock_tech_node(node_id: String) -> void:
    var node = tech_tree.get(node_id)
    if not node or node.is_unlocked:
        return
    
    node.is_unlocked = true
    unlocked_tech_nodes[node_id] = node
    tech_node_unlocked.emit(node)

func unlock_dependent_tech_nodes(node_id: String) -> void:
    for other_node_id in tech_tree:
        var other_node = tech_tree[other_node_id]
        if node_id in other_node.prerequisites:
            if check_tech_prerequisites(other_node):
                unlock_tech_node(other_node_id)

func respec_skills() -> bool:
    if not respec_enabled:
        return false
    
    # Check respec cost
    if InventoryManager:
        for resource_id in respec_cost:
            var required_quantity = respec_cost[resource_id]
            if InventoryManager.get_item_count(resource_id) < required_quantity:
                push_warning("ProgressionManager: Insufficient resources for respec")
                return false
        
        # Deduct cost
        for resource_id in respec_cost:
            var quantity = respec_cost[resource_id]
            InventoryManager.remove_item(resource_id, quantity)
    
    # Refund skill points
    var refunded_points = 0
    for skill_id in purchased_skills:
        var skill = purchased_skills[skill_id]
        refunded_points += skill.skill_points_cost
        
        # Remove skill effects
        remove_skill_effects(skill)
        
        # Reset skill state
        skill.is_purchased = false
        skill.is_unlocked = false
    
    # Clear purchased skills
    purchased_skills.clear()
    unlocked_skills.clear()
    
    # Refund skill points
    player_level.skill_points_available += refunded_points
    player_level.skill_points_spent = 0
    
    return true

func remove_skill_effects(skill: SkillNode) -> void:
    # Remove stat bonuses
    for stat_name in skill.stat_bonuses:
        if player_level.stat_bonuses.has(stat_name):
            player_level.stat_bonuses[stat_name] -= skill.stat_bonuses[stat_name]
            if player_level.stat_bonuses[stat_name] <= 0:
                player_level.stat_bonuses.erase(stat_name)
    
    # Remove abilities
    for ability_id in skill.ability_unlocks:
        player_level.ability_unlocks.erase(ability_id)
    
    # Remove passive effects
    for passive_id in skill.passive_effects:
        player_level.passive_effects.erase(passive_id)
    
    # Remove multipliers
    for stat_name in skill.multiplier_bonuses:
        if player_level.multiplier_bonuses.has(stat_name):
            player_level.multiplier_bonuses[stat_name] /= skill.multiplier_bonuses[stat_name]
            if player_level.multiplier_bonuses[stat_name] <= 1.0:
                player_level.multiplier_bonuses.erase(stat_name)

func get_total_stat_bonuses() -> Dictionary:
    return player_level.stat_bonuses.duplicate()

func get_unlocked_abilities() -> Array[String]:
    return player_level.ability_unlocks.duplicate()

func get_unlocked_passives() -> Array[String]:
    return player_level.passive_effects.duplicate()

func get_level() -> int:
    return player_level.current_level

func get_experience() -> float:
    return player_level.current_experience

func get_experience_to_next() -> float:
    return player_level.experience_to_next_level

func add_skill_points(amount: int) -> void:
    player_level.skill_points_available += amount

func add_experience(amount: float) -> void:
    gain_experience(amount, ExperienceSource.CUSTOM)

func _on_enemy_killed(enemy_id: String, enemy_type: String) -> void:
    var xp_amount = experience_sources.get(ExperienceSource.KILL_ENEMY, 10.0)
    gain_experience(xp_amount, ExperienceSource.KILL_ENEMY)
    
    if AchievementManager:
        AchievementManager.track_event(TrackingType.KILL_COUNT, {"enemy_id": enemy_id, "enemy_type": enemy_type})

func _on_item_crafted(item_id: String) -> void:
    var xp_amount = experience_sources.get(ExperienceSource.CRAFT_ITEM, 5.0)
    gain_experience(xp_amount, ExperienceSource.CRAFT_ITEM)
    
    if AchievementManager:
        AchievementManager.track_event(TrackingType.CRAFT_COUNT, {"item_id": item_id})

func _on_recipe_discovered(recipe_id: String) -> void:
    var xp_amount = experience_sources.get(ExperienceSource.DISCOVER_RECIPE, 15.0)
    gain_experience(xp_amount, ExperienceSource.DISCOVER_RECIPE)

func _on_building_placed(building_id: String) -> void:
    var xp_amount = experience_sources.get(ExperienceSource.BUILD_STRUCTURE, 3.0)
    gain_experience(xp_amount, ExperienceSource.BUILD_STRUCTURE)
    
    if AchievementManager:
        AchievementManager.track_event(TrackingType.BUILD_COUNT, {"structure_id": building_id})

func _on_quest_completed(quest: QuestData) -> void:
    var xp_amount = experience_sources.get(ExperienceSource.COMPLETE_QUEST, 50.0)
    gain_experience(xp_amount, ExperienceSource.COMPLETE_QUEST)
    
    if AchievementManager:
        AchievementManager.track_event(TrackingType.QUEST_COMPLETE, {"quest_id": quest.quest_id})

func _on_day_passed(day: int) -> void:
    var xp_amount = experience_sources.get(ExperienceSource.SURVIVE_TIME, 20.0)
    gain_experience(xp_amount, ExperienceSource.SURVIVE_TIME)
    
    if AchievementManager:
        AchievementManager.track_event(TrackingType.SURVIVE_DAYS, {"days": day})

func _ready() -> void:
    # Initialize TechTreeManager
    tech_tree_manager = TechTreeManager.new()
    add_child(tech_tree_manager)
    tech_tree_manager.load_tech_tree()
    
    # Load progression data
    load_progression_data()

func load_progression_data() -> void:
    # Load skill tree
    var skill_dir = DirAccess.open("res://resources/skills/")
    if skill_dir:
        skill_dir.list_dir_begin()
        var file_name = skill_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var skill = load("res://resources/skills/" + file_name) as SkillNode
                if skill:
                    skill_tree[skill.skill_id] = skill
            file_name = skill_dir.get_next()
    
    # Load tech tree (via TechTreeManager)
    if tech_tree_manager:
        tech_tree_manager.load_tech_tree()
        # Sync with backwards compatibility dictionaries
        for node_id in tech_tree_manager.tech_tree_data:
            tech_tree[node_id] = tech_tree_manager.tech_tree_data[node_id]
    
    # Load achievements
    if AchievementManager:
        AchievementManager.load_achievements()

# TechTreeManager Implementation

func TechTreeManager._ready() -> void:
    load_tech_tree()

func TechTreeManager.load_tech_tree() -> void:
    var tech_dir = DirAccess.open("res://resources/tech/")
    if tech_dir:
        tech_dir.list_dir_begin()
        var file_name = tech_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var tech = load("res://resources/tech/" + file_name) as TechTreeNode
                if tech:
                    tech_tree_data[tech.node_id] = tech
                    # Categorize
                    if not tech_categories.has(tech.category):
                        tech_categories[tech.category] = []
                    tech_categories[tech.category].append(tech)
            file_name = tech_dir.get_next()
        tech_tree_updated.emit()

func TechTreeManager.get_node_by_id(node_id: String) -> TechTreeNode:
    return tech_tree_data.get(node_id)

func TechTreeManager.get_nodes_by_category(category: String) -> Array[TechTreeNode]:
    return tech_categories.get(category, [])

func TechTreeManager.is_node_unlocked(node_id: String) -> bool:
    return node_id in unlocked_nodes

func TechTreeManager.is_node_researched(node_id: String) -> bool:
    return node_id in researched_nodes

func TechTreeManager.get_available_nodes() -> Array[TechTreeNode]:
    var available: Array[TechTreeNode] = []
    for node_id in tech_tree_data:
        var node = tech_tree_data[node_id]
        # Check if prerequisites are met
        var can_unlock = true
        for prereq_id in node.prerequisites:
            if not is_node_researched(prereq_id):
                can_unlock = false
                break
        if can_unlock and not is_node_unlocked(node_id):
            available.append(node)
    return available

func TechTreeManager.get_researched_nodes() -> Array[TechTreeNode]:
    var researched: Array[TechTreeNode] = []
    for node_id in researched_nodes:
        var node = tech_tree_data.get(node_id)
        if node:
            researched.append(node)
    return researched

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── ProgressionManager.gd
   └── resources/
       ├── skills/
       ├── tech/
       └── achievements/
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/ProgressionManager.gd` as `ProgressionManager`
   - **Important:** Load after all systems that provide experience (CombatManager, CraftingManager, etc.)

3. **Create Skill/Tech/Achievement Resources:**
   - Create SkillNode resources for each skill
   - Create TechTreeNode resources for each tech node
   - Create AchievementData resources for each achievement
   - Save as `.tres` files in respective directories

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. CombatManager, CraftingManager, BuildingManager, QuestManager, SurvivalManager
4. **ProgressionManager** (after systems that provide experience)

### System Integration

**Each System Must Emit Signals:**
```gdscript
# Example: CombatManager
signal enemy_killed(enemy_id: String, enemy_type: String)

# Example: CraftingManager
signal item_crafted(item_id: String)
signal recipe_discovered(recipe_id: String)

# Example: BuildingManager
signal building_placed(building_id: String)

# Example: QuestManager
signal quest_completed(quest: QuestData)

# Example: SurvivalManager
signal day_passed(day: int)
```

**ProgressionManager subscribes to these signals in _ready()**

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Progression System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Resources:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
- **Math Functions:** https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-method-pow

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Progression System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Signals Tutorial](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Resources Tutorial](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data storage
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup
- [Math Functions](https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-method-pow) - Mathematical operations

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- SkillNode is a Resource (can be created/edited in inspector)
- TechTreeNode is a Resource (can be created/edited in inspector)
- AchievementData is a Resource (can be created/edited in inspector)
- PlayerLevel is a Resource (can be configured in inspector)

**Visual Configuration:**
- Skill properties editable in inspector
- Tech node properties editable in inspector
- Achievement properties editable in inspector
- Experience sources configurable via code/export variables

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Skill tree visualizer/editor
  - Tech tree visualizer/editor
  - Achievement progress tracker

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Skills/tech/achievements created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Experience Sources:** Configure XP values per source type in `experience_sources` dictionary
2. **Experience Curve:** Adjust `base_experience` and `experience_multiplier` for desired leveling pace
3. **Skill Tree:** Create skill tree data file with all skills and prerequisites
4. **Tech Tree:** Create tech tree data file with all nodes, research times, and recipe unlocks
5. **Achievements:** Create achievement database with all achievements and tracking types
6. **Respec Cost:** Configure respec cost in `respec_cost` dictionary
7. **UI Integration:** Integrate with UI system for skill/tech tree displays and achievement list

---

## Future Enhancements

- Prestige system (reset progression for bonuses)
- Skill point refund (partial respec)
- Research queue (multiple research projects)
- Achievement categories/filtering
- Leaderboards for achievements
- Skill/tech tree visualization improvements
- Dynamic skill/tech tree generation

