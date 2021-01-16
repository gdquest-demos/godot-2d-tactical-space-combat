extends Control


onready var label: Label = $Label
onready var animation_player: AnimationPlayer = $AnimationPlayer


func setup(attack: int, position: Vector2) -> void:
	yield(self, "ready")
	rect_position = position
	label.text = "%d" % attack
	animation_player.play("feedback")
