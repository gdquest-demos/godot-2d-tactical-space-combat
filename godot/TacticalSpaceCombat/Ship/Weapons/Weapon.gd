# Base class for all weapons, whether they shoot bullets or lasers.
# Charges over time. When fully charged, if the weapon has a target, it fires automatically.
# See [UIWeapon] for logic related to selecting targets.
class_name Weapon
extends Position2D

signal projectile_exited_screen(Projectile)
signal charge_changed(new_value)

const Projectile := preload("Projectile.tscn")

# Amount charged each second.
export var charge_rate := 10.0
export var label := "Rocket launcher"

# Current charge level of the weapon. When the value reaches 100, the weapon can fire.
var charge := 0.0 setget set_charge
var target: Room = null setget set_target


func _process(delta: float) -> void:
	set_charge(charge + charge_rate * delta)


func set_charge(value: float) -> void:
	charge = value
	emit_signal("charge_changed", charge)
	if charge >= 100.0:
		set_process(false)
		if target:
			fire()


func set_target(value: Room) -> void:
	target = value
	if charge > 100.0 and target:
		fire()


func fire() -> void:
	charge = 0.0
	# Add the projectile to scene tree and after it exits we emit "projectile_exited_screen" so we can trigger
	# a new projectile creation in the enemy viewport.
	var projectile := Projectile.instance()
	projectile.connect(
		"tree_exited",
		self,
		"emit_signal",
		["projectile_exited_screen", Projectile, target.global_position]
	)
	add_child(projectile)
	set_process(true)
