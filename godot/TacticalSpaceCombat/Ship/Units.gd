extends Node2D

const DEFAULT_POLYGON := PoolVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])

var _is_selecting := false
var _polygon := DEFAULT_POLYGON


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouse and Input.get_current_cursor_shape() == Input.CURSOR_ARROW):
		return

	var mouse_position := get_local_mouse_position()
	if event.is_action_pressed("left_click"):
		_is_selecting = true

		for index in range(_polygon.size()):
			_polygon[index] = mouse_position

		for unit in get_children():
			unit.is_selected = false

	elif _is_selecting and event is InputEventMouseMotion:
		_polygon[1] = Vector2(mouse_position.x, _polygon[0].y)
		_polygon[2] = mouse_position
		_polygon[3] = Vector2(_polygon[0].x, mouse_position.y)

	elif event.is_action_released("left_click"):
		select_units()

		_is_selecting = false
		_polygon = DEFAULT_POLYGON

	update()


func _draw() -> void:
	draw_polygon(_polygon, [self_modulate])


func select_units() -> void:
	var query := Physics2DShapeQueryParameters.new()
	var shape := ConvexPolygonShape2D.new()
	shape.points = _polygon

	query.set_shape(shape)
	query.transform = global_transform
	query.collide_with_bodies = false
	query.collide_with_areas = true
	query.collision_layer = Global.Layers.UI

	for dict in get_world_2d().direct_space_state.intersect_shape(query):
		dict.collider.owner.is_selected = true
