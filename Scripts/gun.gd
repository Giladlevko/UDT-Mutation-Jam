extends Node2D
class_name  GUN
@onready var barrel: Node2D = $barrel
@export var gun_sprite: Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gun_sprite:
		gun_sprite.flip_v = (cos(global_rotation)<0)
	
