extends UI
class_name MUTATION_CARD
@export var mutation_type:MutationData
@onready var card_container: MarginContainer = $MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func move_card(offset:float):
	offset/=20
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	card_container.position.x = -card_container.custom_minimum_size.x/2
	tween.tween_property(self,"anchor_left",0.5+offset,0.8)
	tween.tween_property(self,"anchor_right",0.5+offset,0.8)
	pass


func _on_card_pressed() -> void:
	print(mutation_type.name)
	pass # Replace with function body.
