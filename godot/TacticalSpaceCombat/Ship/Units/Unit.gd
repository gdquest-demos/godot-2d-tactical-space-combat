class_name Unit
extends Path2D

signal died(unit)

const COLORS := {"default": Color("323e4f"), "selected": Color("3ca370")}

export var speed := 150
export var attack := 15
export var o2_damage := 10

var is_walking: bool setget set_is_walking

onready var path_follow: PathFollow2D = $PathFollow2D
onready var area_unit: Area2D = $PathFollow2D/AreaUnit
onready var hitpoints_path_follow: PathFollow2D = $HitpointsPathFollow2D
onready var hitpoints: ProgressBar = $HitpointsPathFollow2D/Hitpoints


func _ready() -> void:
	area_unit.connect("area_entered", self, "_on_AreaUnit_area_entered")
	self.is_walking = false


func _on_AreaUnit_area_entered(area: Area2D) -> void:
	if area.is_in_group("door") and not area.is_open:
		self.is_walking = false


func _process(delta: float) -> void:
	path_follow.offset += speed * delta
	hitpoints_path_follow.offset = path_follow.offset
	if path_follow.offset >= curve.get_baked_length():
		self.is_walking = false


func walk(path: Curve2D) -> void:
	if path.get_point_count() == 0:
		return

	curve = path
	curve.add_point(path_follow.position, Vector2.ZERO, Vector2.ZERO, 0)
	path_follow.offset = 0
	self.is_walking = true


func heal(value: int) -> void:
	hitpoints.value += value


func take_damage(other_attack: int) -> void:
	hitpoints.value -= other_attack
	if hitpoints.value <= 0:
		queue_free()
		emit_signal("died", self)


func set_is_walking(value: bool) -> void:
	is_walking = value
	set_process(is_walking)
