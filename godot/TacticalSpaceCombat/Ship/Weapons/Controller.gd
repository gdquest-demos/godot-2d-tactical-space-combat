class_name Controller
extends Node2D

signal targeting(msg)

enum Type {PROJECTILE, LASER}

onready var weapon: Weapon = null if Engine.editor_hint else $Weapon


func _on_Ship_targeted(msg: Dictionary) -> void:
	match msg:
		{"type": Type.PROJECTILE, ..}:
			if msg.index == get_index():
				weapon.target_position = msg.target_position
		{"type": Type.LASER, "success": true}:
			weapon.has_targeted = true


func _get_configuration_warning() -> String:
	return "" if has_node("Weapon") else "%s needs a Weapon child" % name
