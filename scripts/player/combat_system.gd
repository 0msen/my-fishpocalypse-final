class_name CombatSystem extends Node

signal fired(weapon: FishWeaponData)
signal dodged()
signal weapon_swapped(weapon: FishWeaponData)

@export var dodge_sp_cost := 25

@onready var _player: CharacterBody3D = get_parent().get_parent()
@onready var _inventory := get_tree().get_first_node_in_group("inventory_system")
@onready var _buffs := get_tree().get_first_node_in_group("buff_system")

const CP_MAX := 100
const SP_MAX := 100

var _equipped_weapon_node: Weapon = null
var _shot_delay_timer: float = 0.0

var is_dodging := false
var dodge_timer := 0.0
var dodge_dir := Vector3.ZERO

var _cp_regen_accum := 0.0
var _sp_regen_accum := 0.0


func _ready() -> void:
	# FIX: _on_equipped_weapon_changed is now implemented — this signal is still
	# useful if CombatSystem ever needs to react to data-only changes.
	_inventory.equipped_weapon_changed.connect(_on_equipped_weapon_changed)


func _process(delta: float) -> void:
	if _shot_delay_timer > 0.0: _shot_delay_timer -= delta
	if is_dodging:
		dodge_timer -= delta
		if dodge_timer <= 0.0: _end_dodge()

	if Input.is_action_just_pressed("SHOOT"): fire()
	if Input.is_action_just_pressed("DODGE"): dodge()

	if Input.is_action_just_pressed("PRIMARY"):
		_inventory.set_active_weapon_slot("main_slot")
	if Input.is_action_just_pressed("SECONDARY"):
		_inventory.set_active_weapon_slot("secondary_slot")
	if Input.is_action_just_pressed("ITEM1"):
		_inventory.use_item("item_slot_1")
	if Input.is_action_just_pressed("ITEM2"):
		_inventory.use_item("item_slot_2")

	_handle_regen(delta)


# COMBAT -----------------------------------------------------------------------

func fire() -> void:
	if _equipped_weapon_node == null or _shot_delay_timer > 0.0: return
	var data: FishWeaponData = _equipped_weapon_node.data
	if data == null: return
	if _player.CP < data.base_recharge_cost: return

	var shot_delay: float = float(data.base_shot_delay) * float(
		_buffs.get_multiplier(BuffData.StatTarget.SHOT_DELAY) if _buffs else 1.0
	)

	_shot_delay_timer = shot_delay
	_player.deduct_cp(data.base_recharge_cost)
	_player.block_cp_recharge(shot_delay)
	# FIX: pass the player's actual facing direction so projectiles go the right way
	_equipped_weapon_node.shoot(_player.get_facing_dir())
	fired.emit(data)


func dodge() -> void:
	if _player.SP < dodge_sp_cost or is_dodging: return
	var move_dir := Vector3(_player.velocity.x, 0.0, _player.velocity.z).normalized()
	_player.deduct_sp(dodge_sp_cost)
	is_dodging = true
	dodge_timer = _player.dodge_time
	dodge_dir = move_dir
	_player.start_dodge(dodge_dir)
	_player._play_dodge_sound()
	dodged.emit()


func _end_dodge() -> void:
	is_dodging = false
	dodge_timer = 0.0
	_player.end_dodge()


# WEAPON HANDLING --------------------------------------------------------------

func equip_weapon_node(weapon_node: Weapon) -> void:
	if _equipped_weapon_node == weapon_node: return
	if _equipped_weapon_node:
		_equipped_weapon_node.deactivate()
	_equipped_weapon_node = weapon_node
	if weapon_node:
		# FIX: weapon_node is already in the scene tree (added by Player.equip_weapon)
		# so @onready vars inside Weapon are valid here.
		weapon_node.activate()
		weapon_swapped.emit(weapon_node.data)

# FIX: signature matches the updated signal — Weapon node, not FishWeaponData
func _on_equipped_weapon_changed(_weapon_node: Weapon) -> void:
	# Player.gd handles the actual node swap.
	# Add any CombatSystem-specific reactions here if needed later.
	pass


# REGEN SYSTEM -----------------------------------------------------------------

func _handle_regen(delta: float) -> void:
	if _player == null: return
	if not _player.cp_recharge_blocked and _player.CP < CP_MAX:
		_cp_regen_accum += _player.RR_CP * delta
		if _cp_regen_accum >= 1.0:
			var amount := int(_cp_regen_accum)
			_cp_regen_accum -= amount
			_player.CP = mini(_player.CP + amount, CP_MAX)
	if not is_dodging and _player.SP < SP_MAX:
		_sp_regen_accum += _player.RR_SP * delta
		if _sp_regen_accum >= 1.0:
			var amount := int(_sp_regen_accum)
			_sp_regen_accum -= amount
			_player.SP = mini(_player.SP + amount, SP_MAX)


# DODGE GHOST ------------------------------------------------------------------

const _GHOST_SCRIPT = preload("res://scripts/player/dodge_ghost.gd")

func spawn_dodge_ghost() -> void:
	var ghost := Node3D.new()
	ghost.set_script(_GHOST_SCRIPT)
	get_tree().current_scene.add_child(ghost)
	ghost.global_position = _player.global_position
	ghost.global_rotation = _player.global_rotation
	ghost.setup(_player.anim, _player.anim.frame)
