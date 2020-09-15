class_name Unit
extends Path2D

signal selected
signal selection_toggled(is_selected)

export var colors := {"default": Color("3d6e70"), "selected": Color("3ca370")}

var speed := 150
var is_selected: bool setget set_is_selected
var is_walking: bool setget set_is_walking

var _has_mouse_over := false

onready var path_follow: PathFollow2D = $PathFollow2D
onready var area_unit: Area2D = $PathFollow2D/AreaUnit


func _ready() -> void:
	self.is_selected = false
	self.is_walking = false


func _on_AreaSelect_mouse(has_entered: bool) -> void:
	_has_mouse_over = has_entered


func _on_AreaUnit_area_entered(area: Area2D) -> void:
	if area.is_in_group("door") and not area.is_open:
		self.is_walking = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		self.is_selected = _has_mouse_over


func _process(delta: float) -> void:
	path_follow.offset += speed * delta
	if path_follow.offset >= curve.get_baked_length():
		self.is_walking = false


func walk(path: Curve2D) -> void:
	if path.get_point_count() == 0:
		return
	curve = path
	curve.add_point(path_follow.position, Vector2.ZERO, Vector2.ZERO, 0)
	path_follow.offset = 0
	self.is_walking = true


func set_is_selected(value: bool) -> void:
	is_selected = value

	if is_selected:
		emit_signal("selected")
		area_unit.modulate = colors.selected
		add_to_group("selected-unit")
	else:
		area_unit.modulate = colors.default
		if is_in_group("selected-unit"):
			remove_from_group("selected-unit")
	emit_signal("selection_toggled", is_selected)


func set_is_walking(value: bool) -> void:
	is_walking = value
	set_process(is_walking)
