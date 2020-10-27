extends Position2D


signal projectile_exited(Projectile)
signal targeting(index)

const Projectile := preload("res://TacticalSpaceCombat/Ship/Weapons/Projectile.tscn")

var charge_time := 2.0

var _has_target := false
var _is_charging := false setget _set_is_charging
var _target_global_position := Vector2.INF
var _ui_weapon: VBoxContainer
var _ui_weapon_button: Button
var _ui_weapon_progress_bar: ProgressBar

onready var tween: Tween = $Tween


func setup(ui_weapon: VBoxContainer) -> void:
	_ui_weapon = ui_weapon
	_ui_weapon_button = ui_weapon.get_node("Button")
	_ui_weapon_progress_bar = ui_weapon.get_node("ProgressBar")
	
	_ui_weapon_button.connect("toggled", self, "_on_UIWeaponButton_toggled")
	_set_is_charging(true)


func _ready() -> void:
	tween.connect("tween_all_completed", self, "_set_is_charging", [false])


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	var cursor := Input.CURSOR_ARROW
	if is_pressed:
		_has_target = false
		cursor = Input.CURSOR_CROSS
		emit_signal("targeting", get_index())
	elif _has_target and not (is_pressed or _is_charging):
		_set_is_charging(true)
		_fire()
	Input.set_default_cursor_shape(cursor)


func _on_Room_targeted(targeted_by: int, target_global_position: Vector2) -> void:
	if targeted_by == get_index():
		_target_global_position = target_global_position
		_has_target = true
		_ui_weapon_button.pressed = false


func _fire():
	var projectile := Projectile.instance()
	projectile.connect(
		"tree_exited",
		self,
		"emit_signal",
		["projectile_exited", Projectile, _target_global_position]
	)
	add_child(projectile)


func _set_is_charging(val: bool) -> void:
	_is_charging = val
	tween.stop_all()
	if _is_charging:
		tween.interpolate_property(
			_ui_weapon_progress_bar,
			"value",
			_ui_weapon_progress_bar.min_value,
			_ui_weapon_progress_bar.max_value,
			charge_time
		)
		tween.start()
	elif _has_target and not _is_charging:
		_set_is_charging(true)
		_fire()
