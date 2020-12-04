extends CenterContainer


const MAIN_SCENE := "res://TacticalSpaceCombat.tscn"

onready var scene_tree: SceneTree = get_tree()
onready var label: Label = $VBoxContainer/Label


func _ready() -> void:
	label.text = "You %s!" % ("Won" if Global.winner_is_player else "Lost")


func _on_RetryButton_pressed() -> void:
	scene_tree.change_scene(MAIN_SCENE)
