class_name Room
extends Area2D

enum Type { EMPTY, DEFAULT, HELM, WEAPONS }

const SPRITE := {
	Type.EMPTY: Vector2.INF,
	Type.DEFAULT: Vector2(320, 384),
	Type.HELM: Vector2(352, 384),
	Type.WEAPONS: Vector2(384, 384)
}

export (Type) var type := Type.EMPTY

var is_manned := false setget , get_is_manned

var _units := 0
var _entrances := {}
var _tilemap: TileMap = null
var _size := Vector2.ZERO
var _area := 0
var _iter_index := 0

onready var scene_tree: SceneTree = get_tree()
onready var sprite_type: Sprite = $SpriteType
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var _outline: NinePatchRect = $Outline


func setup(tilemap: TileMap) -> void:
	_tilemap = tilemap

	_size = _tilemap.world_to_map(2 * collision_shape.shape.extents)
	_area = _size.x * _size.y

	sprite_type.visible = type != Type.EMPTY
	sprite_type.region_enabled = sprite_type.visible
	sprite_type.region_rect = Rect2(SPRITE[type], _tilemap.cell_size / 2)

	_outline.rect_position -= collision_shape.shape.extents
	_outline.rect_size = 2 * collision_shape.shape.extents


func _on_mouse_entered() -> void:
	add_to_group("selected-room")
	_outline.show()


func _on_mouse_exited() -> void:
	remove_from_group("selected-room")
	_outline.hide()


func _on_area_entered(area) -> void:
	if area is Unit:
		_units += 1
	elif area is Door:
		_update_door(area)


func _on_area_exited(area) -> void:
	if area is Unit:
		_units -= 1
	elif area is Door:
		_update_door(area)


func _update_door(area: Area2D) -> void:
	var entrance := position - area.position
	entrance *= Vector2.DOWN.rotated(-area.rotation)
	entrance = entrance.normalized() * _tilemap.cell_size / 2
	entrance += area.position
	entrance = _tilemap.world_to_map(entrance)
	_entrances[entrance] = null


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		Events.emit_signal("room_clicked", self)


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


func has_point(point: Vector2) -> bool:
	var top_left := _tilemap.world_to_map(position - collision_shape.shape.extents)
	var bottom_right := top_left + _size
	return (
		top_left.x <= point.x
		and top_left.y <= point.y
		and point.x < bottom_right.x
		and point.y < bottom_right.y
	)


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

		if not is_inf(out.x):
			break
	return out


func get_is_manned() -> bool:
	return _units > 0


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
