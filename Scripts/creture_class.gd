extends CharacterBody2D
class_name CREATURE_CLASS
@export var anim:AnimatedSprite2D
@export var colli:CollisionShape2D
@export var hurt_colli:CollisionShape2D
@export var attack_colli:CollisionShape2D

enum STATES{IDLE,RUNNING,DOGING,TAKING_DAMAGE,BURNING,FROZEN,DASH}
var state:STATES = STATES.IDLE

var health:float = 100;
var speed:float = 50
var attack_power:float = 10
var damage_from_fire:float = 5
var freeze_time:float = 0.5
var protection_from_damage:float = 0

var current_mutations:Array[Global.mutations] = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
