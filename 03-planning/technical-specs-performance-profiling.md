# Technical Specifications: Performance/Profiling System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the performance/profiling system with comprehensive metrics tracking (FPS, frame time, memory, CPU, GPU, network, draw calls, physics), toggleable overlay, visual warnings, hybrid logging (automatic + manual + event-based), detailed performance budgets per system, hybrid memory profiling, multiple export formats, real-time and historical data, advanced customization, performance snapshots, detailed recommendations, and advanced optimization techniques. This system integrates with all game systems to provide comprehensive performance monitoring and optimization guidance.

---

## Research Notes

### Performance Profiling Best Practices

**Research Findings:**
- Comprehensive metrics provide complete performance picture
- Sampling-based profiling reduces overhead significantly
- Async logging prevents blocking main thread
- Configurable detail levels balance data collection and performance
- Performance budgets help maintain target frame rates
- Visual warnings quickly identify performance issues
- Historical data helps identify trends and regressions

**Sources:**
- [Godot 4 Performance Documentation](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance optimization
- [Unity Profiler Best Practices](https://unity.com/how-to/best-practices-for-profiling-game-performance) - Profiling techniques
- General game performance profiling best practices

**Implementation Approach:**
- Comprehensive metrics tracking (FPS, memory, CPU, GPU, network)
- Sampling-based profiling (configurable intervals)
- Async logging (background threads)
- Configurable detail levels (minimal, normal, detailed, verbose)
- Performance budgets per system
- Visual warnings (color changes, icons)
- Historical data tracking (graphs, trends)
- Multiple export formats (CSV, JSON, specialized)

**Why This Approach:**
- Comprehensive monitoring without excessive overhead
- Actionable insights for optimization
- Flexible configuration for different needs
- Professional-grade profiling capabilities

### Performance Budgets Best Practices

**Research Findings:**
- Frame time budgets essential for maintaining target FPS
- Per-system budgets identify bottlenecks
- Hardware tier budgets ensure scalability
- Dynamic adjustment adapts to current performance

**Sources:**
- Unity performance budgeting practices
- General game development performance standards

**Implementation Approach:**
- Overall frame time budget (16.66ms for 60 FPS)
- Per-system budgets (rendering, physics, AI, game logic, audio, network)
- Hardware tier budgets (low-end, mid-range, high-end)
- Dynamic adjustment based on current performance

**Why This Approach:**
- Identifies bottlenecks per system
- Helps maintain target frame rate
- Supports different hardware tiers
- Enables proactive optimization

### Memory Profiling Best Practices

**Research Findings:**
- Basic memory tracking has low overhead
- Detailed allocation tracking has higher overhead
- Leak detection requires periodic checks
- Memory profiling by category helps identify issues

**Sources:**
- Unity Memory Profiler documentation
- General memory profiling best practices

**Implementation Approach:**
- Basic profiling always on (low overhead)
- Detailed profiling optional (debug builds or toggle)
- Leak detection periodic checks
- Memory tracking by category

**Why This Approach:**
- Useful data with minimal overhead
- Detailed profiling available when needed
- Leak detection catches memory issues
- Configurable to balance detail and performance

---

## Data Structures

### PerformanceMetric

```gdscript
class_name PerformanceMetric
extends RefCounted

var metric_id: String  # Unique metric ID
var metric_name: String  # Display name
var category: MetricCategory  # Metric category
var value: float = 0.0  # Current value
var min_value: float = 0.0  # Minimum value
var max_value: float = 0.0  # Maximum value
var average_value: float = 0.0  # Average value
var unit: String = ""  # Unit (ms, MB, %, etc.)
var enabled: bool = true  # Is metric enabled
var visible: bool = true  # Is metric visible in overlay

enum MetricCategory {
    FRAME_RATE,      # FPS, frame time
    MEMORY,          # RAM, VRAM
    CPU,             # CPU usage, per-core
    GPU,             # GPU usage, rendering stats
    NETWORK,         # Latency, bandwidth
    PHYSICS,         # Physics updates, collisions
    RENDERING,       # Draw calls, triangles, vertices
    AUDIO,           # Audio processing
    OTHER            # Other metrics
}
```

### PerformanceBudget

```gdscript
class_name PerformanceBudget
extends Resource

# Budget Identification
@export var budget_id: String  # Unique budget ID
@export var budget_name: String  # Display name
@export var system_name: String  # System this budget applies to

# Budget Values
@export var target_frame_time_ms: float = 16.66  # Target frame time (60 FPS default)
@export var warning_threshold: float = 0.8  # Warning at 80% of budget
@export var critical_threshold: float = 0.95  # Critical at 95% of budget

# Per-System Budgets (as percentage of frame time)
@export var rendering_budget: float = 0.45  # 45% of frame time
@export var physics_budget: float = 0.25  # 25% of frame time
@export var ai_budget: float = 0.15  # 15% of frame time
@export var game_logic_budget: float = 0.10  # 10% of frame time
@export var audio_budget: float = 0.05  # 5% of frame time
@export var network_budget: float = 0.0  # Variable (multiplayer)

# Hardware Tier
@export var hardware_tier: HardwareTier = HardwareTier.MID_RANGE

enum HardwareTier {
    LOW_END,      # 30 FPS target, lenient budgets
    MID_RANGE,    # 60 FPS target, standard budgets
    HIGH_END      # 60+ FPS target, strict budgets
}
```

### PerformanceSnapshot

```gdscript
class_name PerformanceSnapshot
extends RefCounted

var snapshot_id: String  # Unique snapshot ID
var timestamp: float = 0.0  # Snapshot timestamp
var metrics: Dictionary = {}  # metric_id -> value
var budgets: Dictionary = {}  # budget_id -> {current: float, budget: float}
var context: Dictionary = {}  # Context data (level, event, etc.)
var screenshot: Image = null  # Optional screenshot
```

### PerformanceRecommendation

```gdscript
class_name PerformanceRecommendation
extends RefCounted

var recommendation_id: String  # Unique recommendation ID
var priority: int = 0  # Priority (higher = more important)
var category: String = ""  # Category (memory, rendering, physics, etc.)
var title: String = ""  # Recommendation title
var description: String = ""  # Detailed description
var action: String = ""  # Actionable suggestion
var metric_id: String = ""  # Related metric ID
var threshold: float = 0.0  # Threshold that triggered recommendation
```

### ProfilerSettings

```gdscript
class_name ProfilerSettings
extends Resource

# Display Settings
@export var overlay_enabled: bool = false  # Overlay visible
@export var overlay_key: String = "F3"  # Toggle key
@export var overlay_position: Vector2 = Vector2(10, 10)  # Overlay position
@export var overlay_size: Vector2 = Vector2(300, 400)  # Overlay size

# Profiling Settings
@export var detail_level: DetailLevel = DetailLevel.NORMAL
@export var sampling_interval: float = 0.1  # Sampling interval in seconds
@export var enable_async_logging: bool = true
@export var auto_disable_when_hidden: bool = true

enum DetailLevel {
    MINIMAL,    # Basic metrics only
    NORMAL,     # Standard metrics
    DETAILED,   # All metrics
    VERBOSE     # Maximum detail (debug only)
}

# Logging Settings
@export var logging_enabled: bool = false
@export var auto_logging_interval: float = 1.0  # Auto-log interval in seconds
@export var log_format: LogFormat = LogFormat.JSON
@export var max_log_file_size_mb: int = 100  # Max log file size

enum LogFormat {
    CSV,
    JSON,
    BINARY
}

# Memory Profiling
@export var basic_memory_profiling: bool = true  # Always on
@export var detailed_memory_profiling: bool = false  # Optional
@export var leak_detection_interval: float = 60.0  # Leak check interval

# Recommendations
@export var recommendations_enabled: bool = true
@export var recommendation_priority_threshold: int = 5  # Show recommendations above this priority
```

---

## Core Classes

### PerformanceProfiler (Autoload Singleton)

```gdscript
class_name PerformanceProfiler
extends Node

# Profiler State
var is_profiling: bool = false
var is_overlay_visible: bool = false
var current_settings: ProfilerSettings = null

# Metrics Collection
var metrics: Dictionary = {}  # metric_id -> PerformanceMetric
var metric_history: Dictionary = {}  # metric_id -> Array[float] (historical values)
var max_history_size: int = 300  # Keep last 300 samples (30 seconds at 10 FPS)

# Performance Budgets
var budgets: Dictionary = {}  # budget_id -> PerformanceBudget
var current_budget: PerformanceBudget = null

# Snapshots
var snapshots: Array[PerformanceSnapshot] = []
var max_snapshots: int = 100

# Recommendations
var recommendations: Array[PerformanceRecommendation] = []
var max_recommendations: int = 20

# Memory Profiling
var memory_profiler: MemoryProfiler = null
var memory_snapshots: Array[Dictionary] = []

# Logging
var logger: PerformanceLogger = null
var log_queue: Array[Dictionary] = []

# UI Components
var overlay: Control = null
var overlay_container: VBoxContainer = null

# Sampling
var sampling_timer: float = 0.0
var last_sample_time: float = 0.0

# Signals
signal metric_updated(metric_id: String, value: float)
signal budget_exceeded(budget_id: String, current: float, budget: float)
signal recommendation_generated(recommendation: PerformanceRecommendation)
signal snapshot_created(snapshot_id: String)

# Initialization
func _ready() -> void
func initialize() -> void

# Profiling Control
func start_profiling() -> void
func stop_profiling() -> void
func toggle_overlay() -> void
func set_overlay_visible(visible: bool) -> void

# Metrics Management
func register_metric(metric: PerformanceMetric) -> bool
func update_metric(metric_id: String, value: float) -> void
func get_metric(metric_id: String) -> PerformanceMetric
func get_metric_history(metric_id: String) -> Array[float]
func enable_metric(metric_id: String, enabled: bool) -> void
func set_metric_visible(metric_id: String, visible: bool) -> void

# Performance Budgets
func register_budget(budget: PerformanceBudget) -> bool
func set_active_budget(budget_id: String) -> void
func check_budgets() -> void
func get_budget_status(budget_id: String) -> Dictionary  # Returns {current: float, budget: float, percentage: float}

# Snapshots
func create_snapshot(context: Dictionary = {}) -> PerformanceSnapshot
func create_automatic_snapshot(trigger: String) -> PerformanceSnapshot
func get_snapshot(snapshot_id: String) -> PerformanceSnapshot
func compare_snapshots(snapshot1_id: String, snapshot2_id: String) -> Dictionary
func export_snapshots(path: String, format: String = "json") -> bool

# Recommendations
func generate_recommendations() -> void
func get_recommendations(priority_threshold: int = 0) -> Array[PerformanceRecommendation]
func clear_recommendations() -> void

# Logging
func start_logging() -> void
func stop_logging() -> void
func log_manual() -> void
func export_logs(path: String, format: String = "json") -> bool

# Memory Profiling
func start_memory_profiling(detailed: bool = false) -> void
func stop_memory_profiling() -> void
func detect_memory_leaks() -> Array[Dictionary]
func get_memory_by_category() -> Dictionary

# Export
func export_data(path: String, format: String = "json") -> bool
func export_csv(path: String) -> bool
func export_json(path: String) -> bool
func export_binary(path: String) -> bool

# Settings
func load_settings() -> void
func save_settings() -> void
func apply_settings(settings: ProfilerSettings) -> void
```

### MemoryProfiler

```gdscript
class_name MemoryProfiler
extends Node

# Memory Tracking
var memory_snapshots: Array[Dictionary] = []
var allocation_tracker: Dictionary = {}  # address -> allocation_info
var category_memory: Dictionary = {}  # category -> bytes

# Configuration
@export var detailed_tracking: bool = false
@export var track_call_stacks: bool = false
@export var leak_detection_enabled: bool = true
@export var leak_check_interval: float = 60.0

# References
var performance_profiler: PerformanceProfiler

# Functions
func take_snapshot() -> Dictionary
func compare_snapshots(snapshot1: Dictionary, snapshot2: Dictionary) -> Dictionary
func detect_leaks() -> Array[Dictionary]
func track_allocation(size: int, category: String, call_stack: Array = []) -> void
func track_deallocation(address: int) -> void
func get_memory_by_category() -> Dictionary
func get_total_memory() -> int
func get_peak_memory() -> int
```

### PerformanceLogger

```gdscript
class_name PerformanceLogger
extends Node

# Logging State
var is_logging: bool = false
var log_file: FileAccess = null
var log_format: ProfilerSettings.LogFormat = ProfilerSettings.LogFormat.JSON
var log_queue: Array[Dictionary] = []
var max_queue_size: int = 1000

# Configuration
@export var async_logging: bool = true
@export var auto_log_interval: float = 1.0
@export var max_file_size_mb: int = 100
@export var rotate_logs: bool = true

# Threading
var logging_thread: Thread = null
var logging_mutex: Mutex = Mutex.new()

# Functions
func start_logging(file_path: String, format: ProfilerSettings.LogFormat) -> void
func stop_logging() -> void
func log_data(data: Dictionary) -> void
func flush_logs() -> void
func rotate_log_file() -> void
func _logging_thread_function() -> void
```

---

## System Architecture

### Component Hierarchy

```
PerformanceProfiler (Autoload Singleton)
├── Metrics Collection
│   ├── PerformanceMetric[] (Dictionary)
│   └── Metric History (Dictionary)
├── Performance Budgets
│   ├── PerformanceBudget[] (Dictionary)
│   └── Budget Checker
├── Snapshots
│   ├── PerformanceSnapshot[] (Array)
│   └── Snapshot Comparator
├── Recommendations
│   ├── PerformanceRecommendation[] (Array)
│   └── Recommendation Generator
├── Memory Profiler
│   ├── MemoryProfiler
│   └── Leak Detector
├── Logger
│   ├── PerformanceLogger
│   └── Log Queue
└── UI
    ├── Overlay (Control)
    └── Metric Displays
```

### Data Flow

1. **Metric Collection:**
   ```
   _process(delta)
   ├── Sample metrics at interval
   ├── Update metric values
   ├── Store in history
   ├── Check budgets
   ├── Generate recommendations
   └── Update overlay (if visible)
   ```

2. **Snapshot Creation:**
   ```
   Create snapshot
   ├── Capture all metric values
   ├── Capture budget status
   ├── Capture context
   ├── Optional: Capture screenshot
   ├── Store snapshot
   └── snapshot_created.emit()
   ```

3. **Recommendation Generation:**
   ```
   Generate recommendations
   ├── Analyze current metrics
   ├── Compare against budgets
   ├── Check thresholds
   ├── Generate recommendations
   ├── Prioritize recommendations
   └── recommendation_generated.emit()
   ```

---

## Algorithms

### Sampling-Based Profiling Algorithm

```gdscript
func _process(delta: float) -> void:
    if not is_profiling:
        return
    
    # Update sampling timer
    sampling_timer += delta
    
    # Check if it's time to sample
    if sampling_timer >= current_settings.sampling_interval:
        sample_metrics()
        sampling_timer = 0.0
    
    # Update overlay if visible
    if is_overlay_visible:
        update_overlay()

func sample_metrics() -> void:
    # Sample frame rate metrics
    sample_frame_rate_metrics()
    
    # Sample memory metrics
    if current_settings.basic_memory_profiling:
        sample_memory_metrics()
    
    # Sample CPU metrics
    sample_cpu_metrics()
    
    # Sample GPU metrics
    sample_gpu_metrics()
    
    # Sample network metrics (if multiplayer)
    if MultiplayerManager and MultiplayerManager.is_hosting:
        sample_network_metrics()
    
    # Sample physics metrics
    sample_physics_metrics()
    
    # Sample rendering metrics
    sample_rendering_metrics()
    
    # Check budgets
    check_budgets()
    
    # Generate recommendations (periodically)
    if Time.get_unix_time_from_system() - last_recommendation_time > 5.0:
        generate_recommendations()
        last_recommendation_time = Time.get_unix_time_from_system()
    
    # Auto-logging (if enabled)
    if current_settings.logging_enabled and current_settings.auto_logging_interval > 0:
        var time_since_last_log = Time.get_unix_time_from_system() - last_log_time
        if time_since_last_log >= current_settings.auto_logging_interval:
            log_current_metrics()
            last_log_time = Time.get_unix_time_from_system()

func sample_frame_rate_metrics() -> void:
    var current_fps = Engine.get_frames_per_second()
    var frame_time = 1000.0 / current_fps if current_fps > 0 else 0.0
    
    update_metric("fps", current_fps)
    update_metric("frame_time", frame_time)
    
    # Store in history
    add_to_history("fps", current_fps)
    add_to_history("frame_time", frame_time)
```

### Budget Checking Algorithm

```gdscript
func check_budgets() -> void:
    if current_budget == null:
        return
    
    var frame_time = get_metric("frame_time").value
    var target_frame_time = current_budget.target_frame_time_ms
    
    # Check overall frame time
    var frame_time_percentage = frame_time / target_frame_time
    if frame_time_percentage >= current_budget.critical_threshold:
        budget_exceeded.emit("frame_time", frame_time, target_frame_time)
    elif frame_time_percentage >= current_budget.warning_threshold:
        # Warning level
        pass
    
    # Check per-system budgets
    check_system_budget("rendering", current_budget.rendering_budget)
    check_system_budget("physics", current_budget.physics_budget)
    check_system_budget("ai", current_budget.ai_budget)
    check_system_budget("game_logic", current_budget.game_logic_budget)
    check_system_budget("audio", current_budget.audio_budget)

func check_system_budget(system_name: String, budget_percentage: float) -> void:
    var frame_time = get_metric("frame_time").value
    var system_time = get_metric(system_name + "_time").value
    var budget_time = frame_time * budget_percentage
    
    var percentage = system_time / budget_time if budget_time > 0 else 0.0
    
    if percentage >= current_budget.critical_threshold:
        budget_exceeded.emit(system_name, system_time, budget_time)
```

### Recommendation Generation Algorithm

```gdscript
func generate_recommendations() -> void:
    recommendations.clear()
    
    # Check memory recommendations
    check_memory_recommendations()
    
    # Check performance recommendations
    check_performance_recommendations()
    
    # Check rendering recommendations
    check_rendering_recommendations()
    
    # Check physics recommendations
    check_physics_recommendations()
    
    # Sort by priority
    recommendations.sort_custom(func(a, b): return a.priority > b.priority)
    
    # Limit to max recommendations
    if recommendations.size() > max_recommendations:
        recommendations = recommendations.slice(0, max_recommendations)

func check_memory_recommendations() -> void:
    var total_memory = get_metric("memory_total").value
    var texture_memory = get_metric("memory_textures").value
    var memory_percentage = texture_memory / total_memory if total_memory > 0 else 0.0
    
    # High texture memory
    if memory_percentage > 0.6:  # More than 60% textures
        var recommendation = PerformanceRecommendation.new()
        recommendation.priority = 7
        recommendation.category = "memory"
        recommendation.title = "High Texture Memory Usage"
        recommendation.description = "Textures are using " + str(int(memory_percentage * 100)) + "% of total memory"
        recommendation.action = "Consider reducing texture sizes, using compression, or implementing texture streaming"
        recommendation.metric_id = "memory_textures"
        recommendations.append(recommendation)
    
    # Memory leak detection
    if memory_profiler and memory_profiler.leak_detection_enabled:
        var leaks = memory_profiler.detect_leaks()
        if leaks.size() > 0:
            var recommendation = PerformanceRecommendation.new()
            recommendation.priority = 10  # High priority
            recommendation.category = "memory"
            recommendation.title = "Memory Leaks Detected"
            recommendation.description = "Detected " + str(leaks.size()) + " potential memory leaks"
            recommendation.action = "Review memory allocations and ensure proper cleanup"
            recommendations.append(recommendation)

func check_performance_recommendations() -> void:
    var frame_time = get_metric("frame_time").value
    var target_frame_time = current_budget.target_frame_time_ms if current_budget else 16.66
    
    # Low FPS
    if frame_time > target_frame_time * 1.2:  # 20% over budget
        var recommendation = PerformanceRecommendation.new()
        recommendation.priority = 8
        recommendation.category = "performance"
        recommendation.title = "Frame Time Exceeding Budget"
        recommendation.description = "Frame time is " + str(int(frame_time)) + "ms (target: " + str(int(target_frame_time)) + "ms)"
        recommendation.action = "Profile individual systems to identify bottlenecks"
        recommendation.metric_id = "frame_time"
        recommendations.append(recommendation)
```

### Memory Leak Detection Algorithm

```gdscript
func detect_memory_leaks() -> Array[Dictionary]:
    if memory_snapshots.size() < 2:
        return []
    
    var leaks: Array[Dictionary] = []
    var snapshot1 = memory_snapshots[-2]  # Previous snapshot
    var snapshot2 = memory_snapshots[-1]  # Current snapshot
    
    # Compare snapshots
    var time_diff = snapshot2["timestamp"] - snapshot1["timestamp"]
    var memory_diff = snapshot2["total_memory"] - snapshot1["total_memory"]
    
    # Memory growth rate
    var growth_rate = memory_diff / time_diff if time_diff > 0 else 0.0
    
    # Check if memory is growing consistently
    if growth_rate > 1000000:  # More than 1MB per second
        var leak_info = {
            "severity": "high",
            "growth_rate": growth_rate,
            "time_diff": time_diff,
            "memory_diff": memory_diff
        }
        leaks.append(leak_info)
    
    # Check allocation tracker for unreleased allocations
    if detailed_tracking:
        for address in allocation_tracker:
            var allocation = allocation_tracker[address]
            var age = Time.get_unix_time_from_system() - allocation["timestamp"]
            
            # Allocation older than 60 seconds that hasn't been freed
            if age > 60.0:
                var leak_info = {
                    "severity": "medium",
                    "address": address,
                    "size": allocation["size"],
                    "category": allocation["category"],
                    "age": age,
                    "call_stack": allocation.get("call_stack", [])
                }
                leaks.append(leak_info)
    
    return leaks
```

### Async Logging Algorithm

```gdscript
func _logging_thread_function() -> void:
    while is_logging:
        # Process log queue
        logging_mutex.lock()
        var queue_size = log_queue.size()
        var logs_to_process = log_queue.duplicate()
        log_queue.clear()
        logging_mutex.unlock()
        
        # Write logs to file
        for log_data in logs_to_process:
            write_log_entry(log_data)
        
        # Sleep briefly to avoid excessive CPU usage
        OS.delay_msec(10)
    
    # Flush remaining logs
    flush_logs()

func log_data(data: Dictionary) -> void:
    if not is_logging:
        return
    
    # Add timestamp
    data["timestamp"] = Time.get_unix_time_from_system()
    
    if async_logging:
        # Add to queue for async processing
        logging_mutex.lock()
        if log_queue.size() < max_queue_size:
            log_queue.append(data)
        logging_mutex.unlock()
    else:
        # Write synchronously
        write_log_entry(data)

func write_log_entry(data: Dictionary) -> void:
    if log_file == null:
        return
    
    var log_line: String = ""
    
    match log_format:
        ProfilerSettings.LogFormat.CSV:
            log_line = format_csv_entry(data)
        ProfilerSettings.LogFormat.JSON:
            log_line = JSON.stringify(data) + "\n"
        ProfilerSettings.LogFormat.BINARY:
            # Binary format (custom implementation)
            write_binary_entry(data)
            return
    
    log_file.store_string(log_line)
    
    # Check file size and rotate if needed
    if log_file.get_position() > max_file_size_mb * 1024 * 1024:
        rotate_log_file()
```

---

## Integration Points

### With All Game Systems

```gdscript
# All systems can register metrics
func register_system_metrics(system_name: String) -> void:
    # Register system-specific metrics
    var frame_time_metric = PerformanceMetric.new()
    frame_time_metric.metric_id = system_name + "_time"
    frame_time_metric.metric_name = system_name + " Time"
    frame_time_metric.category = PerformanceMetric.MetricCategory.OTHER
    frame_time_metric.unit = "ms"
    performance_profiler.register_metric(frame_time_metric)
    
    # System updates metric during execution
    var start_time = Time.get_ticks_msec()
    # ... system execution ...
    var end_time = Time.get_ticks_msec()
    performance_profiler.update_metric(system_name + "_time", end_time - start_time)
```

### With Rendering System

```gdscript
# Track rendering metrics
func update_rendering_metrics() -> void:
    var draw_calls = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
    var triangles = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
    
    performance_profiler.update_metric("draw_calls", draw_calls)
    performance_profiler.update_metric("triangles", triangles)
```

### With Physics System

```gdscript
# Track physics metrics
func update_physics_metrics() -> void:
    var bodies = PhysicsServer2D.body_get_count()
    var collisions = PhysicsServer2D.space_get_direct_state(physics_space).get_collision_count()
    
    performance_profiler.update_metric("physics_bodies", bodies)
    performance_profiler.update_metric("physics_collisions", collisions)
```

---

## Save/Load System

### Save Data Structure

```gdscript
var profiling_save_data: Dictionary = {
    "settings": serialize_settings(),
    "snapshots": serialize_snapshots(),
    "budgets": serialize_budgets()
}

func serialize_settings() -> Dictionary:
    return {
        "overlay_enabled": current_settings.overlay_enabled,
        "detail_level": current_settings.detail_level,
        "sampling_interval": current_settings.sampling_interval,
        "logging_enabled": current_settings.logging_enabled,
        "recommendations_enabled": current_settings.recommendations_enabled
    }

func serialize_snapshots() -> Array:
    var snapshots_data: Array = []
    for snapshot in snapshots:
        snapshots_data.append({
            "snapshot_id": snapshot.snapshot_id,
            "timestamp": snapshot.timestamp,
            "metrics": snapshot.metrics,
            "context": snapshot.context
        })
    return snapshots_data
```

### Load Data Structure

```gdscript
func load_profiling_data(data: Dictionary) -> void:
    if data.has("settings"):
        load_settings(data["settings"])
    if data.has("snapshots"):
        load_snapshots(data["snapshots"])
    if data.has("budgets"):
        load_budgets(data["budgets"])
```

---

## Error Handling

### PerformanceProfiler Error Handling

- **Invalid Metric IDs:** Check metric exists before operations, return errors gracefully
- **File I/O Errors:** Handle file write failures, rotate logs if needed
- **Thread Errors:** Handle threading errors gracefully, fallback to sync logging
- **Memory Errors:** Handle memory allocation failures, limit history size

### Best Practices

- Use `push_error()` for critical errors (file I/O failures, thread errors)
- Use `push_warning()` for non-critical issues (metric not found, budget exceeded)
- Return false/null on errors (don't crash)
- Validate all inputs before operations
- Limit resource usage (history size, snapshot count)

---

## Default Values and Configuration

### PerformanceProfiler Defaults

```gdscript
max_history_size = 300
max_snapshots = 100
max_recommendations = 20
sampling_interval = 0.1
```

### ProfilerSettings Defaults

```gdscript
overlay_enabled = false
overlay_key = "F3"
detail_level = DetailLevel.NORMAL
sampling_interval = 0.1
enable_async_logging = true
auto_disable_when_hidden = true
logging_enabled = false
auto_logging_interval = 1.0
log_format = LogFormat.JSON
max_log_file_size_mb = 100
basic_memory_profiling = true
detailed_memory_profiling = false
leak_detection_interval = 60.0
recommendations_enabled = true
recommendation_priority_threshold = 5
```

### PerformanceBudget Defaults

```gdscript
target_frame_time_ms = 16.66
warning_threshold = 0.8
critical_threshold = 0.95
rendering_budget = 0.45
physics_budget = 0.25
ai_budget = 0.15
game_logic_budget = 0.10
audio_budget = 0.05
hardware_tier = HardwareTier.MID_RANGE
```

---

## Performance Considerations

### Optimization Strategies

1. **Sampling:**
   - Sample at configurable intervals (not every frame)
   - Reduce overhead significantly
   - Still captures performance trends

2. **Async Logging:**
   - Log to file in background thread
   - Prevents blocking main thread
   - Use mutex for thread safety

3. **Lazy Evaluation:**
   - Calculate expensive metrics only when needed
   - Cache results when possible
   - Skip calculations when overlay hidden

4. **History Limiting:**
   - Limit history size to prevent memory growth
   - Use circular buffer for history
   - Limit snapshot count

5. **Detail Levels:**
   - Minimal: Basic metrics only
   - Normal: Standard metrics
   - Detailed: All metrics (higher overhead)
   - Verbose: Maximum detail (debug only)

---

## Testing Checklist

### Performance Profiler
- [ ] Metrics collection works correctly
- [ ] Overlay displays correctly
- [ ] Toggle overlay works
- [ ] Visual warnings display correctly
- [ ] Budget checking works
- [ ] Recommendations generate correctly

### Logging
- [ ] Auto-logging works
- [ ] Manual logging works
- [ ] Event-based logging works
- [ ] Export works (CSV, JSON, binary)
- [ ] Log rotation works
- [ ] Async logging doesn't block

### Memory Profiling
- [ ] Basic memory profiling works
- [ ] Detailed memory profiling works
- [ ] Leak detection works
- [ ] Memory by category works

### Snapshots
- [ ] Manual snapshots work
- [ ] Automatic snapshots work
- [ ] Snapshot comparison works
- [ ] Snapshot export works

### Integration
- [ ] Integrates with all game systems correctly
- [ ] Performance impact is minimal
- [ ] Settings save/load correctly

---

## Complete Implementation

### PerformanceProfiler Initialization

```gdscript
func _ready() -> void:
    # Initialize components
    memory_profiler = MemoryProfiler.new()
    logger = PerformanceLogger.new()
    
    add_child(memory_profiler)
    add_child(logger)
    
    # Initialize
    initialize()

func initialize() -> void:
    # Load settings
    load_settings()
    
    # Register default metrics
    register_default_metrics()
    
    # Register default budgets
    register_default_budgets()
    
    # Setup input
    setup_input()
    
    # Start basic memory profiling
    if current_settings.basic_memory_profiling:
        memory_profiler.start_memory_profiling(false)

func register_default_metrics() -> void:
    # Frame rate metrics
    var fps_metric = PerformanceMetric.new()
    fps_metric.metric_id = "fps"
    fps_metric.metric_name = "FPS"
    fps_metric.category = PerformanceMetric.MetricCategory.FRAME_RATE
    fps_metric.unit = "fps"
    register_metric(fps_metric)
    
    var frame_time_metric = PerformanceMetric.new()
    frame_time_metric.metric_id = "frame_time"
    frame_time_metric.metric_name = "Frame Time"
    frame_time_metric.category = PerformanceMetric.MetricCategory.FRAME_RATE
    frame_time_metric.unit = "ms"
    register_metric(frame_time_metric)
    
    # Memory metrics
    var memory_total_metric = PerformanceMetric.new()
    memory_total_metric.metric_id = "memory_total"
    memory_total_metric.metric_name = "Total Memory"
    memory_total_metric.category = PerformanceMetric.MetricCategory.MEMORY
    memory_total_metric.unit = "MB"
    register_metric(memory_total_metric)
    
    # CPU metrics
    var cpu_usage_metric = PerformanceMetric.new()
    cpu_usage_metric.metric_id = "cpu_usage"
    cpu_usage_metric.metric_name = "CPU Usage"
    cpu_usage_metric.category = PerformanceMetric.MetricCategory.CPU
    cpu_usage_metric.unit = "%"
    register_metric(cpu_usage_metric)
    
    # GPU metrics
    var gpu_usage_metric = PerformanceMetric.new()
    gpu_usage_metric.metric_id = "gpu_usage"
    gpu_usage_metric.metric_name = "GPU Usage"
    gpu_usage_metric.category = PerformanceMetric.MetricCategory.GPU
    gpu_usage_metric.unit = "%"
    register_metric(gpu_usage_metric)
    
    # Rendering metrics
    var draw_calls_metric = PerformanceMetric.new()
    draw_calls_metric.metric_id = "draw_calls"
    draw_calls_metric.metric_name = "Draw Calls"
    draw_calls_metric.category = PerformanceMetric.MetricCategory.RENDERING
    draw_calls_metric.unit = "calls"
    register_metric(draw_calls_metric)

func setup_input() -> void:
    # Setup toggle key
    if not InputMap.has_action("toggle_profiler"):
        var event = InputEventKey.new()
        event.keycode = KEY_F3
        InputMap.add_action("toggle_profiler")
        InputMap.action_add_event("toggle_profiler", event)
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── PerformanceProfiler.gd
   └── resources/
       └── profiling/
           └── (profiler settings, budgets)
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/PerformanceProfiler.gd` as `PerformanceProfiler`
   - **Important:** Load early (can be first or second)

3. **Configure Settings:**
   - Create ProfilerSettings resource
   - Configure default settings
   - Save as `res://resources/profiling/default_settings.tres`

### Initialization Order

**Autoload Order:**
1. **PerformanceProfiler** (early, can profile other systems)
2. GameManager
3. All other systems

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Performance/Profiling System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Performance:** https://docs.godotengine.org/en/stable/tutorials/performance/index.html
- **RenderingServer:** https://docs.godotengine.org/en/stable/classes/class_renderingserver.html
- **Performance:** https://docs.godotengine.org/en/stable/classes/class_performance.html
- **Thread:** https://docs.godotengine.org/en/stable/classes/class_thread.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Performance/Profiling System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Performance Tutorial](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance optimization
- [RenderingServer Documentation](https://docs.godotengine.org/en/stable/classes/class_renderingserver.html) - Rendering information
- [Performance Class](https://docs.godotengine.org/en/stable/classes/class_performance.html) - Performance metrics
- [Thread Documentation](https://docs.godotengine.org/en/stable/classes/class_thread.html) - Threading for async logging

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- ProfilerSettings is a Resource (can be created/edited in inspector)
- PerformanceBudget is a Resource (can be created/edited in inspector)
- Settings editable in inspector

**Visual Configuration:**
- Overlay position/size configurable
- Metric visibility configurable
- Budget values editable

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Performance profiler window (like Unity Profiler)
  - Real-time metric visualization
  - Snapshot comparison tool
  - Budget editor

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Settings created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Comprehensive Metrics:** Track FPS, frame time, memory, CPU, GPU, network, draw calls, physics, rendering
2. **Toggleable Overlay:** Show/hide with key press (F3 default)
3. **Visual Warnings:** Color changes and icons when performance is poor
4. **Hybrid Logging:** Automatic (configurable intervals) + manual + event-based
5. **Detailed Budgets:** Per-system budgets with configurable tiers
6. **Access Control:** Developers always have access, optional for players
7. **Hybrid Memory Profiling:** Basic always on, detailed optional
8. **Multiple Export Formats:** CSV, JSON, binary, specialized formats
9. **Real-time + Historical:** Current metrics + graphs/history
10. **Advanced Customization:** Choose individual metrics, customize layout
11. **Hybrid Snapshots:** Manual + automatic snapshots
12. **Detailed Recommendations:** Contextual and actionable optimization suggestions
13. **Advanced Optimization:** Sampling, async logging, configurable detail levels, lazy evaluation, disable when hidden

