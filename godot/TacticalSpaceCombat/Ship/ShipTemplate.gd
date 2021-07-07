tool
extends Node2D

signal hitpoints_changed(hitpoints, is_player)

const LaserTracker := preload("Weapons/LaserTracker.tscn")
const AttackLabel := preload("Weapons/AttackLabel.tscn")
const BreachS := preload("Hazards/Breach.tscn")
const FireS := preload("Hazards/Fire.tscn")

export (int, 0, 30) var hitpoints := 30
export (int, 0, 100) var o2_asphyxiation := 10
export (int, 0, 10) var o2_replenish := 2

var has_sensors := false

var _evasion := 0.0
var _slots := {}
var _rng := RandomNumberGenerator.new()

onready var tilemap: TileMap = $TileMap
onready var rooms: Node2D = $Rooms
onready var doors: Node2D = $Doors
onready var units: Node2D = $Units
onready var weapons: Node2D = $Weapons
onready var projectiles: Node2D = $Projectiles
onready var lasers: Node2D = $Lasers
onready var shield: Area2D = $Shield
onready var hazards: Node2D = $Hazards
onready var timer_hazards: Timer = $TimerHazards


func _ready() -> void:
	call("_ready_editor_hint" if Engine.editor_hint else "_ready_not_editor_hint")


func _ready_editor_hint() -> void:
	for room in rooms.get_children():
		room.setup(tilemap)


func _ready_not_editor_hint() -> void:
	timer_hazards.connect("timeout", self, "_on_TimerHazards_timeout")
	_rng.randomize()

	for unit in units.get_children():
		unit.connect("died", self, "_on_Unit_died")
		for door in doors.get_children():
			door.connect("opened", unit, "set_is_walking", [true])

		var position_map := tilemap.world_to_map(unit.path_follow.position)
		_slots[position_map] = unit

	for room in rooms.get_children():
		room.connect("modifier_changed", self, "_on_Room_modifier_changed")
		room.connect("fog_changed", self, "_on_Room_fog_changed")
		room.connect("area_entered", self, "_on_RoomArea2D_area_entered", [room])
		room.hit_area.connect("body_entered", self, "_on_RoomHitArea2D_body_entered", [room])
		room.setup(tilemap)

		for point in room:
			tilemap.set_cellv(point, 0)

		if is_in_group("player") and room.type == Room.Type.SENSORS:
			has_sensors = true

	tilemap.setup(rooms, doors)
	projectiles.setup(rooms.mean_position)
	shield.setup(
		rooms.mean_position,
		Global.Layers.SHIPPLAYER if is_in_group("player") else Global.Layers.SHIPAI
	)


func _get_configuration_warning() -> String:
	var is_verified := (
		is_in_group("player")
		and weapons.get_child_count() <= 4
		or not is_in_group("player")
	)
	return "" if is_verified else "%s can't have more than 4 weapons!" % name


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("right_click"):
		return

	for unit in get_tree().get_nodes_in_group("selected-unit"):
		var point1: Vector2 = tilemap.world_to_map(unit.path_follow.position)
		for room in get_tree().get_nodes_in_group("selected-room"):
			if not room.owner.is_in_group("player"):
				break

			var point2: Vector2 = room.get_slot(_slots, unit)
			if is_inf(point2.x):
				break

			var path: Curve2D = tilemap.find_path(point1, point2)
			Utils.erase_value(_slots, unit)
			_slots[point2] = unit
			unit.walk(path)


func _on_UIDoorsButton_pressed() -> void:
	var has_opened_doors := false
	for door in doors.get_children():
		if door.is_open:
			has_opened_doors = true
			break

	for door in doors.get_children():
		door.is_open = not has_opened_doors


func _on_RoomHitArea2D_body_entered(body: RigidBody2D, room: Room) -> void:
	if not room.position.is_equal_approx(body.params.target_position) or _rng.randf() < _evasion:
		return

	body.animation_player.play("feedback")
	_handle_attack(body.params, room)


func _on_RoomArea2D_area_entered(area: Area2D, room: Room) -> void:
	if area.is_in_group("laser"):
		_handle_attack(area.params, room)


