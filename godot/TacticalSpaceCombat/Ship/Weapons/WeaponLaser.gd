class_name WeaponLaser
extends Weapon


const TARGETTING_LENGTH := 160

var _is_targetting := false

onready var line: Line2D = $Line2D
onready var segment_shape: SegmentShape2D = $Area2D/CollisionShape.shape


func _ready() -> void:
	line.points = [Vector2.INF, Vector2.INF]
	segment_shape.a = line.points[0]
	segment_shape.b = line.points[1]


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouse and _is_targetting):
		return
	
	if event.is_action_pressed("left_click"):
		line.points[0] = global_transform.xform_inv(event.position)
	elif line.points[0] != Vector2.INF and event is InputEventMouseMotion:
		var offset: Vector2 = global_transform.xform_inv(event.position) - line.points[0]
		offset = offset.clamped(TARGETTING_LENGTH)
		line.points[1] = line.points[0] + offset
	elif event.is_action_released("left_click"):
		line.points = [Vector2.INF, Vector2.INF]
		_ui_weapon_button.pressed = false
	
	segment_shape.a = line.points[0]
	segment_shape.b = line.points[1]


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	_is_targetting = is_pressed
	var cursor := Input.CURSOR_CROSS if is_pressed else Input.CURSOR_ARROW
	Input.set_default_cursor_shape(cursor)


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if _is_charging:
		tween.interpolate_property(_ui_weapon_progress_bar, "value", _ui_weapon_progress_bar.min_value, _ui_weapon_progress_bar.max_value, charge_time)
		tween.start()
	elif not _is_charging:
		_set_is_charging(true)
