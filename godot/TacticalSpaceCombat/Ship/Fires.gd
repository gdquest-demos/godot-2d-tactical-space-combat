extends Node2D


const Fire := preload("Fire.tscn")

var _tilemap: TileMap
var _rng := RandomNumberGenerator.new()
var _slots := {}


func setup(tilemap: TileMap) -> void:
	_tilemap = tilemap
	for fire in get_fires():
		fire.connect("tree_exited", self, "_on_Fire_tree_exited", [fire.position])
		fire.setup(tilemap)
		_slots[fire.position] = null


func _on_Timer_timeout() -> void:
	for fire in get_fires():
		var neighbors: Array = fire.get_neightbors()
		var index := _rng.randi_range(0, neighbors.size() - 1)
		if neighbors[index] in _slots:
			continue
		
		var fire_new := Fire.instance()
		fire_new.position = neighbors[index]
		fire_new.connect("tree_exited", self, "_on_Fire_tree_exited", [fire_new.position])
		fire_new.setup(_tilemap)
		add_child(fire_new)
		_slots[fire_new.position] = null


func _on_Fire_tree_exited(position: Vector2) -> void:
	_slots.erase(position)


func get_fires() -> Array:
	var out := []
	for node in get_children():
		if not node is Timer:
			out.append(node)
	return out
