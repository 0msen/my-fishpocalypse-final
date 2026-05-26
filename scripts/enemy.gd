# enemy.gdclass_name Enemy
extends CharacterBody3D

@export var player_reference: CharacterBody3D
@export var max_health: float = 30.0
@export var speed: float = 1.0
@export var damage: float = 5.0
@export var is_elite: bool = false

var health: float

func _ready() -> void:
	health = max_health
	if is_elite:
		_apply_elite_modifiers()

func _apply_elite_modifiers() -> void:
	max_health *= 3.0
	health = max_health
	damage *= 2.0
	speed *= 1.3
	scale *= 1.4

func _physics_process(delta):
	if player_reference == null: return
	var direction = (player_reference.global_position - global_position).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()
	
	# Detect collision with player from fish side
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			_deal_damage_to_player(collider)

func _deal_damage_to_player(player) -> void:
	# Tell the player to take damage
	if player.has_method("_take_damage"):
		player._take_damage(damage)
		
func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	queue_free()
