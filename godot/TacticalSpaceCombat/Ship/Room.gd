class_name Room
extends Area2D


# Emitted when room is successfuly selected as target in order for the projectile weapon to know
# when to start shooting
signal targeted(target_index, target_global_position)
signal modifier_changed(type, value)

# Room type which determines boosts if any
enum Type {EMPTY, SENSORS, HELM, WEAPONS}

# Srites that go with room types. They're selected from the sprite atlas based on their region
const SPRITE := {
	Type.EMPTY: Vector2.INF,
	Type.SENSORS: Vector2(128, 384),
	Type.HELM: Vector2(160, 384),
	Type.WEAPONS: Vector2(128, 416)
}
const FOG_COLOR := Color("#ffe478")

# Easy access in the inspector to change room type
export(Type) var type := Type.EMPTY

var units := {}
var top_left := Vector2.ZERO
var bottom_right := Vector2.ZERO

var _tilemap: TileMap
var _modifiers := {
	Type.EMPTY: [0.0, 0.0],
	Type.SENSORS: [0.0, 0.0],
	Type.HELM: [0.0, 0.5],
	Type.WEAPONS: [1.0, 0.5],
}
var _target_index := -1
var _entrances := {}
var _size := Vector2.ZERO
var _area := 0
var _iter_index := 0
var _fog := {}
var _rng := RandomNumberGenerator.new()

onready var scene_tree: SceneTree = get_tree()
onready var hit_area: Area2D = $HitArea2D
onready var sprite_type: Sprite = $SpriteType
onready var sprite_target: Sprite = $SpriteTarget
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var feedback: NinePatchRect = $Feedback


func setup(tilemap: TileMap) -> void:
	_tilemap = tilemap
	
	_size = _tilemap.world_to_map(2 * collision_shape.shape.extents)
	_area = _size.x * _size.y
	
	top_left = _tilemap.world_to_map(position - collision_shape.shape.extents)
	bottom_right = top_left + _size
	
	sprite_type.visible = type != Type.EMPTY
	sprite_type.region_enabled = sprite_type.visible
	sprite_type.region_rect = Rect2(SPRITE[type], _tilemap.cell_size / 2)
	
	feedback.rect_position -= collision_shape.shape.extents
	feedback.rect_size = 2 * collision_shape.shape.extents


func _ready() -> void:
	_rng.randomize()
	_fog = {
		true: Rect2(-collision_shape.shape.extents, 2 * collision_shape.shape.extents),
		false: Rect2()
	}
	
	hit_area.collision_layer = Utils.Layers.SHIP_PLAYER if owner.is_in_group("player") else Utils.Layers.SHIP_ENEMY
	hit_area.collision_mask = hit_area.collision_layer


func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if (
		event.is_action_pressed("left_click")
		and Input.get_current_cursor_shape() == Input.CURSOR_CROSS
		and _target_index != -1
	):
		sprite_target.visible = true
		sprite_target.get_child(_target_index).visible = true
		emit_signal("targeted", _target_index, global_position)
		_target_index = -1


func _on_mouse_entered_exited(has_entered: bool) -> void:
	feedback.visible = has_entered
	var group := "selected-room"
	if has_entered:
		add_to_group(group)
	elif is_in_group(group):
		remove_from_group(group)


func _on_area_entered_exited(area: Area2D, has_entered: bool) -> void:
	if area.is_in_group("unit"):
		if has_entered:
			units[area.owner] = null
			emit_signal("modifier_changed", type, _modifiers[type][1])
		else:
			units.erase(area.owner)
			if units.empty():
				emit_signal("modifier_changed", type, _modifiers[type][0])
		update()
	elif area.is_in_group("door") and has_entered:
		var entrance := position - area.position
		entrance *= Vector2.DOWN.rotated(-area.rotation)
		entrance = entrance.normalized() * _tilemap.cell_size / 2
		entrance += area.position
		entrance = _tilemap.world_to_map(entrance)
		_entrances[entrance] = null


# When targeting is triggered by clicking the UI button we first switch off
# weapon targeting by turning off the appropriate numbered sprite (child) visibility.
# If at least one numbered sprite is visible then we also make the parent visible, otherwise
# it remains invisible
func _on_WeaponProjectile_targeting(index: int) -> void:
	_target_index = index
	if _target_index != -1:
		sprite_target.visible = false
		sprite_target.get_child(_target_index).visible = false
		for node in sprite_target.get_children():
			if node.visible:
				sprite_target.visible = true
				break


func _draw() -> void:
	var state: bool = not owner.has_sensors
	if owner.is_in_group("player"):
		state = state and units.empty()
	draw_rect(_fog[state], FOG_COLOR)


# Returns the closest entrance to the `from` location
func _get_entrance(from: Vector2) -> Vector2:
	var out := Vector2.INF
	var distance := INF
	for entrance in _entrances:
		var curve: Curve2D = _tilemap.find_path(from, entrance)
		var length := curve.get_baked_length()
		if distance > length:
			distance = length
			out = entrance
	return out


# Checks if the given point is within the bounds of the room
func has_point(point: Vector2) -> bool:
	return (
		top_left.x <= point.x and top_left.y <= point.y
		and point.x < bottom_right.x and point.y < bottom_right.y
	)


# Get available tile position (slot) for unit placement if available
func get_slot(slots: Dictionary, unit: Unit) -> Vector2:
	var out := Vector2.INF
	var entrance := _get_entrance(_tilemap.world_to_map(unit.path_follow.position))
	for i in range(0, max(_size.x, _size.y)):
		for offset in Utils.DIRECTIONS:
			offset *= i
			offset += entrance
			if has_point(offset) and not (offset in slots and slots[offset] != unit):
				out = offset
				break
		
		if not out == Vector2.INF:
			break
	return out


func get_random_vector() -> Vector2:
	var top_left_world := _tilemap.map_to_world(top_left)
	var bottom_right_world := _tilemap.map_to_world(bottom_right)
	return Utils.randvf_range(_rng, top_left_world, bottom_right_world)


func _iter_init(_arg) -> bool:
	_iter_index = 0
	return _iter_is_running()


func _iter_next(_arg) -> bool:
	_iter_index += 1
	return _iter_is_running()


func _iter_get(_arg) -> Vector2:
	var tmp_transform := transform
	tmp_transform.origin -= collision_shape.shape.extents
	tmp_transform.origin = _tilemap.world_to_map(tmp_transform.origin)
	var offset := Utils.index_to_xy(_size.x, _iter_index)
	return tmp_transform.xform(offset)


func _iter_is_running() -> bool:
	return _iter_index < _area
