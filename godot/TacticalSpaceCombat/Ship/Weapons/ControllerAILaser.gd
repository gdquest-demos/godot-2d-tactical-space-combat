tool
class_name ControllerAILaser
extends Controller


func _ready() -> void:
	if Engine.editor_hint:
		return

	var msg := {"targeting_length": weapon.targeting_length}
	weapon.connect("fire_stopped", self, "emit_signal", ["targeting", msg])

	yield(get_tree(), "idle_frame")
	emit_signal("targeting", msg)
