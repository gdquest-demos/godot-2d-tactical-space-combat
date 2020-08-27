class_name Unit
extends Path2D


signal selected(is_selected)

const GROUPS := {
	"main": "unit",
	"selected": "selected-unit"
}

export var colors := {
	"default": Color("3d6e70"),
	"selected": Color("3ca370")
}

var speed := 150
var is_selected: bool setget set_is_selected
var is_walking: bool setget set_is_walking

var _has_mouse_over := false

onready var path_follow: PathFollow2D = $PathFollow2D
onready var body: Sprite = $PathFollow2D/Body
onready var area_unit: Area2D = $PathFollow2D/AreaUnit


func _ready() -> void:
	Events.connect("door_opened", self, "set_is_walking", [true])
	area_unit.add_to_group(GROUPS.main)
	self.is_selected = false
	self.is_walking = false


func _on_AreaSelect_mouse(has_entered: bool) -> void:
	_has_mouse_over = has_entered


func _on_AreaUnit_area_entered(area: Area2D) -> void:
	if area.is_in_group("door"):
		self.is_walking = false


func _on_UIUnit_selected() -> void:
	self.is_selected = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		self.is_selected = _has_mouse_over


func _process(delta: float) -> void:
	path_follow.offset += speed * delta
	if path_follow.offset >= curve.get_baked_length():
		self.is_walking = false


func walk(path: PoolVector2Array) -> void:
	if path.empty():
		return

	curve.clear_points()
	curve.add_point(path_follow.position)
	for point in path:
		curve.add_point(point)

	path_follow.offset = 0
	self.is_walking = true


func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		body.modulate = colors.selected
		add_to_group(GROUPS.selected)
		
	else:
		body.modulate = colors.default
		if is_in_group(GROUPS.selected):
			remove_from_group(GROUPS.selected)
	emit_signal("selected", is_selected)


func set_is_walking(value: bool) -> void:
	is_walking = value
	set_process(is_walking)
