class_name ControllerAIProjectile
extends Controller


func _ready() -> void:
	weapon.setup(Global.Layers.SHIPPLAYER)

	var msg := {"index": get_index()}
	weapon.connect("fired", self, "emit_signal", ["targeting", msg])

	yield(get_tree(), "idle_frame")
	emit_signal("targeting", msg)
