class_name Fire
extends Hazard

export (float, 0.0, 1.0) var chance_attack := 0.1

onready var animation_tree: AnimationTree = $AnimationTree


func _set_hitpoints(value: int) -> void:
	._set_hitpoints(value)
	animation_tree.set("parameters/conditions/high_to_medium", _hitpoints <= 70)
	animation_tree.set("parameters/conditions/medium_to_low", _hitpoints <= 30)
