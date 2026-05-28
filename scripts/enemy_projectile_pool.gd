# projectile_pool.gd
extends Node

@export var max_projectiles: int = 40

var _pool: Array[Node]     = []
var _free_list: Array[int] = []
var current_count: int     = 0
var _scene: PackedScene
var _built: bool           = false  # guards against double-build during deferred frame

func init_pool(scene: PackedScene) -> void:
	if _built or not _pool.is_empty(): return
	_built  = true
	_scene  = scene
	_pool.resize(max_projectiles)
	# defer the actual add_child calls; tree is locked during _ready chain
	_build_deferred.call_deferred()

func _build_deferred() -> void:
	for i in max_projectiles:
		var inst: Node = _scene.instantiate()
		inst.set_process(false)
		inst.visible = false
		inst.add_to_group(&"enemy_projectile")
		get_tree().current_scene.add_child(inst)
		inst.set_meta(&"pool_idx", i)
		_pool[i] = inst
		_free_list.append(i)
	print("[proj_pool] built; size; ", max_projectiles)

func can_shoot() -> bool:
	# pool not ready yet during the deferred frame; block shooting until built
	return _free_list.size() > 0 and current_count < max_projectiles

func acquire() -> Node:
	if _free_list.is_empty(): return null
	var idx: int = _free_list.pop_back()
	current_count += 1
	return _pool[idx]

func release(proj: Node) -> void:
	proj.visible = false
	proj.set_process(false)
	proj.global_position = Vector3(0.0, -9999.0, 0.0)
	_free_list.push_back(proj.get_meta(&"pool_idx"))
	current_count -= 1
