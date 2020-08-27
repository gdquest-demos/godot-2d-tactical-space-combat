class_name Door
extends Sprite


var _units := 0

onready var timer: Timer = $Timer


func _on_Area2D_area(area: Area2D, has_entered: bool) -> void:
	if area.is_in_group(Unit.GROUPS.main):
		_units += 1 if has_entered else -1
		if has_entered and _units == 1:
			timer.start()
		elif not has_entered and _units == 0:
			frame = 0


func _on_Timer_timeout() -> void:
	frame = 1
	Events.emit_signal("door_opened")
