# Technical Specifications: Trading/Economy System

**Date:** 2025-11-24  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the trading and economy system, including dynamic pricing (relationship + supply/demand), currency system (droppable items with inventory slot), trading interface (quick trade + full shop), barter system, NPC shop inventory management, and tag-based item acceptance. This system integrates with Inventory System, Item Database, Relationship System, and UI System.

---

## Research Notes

### Trading System Architecture Best Practices

**Research Findings:**
- Dynamic pricing creates engaging economy
- Relationship-based pricing rewards player investment
- Supply/demand mechanics add realism
- Barter systems increase player agency
- Currency as items (like Terraria) is intuitive and flexible

**Sources:**
- [Godot 4 Resource System](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) - Resource-based data structures
- [Godot 4 Signals Documentation](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) - Signal-based communication
- Terraria trading system patterns - Currency as items, barter system

**Implementation Approach:**
- Currency items stored in dedicated inventory slot
- TradingManager singleton manages all trading logic
- Dynamic pricing calculated from relationship + supply/demand
- Tag-based item acceptance for flexible NPC configuration
- Quick trade menu for common items (currency only)
- Full shop menu for browsing (currency + barter)

**Why This Approach:**
- Currency as items allows multiple currency types
- Dynamic pricing creates engaging economy
- Tag-based system is flexible and configurable
- Dual interface (quick + full) serves different needs
- Barter system gives players more options

### Dynamic Pricing Best Practices

**Research Findings:**
- Relationship-based pricing rewards investment
- Supply/demand creates dynamic economy
- Price caps prevent extreme fluctuations
- Price history helps prevent exploitation

**Sources:**
- General game economy design patterns
- Dynamic pricing in survival games

**Implementation Approach:**
- Base price modified by relationship multiplier
- Then adjusted by supply/demand factor
- Price caps (min/max) prevent extreme values
- Price history tracking prevents rapid exploitation

**Why This Approach:**
- Rewards relationship building
- Creates dynamic, living economy
- Prevents price manipulation
- Balanced and fair

---

## Data Structures

### CurrencyItem

```gdscript
class_name CurrencyItem
extends Resource

# Identification
@export var currency_id: String  # Unique identifier (e.g., "credits", "scrap", "energy_core")
@export var currency_name: String  # Display name
@export var currency_icon: Texture2D  # Icon for inventory

# Value
@export var base_value: int = 1  # Base value (for conversion)
@export var stack_size: int = 999  # Max stack size in currency slot

# Conversion (for multiple currencies)
@export var conversion_rates: Dictionary = {}  # currency_id -> conversion_rate
# Example: {"credits": 10} means 1 of this = 10 credits

# Visual
@export var drop_sprite: Texture2D  # Sprite when dropped in world
@export var pickup_sound: String = ""  # Sound ID for pickup
```

### ShopItem

```gdscript
class_name ShopItem
extends Resource

# Item Reference
@export var item_id: String  # Item ID from ItemDatabase
@export var item_data: ItemData  # Reference to item data

# Pricing
@export var base_price: int = 100  # Base price in currency
@export var min_price: int = 10  # Minimum price (price floor)
@export var max_price: int = 10000  # Maximum price (price ceiling)
@export var currency_type: String = "credits"  # Which currency NPC accepts

# Stock
@export var stock_type: StockType = StockType.UNLIMITED
@export var initial_stock: int = -1  # -1 = unlimited, >0 = limited stock
@export var current_stock: int = -1  # Runtime: current stock (-1 = unlimited)
@export var restock_time: float = 0.0  # Time in seconds to restock (0 = never restocks)

enum StockType {
    UNLIMITED,      # Always available
    LIMITED,        # Limited stock, restocks over time
    ONE_TIME,       # Can only buy once
    ROTATING        # Rotates in/out of shop
}

# Availability
@export var relationship_requirement: int = 0  # Minimum relationship level to see/buy
@export var unlock_condition: String = ""  # Custom unlock condition ID

# Barter
@export var accepts_barter: bool = true  # Can use items to reduce price
@export var accepted_tags: Array[String] = []  # Item tags NPC accepts for barter
```

