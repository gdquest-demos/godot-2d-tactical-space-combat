class_name Breach
extends Hazard


func _set_hitpoints(value: int) -> void:
	._set_hitpoints(value)
	if 30 < _hitpoints and _hitpoints <= 70:
		scale = 0.75 * Vector2.ONE
	elif 0 < _hitpoints and _hitpoints <= 30:
		scale = 0.5 * Vector2.ONE
