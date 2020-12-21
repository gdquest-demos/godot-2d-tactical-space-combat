class_name WeaponProjectilePlayer
extends WeaponPlayer


signal projectile_exited(target_global_position)
signal targeting(index)

const Projectile := preload("Projectile.tscn")

var _target_global_position := Vector2.INF


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	._on_UIWeaponButton_toggled(is_pressed)
	if is_pressed:
		_target_global_position = Vector2.INF
	elif _target_global_position != Vector2.INF and not (is_pressed or _is_charging):
		_fire()
	emit_signal("targeting", get_index() if is_pressed else -1)


func _on_Room_targeted(targeted_by: int, target_global_position: Vector2) -> void:
	if targeted_by == get_index():
		_target_global_position = target_global_position
		_ui_weapon_button.pressed = false


func _fire():
	var projectile: RigidBody2D = Projectile.instance()
	projectile.linear_velocity = projectile.linear_velocity.rotated(rotation)
	projectile.connect(
		"tree_exited", self, "emit_signal",
		["projectile_exited", Utils.PhysicsLayers.SHIP_ENEMY, _target_global_position]
	)
	add_child(projectile)
	_set_is_charging(true)


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if _target_global_position != Vector2.INF and not _is_charging:
		_fire()
