extends CharacterBody2D
class_name CREATURE_CLASS

var BULLET:PackedScene = preload("res://Scenes/bullet.tscn")

@export var anim:AnimatedSprite2D
@export var colli:CollisionShape2D
@export var hurt_area:Area2D
@export var hurt_colli:CollisionShape2D
@export var attack_colli:CollisionShape2D
@export var health_bar:HEALTH_BAR

@export var base_stats:CreatureStats



enum STATES{IDLE,RUNNING,DOGING,TAKING_DAMAGE,BURNING,FROZEN,DASH}
var state:STATES = STATES.IDLE

@export_group("Stats")
@export var health:float = 100;
@export var speed:float = 50
@export var attack_power:float = 10
@export var damage_from_fire:float = 5
@export var freeze_time:float = 0.5
@export var protection_from_damage:float = 0
@export var projectile_amount:int = 1
@export var projectile_cooldown:float = 0.2
@export var projectile_chance_to_split:float = 0.1
var current_mutations: Array[MutationData] = []

@export_group("Audio")
@export var shoot_sfx:AudioStreamPlayer2D
@export var hurt_sfx:AudioStreamPlayer2D
@export var dead_sfx:AudioStreamPlayer2D

@export_group("VFX")
@export var particles:CPUParticles2D

var creature_time_scale:float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func initialize_setup():
	recalculate_stats()
	hurt_area.area_entered.connect(on_hurt_area_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func recalculate_stats(recalc_health:bool = true):
	assert(base_stats,"Did not assign base stats")
	
	if recalc_health: health = base_stats.health
	
	speed = base_stats.speed * creature_time_scale
	attack_power = base_stats.attack_power
	damage_from_fire = base_stats.damage_from_fire
	freeze_time = base_stats.damage_from_fire
	protection_from_damage = base_stats.protection_from_damage
	projectile_amount = base_stats.projectile_amount
	projectile_cooldown = base_stats.projectile_cooldown * creature_time_scale
	projectile_chance_to_split = base_stats.projectile_chance_to_split
	var enemies_health_vis:bool
	for mutation:MutationData in current_mutations:
		
		if recalc_health: health *= mutation.health_mult
		
		speed *= mutation.speed_mult
		attack_power *= mutation.attack_power_mult
		damage_from_fire *= mutation.fire_damage_mult
		freeze_time *= mutation.freeze_time_mult
		protection_from_damage += mutation.protection_bonus
		projectile_amount *= mutation.projectile_mult
		enemies_health_vis = enemies_health_vis or mutation.enemies_health_vis
		projectile_cooldown *= mutation.projectile_cool_mult
		projectile_chance_to_split = max(projectile_chance_to_split,mutation.projectile_chance_to_split)
	if self is PLAYER:Global.enemies_health_visible = enemies_health_vis
	if recalc_health:
		health_bar.update_max(health)
		health_bar.set_health(health)
	assert(projectile_amount>0,"Can't shoot Zero bullets!")
	print("projectile_chance_to_split: ",projectile_chance_to_split)
	protection_from_damage = clampf(protection_from_damage, 0, 10)

func add_mutation(mutation:MutationData):
	if !current_mutations.has(mutation):
		current_mutations.append(mutation)
		recalculate_stats()
func remove_mutation(mutation:MutationData):
	if current_mutations.has(mutation):
		current_mutations.erase(mutation)
		recalculate_stats()

var can_shoot:bool = true
func shoot_projectile(gun:GUN):
	if !can_shoot:return
	shoot_sfx.play()
	can_shoot = false
	var starter_angle:float = 0.0
	var projectils_to_shoot:int = 1
	if projectile_amount>1:
		if randi_range(1,10)<=10*projectile_chance_to_split:
			projectils_to_shoot = projectile_amount
			if randi_range(1,10)<=10*projectile_chance_to_split:
				projectils_to_shoot+=1
				clamp(projectils_to_shoot,1,3)
	if projectils_to_shoot>1:
		starter_angle = PI*projectile_amount/(16)
	var bullet_dir_sign:int = 1
	assert(projectils_to_shoot>0,"Can't shoot Zero bullets!")
	for i:int in projectils_to_shoot:
		var bullet:PROJECTILE = BULLET.instantiate()
		var angle_offset:float = 0.0
		if (i+1)%2 == 0:  angle_offset = -(2)*starter_angle
		elif (i+1)%3==0:  angle_offset = -(1)*starter_angle
		var rot:float = rotation +starter_angle+angle_offset
		var bullet_mutations:Array =current_mutations.filter(func(x):
			return x.name=="Fire Mutation" or x.name=="Ice Mutation" )
		if !bullet_mutations.is_empty():
			bullet.bullet_mutation = bullet_mutations.pick_random()
		bullet.damage = attack_power
		bullet.rotation = rotation
		bullet.direction = Vector2(cos(rot),sin(rot))
		bullet.global_position = gun.barrel.global_position
		bullet.collision_mask = hurt_area.collision_mask
		bullet.collision_layer = hurt_area.collision_layer
		owner.add_child(bullet)
		bullet_dir_sign*=-1
	await get_tree().create_timer(projectile_cooldown).timeout
	can_shoot = true
	pass
	pass

func knock_back(strength:float = 5,rot:float = rotation):
	velocity -= Vector2(cos(rot),sin(rot)) * strength
	pass

signal is_taking_damage
var creature_taking_damage:bool
func take_damage(val:float):
	if creature_taking_damage:return
	creature_taking_damage = true
	is_taking_damage.emit()
	assert(health_bar)
	health-=val-protection_from_damage
	health_bar.set_health(health)
	if health<=0:
		kill_creature()
	else:hurt_anim()

signal hurt_anim_finished
func hurt_anim():
	hurt_sfx.play()
	const FLASH_AMOUNT:int = 3
	var initial_wait_time:float = 0.15
	hurt_shader_color(Color(1,1,1))
	for i in FLASH_AMOUNT:
		var tween: = create_tween().set_speed_scale(creature_time_scale)
		tween.tween_callback(hurt_shader_toggle.bind(true))
		tween.tween_interval(initial_wait_time)
		tween.tween_callback(hurt_shader_toggle.bind(false))
		tween.tween_interval(initial_wait_time)
		await tween.finished
		creature_taking_damage = false
		initial_wait_time-=0.05
	
	hurt_anim_finished.emit()
	pass

signal death_anim_finished
func death_anim():
	dead_sfx.play()
	const FLASH_AMOUNT:int = 3
	var initial_wait_time:float = 0.15
	hurt_shader_color(Color(0.8,0,0))
	for i in FLASH_AMOUNT:
		var tween: = create_tween()
		tween.tween_callback(hurt_shader_toggle.bind(true))
		tween.tween_interval(initial_wait_time)
		tween.tween_callback(hurt_shader_toggle.bind(false))
		tween.tween_interval(initial_wait_time)
		await tween.finished
		initial_wait_time-=0.05
	hurt_shader_toggle(true)
	death_anim_finished.emit()
	pass

func hurt_shader_color(col:Color):
	anim.set_instance_shader_parameter("flash_color",col)

func hurt_shader_toggle(active:bool):
	anim.set_instance_shader_parameter("is_active",active)

func on_hurt_area_body_entered(area:Area2D):
	if area is PROJECTILE and !creature_taking_damage:
		take_damage(area.damage)
		var knock_scale: = 70
		if self is PLAYER: knock_scale*=5
		#var angle_to_projectile:float = global_position.direction_to(area.global_position).angle()
		#angle_to_projectile = snappedf(angle_to_projectile,PI/2)
		knock_back(knock_scale*area.damage,area.rotation+PI)
		if area.bullet_mutation:
			if area.bullet_mutation.name == "Fire Mutation":burn_creature()
			elif area.bullet_mutation.name == "Ice Mutation":freeze_creature()
	pass
var is_dead:bool
func kill_creature():
	if is_dead:return
	is_dead = true
	death_anim()
	await death_anim_finished
	if self is PLAYER:
		get_tree().reload_current_scene()
		return
	queue_free()

var on_fire:bool
var frozen:bool
func burn_creature():
	on_fire = true
	particles.modulate = Color(0.8,0,0)
	creature_time_scale = 1.0
	recalculate_stats(false)
	particles.emitting = true
	for i in damage_from_fire:
		var tween:= create_tween()
		tween.tween_callback(take_damage.bind(2))
		tween.tween_interval(1)
		if frozen: return
		await tween.finished
	particles.emitting = false
	pass
func freeze_creature():
	frozen = true
	particles.modulate = Color(0.43, 0.6, 1.0)
	particles.emitting = true
	creature_time_scale = 0.1
	recalculate_stats(false)#don't recalculate health
	await get_tree().create_timer(freeze_time).timeout
	if on_fire: return
	creature_time_scale = 1.0
	recalculate_stats(false)#don't recalculate health
	particles.emitting = false
