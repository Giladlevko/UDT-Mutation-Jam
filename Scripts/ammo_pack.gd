extends Sprite2D
class_name AMMO_PACK

var rotation_mult:int = 1
@onready var pickup_sfx: AudioStreamPlayer2D = $pickup_sfx

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spin(delta,rotation_mult)
	pass
	

func spin(dt:float,mult:int = 1)->void:
	rotation_degrees += (180 * dt * mult)
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body is PLAYER):
		print("ammo taken yay!!!!")
		body.curr_ammo = Global.player_max_ammo
		remove_anim()
	pass # Replace with function body.


func remove_anim():
	var anim_dur = 1
	rotation_mult = -2
	pickup_sfx.play()
	var tween := create_tween().set_parallel()
	tween.tween_property(self,"modulate",Color(1,1,1,0),anim_dur)
	tween.tween_property(self,"rotation_mult",-5,anim_dur)
	tween.tween_property(self,"scale",Vector2(0,0),anim_dur)
	await tween.finished
	queue_free()
