class_name Breach
extends Hazard


func _set_hitpoints(value: int) -> void:
	._set_hitpoints(value)

	if THRESHOLD.low <= _hitpoints and _hitpoints < THRESHOLD.medium:
		scale = 0.75 * Vector2.ONE
	elif _hitpoints < THRESHOLD.low:
		scale = 0.5 * Vector2.ONE
