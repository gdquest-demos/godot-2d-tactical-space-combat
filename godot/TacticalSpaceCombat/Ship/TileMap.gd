extends TileMap


var _astar: AStar2D = AStar2D.new()
var _size: Vector2 = Vector2.ZERO


func setup(rooms: Node2D, doors: Node2D) -> void:
	# If we don't call `update_bitmask_region()` the tiles won't show up properly
	update_bitmask_region()
	# Store the size of the _TileMap_ in a global variable for easy access
	_size = get_used_rect().size
	for room in rooms.get_children():
		# Remember that we iterate over the points using our custom `Room` iterator
		for point in room:
			# Convert each point from `Vector2(x, y)` coordinates into a 1D index
			# using `Utils.xy_to_index()`. This conversion requires the width of the
			# _TileMap_ which we get from `_size.x`
			var id := Utils.xy_to_index(_size.x, point)
			# `AStar2D` requires that each `point` is associated with an `id`
			_astar.add_point(id, point)
			# For each valid `neighbor` position, we add it to the `AStar2D`
			# algorithm and connect it with the current `point` via its `id`
			for neighbor in _get_neighbors(room, point):
				var neighbor_id := Utils.xy_to_index(_size.x, neighbor)
				_astar.add_point(neighbor_id, neighbor)
				_astar.connect_points(id, neighbor_id)
	
	# We aren't done yet. Up to this point we connected all the tiles within rooms.
	# We still have to connect the valid locations between the rooms based on
	# the `door` placement
	var offset := cell_size / 2 * Vector2.UP
	for door in doors.get_children():
		var id1 := Utils.xy_to_index(_size.x, world_to_map(door.transform.xform(offset)))
		var id2 := Utils.xy_to_index(_size.x, world_to_map(door.transform.xform(-offset)))
		_astar.connect_points(id1, id2)


## Returns a `Curve2D` for units to follow.
func find_path(point1: Vector2, point2: Vector2) -> Curve2D:
	var out := Curve2D.new()
	# Given the two points we first calculate the 1D index IDs
	var id1 := Utils.xy_to_index(_size.x, point1)
	var id2 := Utils.xy_to_index(_size.x, point2)
	if _astar.has_point(id1) and _astar.has_point(id2):
		# If these are valid points in our `AStar2D` object then we
		# just get the `path` between these points
		var path := _astar.get_point_path(id1, id2)
		# We drop the first point in `path` since that's the location of
		# the unit, and add the rest to the `Curve2D`. We make sure to
		# convert to world coordinates considering the centers of the tiles
		for i in range(1, path.size()):
			out.add_point(map_to_world(path[i]) + cell_size / 2)
	return out


## Returns neighboring positions within a `room` given the input `point` location.
func _get_neighbors(room: Room, point: Vector2) -> Array:
	var out := []
	# We traverse the list of valid `DIRECTIONS`
	for offset in Utils.DIRECTIONS:
		# Since these are directions, we first need to add them to the position of
		# the `point` location.
		offset += point
		if room.has_point(offset):
			# In case the `room` contains the calculated position, it means it's a valid
			# neighboring tile so we add it to the `Array`
			out.push_back(offset)
	return out
