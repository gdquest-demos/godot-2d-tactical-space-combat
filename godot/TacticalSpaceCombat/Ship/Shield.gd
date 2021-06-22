tool
extends Area2D

export var powered := true setget set_powered
export var hitpoints_max := 4
export var charge_time := 5
export var radius := 300 setget set_radius
export var height := 100 setget set_height

var hitpoints := 0 setget set_hitpoints
var is_on := false

onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var polygon: Polygon2D = $Polygon2D
onready var timer: Timer = $Timer


func setup(mean_position: Vector2, mask: int) -> void:
	position = mean_position
	collision_mask = mask


func _ready() -> void:
	if Engine.editor_hint:
		return

	connect("body_entered", self, "_on_body_entered")
	timer.connect("timeout", self, "_on_Timer_timeout")
	polygon.self_modulate.a = 0
	polygon.polygon = _get_shape_points()
	timer.wait_time = charge_time
	if powered:
		timer.start()


func _on_Timer_timeout() -> void:
	self.hitpoints += 1


func _on_body_entered(body: Node) -> void:
	if is_on:
		self.hitpoints -= 1
		timer.start()
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


func set_powered(value: bool) -> void:
	if Engine.editor_hint:
		return

	powered = value
	self.hitpoints = 0
	if timer != null:
		timer.call("start" if powered else "stop")


func set_radius(value: int) -> void:
	radius = value
	if collision_shape != null:
		collision_shape.shape.radius = radius


func set_height(value: int) -> void:
	height = value
	if collision_shape != null:
		collision_shape.shape.height = height


func set_hitpoints(value: int) -> void:
	hitpoints = clamp(value, 0, hitpoints_max)
	timer.call("stop" if hitpoints == hitpoints_max else "start")
	is_on = hitpoints > 0
	polygon.self_modulate.a = hitpoints / float(hitpoints_max)
