# Technical Specifications: Audio System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the comprehensive audio system supporting configurable audio buses, hybrid 2D/3D spatial audio, dynamic music with playlists and layers, automatic sound pooling, priority-based playback, settings persistence, and crossfade transitions. This system integrates with all game systems for sound playback and music management.

---

## Research Notes

### Audio System Architecture Best Practices

**Research Findings:**
- Audio buses organize sounds by category (Master, Music, SFX)
- Object pooling reduces audio player creation overhead
- Voice limits prevent audio overload
- Spatial audio (2D/3D) enhances immersion
- Dynamic music adapts to game state

**Sources:**
- [Godot 4 Audio System](https://docs.godotengine.org/en/stable/tutorials/audio/index.html) - Audio system documentation
- [Godot 4 AudioStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html) - 2D audio playback
- [Godot 4 AudioStreamPlayer2D](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer2d.html) - 3D spatial audio
- [Godot 4 Audio Buses](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html) - Audio bus system
- General audio system design patterns

**Implementation Approach:**
- AudioManager as autoload singleton
- Audio buses: Master, Music, SFX (configurable)
- Hybrid spatial audio: 2D for UI, 3D for gameplay
- Object pooling for sound players
- Priority-based voice culling
- Settings persistence via file + project settings

**Why This Approach:**
- Singleton: centralized audio management
- Audio buses: organized sound categories
- Hybrid spatial: appropriate audio for context
- Object pooling: performance optimization
- Priority culling: prevents audio overload
- Settings persistence: user preferences saved

### Audio Bus System Best Practices

**Research Findings:**
- Audio buses organize sounds by category
- Bus volumes controlled independently
- Bus mute/solo for testing
- Bus voice limits prevent overload
- Effects can be applied per bus

**Sources:**
- [Godot 4 Audio Buses Documentation](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html)

**Implementation Approach:**
- Core buses: Master, Music, SFX
- Configurable bus creation
- Bus volume/mute management
- Bus voice limits
- Bus effects support

**Why This Approach:**
- Core buses: standard organization
- Configurable: flexible bus setup
- Volume/mute: user control
- Voice limits: performance optimization
- Effects: audio processing per bus

### Sound Pooling Best Practices

**Research Findings:**
- Object pooling reduces audio player creation overhead
- Pool size based on sound frequency
- Pooled players reused for same sound
- Automatic pool management

**Sources:**
- General object pooling patterns

**Implementation Approach:**
- Sound pools per sound ID
- Configurable pool sizes
- Automatic pool creation
- Player reuse from pool

**Why This Approach:**
- Per sound: efficient reuse
- Configurable: optimize per sound
- Automatic: no manual management
- Reuse: reduces overhead

### Dynamic Music Best Practices

**Research Findings:**
- Music layers enable adaptive music
- Crossfade transitions smooth music changes
- Playlists organize music tracks
- Music state changes based on game events

**Sources:**
- General dynamic music patterns

**Implementation Approach:**
- Music layers for adaptive music
- Crossfade between tracks
- Playlist system for track organization
- State-based layer management

**Why This Approach:**
- Layers: adaptive music system
- Crossfade: smooth transitions
- Playlists: organized music
- State-based: responds to game events

---

## Data Structures

### AudioBusConfig

```gdscript
class_name AudioBusConfig
extends Resource

@export var bus_name: String
@export var bus_index: int = -1  # Auto-assigned
@export var volume_db: float = 0.0
@export var mute: bool = false
@export var solo: bool = false
@export var max_voices: int = -1  # -1 = unlimited
@export var effects: Array[AudioEffect] = []
```

### SoundData

```gdscript
class_name SoundData
extends Resource

# Identification
@export var sound_id: String  # Unique identifier
@export var sound_name: String  # Display name

# Audio Asset
@export var audio_stream: AudioStream
@export var audio_path: String = ""  # Path to audio file

# Playback Settings
@export var bus_name: String = "SFX"  # Audio bus to use
@export var volume_db: float = 0.0  # Volume offset
@export var pitch_scale: float = 1.0
@export var priority: int = 50  # 0-100, higher = more important

# Spatial Audio
@export var is_spatial: bool = false  # 2D or 3D
@export var spatial_type: SpatialType = SpatialType.AUTO  # AUTO determines from bus

enum SpatialType {
    AUTO,     # Determined by bus (UI = 2D, Gameplay = 3D)
    FLAT_2D,  # Always 2D
    SPATIAL_3D # Always 3D
}

# 3D Settings (if spatial)
@export var max_distance: float = 500.0
@export var attenuation: float = 1.0
@export var doppler_tracking: int = 0  # 0 = disabled, 1 = enabled

# Loading
@export var preload: bool = false  # Preload at startup
@export var stream: bool = false  # Stream large files

# Pooling
@export var use_pooling: bool = true  # Use object pooling
@export var pool_size: int = 5  # Pool size for this sound

# Metadata
@export var category: String = ""  # "ui", "combat", "ambient", etc.
@export var tags: Array[String] = []
```

### MusicTrack

```gdscript
class_name MusicTrack
extends Resource

# Identification
@export var track_id: String
@export var track_name: String

# Audio Asset
@export var audio_stream: AudioStream
@export var audio_path: String = ""

# Playback Settings
@export var volume_db: float = 0.0
@export var fade_in_time: float = 1.0
@export var fade_out_time: float = 1.0
@export var loop: bool = true

# Dynamic Layers (for adaptive music)
@export var layers: Array[MusicLayer] = []
@export var has_layers: bool = false
```

### MusicLayer

```gdscript
class_name MusicLayer
extends Resource

@export var layer_name: String  # "calm", "combat", "intense"
@export var audio_stream: AudioStream
@export var audio_path: String = ""
@export var volume_db: float = 0.0
@export var fade_in_time: float = 1.0
@export var fade_out_time: float = 1.0
@export var loop: bool = true
```

### MusicPlaylist

```gdscript
class_name MusicPlaylist
extends Resource

@export var playlist_id: String
@export var playlist_name: String
@export var tracks: Array[MusicTrack] = []
@export var shuffle: bool = true
@export var crossfade_time: float = 2.0  # Crossfade duration between tracks
```

### AudioSettings

```gdscript
class_name AudioSettings
extends Resource

# Master Volume
@export var master_volume: float = 1.0  # 0.0 to 1.0

# Bus Volumes
@export var bus_volumes: Dictionary = {}  # bus_name -> volume (0.0-1.0)

# Mute States
@export var bus_mutes: Dictionary = {}  # bus_name -> bool

# Other Settings
@export var mute_on_focus_lost: bool = false
@export var reduce_volume_on_focus_lost: bool = true
@export var focus_lost_volume: float = 0.3
```

---

## Core Classes

### AudioManager (Autoload Singleton)

```gdscript
class_name AudioManager
extends Node

# References
@export var audio_settings: AudioSettings

# Audio Buses
var bus_configs: Dictionary = {}  # bus_name -> AudioBusConfig
var core_buses: Array[String] = ["Master", "Music", "SFX"]

# Sound Registry
var sound_registry: Dictionary = {}  # sound_id -> SoundData
var preloaded_sounds: Dictionary = {}  # sound_id -> AudioStream

# Music System
var current_music: MusicTrack = null
var current_playlist: MusicPlaylist = null
var music_player_1: AudioStreamPlayer = null
var music_player_2: AudioStreamPlayer = null
var active_music_player: AudioStreamPlayer = null
var music_layers: Dictionary = {}  # layer_name -> AudioStreamPlayer
var music_crossfade_tween: Tween = null

# Sound Pooling
var sound_pools: Dictionary = {}  # sound_id -> Array[AudioStreamPlayer]
var active_sounds: Dictionary = {}  # sound_id -> Array[AudioStreamPlayer]

# Voice Limits
var bus_voice_counts: Dictionary = {}  # bus_name -> int
var bus_voice_queues: Dictionary = {}  # bus_name -> Array[SoundRequest]

# 3D Audio
var listener: Node2D = null  # Camera or player for 3D audio

# Settings File
const SETTINGS_FILE: String = "user://audio_settings.json"

# Signals
signal sound_played(sound_id: String, position: Vector2)
signal music_changed(track_id: String, playlist_id: String)
signal music_layer_changed(layer_name: String, volume: float)
signal audio_bus_volume_changed(bus_name: String, volume: float)
signal audio_bus_muted(bus_name: String, muted: bool)

# Functions
func _ready() -> void
func _process(delta: float) -> void

# Bus Management
func create_audio_bus(bus_name: String, parent_bus: String = "Master") -> int
func get_bus_index(bus_name: String) -> int
func set_bus_volume(bus_name: String, volume: float) -> void
func set_bus_mute(bus_name: String, mute: bool) -> void
func get_bus_volume(bus_name: String) -> float
func is_bus_muted(bus_name: String) -> bool

# Sound Registration
func register_sound(sound_data: SoundData) -> void
func preload_sound(sound_id: String) -> void
func get_sound(sound_id: String) -> SoundData

# Sound Playback (Direct Calls)
func play_sound(sound_id: String, position: Vector2 = Vector2.ZERO, volume_modifier: float = 1.0) -> AudioStreamPlayer
func play_sound_2d(sound_id: String, volume_modifier: float = 1.0) -> AudioStreamPlayer
func play_sound_3d(sound_id: String, position: Vector2, volume_modifier: float = 1.0) -> AudioStreamPlayer2D
func stop_sound(sound_id: String) -> void
func stop_all_sounds(bus_name: String = "") -> void

# Music System
func play_music(track_id: String, fade_in: float = 1.0) -> void
func play_playlist(playlist_id: String, fade_in: float = 1.0) -> void
func stop_music(fade_out: float = 1.0) -> void
func crossfade_music(new_track_id: String, crossfade_time: float = 2.0) -> void
func set_music_layer(layer_name: String, volume: float, fade_time: float = 1.0) -> void
func get_current_music() -> MusicTrack

# Dynamic Music
func set_music_state(state: String) -> void  # "calm", "combat", "intense"
func update_music_layers(game_state: Dictionary) -> void

# Sound Pooling
func get_pooled_player(sound_id: String) -> AudioStreamPlayer
func return_to_pool(sound_id: String, player: AudioStreamPlayer) -> void
func create_sound_pool(sound_id: String, size: int) -> void

# Voice Management
func can_play_sound(sound_id: String) -> bool
func check_voice_limits(bus_name: String) -> bool
func cull_distant_sounds() -> void

# Settings
func load_settings() -> void
func save_settings() -> void
func apply_settings(settings: AudioSettings) -> void
func reset_to_defaults() -> void

# 3D Audio
func set_listener(node: Node2D) -> void
func update_3d_audio_positions() -> void
```

### SoundRequest

```gdscript
class_name SoundRequest
extends RefCounted

var sound_id: String
var position: Vector2
var volume_modifier: float = 1.0
var priority: int = 50
var timestamp: float = 0.0
```

---

## System Architecture

### Component Hierarchy

```
AudioManager (Autoload Singleton)
├── AudioBusManager (bus configuration)
├── SoundPoolManager (object pooling)
├── MusicManager (music playback)
│   ├── MusicPlayer1 (AudioStreamPlayer)
│   ├── MusicPlayer2 (AudioStreamPlayer)
│   └── MusicLayerPlayers (Dictionary)
├── VoiceLimitManager (voice culling)
└── SettingsManager (settings persistence)
```

### Data Flow

1. **Sound Playback:**
   - System calls `AudioManager.play_sound(sound_id)` → Direct call
   - Check voice limits → `can_play_sound()` check
   - Get pooled player → `get_pooled_player()` or create new
   - Configure player → Set bus, volume, position
   - Play sound → `player.play()`
   - Track active sound → Add to active_sounds

2. **Music Playback:**
   - System calls `AudioManager.play_playlist(playlist_id)` → Direct call
   - Load playlist → Get MusicPlaylist resource
   - Start first track → Play on music_player_1
   - When track ends → Crossfade to next track
   - Update layers → Based on game state

3. **Dynamic Music:**
   - Game state changes → `set_music_state(state)` called
   - Update layers → Fade layers in/out based on state
   - Example: Combat starts → Fade in "combat" layer, fade out "calm" layer

4. **Voice Culling:**
   - Each frame → `cull_distant_sounds()` called
   - Check 3D sounds → Calculate distance to listener
   - Stop distant sounds → Beyond max_distance
   - Check bus limits → Stop lowest priority if over limit

---

## Algorithms

### Play Sound Algorithm

```gdscript
func play_sound(sound_id: String, position: Vector2 = Vector2.ZERO, volume_modifier: float = 1.0) -> AudioStreamPlayer:
    # Get sound data
    if not sound_registry.has(sound_id):
        push_error("AudioManager: Sound not found: " + sound_id)
        return null
    
    var sound_data = sound_registry[sound_id]
    
    # Check voice limits
    if not can_play_sound(sound_id):
        # Queue sound or reject
        queue_sound(sound_id, position, volume_modifier)
        return null
    
    # Determine spatial type
    var is_spatial = sound_data.is_spatial
    if sound_data.spatial_type == SoundData.SpatialType.AUTO:
        # UI sounds = 2D, Gameplay sounds = 3D
        is_spatial = sound_data.bus_name != "UI"
    
    # Get or create player
    var player: AudioStreamPlayer = null
    
    if is_spatial and position != Vector2.ZERO:
        # 3D sound
        player = get_pooled_player(sound_id) as AudioStreamPlayer2D
        if player == null:
            player = AudioStreamPlayer2D.new()
            add_child(player)
        
        player.global_position = position
        player.max_distance = sound_data.max_distance
        player.attenuation = sound_data.attenuation
    else:
        # 2D sound
        player = get_pooled_player(sound_id) as AudioStreamPlayer
        if player == null:
            player = AudioStreamPlayer.new()
            add_child(player)
    
    # Configure player
    var bus_index = get_bus_index(sound_data.bus_name)
    player.bus = AudioServer.get_bus_name(bus_index)
    player.volume_db = sound_data.volume_db + linear_to_db(volume_modifier)
    player.pitch_scale = sound_data.pitch_scale
    
    # Load audio stream
    if sound_data.preload and preloaded_sounds.has(sound_id):
        player.stream = preloaded_sounds[sound_id]
    else:
        if sound_data.audio_stream:
            player.stream = sound_data.audio_stream
        elif not sound_data.audio_path.is_empty():
            player.stream = load(sound_data.audio_path)
    
    # Play sound
    player.play()
    
    # Track active sound
    if not active_sounds.has(sound_id):
        active_sounds[sound_id] = []
    active_sounds[sound_id].append(player)
    
    # Update voice count
    bus_voice_counts[sound_data.bus_name] = bus_voice_counts.get(sound_data.bus_name, 0) + 1
    
    # Connect finished signal
    if not player.finished.is_connected(_on_sound_finished):
        player.finished.connect(_on_sound_finished.bind(sound_id, player))
    
    emit_signal("sound_played", sound_id, position)
    return player
```

### Crossfade Music Algorithm

```gdscript
func crossfade_music(new_track_id: String, crossfade_time: float = 2.0) -> void:
    # Get new track
    var new_track = get_music_track(new_track_id)
    if new_track == null:
        return
    
    # Determine which player to use
    var fade_out_player = active_music_player
    var fade_in_player = (music_player_1 == active_music_player) ? music_player_2 : music_player_1
    
    # Stop any existing crossfade
    if music_crossfade_tween:
        music_crossfade_tween.kill()
    
    # Setup fade out player
    if fade_out_player and fade_out_player.playing:
        music_crossfade_tween = create_tween()
        music_crossfade_tween.tween_property(fade_out_player, "volume_db", -80.0, crossfade_time)
        music_crossfade_tween.tween_callback(fade_out_player.stop)
    
    # Setup fade in player
    fade_in_player.stream = new_track.audio_stream
    fade_in_player.volume_db = -80.0
    fade_in_player.play()
    
    if not music_crossfade_tween:
        music_crossfade_tween = create_tween()
    
    music_crossfade_tween.parallel().tween_property(
        fade_in_player,
        "volume_db",
        new_track.volume_db,
        crossfade_time
    )
    
    # Update active player
    active_music_player = fade_in_player
    current_music = new_track
    
    emit_signal("music_changed", new_track_id, "")
```

### Voice Limit Check Algorithm

```gdscript
func can_play_sound(sound_id: String) -> bool:
    var sound_data = sound_registry[sound_id]
    var bus_name = sound_data.bus_name
    
    # Get bus config
    if not bus_configs.has(bus_name):
        return true  # No limit
    
    var bus_config = bus_configs[bus_name]
    
    # Check bus voice limit
    if bus_config.max_voices > 0:
        var current_count = bus_voice_counts.get(bus_name, 0)
        if current_count >= bus_config.max_voices:
            # Check if we can replace a lower priority sound
            return can_replace_sound(bus_name, sound_data.priority)
    
    return true

func can_replace_sound(bus_name: String, new_priority: int) -> bool:
    # Find lowest priority sound on this bus
    var lowest_priority = 100
    var lowest_sound_id = ""
    var lowest_player = null
    
    for sound_id in active_sounds:
        var sound_data = sound_registry[sound_id]
        if sound_data.bus_name != bus_name:
            continue
        
        var players = active_sounds[sound_id]
        for player in players:
            if sound_data.priority < lowest_priority:
                lowest_priority = sound_data.priority
                lowest_sound_id = sound_id
                lowest_player = player
    
    # Replace if new priority is higher
    if new_priority > lowest_priority and lowest_player:
        stop_sound_instance(lowest_sound_id, lowest_player)
        return true
    
    return false
```

### Distance-Based Culling Algorithm

```gdscript
func cull_distant_sounds() -> void:
    if listener == null:
        return
    
    var listener_pos = listener.global_position
    var sounds_to_stop: Array = []
    
    for sound_id in active_sounds:
        var sound_data = sound_registry[sound_id]
        
        # Only cull 3D sounds
        if not sound_data.is_spatial:
            continue
        
        var players = active_sounds[sound_id]
        for player in players:
            if not player is AudioStreamPlayer2D:
                continue
            
            var player_2d = player as AudioStreamPlayer2D
            var distance = listener_pos.distance_to(player_2d.global_position)
            
            # Stop if beyond max distance
            if distance > sound_data.max_distance:
                sounds_to_stop.append([sound_id, player])
    
    # Stop distant sounds
    for item in sounds_to_stop:
        stop_sound_instance(item[0], item[1])
```

---

## Integration Points

### Combat System

**Usage:**
- Weapon sounds, impact sounds, enemy sounds
- Combat music layers

**Example:**
```gdscript
# In CombatManager
func perform_attack() -> void:
    # Play weapon sound
    AudioManager.play_sound_3d("sword_swing", player.global_position)
    
    # Play impact sound
    AudioManager.play_sound_3d("impact", hit_position)
    
    # Trigger combat music
    AudioManager.set_music_state("combat")
```

### UI System

**Usage:**
- UI click sounds, notification sounds
- Menu music

**Example:**
```gdscript
# In UIManager
func on_button_clicked() -> void:
    AudioManager.play_sound_2d("ui_click")

func open_main_menu() -> void:
    AudioManager.play_music("main_menu_theme")
```

### Interaction System

**Usage:**
- Interaction sounds, item pickup sounds

**Example:**
```gdscript
# In InteractionManager
func on_interaction_completed() -> void:
    AudioManager.play_sound_2d("interaction_success")
```

### Survival System

**Usage:**
- Environmental sounds, status effect sounds

**Example:**
```gdscript
# In SurvivalManager
func apply_environmental_effect() -> void:
    AudioManager.play_sound_3d("radiation_zone", player.global_position)
```

---

## Save/Load System

### Audio Settings Save

**Save Format:**
```gdscript
{
    "master_volume": 1.0,
    "bus_volumes": {
        "Music": 0.8,
        "SFX": 1.0,
        "UI": 0.9,
        "Voice": 1.0
    },
    "bus_mutes": {
        "Music": false,
        "SFX": false
    },
    "mute_on_focus_lost": false,
    "reduce_volume_on_focus_lost": true,
    "focus_lost_volume": 0.3
}
```

**Load Format:**
```gdscript
func load_settings() -> void:
    if not FileAccess.file_exists(SETTINGS_FILE):
        audio_settings = AudioSettings.new()
        return
    
    var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
    if file == null:
        return
    
    var json = JSON.new()
    json.parse(file.get_as_text())
    file.close()
    
    var data = json.data
    audio_settings.master_volume = data.get("master_volume", 1.0)
    audio_settings.bus_volumes = data.get("bus_volumes", {})
    audio_settings.bus_mutes = data.get("bus_mutes", {})
    
    apply_settings(audio_settings)
```

---

## Performance Considerations

### Optimization Strategies

1. **Sound Pooling:**
   - Pre-create pools for common sounds
   - Reuse AudioStreamPlayer nodes
   - Limit pool sizes per sound

2. **Voice Limits:**
   - Enforce per-bus limits
   - Cull lowest priority sounds when at limit
   - Distance-based culling for 3D sounds

3. **Asset Loading:**
   - Preload common sounds at startup
   - Lazy load less common sounds
   - Stream large music files

4. **Update Frequency:**
   - Update voice counts every frame
   - Cull distant sounds every 0.1 seconds
   - Update 3D positions every frame

5. **Memory Management:**
   - Unload unused sounds periodically
   - Limit preloaded sound count
   - Use streaming for large files

---

## Testing Checklist

### Audio Playback
- [ ] Sounds play correctly
- [ ] 2D sounds work correctly
- [ ] 3D sounds work correctly
- [ ] Volume levels work correctly
- [ ] Pitch scaling works correctly

### Music System
- [ ] Music plays correctly
- [ ] Playlists work correctly
- [ ] Crossfade works correctly
- [ ] Music layers work correctly
- [ ] Dynamic music state changes work

### Audio Buses
- [ ] Bus volumes work correctly
- [ ] Bus muting works correctly
- [ ] Bus effects work correctly
- [ ] Custom buses can be created

### Voice Limits
- [ ] Per-bus limits enforced correctly
- [ ] Priority-based replacement works
- [ ] Distance culling works correctly
- [ ] No performance issues with many sounds

### Settings
- [ ] Settings save correctly
- [ ] Settings load correctly
- [ ] Volume changes apply immediately
- [ ] Mute toggles work correctly

### Integration
- [ ] Works with combat system
- [ ] Works with UI system
- [ ] Works with interaction system
- [ ] Works with survival system

---

## Error Handling

### AudioManager Error Handling

- **Missing Sound Data:** Handle missing sound IDs gracefully, return null
- **Invalid Bus Names:** Validate bus names before operations, return errors gracefully
- **Missing Audio Files:** Handle missing audio file paths gracefully, use fallback
- **Audio Player Creation Errors:** Handle player creation failures gracefully

### Best Practices

- Use `push_error()` for critical errors (missing sound data, invalid bus names)
- Use `push_warning()` for non-critical issues (missing audio files, voice limit reached)
- Return null on errors (don't crash)
- Validate all data before operations
- Handle missing audio files gracefully (use placeholder or skip)

---

## Default Values and Configuration

### AudioManager Defaults

```gdscript
core_buses = ["Master", "Music", "SFX"]
update_interval = 0.1  # Update every 0.1 seconds
max_voice_distance = 500.0  # Max distance for 3D sounds
```

### AudioSettings Defaults

```gdscript
master_volume = 1.0
bus_volumes = {
    "Master": 1.0,
    "Music": 0.8,
    "SFX": 1.0
}
bus_mutes = {
    "Master": false,
    "Music": false,
    "SFX": false
}
mute_on_focus_lost = false
reduce_volume_on_focus_lost = true
focus_lost_volume = 0.3
```

### SoundData Defaults

```gdscript
sound_id = ""
sound_name = ""
audio_stream = null
audio_path = ""
bus_name = "SFX"
volume_db = 0.0
pitch_scale = 1.0
priority = 50
is_spatial = false
spatial_type = SpatialType.AUTO
max_distance = 500.0
attenuation = 1.0
doppler_tracking = 0
preload = false
stream = false
use_pooling = true
pool_size = 5
category = ""
tags = []
```

### MusicTrack Defaults

```gdscript
track_id = ""
track_name = ""
audio_stream = null
audio_path = ""
volume_db = 0.0
fade_in_time = 1.0
fade_out_time = 1.0
loop = true
layers = []
has_layers = false
```

---

## Complete Implementation

### AudioManager Complete Implementation

```gdscript
class_name AudioManager
extends Node

# References
var audio_settings: AudioSettings = AudioSettings.new()

# Audio Buses
var bus_configs: Dictionary = {}
var core_buses: Array[String] = ["Master", "Music", "SFX"]

# Sound Registry
var sound_registry: Dictionary = {}
var preloaded_sounds: Dictionary = {}

# Music System
var current_music: MusicTrack = null
var current_playlist: MusicPlaylist = null
var music_player_1: AudioStreamPlayer = null
var music_player_2: AudioStreamPlayer = null
var active_music_player: AudioStreamPlayer = null
var music_layers: Dictionary = {}
var music_crossfade_tween: Tween = null

# Sound Pooling
var sound_pools: Dictionary = {}
var active_sounds: Dictionary = {}

# Voice Limits
var bus_voice_counts: Dictionary = {}
var bus_voice_queues: Dictionary = {}

# 3D Audio
var listener: Node2D = null

# Settings File
const SETTINGS_FILE: String = "user://audio_settings.json"

# Signals
signal sound_played(sound_id: String, position: Vector2)
signal music_changed(track_id: String, playlist_id: String)
signal music_layer_changed(layer_name: String, volume: float)
signal audio_bus_volume_changed(bus_name: String, volume: float)
signal audio_bus_muted(bus_name: String, muted: bool)

func _ready() -> void:
    # Setup audio buses
    setup_audio_buses()
    
    # Create music players
    create_music_players()
    
    # Load sounds
    load_sounds()
    
    # Load settings
    load_settings()
    
    # Set listener (player camera)
    var player = get_tree().get_first_node_in_group("player")
    if player:
        var camera = player.get_node_or_null("Camera2D")
        if camera:
            set_listener(camera)

func _process(delta: float) -> void:
    # Cull distant sounds
    cull_distant_sounds()
    
    # Process voice queues
    process_voice_queues()

func setup_audio_buses() -> void:
    # Ensure core buses exist
    for bus_name in core_buses:
        if AudioServer.get_bus_index(bus_name) == -1:
            create_audio_bus(bus_name)

func create_audio_bus(bus_name: String, parent_bus: String = "Master") -> int:
    var parent_index = AudioServer.get_bus_index(parent_bus)
    if parent_index == -1:
        parent_index = 0  # Use Master as default
    
    var bus_index = AudioServer.bus_count
    AudioServer.add_bus(bus_index)
    AudioServer.set_bus_name(bus_index, bus_name)
    
    if parent_index != 0:
        AudioServer.move_bus(bus_index, parent_index)
    
    return bus_index

func get_bus_index(bus_name: String) -> int:
    return AudioServer.get_bus_index(bus_name)

func set_bus_volume(bus_name: String, volume: float) -> void:
    var bus_index = get_bus_index(bus_name)
    if bus_index == -1:
        push_warning("AudioManager: Bus not found: " + bus_name)
        return
    
    var volume_db = linear_to_db(volume)
    AudioServer.set_bus_volume_db(bus_index, volume_db)
    audio_bus_volume_changed.emit(bus_name, volume)

func set_bus_mute(bus_name: String, mute: bool) -> void:
    var bus_index = get_bus_index(bus_name)
    if bus_index == -1:
        push_warning("AudioManager: Bus not found: " + bus_name)
        return
    
    AudioServer.set_bus_mute(bus_index, mute)
    audio_bus_muted.emit(bus_name, mute)

func get_bus_volume(bus_name: String) -> float:
    var bus_index = get_bus_index(bus_name)
    if bus_index == -1:
        return 0.0
    
    return db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func is_bus_muted(bus_name: String) -> bool:
    var bus_index = get_bus_index(bus_name)
    if bus_index == -1:
        return false
    
    return AudioServer.is_bus_mute(bus_index)

func load_sounds() -> void:
    var sound_dir = DirAccess.open("res://resources/sounds/")
    if sound_dir:
        sound_dir.list_dir_begin()
        var file_name = sound_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var sound_data = load("res://resources/sounds/" + file_name) as SoundData
                if sound_data:
                    register_sound(sound_data)
            file_name = sound_dir.get_next()

func register_sound(sound_data: SoundData) -> void:
    if sound_data:
        sound_registry[sound_data.sound_id] = sound_data
        
        # Preload if configured
        if sound_data.preload:
            preload_sound(sound_data.sound_id)
        
        # Create pool if configured
        if sound_data.use_pooling:
            create_sound_pool(sound_data.sound_id, sound_data.pool_size)

func preload_sound(sound_id: String) -> void:
    var sound_data = sound_registry.get(sound_id)
    if not sound_data:
        return
    
    var stream: AudioStream = null
    if sound_data.audio_stream:
        stream = sound_data.audio_stream
    elif not sound_data.audio_path.is_empty():
        stream = load(sound_data.audio_path)
    
    if stream:
        preloaded_sounds[sound_id] = stream

func get_sound(sound_id: String) -> SoundData:
    return sound_registry.get(sound_id)

func play_sound(sound_id: String, position: Vector2 = Vector2.ZERO, volume_modifier: float = 1.0) -> AudioStreamPlayer:
    if not sound_registry.has(sound_id):
        push_error("AudioManager: Sound not found: " + sound_id)
        return null
    
    var sound_data = sound_registry[sound_id]
    
    if not can_play_sound(sound_id):
        return null
    
    var is_spatial = sound_data.is_spatial
    if sound_data.spatial_type == SoundData.SpatialType.AUTO:
        is_spatial = sound_data.bus_name != "UI"
    
    var player: AudioStreamPlayer = null
    
    if is_spatial and position != Vector2.ZERO:
        player = get_pooled_player(sound_id) as AudioStreamPlayer2D
        if player == null:
            player = AudioStreamPlayer2D.new()
            add_child(player)
        
        player.global_position = position
        player.max_distance = sound_data.max_distance
        player.attenuation = sound_data.attenuation
    else:
        player = get_pooled_player(sound_id) as AudioStreamPlayer
        if player == null:
            player = AudioStreamPlayer.new()
            add_child(player)
    
    var bus_index = get_bus_index(sound_data.bus_name)
    if bus_index != -1:
        player.bus = AudioServer.get_bus_name(bus_index)
    
    player.volume_db = sound_data.volume_db + linear_to_db(volume_modifier)
    player.pitch_scale = sound_data.pitch_scale
    
    if sound_data.preload and preloaded_sounds.has(sound_id):
        player.stream = preloaded_sounds[sound_id]
    else:
        if sound_data.audio_stream:
            player.stream = sound_data.audio_stream
        elif not sound_data.audio_path.is_empty():
            var stream = load(sound_data.audio_path)
            if stream:
                player.stream = stream
            else:
                push_warning("AudioManager: Failed to load audio: " + sound_data.audio_path)
                return null
    
    player.play()
    
    if not active_sounds.has(sound_id):
        active_sounds[sound_id] = []
    active_sounds[sound_id].append(player)
    
    bus_voice_counts[sound_data.bus_name] = bus_voice_counts.get(sound_data.bus_name, 0) + 1
    
    if not player.finished.is_connected(_on_sound_finished):
        player.finished.connect(_on_sound_finished.bind(sound_id, player))
    
    sound_played.emit(sound_id, position)
    return player

func play_sound_2d(sound_id: String, volume_modifier: float = 1.0) -> AudioStreamPlayer:
    return play_sound(sound_id, Vector2.ZERO, volume_modifier)

func play_sound_3d(sound_id: String, position: Vector2, volume_modifier: float = 1.0) -> AudioStreamPlayer2D:
    return play_sound(sound_id, position, volume_modifier) as AudioStreamPlayer2D

func play_sound_stream(stream: AudioStream) -> AudioStreamPlayer:
    var player = AudioStreamPlayer.new()
    add_child(player)
    player.stream = stream
    player.play()
    return player

func stop_sound(sound_id: String) -> void:
    if not active_sounds.has(sound_id):
        return
    
    for player in active_sounds[sound_id]:
        player.stop()
        return_to_pool(sound_id, player)
    
    active_sounds[sound_id].clear()

func stop_all_sounds(bus_name: String = "") -> void:
    if bus_name.is_empty():
        for sound_id in active_sounds:
            stop_sound(sound_id)
    else:
        for sound_id in sound_registry:
            var sound_data = sound_registry[sound_id]
            if sound_data.bus_name == bus_name:
                stop_sound(sound_id)

func play_music(track_id: String, fade_in: float = 1.0) -> void:
    var track = get_music_track(track_id)
    if not track:
        push_error("AudioManager: Music track not found: " + track_id)
        return
    
    if active_music_player:
        active_music_player.stop()
    
    active_music_player = music_player_1
    active_music_player.stream = track.audio_stream if track.audio_stream else load(track.audio_path)
    active_music_player.volume_db = -80.0
    active_music_player.play()
    
    var tween = create_tween()
    tween.tween_property(active_music_player, "volume_db", track.volume_db, fade_in)
    
    current_music = track
    music_changed.emit(track_id, "")

func play_playlist(playlist_id: String, fade_in: float = 1.0) -> void:
    var playlist = get_music_playlist(playlist_id)
    if not playlist:
        push_error("AudioManager: Playlist not found: " + playlist_id)
        return
    
    current_playlist = playlist
    
    if playlist.tracks.is_empty():
        return
    
    # Play first track
    play_music(playlist.tracks[0].track_id, fade_in)
    
    # Setup next track callback
    if not active_music_player.finished.is_connected(_on_playlist_track_finished):
        active_music_player.finished.connect(_on_playlist_track_finished)

func crossfade_music(new_track_id: String, crossfade_time: float = 2.0) -> void:
    var new_track = get_music_track(new_track_id)
    if not new_track:
        return
    
    var fade_out_player = active_music_player
    var fade_in_player = (music_player_1 == active_music_player) ? music_player_2 : music_player_1
    
    if music_crossfade_tween:
        music_crossfade_tween.kill()
    
    if fade_out_player and fade_out_player.playing:
        music_crossfade_tween = create_tween()
        music_crossfade_tween.tween_property(fade_out_player, "volume_db", -80.0, crossfade_time)
        music_crossfade_tween.tween_callback(fade_out_player.stop)
    
    fade_in_player.stream = new_track.audio_stream if new_track.audio_stream else load(new_track.audio_path)
    fade_in_player.volume_db = -80.0
    fade_in_player.play()
    
    if not music_crossfade_tween:
        music_crossfade_tween = create_tween()
    
    music_crossfade_tween.parallel().tween_property(fade_in_player, "volume_db", new_track.volume_db, crossfade_time)
    
    active_music_player = fade_in_player
    current_music = new_track
    music_changed.emit(new_track_id, "")

func set_music_layer(layer_name: String, volume: float, fade_time: float = 1.0) -> void:
    if not music_layers.has(layer_name):
        push_warning("AudioManager: Music layer not found: " + layer_name)
        return
    
    var layer_player = music_layers[layer_name]
    var target_volume_db = linear_to_db(volume)
    
    var tween = create_tween()
    tween.tween_property(layer_player, "volume_db", target_volume_db, fade_time)
    
    music_layer_changed.emit(layer_name, volume)

func get_pooled_player(sound_id: String) -> AudioStreamPlayer:
    if not sound_pools.has(sound_id):
        return null
    
    var pool = sound_pools[sound_id]
    for player in pool:
        if not player.playing:
            return player
    
    return null

func return_to_pool(sound_id: String, player: AudioStreamPlayer) -> void:
    if not sound_pools.has(sound_id):
        return
    
    player.stop()
    # Player stays in pool for reuse

func create_sound_pool(sound_id: String, size: int) -> void:
    if sound_pools.has(sound_id):
        return
    
    var pool: Array[AudioStreamPlayer] = []
    for i in range(size):
        var player = AudioStreamPlayer.new()
        add_child(player)
        pool.append(player)
    
    sound_pools[sound_id] = pool

func can_play_sound(sound_id: String) -> bool:
    var sound_data = sound_registry.get(sound_id)
    if not sound_data:
        return false
    
    return check_voice_limits(sound_data.bus_name)

func check_voice_limits(bus_name: String) -> bool:
    var bus_config = bus_configs.get(bus_name)
    if not bus_config or bus_config.max_voices == -1:
        return true
    
    var current_count = bus_voice_counts.get(bus_name, 0)
    return current_count < bus_config.max_voices

func cull_distant_sounds() -> void:
    if not listener:
        return
    
    for sound_id in active_sounds:
        var players = active_sounds[sound_id]
        for player in players:
            if player is AudioStreamPlayer2D:
                var spatial_player = player as AudioStreamPlayer2D
                var distance = listener.global_position.distance_to(spatial_player.global_position)
                var sound_data = sound_registry.get(sound_id)
                if sound_data and distance > sound_data.max_distance:
                    player.stop()
                    return_to_pool(sound_id, player)
                    players.erase(player)

func set_listener(node: Node2D) -> void:
    listener = node

func load_settings() -> void:
    if FileAccess.file_exists(SETTINGS_FILE):
        var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
        var json_string = file.get_as_text()
        file.close()
        
        var json = JSON.new()
        if json.parse(json_string) == OK:
            var data = json.data as Dictionary
            audio_settings.master_volume = data.get("master_volume", 1.0)
            audio_settings.bus_volumes = data.get("bus_volumes", {})
            audio_settings.bus_mutes = data.get("bus_mutes", {})
            apply_settings(audio_settings)

func save_settings() -> void:
    var save_data = {
        "master_volume": audio_settings.master_volume,
        "bus_volumes": audio_settings.bus_volumes,
        "bus_mutes": audio_settings.bus_mutes
    }
    
    var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
    file.close()

func apply_settings(settings: AudioSettings) -> void:
    audio_settings = settings
    
    # Apply master volume
    set_bus_volume("Master", settings.master_volume)
    
    # Apply bus volumes
    for bus_name in settings.bus_volumes:
        set_bus_volume(bus_name, settings.bus_volumes[bus_name])
    
    # Apply bus mutes
    for bus_name in settings.bus_mutes:
        set_bus_mute(bus_name, settings.bus_mutes[bus_name])

func create_music_players() -> void:
    music_player_1 = AudioStreamPlayer.new()
    music_player_1.bus = "Music"
    add_child(music_player_1)
    
    music_player_2 = AudioStreamPlayer.new()
    music_player_2.bus = "Music"
    add_child(music_player_2)
    
    active_music_player = music_player_1

func get_music_track(track_id: String) -> MusicTrack:
    # Load from resources
    var track_path = "res://resources/music/" + track_id + ".tres"
    if ResourceLoader.exists(track_path):
        return load(track_path) as MusicTrack
    return null

func get_music_playlist(playlist_id: String) -> MusicPlaylist:
    # Load from resources
    var playlist_path = "res://resources/music/playlists/" + playlist_id + ".tres"
    if ResourceLoader.exists(playlist_path):
        return load(playlist_path) as MusicPlaylist
    return null

func _on_sound_finished(sound_id: String, player: AudioStreamPlayer) -> void:
    if active_sounds.has(sound_id):
        active_sounds[sound_id].erase(player)
    
    var sound_data = sound_registry.get(sound_id)
    if sound_data:
        bus_voice_counts[sound_data.bus_name] = max(0, bus_voice_counts.get(sound_data.bus_name, 0) - 1)
    
    return_to_pool(sound_id, player)

func _on_playlist_track_finished() -> void:
    if not current_playlist:
        return
    
    # Find current track index
    var current_index = -1
    for i in range(current_playlist.tracks.size()):
        if current_playlist.tracks[i].track_id == current_music.track_id:
            current_index = i
            break
    
    # Play next track
    var next_index = (current_index + 1) % current_playlist.tracks.size()
    var next_track = current_playlist.tracks[next_index]
    
    crossfade_music(next_track.track_id, current_playlist.crossfade_time)

func process_voice_queues() -> void:
    # Process queued sounds when voice slots available
    for bus_name in bus_voice_queues:
        var queue = bus_voice_queues[bus_name]
        if queue.is_empty():
            continue
        
        if check_voice_limits(bus_name):
            var request = queue.pop_front()
            play_sound(request.sound_id, request.position, request.volume_modifier)
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── AudioManager.gd
   └── resources/
       ├── sounds/
       └── music/
           └── playlists/
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/AudioManager.gd` as `AudioManager`
   - **Important:** Load early (before systems that play sounds)

3. **Setup Audio Buses:**
   - **Project > Project Settings > Audio:**
   - Create buses: Master, Music, SFX
   - Configure bus volumes and effects

4. **Create Sound/Music Resources:**
   - Create SoundData resources for each sound
   - Create MusicTrack resources for each music track
   - Create MusicPlaylist resources for playlists
   - Save as `.tres` files in respective directories

### Initialization Order

**Autoload Order:**
1. GameManager
2. **AudioManager** (early, before systems that play sounds)
3. All other systems...

### System Integration

**Systems Must Call AudioManager:**
```gdscript
# Example: Play sound
AudioManager.play_sound("item_pickup")

# Example: Play 3D sound
AudioManager.play_sound_3d("footstep", player.global_position)

# Example: Play music
AudioManager.play_playlist("main_menu_playlist")

# Example: Change music state
AudioManager.set_music_state("combat")
```

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Audio System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Audio System:** https://docs.godotengine.org/en/stable/tutorials/audio/index.html
- **AudioStreamPlayer:** https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html
- **AudioStreamPlayer2D:** https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer2d.html
- **Audio Buses:** https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html
- **AudioServer:** https://docs.godotengine.org/en/stable/classes/class_audioserver.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Audio System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Audio System Tutorial](https://docs.godotengine.org/en/stable/tutorials/audio/index.html) - Audio system documentation
- [AudioStreamPlayer Documentation](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html) - 2D audio playback
- [AudioStreamPlayer2D Documentation](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer2d.html) - 3D spatial audio
- [Audio Buses Tutorial](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html) - Audio bus system
- [AudioServer Documentation](https://docs.godotengine.org/en/stable/classes/class_audioserver.html) - Audio server API

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- SoundData is a Resource (can be created/edited in inspector)
- MusicTrack is a Resource (can be created/edited in inspector)
- MusicPlaylist is a Resource (can be created/edited in inspector)
- AudioSettings is a Resource (can be configured in inspector)

**Visual Configuration:**
- Sound properties editable in inspector
- Music track properties editable in inspector
- Playlist properties editable in inspector
- Audio buses configured in Project Settings

**Editor Tools Needed:**
- **None Required:** Standard Godot systems provide all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Audio preview tool
  - Sound pool visualizer
  - Music layer tester

**Current Approach:**
- Uses Godot's native Audio system (no custom tools needed)
- Sounds/music created as Resource files (editable in inspector)
- Audio buses configured in Project Settings
- Fully functional without custom editor tools

---

## Implementation Notes

### Audio Bus Setup

**Core Buses:**
- Master (index 0, always exists)
- Music (index 1)
- SFX (index 2)

**Optional Buses:**
- UI
- Voice/Dialogue
- Ambient
- Combat

### Sound Registration

**Method:** Register sounds in `AudioManager`

**Example:**
```gdscript
# In AudioManager._ready()
var ui_click = SoundData.new()
ui_click.sound_id = "ui_click"
ui_click.audio_path = "res://assets/audio/sfx/ui_click.wav"
ui_click.bus_name = "UI"
ui_click.priority = 80
ui_click.preload = true
ui_click.is_spatial = false
register_sound(ui_click)
```

### Music Playlist Configuration

**Example:**
```gdscript
var wasteland_playlist = MusicPlaylist.new()
wasteland_playlist.playlist_id = "wasteland"
wasteland_playlist.shuffle = true
wasteland_playlist.crossfade_time = 2.0
wasteland_playlist.tracks = [
    load_music_track("wasteland_theme_1"),
    load_music_track("wasteland_theme_2"),
    load_music_track("wasteland_theme_3")
]
```

---

## Future Enhancements

### Potential Additions

1. **Audio Occlusion:**
   - Sounds blocked by walls/obstacles
   - Realistic audio propagation

2. **Reverb Zones:**
   - Area-based reverb effects
   - Different reverb per biome

3. **Audio Visualization:**
   - Visual feedback for audio
   - Waveform visualization

4. **Advanced Music:**
   - More complex adaptive music
   - Stinger sounds

5. **Audio Recording:**
   - Record gameplay audio
   - Replay system

---

## Dependencies

### Required Systems
- None (foundational system)

### Systems That Depend on This
- Combat System (weapon sounds, combat music)
- UI System (UI sounds, menu music)
- Interaction System (interaction sounds)
- Survival System (environmental sounds)
- Dialogue System (voice lines)

---

## Notes

- Audio system is a foundational system used by many other systems
- Configurable buses allow flexibility while maintaining simplicity
- Hybrid 2D/3D approach provides best of both worlds
- Automatic pooling improves performance without extra configuration
- Priority system prevents audio clutter
- Dynamic music with playlists and layers provides immersive experience
- Settings persistence ensures player preferences are maintained

