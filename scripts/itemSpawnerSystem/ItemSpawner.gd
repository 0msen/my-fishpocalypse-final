extends Node
class_name ItemSpawner

@export var dbg := false

# Trajectory
@export var drop_height: float = 4.0
@export var drop_horizontal_force: float = 3.0
@export var bounce_amount: float = 0.6

# Preloaded scenes
@onready var weapon_scene  = preload("res://scenes/ItemRelated/weaponTemplate.tscn")
@onready var healing_scene = preload("res://scenes/ItemRelated/healingItemTemplate.tscn")
@onready var pole_scene    = preload("res://scenes/ItemRelated/poleTemplate.tscn")

@export var rarity_config: RarityConfig

# The Marker3D child that is the launch origin
@onready var spawn_marker: Marker3D = $Marker3D

#  TRAJECTORY HELPER
## Launches `item` in a circular arc from the Marker3D origin
## `spread_radius`  – how far from the marker the item lands
## `angle_override` – pass a specific angle (radians)
func _launch_arc(item: Node3D,
				 spread_radius: float = 1.2,
				 angle_override: float = -1.0) -> void:
	
	# Random direction in the horizontal plane
	var angle := angle_override if angle_override >= 0.0 else randf() * TAU
	var origin: Vector3 = spawn_marker.global_position
	
	# Place item at origin first so tween starts correctly
	item.global_position = origin
	
	# Landing position (flat circle around the marker)
	var land_offset := Vector3(cos(angle), 0.0, sin(angle)) * spread_radius
	var land_pos    := origin + land_offset
	
	# Arc peak
	var peak_pos := origin + land_offset * 0.5 + Vector3.UP * drop_height
	
	# ---- Tween the arc in two phases ----
	var tween := item.create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	
	# Phase 1 – rise to peak
	tween.tween_property(item, "global_position", peak_pos, 0.25)\
		 .set_ease(Tween.EASE_OUT)

	# Phase 2 – fall to land
	tween.tween_property(item, "global_position", land_pos, 0.25)\
		 .set_ease(Tween.EASE_IN)

	# Bounce
	if bounce_amount > 0.01:
		var bounce_peak := land_pos + Vector3.UP * (drop_height * bounce_amount)
		tween.tween_property(item, "global_position", bounce_peak, 0.15)\
			 .set_ease(Tween.EASE_OUT)
		tween.tween_property(item, "global_position", land_pos, 0.15)\
			 .set_ease(Tween.EASE_IN)
	
	var spin_tween := item.create_tween()
	spin_tween.tween_property(item, "rotation:y",
							  item.rotation.y + TAU, 0.65)\
			  .set_trans(Tween.TRANS_LINEAR)
			
	if dbg:
		print("[SPAWNER] Arc launched to ", land_pos,
			  " angle=", rad_to_deg(angle), "°")
	
#  SPAWN HELPERS
func spawn_weapon(data: FishWeaponData, rarity: RarityTier,
				  _position: Vector3, spread: float = 1.2) -> Node3D:
	if not data or not rarity:
		push_error("[ItemSpawner] Missing data or rarity for weapon")
		return null
		
	var weapon = weapon_scene.instantiate()
	get_tree().current_scene.add_child(weapon)
	weapon.global_position = spawn_marker.global_position
	weapon.setup(data, rarity)
	_launch_arc(weapon, spread)
	
	if dbg: print("[SPAWNER] Weapon spawned: ", data.resource_path, " (", rarity.name, ")")
	return weapon
	
func spawn_healing_item(data: HealingItemData, rarity: RarityTier,
						_position: Vector3, spread: float = 1.2) -> Node3D:
	if not data or not rarity:
		push_error("[ItemSpawner] Missing data or rarity for healing item")
		return null
		
	var item = healing_scene.instantiate()
	get_tree().current_scene.add_child(item)
	item.global_position = spawn_marker.global_position
	item.setup(data, rarity)
	_launch_arc(item, spread)
	
	if dbg: print("[SPAWNER] Healing Item spawned: ", data.resource_path, " (", rarity.name, ")")
	return item
	
