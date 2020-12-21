class_name WeaponProjectileEnemy
extends WeaponEnemy


signal projectile_exited(target_global_position)
signal targeting(index)

const Projectile := preload("Projectile.tscn")

var _target_global_position := Vector2.INF


func _ready() -> void:
	yield(get_tree(), "idle_frame")
	emit_signal("targeting", get_index())


func _on_Room_targeted(targeted_by: int, target_global_position: Vector2) -> void:
	if targeted_by == get_index():
		_target_global_position = target_global_position


func _fire():
	var projectile: RigidBody2D = Projectile.instance()
	projectile.linear_velocity = projectile.linear_velocity.rotated(rotation)
	projectile.connect(
		"tree_exited", self, "emit_signal",
		["projectile_exited", Utils.PhysicsLayers.SHIP_PLAYER, _target_global_position]
	)
	add_child(projectile)
	_set_is_charging(true)


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if _target_global_position != Vector2.INF and not _is_charging:
		_fire()
