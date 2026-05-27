extends StaticBody3D

@onready var _health: HealthComponents = $HealthComponent
@onready var _label: Label3D = $Label3D


func _ready() -> void:
	_health.health_changed.connect(_on_health_changed)
	_health.died.connect(_on_died)
	_update_label()


func take_damage(amount: float) -> void:
	_health.take_damage(amount)


func _on_health_changed(_cur: float, _max: float) -> void:
	_update_label()


func _on_died() -> void:
	_label.text = "DEAD"
	_label.modulate = Color.RED


func _update_label() -> void:
	_label.text = "HP: %.0f / %.0f" % [_health.current_hp, _health.max_hp]