### NPCShopData

```gdscript
class_name NPCShopData
extends Resource

# Shop Identification
@export var shop_id: String  # Unique shop ID
@export var npc_id: String  # NPC ID this shop belongs to
@export var shop_name: String  # Display name

# Shop Items
@export var core_items: Array[ShopItem] = []  # Always available items
@export var rotating_items: Array[ShopItem] = []  # Items that rotate
@export var relationship_items: Dictionary = {}  # relationship_level -> Array[ShopItem]

# Pricing Configuration
@export var relationship_price_multiplier: Dictionary = {}  # relationship_level -> multiplier
# Example: {0: 1.0, 1: 0.95, 2: 0.90} = 5% discount per level
@export var supply_demand_factor: float = 0.1  # How much supply/demand affects price (0.1 = 10% max change)

# Barter Configuration
@export var accepts_barter: bool = true  # Shop accepts barter
@export var accepted_tags: Array[String] = []  # Tags NPC accepts for barter
@export var barter_value_multiplier: float = 0.8  # Items worth 80% of their value in barter

# Rotating Inventory
@export var rotation_schedule: String = "daily"  # "daily", "weekly", "hourly"
@export var rotation_seed: int = 0  # Seed for rotation (ensures consistency)

# State (Runtime)
var last_rotation_time: float = 0.0
var current_rotating_items: Array[ShopItem] = []
var price_history: Dictionary = {}  # item_id -> Array[price_history_entry]
var supply_demand_data: Dictionary = {}  # item_id -> {sold: int, bought: int}
```

### TradeTransaction

```gdscript
class_name TradeTransaction
extends RefCounted

var shop_id: String
var npc_id: String
var items_to_buy: Array[Dictionary] = []  # [{item_id: String, quantity: int}]
var items_to_sell: Array[Dictionary] = []  # [{item_id: String, quantity: int}]
var currency_to_pay: Dictionary = {}  # currency_id -> amount
var total_cost: Dictionary = {}  # currency_id -> total cost after barter
var relationship_bonus: float = 1.0  # Price multiplier from relationship
var supply_demand_adjustment: float = 1.0  # Price multiplier from supply/demand
```

---

## Core Classes

### TradingManager (Autoload Singleton)

```gdscript
class_name TradingManager
extends Node

# Shop Registry
var shops: Dictionary = {}  # shop_id -> NPCShopData
var shops_by_npc: Dictionary = {}  # npc_id -> NPCShopData

# Trading State
var current_shop: NPCShopData = null
var current_npc: Node = null
var is_trading: bool = false

# References
var inventory_manager: InventoryManager
var relationship_manager: RelationshipManager
var item_database: ItemDatabase

# Configuration
const DEFAULT_BARTER_VALUE_MULTIPLIER: float = 0.8
const PRICE_HISTORY_SIZE: int = 100  # Keep last 100 prices per item

# Signals
signal trade_started(shop_id: String, npc_id: String)
signal trade_completed(transaction: TradeTransaction)
signal trade_cancelled()
signal shop_inventory_updated(shop_id: String)
signal price_changed(item_id: String, old_price: int, new_price: int)

# Initialization
func _ready() -> void
func initialize() -> void

# Shop Management
func register_shop(shop_data: NPCShopData) -> bool
func get_shop(shop_id: String) -> NPCShopData
func get_shop_by_npc(npc_id: String) -> NPCShopData
func has_shop(shop_id: String) -> bool

# Trading Operations
func start_trade(shop_id: String, npc: Node) -> bool
func start_trade_by_npc(npc_id: String, npc: Node) -> bool
func cancel_trade() -> void
func complete_trade(transaction: TradeTransaction) -> bool

# Price Calculation
func calculate_item_price(shop: NPCShopData, item_id: String) -> int
func calculate_barter_value(item_id: String, shop: NPCShopData) -> int
func get_price_with_relationship(shop: NPCShopData, item_id: String, relationship_level: int) -> int
func get_price_with_supply_demand(shop: NPCShopData, item_id: String) -> int

# Shop Inventory
func get_available_items(shop: NPCShopData, relationship_level: int) -> Array[ShopItem]
func update_rotating_inventory(shop: NPCShopData) -> void
func restock_shop(shop: NPCShopData) -> void

# Supply/Demand Tracking
func record_purchase(shop: NPCShopData, item_id: String, quantity: int) -> void
func record_sale(shop: NPCShopData, item_id: String, quantity: int) -> void
func get_supply_demand_factor(shop: NPCShopData, item_id: String) -> float

# Barter Validation
func can_barter_item(item_id: String, shop: NPCShopData) -> bool
func get_barter_items_in_inventory(shop: NPCShopData) -> Array[Dictionary]  # Returns items player can barter
```

