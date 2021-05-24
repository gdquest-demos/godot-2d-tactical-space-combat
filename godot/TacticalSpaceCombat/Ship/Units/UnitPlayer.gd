extends Unit

var is_selected: bool setget set_is_selected

var _ui_unit_feedback: NinePatchRect

onready var area_select: Area2D = $PathFollow2D/AreaSelect


func setup(ui_unit: ColorRect) -> void:
	_ui_unit_feedback = ui_unit.get_node("Feedback")
	ui_unit.get_node("Icon").modulate = COLORS.default
	ui_unit.connect("gui_input", self, "_on_UIUnit_gui_input")
	connect("tree_exited", ui_unit, "queue_free")


func _ready() -> void:
	self.is_selected = false


func _on_UIUnit_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		self.is_selected = true


func set_is_selected(value: bool) -> void:
	var group := "selected-unit"

	is_selected = value
	if is_selected:
		area_unit.modulate = COLORS.selected
		add_to_group(group)
	else:
		area_unit.modulate = COLORS.default
		if is_in_group(group):
			remove_from_group(group)

	if _ui_unit_feedback != null:
		_ui_unit_feedback.visible = is_selected
