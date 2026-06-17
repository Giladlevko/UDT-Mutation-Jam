extends Node2D
class_name LEVEL_MANAGER
@onready var nav_reg: NavigationRegion2D = $NavigationRegion2D
@onready var player: PLAYER = $player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	nav_reg.global_position = player.global_position
