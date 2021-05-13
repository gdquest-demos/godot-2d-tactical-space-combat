extends Unit


## _Units.gd_ manages this property. That's  where we query Godot for the selected
## units under a rectangular area activated by `LMB` & dragging the mouse.
var is_selected: bool setget set_is_selected

## Reference to the UI player feedback element. We need to set its state when units
## get selected/deselected.
var _ui_unit_feedback: NinePatchRect

onready var area_select: Area2D = $PathFollow2D/AreaSelect


func setup(ui_unit: ColorRect) -> void:
	_ui_unit_feedback = ui_unit.get_node("Feedback")
	
	# We get the icon and adjust its color from code so that it always stays in
	# sync with `COLORS.default`. I generally store this into a variable for later,
	# but this is a one-time use.
	ui_unit.get_node("Icon").modulate = COLORS.default

	# Instead of overwriting `gui_input()` in the _Unit_ UI node, we prefer to
	# use the `gui_input` signal to handle player interaction right here.
	#
	# This simplifies UI - game entities interactions by a lot.
	ui_unit.connect("gui_input", self, "_on_UIUnit_gui_input")

	# When the unit dies, we also remove its associated UI element.
	connect("tree_exited", ui_unit, "queue_free")


func _ready() -> void:
	# Instead of assigning `false` on declaration we assign it here,
	# using `self.` to trigger the call to the setter function
	self.is_selected = false


func _on_UIUnit_gui_input(event: InputEvent) -> void:
	# Remember that we use used `_input()` instead of `_unhandled_input()`
	# in `Units.gd`. This is why. With `_unhandled_input()`, we would ignore
	# the UI clicks in `Units.gd`. We'd keep on selecting new units without
	# deselecting previous ones.
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
