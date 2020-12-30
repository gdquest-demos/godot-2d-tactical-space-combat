class_name WeaponEnemyProjectile
extends WeaponEnemy


signal projectile_exited(physics_layer, target_position, params)
signal targeting(index)

const Projectile := preload("Projectile.tscn")

export(float, 0, 1) var chance_fire := 0.1
export(float, 0, 1) var chance_hull_damage := 0.5
export(int, 0, 5) var attack := 2

var _target_position := Vector2.INF


func _ready() -> void:
	yield(get_tree(), "idle_frame")
	emit_signal("targeting", get_index())


func _on_Room_targeted(targeted_by: int, target_position: Vector2) -> void:
	if targeted_by == get_index():
		print(name, target_position)
		_target_position = target_position


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
		["projectile_exited", Utils.Layers.SHIP_PLAYER, _target_position, params]
	)
	add_child(projectile)
	_set_is_charging(true)


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if _target_position != Vector2.INF and not _is_charging:
		_fire()
