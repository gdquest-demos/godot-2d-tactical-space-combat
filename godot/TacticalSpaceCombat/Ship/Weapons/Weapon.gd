extends Position2D


signal projectile_exited(Projectile)

const Projectile := preload("res://TacticalSpaceCombat/Ship/Weapons/Projectile.tscn")

var _target_position := Vector2.INF


func _on_UIWeapon_fired():
	var projectile := Projectile.instance()
	projectile.connect("tree_exited", self, "emit_signal", ["projectile_exited", Projectile, _target_position])
	add_child(projectile)


func _on_Room_targeted(is_target: bool, targeted_by: int, room_position: Vector2) -> void:
	if is_target and targeted_by == get_index():
		_target_position = room_position
	elif not is_target:
		_target_position = Vector2.INF
