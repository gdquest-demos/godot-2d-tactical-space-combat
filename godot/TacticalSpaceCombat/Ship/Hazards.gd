extends Node2D

var _rng := RandomNumberGenerator.new()
var _slots := {}


func _on_Hazard_tree_exited(hazard_position: Vector2) -> void:
	_slots.erase(hazard_position)


func add(hazard_scene: PackedScene, offset: Vector2) -> Node:
	var out: Node = null
	if not offset in _slots:
		var hazard := hazard_scene.instance()
		hazard.position = offset
		hazard.connect("tree_exited", self, "_on_Hazard_tree_exited", [hazard.position])
		add_child(hazard)
		if hazard is Fire:
			var index := 0
			for child in get_children():
				if child is Fire:
					index += 1
				else:
					break
			move_child(hazard, index)
		_slots[hazard.position] = null
		out = hazard
	return out
