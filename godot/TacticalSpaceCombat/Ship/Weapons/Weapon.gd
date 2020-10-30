class_name Weapon
extends Sprite


export var weapon_name := ''

var charge_time := 2.0

var _is_charging := false setget _set_is_charging
var _ui_weapon: VBoxContainer
var _ui_weapon_button: Button
var _ui_weapon_progress_bar: ProgressBar

onready var tween: Tween = $Tween


func setup(ui_weapon: VBoxContainer) -> void:
	_ui_weapon = ui_weapon
	_ui_weapon_button = ui_weapon.get_node("Button")
	_ui_weapon_progress_bar = ui_weapon.get_node("ProgressBar")
	
	_ui_weapon_button.text = weapon_name
	_ui_weapon_button.connect("toggled", self, "_on_UIWeaponButton_toggled")
	_set_is_charging(true)


func _ready() -> void:
	tween.connect("tween_all_completed", self, "_set_is_charging", [false])


func _set_is_charging(value: bool) -> void:
	_is_charging = value
	tween.stop_all()
