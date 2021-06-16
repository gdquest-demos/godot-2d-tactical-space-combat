tool
extends Weapon

signal fired
signal projectile_exited(params)

const Projectile := preload("Projectile.tscn")

var target_position := Vector2.INF

var _physics_layer := -1


func setup(physics_layer: int) -> void:
	_physics_layer = physics_layer


func _get_configuration_warning() -> String:
	var parent := get_parent()
	var is_verified := parent != null and parent is ControllerAIProjectile or parent is ControllerPlayerProjectile
	return "" if is_verified else "WeaponProjectile needs to be a parent of Controller*Projectile"


func fire() -> void:
	if not can_fire():
		return

	self.is_charging = true
	var projectile: RigidBody2D = Projectile.instance()
	projectile.linear_velocity = projectile.linear_velocity.rotated(global_rotation)
	var params := {
		"physics_layer": _physics_layer,
		"target_position": target_position,
		"chance_fire": chance_fire,
		"chance_hull_breach": chance_hull_breach,
		"attack": attack
	}
	projectile.connect("tree_exited", self, "emit_signal", ["projectile_exited", params])
	add_child(projectile)
	emit_signal("fired")


func can_fire() -> bool:
	return not is_charging and target_position != Vector2.INF
