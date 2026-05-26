class_name BuffSystem extends Node

signal buff_applied(buff: BuffData)
signal buff_removed(buff: BuffData)
signal stats_changed()

# Stackable buffs
var _active: Array[BuffData] = []
func _ready() -> void:
	add_to_group("buff_system")
	var gs = get_node_or_null("/root/GameState")
	if gs:
		if gs.has_signal("buff_applied"):
			gs.buff_applied.connect(_on_gamestate_buff_applied)
			
			
func apply_buff(buff: BuffData) -> void:
	if buff == null: return
	_active.append(buff)
	buff_applied.emit(buff)
	stats_changed.emit()
	
	
func remove_buff(buff: BuffData) -> void:
	for i in range(_active.size() - 1, -1, -1):
		if _active[i] == buff:
			_active.remove_at(i)
			buff_removed.emit(buff)
			stats_changed.emit()
			return
func remove_all_of_buff(buff: BuffData) -> void:
	var removed := false
	for i in range(_active.size() - 1, -1, -1):
		if _active[i] == buff:
			_active.remove_at(i)
			removed = true
	if removed:
		buff_removed.emit(buff)
		stats_changed.emit()
		
		
func get_multiplier(stat: BuffData.StatTarget) -> float:
	var result := 1.0
	for buff in _active:
		if buff.stat_target == stat:
			result *= buff.multiplier
	return result
func get_addend(stat: BuffData.StatTarget) -> float:
	var result := 0.0
	for buff in _active:
		if buff.stat_target == stat:
			result += buff.addend
	return result
	
# GameState hookup
func _on_gamestate_buff_applied(buff: BuffData) -> void:
	apply_buff(buff)
