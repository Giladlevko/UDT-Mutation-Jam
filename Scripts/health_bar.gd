extends Control
class_name HEALTH_BAR
@export var bar_size:Vector2 = Vector2(100,15)
@onready var health_bar: ProgressBar = $health
@onready var damage_bar: ProgressBar = $health/damage
@export var max_health:float = 100


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.custom_minimum_size = bar_size
	damage_bar.custom_minimum_size = bar_size
	health_bar.size = bar_size
	damage_bar.size = bar_size
	health_bar.max_value = max_health
	damage_bar.max_value = max_health
	health_bar.value = health_bar.max_value
	damage_bar.value = damage_bar.max_value
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_max(val:float):
	max_health = val
	health_bar.max_value = max_health
	damage_bar.max_value = max_health

func set_health(new_health:float):
	var old_health: = health_bar.value
	health_bar.value =  new_health
	var tween:=create_tween()
	var speed:float = 25.0
	var dur:float = abs(new_health-old_health)/speed
	tween.tween_property(damage_bar,"value",new_health,dur)
	pass