---

## System Architecture

### Component Hierarchy

```
TradingManager (Autoload Singleton)
├── NPCShopData[] (Dictionary)
│   ├── ShopItem[] (Core Items)
│   ├── ShopItem[] (Rotating Items)
│   └── ShopItem[] (Relationship Items)
├── Price History (Dictionary)
├── Supply/Demand Data (Dictionary)
└── UI/TradingUI (Control)
    ├── QuickTradeMenu (Control)
    └── FullShopMenu (Control)
        ├── ItemList (ItemList)
        ├── BarterSlot (Control)
        └── CurrencyDisplay (Control)
```

### Data Flow

1. **Starting Trade:**
   ```
   Player interacts with NPC
   ├── TradingManager.start_trade(shop_id, npc)
   ├── Load shop inventory (core + rotating + relationship items)
   ├── Calculate current prices (relationship + supply/demand)
   ├── Open trading UI
   └── trade_started.emit(shop_id, npc_id)
   ```

2. **Price Calculation:**
   ```
   Calculate item price
   ├── Get base_price from ShopItem
   ├── Apply relationship multiplier
   ├── Apply supply/demand adjustment
   ├── Clamp to min_price/max_price
   └── Return final price
   ```

3. **Completing Trade:**
   ```
   Player confirms trade
   ├── Validate transaction (can afford, items available)
   ├── Calculate total cost (currency + barter items)
   ├── Remove currency from inventory
   ├── Remove barter items from inventory
   ├── Add purchased items to inventory
   ├── Update supply/demand data
   ├── Update price history
   ├── Record transaction
   └── trade_completed.emit(transaction)
   ```

---

## Algorithms

### Price Calculation Algorithm

```gdscript
func calculate_item_price(shop: NPCShopData, item_id: String) -> int:
    var shop_item = get_shop_item(shop, item_id)
    if shop_item == null:
        return 0
    
    # Start with base price
    var price: float = shop_item.base_price
    
    # Apply relationship multiplier
    var relationship_level = relationship_manager.get_relationship_level(shop.npc_id)
    var relationship_mult = shop.relationship_price_multiplier.get(relationship_level, 1.0)
    price *= relationship_mult
    
    # Apply supply/demand adjustment
    var supply_demand_factor = get_supply_demand_factor(shop, item_id)
    price *= (1.0 + supply_demand_factor * shop.supply_demand_factor)
    
    # Clamp to min/max
    price = clamp(price, shop_item.min_price, shop_item.max_price)
    
    # Round to nearest integer
    return int(round(price))

func get_supply_demand_factor(shop: NPCShopData, item_id: String) -> float:
    # Returns -1.0 to 1.0 (negative = high supply/low demand, positive = low supply/high demand)
    if not shop.supply_demand_data.has(item_id):
        return 0.0
    
    var data = shop.supply_demand_data[item_id]
    var sold = data.get("sold", 0)
    var bought = data.get("bought", 0)
    
    # More sold = lower price (negative factor)
    # More bought = higher price (positive factor)
    var net_transactions = bought - sold
    
    # Normalize to -1.0 to 1.0 range
    var max_transactions = 100.0  # Configurable threshold
    return clamp(net_transactions / max_transactions, -1.0, 1.0)
```

### Barter Value Calculation Algorithm

