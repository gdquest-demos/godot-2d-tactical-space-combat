extends Node2D


# This dictionary keeps track of the crew locations.
var slots := {}

onready var scene_tree: SceneTree = get_tree()
onready var tilemap: TileMap = $TileMap
onready var rooms: Node2D = $Rooms
onready var doors: Node2D = $Doors
onready var weapons: Node2D = $Weapons
onready var units: Node2D = $Units


func _ready() -> void:
	if has_node("Shield"):
		var shield: Area2D = $Shield
		shield.setup(rooms)
	
	for unit in units.get_children():
		for door in doors.get_children():
			door.connect("opened", unit, "set_is_walking", [true])
		
		# store position of unit
		var position_map := tilemap.world_to_map(unit.path_follow.position)
		slots[position_map] = unit
	
	for room in rooms.get_children():
		room.setup(tilemap)
		for point in room:
			tilemap.set_cellv(point, 0)
	tilemap.setup(rooms, doors)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		for unit in units.get_children():
			unit.is_selected = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		for unit in scene_tree.get_nodes_in_group("selected-unit"):
			var point1: Vector2 = tilemap.world_to_map(unit.path_follow.position)
			for room in scene_tree.get_nodes_in_group("selected-room"):
				var point2: Vector2 = room.get_slot(slots, unit)
				if is_inf(point2.x):
					break
				
				var path: Curve2D = tilemap.find_path(point1, point2)
				Utils.erase_value(slots, unit)
				slots[point2] = unit
				unit.walk(path)
