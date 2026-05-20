extends Node3D
class_name PoleTemplate

signal fish_bite
signal fish_caught
signal cast_started
signal line_broke

@export var dbg: bool
@export var data: FishingPoleData
var rarity: RarityTier

@onready var sprite: AnimatedSprite3D = $Sprite3D
@onready var hook: Marker3D = $Hook
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var timer: Timer = $Timer


func setup(new_data: FishingPoleData, rolled_rarity: RarityTier):
	data = new_data
	rarity = rolled_rarity
	apply_data()
	
func apply_data():
	if data == null:
		push_warning("PoleTemplate: data is null")
		return

	if sprite: sprite.sprite_frames = data.sprite if data.sprite else null
	else: push_warning("PoleTemplate: AnimatedSprite3D node missing")
