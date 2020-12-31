class_name WeaponLaserPlayer
extends WeaponLaser


var _ui_weapon: VBoxContainer
var _ui_weapon_button: Button
var _ui_weapon_progress_bar: ProgressBar


func setup(ui_weapon: VBoxContainer) -> void:
	_ui_weapon = ui_weapon
	_ui_weapon_button = ui_weapon.get_node("Button")
	_ui_weapon_progress_bar = ui_weapon.get_node("ProgressBar")
	
	_ui_weapon_button.connect("gui_input", self, "_on_UIWeaponButton_gui_input")
	_ui_weapon_button.connect("toggled", self, "_on_UIWeaponButton_toggled")
	
	_ui_weapon_button.text = weapon_name
	_set_is_charging(true)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouse and _is_targeting):
		return
	
	if event.is_action_pressed("left_click"):
		_points[0] = event.position
	elif _points[0] != Vector2.INF and event is InputEventMouseMotion:
		var offset: Vector2 = event.position - _points[0]
		offset = offset.clamped(TARGETTING_LENGTH)
		_points[1] = _points[0] + offset
	elif event.is_action_released("left_click"):
		_ui_weapon_button.pressed = false
		if not _is_charging:
			_fire()
	
	if _points[1] != Vector2.INF:
		emit_signal("targeting", _points)


func _on_UIWeaponButton_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		_ui_weapon_button.pressed = false


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	Input.set_default_cursor_shape(Input.CURSOR_CROSS if is_pressed else Input.CURSOR_ARROW)
	_is_targeting = is_pressed
	if _is_targeting:
		_points = TARGET_LINE_DEFAULT
		emit_signal("targeting", _points)
