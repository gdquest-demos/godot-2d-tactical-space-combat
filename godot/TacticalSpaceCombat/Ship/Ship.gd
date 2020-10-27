extends Node2D


var slots := {}

onready var scene_tree: SceneTree = get_tree()
onready var tilemap: TileMap = $TileMap
onready var rooms: Node2D = $Rooms
onready var doors: Node2D = $Doors
onready var weapons: Node2D = $Weapons
onready var units: Node2D = $Units
onready var shield: Area2D = $Shield


func _ready() -> void:
	for room in rooms.get_children():
		room.setup(tilemap)
		for point in room:
			tilemap.set_cellv(point, 0)
		shield.position += room.position
	shield.position /= rooms.get_child_count()
	tilemap.setup(rooms, doors)
	
	for unit in units.get_children():
		for door in doors.get_children():
			door.connect("opened", unit, "set_is_walking", [true])
		
		var position_map := tilemap.world_to_map(unit.path_follow.position)
		slots[position_map] = unit


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		for unit in units.get_children():
			unit.is_selected = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		var group := "selected-unit"
		for unit in scene_tree.get_nodes_in_group(group):
			var point1: Vector2 = tilemap.world_to_map(unit.path_follow.position)
			group = "selected-room"
			for room in scene_tree.get_nodes_in_group(group):
				var point2: Vector2 = room.get_slot(slots, unit)
				if is_inf(point2.x):
					break
				
				var path: Curve2D = tilemap.find_path(point1, point2)
				unit.walk(path)
				Utils.erase_val(slots, unit)
				slots[point2] = unit
