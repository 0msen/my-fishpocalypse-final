extends Node3D
class_name Projectile

var data: ProjectileData
var damage: float = 0.0        # set by Weapon.shoot(); overrides data.damage
var direction: Vector3 = Vector3.FORWARD
var _elapsed: float = 0.0
var _tick_accum: float = 0.0   # laser tick accumulator

@onready var sprite: Sprite3D = $Sprite3D
@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var hitbox: Area3D = $Hitbox


func setup(p_data: ProjectileData, p_damage: float, p_direction: Vector3) -> void:
	if p_data == null:
		push_error("Projectile: data is null")
		queue_free()
		return
		
	data = p_data
	damage = p_damage
	direction = p_direction.normalized()
	
	# Sprite
	if sprite: sprite.texture = data.sprite if data.sprite else null
	else: push_warning("Projectile: Sprite3D node missing")
	
	# Lifetime timer
	if lifetime_timer:
		lifetime_timer.wait_time = data.lifetime
		lifetime_timer.one_shot  = true
		lifetime_timer.timeout.connect(queue_free)
		lifetime_timer.start()
	else: push_warning("Projectile: LifetimeTimer node missing")
	
	# Hitbox
	if hitbox: hitbox.body_entered.connect(_on_body_entered)
	else: push_warning("Projectile: Hitbox Area3D node missing")
	
func _physics_process(delta: float) -> void:
	if data == null: return
	match data.type:
		ProjectileData.ProjectileType.BULLET:
			global_position += direction * data.speed * delta
			
		ProjectileData.ProjectileType.LASER:
			# Laser doesn't move — ticks damage on overlapping bodies
			_tick_accum += delta
			if _tick_accum >= data.tick_rate:
				_tick_accum = 0.0
				if hitbox:
					for body in hitbox.get_overlapping_bodies():
						_apply_damage(body)
	
func _on_body_entered(body: Node) -> void:
	if data == null: return
	# Bullets hit on contact; lasers use tick instead
	if data.type == ProjectileData.ProjectileType.BULLET:
		_apply_damage(body)
		queue_free()
	
	
func _apply_damage(body: Node) -> void:
	if body == null: return
	# Skip same-owner targets
	if data.owner_type == ProjectileData.OwnerType.PLAYER and body.is_in_group("player"): return
	if data.owner_type == ProjectileData.OwnerType.ENEMY  and body.is_in_group("enemy"):  return
	
	# wala pa ni sa player
	if body.has_method("take_damage"):
		body.take_damage(damage)
