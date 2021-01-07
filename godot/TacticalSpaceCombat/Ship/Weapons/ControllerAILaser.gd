class_name ControllerAILaser
extends Controller


func _ready() -> void:
	yield(get_tree(), "idle_frame")
	emit_signal("targeting", {"targeting_length": weapon.targeting_length})


func get_class() -> String:
	return "ControllerAILaser"
