class_name WeaponLaserEnemy
extends WeaponLaser


func _ready() -> void:
	yield(get_tree(), "idle_frame")
	emit_signal("targeting")


func _on_Ship_targeted(msg: Dictionary) -> void:
	match msg:
		{"start": var start, "direction": var direction}:
			var end: Vector2 = start + TARGETTING_LENGTH * direction
			_points = [start, end]


func _fire() -> void:
	._fire()
	_points = TARGET_LINE_DEFAULT
	emit_signal("targeting")
