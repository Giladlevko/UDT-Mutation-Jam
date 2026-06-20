extends CREATURE_CLASS
class_name PLAYER

var damage_amount:float = 10
var can_dash:bool = true
var gun_cooldown:float = 0.2
@onready var cam: PLAYER_CAM = $Camera2D
@onready var walk: AudioStreamPlayer2D = $audio/walk
@onready var gun: Node2D = $gun
var player_taking_damage:bool
@onready var dash_sfx: AudioStreamPlayer2D = $audio/dash

func _ready() -> void:
	Global.player = self
	speed = 100
	initialize_setup()
	is_taking_damage.connect(on_taking_damage)
	SignalBus.dash_ready.connect(on_dash_ready)
	hurt_anim_finished.connect(regain_health)
	is_taking_damage.connect(on_player_take_damage)

func on_dash_ready():
	can_dash = true

func on_taking_damage():
	const CAM_FREEZE_TIME = 0.3
	const FREEZE_TIME_SCALE = 0.2
	freeze_frame(CAM_FREEZE_TIME,FREEZE_TIME_SCALE)

func freeze_frame(dur:float,time_scale:float):
	Engine.time_scale = time_scale
	Engine.time_scale = time_scale
	await get_tree().create_timer(dur,true,false,true).timeout
	Engine.time_scale = 1.0

func mutation_cards():
	SignalBus.display_cards.emit(current_mutations)

func on_player_take_damage():
	player_taking_damage = true

var is_regaining_health:bool
func regain_health():
	if is_regaining_health:return
	is_regaining_health = true
	await get_tree().create_timer(5).timeout
	player_taking_damage = false
	var new_health:float
	while(health<health_bar.max_health and !player_taking_damage):
		new_health = clampf(health+3,0,health_bar.max_health)
		var tween:=create_tween().set_speed_scale(creature_time_scale)
		health = new_health
		tween.tween_callback(health_bar.set_health.bind(new_health))
		tween.tween_interval(1)
		await tween.finished
	is_regaining_health = false


func _physics_process(delta: float) -> void:
	match state:
		STATES.RUNNING: move(delta)
		STATES.IDLE:idle()
		STATES.DASH:dash(delta)
	constant_state()


func constant_state():
	move_and_slide()
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("SHOOT") and can_shoot:
		shoot_projectile(gun)
		cam_shake()
		knock_back(1000)

func cam_shake():
	cam.shake()

func idle():
	velocity = lerp(velocity,Vector2.ZERO,0.5)
	if movement_action_pressed():
		change_state(STATES.RUNNING,state)
	

func movement_action_pressed()->bool:
	var movement_actions: Array[String] = ["UP", "DOWN", "LEFT", "RIGHT"]
	for action:String in movement_actions:
		if Input.is_action_pressed(action):
			return true
	return false

func move(delta:float):
	var x_dir:= Input.get_axis("LEFT", "RIGHT")
	var y_dir := Input.get_axis("DOWN", "UP")
	var vel:Vector2
	if x_dir and !y_dir:
		vel.x = x_dir * speed
		
		vel.y = 0
	elif  y_dir and !x_dir:
		vel.y = -y_dir * speed
		vel.x = 0
	elif  y_dir and x_dir:
		var norm_speed = sqrt(speed*speed/2)
		vel = Vector2(norm_speed*x_dir,-norm_speed*y_dir)
	elif !movement_action_pressed():
		change_state(STATES.IDLE,state)
	elif !x_dir and !y_dir:
		vel = Vector2.ZERO
	if x_dir !=0:
		anim.flip_h = (x_dir == -1)
	velocity = lerp(velocity,vel,0.5)
	check_dash()
	step_timer()

var in_step_cooldown:bool
func step_timer():
	if in_step_cooldown:return
	in_step_cooldown = true
	await get_tree().create_timer(0.5*1/creature_time_scale).timeout
	in_step_cooldown = false
	if state == STATES.RUNNING:
		walk.play()

func check_dash():
	if can_dash and Input.is_action_just_pressed("DASH"):
		change_state(STATES.DASH)

func dash(delta:float):
	var DASH_SPEED = 25*speed
	dash_sfx.play()
	var x_dir:= Input.get_axis("LEFT", "RIGHT")
	var y_dir := Input.get_axis("UP","DOWN")
	var direction:Vector2 = Vector2(x_dir,y_dir)
	direction = direction.normalized()
	velocity += DASH_SPEED*direction*delta



var changing_state:bool = false
func change_state(next:STATES,prev:STATES = state):
	print("changing")
	if !changing_state and state != next:
		changing_state = true
		state = next
		exit_state(prev)
		enter_state(next)
		set_deferred("changing_state",false)

##function for handleing state entries
func enter_state(state_name:STATES):
	match state_name:
		STATES.IDLE:
			pass
		STATES.RUNNING:
			pass
		STATES.DASH:
			const DASH_TIME = 0.2
			can_dash = false
			await get_tree().create_timer(DASH_TIME).timeout
			change_state(STATES.RUNNING)
			const dash_cooldown = 1.5
			SignalBus.start_dash_cooldown.emit(dash_cooldown)
##function for handleing state exits
func exit_state(state_name):
	match state_name:
		pass
