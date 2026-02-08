# 物品数据资源
# 定义游戏中所有可拾取物品的属性

class_name ItemData
extends Resource

enum ItemType { WEAPON, ARMOR, CONSUMABLE, MATERIAL }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var type: ItemType = ItemType.MATERIAL
@export var rarity: Rarity = Rarity.COMMON
@export var weight: float = 1.0
@export var value: int = 100

# 武器属性
@export_group("Weapon Stats")
@export var damage: int = 0
@export var range: float = 0.0

# 防具属性
@export_group("Armor Stats")
@export var defense: int = 0

func _to_string() -> String:
	return "Item[%s: %s]" % [id, name]
