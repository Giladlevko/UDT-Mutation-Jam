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
	
	if shake_strength>0.0:
		offset = random_offset()
		shake_strength = lerpf(shake_strength,0.0,shake_fade*delta)
	#admouse_offset(delta)

func shake(max_shake:float = default_max_shake):
	shake_strength = max_shake

func random_offset():
	var rand_x: = randf_range(-shake_strength,shake_strength)
	var rand_y: = randf_range(-shake_strength,shake_strength)
	return Vector2(rand_x,rand_y)


func mouse_offset(dt:float):
	var mouse_pos:Vector2 = get_global_mouse_position()
	var dir:float = global_position.angle_to_point(mouse_pos)
	if abs(sin(dir)) > 0.95:
		offset.y = lerpf(offset.y,clamp(offset.y+sin(dir)*20,-20,20),10*dt)
	else:
		offset.y = lerpf(offset.y,0,10*dt)
		offset.x = lerpf(offset.x,0,10*dt)
	
	
