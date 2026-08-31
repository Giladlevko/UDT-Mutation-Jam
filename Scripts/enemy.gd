extends CREATURE_CLASS
class_name ENEMY
@onready var nav2d: NavigationAgent2D = $navigation/NavigationAgent2D
const UPDATE_INTERVAL = 0.35
@onready var gun: GUN = $gun

var update_timer:float
func _ready() -> void:
	spawn_anim()
	
	var angle_to_player:float = global_position.angle_to_point(Global.player.global_position)
	global_rotation = angle_to_player
	initialize_setup()
	pass

func spawn_anim():
	anim.modulate.a = 0
	var tween:Tween = create_tween().set_parallel()
	tween.tween_property(anim,"modulate",Color(1,1,1,1),0.3)
	tween.tween_property(anim,"scale",Vector2(1,1),0.3)
	if(Global.enemies_health_visible):
		tween.chain().tween_property(health_bar,"visible",true,0.3)
	

func _physics_process(delta: float) -> void:
	health_bar.global_position = global_position+Vector2(health_bar.bar_size.x,-50)
	update_timer +=delta *creature_time_scale
	if Global.player:
		var angle_to_player:float = global_position.angle_to_point(Global.player.global_position)
		global_rotation = rotate_toward(global_rotation,angle_to_player,delta*creature_time_scale)
	if update_timer >= UPDATE_INTERVAL:
		update_timer = 0.0
		set_nav_point()
	
	navigate(delta)
	move_and_slide()

func set_nav_point():
	if !Global.player:return
	nav2d.target_position = Global.player.global_position

func navigate(dt:float):
	if nav2d.is_navigation_finished():
		velocity = lerp(velocity,Vector2.ZERO,0.2)
		if Global.player and (global_position.distance_to(Global.player.global_position))<200:
			spit_anim()
		return
	var next_path_pos:Vector2 = nav2d.get_next_path_position()
	var new_vel:Vector2 = (global_position.direction_to(next_path_pos)*speed)
	nav2d.velocity = new_vel


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = lerp(velocity,safe_velocity,0.2)
	

var is_spitting:bool
func spit_anim():
	if is_spitting:return
	is_spitting = true
	var tween:=create_tween().set_trans(Tween.TRANS_ELASTIC).set_parallel().set_speed_scale(1/projectile_cooldown)
	tween.tween_property(self,"scale",Vector2(0.7,1.3),0.4)
	tween.tween_property(self,"scale",Vector2(1.3,0.7),0.4).set_delay(0.4)
	tween.tween_property(self,"scale",Vector2(1,1),0.5).set_delay(0.8)
	tween.tween_callback(spit_projectile).set_delay(0.7)
	tween.tween_callback(func():is_spitting = false).set_delay(0.8+projectile_cooldown)
	
	
func spit_projectile():
	shoot_projectile(gun)
	knock_back(500)
