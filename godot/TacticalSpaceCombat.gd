extends Node2D


const UIUnit = preload("TacticalSpaceCombat/UI/UIUnit.tscn")
const UISystem = preload("TacticalSpaceCombat/UI/UISystem.tscn")
const UIWeapons = preload("TacticalSpaceCombat/UI/UIWeapons.tscn")
const UIWeapon = preload("TacticalSpaceCombat/UI/UIWeapon.tscn")

const END_SCENE = "TacticalSpaceCombat/End.tscn"

var _rng := RandomNumberGenerator.new()

onready var scene_tree: SceneTree = get_tree()
onready var ship_player: Node2D = $ShipPlayer
onready var viewport_container: ViewportContainer = $ViewportContainer
onready var ship_ai: Node2D = $ViewportContainer/Viewport/ShipAI
onready var ui: Control = $UI
onready var ui_hitpoints_player: Label = $UI/HitPoints
onready var ui_hitpoints_ai: Label = $ViewportContainer/Viewport/UI/HitPoints
onready var ui_units: VBoxContainer = $UI/Units
onready var ui_systems: HBoxContainer = $UI/Systems
onready var ui_doors: MarginContainer = $UI/Systems/Doors


func _ready() -> void:
	_rng.randomize()
	
	ship_player.connect("hitpoints_changed", self, "_on_Ship_hitpoints_changed")
	ship_ai.connect("hitpoints_changed", self, "_on_Ship_hitpoints_changed")
	
	ui_doors.get_node("Button").connect("pressed", ship_player, "_on_UIDoorsButton_pressed")
	ship_ai.has_sensors = ship_player.has_sensors
	if ship_player.has_sensors:
		var ui_sensors := UISystem.instance()
		var button := ui_sensors.get_node("Button")
		button.text = "s"
		button.disabled = true
		ui_systems.add_child(ui_sensors)
	ui_systems.add_child(VSeparator.new())
	
	if ship_player.has_node("Shield"):
		var ui_shield := UISystem.instance()
		ui_shield.get_node("Button").text = "S"
		ui_systems.add_child(ui_shield)
	
	for controller in ship_player.weapons.get_children():
		if not ui_systems.has_node("Weapons"):
			ui_systems.add_child(UIWeapons.instance())
		var ui_weapon: VBoxContainer = UIWeapon.instance()
		ui_systems.get_node("Weapons").add_child(ui_weapon)
		
		if controller is ControllerPlayerProjectile:
			controller.weapon.connect("projectile_exited", ship_ai.projectiles, "_on_Weapon_projectile_exited")
			for room in ship_ai.rooms.get_children():
				controller.connect("targeting", room, "_on_Controller_targeting")
				room.connect("targeted", controller, "_on_Ship_targeted")
		elif controller is ControllerPlayerLaser:
			var laser_tracker: Node = ship_ai.add_laser_tracker(controller.weapon.line.default_color)
			controller.connect("targeting", laser_tracker, "_on_Controller_targeting")
			laser_tracker.connect("targeted", controller, "_on_Ship_targeted")
			controller.weapon.connect("fire_started", laser_tracker, "_on_Weapon_fire_started")
			controller.weapon.connect("fire_stopped", laser_tracker, "_on_Weapon_fire_stopped")
		controller.setup(ui_weapon)
	
	for unit in ship_player.units.get_children():
		var ui_unit: ColorRect = UIUnit.instance()
		ui_units.add_child(ui_unit)
		unit.setup(ui_unit)
	
	for controller in ship_ai.weapons.get_children():
		if controller is ControllerAIProjectile:
			controller.connect("targeting", ship_player.rooms, "_on_Controller_targeting")
			controller.weapon.connect("projectile_exited", ship_player.projectiles, "_on_Weapon_projectile_exited")
			ship_player.rooms.connect("targeted", controller, "_on_Ship_targeted")
		elif controller is ControllerAILaser:
			var laser_tracker: Node = ship_player.add_laser_tracker(controller.weapon.line.default_color)
			controller.connect("targeting", laser_tracker, "_on_Controller_targeting")
			controller.weapon.connect("fire_started", laser_tracker, "_on_Weapon_fire_started")
			controller.weapon.connect("fire_stopped", laser_tracker, "_on_Weapon_fire_stopped")
			laser_tracker.connect("targeted", controller, "_on_Ship_targeted")
	
	ship_player.emit_signal("hitpoints_changed", ship_player.hitpoints, true)
	ship_ai.emit_signal("hitpoints_changed", ship_ai.hitpoints, false)


func _on_Ship_hitpoints_changed(hitpoints: int, is_player: bool) -> void:
	var label := ui_hitpoints_player if is_player else ui_hitpoints_ai
	label.text = "HP: %d" % hitpoints
	if hitpoints == 0:
		Global.winner_is_player = not is_player
		scene_tree.change_scene(END_SCENE)
