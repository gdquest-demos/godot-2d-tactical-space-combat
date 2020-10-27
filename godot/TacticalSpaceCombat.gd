extends Node2D


const UIUnit = preload("res://TacticalSpaceCombat/UI/UIUnit.tscn")
const UIWeapons = preload("res://TacticalSpaceCombat/UI/UIWeapons.tscn")
const UIWeapon = preload("res://TacticalSpaceCombat/UI/UIWeapon.tscn")

var _rng := RandomNumberGenerator.new()

onready var scene_tree: SceneTree = get_tree()
onready var ship_player: Node2D = $ShipPlayer
onready var ship_enemy: Node2D = $ViewportContainer/Viewport/ShipEnemy
onready var spawner: PathFollow2D = $ViewportContainer/Viewport/PathSpawner/Spawner
onready var projectiles: Node2D = $ViewportContainer/Viewport/Projectiles
onready var ui: Control = $UI
onready var ui_units: VBoxContainer = ui.get_node("Units")
onready var ui_systems: HBoxContainer = ui.get_node("Systems")


func _ready() -> void:
	ship_player.shield.connect("body_entered", self, "_on_ShipShield_body_entered")
	ship_enemy.shield.connect("body_entered", self, "_on_ShipShield_body_entered")
	_rng.randomize()
	
	for weapon in ship_player.weapons.get_children():
		if not ui_systems.has_node("Weapons"):
			ui_systems.add_child(UIWeapons.instance())
		
		var ui_weapon: VBoxContainer = UIWeapon.instance()
		weapon.connect("projectile_exited", self, "_on_Weapon_projectile_exited")
		ui_systems.get_node("Weapons").add_child(ui_weapon)
		weapon.setup(ui_weapon)
		
		for room in ship_enemy.rooms.get_children():
			weapon.connect("targeting", room, "_on_Weapon_targeting")
			room.connect("targeted", weapon, "_on_Room_targeted")
	
	for unit in ship_player.units.get_children():
		var ui_unit: ColorRect = UIUnit.instance()
		ui_units.add_child(ui_unit)
		unit.setup(ui_unit)


func _on_Weapon_projectile_exited(Projectile: PackedScene, target_global_position: Vector2) -> void:
	spawner.unit_offset = _rng.randf()
	var direction: Vector2 = (target_global_position - spawner.global_position).normalized()
	var projectile: RigidBody2D = Projectile.instance()
	projectile.global_position = spawner.global_position
	projectile.linear_velocity = direction * projectile.linear_velocity.length()
	projectile.rotation = direction.angle()
	projectiles.add_child(projectile)
	projectile.setup(_rng, target_global_position)


func _on_ShipShield_body_entered(body: Node) -> void:
	if _rng.randf() < 0.8:
		return
	
	print(body.name)
	body.queue_free()
