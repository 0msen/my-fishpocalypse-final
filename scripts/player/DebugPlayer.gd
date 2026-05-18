extends CharacterBody3D

@export var walk_speed := 5.0
@export var run_speed := 9.0
@export var dodge_speed := 18.0
@export var dodge_time := 0.15
@export var gravity := 20.0

var is_dodging := false
var dodge_timer := 0.0
var dodge_dir := Vector3.ZERO

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta):
	if not is_on_floor(): velocity.y -= gravity * delta
	else: velocity.y = 0
	
	if is_dodging:
		dodge_timer -= delta
		velocity = dodge_dir * dodge_speed
		if dodge_timer <= 0: is_dodging = false
		
		move_and_slide()
		return
		
	var input_dir := Vector3.ZERO
	if Input.is_action_pressed("D"): input_dir.x += 1
	if Input.is_action_pressed("A"): input_dir.x -= 1
	if Input.is_action_pressed("S"): input_dir.z += 1
	if Input.is_action_pressed("W"): input_dir.z -= 1
	
	input_dir = input_dir.normalized()
	
	var speed = walk_speed
	if Input.is_action_pressed("RUN"): speed = run_speed
	
	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed
	
	if Input.is_action_just_pressed("DODGE") and input_dir != Vector3.ZERO:
		is_dodging = true
		dodge_timer = dodge_time
		dodge_dir = input_dir
		velocity.x = dodge_dir.x * dodge_speed
		velocity.z = dodge_dir.z * dodge_speed
		
	if Input.is_action_just_pressed("SHOOT"): print("Shoot!")
	move_and_slide()
