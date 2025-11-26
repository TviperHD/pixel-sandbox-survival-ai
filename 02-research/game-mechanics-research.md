# Game Mechanics Research

**Date:** 2025-11-24  
**Source:** Analysis of Noita, Terraria, and similar games

## Key Findings

- Noita uses custom C++ engine for pixel physics simulation
- Terraria combines survival, building, and exploration effectively
- Pixel physics requires performance optimization (chunking, LOD, culling)
- Survival mechanics need careful balance to avoid frustration
- Building systems benefit from grid + freeform options

## Relevance

Understanding successful games in similar genres helps design our systems. Guides implementation priorities.

## Links

- Noita: https://noitagame.com
- Terraria: https://terraria.org

## Noita Mechanics Analysis

### Pixel Physics System
- **Every pixel is simulated** - creates emergent destruction
- **Material interactions** - different materials react differently
- **Liquid simulation** - water, lava, oil, etc. flow realistically
- **Powder simulation** - sand, snow, etc. fall and pile up
- **Chemical reactions** - materials can combine/explode

### Key Features
- Destructible terrain at pixel level
- Emergent gameplay from physics
- Spell crafting system
- Permadeath mechanics
- Procedural generation

### Technical Challenges
- Performance optimization for pixel simulation
- Efficient spatial partitioning
- Material property management
- Physics calculations

## Terraria Mechanics Analysis

### Survival Elements
- **Health and Mana** - resource management
- **Hunger system** - food required for survival
- **Day/Night cycle** - different challenges
- **Boss progression** - difficulty scaling
- **NPCs and towns** - building communities

### Building System
- **Block placement** - grid-based construction
- **Furniture and decorations** - customization
- **Wiring system** - mechanical contraptions
- **Multiplayer support** - co-op gameplay

### Exploration
- **Biomes** - diverse environments
- **Underground exploration** - mining and caves
- **Treasure hunting** - rewards for exploration
- **Procedural worlds** - unique each playthrough

## Combining Mechanics

### Core Systems Needed

1. **Pixel Physics Engine**
   - Material simulation
   - Destruction system
   - Liquid/powder physics
   - Performance optimization

2. **Survival Systems**
   - Health/mana management
   - Resource gathering
   - Crafting system
   - Building mechanics

3. **Combat System**
   - Player combat
   - Enemy AI (ML-driven)
   - Weapon variety
   - Physics-based damage

4. **World Generation**
   - Procedural terrain
   - Biome generation
   - Resource distribution
   - Structure placement

5. **Progression Systems**
   - Character upgrades
   - Equipment crafting
   - Skill/ability unlocks
   - Difficulty scaling

## Technical Architecture Considerations

### Performance Priorities
1. **Pixel simulation optimization** - most resource-intensive
2. **AI inference** - ML model execution
3. **Rendering** - efficient sprite batching
4. **Physics calculations** - spatial optimization

### Scalability
- Chunk-based world loading
- Level-of-detail systems
- Culling and occlusion
- Efficient data structures

### Integration Challenges
- Combining pixel physics with survival mechanics
- Balancing AI difficulty with player progression
- Managing complexity without overwhelming players
- Ensuring emergent gameplay remains fun

## Best Practices

1. **Start Simple** - Begin with basic pixel physics, add complexity gradually
2. **Iterate on AI** - Start with traditional AI, evolve to ML
3. **Test Extensively** - Physics systems need thorough testing
4. **Optimize Early** - Performance is critical for pixel simulation
5. **Player Feedback** - Ensure destruction feels satisfying

## References

- Noita development insights
- Terraria design philosophy
- Sandbox game design principles
- Physics simulation techniques

