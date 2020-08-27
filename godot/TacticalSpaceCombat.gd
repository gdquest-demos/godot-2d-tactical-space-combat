extends Node2D


const UIUnit := preload("res://TacticalSpaceCombat/UI/Unit.tscn")

var slots := {}

onready var scene_tree: SceneTree = get_tree()
onready var ship: Node2D = $Ship
onready var rooms: Node2D = $Ship/Rooms
onready var units: Node2D = $Ship/Units
onready var tilemap: TileMap = $Ship/TileMap
onready var ui: CanvasLayer = $UI


func _ready() -> void:
	for room in rooms.get_children():
		room.setup(tilemap)
		room.render()
	
	tilemap.setup()
	
	yield(scene_tree, "idle_frame")
	for unit in units.get_children():
		var position_map := tilemap.world_to_map(unit.path_follow.position)
		slots[position_map] = unit
		var ui_unit := UIUnit.instance()
		ui_unit.connect("selected", self, "_on_UIUnit_selected")
		ui_unit.connect("selected", unit, "_on_UIUnit_selected")
		unit.connect("selected", ui_unit, "_on_Unit_selected")
		ui.get_node("Units").add_child(ui_unit)
		ui_unit.setup(unit.colors.default)


func _on_UIUnit_selected() -> void:
	for unit in units.get_children():
		unit.is_selected = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_RIGHT:
		for unit in scene_tree.get_nodes_in_group(Unit.GROUPS.selected):
			var point1: Vector2 = tilemap.world_to_map(unit.path_follow.position)
			for room in scene_tree.get_nodes_in_group(Room.GROUPS.selected):
				var point2: Vector2 = room.get_slot(slots, unit)
				if point2 in slots and slots[point2] == unit:
					break
				
				var path: PoolVector2Array = tilemap.find_path(point1, point2)
				unit.walk(path)
				if path:
					slots.erase(point1)
					slots[point2] = unit
