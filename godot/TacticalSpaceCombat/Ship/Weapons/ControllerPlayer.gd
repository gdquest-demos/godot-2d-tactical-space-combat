class_name ControllerPlayer
extends Controller


var _ui_weapon: VBoxContainer
var _ui_weapon_button: Button
var _ui_weapon_progress_bar: ProgressBar


func setup(ui_weapon: VBoxContainer) -> void:
	_ui_weapon = ui_weapon
	_ui_weapon_button = ui_weapon.get_node("Button")
	_ui_weapon_progress_bar = ui_weapon.get_node("ProgressBar")
	
	weapon.tween.connect("tween_step", self, "_on_WeaponTween_tween_step")
	_ui_weapon_button.connect("gui_input", self, "_on_UIWeaponButton_gui_input")
	_ui_weapon_button.connect("toggled", self, "_on_UIWeaponButton_toggled")
	
	_ui_weapon_button.text = weapon.weapon_name


func _on_WeaponTween_tween_step(object: Object, key: NodePath, ellapsed: float, value: float) -> void:
	_ui_weapon_progress_bar.value = value


func _on_UIWeaponButton_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		_ui_weapon_button.pressed = false


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	var cursor_shape := Input.CURSOR_CROSS if is_pressed else Input.CURSOR_ARROW
	Input.set_default_cursor_shape(cursor_shape)
