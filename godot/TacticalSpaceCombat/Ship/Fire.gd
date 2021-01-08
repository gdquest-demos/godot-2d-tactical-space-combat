extends Sprite


export(int, 0, 4) var attack := 1
export(float, 0.0, 1.0) var chance_attack := 0.1

var _tilemap: TileMap
var _hitpoints := 100 setget _set_hitpoints

onready var animation_tree: AnimationTree = $AnimationTree


func setup(tilemap: TileMap) -> void:
	_tilemap = tilemap


func take_damage(value: int) -> void:
	_set_hitpoints(_hitpoints - value)


func get_neightbor_positions() -> Array:
	var out := []
	var point1 := _tilemap.world_to_map(position)
	for offset in Utils.DIRECTIONS:
		var point2: Vector2 = point1 + offset
		if point2.x < 0 or point2.y < 0:
			continue
		
		var curve: Curve2D = _tilemap.find_path(point1, point2)
		if curve.get_point_count() == 1:
			out.append_array(curve.get_baked_points())
	return out


func _set_hitpoints(value: int) -> void:
	_hitpoints = value
	animation_tree.set("parameters/conditions/high_to_medium", _hitpoints <= 70)
	animation_tree.set("parameters/conditions/medium_to_low", _hitpoints <= 30)
	if _hitpoints <= 0:
		queue_free()
