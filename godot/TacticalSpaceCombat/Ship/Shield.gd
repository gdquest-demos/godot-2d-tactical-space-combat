extends Area2D


onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var polygon: Polygon2D = $Polygon2D


func _ready() -> void:
	polygon.polygon = _get_shape_points()


func _get_shape_points() -> PoolVector2Array:
	var out := PoolVector2Array()
	var weight := PI * 2 / 24.0
	var shape: CapsuleShape2D = collision_shape.shape
	for i in range(24):
		var offset := Vector2(0, 0.5 * shape.height * (-1 if i > 6 and i <= 18 else 1))
		out.push_back(shape.radius * Vector2(sin(weight * i), cos(weight * i)) + offset)
		if i == 6 or i == 18:
			out.push_back(shape.radius * Vector2(sin(weight * i), cos(weight * i)) - offset)
	return collision_shape.transform.xform(out)
