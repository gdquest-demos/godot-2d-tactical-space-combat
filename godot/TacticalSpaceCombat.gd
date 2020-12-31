extends Node2D

const Projectile = preload("TacticalSpaceCombat/Ship/Weapons/Projectile.tscn")
const UIUnit = preload("TacticalSpaceCombat/UI/UIUnit.tscn")
const UISystem = preload("TacticalSpaceCombat/UI/UISystem.tscn")
const UIWeapons = preload("TacticalSpaceCombat/UI/UIWeapons.tscn")
const UIWeapon = preload("TacticalSpaceCombat/UI/UIWeapon.tscn")

const END_SCENE = "TacticalSpaceCombat/End.tscn"

var _rng := RandomNumberGenerator.new()
#var _swipe_laser_player_start := Vector2.ZERO
#var _swipe_laser_enemy_start := Vector2.ZERO

onready var scene_tree: SceneTree = get_tree()
onready var tween: Tween = $Tween
onready var ship_player: Node2D = $ShipPlayer
onready var viewport_container: ViewportContainer = $ViewportContainer
onready var ship_enemy: Node2D = $ViewportContainer/Viewport/ShipEnemy
#onready var spawner: PathFollow2D = $ViewportContainer/Viewport/PathSpawner/Spawner
#onready var projectiles_player: Node2D = $ViewportContainer/Viewport/ProjectilesPlayer
#onready var projectiles_enemy: Node2D = $ProjectilesEnemy
onready var ui: Control = $UI
onready var ui_hit_points_player: Label = $UI/HitPoints
onready var ui_hit_points_enemy: Label = $ViewportContainer/Viewport/UI/HitPoints
onready var ui_units: VBoxContainer = $UI/Units
onready var ui_systems: HBoxContainer = $UI/Systems
onready var ui_doors: MarginContainer = $UI/Systems/Doors


func _ready() -> void:
	_rng.randomize()
	
	ship_player.connect("hit_points_changed", self, "_on_Ship_hit_points_changed")
	ship_enemy.connect("hit_points_changed", self, "_on_Ship_hit_points_changed")
	
	ui_doors.get_node("Button").connect("pressed", ship_player, "_on_UIDoorsButton_pressed")
	ship_enemy.has_sensors = ship_player.has_sensors
	if ship_player.has_sensors:
		var ui_sensors := UISystem.instance()
		var button := ui_sensors.get_node("Button")
		button.text = "s"
		button.disabled = true
		ui_systems.add_child(ui_sensors)
	ui_systems.add_child(VSeparator.new())
	
	ship_player.connect("attached_shield", self, "_on_ShipPlayer_attached_shield")
	if ship_player.has_node("Shield"):
		var ui_shield := UISystem.instance()
		ui_shield.get_node("Button").text = "S"
		ui_systems.add_child(ui_shield)
	
	for weapon in ship_player.weapons.get_children():
		if weapon is WeaponProjectile:
			weapon.connect("projectile_exited", ship_enemy, "_on_WeaponProjectile_projectile_exited")
			for room in ship_enemy.rooms.get_children():
				weapon.connect("targeting", room, "_on_WeaponProjectile_targeting")
				room.connect("targeted", weapon, "_on_Room_targeted")
#		elif weapon is WeaponPlayerLaser:
#			weapon.connect("targeting", self, "_on_WeaponLaser_targeting")
#			weapon.connect("fire_started", self, "_on_WeaponLaser_fire_started", [true])
#			weapon.connect("fire_stopped", self, "_on_WeaponLaser_fire_stopped", [true])
		
		if not ui_systems.has_node("Weapons"):
			ui_systems.add_child(UIWeapons.instance())
		
		var ui_weapon: VBoxContainer = UIWeapon.instance()
		ui_systems.get_node("Weapons").add_child(ui_weapon)
		weapon.setup(ui_weapon)
	
	for unit in ship_player.units.get_children():
		var ui_unit: ColorRect = UIUnit.instance()
		ui_units.add_child(ui_unit)
		unit.setup(ui_unit)
	
	for weapon in ship_enemy.weapons.get_children():
		if weapon is WeaponProjectile:
			weapon.connect("projectile_exited", ship_player, "_on_WeaponProjectile_projectile_exited")
			weapon.connect("targeting", ship_player, "_on_WeaponProjectile_targeting")
			for room in ship_player.rooms.get_children():
				room.connect("targeted", weapon, "_on_Room_targeted")
#		elif weapon is WeaponEnemyLaser:
#			weapon.connect("targeting", ship_player, "_on_WeaponLaser_targeting")
#			weapon.connect("fire_started", self, "_on_WeaponLaser_fire_started", [false])
#			weapon.connect("fire_stopped", self, "_on_WeaponLaser_fire_stopped", [false])
#			ship_player.connect("targeted", weapon, "_on_Ship_targeted")
	
	ship_player.emit_signal("hit_points_changed", ship_player.hit_points, true)
	ship_enemy.emit_signal("hit_points_changed", ship_enemy.hit_points, false)


#func _on_WeaponLaser_targeting(points: PoolVector2Array) -> void:
#	points = viewport_container.get_global_transform().xform_inv(points)
#	points = ship_enemy.get_global_transform().xform_inv(points)
#	ship_enemy.laser_target_line.points = points


#func _on_WeaponLaser_fire_started(
#		points: PoolVector2Array,
#		duration: float,
#		params: Dictionary,
#		is_player: bool) -> void:
#	var method := "_swipe_laser"
#	if is_player:
#		method += "_player"
#		ship_enemy.laser_area.set_deferred("monitorable", true)
#		ship_enemy.laser_area.params = params
#		points = viewport_container.get_global_transform().xform_inv(points)
#		points = ship_enemy.get_global_transform().xform_inv(points)
#		spawner.unit_offset = _rng.randf()
#		_swipe_laser_player_start = ship_enemy.transform.xform_inv(spawner.position)
#	else:
#		method += "_enemy"
#		ship_player.laser_area.set_deferred("monitorable", true)
#		ship_player.laser_area.params = params
#		_swipe_laser_enemy_start = scene_tree.root.size
#		_swipe_laser_enemy_start.y /= 2
#	tween.interpolate_method(self, method, points[0], points[1], duration)
#	tween.start()
#
#
#func _on_WeaponLaser_fire_stopped(is_player: bool) -> void:
#	if is_player:
#		tween.remove(self, "_swipe_laser_player")
#		ship_enemy.laser_area.set_deferred("monitorable", false)
#		ship_enemy.laser_area.position = Vector2.ZERO
#		ship_enemy.laser_line.points = []
#	else:
#		tween.remove(self, "_swipe_laser_enemy")
#		ship_player.laser_area.set_deferred("monitorable", false)
#		ship_player.laser_area.position = Vector2.ZERO
#		ship_player.laser_line.points = []
#
#
#func _swipe_laser_player(offset: Vector2) -> void:
#	ship_enemy.laser_area.position = offset
#	ship_enemy.laser_line.points = [_swipe_laser_player_start, offset]
#
#
#func _swipe_laser_enemy(offset: Vector2) -> void:
#	ship_player.laser_area.position = offset
#	ship_player.laser_line.points = [_swipe_laser_enemy_start, offset]


func _on_Ship_hit_points_changed(hit_points: int, is_player: bool) -> void:
	var label := ui_hit_points_player if is_player else ui_hit_points_enemy
	label.text = "HP: %d" % hit_points
	if hit_points == 0:
		Global.winner_is_player = not is_player
		scene_tree.change_scene(END_SCENE)