```gdscript
func calculate_barter_value(item_id: String, shop: NPCShopData) -> int:
    # Check if item can be bartered
    if not can_barter_item(item_id, shop):
        return 0
    
    # Get item data
    var item_data = item_database.get_item(item_id)
    if item_data == null:
        return 0
    
    # Calculate base value (use item's base_value or sell price)
    var base_value = item_data.base_value
    if base_value <= 0:
        # Fallback: estimate from item type/rarity
        base_value = estimate_item_value(item_data)
    
    # Apply barter multiplier (items worth less in barter)
    var barter_value = base_value * shop.barter_value_multiplier
    
    return int(round(barter_value))

func can_barter_item(item_id: String, shop: NPCShopData) -> bool:
    if not shop.accepts_barter:
        return false
    
    var item_data = item_database.get_item(item_id)
    if item_data == null:
        return false
    
    # Check if item has any accepted tags
    for tag in shop.accepted_tags:
        if tag in item_data.tags:
            return true
    
    return false
```

### Trade Transaction Algorithm

```gdscript
func complete_trade(transaction: TradeTransaction) -> bool:
    if not is_trading:
        return false
    
    var shop = get_shop(transaction.shop_id)
    if shop == null:
        return false
    
    # Validate transaction
    if not validate_transaction(transaction, shop):
        return false
    
    # Calculate total cost
    var total_cost = calculate_total_cost(transaction, shop)
    
    # Check if player can afford
    if not can_afford_transaction(total_cost, transaction.items_to_sell):
        return false
    
    # Remove currency from inventory
    for currency_id in total_cost:
        var amount = total_cost[currency_id]
        inventory_manager.remove_currency(currency_id, amount)
    
    # Remove barter items from inventory
    for item_sale in transaction.items_to_sell:
        var item_id = item_sale["item_id"]
        var quantity = item_sale["quantity"]
        inventory_manager.remove_item(item_id, quantity)
    
    # Add purchased items to inventory
    for item_purchase in transaction.items_to_buy:
        var item_id = item_purchase["item_id"]
        var quantity = item_purchase["quantity"]
        var shop_item = get_shop_item(shop, item_id)
        
        # Update stock if limited
        if shop_item.stock_type == ShopItem.StockType.LIMITED:
            shop_item.current_stock -= quantity
            if shop_item.current_stock <= 0:
                shop_item.current_stock = 0
        
        # Add items to inventory
        for i in range(quantity):
            var item_instance = item_database.create_item_instance(item_id)
            inventory_manager.add_item(item_instance)
    
    # Update supply/demand data
    for item_purchase in transaction.items_to_buy:
        record_purchase(shop, item_purchase["item_id"], item_purchase["quantity"])
    
    # Update price history
    update_price_history(shop, transaction)
    
    # Emit signal
    trade_completed.emit(transaction)
    
    # Close trade
    is_trading = false
    current_shop = null
    current_npc = null
    
    return true

func calculate_total_cost(transaction: TradeTransaction, shop: NPCShopData) -> Dictionary:
    var total_cost: Dictionary = {}  # currency_id -> amount
    
    # Calculate cost for each item to buy
    for item_purchase in transaction.items_to_buy:
        var item_id = item_purchase["item_id"]
        var quantity = item_purchase["quantity"]
        var price = calculate_item_price(shop, item_id)
        var shop_item = get_shop_item(shop, item_id)
        var currency_id = shop_item.currency_type
        
        if not total_cost.has(currency_id):
            total_cost[currency_id] = 0
        
        total_cost[currency_id] += price * quantity
    
    # Subtract barter value
    var barter_value: Dictionary = {}  # currency_id -> value
    for item_sale in transaction.items_to_sell:
        var item_id = item_sale["item_id"]
        var quantity = item_sale["quantity"]
        var value = calculate_barter_value(item_id, shop)
        var shop_item = get_shop_item(shop, item_id)
        var currency_id = shop_item.currency_type
        
        if not barter_value.has(currency_id):
            barter_value[currency_id] = 0
        
        barter_value[currency_id] += value * quantity
    
    # Apply barter value to total cost
    for currency_id in barter_value:
        if total_cost.has(currency_id):
            total_cost[currency_id] = max(0, total_cost[currency_id] - barter_value[currency_id])
    
    return total_cost
```

