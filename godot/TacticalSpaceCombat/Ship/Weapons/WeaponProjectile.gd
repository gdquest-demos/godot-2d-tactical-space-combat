class_name WeaponProjectile
extends Weapon


signal projectile_exited(physics_layer, params)
signal targeting(index)

const Projectile := preload("Projectile.tscn")

export(float, 0, 1) var chance_fire := 0.1
export(float, 0, 1) var chance_hull_damage := 0.5

var _target_position := Vector2.INF


func _ready() -> void:
	if owner.is_in_group("enemy"):
		yield(scene_tree, "idle_frame")
		_set_is_charging(true)
		emit_signal("targeting", get_index())


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	._on_UIWeaponButton_toggled(is_pressed)
	
	if is_pressed:
		_target_position = Vector2.INF
	elif not (_target_position == Vector2.INF or is_pressed or _is_charging):
		_fire()
	
	emit_signal("targeting", get_index() if is_pressed else -1)


func _on_Room_targeted(targeted_by: int, target_position: Vector2) -> void:
	if targeted_by == get_index():
		_target_position = target_position
		if owner.is_in_group("player"):
			_ui_weapon_button.pressed = false


func _fire():
	var params := {
		"target_position": _target_position,
		"chance_fire": chance_fire,
		"chance_hull_damage": chance_hull_damage,
		"attack": attack
	}
	var physics_layer: int = (
		Utils.Layers.SHIP_ENEMY if owner.is_in_group("player") else Utils.Layers.SHIP_PLAYER
	)
	var projectile: RigidBody2D = Projectile.instance()
	projectile.linear_velocity = projectile.linear_velocity.rotated(rotation)
	projectile.connect(
		"tree_exited", self, "emit_signal", ["projectile_exited", physics_layer, params]
	)
	add_child(projectile)
	_set_is_charging(true)


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if not (_target_position == Vector2.INF or _is_charging):
		_fire()
