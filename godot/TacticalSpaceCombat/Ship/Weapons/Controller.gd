class_name Controller
extends Node2D


signal targeting(msg)

onready var weapon: Weapon = $Weapon


func _ready() -> void:
	match get_class():
		"ContollerPlayerProjectile":
			weapon.physics_layer = Utils.Layers.SHIP_ENEMY
		"ContollerAIProjectile":
			weapon.physics_layer = Utils.Layers.SHIP_PLAYER


func _on_Ship_targeted(msg: Dictionary) -> void:
	print(owner.name)
	match msg:
		{"index": var index, "target_position": var target_position}:
			if index == get_index():
				weapon.target_position = target_position
		{"points": var points}:
			weapon.points = points
