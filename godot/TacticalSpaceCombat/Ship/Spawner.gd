extends Path2D

const POINTS_MASK := [Vector2.ZERO, Vector2.RIGHT, Vector2.ONE, Vector2.DOWN, Vector2.ZERO]


func _ready() -> void:
	if curve:
		curve.clear_points()
		var viewport_size := get_viewport_rect().size
		for point_mask in POINTS_MASK:
			var point: Vector2 = global_transform.xform_inv(point_mask * viewport_size)
			curve.add_point(point)


func interpolate(offset: float) -> Vector2:
	var out := Vector2.INF
	if curve != null and curve.get_point_count() > 1:
		out = curve.interpolate_baked(offset * curve.get_baked_length())
	return out
