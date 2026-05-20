class_name InventorySystem extends Node

signal equipped_weapon_changed(weapon: FishWeaponData)
signal equipped_pole_changed(pole: FishingPoleData)
signal item_picked_up(item: Resource)
signal item_used(item: HealingItemData, heal_amount: float)
signal inventory_changed()

@export var items_db: ItemsDB

var equipped_weapon: FishWeaponData = null
var equipped_pole: FishingPoleData = null
var healing_items: Dictionary = {}    # HealingItemData -> stack count
var weapons: Array[FishWeaponData] = []
var poles: Array[FishingPoleData] = []


func _ready() -> void:
	# Auto-equip first pole so FishingSystem always gets one
	if items_db and not items_db.fishing_poles.is_empty():
		_equip_pole(items_db.fishing_poles[0])


func pickup(item: Resource) -> void:
	if item is FishWeaponData:    _add_weapon(item)
	elif item is HealingItemData: _add_healing_item(item)
	elif item is FishingPoleData: _add_pole(item)
	item_picked_up.emit(item)
	inventory_changed.emit()


func get_equipped_pole() -> FishingPoleData:
	return equipped_pole


func cycle_weapon(direction: int) -> void:
	if weapons.is_empty():
		return
	var idx := weapons.find(equipped_weapon)
	idx = (idx + direction) % weapons.size()
	_equip_weapon(weapons[idx])


func use_healing_item() -> void:
	if healing_items.is_empty():
		return
	var item: HealingItemData = healing_items.keys()[0]
	var heal_amount := item.base_heal_amount * item.rarity.heal_multiplier
	healing_items[item] -= 1
	if healing_items[item] <= 0:
		healing_items.erase(item)
	item_used.emit(item, heal_amount)
	inventory_changed.emit()


func _add_weapon(w: FishWeaponData) -> void:
	weapons.append(w)
	if equipped_weapon == null:
		_equip_weapon(w)


func _add_healing_item(h: HealingItemData) -> void:
	var current: int = healing_items.get(h, 0)
	healing_items[h] = mini(current + 1, h.stack_limit)


func _add_pole(p: FishingPoleData) -> void:
	poles.append(p)
	if equipped_pole == null:
		_equip_pole(p)


func _equip_pole(p: FishingPoleData) -> void:
	equipped_pole = p
	equipped_pole_changed.emit(p)


func _equip_weapon(w: FishWeaponData) -> void:
	equipped_weapon = w
	equipped_weapon_changed.emit(w)
