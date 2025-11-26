# New Systems Summary

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

This document summarizes the design decisions for new game systems that need technical specifications: Trading/Economy, Day/Night Cycle, Weather, Item Pickup, Relationship System, and Tutorial/Onboarding.

---

## Trading/Economy System

### Dynamic Pricing
- **Approach:** Hybrid (Relationship + Supply/Demand)
- Base prices modified by relationship level
- Then adjusted by supply/demand (sell many items → price drops, buy many items → price increases)

### Currency System
- **Approach:** Currency + Barter System
- Currency is a droppable item (like Terraria coins)
- Dedicated currency slot in inventory
- Players can use items to reduce purchase cost (barter)
- Not all NPCs accept all items for barter

### Trading Interface
- **Approach:** Quick Trade + Full Shop
- Quick trade button for common items (currency only)
- Full shop menu for browsing (currency + barter)

### Player Shop
- **Decision:** No player shop needed
- Players don't sell items (mainly solo game with coop)
- Trading is NPCs selling to players

### NPC Shop Inventory
- **Approach:** Hybrid (Fixed Core + Rotating Extras) + Relationship-Based
- Fixed core items always available
- Additional items rotate daily/weekly
- Higher-tier items unlock with better relationship

### Barter System
- Players put items in "sell" slot to reduce purchase cost
- NPCs put items in "buy" slot (items they want)
- Items in buy slot reduce currency owed
- Not all NPCs accept all items for selling
- Quick trade menu: currency only
- Full shop menu: currency + barter

### NPC Item Acceptance
- **Approach:** Tag-Based
- NPCs accept items with specific tags
- Items can have multiple tags
- More flexible than categories

### Currency Types
- **Decision:** Support multiple currencies (details TBD)
- System designed flexibly to support both single and multiple currency systems
- Specific currency types and conversion rates to be determined

---

## Day/Night Cycle System

### Duration
- **Approach:** Variable Duration
- Day/night length changes based on biome/season
- Some areas have longer days/nights
- More dynamic than fixed duration

### Gameplay Effects
- **Approach:** Full Effects (Visual + Enemies + Survival)
- Lighting changes (visual)
- Different enemy spawns (some only at night)
- Survival stat changes (temperature, etc.)
- Most immersive and complex

### Time Display
- **Approach:** Hybrid (Visual + Optional Clock)
- Visual indicators always visible (sun/moon position, sky color)
- Optional clock in HUD/settings
- Best of both worlds

---

## Weather System

### Weather Types
- **Approach:** Hybrid (Normal + Sci-Fi), Biome-Dependent
- Normal weather: Rain, Snow, Clear, Cloudy
- Sci-Fi weather: Acid Rain, Radiation Storms, Toxic Fog, Energy Storms
- Weather types vary by biome
- Some biomes have normal weather, others have sci-fi weather

### Weather Effects
- **Approach:** Full Effects (Visual + Survival + Physics)
- Visual changes (atmosphere, sky color)
- Survival stat changes (temperature, visibility, movement speed)
- Pixel physics interactions (rain fills water pools, acid rain damages materials)
- Most complete and complex system

---

## Item Pickup System

### Auto-Pickup Range
- **Approach:** Hybrid (Base Range + Upgrades)
- Base range for all items
- Can upgrade range with skills/items
- Currency has longer base range
- Flexible and rewarding

### Visual Feedback
- **Approach:** Pull Animation
- Items move toward player when in pickup range
- Satisfying pickup feel
- More engaging than simple glow

---

## Relationship System

### Relationship Levels
- **Approach:** Reputation Tiers (with negative tiers)
- Positive tiers: Stranger, Acquaintance, Friend, Close Friend, Ally
- Negative tiers: Can lose reputation (tiers TBD)
- More narrative-focused and immersive

### Gain/Lose Reputation
- **Approach:** Full System (Quests + Dialogue + Actions)
- Complete quests = gain reputation
- Dialogue choices affect reputation
- Actions have consequences (help NPCs, attack them, etc.)
- Most complete system

### Relationship Benefits
- **Approach:** Full Benefits (Trading + Quests + Items + Story)
- Better prices (trading)
- Better quests unlock
- Special items/recipes unlock
- Story content/dialogue unlocks
- Most rewarding system

---

## Tutorial/Onboarding System

### Tutorial Approach
- **Approach:** Hybrid (Optional NPC + Context Popups)
- Optional tutorial NPC for basics
- Context popups for advanced systems
- Best of both worlds
- **Note:** Only first question answered, more questions needed

---

## Next Steps

1. Complete Tutorial/Onboarding System design questions
2. Create technical specifications for each system:
   - Trading/Economy System
   - Day/Night Cycle System
   - Weather System
   - Item Pickup System
   - Relationship System
   - Tutorial/Onboarding System
3. Integrate new systems with existing systems
4. Update technical-specs-index.md with new specs

---

## Integration Points

### Trading/Economy System
- Integrates with: Inventory System, Item Database, Relationship System, UI System

### Day/Night Cycle System
- Integrates with: Survival System, World Generation, Enemy Spawning, Lighting System, UI System

### Weather System
- Integrates with: Survival System, Pixel Physics System, World Generation, Day/Night Cycle, UI System

### Item Pickup System
- Integrates with: Inventory System, Item Database, Player Controller, UI System

### Relationship System
- Integrates with: NPC System, Dialogue System, Quest System, Trading System, UI System

### Tutorial/Onboarding System
- Integrates with: All systems (teaches players about them), UI System

