class_name UIUnit
extends ColorRect

onready var icon: NinePatchRect = $Icon
onready var feedback: NinePatchRect = $Feedback

var _unit: Unit


func setup(unit: Unit) -> void:
	_unit = unit
	_unit.connect("selection_toggled", self, "_on_Unit_selection_toggled")


func _ready() -> void:
	icon.modulate = _unit.colors.default


func _on_Unit_selection_toggled(is_selected: bool) -> void:
	feedback.visible = is_selected


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		_unit.is_selected = true
