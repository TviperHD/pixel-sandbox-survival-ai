# Technical Specifications: Multiplayer/Co-op System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the multiplayer/co-op system supporting both local and online multiplayer (coop-focused with PvP option), world-based multiplayer (worlds created, people invited), hybrid network architecture (P2P default with optional dedicated servers), host-authoritative world synchronization with client-side prediction, hybrid save system, automatic host migration, full modding support, and comprehensive anti-cheat measures. This system integrates with all game systems to provide seamless multiplayer gameplay.

---

## Research Notes

### Multiplayer Architecture Best Practices

**Research Findings:**
- Host-authoritative world prevents desync in destructible terrain games
- Client-side prediction provides responsive gameplay despite latency
- Chunk-based synchronization reduces bandwidth for large worlds
- Delta compression minimizes data transmission
- Interest management (area-of-interest) reduces unnecessary updates
- UDP protocol provides lower latency than TCP for real-time games
- Adaptive tick rates balance performance and responsiveness

**Sources:**
- [Godot 4 Multiplayer Documentation](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html) - Multiplayer networking
- [Godot 4 ENet Documentation](https://docs.godotengine.org/en/stable/classes/class_enetmultiplayerpeer.html) - ENet networking
- Terraria multiplayer architecture patterns - Industry standard approach
- General multiplayer game networking best practices

**Implementation Approach:**
- Host-authoritative world state (world generation, terrain, physics)
- Client-side prediction for player actions (movement, combat)
- Chunk-based synchronization (sync only nearby chunks)
- Delta compression (send only changes)
- Interest management (updates only to nearby players)
- UDP protocol (lower latency)
- Adaptive tick rates (adjust based on load)

**Why This Approach:**
- Prevents world desync with destructible terrain
- Provides responsive gameplay (client prediction)
- Efficient bandwidth usage (chunk-based + delta compression)
- Works for both P2P and dedicated servers

### NAT Traversal Best Practices

**Research Findings:**
- UPnP works for most home routers (automatic port forwarding)
- STUN enables direct P2P connections through NAT
- TURN provides relay fallback for strict NAT
- Manual port forwarding as last resort

**Sources:**
- General NAT traversal techniques
- P2P networking best practices

**Implementation Approach:**
- Try UPnP first (automatic)
- Then STUN (NAT traversal)
- Then TURN (relay fallback)
- Finally manual port forwarding (instructions)

**Why This Approach:**
- Works automatically for most players
- Handles strict NAT with TURN fallback
- Provides manual option if needed
- Balances ease of use and connectivity

### Anti-Cheat Best Practices

**Research Findings:**
- Server-side validation prevents most cheats
- Rate limiting prevents spam/exploits
- Sanity checks validate data ranges
- Checksum validation verifies game state integrity
- Action logging tracks suspicious behavior

**Sources:**
- General multiplayer anti-cheat patterns
- Server-authoritative architecture best practices

**Implementation Approach:**
- Server-side validation (authoritative host/server)
- Rate limiting (actions per second, movement speed)
- Sanity checks (data ranges, position validation)
- Checksum validation (game state integrity)
- Action logging (suspicious behavior tracking)
- Peer reporting (players can report cheaters)
- Admin tools (kick/ban suspicious players)

**Why This Approach:**
- Prevents most common cheats (server authority)
- Works for both P2P and dedicated servers
- Balances security and performance
- Allows admin intervention

---

## Data Structures

### NetworkType

```gdscript
enum NetworkType {
    P2P,                # Peer-to-peer (default)
    DEDICATED_SERVER,   # Dedicated server (paid or self-hosted)
    LOCAL               # Local multiplayer (same device)
}
```

### ConnectionState

```gdscript
enum ConnectionState {
    DISCONNECTED,       # Not connected
    CONNECTING,         # Connecting to host/server
    CONNECTED,          # Connected and synchronized
    SYNCHRONIZING,      # Synchronizing world state
    RECONNECTING        # Reconnecting after disconnect
}
```

### PlayerRole

```gdscript
enum PlayerRole {
    PLAYER,            # Regular player
    ADMIN,             # World admin (can manage world)
    MODERATOR,         # Moderator (can kick players)
    HOST               # Current host (authoritative)
}
```

### WorldData

```gdscript
class_name WorldData
extends Resource

# World Identification
@export var world_id: String  # Unique world ID
@export var world_name: String  # Display name
@export var world_owner_id: String  # Creator's player ID

# World Settings
@export var max_players: int = 8  # Maximum players (configurable)
@export var pvp_enabled: bool = false  # PvP enabled (world setting)
@export var character_locked: bool = false  # Characters locked to this world
@export var is_public: bool = false  # Public listing (optional)

# World State
@export var current_host_id: String = ""  # Current host player ID
@export var is_hosted: bool = false  # Is world currently hosted
@export var last_hosted_time: float = 0.0  # Last time world was hosted
@export var last_save_time: float = 0.0  # Last auto-save time

# World Members
@export var members: Array[String] = []  # Player IDs in world
@export var admins: Array[String] = []  # Admin player IDs
@export var moderators: Array[String] = []  # Moderator player IDs
@export var banned_players: Array[String] = []  # Banned player IDs

# World Mods
@export var enabled_mods: Array[String] = []  # Enabled mod IDs
@export var required_mods: Array[String] = []  # Required mod IDs (server mods)

# World Save Data
@export var world_save_path: String = ""  # Path to world save file
@export var world_seed: int = 0  # World generation seed
```

### PlayerConnectionData

```gdscript
class_name PlayerConnectionData
extends RefCounted

var player_id: String  # Unique player ID
var player_name: String  # Display name
var role: PlayerRole = PlayerRole.PLAYER
var connection_state: ConnectionState = ConnectionState.DISCONNECTED
var ping: float = 0.0  # Latency in milliseconds
var is_host: bool = false
var is_local: bool = false  # Local player (same device)

# Character Data
var character_id: String = ""  # Character ID (world-specific if locked)
var character_data: Dictionary = {}  # Character save data

# Connection Info
var ip_address: String = ""
var port: int = 0
var connection_time: float = 0.0
var last_ping_time: float = 0.0
```

### NetworkMessage

```gdscript
class_name NetworkMessage
extends RefCounted

var message_type: String  # Message type ID
var sender_id: String  # Sender player ID
var target_id: String = ""  # Target player ID (empty = broadcast)
var data: Dictionary = {}  # Message data
var timestamp: float = 0.0  # Message timestamp
var reliable: bool = true  # Reliable delivery (TCP-like)
```

### ChunkSyncData

```gdscript
class_name ChunkSyncData
extends RefCounted

var chunk_coords: Vector2i  # Chunk coordinates
var chunk_data: Dictionary = {}  # Chunk data (terrain, materials, etc.)
var last_update_time: float = 0.0  # Last update timestamp
var version: int = 0  # Chunk version (for delta sync)
var delta_data: Dictionary = {}  # Delta changes (for compression)
```

---

## Core Classes

### MultiplayerManager (Autoload Singleton)

```gdscript
class_name MultiplayerManager
extends Node

# Network Configuration
@export var network_type: NetworkType = NetworkType.P2P
@export var default_port: int = 7777
@export var max_players: int = 8  # Hard maximum
@export var enable_nat_traversal: bool = true

# World Management
var current_world: WorldData = null
var world_registry: Dictionary = {}  # world_id -> WorldData
var hosted_worlds: Dictionary = {}  # world_id -> host_id

# Connection Management
var players: Dictionary = {}  # player_id -> PlayerConnectionData
var local_player_id: String = ""
var is_hosting: bool = false
var connection_state: ConnectionState = ConnectionState.DISCONNECTED

# Network Components
var multiplayer_peer: MultiplayerPeer = null
var nat_traversal: NATTraversal = null
var stun_server: String = "stun.l.google.com:19302"
var turn_server: String = ""  # TURN server URL (if available)

# Synchronization
var chunk_manager: ChunkSyncManager = null
var interest_manager: InterestManager = null
var delta_compressor: DeltaCompressor = null

# Anti-Cheat
var validation_manager: ValidationManager = null
var rate_limiter: RateLimiter = null
var action_logger: ActionLogger = null

# Mod Support
var mod_manager: ModManager = null

# References
var world_generator: WorldGenerator
var pixel_physics_manager: PixelPhysicsManager
var save_manager: SaveManager

# Signals
signal world_created(world_id: String)
signal world_hosted(world_id: String, host_id: String)
signal world_closed(world_id: String)
signal player_connected(player_id: String)
signal player_disconnected(player_id: String)
signal host_migrated(new_host_id: String)
signal connection_failed(reason: String)
signal world_synchronized()

# Initialization
func _ready() -> void
func initialize() -> void

# World Management
func create_world(world_name: String, settings: Dictionary) -> WorldData
func host_world(world_id: String) -> bool
func stop_hosting() -> void
func join_world(world_id: String, password: String = "") -> bool
func leave_world() -> void
func get_world(world_id: String) -> WorldData

# Connection Management
func start_hosting(port: int = -1) -> bool
func connect_to_host(ip: String, port: int) -> bool
func disconnect() -> void
func get_local_player_id() -> String
func is_local_player(player_id: String) -> bool

# NAT Traversal
func setup_nat_traversal() -> void
func try_upnp() -> bool
func try_stun() -> bool
func try_turn() -> bool
func get_public_ip() -> String

# Host Migration
func migrate_host(new_host_id: String) -> void
func select_new_host() -> String
func transfer_world_state(new_host_id: String) -> void

# Synchronization
func sync_world_chunk(chunk_coords: Vector2i) -> void
func sync_player_state(player_id: String) -> void
func sync_world_state() -> void
func handle_chunk_update(chunk_data: ChunkSyncData) -> void

# Anti-Cheat
func validate_action(player_id: String, action: String, data: Dictionary) -> bool
func rate_limit_check(player_id: String, action: String) -> bool
func log_action(player_id: String, action: String, data: Dictionary) -> void
func report_player(player_id: String, reason: String) -> void

# Player Management
func get_player(player_id: String) -> PlayerConnectionData
func kick_player(player_id: String, reason: String) -> void
func ban_player(player_id: String, reason: String) -> void
func set_player_role(player_id: String, role: PlayerRole) -> void

# Mod Support
func load_world_mods(world_id: String) -> void
func validate_mods(player_id: String) -> bool
func sync_mods_to_player(player_id: String) -> void
```

### ChunkSyncManager

```gdscript
class_name ChunkSyncManager
extends Node

# Chunk Tracking
var synced_chunks: Dictionary = {}  # chunk_coords -> ChunkSyncData
var chunk_versions: Dictionary = {}  # chunk_coords -> version
var pending_chunks: Array[Vector2i] = []  # Chunks waiting to sync

# Configuration
@export var sync_radius: int = 3  # Chunks to sync around player
@export var sync_interval: float = 0.1  # Sync interval in seconds
@export var enable_delta_compression: bool = true

# References
var multiplayer_manager: MultiplayerManager
var world_generator: WorldGenerator
var pixel_physics_manager: PixelPhysicsManager

# Functions
func update_chunk_sync(player_pos: Vector2) -> void
func sync_chunk(chunk_coords: Vector2i) -> void
func handle_chunk_update(chunk_data: ChunkSyncData) -> void
func get_chunks_in_radius(center: Vector2i, radius: int) -> Array[Vector2i]
func compress_chunk_data(chunk_data: Dictionary) -> Dictionary
func decompress_chunk_data(compressed_data: Dictionary) -> Dictionary
```

### InterestManager

```gdscript
class_name InterestManager
extends Node

# Interest Tracking
var player_interests: Dictionary = {}  # player_id -> Array[chunk_coords]
var update_queue: Array[Dictionary] = []  # Queued updates

# Configuration
@export var interest_radius: float = 500.0  # Pixels
@export var update_interval: float = 0.2  # Update interval

# References
var multiplayer_manager: MultiplayerManager

# Functions
func update_player_interest(player_id: String, position: Vector2) -> void
func should_send_update(player_id: String, chunk_coords: Vector2i) -> bool
func get_interested_players(chunk_coords: Vector2i) -> Array[String]
func queue_update(update_data: Dictionary) -> void
func process_update_queue() -> void
```

### ValidationManager

```gdscript
class_name ValidationManager
extends Node

# Validation Rules
var validation_rules: Dictionary = {}  # action -> validation_function
var player_stats: Dictionary = {}  # player_id -> stats

# References
var multiplayer_manager: MultiplayerManager
var rate_limiter: RateLimiter

# Functions
func register_validation_rule(action: String, validator: Callable) -> void
func validate_action(player_id: String, action: String, data: Dictionary) -> bool
func validate_movement(player_id: String, new_position: Vector2) -> bool
func validate_combat(player_id: String, damage: float, target_id: String) -> bool
func validate_inventory(player_id: String, item_id: String, quantity: int) -> bool
func validate_world_modification(player_id: String, position: Vector2, modification: Dictionary) -> bool
```

### RateLimiter

```gdscript
class_name RateLimiter
extends Node

# Rate Limits
var rate_limits: Dictionary = {}  # action -> {max_count: int, window: float}
var player_actions: Dictionary = {}  # player_id -> {action -> Array[timestamps]}

# Configuration
@export var default_rate_limit: Dictionary = {"max_count": 10, "window": 1.0}

# Functions
func set_rate_limit(action: String, max_count: int, window: float) -> void
func check_rate_limit(player_id: String, action: String) -> bool
func record_action(player_id: String, action: String) -> void
func cleanup_old_actions() -> void
```

### NATTraversal

```gdscript
class_name NATTraversal
extends Node

# NAT Configuration
@export var stun_servers: Array[String] = ["stun.l.google.com:19302"]
@export var turn_server: String = ""
@export var enable_upnp: bool = true

# State
var nat_type: String = "Unknown"
var public_ip: String = ""
var public_port: int = 0
var traversal_method: String = ""

# Functions
func detect_nat_type() -> String
func try_upnp() -> bool
func try_stun() -> bool
func try_turn() -> bool
func get_public_endpoint() -> Dictionary  # Returns {ip: String, port: int}
func setup_port_forwarding(port: int) -> bool
```

---

## System Architecture

### Component Hierarchy

```
MultiplayerManager (Autoload Singleton)
├── Network Components
│   ├── MultiplayerPeer (ENet/WebRTC)
│   ├── NATTraversal
│   └── ConnectionManager
├── Synchronization
│   ├── ChunkSyncManager
│   ├── InterestManager
│   └── DeltaCompressor
├── Anti-Cheat
│   ├── ValidationManager
│   ├── RateLimiter
│   └── ActionLogger
├── World Management
│   ├── WorldRegistry
│   └── HostMigration
└── Mod Support
    └── ModManager
```

### Data Flow

1. **World Hosting:**
   ```
   Player hosts world
   ├── Create/load world data
   ├── Setup NAT traversal
   ├── Start multiplayer peer
   ├── Begin world synchronization
   ├── Accept player connections
   └── world_hosted.emit()
   ```

2. **Player Connection:**
   ```
   Player joins world
   ├── Connect to host/server
   ├── Authenticate player
   ├── Validate mods match
   ├── Synchronize world state
   ├── Load character data
   ├── Spawn player in world
   └── player_connected.emit()
   ```

3. **World Synchronization:**
   ```
   Host updates world
   ├── Detect chunk changes
   ├── Compress delta data
   ├── Find interested players
   ├── Send updates to players
   ├── Players apply updates
   └── World synchronized
   ```

---

## Algorithms

### Host-Authoritative World Synchronization

```gdscript
func sync_world_chunk(chunk_coords: Vector2i) -> void:
    if not is_hosting:
        return
    
    # Get chunk data from world generator/pixel physics
    var chunk_data = get_chunk_data(chunk_coords)
    if chunk_data == null:
        return
    
    # Create sync data
    var sync_data = ChunkSyncData.new()
    sync_data.chunk_coords = chunk_coords
    sync_data.chunk_data = chunk_data
    
    # Delta compression
    if enable_delta_compression:
        var previous_version = chunk_versions.get(chunk_coords, 0)
        sync_data.delta_data = calculate_delta(chunk_data, previous_version)
        sync_data.version = previous_version + 1
    else:
        sync_data.chunk_data = chunk_data
        sync_data.version = chunk_versions.get(chunk_coords, 0) + 1
    
    # Update version
    chunk_versions[chunk_coords] = sync_data.version
    
    # Find interested players
    var interested_players = interest_manager.get_interested_players(chunk_coords)
    
    # Send to interested players
    for player_id in interested_players:
        send_chunk_update(player_id, sync_data)

func handle_chunk_update(chunk_data: ChunkSyncData) -> void:
    if is_hosting:
        return  # Host doesn't receive updates
    
    # Apply chunk update
    var chunk_coords = chunk_data.chunk_coords
    
    # Delta decompression
    if chunk_data.delta_data.size() > 0:
        var current_chunk = get_chunk_data(chunk_coords)
        apply_delta(current_chunk, chunk_data.delta_data)
    else:
        set_chunk_data(chunk_coords, chunk_data.chunk_data)
    
    # Update version
    chunk_versions[chunk_coords] = chunk_data.version
```

### Client-Side Prediction

```gdscript
func predict_player_action(player_id: String, action: String, data: Dictionary) -> void:
    # Predict action locally for immediate feedback
    match action:
        "move":
            predict_movement(player_id, data["position"], data["velocity"])
        "attack":
            predict_attack(player_id, data["target"], data["damage"])
        "interact":
            predict_interaction(player_id, data["target"])
    
    # Send to host for validation
    send_action_to_host(player_id, action, data)

func reconcile_prediction(player_id: String, server_state: Dictionary) -> void:
    # Compare predicted state with server state
    var predicted_state = get_predicted_state(player_id)
    var difference = calculate_difference(predicted_state, server_state)
    
    # If difference is significant, correct
    if difference > threshold:
        correct_player_state(player_id, server_state)
```

### Host Migration Algorithm

```gdscript
func migrate_host(new_host_id: String) -> void:
    if not is_hosting:
        return
    
    var old_host_id = local_player_id
    
    # Transfer world state to new host
    var world_state = collect_world_state()
    send_world_state(new_host_id, world_state)
    
    # Transfer player connections
    for player_id in players:
        if player_id != new_host_id:
            send_player_connection_info(player_id, new_host_id)
    
    # Stop hosting
    stop_hosting()
    
    # New host takes over
    if new_host_id == local_player_id:
        start_hosting()
    
    host_migrated.emit(new_host_id)

func select_new_host() -> String:
    # Select new host based on priority:
    # 1. Admins
    # 2. Moderators
    # 3. Longest connected player
    # 4. Random player
    
    var candidates: Array[String] = []
    
    # Find admins
    for player_id in players:
        var player = players[player_id]
        if player.role == PlayerRole.ADMIN:
            candidates.append(player_id)
    
    if candidates.size() > 0:
        return candidates[0]
    
    # Find moderators
    for player_id in players:
        var player = players[player_id]
        if player.role == PlayerRole.MODERATOR:
            candidates.append(player_id)
    
    if candidates.size() > 0:
        return candidates[0]
    
    # Find longest connected
    var longest_connected: String = ""
    var longest_time: float = 0.0
    
    for player_id in players:
        var player = players[player_id]
        var connection_time = Time.get_unix_time_from_system() - player.connection_time
        if connection_time > longest_time:
            longest_time = connection_time
            longest_connected = player_id
    
    if longest_connected != "":
        return longest_connected
    
    # Random fallback
    if players.size() > 0:
        return players.keys()[0]
    
    return ""
```

### NAT Traversal Algorithm

```gdscript
func setup_nat_traversal() -> void:
    # Try methods in order: UPnP → STUN → TURN → Manual
    
    # Try UPnP first
    if enable_upnp:
        if try_upnp():
            traversal_method = "UPnP"
            return
    
    # Try STUN
    if try_stun():
        traversal_method = "STUN"
        return
    
    # Try TURN (if available)
    if turn_server != "":
        if try_turn():
            traversal_method = "TURN"
            return
    
    # Fallback to manual port forwarding
    traversal_method = "Manual"
    show_port_forwarding_instructions()

func try_upnp() -> bool:
    # Attempt UPnP port mapping
    var upnp = UPNP.new()
    upnp.discover()
    
    if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
        var result = upnp.add_port_mapping(default_port)
        if result == UPNP.UPNP_RESULT_SUCCESS:
            public_ip = upnp.query_external_address()
            public_port = default_port
            return true
    
    return false

func try_stun() -> bool:
    # Use STUN to discover public IP/port
    var stun_client = STUNClient.new()
    var result = stun_client.query(stun_server)
    
    if result.success:
        public_ip = result.public_ip
        public_port = result.public_port
        nat_type = result.nat_type
        return true
    
    return false
```

### Anti-Cheat Validation Algorithm

```gdscript
func validate_action(player_id: String, action: String, data: Dictionary) -> bool:
    # Rate limiting check
    if not rate_limiter.check_rate_limit(player_id, action):
        log_suspicious_action(player_id, action, "Rate limit exceeded")
        return false
    
    # Sanity checks
    match action:
        "move":
            if not validate_movement(player_id, data["position"], data["velocity"]):
                return false
        "attack":
            if not validate_combat(player_id, data["damage"], data["target"]):
                return false
        "world_modify":
            if not validate_world_modification(player_id, data["position"], data["modification"]):
                return false
    
    # Record action
    action_logger.log_action(player_id, action, data)
    rate_limiter.record_action(player_id, action)
    
    return true

func validate_movement(player_id: String, new_position: Vector2, velocity: Vector2) -> bool:
    var player = get_player(player_id)
    if player == null:
        return false
    
    # Check speed limit
    var speed = velocity.length()
    var max_speed = 500.0  # Configurable
    if speed > max_speed:
        log_suspicious_action(player_id, "move", "Speed hack detected: " + str(speed))
        return false
    
    # Check position bounds
    var world_bounds = world_generator.get_world_bounds()
    if not world_bounds.has_point(new_position):
        log_suspicious_action(player_id, "move", "Position out of bounds")
        return false
    
    # Check teleportation (large distance change)
    var current_pos = get_player_position(player_id)
    var distance = current_pos.distance_to(new_position)
    var max_distance = speed * get_physics_process_delta_time() * 2.0  # Allow 2x for lag
    
    if distance > max_distance:
        log_suspicious_action(player_id, "move", "Possible teleportation: " + str(distance))
        return false
    
    return true
```

---

## Integration Points

### With All Game Systems

```gdscript
# All systems need to be multiplayer-aware
# Example: Inventory System
func add_item_to_inventory(item_id: String, quantity: int) -> bool:
    # Add locally
    var success = inventory_manager.add_item(item_id, quantity)
    
    # If hosting, validate and sync
    if multiplayer_manager.is_hosting:
        if not multiplayer_manager.validate_action(local_player_id, "inventory_add", {"item_id": item_id, "quantity": quantity}):
            # Revert local change
            inventory_manager.remove_item(item_id, quantity)
            return false
        
        # Sync to other players
        multiplayer_manager.sync_player_state(local_player_id)
    
    return success
```

### With Save System

```gdscript
# World saves
func save_world() -> void:
    if multiplayer_manager.is_hosting:
        var world_data = collect_world_data()
        save_manager.save_world(world_id, world_data)
        multiplayer_manager.current_world.last_save_time = Time.get_unix_time_from_system()

# Character saves
func save_character() -> void:
    var character_data = collect_character_data()
    save_manager.save_character(local_player_id, character_data)
```

### With Mod System

```gdscript
# Validate mods match
func validate_mods_match(player_id: String) -> bool:
    var world_mods = multiplayer_manager.current_world.enabled_mods
    var player_mods = get_player_mods(player_id)
    
    # Check required mods (server mods)
    for mod_id in multiplayer_manager.current_world.required_mods:
        if mod_id not in player_mods:
            return false
    
    return true
```

---

## Save/Load System

### Save Data Structure

```gdscript
var multiplayer_save_data: Dictionary = {
    "worlds": serialize_worlds(),
    "player_connections": serialize_player_connections(),
    "mod_config": serialize_mod_config()
}

func serialize_worlds() -> Dictionary:
    var worlds_data: Dictionary = {}
    for world_id in world_registry:
        var world = world_registry[world_id]
        worlds_data[world_id] = {
            "world_name": world.world_name,
            "world_owner_id": world.world_owner_id,
            "max_players": world.max_players,
            "pvp_enabled": world.pvp_enabled,
            "character_locked": world.character_locked,
            "is_public": world.is_public,
            "members": world.members,
            "admins": world.admins,
            "moderators": world.moderators,
            "enabled_mods": world.enabled_mods,
            "required_mods": world.required_mods,
            "world_save_path": world.world_save_path,
            "last_save_time": world.last_save_time
        }
    return worlds_data
```

### Load Data Structure

```gdscript
func load_multiplayer_data(data: Dictionary) -> void:
    if data.has("worlds"):
        load_worlds(data["worlds"])
    if data.has("player_connections"):
        load_player_connections(data["player_connections"])
    if data.has("mod_config"):
        load_mod_config(data["mod_config"])
```

---

## Error Handling

### MultiplayerManager Error Handling

- **Connection Failures:** Graceful disconnection, reconnection attempts
- **NAT Traversal Failures:** Fallback to next method, show instructions
- **Mod Mismatches:** Clear error messages, mod download prompts
- **Validation Failures:** Log suspicious actions, kick/ban if severe
- **Host Migration Failures:** Select new host, transfer state

### Best Practices

- Use `push_error()` for critical errors (connection failures, validation failures)
- Use `push_warning()` for non-critical issues (mod mismatches, NAT failures)
- Return false/null on errors (don't crash)
- Validate all inputs before operations
- Log all suspicious actions for review

---

## Default Values and Configuration

### MultiplayerManager Defaults

```gdscript
network_type = NetworkType.P2P
default_port = 7777
max_players = 8
enable_nat_traversal = true
stun_server = "stun.l.google.com:19302"
```

### WorldData Defaults

```gdscript
max_players = 8
pvp_enabled = false
character_locked = false
is_public = false
is_hosted = false
```

### ChunkSyncManager Defaults

```gdscript
sync_radius = 3
sync_interval = 0.1
enable_delta_compression = true
```

---

## Performance Considerations

### Optimization Strategies

1. **Chunk Synchronization:**
   - Sync only chunks near players
   - Use delta compression
   - Batch chunk updates
   - Limit sync frequency

2. **Interest Management:**
   - Update only interested players
   - Use spatial partitioning
   - Limit update radius
   - Cache interest calculations

3. **Network Optimization:**
   - Use UDP for real-time data
   - Compress data packets
   - Limit packet size
   - Adaptive tick rates

4. **Anti-Cheat:**
   - Cache validation results
   - Batch validation checks
   - Limit logging frequency
   - Efficient data structures

---

## Testing Checklist

### Multiplayer System
- [ ] World creation works
- [ ] World hosting works
- [ ] Player connection works
- [ ] World synchronization works
- [ ] Host migration works
- [ ] Reconnection works

### Network Features
- [ ] NAT traversal works (UPnP, STUN, TURN)
- [ ] Connection discovery works
- [ ] Latency handling works (prediction, compensation)
- [ ] Bandwidth optimization works

### Anti-Cheat
- [ ] Server-side validation works
- [ ] Rate limiting works
- [ ] Sanity checks work
- [ ] Action logging works

### Mod Support
- [ ] Mod loading works
- [ ] Mod validation works
- [ ] Mod synchronization works

### Integration
- [ ] Integrates with all game systems correctly
- [ ] Save/load works correctly
- [ ] World persistence works correctly

---

## Complete Implementation

### MultiplayerManager Initialization

```gdscript
func _ready() -> void:
    # Get references
    world_generator = get_node_or_null("/root/WorldGenerator")
    pixel_physics_manager = get_node_or_null("/root/PixelPhysicsManager")
    save_manager = get_node_or_null("/root/SaveManager")
    
    # Initialize components
    chunk_manager = ChunkSyncManager.new()
    interest_manager = InterestManager.new()
    validation_manager = ValidationManager.new()
    rate_limiter = RateLimiter.new()
    action_logger = ActionLogger.new()
    nat_traversal = NATTraversal.new()
    
    add_child(chunk_manager)
    add_child(interest_manager)
    add_child(validation_manager)
    add_child(rate_limiter)
    add_child(action_logger)
    add_child(nat_traversal)
    
    # Initialize
    initialize()

func initialize() -> void:
    # Setup NAT traversal
    if enable_nat_traversal:
        setup_nat_traversal()
    
    # Register validation rules
    register_validation_rules()
    
    # Setup rate limits
    setup_rate_limits()
    
    # Load world registry
    load_world_registry()

func register_validation_rules() -> void:
    validation_manager.register_validation_rule("move", validate_movement)
    validation_manager.register_validation_rule("attack", validate_combat)
    validation_manager.register_validation_rule("world_modify", validate_world_modification)
    validation_manager.register_validation_rule("inventory_add", validate_inventory_add)
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── scripts/
   │   └── managers/
   │       └── MultiplayerManager.gd
   └── resources/
       └── multiplayer/
           └── (world data, mod configs)
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/MultiplayerManager.gd` as `MultiplayerManager`
   - **Important:** Load after all game systems

3. **Configure Network Settings:**
   - Set default port
   - Configure STUN/TURN servers
   - Setup rate limits
   - Configure validation rules

### Initialization Order

**Autoload Order:**
1. GameManager
2. All game systems
3. **MultiplayerManager** (after all dependencies)

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Multiplayer/Co-op System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Multiplayer:** https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html
- **ENet:** https://docs.godotengine.org/en/stable/classes/class_enetmultiplayerpeer.html
- **WebRTC:** https://docs.godotengine.org/en/stable/classes/class_webrtcpeerconnection.html
- **UPNP:** https://docs.godotengine.org/en/stable/classes/class_upnp.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Multiplayer/Co-op System. All links are to official Godot 4 documentation.

### Core Systems Documentation

- [Multiplayer Tutorial](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html) - Multiplayer networking
- [ENet Documentation](https://docs.godotengine.org/en/stable/classes/class_enetmultiplayerpeer.html) - ENet networking
- [WebRTC Documentation](https://docs.godotengine.org/en/stable/classes/class_webrtcpeerconnection.html) - WebRTC networking
- [UPNP Documentation](https://docs.godotengine.org/en/stable/classes/class_upnp.html) - UPnP port forwarding

### Best Practices

- [Godot 4 Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html) - General development guidelines
- [Performance Optimization](https://docs.godotengine.org/en/stable/tutorials/performance/index.html) - Performance considerations

---

## Editor Support

**Editor-Friendly Design:**
- WorldData is a Resource (can be created/edited in inspector)
- World settings editable in inspector
- Network settings configurable

**Visual Configuration:**
- World settings configurable
- Network settings editable
- Mod settings configurable

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - World browser/editor
  - Network testing tools
  - Mod management UI

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Worlds managed programmatically
- Fully functional without custom editor tools

---

## Implementation Notes

1. **World-Based System:** Worlds are created, people are invited. Anyone in world can host, but only one instance at a time.
2. **Hybrid Network:** P2P default, optional dedicated servers (paid or self-hosted).
3. **Host-Authoritative:** Host/server controls world state, clients predict actions.
4. **Auto-Save:** World auto-saves, especially on game close.
5. **Character Locking:** Option to lock characters to specific worlds.
6. **Mod Support:** Full modding support, server mods required for all players.
7. **Anti-Cheat:** Server-side validation, rate limiting, sanity checks.
8. **NAT Traversal:** Automatic with fallback (UPnP → STUN → TURN → Manual).

