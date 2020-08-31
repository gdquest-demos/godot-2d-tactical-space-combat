extends Node2D


const UIUnit := preload("res://TacticalSpaceCombat/UI/Unit.tscn")

onready var ship: Node2D = $Ship
onready var ui: CanvasLayer = $UI


func _ready() -> void:
	for unit in ship.units.get_children():
		var ui_unit := UIUnit.instance()
		ui_unit.connect("selected", self, "_on_UIUnit_selected")
		ui_unit.connect("selected", unit, "set_is_selected", [true])
		unit.connect("selected", ui_unit, "_on_Unit_selected")
		ui.get_node("Units").add_child(ui_unit)
		ui_unit.setup(unit.colors.default)


func _on_UIUnit_selected() -> void:
	for unit in ship.units.get_children():
		unit.is_selected = false
