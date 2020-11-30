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
		var neighbors: Array = fire.get_neightbor_positions()
		var index := _rng.randi_range(0, neighbors.size() - 1)
		add_fire(neighbors[index])


func _on_Fire_tree_exited(position: Vector2) -> void:
	_slots.erase(position)


func add_fire(offset: Vector2) -> void:
	if offset in _slots:
		return
	
	var fire := Fire.instance()
	fire.position = offset
	fire.connect("tree_exited", self, "_on_Fire_tree_exited", [fire.position])
	fire.setup(_tilemap)
	add_child(fire)
	_slots[fire.position] = null


func get_fires() -> Array:
	var out := []
	for node in get_children():
		if not node is Timer:
			out.append(node)
	return out
