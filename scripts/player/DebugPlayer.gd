extends CharacterBody3D

@export var walk_speed := 5.0
@export var run_speed := 9.0
@export var dodge_speed := 18.0
@export var dodge_time := 0.15
@export var gravity := 20.0

@onready var anim: AnimatedSprite3D = $Sprite3D

var is_dodging := false
var dodge_timer := 0.0
var dodge_dir := Vector3.ZERO

var current_anim := ""

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta):
	# gravity
	if not is_on_floor(): velocity.y -= gravity * delta
	else: velocity.y = 0
	
	# DODGE STATE
	if is_dodging:
		dodge_timer -= delta
		velocity.x = dodge_dir.x * dodge_speed
		velocity.z = dodge_dir.z * dodge_speed
		_play_anim("dodge")
		if dodge_timer <= 0:
			is_dodging = false
		move_and_slide()
		return
	
	# INPUT
	var input_dir := Vector3.ZERO
	if Input.is_action_pressed("D"): input_dir.x += 1
	if Input.is_action_pressed("A"): input_dir.x -= 1
	if Input.is_action_pressed("S"): input_dir.z += 1
	if Input.is_action_pressed("W"): input_dir.z -= 1
	input_dir = input_dir.normalized()
	
	var speed = walk_speed
	if Input.is_action_pressed("RUN"):
		speed = run_speed
	
	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed
	
	# DODGE START
	if Input.is_action_just_pressed("DODGE") and input_dir != Vector3.ZERO:
		is_dodging = true
		dodge_timer = dodge_time
		dodge_dir = input_dir
		return
		
	# SHOOT
	if Input.is_action_just_pressed("SHOOT"):
		print("Shoot!")
		
	# ANIMATION and AUDIO
	_play_move_anim()
	
	move_and_slide()
	
# Handles animations for now
func _play_move_anim() -> void:
	if Input.is_action_pressed("W"):
		_play_anim("walk_back")
	elif Input.is_action_pressed("S"):
		_play_anim("walk_front")
	elif Input.is_action_pressed("A"):
		_play_anim("walk_left")
	elif Input.is_action_pressed("D"):
		_play_anim("walk_right")
	else:
		_play_anim("idle")
		
func _play_anim(name: String) -> void:
	if current_anim == name: return
	current_anim = name
	anim.play(name)
