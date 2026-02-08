# 背包系统
# 管理玩家物品存储

class_name Inventory
extends RefCounted

signal item_added(item: ItemData)
signal item_removed(item: ItemData)
signal inventory_changed

const MAX_SLOTS = 20
const MAX_WEIGHT = 50.0

var slots: Array[ItemData] = []
var current_weight: float = 0.0

# 添加物品
func add_item(item: ItemData) -> bool:
    if slots.size() >= MAX_SLOTS:
        print("[Inventory] 背包已满")
        return false
    
    if current_weight + item.weight > MAX_WEIGHT:
        print("[Inventory] 负重超限")
        return false
    
    slots.append(item)
    current_weight += item.weight
    item_added.emit(item)
    inventory_changed.emit()
    print("[Inventory] 添加物品:", item.name)
    return true

# 移除物品
func remove_item(index: int) -> ItemData:
    if index < 0 or index >= slots.size():
        return null
    
    var item = slots[index]
    slots.remove_at(index)
    current_weight -= item.weight
    item_removed.emit(item)
    inventory_changed.emit()
    print("[Inventory] 移除物品:", item.name)
    return item

# 获取物品
func get_item(index: int) -> ItemData:
    if index < 0 or index >= slots.size():
        return null
    return slots[index]

# 清空背包
func clear():
    slots.clear()
    current_weight = 0.0
    inventory_changed.emit()

# 检查是否有空位
func has_space() -> bool:
    return slots.size() < MAX_SLOTS

# 检查负重
func can_carry(weight: float) -> bool:
    return current_weight + weight <= MAX_WEIGHT

# 序列化
func to_dict() -> Dictionary:
    var items = []
    for item in slots:
        items.append({"id": item.id})
    
    return {
        "items": items,
        "weight": current_weight
    }

# 反序列化
func from_dict(data: Dictionary, item_database: Dictionary):
    slots.clear()
    for item_data in data.get("items", []):
        var item_id = item_data.get("id", "")
        if item_database.has(item_id):
            slots.append(item_database[item_id])
    current_weight = data.get("weight", 0.0)
    inventory_changed.emit()
