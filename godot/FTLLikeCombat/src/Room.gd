class_name FTLLikeRoom
extends Area2D


var _tilemap: TileMap = null
var _tilemap_size := Vector2.ZERO
var _tilemap_area := 0

var _iter_index := 0

onready var collision_shape: CollisionShape2D = $CollisionShape2D


func setup(tilemap: TileMap) -> void:
	_tilemap = tilemap
	
	_tilemap_size = _tilemap.world_to_map(2 * collision_shape.shape.extents)
	_tilemap_area = _tilemap_size.x * _tilemap_size.y


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
	var offset := FTLLikeUtils.index_to_xy(_tilemap_size.x, _iter_index)
	return tmp_transform.xform(offset)


func _iter_is_running() -> bool:
	return _iter_index < _tilemap_area
