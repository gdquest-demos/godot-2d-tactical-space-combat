class_name Hazard
extends Sprite

export (int) var attack := 1

var _hitpoints := 100 setget _set_hitpoints


func take_damage(value: int) -> void:
	_set_hitpoints(_hitpoints - value)


func _set_hitpoints(value: int) -> void:
	_hitpoints = value
	if _hitpoints <= 0:
		queue_free()
