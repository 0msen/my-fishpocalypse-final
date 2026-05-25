extends Area3D

@export var inside_volume: float = 100.0
@export var outside_volume: float = 10.0
@export var fade_speed: float = 5.0

@onready var audio := $AudioStreamPlayer3D

func _ready() -> void:
	audio.stream.loop = true
	audio.volume_db = outside_volume
	audio.play()
	body_entered.connect(_on_entered)
	body_exited.connect(_on_exited)

func _on_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_fade_to(inside_volume)

func _on_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_fade_to(outside_volume)
func _fade_to(target_db: float) -> void:
	var t := create_tween()
	t.tween_property(audio, "volume_db", target_db, fade_speed)\
	 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
