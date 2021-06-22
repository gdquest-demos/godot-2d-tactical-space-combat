extends CenterContainer

const MAIN_SCENE := "res://TacticalSpaceCombat.tscn"

onready var label: Label = $VBoxContainer/Label
onready var button_retry: Button = $VBoxContainer/ButtonRetry
onready var button_quit: Button = $VBoxContainer/ButtonQuit


func _ready() -> void:
	button_retry.connect("pressed", get_tree(), "change_scene", [MAIN_SCENE])
	button_quit.connect("pressed", get_tree(), "quit")
	label.text = "You %s!" % ("Won" if Global.winner_is_player else "Lost")
