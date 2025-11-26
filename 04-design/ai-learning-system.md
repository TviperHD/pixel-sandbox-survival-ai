# AI Learning System Design

**Date:** 2025-11-24  
**Status:** Planning

## Learning Approach: Hybrid System

**Decision:** "A bit of both" - Combining real-time adaptation with persistent learning.

### Real-Time Learning (During Gameplay)
- **Session-based adaptation** - Enemies learn during current play session
- **Immediate response** - Quick adaptation to player tactics
- **Tactical learning** - Adapts to current combat situation
- **Short-term memory** - Remembers recent player actions

### Persistent Learning (Across Sessions)
- **Long-term patterns** - Learns from multiple play sessions
- **Global knowledge** - Shared learning across all enemies (or enemy types)
- **Progressive difficulty** - Enemies get smarter over time
- **Persistent memory** - Retains learned behaviors

## What Enemies Learn

### Combat Patterns
- **Attack timing** - When player attacks, how often
- **Dodge patterns** - How player dodges, when they dodge
- **Defensive strategies** - How player blocks, retreats
- **Weapon preferences** - Melee vs ranged, preferred ranges
- **Combo patterns** - Attack sequences player uses

### Movement & Positioning
- **Movement habits** - Preferred movement patterns
- **Positioning** - Where player likes to fight from
- **Retreat patterns** - How player escapes danger
- **Approach patterns** - How player engages enemies

### Resource & Building Behavior
- **Resource gathering routes** - Common paths player takes
- **Base locations** - Where player builds structures
- **Building patterns** - How player constructs defenses
- **Resource priorities** - What resources player values

### Strategic Adaptation
- **Weakness exploitation** - Identifies player weaknesses
- **Counter-strategies** - Develops counters to player tactics
- **Environmental usage** - Uses terrain effectively
- **Coordination** - Works with other enemies (if applicable)

## Learning Implementation

### Phase 1: Traditional AI (Starting Point)
- **State machines** - Basic enemy behaviors
- **Behavior trees** - Decision-making structures
- **Pathfinding** - Navigation and movement
- **Combat AI** - Basic attack/defend patterns

**Purpose:** Establish baseline, test gameplay, gather data

### Phase 2: Simple ML Integration
- **MLGodotKit** - Start with simpler ML models
- **Basic learning** - Learn simple patterns (dodge timing, etc.)
- **Parameter optimization** - ML optimizes AI parameters
- **Hybrid approach** - ML enhances traditional AI

**Purpose:** Prototype ML integration, test performance

### Phase 3: Advanced ML System
- **Deep Reinforcement Learning** - Full DRL implementation
- **Neural networks** - Complex behavior learning
- **External training** - Train models in Python
- **Model deployment** - Deploy trained models to Godot

**Purpose:** Full adaptive AI system

## Learning Architecture

### Observation Space (What AI Sees)
- **Player position** - Relative to enemy
- **Player velocity** - Movement direction and speed
- **Player health** - Current health percentage
- **Player actions** - Recent actions (attack, dodge, etc.)
- **Player equipment** - Visible weapons/armor
- **Environment** - Terrain, obstacles, cover
- **Other enemies** - Positions of allies (if applicable)
- **Resources** - Nearby resources player might want

### Action Space (What AI Can Do)
- **Movement** - Move in different directions
- **Attack** - Different attack types
- **Defend** - Block, dodge, retreat
- **Positioning** - Move to advantageous positions
- **Use environment** - Interact with terrain
- **Coordination** - Signal other enemies (if applicable)

### Reward Function (What AI Optimizes)
- **Damage dealt** - Reward for hitting player
- **Damage avoided** - Reward for avoiding player attacks
- **Survival time** - Reward for staying alive
- **Player health reduction** - Reward for reducing player health
- **Strategic positioning** - Reward for good positioning
- **Penalties** - Negative rewards for bad decisions

## Learning Phases

### Initial Training (Pre-Release)
- **Simulation training** - Train in controlled environments
- **Scripted scenarios** - Various combat situations
- **Baseline behaviors** - Establish starting enemy behaviors
- **Balanced difficulty** - Ensure fair starting difficulty

### Live Learning (Post-Release)
- **Player data collection** - Gather data from real gameplay
- **Periodic retraining** - Retrain models with new data
- **Model updates** - Deploy updated models
- **Balance monitoring** - Ensure difficulty stays balanced

## Learning Limits & Controls

### Performance Limits
- **Inference speed** - ML models must run fast enough (<16ms)
- **Model size** - Keep models small for performance
- **Memory usage** - Limit memory footprint
- **CPU/GPU usage** - Balance with other game systems

### Learning Limits
- **Learning rate** - How fast enemies adapt
- **Forgetting** - Enemies forget old patterns over time?
- **Difficulty caps** - Maximum difficulty enemies can reach
- **Player skill consideration** - Adapt to player skill level

### Balance Controls
- **Difficulty scaling** - Ensure enemies don't become too hard
- **Player counterplay** - Always give player ways to counter
- **Fairness** - Ensure learning doesn't create unfair situations
- **Fun factor** - Learning should enhance, not frustrate

## Enemy Types & Learning

### Basic Enemies
- **Simple learning** - Basic pattern recognition
- **Quick adaptation** - Fast but limited learning
- **Common behaviors** - Learn common player patterns
- **Lower difficulty** - Easier to defeat

### Elite Enemies
- **Advanced learning** - More complex pattern recognition
- **Strategic adaptation** - Learn strategic patterns
- **Unique behaviors** - More sophisticated tactics
- **Higher difficulty** - More challenging

### Boss Enemies
- **Highly trained** - Pre-trained with advanced models
- **Complex behaviors** - Multiple attack patterns
- **Adaptive strategies** - Can adapt mid-fight
- **Significant challenge** - Major difficulty spike

## Technical Implementation

### Training Pipeline
1. **Data collection** - Gather gameplay data
2. **Data preprocessing** - Clean and format data
3. **Model training** - Train ML models (Python)
4. **Model evaluation** - Test model performance
5. **Model optimization** - Optimize for runtime
6. **Model export** - Export to TensorFlow Lite/ONNX
7. **Model deployment** - Load into Godot
8. **Runtime inference** - Run models during gameplay

### Integration Methods
- **Phase 1:** MLGodotKit for simple models
- **Phase 2:** Python subprocess for training, simple inference
- **Phase 3:** GDExtension + TensorFlow Lite for production

### Performance Optimization
- **Model quantization** - Reduce model precision
- **Model pruning** - Remove unnecessary connections
- **Batch inference** - Process multiple enemies together
- **Caching** - Cache common predictions
- **LOD system** - Simpler AI for distant enemies

## Ethical Considerations

### Fairness
- **No cheating** - AI doesn't have unfair advantages
- **Predictable enough** - Players can learn enemy patterns
- **Counterplay** - Always ways to counter AI strategies

### Player Experience
- **Challenge, not frustration** - Difficult but fun
- **Variety** - Learning creates variety, not repetition
- **Rewarding** - Defeating adaptive enemies feels rewarding

### Transparency
- **Visual indicators** - Show when enemies are adapting
- **Feedback** - Let players know what enemies learned
- **Options** - Allow players to reset learning (if desired)

