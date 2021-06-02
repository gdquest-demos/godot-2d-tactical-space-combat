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

static func randvf_circle(_rng: RandomNumberGenerator, radius: float) -> Vector2:
	return (radius * Vector2.RIGHT).rotated(_rng.randf_range(0, 2 * PI))

static func erase_value(dict: Dictionary, value) -> bool:
	var out := false
	for key in dict:
		if dict[key] == value:
			out = dict.erase(key)
	return out

static func randvf_range(_rng: RandomNumberGenerator, top_left: Vector2, bottom_right: Vector2) -> Vector2:
	var x: float = lerp(top_left.x, bottom_right.x, _rng.randf())
	var y: float = lerp(top_left.y, bottom_right.y, _rng.randf())
	return Vector2(x, y)

static func randvi_range(_rng: RandomNumberGenerator, top_left: Vector2, bottom_right: Vector2) -> Vector2:
	var x := _rng.randi_range(top_left.x, bottom_right.x)
	var y := _rng.randi_range(top_left.y, bottom_right.y)
	return Vector2(x, y)
