class_name WeaponProjectile
extends Weapon


signal projectile_exited(target_global_position)
signal targeting(index)

const Projectile := preload("Projectile.tscn")

var _has_target := false
var _target_global_position := Vector2.INF

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
	var physics_layer = Utils.PhysicsLayers.SHIP_ENEMY if is_in_group("player") else Utils.PhysicsLayers.SHIP_PLAYER
	var projectile: RigidBody2D = Projectile.instance()
	projectile.connect(
		"tree_exited",
		self,
		"emit_signal",
		["projectile_exited", physics_layer, _target_global_position]
	)
	add_child(projectile)


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
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
