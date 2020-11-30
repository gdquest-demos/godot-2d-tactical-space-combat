extends Sprite


var _tilemap: TileMap
var _hitpoints := 100


func setup(tilemap: TileMap) -> void:
	_tilemap = tilemap


func take_damage(value: int) -> void:
	_hitpoints -= value
	if _hitpoints <= 0:
		queue_free()


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
