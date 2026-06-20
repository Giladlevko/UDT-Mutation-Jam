extends Area2D
class_name PROJECTILE
var direction:Vector2
@export var speed:float = 1000
@export var lifetime:float = 0.5
@export var bullet_mutation:MutationData
@onready var cpu_particles: CPUParticles2D = $CPUParticles2D



@export var damage:float = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if bullet_mutation:
		cpu_particles.modulate = bullet_mutation.rgb_color_for_text
	death_timer(lifetime)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	emit_bullet(delta)

func emit_bullet(delta:float):
	direction = direction.normalized()
	position += speed * direction * delta

func death_timer(dur:float):
	await get_tree().create_timer(dur).timeout
	print("freed bullet")
	self.queue_free()
