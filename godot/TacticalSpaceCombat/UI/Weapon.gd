extends VBoxContainer
# The flow needs to be fixed, there's lots of bugs for now.
# FIXME: automatically recharge after shot.

signal targeting(index)
signal fired

var charge_time := 2.0

var _has_target := false
var _is_charging := false setget _set_is_charging

onready var scene_tree: SceneTree = get_tree()
onready var progress_bar: ProgressBar = $ProgressBar
onready var button: Button = $Button
onready var tween: Tween = $Tween


func _ready() -> void:
	_set_is_charging(true)


func _on_Button_toggled(is_pressed: bool) -> void:
	var cursor := Input.CURSOR_ARROW
	if is_pressed:
		cursor = Input.CURSOR_CROSS
		emit_signal("targeting", get_index() - 1)
	elif not (is_pressed or _is_charging or scene_tree.get_nodes_in_group("target").empty()):
		# If the room is targeted after weapon got charged then fire directly.
		emit_signal("fired")
	Input.set_default_cursor_shape(cursor)


# Cancel press toggle
func _on_Room_targeted(targeted_by: int, _position: Vector2) -> void:
	if targeted_by == get_index() - 1:
		button.pressed = false
		_has_target = true


func _set_is_charging(val: bool) -> void:
	_is_charging = val
	tween.stop_all()
	if _is_charging:
		tween.interpolate_property(
			progress_bar, "value", progress_bar.min_value, progress_bar.max_value, charge_time
		)
		tween.start()
	elif not _is_charging and _has_target:
		_has_target = false
		emit_signal("fired")
