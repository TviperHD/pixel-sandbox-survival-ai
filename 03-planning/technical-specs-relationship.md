# Technical Specifications: Relationship System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the relationship system with reputation tiers (positive and negative), gain/lose reputation (quests + dialogue + actions), and full benefits (trading + quests + items + story). This system integrates with NPC System, Dialogue System, Quest System, Trading System, and UI System.

---

## Research Notes

### Relationship System Architecture Best Practices

**Research Findings:**
- Reputation tiers create clear progression
- Multiple ways to gain/lose reputation add depth
- Benefits reward relationship building
- Negative reputation adds consequences
- Relationship affects multiple systems (trading, quests, story)

**Sources:**
- [Godot 4 Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data structures
- [Godot 4 Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- General relationship system patterns in RPGs

**Implementation Approach:**
- RelationshipManager singleton manages all relationships
- Reputation tiers (positive and negative)
- Multiple reputation sources (quests, dialogue, actions)
- Benefits unlock with relationship level
- Relationship affects trading, quests, items, story

**Why This Approach:**
- Reputation tiers create clear progression
- Multiple sources add depth
- Benefits reward investment
- Negative reputation adds consequences
- Affects multiple systems for depth

### Reputation Calculation Best Practices

**Research Findings:**
- Reputation points accumulate to tiers
- Different actions give different amounts
- Reputation decays over time (optional)
- Relationship history tracks changes

**Sources:**
- General reputation system patterns
- RPG relationship mechanics

**Implementation Approach:**
- Reputation points accumulate
- Tiers based on point thresholds
- Different actions give different amounts
- Optional decay over time
- History tracking for debugging

**Why This Approach:**
- Points system is flexible
- Tiers provide clear progression
- Different amounts create meaningful choices
- Decay prevents permanent reputation
- History helps debugging

---

## Data Structures

### RelationshipTier

```gdscript
enum RelationshipTier {
    # Negative Tiers
    ENEMY = -3,         # -1000 to -500 points
    HOSTILE = -2,      # -500 to -200 points
    DISLIKED = -1,     # -200 to -50 points
    
    # Neutral
    STRANGER = 0,      # -50 to 50 points
    
    # Positive Tiers
    ACQUAINTANCE = 1,  # 50 to 200 points
    FRIEND = 2,        # 200 to 500 points
    CLOSE_FRIEND = 3,  # 500 to 1000 points
    ALLY = 4           # 1000+ points
}
```

### RelationshipData

```gdscript
class_name RelationshipData
extends Resource

# NPC Identification
@export var npc_id: String  # NPC this relationship is with

# Reputation
@export var reputation_points: int = 0  # Current reputation points
@export var current_tier: RelationshipTier = RelationshipTier.STRANGER
@export var max_reputation: int = 0  # Highest reputation achieved
@export var min_reputation: int = 0  # Lowest reputation achieved

# Reputation History
@export var reputation_history: Array[Dictionary] = []  # [{time: float, change: int, source: String, reason: String}]
@export var max_history_size: int = 100  # Limit history size

# Benefits Unlocked
@export var unlocked_quests: Array[String] = []  # Quest IDs unlocked
@export var unlocked_items: Array[String] = []  # Item IDs unlocked
@export var unlocked_dialogue: Array[String] = []  # Dialogue node IDs unlocked
@export var unlocked_story_content: Array[String] = []  # Story content IDs unlocked

# Trading Benefits
@export var trading_discount: float = 0.0  # Discount multiplier (0.0 = no discount, 0.1 = 10% discount)
@export var trading_items_unlocked: Array[String] = []  # Shop item IDs unlocked

# Configuration
@export var reputation_decay_enabled: bool = false
@export var reputation_decay_rate: float = 1.0  # Points per day
@export var reputation_decay_threshold: int = 0  # Don't decay below this
```

### ReputationSource

```gdscript
enum ReputationSource {
    QUEST_COMPLETION,      # Completed quest
    QUEST_FAILURE,         # Failed quest
    DIALOGUE_CHOICE,       # Dialogue choice
    ACTION,                # Player action (help, attack, etc.)
    GIFT,                  # Gave gift
    TRADE,                 # Trading interaction
    STORY_EVENT            # Story event
}
```

### ReputationChange

```gdscript
class_name ReputationChange
extends RefCounted

var npc_id: String
var change_amount: int  # Positive or negative
var source: ReputationSource
var reason: String = ""  # Description of change
var timestamp: float = 0.0
```

---

## Core Classes

### RelationshipManager (Autoload Singleton)

```gdscript
class_name RelationshipManager
extends Node

# Relationship Storage
var relationships: Dictionary = {}  # npc_id -> RelationshipData

# Reputation Configuration
@export var tier_thresholds: Dictionary = {}  # RelationshipTier -> point_threshold
@export var default_reputation: int = 0  # Starting reputation
@export var enable_reputation_decay: bool = false
@export var decay_check_interval: float = 3600.0  # Check decay every hour

# Reputation Sources Configuration
@export var quest_completion_reputation: Dictionary = {}  # quest_id -> reputation_change
@export var dialogue_choice_reputation: Dictionary = {}  # dialogue_node_id -> reputation_change
@export var action_reputation: Dictionary = {}  # action_id -> reputation_change

# References
var quest_manager: QuestManager
var dialogue_manager: DialogueManager
var trading_manager: TradingManager
var npc_manager: NPCManager

# Signals
signal reputation_changed(npc_id: String, old_points: int, new_points: int, change: int)
signal tier_changed(npc_id: String, old_tier: RelationshipTier, new_tier: RelationshipTier)
signal benefit_unlocked(npc_id: String, benefit_type: String, benefit_id: String)

# Initialization
func _ready() -> void
func initialize() -> void

# Relationship Management
func initialize_relationship(npc_id: String) -> RelationshipData
func get_relationship(npc_id: String) -> RelationshipData
func has_relationship(npc_id: String) -> bool

# Reputation Management
func change_reputation(npc_id: String, amount: int, source: ReputationSource, reason: String = "") -> bool
func set_reputation(npc_id: String, points: int) -> void
func get_reputation(npc_id: String) -> int
func get_tier(npc_id: String) -> RelationshipTier

# Reputation Sources
func on_quest_completed(quest_id: String, npc_id: String) -> void
func on_quest_failed(quest_id: String, npc_id: String) -> void
func on_dialogue_choice(npc_id: String, choice_id: String) -> void
func on_player_action(npc_id: String, action_id: String) -> void
func on_gift_given(npc_id: String, item_id: String) -> void

# Tier Management
func update_tier(npc_id: String) -> void
func get_tier_from_points(points: int) -> RelationshipTier
func get_points_for_tier(tier: RelationshipTier) -> int

# Benefits Management
func check_benefits(npc_id: String) -> void
func unlock_benefits(npc_id: String, tier: RelationshipTier) -> void
func has_unlocked_quest(npc_id: String, quest_id: String) -> bool
func has_unlocked_item(npc_id: String, item_id: String) -> bool
func has_unlocked_dialogue(npc_id: String, dialogue_id: String) -> bool
func get_trading_discount(npc_id: String) -> float

# Reputation Decay
func _process(delta: float) -> void
func update_reputation_decay() -> void
func apply_reputation_decay(npc_id: String, delta: float) -> void
```

---

## System Architecture

### Component Hierarchy

```
RelationshipManager (Autoload Singleton)
├── RelationshipData[] (Dictionary)
│   ├── Reputation Points (int)
│   ├── Current Tier (RelationshipTier)
│   └── Reputation History (Array)
└── UI/RelationshipDisplay (Control)
    └── ReputationBar (ProgressBar)
```

### Data Flow

1. **Reputation Change:**
   ```
   Action occurs (quest, dialogue, etc.)
   ├── RelationshipManager.change_reputation()
   ├── Update reputation points
   ├── Check for tier change
   ├── Update tier if changed
   ├── Check for benefits unlock
   ├── Record in history
   └── Emit signals
   ```

2. **Tier Change:**
   ```
   Reputation crosses threshold
   ├── Calculate new tier
   ├── If tier changed:
   │   ├── Unlock benefits for new tier
   │   ├── Emit tier_changed signal
   │   └── Update UI
   └── Update relationship data
   ```

3. **Benefit Unlock:**
   ```
   Tier increases
   ├── Check benefits for new tier
   ├── Unlock quests
   ├── Unlock items
   ├── Unlock dialogue
   ├── Unlock story content
   ├── Update trading discounts
   └── Emit benefit_unlocked signals
   ```

---

## Algorithms

### Reputation Change Algorithm

```gdscript
func change_reputation(npc_id: String, amount: int, source: ReputationSource, reason: String = "") -> bool:
    if not has_relationship(npc_id):
        initialize_relationship(npc_id)
    
    var relationship = get_relationship(npc_id)
    var old_points = relationship.reputation_points
    var old_tier = relationship.current_tier
    
    # Change reputation
    relationship.reputation_points += amount
    relationship.reputation_points = clamp(relationship.reputation_points, -1000, 2000)  # Reasonable limits
    
    # Update min/max
    relationship.max_reputation = max(relationship.max_reputation, relationship.reputation_points)
    relationship.min_reputation = min(relationship.min_reputation, relationship.reputation_points)
    
    # Record in history
    var history_entry = {
        "time": Time.get_unix_time_from_system(),
        "change": amount,
        "source": source,
        "reason": reason,
        "old_points": old_points,
        "new_points": relationship.reputation_points
    }
    relationship.reputation_history.append(history_entry)
    
    # Limit history size
    if relationship.reputation_history.size() > relationship.max_history_size:
        relationship.reputation_history.pop_front()
    
    # Check for tier change
    var new_tier = get_tier_from_points(relationship.reputation_points)
    if new_tier != old_tier:
        relationship.current_tier = new_tier
        update_tier(npc_id)
        tier_changed.emit(npc_id, old_tier, new_tier)
    
    # Emit signal
    reputation_changed.emit(npc_id, old_points, relationship.reputation_points, amount)
    
    return true

func get_tier_from_points(points: int) -> RelationshipTier:
    # Check tier thresholds
    if points >= tier_thresholds.get(RelationshipTier.ALLY, 1000):
        return RelationshipTier.ALLY
    elif points >= tier_thresholds.get(RelationshipTier.CLOSE_FRIEND, 500):
        return RelationshipTier.CLOSE_FRIEND
    elif points >= tier_thresholds.get(RelationshipTier.FRIEND, 200):
        return RelationshipTier.FRIEND
    elif points >= tier_thresholds.get(RelationshipTier.ACQUAINTANCE, 50):
        return RelationshipTier.ACQUAINTANCE
    elif points <= tier_thresholds.get(RelationshipTier.ENEMY, -1000):
        return RelationshipTier.ENEMY
    elif points <= tier_thresholds.get(RelationshipTier.HOSTILE, -500):
        return RelationshipTier.HOSTILE
    elif points <= tier_thresholds.get(RelationshipTier.DISLIKED, -200):
        return RelationshipTier.DISLIKED
    else:
        return RelationshipTier.STRANGER
```

### Benefit Unlock Algorithm

```gdscript
func unlock_benefits(npc_id: String, tier: RelationshipTier) -> void:
    var relationship = get_relationship(npc_id)
    if relationship == null:
        return
    
    # Get NPC data for benefit configuration
    var npc_data = npc_manager.get_npc_data(npc_id)
    if npc_data == null:
        return
    
    # Unlock quests for tier
    if npc_data.relationship_quests.has(tier):
        for quest_id in npc_data.relationship_quests[tier]:
            if quest_id not in relationship.unlocked_quests:
                relationship.unlocked_quests.append(quest_id)
                benefit_unlocked.emit(npc_id, "quest", quest_id)
    
    # Unlock items for tier
    if npc_data.relationship_items.has(tier):
        for item_id in npc_data.relationship_items[tier]:
            if item_id not in relationship.unlocked_items:
                relationship.unlocked_items.append(item_id)
                benefit_unlocked.emit(npc_id, "item", item_id)
    
    # Unlock dialogue for tier
    if npc_data.relationship_dialogue.has(tier):
        for dialogue_id in npc_data.relationship_dialogue[tier]:
            if dialogue_id not in relationship.unlocked_dialogue:
                relationship.unlocked_dialogue.append(dialogue_id)
                benefit_unlocked.emit(npc_id, "dialogue", dialogue_id)
    
    # Unlock story content for tier
    if npc_data.relationship_story_content.has(tier):
        for story_id in npc_data.relationship_story_content[tier]:
            if story_id not in relationship.unlocked_story_content:
                relationship.unlocked_story_content.append(story_id)
                benefit_unlocked.emit(npc_id, "story", story_id)
    
    # Update trading discount
    var discount_multiplier = get_discount_for_tier(tier)
    relationship.trading_discount = discount_multiplier
    
    # Update trading items
    if npc_data.relationship_trading_items.has(tier):
        for item_id in npc_data.relationship_trading_items[tier]:
            if item_id not in relationship.trading_items_unlocked:
                relationship.trading_items_unlocked.append(item_id)
                benefit_unlocked.emit(npc_id, "trading_item", item_id)

func get_discount_for_tier(tier: RelationshipTier) -> float:
    match tier:
        RelationshipTier.ALLY:
            return 0.20  # 20% discount
        RelationshipTier.CLOSE_FRIEND:
            return 0.15  # 15% discount
        RelationshipTier.FRIEND:
            return 0.10  # 10% discount
        RelationshipTier.ACQUAINTANCE:
            return 0.05  # 5% discount
        _:
            return 0.0  # No discount
```

### Reputation Source Handlers

```gdscript
func on_quest_completed(quest_id: String, npc_id: String) -> void:
    if not quest_completion_reputation.has(quest_id):
        return
    
    var reputation_change = quest_completion_reputation[quest_id]
    change_reputation(npc_id, reputation_change, ReputationSource.QUEST_COMPLETION, "Completed quest: " + quest_id)

func on_quest_failed(quest_id: String, npc_id: String) -> void:
    if not quest_completion_reputation.has(quest_id):
        return
    
    # Failed quests give negative reputation (half of completion)
    var reputation_change = quest_completion_reputation[quest_id] / -2
    change_reputation(npc_id, reputation_change, ReputationSource.QUEST_FAILURE, "Failed quest: " + quest_id)

func on_dialogue_choice(npc_id: String, choice_id: String) -> void:
    if not dialogue_choice_reputation.has(choice_id):
        return
    
    var reputation_change = dialogue_choice_reputation[choice_id]
    change_reputation(npc_id, reputation_change, ReputationSource.DIALOGUE_CHOICE, "Dialogue choice: " + choice_id)

func on_player_action(npc_id: String, action_id: String) -> void:
    if not action_reputation.has(action_id):
        return
    
    var reputation_change = action_reputation[action_id]
    change_reputation(npc_id, reputation_change, ReputationSource.ACTION, "Action: " + action_id)

func on_gift_given(npc_id: String, item_id: String) -> void:
    # Calculate reputation based on item value
    var item_data = ItemDatabase.get_item(item_id)
    if item_data == null:
        return
    
    # Reputation = item value / 10 (configurable)
    var reputation_change = int(item_data.base_value / 10.0)
    reputation_change = max(1, reputation_change)  # Minimum 1 point
    
    change_reputation(npc_id, reputation_change, ReputationSource.GIFT, "Gift: " + item_id)
```

### Reputation Decay Algorithm

```gdscript
func _process(delta: float) -> void:
    if not enable_reputation_decay:
        return
    
    var time_since_last_check = get_meta("last_decay_check", 0.0)
    time_since_last_check += delta
    
    if time_since_last_check >= decay_check_interval:
        update_reputation_decay()
        set_meta("last_decay_check", 0.0)
    else:
        set_meta("last_decay_check", time_since_last_check)

func update_reputation_decay() -> void:
    var current_time = Time.get_unix_time_from_system()
    var time_delta = decay_check_interval  # Seconds
    
    for npc_id in relationships:
        var relationship = relationships[npc_id]
        if not relationship.reputation_decay_enabled:
            continue
        
        apply_reputation_decay(npc_id, time_delta)

func apply_reputation_decay(npc_id: String, delta: float) -> void:
    var relationship = get_relationship(npc_id)
    if relationship == null:
        return
    
    # Calculate decay amount
    var decay_amount = relationship.reputation_decay_rate * (delta / 86400.0)  # Per day
    
    # Don't decay below threshold
    var target_reputation = relationship.reputation_points - decay_amount
    if target_reputation < relationship.reputation_decay_threshold:
        target_reputation = relationship.reputation_decay_threshold
    
    # Apply decay
    if target_reputation < relationship.reputation_points:
        var change = int(target_reputation - relationship.reputation_points)
        change_reputation(npc_id, change, ReputationSource.STORY_EVENT, "Reputation decay")
```

---

## Integration Points

### With Quest System

```gdscript
# Quest completion affects reputation
func on_quest_completed(quest_id: String) -> void:
    var quest_data = quest_manager.get_quest(quest_id)
    if quest_data and quest_data.npc_id != "":
        relationship_manager.on_quest_completed(quest_id, quest_data.npc_id)

# Check if quest is unlocked
func is_quest_available(quest_id: String, npc_id: String) -> bool:
    return relationship_manager.has_unlocked_quest(npc_id, quest_id)
```

### With Dialogue System

```gdscript
# Dialogue choices affect reputation
func on_dialogue_choice_selected(choice_id: String, npc_id: String) -> void:
    relationship_manager.on_dialogue_choice(npc_id, choice_id)

# Check if dialogue node is unlocked
func is_dialogue_available(dialogue_id: String, npc_id: String) -> bool:
    return relationship_manager.has_unlocked_dialogue(npc_id, dialogue_id)
```

### With Trading System

```gdscript
# Get trading discount from relationship
func get_price_with_relationship(shop: NPCShopData, item_id: String, relationship_level: int) -> int:
    var npc_id = shop.npc_id
    var discount = relationship_manager.get_trading_discount(npc_id)
    var base_price = get_base_price(shop, item_id)
    return int(base_price * (1.0 - discount))

# Check if trading item is unlocked
func is_trading_item_available(shop: NPCShopData, item_id: String) -> bool:
    var npc_id = shop.npc_id
    var relationship = relationship_manager.get_relationship(npc_id)
    if relationship == null:
        return false
    return item_id in relationship.trading_items_unlocked
```

### With NPC System

```gdscript
# Get relationship tier for NPC
func get_npc_relationship_tier(npc_id: String) -> RelationshipTier:
    return relationship_manager.get_tier(npc_id)

# Check if NPC has unlocked content
func has_unlocked_content(npc_id: String, content_type: String, content_id: String) -> bool:
    match content_type:
        "quest":
            return relationship_manager.has_unlocked_quest(npc_id, content_id)
        "item":
            return relationship_manager.has_unlocked_item(npc_id, content_id)
        "dialogue":
            return relationship_manager.has_unlocked_dialogue(npc_id, content_id)
        "story":
            var relationship = relationship_manager.get_relationship(npc_id)
            return content_id in relationship.unlocked_story_content
    return false
```

---

## Save/Load System

### Save Data Structure

```gdscript
var relationship_save_data: Dictionary = {
    "relationships": serialize_relationships()
}

func serialize_relationships() -> Dictionary:
    var relationships_data: Dictionary = {}
    for npc_id in relationships:
        var relationship = relationships[npc_id]
        relationships_data[npc_id] = {
            "reputation_points": relationship.reputation_points,
            "current_tier": relationship.current_tier,
            "max_reputation": relationship.max_reputation,
            "min_reputation": relationship.min_reputation,
            "reputation_history": relationship.reputation_history,
            "unlocked_quests": relationship.unlocked_quests,
            "unlocked_items": relationship.unlocked_items,
            "unlocked_dialogue": relationship.unlocked_dialogue,
            "unlocked_story_content": relationship.unlocked_story_content,
            "trading_discount": relationship.trading_discount,
            "trading_items_unlocked": relationship.trading_items_unlocked
        }
    return relationships_data
```

### Load Data Structure

```gdscript
func load_relationship_data(data: Dictionary) -> void:
    if data.has("relationships"):
        load_relationships(data["relationships"])

func load_relationships(relationships_data: Dictionary) -> void:
    for npc_id in relationships_data:
        var data = relationships_data[npc_id]
        var relationship = initialize_relationship(npc_id)
        
        relationship.reputation_points = data.get("reputation_points", 0)
        relationship.current_tier = data.get("current_tier", RelationshipTier.STRANGER)
        relationship.max_reputation = data.get("max_reputation", 0)
        relationship.min_reputation = data.get("min_reputation", 0)
        relationship.reputation_history = data.get("reputation_history", [])
        relationship.unlocked_quests = data.get("unlocked_quests", [])
        relationship.unlocked_items = data.get("unlocked_items", [])
        relationship.unlocked_dialogue = data.get("unlocked_dialogue", [])
        relationship.unlocked_story_content = data.get("unlocked_story_content", [])
        relationship.trading_discount = data.get("trading_discount", 0.0)
        relationship.trading_items_unlocked = data.get("trading_items_unlocked", [])
        
        # Update tier to ensure consistency
        update_tier(npc_id)
```

---

## Error Handling

### RelationshipManager Error Handling

- **Invalid NPC IDs:** Check NPC exists before operations, return errors gracefully
- **Missing References:** Check references exist before using (quest_manager, dialogue_manager, trading_manager)
- **Invalid Reputation Values:** Clamp reputation to valid range
- **Missing Configuration:** Fallback to defaults when configuration missing

### Best Practices

- Use `push_error()` for critical errors (invalid npc_id, missing references)
- Use `push_warning()` for non-critical issues (missing configuration, no relationship)
- Return default values on errors (don't crash)
- Validate all inputs before operations
- Initialize relationships on first access

---

## Default Values and Configuration

### RelationshipManager Defaults

```gdscript
default_reputation = 0
enable_reputation_decay = false
decay_check_interval = 3600.0
tier_thresholds = {
    RelationshipTier.ALLY: 1000,
    RelationshipTier.CLOSE_FRIEND: 500,
    RelationshipTier.FRIEND: 200,
    RelationshipTier.ACQUAINTANCE: 50,
    RelationshipTier.STRANGER: 0,
    RelationshipTier.DISLIKED: -50,
    RelationshipTier.HOSTILE: -200,
    RelationshipTier.ENEMY: -500
}
```

### RelationshipData Defaults

```gdscript
reputation_points = 0
current_tier = RelationshipTier.STRANGER
max_reputation = 0
min_reputation = 0
reputation_history = []
max_history_size = 100
unlocked_quests = []
unlocked_items = []
unlocked_dialogue = []
unlocked_story_content = []
trading_discount = 0.0
trading_items_unlocked = []
reputation_decay_enabled = false
reputation_decay_rate = 1.0
reputation_decay_threshold = 0
```

---

## Performance Considerations

### Optimization Strategies

1. **Reputation Updates:**
   - Update only when reputation changes
   - Cache tier calculations
   - Limit history size
   - Batch updates when possible

2. **Benefit Checks:**
   - Check benefits only on tier change
   - Cache unlocked content lists
   - Use efficient lookups (Dictionary)

3. **Decay Updates:**
   - Check decay at intervals (not every frame)
   - Skip NPCs with decay disabled
   - Batch decay calculations

4. **Memory Management:**
   - Limit history size per relationship
   - Remove old history entries
   - Use efficient data structures

---

## Testing Checklist

### Relationship System
- [ ] Relationships initialize correctly
- [ ] Reputation changes correctly
- [ ] Tier updates correctly
- [ ] Reputation history records correctly
- [ ] Reputation decay works (if enabled)

### Reputation Sources
- [ ] Quest completion affects reputation
- [ ] Quest failure affects reputation
- [ ] Dialogue choices affect reputation
- [ ] Player actions affect reputation
- [ ] Gifts affect reputation

### Benefits System
- [ ] Quests unlock with tier
- [ ] Items unlock with tier
- [ ] Dialogue unlocks with tier
- [ ] Story content unlocks with tier
- [ ] Trading discounts apply correctly
- [ ] Trading items unlock correctly

### Integration
- [ ] Integrates with Quest System correctly
- [ ] Integrates with Dialogue System correctly
- [ ] Integrates with Trading System correctly
- [ ] Integrates with NPC System correctly
- [ ] Save/load works correctly

---

## Complete Implementation

### RelationshipManager Initialization

```gdscript
func _ready() -> void:
    # Get references
    quest_manager = get_node_or_null("/root/QuestManager")
    dialogue_manager = get_node_or_null("/root/DialogueManager")
    trading_manager = get_node_or_null("/root/TradingManager")
    npc_manager = get_node_or_null("/root/NPCManager")
    
    # Connect signals
    if quest_manager:
        quest_manager.quest_completed.connect(_on_quest_completed)
        quest_manager.quest_failed.connect(_on_quest_failed)
    
    if dialogue_manager:
        dialogue_manager.choice_selected.connect(_on_dialogue_choice)
    
    # Initialize
    initialize()

func initialize() -> void:
    # Load reputation configuration
    load_reputation_config()
    
    # Initialize tier thresholds if not set
    if tier_thresholds.is_empty():
        tier_thresholds = get_default_tier_thresholds()

func _on_quest_completed(quest_id: String) -> void:
    var quest_data = quest_manager.get_quest(quest_id)
    if quest_data and quest_data.npc_id != "":
        on_quest_completed(quest_id, quest_data.npc_id)

func _on_quest_failed(quest_id: String) -> void:
    var quest_data = quest_manager.get_quest(quest_id)
    if quest_data and quest_data.npc_id != "":
        on_quest_failed(quest_id, quest_data.npc_id)

func _on_dialogue_choice(npc_id: String, choice_id: String) -> void:
    on_dialogue_choice(npc_id, choice_id)

func get_default_tier_thresholds() -> Dictionary:
    return {
        RelationshipTier.ALLY: 1000,
        RelationshipTier.CLOSE_FRIEND: 500,
        RelationshipTier.FRIEND: 200,
        RelationshipTier.ACQUAINTANCE: 50,
        RelationshipTier.STRANGER: 0,
        RelationshipTier.DISLIKED: -50,
        RelationshipTier.HOSTILE: -200,
        RelationshipTier.ENEMY: -500
    }
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── resources/
   │   └── relationships/
   │       └── (relationship configuration files)
   └── scripts/
       └── managers/
           └── RelationshipManager.gd
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/RelationshipManager.gd` as `RelationshipManager`
   - **Important:** Load after QuestManager, DialogueManager, TradingManager, and NPCManager

3. **Configure Reputation Sources:**
   - Set `quest_completion_reputation` dictionary (quest_id -> reputation_change)
   - Set `dialogue_choice_reputation` dictionary (choice_id -> reputation_change)
   - Set `action_reputation` dictionary (action_id -> reputation_change)

### Initialization Order

**Autoload Order:**
1. GameManager
2. QuestManager
3. DialogueManager
4. TradingManager
5. NPCManager
6. **RelationshipManager** (after all dependencies)

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Relationship System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Resource System:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
- **Dictionary:** https://docs.godotengine.org/en/stable/classes/class_dictionary.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Relationship System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data structures
- [Signals Tutorial](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- [Autoload Singletons](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) - Singleton setup
- [Dictionary Documentation](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) - Dictionary operations

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- RelationshipData is a Resource (can be created/edited in inspector)
- Reputation configuration editable in inspector
- Tier thresholds configurable

**Visual Configuration:**
- Reputation sources configurable in inspector
- Benefit unlocks configurable
- Decay settings editable

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Relationship visualization (graph)
  - Reputation history viewer
  - Benefit unlock preview

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Relationship data managed programmatically
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Reputation Tiers:** Positive and negative tiers with point thresholds
2. **Multiple Sources:** Quests, dialogue, actions all affect reputation
3. **Full Benefits:** Trading discounts, quest unlocks, item unlocks, dialogue unlocks, story content unlocks
4. **Reputation History:** Tracks all reputation changes for debugging
5. **Optional Decay:** Reputation can decay over time (configurable)
6. **Integration:** Affects multiple systems (trading, quests, dialogue, NPCs)
7. **Signals:** Emits signals for reputation changes, tier changes, benefit unlocks
8. **Save/Load:** Full relationship state saved and loaded

