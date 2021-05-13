class_name Unit
extends Path2D


signal died(unit)

const COLORS := {
	"default": Color("323e4f"),
	"selected": Color("3ca370")
}

var speed := 150
var attack := 30
var is_walking: bool setget set_is_walking

onready var path_follow: PathFollow2D = $PathFollow2D
onready var area_unit: Area2D = $PathFollow2D/AreaUnit
onready var hitpoints_path_follow: PathFollow2D = $HitpointsPathFollow2D
onready var hitpoints: ProgressBar = $HitpointsPathFollow2D/Hitpoints


func _ready() -> void:
	self.is_walking = false


func _on_AreaUnit_area_entered(area: Area2D) -> void:
	if area.is_in_group("door") and not area.is_open:
		self.is_walking = false


func _process(delta: float) -> void:
	path_follow.offset += speed * delta
	hitpoints_path_follow.offset = path_follow.offset
	if path_follow.offset >= curve.get_baked_length():
		self.is_walking = false


## Assigns the given `Curve2D` `path` to `curve`. It appends `path_follow.position`
## as the starting point on the `curve`.
func walk(path: Curve2D) -> void:
	# Check if path is valid.
	if path.get_point_count() == 0:
		return
	curve = path
	# Remember that `TileMap.find_path()` returns the path missing the start
	# position. That's because we want the current unit position instead, to
	# take in account already moving units.
	#
	# NOTE that the two `Vector2.ZERO` parameters are the in/out point handles.
	# They're `Vector2.ZERO` because we don't care about them.
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
