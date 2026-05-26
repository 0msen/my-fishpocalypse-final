extends CanvasLayer

@onready var _label: Label = $Label

var _player: Node = null
var _health: Node = null


func _ready() -> void:
	await get_tree().process_frame
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	_player = players[0]
	_health = _player.get_node_or_null("HealthComponent")
	if not _health:
		_health = _player.get_node_or_null("Health")


func _process(_delta: float) -> void:
	if not _player:
		return
	var hp_str := "HP: N/A"
	if _health:
		hp_str = "HP: %.0f / %.0f" % [_health.current_hp, _health.max_hp]

	var cp_str := "CP: N/A"
	var sp_str := "SP: N/A"
	if "cp" in _player:
		cp_str = "CP: %.0f / %.0f" % [_player.cp, _player.max_cp]
	if "sp" in _player:
		sp_str = "SP: %.0f / %.0f" % [_player.sp, _player.max_sp]

	_label.text = "%s\n%s\n%s" % [hp_str, cp_str, sp_str]
