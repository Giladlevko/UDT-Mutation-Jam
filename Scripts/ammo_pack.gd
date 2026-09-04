extends Sprite2D
class_name AMMO_PACK

var rotation_mult:int = 1
@onready var pickup_sfx: AudioStreamPlayer2D = $pickup_sfx
@onready var spawn_sfx: AudioStreamPlayer2D = $spawn_sfx


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_transition()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spin(delta,rotation_mult)
	pass
	

func spin(dt:float,mult:int = 1)->void:
	rotation_degrees += (180 * dt * mult)
	pass

var entered:bool = false
func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body is PLAYER && !entered):
		print("ammo taken yay!!!!")
		entered = true
		body.curr_ammo = Global.player_max_ammo
		remove_anim()
	pass # Replace with function body.


func remove_anim():
	var anim_dur = 1
	rotation_mult = -2
	handle_load_sfx()
	var tween := create_tween().set_parallel()
	tween.tween_property(self,"modulate",Color(1,1,1,0),anim_dur)
	tween.tween_property(self,"rotation_mult",-5,anim_dur)
	tween.tween_property(self,"scale",Vector2(0,0),anim_dur)
	await tween.finished
	queue_free()


func handle_load_sfx():
	var max:int = 5
	for i in max:
		pickup_sfx.play()
		await get_tree().create_timer((max-i)*0.01).timeout


func spawn_transition():
	var anim_dur = 1
	spawn_sfx.play()
	scale = Vector2.ZERO
	modulate.a = 0 
	var tween:=create_tween().set_parallel()
	tween.tween_property(self,"scale",Vector2(1,1),anim_dur)
	tween.tween_property(self,"modulate",Color(1,1,1,1),anim_dur)
