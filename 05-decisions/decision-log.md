# Decision Log

## [2025-11-24] - Project Initialization

**Context:** Starting new project combining Noita-style pixel physics, Terraria-style survival, and Arc Raiders-style AI enemies.

**Options Considered:**
- Various project names and structures
- Research approach and documentation organization

**Decision:** 
- Project name: `pixel-sandbox-survival-ai`
- Follow standard workspace structure (6 subfolders)
- Status: Researching

**Rationale:** 
- Clear, descriptive project name
- Standard structure ensures consistency
- Research phase needed before technical decisions

**Consequences:** 
- Project structure established
- Research phase initiated
- Technical decisions pending further research

---

## [2025-11-24] - Game Engine Selection

**Context:** Need to choose game engine that supports 2D pixel art, physics simulation, and ML/AI integration.

**Options Considered:**
- Unity (with ML-Agents Toolkit)
- Godot (open-source alternative)
- Defold (2D-focused)
- GameMaker Studio 2 (2D-focused)

**Decision:** **Godot Engine**

**Rationale:** 
- User already has Godot installed
- Open-source and free (no licensing concerns)
- Excellent 2D engine capabilities
- Lightweight and efficient
- Good community support
- GDScript is Python-like and easy to learn
- Can integrate ML through Python bindings or GDExtension

**Consequences:** 
- Will need custom ML integration (no built-in ML-Agents)
- Can use Python integration or GDExtension for TensorFlow/PyTorch
- May use MLGodotKit for simpler ML models
- Technical architecture updated to use Godot systems

---

## [2025-11-24] - AI Approach Selection (Pending)

**Context:** Need to determine how to implement learning enemies in Godot.

**Options Considered:**
- Deep Reinforcement Learning (via Python/TensorFlow integration)
- MLGodotKit (simpler ML models)
- Behavior Trees + ML Enhancement
- Neural Networks with Genetic Algorithms
- Traditional AI (starting point)

**Decision:** **PENDING** - Recommend starting with traditional AI, evolving to Python-based ML integration

**Rationale:**
- Start simple, add complexity gradually
- Python integration allows use of TensorFlow/PyTorch
- MLGodotKit good for prototyping simpler models
- Allows iterative development
- Reduces initial complexity

**Consequences:**
- Development timeline affected
- Training phase required later
- Performance considerations for ML models
- Need to set up Python-Godot bridge

---

## [2025-11-24] - World Setting & Theme

**Context:** Need to define the game's world, setting, and visual style.

**Options Considered:**
- Fantasy
- Sci-Fi
- Post-Apocalyptic
- Modern
- Other

**Decision:** **Sci-Fi / Post-Apocalyptic**

**Rationale:**
- Fits well with advanced technology themes
- Allows for diverse biomes and hazards
- Provides context for AI enemies (robotic security, etc.)
- Creates interesting survival challenges

**Consequences:**
- World design focuses on ruins, tech facilities, hazards
- Enemies can be robotic, mutated, or AI-controlled
- Resources include tech components, energy sources
- Environmental hazards include radiation, toxic zones

---

## [2025-11-24] - Survival Mechanics

**Context:** Define survival systems and difficulty level.

**Options Considered:**
- Simple survival (health, hunger)
- Moderate survival (health, hunger, thirst)
- Complex survival (multiple systems)
- Difficulty levels (easy, normal, hard)

**Decision:** 
- **Survival Systems:** Health, Hunger, Thirst, Temperature, Radiation, Oxygen/Air Quality, Sleep/Rest
- **Difficulty:** Harder side (challenging but fair)
- **Death System:** Respawn with options (beds, checkpoints, world spawn)

**Rationale:**
- Comprehensive survival creates engaging challenge
- Harder difficulty fits post-apocalyptic theme
- Respawn options provide flexibility while maintaining challenge

**Consequences:**
- More complex systems to implement
- Need careful balance to avoid frustration
- Respawn system needs design consideration

---

## [2025-11-24] - AI Learning System

**Context:** Determine how enemies learn and adapt.

**Options Considered:**
- Real-time learning only
- Persistent learning only
- Hybrid approach
- No learning (traditional AI)

**Decision:** **Hybrid Approach** - "A bit of both"

**Rationale:**
- Real-time learning provides immediate adaptation
- Persistent learning creates long-term challenge
- Combines best of both approaches
- More interesting and dynamic gameplay

**Consequences:**
- More complex implementation
- Need both real-time and persistent systems
- Requires careful balance to avoid frustration

---

## [2025-11-24] - Pixel Physics Scope

**Context:** Determine level of detail for pixel physics system.

**Options Considered:**
- Basic destruction only
- Material simulation
- Full physics (liquids, powders, gases)
- Chemical reactions

**Decision:** **Comprehensive Physics** - "All of the above and really just the best way to do its task with limits of course"

**Rationale:**
- Full physics creates most interesting gameplay
- Material interactions add depth
- Performance limits will guide implementation
- Can scale back if needed for performance

**Consequences:**
- Most technically challenging system
- Performance optimization critical
- May need to simplify based on testing

---

## [2025-11-24] - Progression System

**Context:** Define how players progress through the game.

**Options Considered:**
- Linear progression
- Open-ended progression
- Quest/story-based
- Pure sandbox

**Decision:** **"Maybe a little bit of everything?"**

**Rationale:**
- Flexible approach allows for multiple playstyles
- Can include various progression types
- Keeps options open for development

**Consequences:**
- Need to design multiple progression systems
- Can be complex to balance
- Provides flexibility in development

---

## Future Decisions Needed

- Development priorities (what to build first)
- Art style and resolution details
- Platform targets
- Multiplayer approach (if applicable)
- Monetization model (if applicable)
- Specific progression system details