### Rotating Inventory Algorithm

```gdscript
func update_rotating_inventory(shop: NPCShopData) -> void:
    if shop.rotation_schedule == "":
        return
    
    var current_time = Time.get_unix_time_from_system()
    var time_since_rotation = current_time - shop.last_rotation_time
    
    # Check if rotation needed
    var rotation_interval: float = 0.0
    match shop.rotation_schedule:
        "hourly":
            rotation_interval = 3600.0
        "daily":
            rotation_interval = 86400.0
        "weekly":
            rotation_interval = 604800.0
    
    if time_since_rotation < rotation_interval:
        return  # Not time to rotate yet
    
    # Rotate items
    var rng = RandomNumberGenerator.new()
    rng.seed = hash(shop.rotation_seed) + int(current_time / rotation_interval)
    
    # Select random items from rotating pool
    var items_to_show = min(shop.rotating_items.size(), 5)  # Show up to 5 rotating items
    shop.current_rotating_items.clear()
    
    var available_items = shop.rotating_items.duplicate()
    for i in range(items_to_show):
        if available_items.is_empty():
            break
        
        var index = rng.randi() % available_items.size()
        shop.current_rotating_items.append(available_items[index])
        available_items.remove_at(index)
    
    shop.last_rotation_time = current_time
    shop_inventory_updated.emit(shop.shop_id)
```

---

## Integration Points

### With Inventory System

```gdscript
# Currency Management
func remove_currency(currency_id: String, amount: int) -> bool:
    return inventory_manager.remove_currency(currency_id, amount)

func get_currency_amount(currency_id: String) -> int:
    return inventory_manager.get_currency_amount(currency_id)

# Item Management
func add_item_to_inventory(item_instance: ItemData) -> bool:
    return inventory_manager.add_item(item_instance)

func remove_item_from_inventory(item_id: String, quantity: int) -> int:
    return inventory_manager.remove_item(item_id, quantity)
```

### With Relationship System

```gdscript
# Get relationship level for pricing
func get_relationship_level(npc_id: String) -> int:
    return relationship_manager.get_relationship_level(npc_id)

# Get available items based on relationship
func get_available_items(shop: NPCShopData, relationship_level: int) -> Array[ShopItem]:
    var available: Array[ShopItem] = []
    
    # Core items (always available)
    available.append_array(shop.core_items)
    
    # Rotating items
    available.append_array(shop.current_rotating_items)
    
    # Relationship items
    for level in shop.relationship_items:
        if relationship_level >= level:
            available.append_array(shop.relationship_items[level])
    
    return available
```

### With Item Database

```gdscript
# Validate items exist
func validate_shop_item(shop_item: ShopItem) -> bool:
    return item_database.has_item(shop_item.item_id)

# Get item data for display
func get_item_display_data(item_id: String) -> ItemData:
    return item_database.get_item(item_id)

# Check item tags for barter
func item_has_tag(item_id: String, tag: String) -> bool:
    var item_data = item_database.get_item(item_id)
    if item_data == null:
        return false
    return tag in item_data.tags
```

---

## Save/Load System

### Save Data Structure

```gdscript
var trading_save_data: Dictionary = {
    "shops": serialize_shops(),
    "price_history": serialize_price_history(),
    "supply_demand_data": serialize_supply_demand(),
    "last_rotation_times": serialize_rotation_times()
}

func serialize_shops() -> Dictionary:
    var shops_data: Dictionary = {}
    for shop_id in shops:
        var shop = shops[shop_id]
        shops_data[shop_id] = {
            "current_stock": serialize_shop_stock(shop),
            "last_rotation_time": shop.last_rotation_time,
            "current_rotating_items": serialize_rotating_items(shop)
        }
    return shops_data

func serialize_price_history() -> Dictionary:
    var history_data: Dictionary = {}
    for shop_id in shops:
        var shop = shops[shop_id]
        history_data[shop_id] = shop.price_history
    return history_data

func serialize_supply_demand() -> Dictionary:
    var supply_demand_data: Dictionary = {}
    for shop_id in shops:
        var shop = shops[shop_id]
        supply_demand_data[shop_id] = shop.supply_demand_data
    return supply_demand_data
```

