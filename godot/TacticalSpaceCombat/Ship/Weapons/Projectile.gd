class_name Projectile
extends RigidBody2D

const MAX_DISTANCE := 2000

var max_distance := MAX_DISTANCE
var params := {}

var _origin := Vector2.ZERO

onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_origin = position


func _process(delta: float) -> void:
	if position.distance_to(_origin) > max_distance:
		queue_free()
