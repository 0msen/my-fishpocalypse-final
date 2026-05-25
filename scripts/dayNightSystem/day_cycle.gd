extends Node3D

signal day_night_changed(is_night_active: bool)

@export var day_length_sec: int = 360
@export var speed_factor: float = 1.0

@onready var light: DirectionalLight3D = $DirectionalLight3D
@onready var world_env: WorldEnvironment = $WorldEnvironment

var time_accumulated: float = 0.0
var is_night: bool = false
var sky_material: ProceduralSkyMaterial

func _ready() -> void:
	add_to_group("day_night")
	var env = world_env.environment
	if env and env.sky and env.sky.sky_material:
		sky_material = env.sky.sky_material as ProceduralSkyMaterial
	_set_day_state()
	
func _process(delta: float) -> void:
	time_accumulated += delta * speed_factor
	
	if not is_night and time_accumulated >= day_length_sec:
		_set_night_state()
		time_accumulated = 0.0
		
		
func _set_day_state() -> void:
	is_night = false
	light.light_energy = 1.5
	light.light_color = Color("ffff9aff")
	
	var env = world_env.environment
	if env:
		env.background_mode = Environment.BG_SKY
		env.fog_enabled = false
		# Day ambient - use sky
		env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		env.ambient_light_sky_contribution = 1.0
		# fog
		env.fog_enabled = true
		env.fog_mode = Environment.FOG_MODE_DEPTH
		env.fog_light_color = Color(0.568, 0.996, 0.922, 1.0)
		env.fog_density = 0.90
		env.fog_sky_affect = 1.0
		
	day_night_changed.emit(false)
	
func _set_night_state() -> void:
	is_night = true
	# Turn off sun
	light.light_energy = 0.0
	
	var env = world_env.environment
	if env:
		env.background_mode = Environment.BG_SKY
		
		if sky_material:
			sky_material.sky_top_color = Color(0.95, 0.15, 0.15)
			sky_material.sky_horizon_color = Color(0.0, 0.0, 0.0, 1.0)
			sky_material.ground_bottom_color = Color(0.05, 0.0, 0.0)
			sky_material.ground_horizon_color = Color(0.12, 0.02, 0.02)
			
			# Force refresh
			env.sky.sky_material = sky_material
		
		# NIGHT AMBIENT SETTINGS - Prevent sky from tinting objects
		env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		env.ambient_light_color = Color(0.12, 0.03, 0.03)   # Very dark red
		env.ambient_light_energy = 0.5
		env.ambient_light_sky_contribution = 0.0
		
		# Red fog
		env.fog_enabled = true
		env.fog_mode = Environment.FOG_MODE_DEPTH
		env.fog_light_color = Color(1.0, 0.204, 0.204, 1.0)
		env.fog_density = 0.9
		env.fog_sky_affect = 1.0
	
	day_night_changed.emit(true)

# CALL ONCE ENEMIES ARE DEAD
func return_to_day() -> void:
	if is_night:
		time_accumulated = 0.0
		_set_day_state()
		print("Returned to day - all enemies defeated")
