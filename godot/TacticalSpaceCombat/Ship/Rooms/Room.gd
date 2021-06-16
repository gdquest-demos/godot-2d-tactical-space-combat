tool
class_name Room
extends Area2D

signal targeted(msg)
signal modifier_changed(type, value)

enum Type { EMPTY, SENSORS, HELM, WEAPONS, MEDBAY }

const SPRITE := {
	Type.EMPTY: Vector2.INF,
	Type.SENSORS: Vector2(128, 384),
	Type.HELM: Vector2(160, 384),
	Type.WEAPONS: Vector2(128, 416),
	Type.MEDBAY: Vector2(160, 416)
}
const FOG_COLOR := Color("ffe478")

export var size := Vector2.ONE setget set_size
export (Type) var type := Type.EMPTY

var units := {}
var o2 := 100 setget set_o2

var _modifiers := {
	Type.EMPTY: [0.0, 0.0],
	Type.SENSORS: [0.0, 0.0],
	Type.HELM: [0.0, 0.5],
	Type.WEAPONS: [1.0, 2.0],
	Type.MEDBAY: [0.0, 0.0]
}
var _target_index := -1

var _rng := RandomNumberGenerator.new()
var _fog := {}

var _entrances := {}

var _area := 0
var _top_left := Vector2.ZERO
var _bottom_right := Vector2.ZERO

var _iter_index := 0

var _tilemap: TileMap = null

onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var feedback: NinePatchRect = $Feedback
onready var sprite_target: Sprite = $SpriteTarget
onready var sprite_type: Sprite = $SpriteType
onready var hit_area: Area2D = $HitArea2D
onready var o2_color_rect: ColorRect = $O2ColorRect


func setup(tilemap: TileMap) -> void:
	_tilemap = tilemap
	_setup_extents()

	_area = size.x * size.y
	_top_left = _tilemap.world_to_map(position - collision_shape.shape.extents)
	_bottom_right = _top_left + size

	feedback.rect_position -= collision_shape.shape.extents
	feedback.rect_size = 2 * collision_shape.shape.extents

	sprite_type.visible = type != Type.EMPTY
	sprite_type.region_enabled = sprite_type.visible
	sprite_type.region_rect = Rect2(SPRITE[type], _tilemap.cell_size / 2)

	o2_color_rect.rect_position = feedback.rect_position
	o2_color_rect.rect_size = feedback.rect_size


func _setup_extents() -> void:
	if _tilemap != null:
		collision_shape.shape.extents = 0.5 * _tilemap.map_to_world(size)


func _ready() -> void:
	if Engine.editor_hint:
		return

	connect("mouse_entered", self, "_on_mouse_entered_exited", [true])
	connect("mouse_exited", self, "_on_mouse_entered_exited", [false])
	connect("area_entered", self, "_on_area_entered_exited", [true])
	connect("area_exited", self, "_on_area_entered_exited", [false])
	connect("input_event", self, "_on_input_event")

	_rng.randomize()
	_fog = {
		true: Rect2(-collision_shape.shape.extents, 2 * collision_shape.shape.extents),
		false: Rect2()
	}
	hit_area.collision_mask = (
		Global.Layers.SHIPPLAYER
		if owner.is_in_group("player")
		else Global.Layers.SHIPAI
	)

	if type == Type.MEDBAY:
		var medbay_timer := Timer.new()
		medbay_timer.autostart = true
		add_child(medbay_timer)
		medbay_timer.connect("timeout", self, "_on_MedbayTimer_timeout")


func _on_input_event(_v: Viewport, event: InputEvent, _s: int) -> void:
	if (
		event.is_action_pressed("left_click")
		and Input.get_current_cursor_shape() == Input.CURSOR_CROSS
		and _target_index != -1
	):
		sprite_target.visible = true
		sprite_target.get_child(_target_index).visible = true
		emit_signal(
			"targeted",
			{
				"type": Controller.Type.PROJECTILE,
				"index": _target_index,
				"target_position": position
			}
		)
		_target_index = -1


func _on_mouse_entered_exited(has_entered: bool) -> void:
	feedback.visible = has_entered
	var group := "selected-room"
	if has_entered:
		add_to_group(group)
	elif is_in_group(group):
		remove_from_group(group)


func _on_area_entered_exited(area: Area2D, has_entered: bool) -> void:
	if area.is_in_group("door"):
		var entrance := position - area.position
		entrance = entrance.project(Vector2.DOWN.rotated(area.rotation)).normalized()
		entrance *= 0.5 * _tilemap.cell_size.x
		entrance += area.position
		entrance = _tilemap.world_to_map(entrance)
		_entrances[entrance] = null
	elif area.is_in_group("unit"):
		if has_entered:
			units[area.owner] = null
			emit_signal("modifier_changed", type, _modifiers[type][1])
		else:
			units.erase(area.owner)
			if units.empty():
				emit_signal("modifier_changed", type, _modifiers[type][0])
		update()


func _on_Controller_targeting(msg: Dictionary) -> void:
	_target_index = msg.index
	if _target_index != -1:
		sprite_target.visible = false
		sprite_target.get_child(_target_index).visible = false
		for node in sprite_target.get_children():
			if node.visible:
				sprite_target.visible = true
				break


func _on_MedbayTimer_timeout() -> void:
	for unit in units:
		unit.heal(2)


func _draw() -> void:
	if Engine.editor_hint:
		return

	var state: bool = not owner.has_sensors
	if owner.is_in_group("player"):
		state = state and units.empty()
	draw_rect(_fog[state], FOG_COLOR)


func randv() -> Vector2:
	var top_left_world := _tilemap.map_to_world(_top_left)
	var bottom_right_world := _tilemap.map_to_world(_bottom_right)
	return Utils.randvf_range(_rng, top_left_world, bottom_right_world)


func randvi() -> Vector2:
	var offset := Utils.randvi_range(_rng, _top_left, _bottom_right - Vector2.ONE)
	offset = _tilemap.map_to_world(offset) + _tilemap.cell_size / 2
	return offset


func has_point(point: Vector2) -> bool:
	return (
		_top_left.x <= point.x
		and _top_left.y <= point.y
		and point.x < _bottom_right.x
		and point.y < _bottom_right.y
	)


func set_o2(value: int) -> void:
	o2 = clamp(value, 0, 100)
	o2_color_rect.color.a = lerp(0.5, 0, o2 / 100.0)


func set_size(value: Vector2) -> void:
	for axis in [Vector2.AXIS_X, Vector2.AXIS_Y]:
		size[axis] = max(1, value[axis])
	_setup_extents()


func get_slot(slots: Dictionary, unit: Unit) -> Vector2:
	var out := Vector2.INF
	var entrance := _get_entrance(_tilemap.world_to_map(unit.path_follow.position))

	var valid_positions := []
	for offset in self:
		valid_positions.push_back([offset, offset.distance_to(entrance)])
	valid_positions.sort_custom(self, "sort_by_second_index")

	for data in valid_positions:
		var offset: Vector2 = data[0]
		if not (offset in slots and slots[offset] != unit):
			out = offset
			break
	return out


static func sort_by_second_index(a: Array, b: Array) -> bool:
	return a[1] < b[1]


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


func _iter_init(_arg) -> bool:
	_iter_index = 0
	return _iter_is_running()


func _iter_next(_arg) -> bool:
	_iter_index += 1
	return _iter_is_running()


func _iter_get(_arg) -> Vector2:
	var offset := Utils.index_to_xy(size.x, _iter_index)
	return _top_left + offset


func _iter_is_running() -> bool:
	return _iter_index < _area
