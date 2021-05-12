extends Unit


## _Units.gd_ manages this property. That's  where we query Godot for the selected
## units under a rectangular area activated by `LMB` & dragging the mouse.
var is_selected: bool setget set_is_selected

var _ui_unit: ColorRect
var _ui_unit_icon: NinePatchRect
var _ui_unit_feedback: NinePatchRect

onready var area_select: Area2D = $PathFollow2D/AreaSelect


func setup(ui_unit: ColorRect) -> void:
	_ui_unit = ui_unit
	_ui_unit_icon = ui_unit.get_node("Icon")
	_ui_unit_feedback = ui_unit.get_node("Feedback")
	
	# Instead of overwriting `gui_input()` in the _Unit_ UI node, we prefer to
	# use the `gui_input` signal to handle player interaction right here.
	#
	# This simplifies UI - game entities interactions by a lot.
	_ui_unit.connect("gui_input", self, "_on_UIUnit_gui_input")
	_ui_unit_icon.modulate = COLORS.default


func _ready() -> void:
	# Instead of assigning `false` on declaration we assign it here,
	# using `self.` to trigger the call to the setter function
	self.is_selected = false


func _on_UIUnit_gui_input(event: InputEvent) -> void:
	# We keep track of selected units using this group name
	if event.is_action_pressed("left_click"):
		self.is_selected = true


func set_is_selected(value: bool) -> void:
	# We keep track of selected units using this group name
	var group := "selected-unit"
	
	is_selected = value
	if is_selected:
		area_unit.modulate = COLORS.selected
		add_to_group(group)
	else:
		area_unit.modulate = COLORS.default
		if is_in_group(group):
			remove_from_group(group)
	
	# We need this `null` check otherwise Godot will complain at the start of the game,
	# on the first frame.
	if _ui_unit_feedback != null:
		_ui_unit_feedback.visible = is_selected
