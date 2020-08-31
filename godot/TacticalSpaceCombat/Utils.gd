class_name Utils


const DIRECTIONS := [
	Vector2.UP,
	Vector2.RIGHT + Vector2.UP,
	Vector2.RIGHT,
	Vector2.RIGHT + Vector2.DOWN,
	Vector2.DOWN,
	Vector2.LEFT + Vector2.DOWN,
	Vector2.LEFT,
	Vector2.LEFT + Vector2.UP
]


static func xy_to_index(width: int, offset: Vector2) -> int:
	return int(offset.x + width * offset.y)


static func index_to_xy(width: int, index: int) -> Vector2:
	return Vector2(index % width, index / width)


static func group_name(base: String, suffix: String = "") -> String:
	return "%s-%s" % [base, suffix] if suffix != "" else base


static func manhattan(point1: Vector2, point2: Vector2) -> float:
	var diff := (point2 - point1).abs()
	return diff.x + diff.y


static func erase_val(dict: Dictionary, val) -> bool:
	var out := false
	for key in dict:
		if dict[key] == val:
			out = dict.erase(key)
	return out
