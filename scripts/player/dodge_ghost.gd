extends Node3D

var lifetime := 3.0
var timer := 0.0
var sprite: AnimatedSprite3D
const BASE_SCALE := Vector3(5.0, 5.0, 5.0)

func _ready() -> void:
	sprite = AnimatedSprite3D.new()
	add_child(sprite)
	
func setup(source_anim: AnimatedSprite3D, ghost_frame: int) -> void:
	sprite.sprite_frames = source_anim.sprite_frames
	sprite.animation = "dodge"
	sprite.frame = ghost_frame
	sprite.pixel_size = source_anim.pixel_size
	sprite.billboard = source_anim.billboard
	sprite.texture_filter = source_anim.texture_filter
	sprite.pause()
	sprite.scale = BASE_SCALE
	sprite.modulate = Color.GREEN
	
func _process(delta: float) -> void:
	timer += delta
	var progress: float = minf(timer / lifetime, 1.0)
	# CHANGED: scale and modulate collapsed — was computing lerp twice separately
	sprite.scale = BASE_SCALE * lerp(1.0, 0.8, progress)
	
	# GREEN -> BLUE -> PURPLE -> ORANGE -> RED mapped across 0..1
	var color: Color = _ghost_color(progress)
	color.a = lerp(0.6, 0.0, progress)
	sprite.modulate = color
	
	if progress >= 1.0: queue_free()
	
func _ghost_color(t: float) -> Color:
	if t < 0.25: 	return Color.GREEN.lerp(Color.BLUE,   t * 4.0)
	elif t < 0.5: 	return Color.BLUE.lerp(Color.PURPLE,  (t - 0.25) * 4.0)
	elif t < 0.75: 	return Color.PURPLE.lerp(Color.ORANGE, (t - 0.5) * 4.0)
	else: 			return Color.ORANGE.lerp(Color.RED,   (t - 0.75) * 4.0)
