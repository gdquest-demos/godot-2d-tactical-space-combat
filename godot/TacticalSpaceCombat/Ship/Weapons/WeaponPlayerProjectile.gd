class_name WeaponPlayerProjectile
extends WeaponPlayer


signal projectile_exited(physics_layer, target_global_position, params)
signal targeting(index)

const Projectile := preload("Projectile.tscn")

export(float, 0, 1) var chance_fire := 0.1
export(float, 0, 1) var chance_hull_damage := 0.5
export(int, 0, 5) var attack := 2

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
	var params := {
		"chance_fire": chance_fire,
		"chance_hull_damage": chance_hull_damage,
		"attack": attack
	}
	var projectile: RigidBody2D = Projectile.instance()
	projectile.linear_velocity = projectile.linear_velocity.rotated(rotation)
	projectile.connect(
		"tree_exited", self, "emit_signal",
		["projectile_exited", Utils.Layers.SHIP_ENEMY, _target_global_position, params]
	)
	add_child(projectile)
	_set_is_charging(true)


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if _target_global_position != Vector2.INF and not _is_charging:
		_fire()