### Load Data Structure

```gdscript
func load_trading_data(data: Dictionary) -> void:
    if data.has("shops"):
        load_shops(data["shops"])
    if data.has("price_history"):
        load_price_history(data["price_history"])
    if data.has("supply_demand_data"):
        load_supply_demand(data["supply_demand_data"])
    if data.has("last_rotation_times"):
        load_rotation_times(data["last_rotation_times"])
```

---

## Error Handling

### TradingManager Error Handling

- **Invalid Shop IDs:** Check shop exists before operations, return errors gracefully
- **Missing Currency:** Validate player has enough currency before trade
- **Out of Stock:** Check stock availability before allowing purchase
- **Invalid Items:** Validate items exist in ItemDatabase before trading
- **Relationship Changes:** Handle relationship changes during trade gracefully

### Best Practices

- Use `push_error()` for critical errors (invalid shop_id, missing currency)
- Use `push_warning()` for non-critical issues (out of stock, can't afford)
- Return false/null on errors (don't crash)
- Validate all inputs before operations
- Refund items if trade fails partway through

---

## Default Values and Configuration

### TradingManager Defaults

```gdscript
DEFAULT_BARTER_VALUE_MULTIPLIER = 0.8
PRICE_HISTORY_SIZE = 100
DEFAULT_SUPPLY_DEMAND_FACTOR = 0.1
DEFAULT_ROTATION_INTERVAL = 86400.0  # 1 day
```

### ShopItem Defaults

```gdscript
base_price = 100
min_price = 10
max_price = 10000
stock_type = StockType.UNLIMITED
initial_stock = -1
current_stock = -1
restock_time = 0.0
relationship_requirement = 0
accepts_barter = true
accepted_tags = []
```

### NPCShopData Defaults

```gdscript
relationship_price_multiplier = {0: 1.0, 1: 0.95, 2: 0.90, 3: 0.85, 4: 0.80}
supply_demand_factor = 0.1
accepts_barter = true
barter_value_multiplier = 0.8
rotation_schedule = "daily"
```

---

## Performance Considerations

### Optimization Strategies

1. **Price Calculation:**
   - Cache calculated prices (invalidate on relationship/supply change)
   - Limit price calculations per frame for UI updates
   - Batch price updates when possible

2. **Shop Inventory:**
   - Load shop data at startup (eager loading)
   - Cache available items list (invalidate on relationship change)
   - Update rotating inventory only when needed

3. **Supply/Demand Tracking:**
   - Limit history size to prevent memory issues
   - Aggregate data periodically (not every transaction)
   - Use efficient data structures

4. **Barter Validation:**
   - Cache barter-able items list
   - Update only when inventory changes
   - Use tag-based filtering efficiently

---

## Testing Checklist

### Trading System
- [ ] Shops register correctly
- [ ] Price calculation works (relationship + supply/demand)
- [ ] Barter system works correctly
- [ ] Currency removal/addition works
- [ ] Stock management works (limited stock, restocking)
- [ ] Rotating inventory updates correctly

### Price System
- [ ] Relationship affects prices correctly
- [ ] Supply/demand affects prices correctly
- [ ] Price clamping works (min/max)
- [ ] Price history tracks correctly
- [ ] Price updates when relationship changes

### Barter System
- [ ] Tag-based item acceptance works
- [ ] Barter value calculation correct
- [ ] Barter reduces cost correctly
- [ ] Items removed from inventory correctly
- [ ] Invalid items rejected correctly

### Integration
- [ ] Integrates with Inventory System correctly
- [ ] Integrates with Relationship System correctly
- [ ] Integrates with Item Database correctly
- [ ] UI updates correctly on trade
- [ ] Save/load works correctly

---

## Complete Implementation

### TradingManager Initialization

```gdscript
func _ready() -> void:
    # Get references
    inventory_manager = get_node_or_null("/root/InventoryManager")
    relationship_manager = get_node_or_null("/root/RelationshipManager")
    item_database = get_node_or_null("/root/ItemDatabase")
    
    # Initialize
    initialize()

func initialize() -> void:
    # Load all shop data
    load_all_shops()
    
    # Initialize rotation times
    for shop_id in shops:
        var shop = shops[shop_id]
        if shop.last_rotation_time == 0.0:
            shop.last_rotation_time = Time.get_unix_time_from_system()
    
    # Update rotating inventories
    for shop_id in shops:
        update_rotating_inventory(shops[shop_id])

func load_all_shops() -> void:
    var shop_dir = DirAccess.open("res://resources/shops/")
    if shop_dir:
        shop_dir.list_dir_begin()
        var file_name = shop_dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var shop_data = load("res://resources/shops/" + file_name) as NPCShopData
                if shop_data:
                    register_shop(shop_data)
            file_name = shop_dir.get_next()
```

---

## Setup Instructions

### Project Setup

1. **Create Directory Structure:**
   ```
   res://
   ├── resources/
   │   ├── shops/
   │   │   └── (shop resource files)
   │   └── currency/
   │       └── (currency item resource files)
   └── scripts/
       └── managers/
           └── TradingManager.gd
   ```

2. **Setup Autoload Singleton:**
   - **Project > Project Settings > Autoload:**
   - Add `scripts/managers/TradingManager.gd` as `TradingManager`
   - **Important:** Load after ItemDatabase, InventoryManager, and RelationshipManager

3. **Create Shop Resources:**
   - Right-click in `res://resources/shops/`
   - Select "New Resource" → "NPCShopData"
   - Fill in shop_id, npc_id, core_items, rotating_items, etc.
   - Save as `{shop_id}.tres`

4. **Create Currency Resources:**
   - Right-click in `res://resources/currency/`
   - Select "New Resource" → "CurrencyItem"
   - Fill in currency_id, currency_name, base_value, etc.
   - Register in ItemDatabase

### Initialization Order

**Autoload Order:**
1. GameManager
2. ItemDatabase
3. InventoryManager
4. RelationshipManager
5. **TradingManager** (after all dependencies)

---

## Tools and Resources

**Note:** Only tools/resources that will be actively used for implementing Trading/Economy System are listed here.

### Godot Documentation (Required)

**Required for:** Implementation reference

**Official Godot 4 Documentation:**
- **Resources:** https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- **Signals:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **Autoload Singletons:** https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
- **Dictionary:** https://docs.godotengine.org/en/stable/classes/class_dictionary.html

**Status:** Will be referenced during implementation

---

## References

**Note:** These references are specifically for implementing Trading/Economy System. All links are to official Godot 4 documentation.

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
- NPCShopData is a Resource (can be created/edited in inspector)
- ShopItem is a Resource (can be created/edited in inspector)
- CurrencyItem is a Resource (can be created/edited in inspector)
- Shop properties editable in inspector

**Visual Configuration:**
- Shop inventory editable in inspector
- Price multipliers configurable in inspector
- Barter tags configurable in inspector

**Editor Tools Needed:**
- **None Required:** Standard Godot Resource system provides all needed editor support
- **Optional Future Enhancement:** Custom editor plugin could provide:
  - Shop inventory visual editor
  - Price calculation preview
  - Barter value calculator

**Current Approach:**
- Uses Godot's native Resource system (no custom tools needed)
- Shops created as Resource files (editable in inspector)
- Fully functional without custom editor tools

---

## Implementation Notes

1. **Currency System:** Currency items stored in dedicated inventory slot (like Terraria)
2. **Dynamic Pricing:** Prices calculated from base_price * relationship_mult * (1 + supply_demand_factor)
3. **Barter System:** Items reduce purchase cost based on their value * barter_multiplier
4. **Tag-Based Acceptance:** NPCs accept items with specific tags for barter
5. **Rotating Inventory:** Items rotate on schedule (daily/weekly/hourly)
6. **Relationship Items:** Higher-tier items unlock with better relationship
7. **Price History:** Tracks price changes to prevent exploitation
8. **Supply/Demand:** Tracks purchases/sales to adjust prices dynamically

