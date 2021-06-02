class_name ControllerAILaser
extends Controller


func _ready() -> void:
	var msg := {"type": Type.LASER, "targeting_length": weapon.targeting_length}
	weapon.connect("fire_stopped", self, "emit_signal", ["targeting", msg])

	yield(get_tree(), "idle_frame")
	emit_signal("targeting", msg)


func _on_Ship_targeted(msg: Dictionary) -> void:
	._on_Ship_targeted(msg)
	weapon.targeted = true
	if not weapon.is_charging:
		weapon.fire()
