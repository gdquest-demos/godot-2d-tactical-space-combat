extends TileMap


var _astar: AStar2D = AStar2D.new()
var _size: Vector2 = Vector2.ZERO


func setup(rooms: Node2D, doors: Node2D) -> void:
	update_bitmask_region()
	_size = get_used_rect().size
	for node in rooms.get_children():
		if node is Room:
			for point in node:
				var id := Utils.xy_to_index(_size.x, point)
				_astar.add_point(id, point)
				for neighbor in _get_neighbors(node, point):
					_astar.add_point(neighbor.id, neighbor.point)
					_astar.connect_points(id, neighbor.id)
	for door in doors.get_children():
		var offset := cell_size / 2 * Vector2.UP
		var id1 := Utils.xy_to_index(_size.x, world_to_map(door.transform.xform(offset)))
		var id2 := Utils.xy_to_index(_size.x, world_to_map(door.transform.xform(-offset)))
		_astar.connect_points(id1, id2)


func find_path(point1: Vector2, point2: Vector2) -> Curve2D:
	var out := Curve2D.new()
	var id1 := Utils.xy_to_index(_size.x, point1)
	var id2 := Utils.xy_to_index(_size.x, point2)
	if _astar.has_point(id1) and _astar.has_point(id2):
		var path := _astar.get_point_path(id1, id2)
		for i in range(1, path.size()):
			out.add_point(map_to_world(path[i]) + cell_size / 2.0)
	return out


func _get_neighbors(room: Room, point: Vector2) -> Array:
	var out := []
	for offset in Utils.DIRECTIONS:
		offset += point
		if room.has_point(offset):
			out.push_back({
				"id": Utils.xy_to_index(_size.x, offset),
				"point": offset
			})
	return out
