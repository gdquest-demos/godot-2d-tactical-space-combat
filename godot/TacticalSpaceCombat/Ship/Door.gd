class_name Door
extends Area2D


var is_open := false setget set_is_open

var _units := 0

onready var sprite: Sprite = $Sprite
onready var timer: Timer = $Timer


func _on_area(area: Area2D, has_entered: bool) -> void:
	if area.is_in_group("unit"):
		_units += 1 if has_entered else -1
		if has_entered and _units == 1:
			timer.start()
		elif not has_entered and _units == 0:
			timer.stop()
			self.is_open = false


func set_is_open(val: bool) -> void:
	is_open = val
	if is_open:
		sprite.frame = 1
		Events.emit_signal("door_opened")
	else:
		sprite.frame = 0
