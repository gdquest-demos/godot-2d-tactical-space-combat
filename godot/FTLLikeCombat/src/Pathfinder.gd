class_name FTLLikePathFinder


const NEIGHBORS := [
	Vector2.UP,
	Vector2.RIGHT + Vector2.UP,
	Vector2.RIGHT,
	Vector2.RIGHT + Vector2.DOWN,
	Vector2.DOWN,
	Vector2.LEFT + Vector2.DOWN,
	Vector2.LEFT,
	Vector2.LEFT + Vector2.UP
]

var _astar: AStar2D = AStar2D.new()

var _tilemap: TileMap = null
var _tilemap_size: Vector2 = Vector2.ZERO


func setup(tilemap: TileMap) -> void:
	_tilemap = tilemap
	_tilemap_size = _tilemap.get_used_rect().size

	for point in _tilemap.get_used_cells():
		var id := FTLLikeUtils.xy_to_index(_tilemap_size.x, point)
		_astar.add_point(id, point)

	for id1 in _astar.get_points():
		for id2 in _get_neighbors(id1):
			_astar.connect_points(id1, id2)


func find_path(point1: Vector2, point2: Vector2) -> PoolVector2Array:
	var id1 := FTLLikeUtils.xy_to_index(_tilemap_size.x, _tilemap.world_to_map(point1))
	var id2 := FTLLikeUtils.xy_to_index(_tilemap_size.x, _tilemap.world_to_map(point2))
	return _astar.get_point_path(id1, id2)


func _get_neighbors(id: int) -> Array:
	var out := []

	var point := FTLLikeUtils.index_to_xy(_tilemap_size.x, id)
	for offset in NEIGHBORS:
		var skip := (
			_tilemap.get_cellv(point + offset) == TileMap.INVALID_CELL
			and is_equal_approx(offset.dot(offset), 2)
			or _tilemap.get_cellv(point + Vector2(offset.x, 0)) == TileMap.INVALID_CELL
			or _tilemap.get_cellv(point + Vector2(0, offset.y)) == TileMap.INVALID_CELL
		)
		if not skip:
			out.push_back(FTLLikeUtils.xy_to_index(_tilemap_size.x, point + offset))

	return out
