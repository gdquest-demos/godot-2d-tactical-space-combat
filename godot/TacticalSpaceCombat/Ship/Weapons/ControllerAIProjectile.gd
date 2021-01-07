class_name ControllerAIProjectile
extends Controller


func _ready() -> void:
	yield(get_tree(), "idle_frame")
	emit_signal("targeting", {"index": get_index()})


func get_class() -> String:
	return "ControllerAIProjectile"