func _on_Room_modifier_changed(type: int, value: float) -> void:
	match type:
		Room.Type.HELM:
			_evasion = value
		Room.Type.WEAPONS:
			for controller in weapons.get_children():
				controller.weapon.modifier = value


func _on_Room_fog_changed(room: Room, has_fog: bool) -> void:
	for hazard in hazards.get_children():
		if room.has_point(tilemap.world_to_map(hazard.position)):
			hazard.visible = not has_fog


func _on_Unit_died(unit: Unit) -> void:
	Utils.erase_value(_slots, unit)
	for room in rooms.get_children():
		room.units.erase(unit)


func _on_Fire_spread(fire_position: Vector2) -> void:
	var neighbor_position := _get_neighbor_position(fire_position)
	var fire: Fire = hazards.add(FireS, neighbor_position)
	if fire != null:
		fire.connect("attacked", self, "_take_damage")
		fire.connect("spread", self, "_on_Fire_spread")
		for room in rooms.get_children():
			if room.has_point(tilemap.world_to_map(fire.position)):
				fire.visible = not _has_fog(room)
				break


func _on_TimerHazards_timeout() -> void:
	_hazards_breach()
	_hazards_units()
	_hazards_o2()


func _hazards_breach() -> void:
	for hazard in hazards.get_children():
		if hazard is Fire:
			continue

		for room in rooms.get_children():
			if room.has_point(tilemap.world_to_map(hazard.position)):
				room.o2 -= hazard.attack


func _hazards_units() -> void:
	for room in rooms.get_children():
		var hazard_was_attacked := false
		for hazard in hazards.get_children():
			if room.has_point(tilemap.world_to_map(hazard.position)):
				for unit in room.units:
					if hazard is Fire:
						unit.take_damage(hazard.attack)

					if not hazard_was_attacked:
						hazard.take_damage(unit.attack)
						hazard_was_attacked = true

				if hazard is Fire and room.o2 < o2_asphyxiation:
					hazard.take_damage(hazard.o2_damage)

		for unit in room.units:
			if room.o2 < o2_asphyxiation:
				unit.take_damage(unit.o2_damage)


func _hazards_o2() -> void:
	var o2s := {}
	var ns := {}
	for door in doors.get_children():
		if not door.is_open:
			continue

		var o2_mean := 0.0
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
		room.o2 += o2_replenish


func add_laser_tracker(color: Color) -> Node:
	var laser_tracker := LaserTracker.instance()
	lasers.add_child(laser_tracker)
	laser_tracker.setup(color, rooms, shield)
	return laser_tracker


func _has_fog(room: Room) -> bool:
	var room_has_fog := not has_sensors
	if is_in_group("player"):
		room_has_fog = room_has_fog and room.units.empty()
	return room_has_fog


func _handle_attack(params: Dictionary, room: Room) -> void:
	var room_has_fog := _has_fog(room)

	if _rng.randf() < params.chance_fire:
		var fire: Fire = hazards.add(FireS, room.randvi())
		if fire != null:
			fire.connect("attacked", self, "_take_damage")
			fire.connect("spread", self, "_on_Fire_spread")
			fire.visible = not room_has_fog

	if _rng.randf() < params.chance_breach:
		var breach: Breach = hazards.add(BreachS, room.randvi())
		if breach != null:
			breach.visible = not room_has_fog

	_take_damage(params.attack, room.position)


func _take_damage(attack: int, object_position: Vector2) -> void:
	var attack_label := AttackLabel.instance()
	attack_label.setup(attack, object_position)
	add_child(attack_label)

	hitpoints -= attack
	hitpoints = max(0, hitpoints)
	emit_signal("hitpoints_changed", hitpoints, is_in_group("player"))


func _get_neighbor_position(at: Vector2) -> Vector2:
	var neighbors := []
	var point1 := tilemap.world_to_map(at)
	for offset in Utils.DIRECTIONS:
		var point2: Vector2 = point1 + offset
		if tilemap.get_cellv(point2) != tilemap.INVALID_CELL:
			neighbors.push_back(tilemap.map_to_world(point2) + 0.5 * tilemap.cell_size)
	var index := _rng.randi_range(0, neighbors.size() - 1)
	return neighbors[index]
