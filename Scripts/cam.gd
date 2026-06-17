extends Camera2D
class_name PLAYER_CAM
var default_max_shake:float = 5
var shake_strength:float = 0.0
var shake_fade = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_strength>0:
		offset = random_offset()
		shake_strength = lerpf(shake_strength,0,shake_fade*delta)
	

func shake(max_shake:float = default_max_shake):
	shake_strength = max_shake

func random_offset():
	var rand_x: = randf_range(-shake_strength,shake_strength)
	var rand_y: = randf_range(-shake_strength,shake_strength)
	return Vector2(rand_x,rand_y)
