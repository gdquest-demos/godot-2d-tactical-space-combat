class_name Ship
extends Node2D


signal hitpoints_changed(hitpoints, is_player)

const BreachS = preload("Hazards/Breach.tscn")
const FireS = preload("Hazards/Fire.tscn")
const LaserTracker = preload("LaserTracker.tscn")

export(int, 0, 30) var hitpoints := 30

var has_sensors := false

# This dictionary keeps track of the crew locations.
var _slots := {}
var _rng := RandomNumberGenerator.new()
var _shield: Area2D = null
var _evasion := 0.0
var _shield_is_on := false

onready var scene_tree: SceneTree = get_tree()
onready var hazards_timer: Timer = $HazardsTimer
onready var tilemap: TileMap = $TileMap
onready var rooms: Node2D = $Rooms
onready var hazards: Node2D = $Hazards
onready var doors: Node2D = $Doors
onready var weapons: Node2D = $Weapons
onready var units: Node2D = $Units
onready var spawner: Path2D = $Spawner
onready var projectiles: Node2D = $Projectiles
onready var lasers: Node2D = $Lasers


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
		room.connect("area_entered", self, "_on_RoomArea2D_area_entered", [room])
		room.hit_area.connect("body_entered", self, "_on_RoomHitArea2D_body_entered", [room])
		
		for point in room:
			tilemap.set_cellv(point, 0)
		
		if room.type == Room.Type.SENSORS:
			has_sensors = true
	
	if has_node("Shield"):
		_shield = $Shield
		_shield.position = _get_mean_position()
		_shield.connect("hitpoints_changed", self, "_on_Shield_hitpoints_changed")
	tilemap.setup(rooms, doors)


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


func _on_Room_modifier_changed(type: int, value: float) -> void:
	match type:
		Room.Type.HELM:
			_evasion = value
		Room.Type.WEAPONS:
			for weapon in weapons.get_children():
				weapon.weapon.modifier = value


func _on_UIDoorsButton_pressed() -> void:
	var has_opened_doors := false
	for door in doors.get_children():
		if door.is_open:
			has_opened_doors = true
			break
	
	for door in doors.get_children():
		door.is_open = not has_opened_doors


func _on_Shield_hitpoints_changed(hitpoints: int) -> void:
	_shield_is_on = hitpoints > 0


func _on_RoomArea2D_area_entered(area: Area2D, room: Room) -> void:
	if area.is_in_group("laser") and not _shield_is_on:
		_handle_attack(area.params, room)


func _on_RoomHitArea2D_body_entered(body: RigidBody2D, room: Room) -> void:
	if not room.position.is_equal_approx(body.params.target_position) or _rng.randf() < _evasion:
		return
	
	body.animation_player.play("feedback")
	_handle_attack(body.params, room)


func _on_HazardsTimer_timeout() -> void:
	for hazard in hazards.get_children():
		if hazard is Fire and _rng.randf() < hazard.chance_attack:
			_take_damage(hazard.attack)
		elif hazard is Breach:
			for room in rooms.get_children():
				if room.has_point(tilemap.world_to_map(hazard.position)):
					room.o2 -= hazard.attack
	
	var o2s := {}
	var ns := {}
	for door in doors.get_children():
		if not door.is_open:
			continue

		var o2_mean := 0
		for room in door.rooms:
			o2_mean += room.o2
			ns[room] = ns.get(room, 0) + 1
		o2_mean /= door.rooms.size()
		
		for room in door.rooms:
			o2s[room] = o2s.get(room, 0) + o2_mean
	
	for room in rooms.get_children():
		if room in o2s:
			o2s[room] /= ns[room]
			room.o2 = lerp(room.o2, o2s[room], 0.5)
		
		for hazard in hazards.get_children():
			if room.has_point(tilemap.world_to_map(hazard.position)):
				for unit in room.units:
					hazard.take_damage(unit.attack)
				break
		room.o2 += 2


func _on_FireSpreadTimer_timeout() -> void:
	for hazard in hazards.get_children():
		if hazard is Breach:
			continue
		
		var neighbors: Array = _get_neightbor_positions(hazard.position)
		var index := _rng.randi_range(0, neighbors.size() - 1)
		hazards.add(FireS, neighbors[index])


func add_laser_tracker(color: Color) -> Node:
	var laser_tracker := LaserTracker.instance()
	lasers.add_child(laser_tracker)
	laser_tracker.setup(rooms, spawner, _shield, color)
	return laser_tracker


func _handle_attack(params: Dictionary, room: Room) -> void:
	if _rng.randf() < params.chance_fire:
		hazards.add(FireS, room.randvi())
	
	if _rng.randf() < params.chance_hull_breach:
		hazards.add(BreachS, room.randvi())
	
	_take_damage(params.attack)


func _take_damage(value: int) -> void:
	hitpoints -= value
	hitpoints = max(0, hitpoints)
	emit_signal("hitpoints_changed", hitpoints, is_in_group("player"))


func _get_neightbor_positions(at: Vector2) -> Array:
	var out := []
	var point1 := tilemap.world_to_map(at)
	for offset in Utils.DIRECTIONS:
		var point2: Vector2 = point1 + offset
		if point2.x < 0 or point2.y < 0:
			continue
		
		var curve: Curve2D = tilemap.find_path(point1, point2)
		if curve.get_point_count() == 1:
			out.append_array(curve.get_baked_points())
	return out


func _get_mean_position() -> Vector2:
	var out := Vector2.ZERO
	if rooms.get_child_count() > 0:
		for room in rooms.get_children():
			out += room.position
		out /= rooms.get_child_count()
	return out
