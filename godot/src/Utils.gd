class_name TSCUtils


static func xy_to_index(width: int, offset: Vector2) -> int:
	return int(offset.x + width * offset.y)


static func index_to_xy(width: int, index: int) -> Vector2:
	return Vector2(index % width, index / width)
