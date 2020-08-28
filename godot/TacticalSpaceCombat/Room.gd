class_name Room
extends Area2D


var _entrances := {}
var _tilemap: TileMap = null
var _size := Vector2.ZERO
var _area := 0
var _iter_index := 0

onready var scene_tree: SceneTree = get_tree()
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var ui_feedback: NinePatchRect = $UI/Feedback


func setup(tilemap: TileMap) -> void:
	_tilemap = tilemap
	
	_size = _tilemap.world_to_map(2 * collision_shape.shape.extents)
	_area = _size.x * _size.y
	
	ui_feedback.rect_position = global_position - collision_shape.shape.extents
	ui_feedback.rect_size = 2 * collision_shape.shape.extents


func _on_mouse(has_entered: bool) -> void:
	var group := Utils.group_name("selected", "room")
	if has_entered or not is_in_group(group):
		add_to_group(group) 
	else:
		remove_from_group(group)
	ui_feedback.visible = has_entered


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("door"):
		var entrance := (position - area.position)
		entrance *= Vector2.DOWN.rotated(-area.rotation)
		entrance = entrance.normalized() * _tilemap.cell_size / 2
		entrance += area.position
		entrance = _tilemap.world_to_map(entrance)
		_entrances[entrance] = null


func has_point(point: Vector2) -> bool:
	var top_left := _tilemap.world_to_map(position - collision_shape.shape.extents)
	var bottom_right := top_left + _size
	return (
		top_left.x <= point.x and top_left.y <= point.y
		and point.x < bottom_right.x and point.y < bottom_right.y
	)


func get_slot(slots: Dictionary, unit: Unit) -> Vector2:
	var out := Vector2.INF
	for offset in self:
		if not offset in slots or slots[offset] == unit:
			out = offset
			break
	return out


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


func get_slot_new(slots: Dictionary, unit: Unit) -> Vector2:
	var out := Vector2.INF
	var entrance := _get_entrance(_tilemap.world_to_map(unit.path_follow.position))
	for i in range(0, max(_size.x, _size.y)):
		for offset in Utils.DIRECTIONS:
			offset *= i
			offset += entrance
			if has_point(offset) and not (offset in slots and slots[offset] != unit):
				out = offset
				break
		
		if not is_inf(out.x):
			break
	return out


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
