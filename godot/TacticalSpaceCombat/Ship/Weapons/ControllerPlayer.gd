class_name ControllerPlayer
extends Controller

var _ui_weapon_button: Button
var _ui_weapon_progress_bar: ProgressBar


func setup(ui_weapon: VBoxContainer) -> void:
	_ui_weapon_button = ui_weapon.get_node("Button")
	_ui_weapon_progress_bar = ui_weapon.get_node("ProgressBar")
	_ui_weapon_progress_bar.min_value = Weapon.MIN_CHARGE
	_ui_weapon_progress_bar.max_value = Weapon.MAX_CHARGE

	_ui_weapon_button.connect("toggled", self, "_on_UIWeaponButton_toggled")
	_ui_weapon_button.text = weapon.weapon_name


func _ready() -> void:
	weapon.tween.connect("tween_step", self, "_on_WeaponTween_tween_step")


func _input(event: InputEvent) -> void:
	if (
		event.is_action("right_click")
		and _ui_weapon_button.pressed
		and Input.get_current_cursor_shape() == Input.CURSOR_CROSS
	):
		_ui_weapon_button.pressed = false


func _on_WeaponTween_tween_step(_o: Object, _k: NodePath, _e: float, value: float) -> void:
	_ui_weapon_progress_bar.value = value


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	var cursor_shape := Input.CURSOR_CROSS if is_pressed else Input.CURSOR_ARROW
	Input.set_default_cursor_shape(cursor_shape)
