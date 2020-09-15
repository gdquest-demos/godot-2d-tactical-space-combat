extends Control


const Unit := preload("UIUnit.tscn")

onready var units := $Units
onready var systems := $Systems
onready var weapons_list := $Systems/UIWeaponsList


func setup(weapons: Array) -> void:
	weapons_list.setup(weapons)
