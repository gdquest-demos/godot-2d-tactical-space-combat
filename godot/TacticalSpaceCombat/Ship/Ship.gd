extends Node2D


signal hit_points_changed(hit_points, is_player)

export(int, 0, 30) var hit_points := 30

var evasion := 0.0
var has_sensors := false

# This dictionary keeps track of the crew locations.
var _slots := {}
var _rng := RandomNumberGenerator.new()

onready var scene_tree: SceneTree = get_tree()
onready var tilemap: TileMap = $TileMap
onready var rooms: Node2D = $Rooms
onready var fires: Node2D = $Fires
onready var doors: Node2D = $Doors
onready var weapons: Node2D = $Weapons
onready var units: Node2D = $Units


func _ready() -> void:
	_rng.randomize()
	
	for unit in units.get_children():
		for door in doors.get_children():
			door.connect("opened", unit, "set_is_walking", [true])
		
		# store position of unit
		var position_map := tilemap.world_to_map(unit.path_follow.position)
		_slots[position_map] = unit
	
	for room in rooms.get_children():
		room.setup(tilemap)
		room.connect("modifier_changed", self, "_on_Room_modifier_changed")
		room.hit_area.connect("body_entered", self, "_on_RoomHitArea2D_body_entered", [room.top_left, room.bottom_right])
		for point in room:
			tilemap.set_cellv(point, 0)
		
		if room.type == Room.Type.SENSORS:
			has_sensors = true
	
	if has_node("Shield"):
		$Shield.position = _get_mean_position()
	
	tilemap.setup(rooms, doors)
	fires.setup(tilemap)


func _on_Room_modifier_changed(type: int, value: float) -> void:
	match type:
		Room.Type.HELM:
			evasion = value
		Room.Type.WEAPONS:
			for weapon in weapons.get_children():
				weapon.modifier = value


func _on_RoomHitArea2D_body_entered(body: RigidBody2D, top_left: Vector2, bottom_right: Vector2):
	if _rng.randf() >= evasion:
		if _rng.randf() < body.chances.fire:
			var offset := Utils.randvi_range(_rng, top_left, bottom_right - Vector2.ONE)
			fires.add_fire(offset, true)
		if _rng.randf() < body.chances.hull_damage:
			# TODO: finish implementation
			print("hull_damage")
		take_damage(body.attack)
		body.queue_free()


func _on_FireTimer_timeout() -> void:
	for room in rooms.get_children():
		for fire in _get_fires(room):
			for unit in room.units:
				fire.take_damage(unit.attack)
			break
	
	for fire in fires.get_fires():
		if _rng.randf() < fire.chance_attack:
			take_damage(fire.attack)


func _on_UIDoorsButton_pressed() -> void:
	var has_opened_doors := false
	for door in doors.get_children():
		if door.is_open:
			has_opened_doors = true
			break
	
	for door in doors.get_children():
		door.is_open = not has_opened_doors


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		for unit in units.get_children():
			unit.is_selected = false
	elif event.is_action_pressed("right_click"):
		for unit in scene_tree.get_nodes_in_group("selected-unit"):
			var point1: Vector2 = tilemap.world_to_map(unit.path_follow.position)
			for room in scene_tree.get_nodes_in_group("selected-room"):
				var point2: Vector2 = room.get_slot(_slots, unit)
				if is_inf(point2.x):
					break
				
				var path: Curve2D = tilemap.find_path(point1, point2)
				Utils.erase_value(_slots, unit)
				_slots[point2] = unit
				unit.walk(path)


func take_damage(value: int) -> void:
	hit_points -= value
	hit_points = max(0, hit_points)
	emit_signal("hit_points_changed", hit_points, is_in_group("player"))


func _get_mean_position() -> Vector2:
	var out := Vector2.ZERO
	if rooms.get_child_count() > 0:
		for room in rooms.get_children():
			out += room.position
		out /= rooms.get_child_count()
	return out


func _get_fires(room: Room) -> Array:
	var out := []
	for fire in fires.get_fires():
		if room.has_point(tilemap.world_to_map(fire.position)):
			out.append(fire)
	return out
