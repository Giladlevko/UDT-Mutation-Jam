extends CharacterBody2D
class_name PROJECTILE
var direction:Vector2
@export var speed:float = 1000
@export var lifetime:float = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	death_timer(lifetime)
	emit_bullet()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	move_and_slide()

func emit_bullet():
	direction = direction.normalized()
	velocity = speed * direction

func death_timer(dur:float):
	await get_tree().create_timer(dur).timeout
	print("freed bullet")
	self.queue_free()
