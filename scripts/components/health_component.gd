# scripts/components/health_component.gd
# Connected now to player script via signal
# Connected now in inventory system via var health := get_tree().get_first_node_in_group("health_system") in use_item()

# Enemies Attack Area Zone or projectile not connected yet
# Bali, the player can now be inflicted with damage but there are NO damage sources yet

# CHANGED: int and hp, mahal ang float
class_name HealthComponents
extends Node

signal died()
signal health_changed(current: int, maximum: int)

@export var max_hp: int = 100
var current_hp: int = 0

func _ready() -> void:
	add_to_group("health_system")
	current_hp = max_hp
	
# Initialize from Player's HP
func initialize(starting_hp: int) -> void:
	max_hp = starting_hp
	current_hp = starting_hp
	health_changed.emit(current_hp, max_hp)
	
func take_damage(amount: int) -> void:
	if current_hp <= 0: return
	current_hp = max(current_hp - amount, 0)
	health_changed.emit(current_hp, max_hp)
	if current_hp <= 0: died.emit()
	
func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)
	health_changed.emit(current_hp, max_hp)
	
func is_dead() -> bool:
	return current_hp <= 0
	
func get_current_hp() -> int:
	return current_hp
