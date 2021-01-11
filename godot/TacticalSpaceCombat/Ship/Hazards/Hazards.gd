extends Node2D


var _rng := RandomNumberGenerator.new()
var _slots := {}


func _ready() -> void:
	for hazard in get_children():
		hazard.connect("tree_exited", self, "_on_Hazard_tree_exited", [hazard.position])
		_slots[hazard.position] = null


func _on_Hazard_tree_exited(hazard_position: Vector2) -> void:
	_slots.erase(hazard_position)


func add(hazard_scene: PackedScene, offset: Vector2) -> void:
	if not offset in _slots:
		var hazard := hazard_scene.instance()
		hazard.position = offset
		hazard.connect("tree_exited", self, "_on_Hazard_tree_exited", [hazard.position])
		add_child(hazard)
		if hazard is Fire:
			move_child(hazard, 0)
		_slots[hazard.position] = null
