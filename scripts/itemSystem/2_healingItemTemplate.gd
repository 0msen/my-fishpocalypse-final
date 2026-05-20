extends Node3D
class_name HealingItemTemplate

@export var dbg: bool
@export var data: HealingItemData
var rarity: RarityTier

@onready var sprite: Sprite3D = $Sprite3D
@onready var audio: AudioStreamPlayer3D = $ConsumeSound
@onready var timer: Timer = $Timer

# Data injector to make health items
func setup(new_data: HealingItemData, rolled_rarity: RarityTier):
	data = new_data
	rarity = rolled_rarity
	apply_data()
	
func apply_data():
	if data == null:
		push_warning("HealingItem: data is null")
		return
	
	if sprite: sprite.texture = data.sprite if data.sprite else null
	else: push_warning("HealingItem: Sprite3D node missing")
		
	if timer:
		timer.wait_time = data.use_delay * (rarity.heal_multiplier if rarity else 1.0)
		timer.one_shot = true
	else:
		push_warning("HealingItem: Timer node missing")
	

# Placeholder for healing mechanic - needs to be changed according to design
# obselete if player doesnt have heal function
func use(target):
	if data == null or rarity == null:
		if dbg: push_error("HealingItem: Cannot use - data or rarity is null")
		return

	if not timer.is_stopped(): return
		
	timer.start()
	var heal_amount := data.base_heal_amount * (rarity.heal_multiplier if rarity else 1.0)
	if target.has_method("heal"): target.heal(heal_amount)
	if audio: audio.play()
	
func get_final_heal() -> float:
	if data == null: return 0.0
	return data.base_heal_amount * (rarity.heal_multiplier if rarity else 1.0)
