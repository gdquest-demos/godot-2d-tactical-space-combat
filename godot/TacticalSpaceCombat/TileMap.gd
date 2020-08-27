extends TileMap


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
var _size: Vector2 = Vector2.ZERO


func setup() -> void:
	update_bitmask_region()
	_size = get_used_rect().size
	for point in get_used_cells():
		var id := Utils.xy_to_index(_size.x, point)
		_astar.add_point(id, point)

	for id1 in _astar.get_points():
		for id2 in _get_neighbors(id1):
			_astar.connect_points(id1, id2)


func find_path(point1: Vector2, point2: Vector2) -> PoolVector2Array:
	var out: PoolVector2Array = []
	var id1 := Utils.xy_to_index(_size.x, point1)
	var id2 := Utils.xy_to_index(_size.x, point2)
	if _astar.has_point(id1) and _astar.has_point(id2):
		var path := _astar.get_point_path(id1, id2)
		for i in range(1, path.size()):
			out.push_back(map_to_world(path[i]) + cell_size / 2.0)
	return out


func _get_neighbors(id: int) -> Array:
	var out := []
	var point := Utils.index_to_xy(_size.x, id)
	for offset in NEIGHBORS:
		var skip := (
			get_cellv(point + offset) == INVALID_CELL
			and is_equal_approx(offset.dot(offset), 2)
			or get_cellv(point + Vector2(offset.x, 0)) == INVALID_CELL
			or get_cellv(point + Vector2(0, offset.y)) == INVALID_CELL
		)
		if not skip:
			out.push_back(Utils.xy_to_index(_size.x, point + offset))
	return out
