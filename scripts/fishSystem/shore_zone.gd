@tool
class_name ShoreZone
extends Area3D

signal player_entered_shore(player: Node3D)
signal player_exited_shore()

## X,Z of the island's top-left corner (west/north edge)
@export var island_min: Vector2 = Vector2(-50, -70):
	set(v):
		island_min = v
		if is_node_ready():
			_rebuild()

## X,Z of the island's bottom-right corner (east/south edge)
@export var island_max: Vector2 = Vector2(80, 20):
	set(v):
		island_max = v
		if is_node_ready():
			_rebuild()

## How thick each shore strip is (world units). Increase if player misses the trigger.
@export var zone_depth: float = 6.0:
	set(v):
		zone_depth = v
		if is_node_ready():
			_rebuild()

## Height of each detection volume. Should be taller than the player.
@export var zone_height: float = 6.0:
	set(v):
		zone_height = v
		if is_node_ready():
			_rebuild()

func _ready() -> void:
	_rebuild()
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("shore_zones")

func _rebuild() -> void:
	# Clear previously generated children
	for child in get_children():
		child.free()

	var cx := (island_min.x + island_max.x) / 2.0
	var cz := (island_min.y + island_max.y) / 2.0
	var w  := island_max.x - island_min.x
	var d  := island_max.y - island_min.y
	var hd := zone_depth / 2.0

	# North strip
	_add_strip(Vector3(cx, 0.0, island_min.y - hd), Vector3(w + zone_depth * 2.0, zone_height, zone_depth))
	# South strip
	_add_strip(Vector3(cx, 0.0, island_max.y + hd), Vector3(w + zone_depth * 2.0, zone_height, zone_depth))
	# West strip
	_add_strip(Vector3(island_min.x - hd, 0.0, cz), Vector3(zone_depth, zone_height, d))
	# East strip
	_add_strip(Vector3(island_max.x + hd, 0.0, cz), Vector3(zone_depth, zone_height, d))

func _add_strip(pos: Vector3, size: Vector3) -> void:
	# Collision shape
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	col.shape = box
	col.position = pos
	add_child(col)

	# Debug visual — shown in editor and at runtime for easy placement
	var mesh_inst := MeshInstance3D.new()
	var box_mesh  := BoxMesh.new()
	box_mesh.size = size
	mesh_inst.mesh = box_mesh
	var mat := StandardMaterial3D.new()
	mat.transparency               = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color               = Color(0.0, 0.8, 1.0, 0.28)
	mat.emission_enabled           = true
	mat.emission                   = Color(0.0, 0.5, 1.0, 1.0)
	mat.emission_energy_multiplier = 0.35
	mat.cull_mode                  = BaseMaterial3D.CULL_DISABLED
	mesh_inst.set_surface_override_material(0, mat)
	mesh_inst.position = pos
	add_child(mesh_inst)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_entered_shore.emit(body)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_exited_shore.emit()
