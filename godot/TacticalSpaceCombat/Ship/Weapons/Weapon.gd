class_name Weapon
extends Sprite


export var weapon_name := ''
export var charge_time := 2.0
export(int, 0, 5) var attack := 2

var modifier := 1.0

var _is_charging := false setget _set_is_charging
var _min_charge := 0
var _max_charge := 100
var _charge := _min_charge setget _set_charge
var _ui_weapon: VBoxContainer = null
var _ui_weapon_button: Button = null
var _ui_weapon_progress_bar: ProgressBar = null

onready var scene_tree: SceneTree = get_tree()
onready var tween: Tween = $Tween


func setup(ui_weapon: VBoxContainer) -> void:
	_ui_weapon = ui_weapon
	_ui_weapon_button = ui_weapon.get_node("Button")
	_ui_weapon_progress_bar = ui_weapon.get_node("ProgressBar")
	
	_ui_weapon_button.connect("gui_input", self, "_on_UIWeaponButton_gui_input")
	_ui_weapon_button.connect("toggled", self, "_on_UIWeaponButton_toggled")
	
	_ui_weapon_button.text = weapon_name
	_set_is_charging(true)


func _ready() -> void:
	tween.connect("tween_all_completed", self, "_set_is_charging", [false])


func _on_UIWeaponButton_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		_ui_weapon_button.pressed = false


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	Input.set_default_cursor_shape(Input.CURSOR_CROSS if is_pressed else Input.CURSOR_ARROW)


func _set_is_charging(value: bool) -> void:
	_is_charging = value
	if _is_charging:
		tween.interpolate_property(self, "_charge", _min_charge, _max_charge, charge_time * modifier)
		tween.start()


func _set_charge(value: int) -> void:
	_charge = value
	if owner.is_in_group("player"):
		_ui_weapon_progress_bar.value = _charge
