extends Path2D

const POINTS := 24
const VECTOR := Projectile.MAX_DISTANCE * Vector2.RIGHT


func _ready() -> void:
	for i in range(POINTS):
		var step := range_lerp(i, 0, POINTS - 1, 0, 2 * PI)
		curve.add_point(VECTOR.rotated(step))


func interpolate(offset: float) -> Vector2:
	var out := Vector2.INF
	if curve != null and curve.get_point_count() > 1:
		out = curve.interpolate_baked(offset * curve.get_baked_length())
	return out
