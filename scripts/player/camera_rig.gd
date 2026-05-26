class_name CameraRig extends Node3D

@export var camera_offset: Vector3 = Vector3(7, 13, 7)
@export var lerp_speed: float = 8.0

@onready var _camera: Camera3D = $Camera3D

var _target: Node3D = null


func _ready() -> void:
	_camera.position = camera_offset
	call_deferred("_find_player")


func set_target(target: Node3D) -> void:
	_target = target
	if _target:
		global_position = _target.global_position


func _process(delta: float) -> void:
	if not _target:
		return
	var goal := _target.global_position
	goal.y = 0.0
	global_position = global_position.lerp(goal, lerp_speed * delta)
	_camera.look_at(global_position, Vector3.UP)


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		set_target(players[0] as Node3D)
