# Game Engine Research

**Date:** 2025-11-24  
**Source:** Web research and engine documentation

## Key Findings

- Unity ML-Agents provides best AI integration but requires license for commercial use
- Godot is open-source, excellent for 2D, but requires custom ML integration
- Defold and GameMaker are less suitable for complex ML needs
- Godot selected as engine choice

## Relevance

Critical decision for project - engine choice affects all technical implementation. Godot chosen for open-source nature and user preference.

## Links

- Unity: https://unity.com
- Godot: https://godotengine.org
- Defold: https://defold.com
- GameMaker: https://gamemaker.io

## Requirements

- 2D pixel art support
- Physics engine capable of pixel-level simulation
- Cross-platform deployment
- ML/AI framework integration capabilities
- Good performance for complex simulations
- Active community and documentation

## Engine Options

### Unity

**Pros:**
- Extensive ML-Agents Toolkit for AI integration
- Large community and asset store
- Strong 2D support with SpriteRenderer and Tilemap systems
- C# scripting (familiar to many developers)
- Cross-platform deployment
- Excellent documentation
- Can handle complex physics simulations

**Cons:**
- Larger build sizes
- Steeper learning curve
- Requires Unity license for commercial use (revenue thresholds)

**ML Integration:** Unity ML-Agents Toolkit (excellent for this project)

**Best For:** Projects requiring advanced AI/ML integration

### Godot

**Pros:**
- Open-source and free
- Lightweight and efficient
- Excellent 2D engine
- GDScript (Python-like, easy to learn)
- C# support available
- Active community
- Good documentation

**Cons:**
- Less mature ML integration (would need custom solutions)
- Smaller asset ecosystem compared to Unity
- May require more custom work for pixel physics

**ML Integration:** Would need custom integration with TensorFlow/PyTorch

**Best For:** Indie developers wanting open-source solution

### Defold

**Pros:**
- Free and cross-platform
- Optimized for 2D games
- Very small bundle sizes (<2MB typical)
- Efficient performance
- Lua scripting

**Cons:**
- Smaller community
- Less ML/AI integration support
- Limited resources compared to Unity/Godot

**ML Integration:** Would require significant custom work

**Best For:** Simple 2D games, less suitable for complex AI needs

### GameMaker Studio 2

**Pros:**
- Excellent for 2D games
- Visual scripting + GML
- Good pixel art support
- Active community

**Cons:**
- Commercial license required
- Limited ML integration
- Less flexible for complex systems

**ML Integration:** Limited, would need custom solutions

**Best For:** Traditional 2D games without advanced AI

## Recommendation

**Selected: Godot Engine**

Godot has been chosen for this project because:
1. **User Preference** - Already installed and ready to use
2. **Open-Source** - Free, no licensing concerns
3. **Excellent 2D Engine** - Built specifically for 2D games
4. **Lightweight** - Efficient performance, smaller builds
5. **GDScript** - Python-like language, easy to learn
6. **ML Integration Options** - Can integrate via Python bindings or GDExtension

**ML Integration Approaches:**
- **Python Integration** - Use GDExtension or subprocess to connect with TensorFlow/PyTorch
- **MLGodotKit** - Lightweight toolkit for simpler ML models (Linear Regression, Neural Networks)
- **TensorFlow Lite / ONNX Runtime** - Deploy optimized models via GDExtension
- **Hybrid Approach** - Train models externally in Python, deploy to Godot for inference

## Next Steps

1. Prototype pixel physics system in Godot
2. Research and test Python-Godot integration for ML
3. Evaluate MLGodotKit for simpler models
4. Test TensorFlow Lite integration for optimized models
5. Evaluate performance with pixel-level simulation
6. Consider hybrid approach (Godot for game, Python for training)

