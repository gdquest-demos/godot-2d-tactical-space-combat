class_name Door
extends Area2D


signal opened

var is_open := false setget set_is_open

var _units := 0

onready var sprite: Sprite = $Sprite
onready var timer: Timer = $Timer


func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("unit"):
		return
	
	_units += 1
	if _units == 1:
		timer.start()


func _on_area_exited(area: Area2D) -> void:
	if not area.is_in_group("unit"):
		return
	
	_units -= 1
	if _units == 0:
		timer.stop()
		self.is_open = false


func set_is_open(value: bool) -> void:
	is_open = value
	if is_open:
		sprite.frame = 1
		emit_signal("opened")
	else:
		sprite.frame = 0