func spawn_pole(data: FishingPoleData, rarity: RarityTier,
				_position: Vector3, spread: float = 1.2) -> Node3D:
	if not data or not rarity:
		push_error("[ItemSpawner] Missing data or rarity for pole")
		return null
		
	var pole = pole_scene.instantiate()
	get_tree().current_scene.add_child(pole)
	pole.global_position = spawn_marker.global_position
	pole.setup(data, rarity)
	_launch_arc(pole, spread)
	
	if dbg: print("[SPAWNER] Pole spawned: ", data.resource_path, " (", rarity.name, ")")
	return pole
	
	
#  CIRCULAR MULTI-SPAWN
## Spawns `count` items evenly distributed around a circle.
## Useful for chest bursts, enemy drops, etc.
func spawn_circle(items_to_spawn: Array, spread_radius: float = 2.0) -> void:
	var count := items_to_spawn.size()
	if count == 0: return

	for i in count:
		var angle := (TAU / count) * i
		var entry  = items_to_spawn[i]   # expects {type, data, rarity}

		match entry.get("type", ""):
			"weapon":
				var w = weapon_scene.instantiate()
				w.setup(entry.data, entry.rarity)
				w.global_position = spawn_marker.global_position
				get_tree().current_scene.add_child(w)
				_launch_arc(w, spread_radius, angle)

			"healing":
				var h = healing_scene.instantiate()
				h.setup(entry.data, entry.rarity)
				h.global_position = spawn_marker.global_position
				get_tree().current_scene.add_child(h)
				_launch_arc(h, spread_radius, angle)

			"pole":
				var p = pole_scene.instantiate()
				p.setup(entry.data, entry.rarity)
				p.global_position = spawn_marker.global_position
				get_tree().current_scene.add_child(p)
				_launch_arc(p, spread_radius, angle)

#  RANDOMIZER
enum ItemType { WEAPON, HEALING, POLE }
func spawn_random_item(position: Vector3,
					   weapon_pool:  Array[FishWeaponData],
					   healing_pool: Array[HealingItemData],
					   pole_pool:    Array[FishingPoleData]) -> Node3D:
	
	if not rarity_config or rarity_config.tiers.is_empty():
		push_error("[ItemSpawner] RarityConfig is missing or empty!")
		return null
		
	var rarity = _pick_weighted_rarity()
	if not rarity:
		push_error("[ItemSpawner] Failed to pick rarity")
		return null
		
	var item_type = ItemType.values()[randi() % ItemType.size()]
	
	match item_type:
		ItemType.WEAPON:
			if weapon_pool.is_empty():
				push_warning("No weapons in pool"); return null
			return spawn_weapon(weapon_pool[randi() % weapon_pool.size()],
								rarity, position)
			
		ItemType.HEALING:
			if healing_pool.is_empty():
				push_warning("No healing items in pool"); return null
			return spawn_healing_item(healing_pool[randi() % healing_pool.size()],
									 rarity, position)
			
		ItemType.POLE:
			if pole_pool.is_empty():
				push_warning("No poles in pool"); return null
			return spawn_pole(pole_pool[randi() % pole_pool.size()],
							  rarity, position)
	return null
	
#  WEIGHTED RARITY PICKER
func _pick_weighted_rarity() -> RarityTier:
	if not rarity_config or rarity_config.tiers.is_empty(): return null
	
	var total_weight := 0.0
	for tier in rarity_config.tiers: total_weight += tier.weight
	
	if total_weight <= 0: return rarity_config.tiers[0]
	
	var roll    := randf() * total_weight
	var current := 0.0
	for tier in rarity_config.tiers:
		current += tier.weight
		if roll <= current: return tier
		
	return rarity_config.tiers.back()
	
	
#  TEST  (tangtangon ra after)
@export var test_weapon_pool:  Array[FishWeaponData]
@export var test_healing_pool: Array[HealingItemData]
@export var test_pole_pool:    Array[FishingPoleData]

var _player_in_range := false


func _ready() -> void:
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed("INTERACT"):
		spawn_random_item(spawn_marker.global_position,
						  test_weapon_pool,
						  test_healing_pool,
						  test_pole_pool)
	
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		if dbg: print("[ItemSpawner] Player entered range")
		
func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if dbg: print("[ItemSpawner] Player left range")
