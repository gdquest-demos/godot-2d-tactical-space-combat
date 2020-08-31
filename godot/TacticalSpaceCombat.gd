extends Node2D


const UIUnit := preload("res://TacticalSpaceCombat/UI/Unit.tscn")

var slots := {}

onready var scene_tree: SceneTree = get_tree()
onready var ship: Node2D = $Ship
onready var rooms: Node2D = $Ship/Rooms
onready var doors: Node2D = $Ship/Doors
onready var units: Node2D = $Ship/Units
onready var tilemap: TileMap = $Ship/TileMap
onready var ui: CanvasLayer = $UI


func _ready() -> void:
	for room in rooms.get_children():
		room.setup(tilemap)
		for point in room:
			tilemap.set_cellv(point, 0)
	tilemap.setup(rooms, doors)
	
	for unit in units.get_children():
		var position_map := tilemap.world_to_map(unit.path_follow.position)
		slots[position_map] = unit
		
		var ui_unit := UIUnit.instance()
		ui_unit.connect("selected", self, "_on_UIUnit_selected")
		ui_unit.connect("selected", unit, "set_is_selected", [true])
		unit.connect("selected", ui_unit, "_on_Unit_selected")
		ui.get_node("Units").add_child(ui_unit)
		ui_unit.setup(unit.colors.default)


func _on_UIUnit_selected() -> void:
	for unit in units.get_children():
		unit.is_selected = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_RIGHT:
		var group := Utils.group_name("selected", "unit")
		for unit in scene_tree.get_nodes_in_group(group):
			var point1: Vector2 = tilemap.world_to_map(unit.path_follow.position)
			group = Utils.group_name("selected", "room")
			for room in scene_tree.get_nodes_in_group(group):
				var point2: Vector2 = room.get_slot(slots, unit)
				if is_inf(point2.x):
					break
				
				var path: Curve2D = tilemap.find_path(point1, point2)
				unit.walk(path)
				Utils.erase_val(slots, unit)
				slots[point2] = unit
