# Technical Specifications: AI System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the adaptive AI enemy system, including traditional AI (state machines, behavior trees) and ML integration (hybrid approach with real-time and persistent learning). This system integrates with CombatManager, ProgressionManager, and WorldGenerator for enemy AI behavior and learning.

---

## Research Notes

### AI System Architecture Best Practices

**Research Findings:**
- Hybrid approach combines traditional AI with ML for adaptive behavior
- State machines provide reliable base behavior
- Behavior trees enable complex decision-making
- ML enhances AI with learning capabilities
- Python bridge enables TensorFlow/PyTorch integration

**Sources:**
- [Godot 4 NavigationAgent2D](https://docs.godotengine.org/en/stable/classes/class_navigationagent2d.html) - Pathfinding
- [MLGodotKit](https://github.com/Godot-ML/MLGodotKit) - ML integration for Godot
- [Deep Reinforcement Learning](https://en.wikipedia.org/wiki/Deep_reinforcement_learning) - ML approach
- [Arc Raiders AI](https://www.ea.com/games/arc-raiders) - Inspiration for adaptive AI
- General AI system design patterns

**Implementation Approach:**
- EnemyAI as base class for all enemies
- StateMachine for reliable base behavior
- BehaviorTree for complex decisions
- MLAgent for adaptive learning
- Python bridge for ML model integration
- Hybrid learning (real-time + persistent)

**Why This Approach:**
- Hybrid: combines reliability of traditional AI with adaptability of ML
- State machines: reliable base behavior
- Behavior trees: complex decision-making
- ML integration: adaptive enemy behavior
- Python bridge: access to ML frameworks
- Hybrid learning: both session and persistent learning

### State Machine Best Practices

**Research Findings:**
- State machines provide reliable AI behavior
- State transitions based on conditions
- Each state has enter/update/exit logic
- State machines easy to debug and tune

**Sources:**
- General state machine patterns

**Implementation Approach:**
- StateMachine class manages states
- StateNode base class for all states
- StateTransition for state changes
- Condition checking for transitions

**Why This Approach:**
- Reliable: predictable AI behavior
- Modular: easy to add new states
- Debuggable: clear state flow
- Configurable: easy to tune

### Behavior Tree Best Practices

**Research Findings:**
- Behavior trees enable complex decision-making
- Composite nodes (sequence, selector) organize behavior
- Leaf nodes perform actions
- Decorator nodes modify behavior

**Sources:**
- General behavior tree patterns

**Implementation Approach:**
- BehaviorTree class manages tree
- CompositeNode for sequences/selectors
- ActionNode for actions
- DecoratorNode for modifications

**Why This Approach:**
- Complex decisions: handles complex AI logic
- Modular: easy to build complex behaviors
- Flexible: easy to modify behavior
- Reusable: share behaviors between enemies

### ML Integration Best Practices

**Research Findings:**
- Python bridge enables ML framework integration
- ONNX Runtime provides efficient inference
- MLGodotKit simplifies ML integration
- Deep Reinforcement Learning for adaptive AI

**Sources:**
- [MLGodotKit Documentation](https://github.com/Godot-ML/MLGodotKit) - ML integration
- [ONNX Runtime](https://onnxruntime.ai/) - Efficient ML inference
- [TensorFlow Lite](https://www.tensorflow.org/lite) - Mobile ML
- [PyTorch](https://pytorch.org/) - ML framework

**Implementation Approach:**
- Python subprocess for ML model execution
- ONNX Runtime for efficient inference
- MLGodotKit for simplified integration
- Observation/Action system for ML communication

**Why This Approach:**
- Python bridge: access to ML frameworks
- ONNX Runtime: efficient inference
- MLGodotKit: simplified integration
- Observation/Action: clear ML interface

### Learning System Best Practices

**Research Findings:**
- Real-time learning adapts during combat
- Persistent learning improves over sessions
- Reward calculation critical for learning
- Experience replay improves learning efficiency

**Sources:**
- General reinforcement learning patterns

**Implementation Approach:**
- Real-time learning during combat
- Persistent learning across sessions
- Reward calculation based on combat outcomes
- Experience replay for efficient learning

**Why This Approach:**
- Real-time: immediate adaptation
- Persistent: long-term improvement
- Reward-based: clear learning signal
- Experience replay: efficient learning

---

## Data Structures

### EnemyState

```gdscript
enum EnemyState {
    IDLE,
    PATROL,
    CHASE,
    ATTACK,
    RETREAT,
    SEARCH,
    DEAD
}
```

### EnemyStats

```gdscript
class_name EnemyStats
extends Resource

@export var health: float = 100.0
@export var max_health: float = 100.0
@export var speed: float = 50.0
@export var attack_damage: float = 10.0
@export var attack_range: float = 50.0
@export var detection_range: float = 200.0
@export var attack_cooldown: float = 1.0
@export var last_attack_time: float = 0.0
```

### ObservationData

```gdscript
class_name ObservationData
extends RefCounted

# Player Information
var player_position: Vector2
var player_velocity: Vector2
var player_health: float
var player_distance: float
var player_direction: Vector2  # Normalized direction to player

# Recent Player Actions
var player_recent_actions: Array[String] = []  # Last 10 actions
var player_attack_pattern: Dictionary = {}  # Attack type -> frequency
var player_movement_pattern: Dictionary = {}  # Direction -> frequency

# Environment
var nearby_cover: Array[Vector2] = []
var nearby_allies: Array[Vector2] = []
var terrain_type: String
var is_player_in_range: bool

# Enemy State
var enemy_health: float
var enemy_position: Vector2
var current_state: EnemyState

# Serialization for ML
func to_array() -> Array:
    return [
        player_position.x, player_position.y,
        player_velocity.x, player_velocity.y,
        player_health,
        player_distance,
        player_direction.x, player_direction.y,
        enemy_health,
        enemy_position.x, enemy_position.y,
        current_state
    ]
```

### ActionData

```gdscript
class_name ActionData
extends RefCounted

var move_direction: Vector2  # Normalized direction
var move_speed: float  # 0.0 to 1.0
var attack_type: String  # "melee", "ranged", "special"
var attack_target: Vector2
var use_ability: bool
var ability_type: String
```

### LearningData

```gdscript
class_name LearningData
extends RefCounted

# Session Data (Real-time Learning)
var session_observations: Array[ObservationData] = []
var session_actions: Array[ActionData] = []
var session_rewards: Array[float] = []
var session_start_time: float

# Persistent Data (Long-term Learning)
var total_encounters: int = 0
var learned_patterns: Dictionary = {}  # Pattern -> success_rate
var adaptation_history: Array[Dictionary] = []
var model_weights: Dictionary = {}  # For ML models
```

---

## Core Classes

### EnemyAI

```gdscript
class_name EnemyAI
extends Node2D

# Components
@export var enemy_stats: EnemyStats
@export var enemy_body: CharacterBody2D
@export var navigation_agent: NavigationAgent2D
@export var detection_area: Area2D

# State Machine
var current_state: EnemyState = EnemyState.IDLE
var state_machine: StateMachine

# Behavior Tree
var behavior_tree: BehaviorTree

# ML Components
var ml_agent: MLAgent
var observation_collector: ObservationCollector
var action_executor: ActionExecutor

# Learning
var learning_data: LearningData
var is_learning_enabled: bool = true

# Target
var target: Node2D  # Player reference
var last_known_position: Vector2

# Functions
func _ready() -> void
func _process(delta: float) -> void
func update_ai(delta: float) -> void
func collect_observations() -> ObservationData
func decide_action(observation: ObservationData) -> ActionData
func execute_action(action: ActionData, delta: float) -> void
func calculate_reward() -> float
func update_learning(observation: ObservationData, action: ActionData, reward: float) -> void
func switch_state(new_state: EnemyState) -> void
```

### StateMachine

```gdscript
class_name StateMachine
extends RefCounted

var current_state: EnemyState
var states: Dictionary = {}  # EnemyState -> StateNode
var transitions: Array[StateTransition] = []

func _init() -> void:
    initialize_states()

func initialize_states() -> void:
    states[EnemyState.IDLE] = IdleState.new()
    states[EnemyState.PATROL] = PatrolState.new()
    states[EnemyState.CHASE] = ChaseState.new()
    states[EnemyState.ATTACK] = AttackState.new()
    states[EnemyState.RETREAT] = RetreatState.new()
    states[EnemyState.SEARCH] = SearchState.new()

func update(delta: float, enemy: EnemyAI) -> void:
    if current_state in states:
        states[current_state].update(delta, enemy)
        check_transitions(enemy)

func check_transitions(enemy: EnemyAI) -> void:
    for transition in transitions:
        if transition.from_state == current_state:
            if transition.condition.check(enemy):
                transition_to(transition.to_state, enemy)

func transition_to(new_state: EnemyState, enemy: EnemyAI) -> void:
    if current_state in states:
        states[current_state].exit(enemy)
    current_state = new_state
    if current_state in states:
        states[current_state].enter(enemy)
```

### BehaviorTree

```gdscript
class_name BehaviorTree
extends RefCounted

var root_node: BTNode

func _init() -> void:
    build_tree()

func build_tree() -> void:
    # Example tree structure
    var selector: BTSelector = BTSelector.new()
    
    var attack_sequence: BTSequence = BTSequence.new()
    attack_sequence.add_child(BTCheckPlayerInRange.new())
    attack_sequence.add_child(BTAttack.new())
    
    var chase_sequence: BTSequence = BTSequence.new()
    chase_sequence.add_child(BTCheckPlayerDetected.new())
    chase_sequence.add_child(BTChase.new())
    
    var patrol_sequence: BTSequence = BTSequence.new()
    patrol_sequence.add_child(BTPatrol.new())
    
    selector.add_child(attack_sequence)
    selector.add_child(chase_sequence)
    selector.add_child(patrol_sequence)
    
    root_node = selector

func execute(enemy: EnemyAI, delta: float) -> BTStatus:
    return root_node.execute(enemy, delta)
```

### MLAgent

```gdscript
class_name MLAgent
extends RefCounted

# Model
var model: MLModel  # TensorFlow Lite or ONNX model
var model_loaded: bool = false

# Training
var is_training: bool = false
var training_data: Array[Dictionary] = []

# Inference
func load_model(model_path: String) -> bool:
    # Load TensorFlow Lite or ONNX model
    pass

func predict(observation: ObservationData) -> ActionData:
    if not model_loaded:
        return fallback_action(observation)
    
    var input_array: Array = observation.to_array()
    var output_array: Array = model.predict(input_array)
    return parse_action_output(output_array)

func fallback_action(observation: ObservationData) -> ActionData:
    # Fallback to traditional AI
    return ActionData.new()

func parse_action_output(output: Array) -> ActionData:
    var action: ActionData = ActionData.new()
    # Parse model output into action
    action.move_direction = Vector2(output[0], output[1]).normalized()
    action.move_speed = output[2]
    action.attack_type = "melee" if output[3] > 0.5 else "ranged"
    return action
```

### ObservationCollector

```gdscript
class_name ObservationCollector
extends RefCounted

var player: Node2D
var enemy: EnemyAI
var world_manager: Node

func collect(enemy: EnemyAI) -> ObservationData:
    var observation: ObservationData = ObservationData.new()
    
    # Player data
    observation.player_position = player.global_position
    observation.player_velocity = get_player_velocity()
    observation.player_health = get_player_health()
    observation.player_distance = enemy.global_position.distance_to(player.global_position)
    observation.player_direction = (player.global_position - enemy.global_position).normalized()
    
    # Recent actions
    observation.player_recent_actions = get_recent_player_actions()
    observation.player_attack_pattern = analyze_attack_pattern()
    observation.player_movement_pattern = analyze_movement_pattern()
    
    # Environment
    observation.nearby_cover = find_nearby_cover()
    observation.nearby_allies = find_nearby_allies()
    observation.terrain_type = get_terrain_type(enemy.global_position)
    observation.is_player_in_range = observation.player_distance <= enemy.enemy_stats.attack_range
    
    # Enemy state
    observation.enemy_health = enemy.enemy_stats.health
    observation.enemy_position = enemy.global_position
    observation.current_state = enemy.current_state
    
    return observation
```

### ActionExecutor

```gdscript
class_name ActionExecutor
extends RefCounted

func execute(enemy: EnemyAI, action: ActionData, delta: float) -> void:
    # Movement
    if action.move_direction.length() > 0.0:
        move_enemy(enemy, action.move_direction, action.move_speed, delta)
    
    # Attack
    if action.attack_type != "":
        perform_attack(enemy, action.attack_type, action.attack_target)
    
    # Ability
    if action.use_ability:
        use_ability(enemy, action.ability_type)

func move_enemy(enemy: EnemyAI, direction: Vector2, speed: float, delta: float) -> void:
    var velocity: Vector2 = direction * enemy.enemy_stats.speed * speed
    enemy.enemy_body.velocity = velocity
    enemy.enemy_body.move_and_slide()

func perform_attack(enemy: EnemyAI, attack_type: String, target: Vector2) -> void:
    var current_time: float = Time.get_ticks_msec() / 1000.0
    if current_time - enemy.enemy_stats.last_attack_time < enemy.enemy_stats.attack_cooldown:
        return
    
    enemy.enemy_stats.last_attack_time = current_time
    
    if attack_type == "melee":
        perform_melee_attack(enemy, target)
    elif attack_type == "ranged":
        perform_ranged_attack(enemy, target)
```

### RewardCalculator

```gdscript
class_name RewardCalculator
extends RefCounted

func calculate_reward(enemy: EnemyAI, observation: ObservationData, action: ActionData, result: Dictionary) -> float:
    var reward: float = 0.0
    
    # Damage dealt
    if result.has("damage_dealt"):
        reward += result.damage_dealt * 10.0
    
    # Damage taken (negative)
    if result.has("damage_taken"):
        reward -= result.damage_taken * 5.0
    
    # Survival time
    reward += 0.1
    
    # Distance to player (closer is better for aggressive enemies)
    var distance_reward: float = 1.0 / (observation.player_distance + 1.0)
    reward += distance_reward * 0.5
    
    # Successful attack
    if result.has("attack_hit") and result.attack_hit:
        reward += 5.0
    
    # Death (large negative)
    if result.has("died") and result.died:
        reward -= 100.0
    
    return reward
```

---

## System Architecture

### Component Hierarchy

```
EnemyAI (Node2D)
├── EnemyStats (Resource)
├── EnemyBody (CharacterBody2D)
├── NavigationAgent2D
├── DetectionArea (Area2D)
├── StateMachine
│   ├── StateNode[] (Dictionary)
│   └── StateTransition[] (Array)
├── BehaviorTree
│   └── BTNode (root)
├── MLAgent
│   └── MLModel
├── ObservationCollector
├── ActionExecutor
├── RewardCalculator
└── LearningData
```

### Data Flow

1. **AI Update Loop:**
   ```
   EnemyAI._process(delta)
   ├── ObservationCollector.collect()
   ├── Decide action:
   │   ├── If ML enabled: MLAgent.predict(observation)
   │   └── Else: BehaviorTree.execute() or StateMachine.update()
   ├── ActionExecutor.execute(action)
   ├── Calculate reward
   └── If learning: update_learning(obs, action, reward)
   ```

2. **Learning Update:**
   ```
   update_learning(observation, action, reward)
   ├── Store in LearningData.session_*
   ├── If session complete:
   │   ├── Send to training pipeline
   │   └── Update persistent patterns
   └── Update model weights (if online learning)
   ```

---

## State Implementations

### IdleState

```gdscript
class_name IdleState
extends StateNode

func enter(enemy: EnemyAI) -> void:
    enemy.enemy_body.velocity = Vector2.ZERO

func update(delta: float, enemy: EnemyAI) -> void:
    # Check for player detection
    if enemy.detection_area.has_overlapping_bodies():
        var bodies = enemy.detection_area.get_overlapping_bodies()
        for body in bodies:
            if body.is_in_group("player"):
                enemy.switch_state(EnemyState.CHASE)
                return
    
    # Randomly start patrolling
    if randf() < 0.01:  # 1% chance per frame
        enemy.switch_state(EnemyState.PATROL)

func exit(enemy: EnemyAI) -> void:
    pass
```

### ChaseState

```gdscript
class_name ChaseState
extends StateNode

func enter(enemy: EnemyAI) -> void:
    enemy.navigation_agent.target_position = enemy.target.global_position

func update(delta: float, enemy: EnemyAI) -> void:
    # Update navigation target
    enemy.navigation_agent.target_position = enemy.target.global_position
    
    # Move towards target
    var next_position: Vector2 = enemy.navigation_agent.get_next_path_position()
    var direction: Vector2 = (next_position - enemy.global_position).normalized()
    enemy.enemy_body.velocity = direction * enemy.enemy_stats.speed
    enemy.enemy_body.move_and_slide()
    
    # Check if in attack range
    var distance: float = enemy.global_position.distance_to(enemy.target.global_position)
    if distance <= enemy.enemy_stats.attack_range:
        enemy.switch_state(EnemyState.ATTACK)
    
    # Check if lost target
    if distance > enemy.enemy_stats.detection_range * 2.0:
        enemy.last_known_position = enemy.target.global_position
        enemy.switch_state(EnemyState.SEARCH)
```

### AttackState

```gdscript
class_name AttackState
extends StateNode

func enter(enemy: EnemyAI) -> void:
    enemy.enemy_body.velocity = Vector2.ZERO

func update(delta: float, enemy: EnemyAI) -> void:
    # Face target
    var direction: Vector2 = (enemy.target.global_position - enemy.global_position).normalized()
    enemy.look_at(enemy.target.global_position)
    
    # Attack
    var current_time: float = Time.get_ticks_msec() / 1000.0
    if current_time - enemy.enemy_stats.last_attack_time >= enemy.enemy_stats.attack_cooldown:
        perform_attack(enemy)
        enemy.enemy_stats.last_attack_time = current_time
    
    # Check if target out of range
    var distance: float = enemy.global_position.distance_to(enemy.target.global_position)
    if distance > enemy.enemy_stats.attack_range:
        enemy.switch_state(EnemyState.CHASE)
    
    # Check if low health
    if enemy.enemy_stats.health < enemy.enemy_stats.max_health * 0.3:
        enemy.switch_state(EnemyState.RETREAT)
```

---

## ML Integration

### Python Bridge (Subprocess)

```gdscript
class_name PythonMLBridge
extends RefCounted

var python_process: OSProcess
var input_pipe: FileAccess
var output_pipe: FileAccess

func start_python_process() -> void:
    var script_path: String = "res://ml_training/inference_server.py"
    python_process = OS.execute("python", [script_path], [], false, true, true)

func send_observation(observation: ObservationData) -> void:
    var json_data: String = JSON.stringify(observation.to_dictionary())
    input_pipe.store_string(json_data + "\n")
    input_pipe.flush()

func receive_action() -> ActionData:
    var json_data: String = output_pipe.get_line()
    var data: Dictionary = JSON.parse_string(json_data)
    return ActionData.from_dictionary(data)
```

### Model Loading (TensorFlow Lite)

```gdscript
class_name TensorFlowLiteLoader
extends RefCounted

func load_model(model_path: String) -> MLModel:
    # Via GDExtension
    var gdextension: GDExtension = load("res://addons/tensorflow_lite/tensorflow_lite.gdextension")
    var model: MLModel = gdextension.load_model(model_path)
    return model
```

---

## Learning System (Hybrid: Pre-trained + In-Game Fine-Tuning)

### Training Workflow Overview

**Hybrid Approach:**
1. **Pre-trained Models:** Load pre-trained ML models at game start (trained offline with simulation data)
2. **In-Game Fine-Tuning:** Continuously fine-tune models during gameplay using collected experience
3. **Model Updates:** Periodically update model weights based on accumulated experience
4. **Model Persistence:** Save fine-tuned models to disk for future sessions

### Pre-Trained Model Loading

```gdscript
func load_pretrained_model(model_type: String) -> bool:
    # Load pre-trained model from disk
    var model_path: String = "res://ml_models/pretrained/" + model_type + ".tflite"
    if not FileAccess.file_exists(model_path):
        push_warning("MLAgent: Pre-trained model not found: " + model_path)
        return false
    
    # Load model via Python bridge
    var success = python_bridge.load_model(model_path)
    if success:
        model_loaded = true
        push_print("MLAgent: Loaded pre-trained model: " + model_type)
    return success
```

### In-Game Fine-Tuning

```gdscript
func update_in_game_fine_tuning(observation: ObservationData, action: ActionData, reward: float) -> void:
    # Store experience for fine-tuning
    learning_data.session_observations.append(observation)
    learning_data.session_actions.append(action)
    learning_data.session_rewards.append(reward)
    
    # Accumulate experience buffer
    learning_data.experience_buffer.append({
        "observation": observation,
        "action": action,
        "reward": reward
    })
    
    # Fine-tune model periodically (every N experiences)
    if learning_data.experience_buffer.size() >= FINE_TUNING_BATCH_SIZE:
        fine_tune_model()
        learning_data.experience_buffer.clear()

func fine_tune_model() -> void:
    # Send experience buffer to Python training script for fine-tuning
    var training_data: Dictionary = {
        "experiences": serialize_experiences(learning_data.experience_buffer),
        "model_path": current_model_path,
        "fine_tune": true  # Flag for fine-tuning (not full training)
    }
    
    # Fine-tune via Python bridge
    var updated_model_path = python_bridge.fine_tune_model(training_data)
    if not updated_model_path.is_empty():
        # Reload fine-tuned model
        load_pretrained_model(updated_model_path)
        push_print("MLAgent: Model fine-tuned successfully")
```

### Real-Time Learning (Simple Adaptation)

```gdscript
func update_real_time_learning(observation: ObservationData, action: ActionData, reward: float) -> void:
    # Simple immediate adaptation (without ML model update)
    if reward > 0.0:
        # Reinforce this action pattern
        reinforce_action_pattern(observation, action)
    else:
        # Avoid this pattern
        avoid_action_pattern(observation, action)
    
    # Also accumulate for fine-tuning
    update_in_game_fine_tuning(observation, action, reward)
```

### Persistent Learning (Save Fine-Tuned Models)

```gdscript
func save_fine_tuned_model() -> void:
    # Save fine-tuned model to disk
    var save_path: String = "user://ml_models/fine_tuned/" + model_type + "_" + str(Time.get_unix_time_from_system()) + ".tflite"
    python_bridge.save_model(current_model_path, save_path)
    push_print("MLAgent: Saved fine-tuned model: " + save_path)

func load_fine_tuned_model() -> bool:
    # Try to load most recent fine-tuned model
    var fine_tuned_path = get_most_recent_fine_tuned_model()
    if not fine_tuned_path.is_empty():
        return load_pretrained_model(fine_tuned_path)
    return false
```

---

## Integration Points

### With Combat System

```gdscript
# EnemyAI needs to interact with combat
func perform_attack(enemy: EnemyAI, attack_type: String, target: Vector2) -> void:
    var combat_system: CombatSystem = get_node("/root/CombatSystem")
    var damage: float = enemy.enemy_stats.attack_damage
    combat_system.apply_damage(target, damage, attack_type)
```

### With World System

```gdscript
# Need world data for observations
func get_terrain_type(position: Vector2) -> String:
    var world_manager: WorldManager = get_node("/root/WorldManager")
    return world_manager.get_terrain_type_at(position)
```

---

## Performance Considerations

1. **Update Frequency:** Update AI every 0.1-0.2 seconds, not every frame
2. **ML Inference:** Batch predictions when possible
3. **Observation Collection:** Cache expensive calculations
4. **State Machine:** Limit state transitions per frame
5. **Learning Data:** Limit session data size, flush periodically

---

## Testing Checklist

- [ ] State machine transitions work correctly
- [ ] Behavior tree executes correctly
- [ ] Observations collect accurate data
- [ ] Actions execute correctly
- [ ] ML model loads and predicts
- [ ] Learning data stores correctly
- [ ] Real-time learning adapts behavior
- [ ] Persistent learning updates models
- [ ] Performance is acceptable (60+ FPS)
- [ ] Multiple enemies work simultaneously

---

## Error Handling

### EnemyAI Error Handling

- **Missing Target References:** Handle missing player target gracefully
- **Invalid ML Model:** Handle missing or invalid ML models gracefully
- **Python Process Errors:** Handle Python subprocess failures gracefully
- **Navigation Errors:** Handle navigation failures gracefully

### Best Practices

- Use `push_error()` for critical errors (missing models, Python failures)
- Use `push_warning()` for non-critical issues (missing targets, navigation failures)
- Return null/false on errors (don't crash)
- Validate all data before operations
- Fallback to traditional AI if ML fails

---

## Default Values and Configuration

### EnemyAI Defaults

```gdscript
current_state = EnemyState.IDLE
is_learning_enabled = true
```

### EnemyStats Defaults

```gdscript
health = 100.0
max_health = 100.0
speed = 50.0
attack_damage = 10.0
attack_range = 50.0
detection_range = 200.0
attack_cooldown = 1.0
last_attack_time = 0.0
```

### ObservationData Defaults

```gdscript
player_position = Vector2.ZERO
player_velocity = Vector2.ZERO
player_health = 100.0
player_distance = 0.0
player_direction = Vector2.ZERO
player_recent_actions = []
player_attack_pattern = {}
player_movement_pattern = {}
nearby_cover = []
nearby_allies = []
terrain_type = ""
is_player_in_range = false
enemy_health = 100.0
enemy_position = Vector2.ZERO
current_state = EnemyState.IDLE
```

### ActionData Defaults

```gdscript
move_direction = Vector2.ZERO
move_speed = 0.0
attack_type = ""
attack_target = Vector2.ZERO
use_ability = false
ability_type = ""
```

### LearningData Defaults

```gdscript
session_observations = []
session_actions = []
session_rewards = []
session_start_time = 0.0
total_encounters = 0
learned_patterns = {}
adaptation_history = []
model_weights = {}
```

---

## Complete Implementation

### EnemyAI Complete Implementation

```gdscript
class_name EnemyAI
extends Node2D

# Components
var enemy_stats: EnemyStats = EnemyStats.new()
var enemy_body: CharacterBody2D = null
var navigation_agent: NavigationAgent2D = null
var detection_area: Area2D = null

# State Machine
var current_state: EnemyState = EnemyState.IDLE
var state_machine: StateMachine = StateMachine.new()

# Behavior Tree
var behavior_tree: BehaviorTree = BehaviorTree.new()

# ML Components
var ml_agent: MLAgent = null
var observation_collector: ObservationCollector = ObservationCollector.new()
var action_executor: ActionExecutor = ActionExecutor.new()

# Learning
var learning_data: LearningData = LearningData.new()
var is_learning_enabled: bool = true

# Target
var target: Node2D = null
var last_known_position: Vector2 = Vector2.ZERO

func _ready() -> void:
    # Find components
    enemy_body = get_node_or_null("CharacterBody2D")
    navigation_agent = get_node_or_null("NavigationAgent2D")
    detection_area = get_node_or_null("DetectionArea")
    
    # Find player
    target = get_tree().get_first_node_in_group("player")
    
    # Initialize ML agent
    if is_learning_enabled:
        ml_agent = MLAgent.new()
        ml_agent.initialize()

func _process(delta: float) -> void:
    update_ai(delta)

func update_ai(delta: float) -> void:
    # Collect observations
    var observation = collect_observations()
    
    # Decide action (ML or traditional)
    var action: ActionData = null
    if is_learning_enabled and ml_agent:
        action = ml_agent.decide_action(observation)
    else:
        action = decide_action_traditional(observation)
    
    # Execute action
    if action:
        execute_action(action, delta)
    
    # Update learning
    if is_learning_enabled:
        var reward = calculate_reward()
        update_learning(observation, action, reward)
    
    # Update state machine
    state_machine.update(delta, self)

func collect_observations() -> ObservationData:
    var observation = ObservationData.new()
    
    if target:
        observation.player_position = target.global_position
        observation.player_velocity = target.velocity if target.has("velocity") else Vector2.ZERO
        observation.player_health = target.health if target.has("health") else 100.0
        observation.player_distance = global_position.distance_to(target.global_position)
        observation.player_direction = (target.global_position - global_position).normalized()
        observation.is_player_in_range = observation.player_distance <= enemy_stats.detection_range
    
    observation.enemy_health = enemy_stats.health
    observation.enemy_position = global_position
    observation.current_state = current_state
    
    return observation

func decide_action_traditional(observation: ObservationData) -> ActionData:
    # Use behavior tree or state machine
    return behavior_tree.execute(observation)

func execute_action(action: ActionData, delta: float) -> void:
    action_executor.execute(action, self, delta)

func calculate_reward() -> float:
    var reward = 0.0
    
    # Damage dealt
    if has_damaged_player():
        reward += 10.0
    
    # Damage taken
    if has_taken_damage():
        reward -= 5.0
    
    # Health remaining
    reward += enemy_stats.health / enemy_stats.max_health * 5.0
    
    # Distance to player (closer is better for melee)
    if target:
        var distance = global_position.distance_to(target.global_position)
        reward += (1.0 - distance / enemy_stats.detection_range) * 2.0
    
    return reward

func update_learning(observation: ObservationData, action: ActionData, reward: float) -> void:
    learning_data.session_observations.append(observation)
    learning_data.session_actions.append(action)
    learning_data.session_rewards.append(reward)
    
    # Update ML model periodically
    if learning_data.session_observations.size() >= 100:
        if ml_agent:
            ml_agent.update_model(learning_data)
        learning_data.session_observations.clear()
        learning_data.session_actions.clear()
        learning_data.session_rewards.clear()

func switch_state(new_state: EnemyState) -> void:
    if current_state != new_state:
        current_state = new_state
        state_machine.transition_to(new_state, self)

func has_damaged_player() -> bool:
    # Check if enemy damaged player recently
    return false  # Implement based on combat system

func has_taken_damage() -> bool:
    # Check if enemy took damage recently
    return false  # Implement based on combat system
```

---

## Save/Load System

### AI System Save Format

```gdscript
{
    "enemy_ai": {
        "enemy_id": {
            "learning_data": {
                "total_encounters": 10,
                "learned_patterns": {
                    "player_attack_pattern_1": 0.8
                },
                "model_weights": {}
            },
            "current_state": 0,  # EnemyState.IDLE
            "last_known_position": {"x": 100, "y": 200}
        }
    }
}
```

### Load Format

```gdscript
func load_ai_data(save_data: Dictionary) -> void:
    if save_data.has("enemy_ai"):
        for enemy_id in save_data.enemy_ai:
            var enemy = get_enemy_by_id(enemy_id)
            if enemy:
                var ai_data = save_data.enemy_ai[enemy_id]
                enemy.learning_data.total_encounters = ai_data.get("total_encounters", 0)
                enemy.learning_data.learned_patterns = ai_data.get("learned_patterns", {})
                enemy.current_state = ai_data.get("current_state", EnemyState.IDLE)
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── ai/
   │       ├── EnemyAI.gd
   │       ├── StateMachine.gd
   │       ├── BehaviorTree.gd
   │       ├── MLAgent.gd
   │       └── ObservationCollector.gd
   └── ml_training/
       └── inference_server.py
   ```

2. **Setup Python Environment:**
   - Install Python 3.8+
   - Install required packages: `pip install tensorflow numpy`
   - Create inference server script

3. **Setup ML Models:**
   - Train ML models (TensorFlow/PyTorch)
   - Export models to ONNX format
   - Place models in `res://ml_models/`

### Initialization Order

**Autoload Order:**
1. GameManager
2. CombatManager
3. **EnemyAI** (spawned as enemies)

### System Integration

**Systems Must Call EnemyAI:**
```gdscript
# Example: Spawn enemy
var enemy_scene = preload("res://scenes/enemies/robot.tscn")
var enemy = enemy_scene.instantiate()
enemy.enemy_stats.health = 150.0
get_tree().current_scene.add_child(enemy)
```

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing AI System are listed here.

### Required Tools

**Python 3.8+ (Required)**
- **Required for:** ML model inference
- **Installation:** https://www.python.org/downloads/
- **Status:** Must be installed for ML integration

**TensorFlow/PyTorch (Required)**
- **Required for:** ML model training and inference
- **Installation:** `pip install tensorflow` or `pip install torch`
- **Status:** Must be installed for ML integration

**ONNX Runtime (Optional)**
- **Required for:** Efficient ML inference
- **Installation:** `pip install onnxruntime`
- **Status:** Recommended for performance

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- [NavigationAgent2D](https://docs.godotengine.org/en/stable/classes/class_navigationagent2d.html) - Pathfinding
- [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Detection areas

**Status:** Will be referenced during implementation

### External Resources

**MLGodotKit (Optional)**
- **Required for:** Simplified ML integration
- **GitHub:** https://github.com/Godot-ML/MLGodotKit
- **Status:** Optional, simplifies ML integration

---

## References

**Note:** These references are specifically for implementing AI System. All links are to official documentation or relevant resources.

### Core Systems Documentation

- [NavigationAgent2D Documentation](https://docs.godotengine.org/en/stable/classes/class_navigationagent2d.html) - Pathfinding
- [Area2D Documentation](https://docs.godotengine.org/en/stable/classes/class_area2d.html) - Detection areas

### ML Resources

- [TensorFlow Documentation](https://www.tensorflow.org/api_docs) - ML framework
- [PyTorch Documentation](https://pytorch.org/docs/stable/index.html) - ML framework
- [ONNX Runtime Documentation](https://onnxruntime.ai/docs/) - ML inference
- [MLGodotKit GitHub](https://github.com/Godot-ML/MLGodotKit) - Godot ML integration

### Inspiration

- [Arc Raiders](https://www.ea.com/games/arc-raiders) - Adaptive AI inspiration

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- EnemyStats is a Resource (can be created/edited in inspector)
- Enemy properties configurable via @export variables
- State machine configurable in inspector
- Behavior tree configurable in inspector

**Visual Configuration:**
- Enemy stats editable in inspector
- State machine transitions editable in inspector
- Behavior tree editable in inspector
- ML settings configurable in inspector

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Behavior tree visual editor
  - State machine visual editor
  - ML model tester

**Current Approach:**
- Uses Godot's native systems (no custom tools needed)
- Enemy stats created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

