extends Control

onready var label: Label = $Label
onready var animation_player: AnimationPlayer = $AnimationPlayer

var _position := Vector2.ZERO
var _text := ""


func setup(attack: int, position: Vector2) -> void:
	_position = position
	_text = "%d" % attack


func _ready() -> void:
	rect_position = _position
	label.text = _text
	animation_player.play("feedback")
