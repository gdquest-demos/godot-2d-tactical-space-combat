class_name Room
extends Area2D


const GROUPS := {"selected": "selected-room"}

var units := []

var _tilemap: TileMap = null
var _tilemap_size := Vector2.ZERO
var _tilemap_area := 0
var _iter_index := 0

onready var scene_tree: SceneTree = get_tree()
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var ui_feedback: NinePatchRect = $UI/Feedback


func setup(tilemap: TileMap) -> void:
	_tilemap = tilemap
	
	_tilemap_size = _tilemap.world_to_map(2 * collision_shape.shape.extents)
	_tilemap_area = _tilemap_size.x * _tilemap_size.y
	
	ui_feedback.rect_position = global_position - collision_shape.shape.extents
	ui_feedback.rect_size = 2 * collision_shape.shape.extents


func _on_Room_mouse(has_entered: bool) -> void:
	if has_entered or not is_in_group(GROUPS.selected):
		add_to_group(GROUPS.selected) 
	else:
		remove_from_group(GROUPS.selected)
	ui_feedback.visible = has_entered


func render() -> void:
	for offset in self:
		_tilemap.set_cellv(offset, 0)


func has_point(point: Vector2) -> bool:
	var out := false
	for offset in self:
		if point.is_equal_approx(offset):
			out = true
			break
	return out


func get_slot(slots: Dictionary, unit: Unit) -> Vector2:
	var out := Vector2.ZERO
	for offset in self:
		if not offset in slots or slots[offset] == unit:
			out = offset
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
	var offset := Utils.index_to_xy(_tilemap_size.x, _iter_index)
	return tmp_transform.xform(offset)


func _iter_is_running() -> bool:
	return _iter_index < _tilemap_area
