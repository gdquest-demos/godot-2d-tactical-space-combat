class_name Controller
extends Node2D

signal targeting(msg)

enum Type {PROJECTILE, LASER}

onready var weapon: Weapon = $Weapon


func _on_Ship_targeted(msg: Dictionary) -> void:
	match msg:
		{"type": Type.PROJECTILE, ..}:
			if msg.index == get_index():
				weapon.target_position = msg.target_position
		{"type": Type.LASER, ..}:
			weapon.has_targeted = true
