class_name WeaponProjectile
extends Weapon


signal projectile_exited(target_global_position)
signal targeting(index)

const Projectile := preload("Projectile.tscn")

var _has_target := false
var _target_global_position := Vector2.INF


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	._on_UIWeaponButton_toggled(is_pressed)
	if is_pressed:
		_has_target = false
	elif _has_target and not (is_pressed or _is_charging):
		_fire()
	emit_signal("targeting", get_index() if is_pressed else -1)


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
	_set_is_charging(true)


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if _has_target and not _is_charging:
		_fire()
