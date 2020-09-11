extends Position2D


signal projectile_exited(Projectile)

const Projectile := preload("res://TacticalSpaceCombat/Ship/Weapons/Projectile.tscn")

var _target_global_position := Vector2.INF


# Add the projectile to scene tree and after it exits we emit "projectile_exited" so we can trigger
# a new projectile creation in the enemy viewport.
func _on_UIWeapon_fired():
	var projectile := Projectile.instance()
	projectile.connect("tree_exited", self, "emit_signal", ["projectile_exited", Projectile, _target_global_position])
	add_child(projectile)


# Save room position in case player want to target a new room while projectile already fired
func _on_Room_targeted(targeted_by: int, target_global_position: Vector2) -> void:
	if targeted_by == get_index():
		_target_global_position = target_global_position
