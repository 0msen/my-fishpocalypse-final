extends Node3D

@export var day_length_sec: int = 360
@export var speed_factor: float = 1.0

@onready var light: DirectionalLight3D = $DirectionalLight3D
@onready var world_env: WorldEnvironment = $WorldEnvironment

var time_of_day: float = 0.0
signal is_night(active: bool)

var night_active: bool = false
var sky: ProceduralSkyMaterial
var _inv_day_length: float


func _ready() -> void:
	add_to_group("day_night")
	_inv_day_length = 1.0 / float(day_length_sec)
	
	var env: Environment = world_env.environment
	if env != null and env.sky != null:
		sky = env.sky.sky_material as ProceduralSkyMaterial
		
func _process(delta: float) -> void:
	# TIME SYSTEM
	time_of_day = fmod(time_of_day + delta * speed_factor * _inv_day_length, 1.0)
	
	# SUN ROTATION
	light.rotation_degrees.x = time_of_day * -360.0
	
	# DAYLIGHT + LIGHT
	var daylight: float = _calculate_daylight(time_of_day)
	var sun_color := Color(1.0, daylight, 1.0)
	light.light_color = sun_color
	light.light_energy = daylight * 1.5
	# SKY
	_update_sky(sun_color)
	
	# NIGHT DETECTION
	# Night = sun below horizon = time_of_day outside [0.25, 0.75] (dawn to dusk)
	var now_night: bool = time_of_day < 0.25 or time_of_day > 0.75
	if now_night != night_active:
		night_active = now_night
		is_night.emit(night_active)
		
		
# DAYLIGHT CURVE (smooth sine wave)
func _calculate_daylight(t: float) -> float:
	return clampf(cos((t - 0.5) * TAU) * 0.5 + 0.5, 0.0, 1.0)
	
# SKY GRADIENT
func _update_sky(sun_color: Color) -> void:
	var env: Environment = world_env.environment
	if env == null: return
	env.background_mode = Environment.BG_COLOR
	env.background_color = sun_color.darkened(0.6)
