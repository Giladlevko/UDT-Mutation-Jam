extends CREATURE_CLASS
class_name PLAYER
var damage_amount:float = 10
var can_dash:bool = true
var can_shoot:bool = true
var gun_cooldown:float = 0.2
var BULLET:PackedScene = preload("res://Scenes/bullet.tscn")
@onready var gun: Node2D = $gun

func _ready() -> void:
	speed = 100
	SignalBus.dash_ready.connect(on_dash_ready)

func on_dash_ready():
	can_dash = true

func taking_damage(damage_type:STATES):
	match damage_type:
		STATES.TAKING_DAMAGE:
			normal_damage()

func normal_damage():
	health -= damage_amount
	#hurt_anim here


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
		shoot()

func shoot():
	can_shoot = false
	var bullet:PROJECTILE = BULLET.instantiate()
	bullet.direction = Vector2(cos(rotation),sin(rotation))
	bullet.global_position = gun.global_position
	bullet.collision_mask = collision_mask
	bullet.collision_layer = collision_layer
	owner.add_child(bullet)
	await get_tree().create_timer(gun_cooldown).timeout
	can_shoot = true
	
	pass

func idle():
	velocity = Vector2.ZERO
	if movement_action_pressed():
		change_state(STATES.RUNNING,state)
	check_dash()
	

func movement_action_pressed()->bool:
	var movement_actions: Array[String] = ["UP", "DOWN", "LEFT", "RIGHT"]
	for action:String in movement_actions:
		if Input.is_action_pressed(action):
			return true
	return false

func move(delta:float):
	var x_dir:= Input.get_axis("LEFT", "RIGHT")
	var y_dir := Input.get_axis("DOWN", "UP")
	if x_dir and !y_dir:
		velocity.x = x_dir * speed
		velocity.y = 0
	elif  y_dir and !x_dir:
		velocity.y = -y_dir * speed
		velocity.x = 0
	elif  y_dir and x_dir:
		var norm_speed = sqrt(speed*speed/2)
		velocity = Vector2(norm_speed*x_dir,-norm_speed*y_dir)
	elif !movement_action_pressed():
		change_state(STATES.IDLE,state)
	elif !x_dir and !y_dir:
		velocity = Vector2.ZERO
	
	check_dash()

func check_dash():
	if can_dash and Input.is_action_just_pressed("DASH"):
		change_state(STATES.DASH)

func dash(delta:float):
	const DASH_SPEED = 2500
	
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
