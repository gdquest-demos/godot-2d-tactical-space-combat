extends CenterContainer

const MAIN_SCENE := "res://TacticalSpaceCombat.tscn"

onready var label: Label = $VBoxContainer/Label


func _ready() -> void:
	label.text = "You %s!" % ("Won" if Global.winner_is_player else "Lost")


func _on_RetryButton_pressed() -> void:
	get_tree().change_scene(MAIN_SCENE)


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
