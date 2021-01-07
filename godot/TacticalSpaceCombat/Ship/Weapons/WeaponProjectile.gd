class_name WeaponProjectile
extends Weapon


signal projectile_exited(physics_layer, params)

const Projectile := preload("Projectile.tscn")

var physics_layer := -1
var target_position := Vector2.INF


func fire() -> void:
	var params := {
		"target_position": target_position,
		"chance_fire": chance_fire,
		"chance_hull_breach": chance_hull_breach,
		"attack": attack
	}
	var projectile: RigidBody2D = Projectile.instance()
	projectile.linear_velocity = projectile.linear_velocity.rotated(global_rotation)
	projectile.connect(
		"tree_exited", self, "emit_signal", ["projectile_exited", physics_layer, params]
	)
	add_child(projectile)
	self.is_charging = true


func set_is_charging(value: bool) -> void:
	.set_is_charging(value)
	if not (is_charging or target_position == Vector2.INF):
		fire()
