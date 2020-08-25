extends Sprite


var is_open := false

onready var timer: Timer = $Timer


func _on_AreaDoor_area_entered(area: Area2D) -> void:
	timer.start()


func _on_Timer_timeout() -> void:
	if is_open:
		is_open = false
		frame = 0
		FTLLikeEvents.emit_signal("door_closed")
	else:
		timer.start()
		is_open = true
		frame = 1
		FTLLikeEvents.emit_signal("door_opened")
