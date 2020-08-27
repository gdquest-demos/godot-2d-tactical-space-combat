extends ColorRect


signal selected

onready var icon: NinePatchRect = $Icon
onready var feedback: NinePatchRect = $Feedback


func setup(color: Color) -> void:
	icon.modulate = color


func _on_Unit_selected(is_selected: bool) -> void:
	feedback.visible = is_selected


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
			emit_signal("selected")
