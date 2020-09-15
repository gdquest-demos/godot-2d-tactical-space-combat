# As the player can only select one unit at a time,
# when a unit is selected, we need to deselect others.
# This is what this node does.
class_name ShipUnits
extends Node2D


func _ready() -> void:
	for unit in get_units():
		unit.connect("selected", self, "_on_Unit_selected", [unit])


func get_units() -> Array:
	return get_children()


func _on_Unit_selected(selected_unit: Unit) -> void:
	for unit in get_units():
		if unit == selected_unit:
			continue
		unit.is_selected = false
