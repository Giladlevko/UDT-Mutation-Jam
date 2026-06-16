extends UI
class_name MUTATION_CARD
@export var mutation_type:MutationData
@onready var card_container: MarginContainer = $MarginContainer
@onready var card: TextureButton = $MarginContainer/card

const mutation_textures:Dictionary = {
	"FIRE": "res://Assets/sprites/UI/mutations/fire.png",
	"ICE": "res://Assets/sprites/UI/mutations/ice.png",
	"SPLIT": "res://Assets/sprites/UI/mutations/split.png",
	"SPEED": "res://Assets/sprites/UI/mutations/speed.png",
	"SHIELD": "NULL"
}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func move_card(offset:float):
	assign_texture(mutation_type)
	offset/=20
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	card_container.position.x = -card_container.custom_minimum_size.x/2
	tween.tween_property(self,"anchor_left",0.5+offset,0.8)
	tween.tween_property(self,"anchor_right",0.5+offset,0.8)
	pass


func assign_texture(mutation:MutationData):
	var texture_path:String
	match mutation.name:
		"Fire Mutation":texture_path = mutation_textures["FIRE"]
		"Ice Mutation": texture_path = mutation_textures["ICE"]
		"Quick Mutation": texture_path = mutation_textures["SPEED"]
		"Split Mutation": texture_path = mutation_textures["SPLIT"]
		"Shield Mutation": texture_path = mutation_textures["SHIELD"]
	card.texture_pressed = load(texture_path)

func _on_card_pressed() -> void:
	print(mutation_type.name)
	pass # Replace with function body.
