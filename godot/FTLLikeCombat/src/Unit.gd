extends Node2D


var speed := 150

onready var path_follow: PathFollow2D = $Path2D/PathFollow2D


func _ready() -> void:
	FTLLikeEvents.connect("door_opened", self, "_on_Events_door_opened")


func _on_AreaUnit_area_entered(area: Area2D) -> void:
	set_process(false)


func _on_Events_door_opened() -> void:
	set_process(true)


func _process(delta: float) -> void:
	path_follow.offset += speed * delta
