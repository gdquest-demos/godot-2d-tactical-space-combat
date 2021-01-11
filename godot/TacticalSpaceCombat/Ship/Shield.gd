extends Area2D


signal hitpoints_changed(hitpoints)

export var hitpoints_max := 4

var hitpoints := 0 setget set_hitpoints

onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var polygon: Polygon2D = $Polygon2D
onready var timer: Timer = $Timer


func _ready() -> void:
	polygon.self_modulate.a = 0
	polygon.polygon = _get_shape_points()


func _on_Timer_timeout() -> void:
	self.hitpoints += 1


func _on_body_entered(body: Node) -> void:
	if hitpoints > 0:
		self.hitpoints -= 1
		body.animation_player.play("feedback")


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


func set_hitpoints(value: int) -> void:
	if value == hitpoints_max:
		timer.stop()
	else:
		hitpoints = clamp(value, 0, hitpoints_max)
		timer.start()
	polygon.self_modulate.a = hitpoints / float(hitpoints_max)
	emit_signal("hitpoints_changed", hitpoints)
