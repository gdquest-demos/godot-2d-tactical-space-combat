class_name Unit
extends Path2D


export var colors := {
	"default": Color("3d6e70"),
	"selected": Color("3ca370")
}

var speed := 150
var strenghts := {
	"fire": 25
}
var is_selected: bool setget set_is_selected
var is_walking: bool setget set_is_walking

var _ui_unit: ColorRect
var _ui_unit_icon: NinePatchRect
var _ui_unit_feedback: NinePatchRect

onready var path_follow: PathFollow2D = $PathFollow2D
onready var area_unit: Area2D = $PathFollow2D/AreaUnit
onready var area_select: Area2D = $PathFollow2D/AreaSelect


func setup(ui_unit: ColorRect) -> void:
	_ui_unit = ui_unit
	_ui_unit_icon = ui_unit.get_node("Icon")
	_ui_unit_feedback = ui_unit.get_node("Feedback")
	
	_ui_unit.connect("gui_input", self, "_on_UIUnit_gui_input")
	_ui_unit_icon.modulate = colors.default


func _ready() -> void:
	self.is_selected = false
	self.is_walking = false


func _on_UIUnit_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		self.is_selected = true


func _on_AreaUnit_area_entered(area: Area2D) -> void:
	if area.is_in_group("door") and not area.is_open:
		self.is_walking = false


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
	var group := "selected-unit"
	
	is_selected = value
	if is_selected:
		area_unit.modulate = colors.selected
		add_to_group(group)
	else:
		area_unit.modulate = colors.default
		if is_in_group(group):
			remove_from_group(group)
	
	if _ui_unit_feedback != null:
		_ui_unit_feedback.visible = is_selected


func set_is_walking(value: bool) -> void:
	is_walking = value
	set_process(is_walking)
