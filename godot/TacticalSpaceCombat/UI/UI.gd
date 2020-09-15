extends Control

onready var ui_units := $UIUnitsList
onready var weapons_list := $Systems/UIWeaponsList


func setup(weapons: Array, units: Array) -> void:
	weapons_list.setup(weapons)
	ui_units.setup(units)
