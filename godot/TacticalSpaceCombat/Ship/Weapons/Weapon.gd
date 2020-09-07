extends Position2D


signal spawn

const Projectile := preload("res://TacticalSpaceCombat/Ship/Weapons/Projectile.tscn")


func _on_UIWeapon_fired():
	var projectile := Projectile.instance()
	projectile.connect("tree_exited", self, "emit_signal", ["spawn"])
	add_child(projectile)
