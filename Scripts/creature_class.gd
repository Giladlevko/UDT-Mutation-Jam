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



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func initialize_setup():
	recalculate_stats()
	hurt_area.area_entered.connect(on_hurt_area_body_entered)
	hurt_area.collision_layer = collision_layer
	hurt_area.collision_mask = collision_mask
	health_bar.max_health = health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func recalculate_stats():
	assert(base_stats,"Did not assign base stats")
	
	health = base_stats.health
	speed = base_stats.speed
	attack_power = base_stats.attack_power
	damage_from_fire = base_stats.damage_from_fire
	freeze_time = base_stats.damage_from_fire
	protection_from_damage = base_stats.protection_from_damage
	projectile_amount = base_stats.projectile_amount
	projectile_cooldown = base_stats.projectile_cooldown
	projectile_chance_to_split = base_stats.projectile_chance_to_split
	
	for mutation:MutationData in current_mutations:
		health = mutation.health
		speed *= mutation.speed_mult
		attack_power *= mutation.attack_power_mult
		damage_from_fire *= mutation.fire_damage_mult
		freeze_time *= mutation.freeze_time_mult
		protection_from_damage += mutation.protection_from_damage
		projectile_amount *= mutation.projectile_mult
		projectile_cooldown *= mutation.projectile_cool_mult
		projectile_chance_to_split = max(projectile_chance_to_split,mutation.projectile_chance_to_split)
	
	protection_from_damage = clampi(protection_from_damage, 0, 10)

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
	can_shoot = false
	var starter_angle:float = 0.0
	var projectils_to_shoot:int = 1
	if randi_range(1,10)<=10*projectile_chance_to_split:
		projectils_to_shoot = projectile_amount
	if projectils_to_shoot>1:
		starter_angle = PI*projectile_amount/(16)
	var bullet_dir_sign:int = 1
	for i:int in projectils_to_shoot:
		var bullet:PROJECTILE = BULLET.instantiate()
		var angle_offset:float = 0.0
		if (i+1)%2 == 0:  angle_offset = -(2)*starter_angle
		elif (i+1)%3==0:  angle_offset = -(1)*starter_angle
		var rot:float = rotation +starter_angle+angle_offset
		bullet.direction = Vector2(cos(rot),sin(rot))
		bullet.global_position = gun.barrel.global_position
		bullet.collision_mask = collision_mask
		bullet.collision_layer = collision_layer
		owner.add_child(bullet)
		bullet_dir_sign*=-1
	await get_tree().create_timer(projectile_cooldown).timeout
	can_shoot = true
	pass
	pass

func knock_back(strength:float = 5):
	velocity -= Vector2(cos(rotation),sin(rotation)) * strength
	pass

func take_damage(val:float):
	assert(health_bar)
	health-=val
	health_bar.set_health(health)
	if health<=0:
		kill_creature()
	

func on_hurt_area_body_entered(area:Area2D):
	if area is PROJECTILE:
		take_damage(area.damage)
	pass

func kill_creature():
	if self is PLAYER:
		get_tree().reload_current_scene()
		return
	queue_free()
