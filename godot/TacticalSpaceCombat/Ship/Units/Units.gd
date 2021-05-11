extends Node2D


# Default value for the `_polygon` variable to reset to when we
# stop the selection process.
const DEFAULT_POLYGON := PoolVector2Array(
	[Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
)

var _is_pressed := false
var _polygon := DEFAULT_POLYGON


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouse or Input.get_current_cursor_shape() == Input.CURSOR_CROSS:
		# Skip it entirely if `event` is something other than `InputEventMouse`
		return
	
	# `event.position` is the mouse position relative to the `Viewport`.
	# We need to calculate its inverse with `global_transform.inverse().xform()`
	# otherwise our rectangle will be relative to the `ShipTemplate` position.
	#
	# In the final version of the game, _ShipTemplate_ won't be positioned at
	# `Vector2.ZERO` so we need to do this transformation.
	var mouse_position: Vector2 = global_transform.inverse().xform(event.position)
	
	if event.is_action_pressed("left_click"):
		# When we first detect the `left_click` action pressed we assign
		# `true` to `_is_pressed`. On subsequent calls to `_unhandeld_input()`, this
		# allows us to run the code in the other branches of this if statement.
		_is_pressed = true
		
		# Assign `mouse_position` to all indices in `_polygon`. This is the starting
		# position of the rectangle.
		for index in range(_polygon.size()):
			_polygon[index] = mouse_position
		
		# Finally, on every pressed `left_click` we also deselect al _UnitPlayer_ child
		# nodes to reset the state prior to commiting to the selection rectangle.
		for unit in get_children():
			unit.is_selected = false
	
	elif _is_pressed and event is InputEventMouseMotion:
		# On mouse drag (`_is_pressed` is `true` & mouse motion is detected), update
		# the last three indices in `_polygon` with the appropriate positions based on
		# `mouse_position` such that we construct a rectangle.
		_polygon[1] = Vector2(mouse_position.x, _polygon[0].y)
		_polygon[2] = mouse_position
		_polygon[3] = Vector2(_polygon[0].x, mouse_position.y)
	
	elif event.is_action_released("left_click"):
		# After `left_click` is released we need to commit the selecction process to the
		# previously assigned `_polygon`.
		
		# We use `Physics2DShapeQueryParameters` class to identify collisions on demand.
		# That's our strategy for checking which units overlap our rectangular selection
		# region.
		var query := Physics2DShapeQueryParameters.new()
		var shape := ConvexPolygonShape2D.new()
		shape.points = _polygon
		
		# In order to ask Godot for collision information we need to adjust the `query`
		# properties. `shape` here is based on our previously calculated `_polygon` data,
		# that's how Godot knows where to look for collisions.
		query.set_shape(shape)
		query.transform = global_transform
		query.collide_with_bodies = false
		query.collide_with_areas = true
		query.collision_layer = Global.Layers.UI
		# Remember that _UnitPlayer > AreaSelecct` collision mask property is assigned to
		# `Global.Layers.UI` from the _Inspector_ in the _UnitPlayer_ scene.
		
		# After filling out the appropriate `query` parameters, we recover the collision
		# information from `World2D`'s `Physics2DDirectSpaceState` propery. The return
		# value is an array of dictionaries with collision information.
		for dict in get_world_2d().direct_space_state.intersect_shape(query):
			# `dict.collider.owner` is our _UnitPlayer_ nodes since they are the only
			# ones that meet the criteria from the `query` data.
			
			# We set `UnitPlayer.is_selected` to `true` and that's how we know which
			# units we have selected.
			dict.collider.owner.is_selected = true
		
		# Finally we reset to default values in order to terminate the selection process.
		_is_pressed = false
		_polygon = DEFAULT_POLYGON
	
	# At the very end we call `update()` to instruct Godot to call the `_draw()` function.
	# We use `_draw()` to construct the visual representation of the rectangular selection
	# based on `_polygon`.
	update()


func _draw() -> void:
	draw_polygon(_polygon, [self_modulate])
