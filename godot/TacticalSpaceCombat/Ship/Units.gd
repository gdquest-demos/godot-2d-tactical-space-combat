extends Node2D


const COLLISION_LAYER := Utils.Layers.UI
const DEFAULT_POLYGON := PoolVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])

var _is_pressed := false
var _polygon := DEFAULT_POLYGON


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouse or Input.get_current_cursor_shape() == Input.CURSOR_CROSS:
		return
	
	var mouse_position: Vector2 = global_transform.inverse().xform(event.position)
	if event.is_action_pressed("left_click"):
		_is_pressed = true
		for index in range(_polygon.size()):
			_polygon[index] = mouse_position
	elif _is_pressed and event is InputEventMouseMotion:
		_polygon[1] = Vector2(mouse_position.x, _polygon[0].y)
		_polygon[2] = mouse_position
		_polygon[3] = Vector2(_polygon[0].x, mouse_position.y)
	elif event.is_action_released("left_click"):
		_is_pressed = false
		var query := Physics2DShapeQueryParameters.new()
		var shape := ConvexPolygonShape2D.new()
		shape.points = _polygon
		query.set_shape(shape)
		query.transform = global_transform
		query.collide_with_bodies = false
		query.collide_with_areas = true
		query.collision_layer = COLLISION_LAYER
		for dict in get_world_2d().direct_space_state.intersect_shape(query):
			dict.collider.owner.is_selected = true
		_polygon = DEFAULT_POLYGON
	update()


func _draw() -> void:
	draw_polygon(_polygon, [self_modulate])
