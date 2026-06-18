extends UI
class_name MUTATION_CARD
@export var mutation_type:MutationData

@onready var card_button: Button = $card_button

@export var base_tex:Texture
@onready var mutation_name: Label = $card_button/VBoxContainer/mutation_name
@onready var stats: Label = $card_button/VBoxContainer/stats
@onready var card_texture: TextureRect = $card_button/VBoxContainer/card_texture




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0
	stats.text = ""
	mutation_name.text = ""
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("DASH"):
		#move_card(0)
	#if Input.is_action_just_pressed("DOWN"):
		#remove_card()
	pass


func move_card(offset:float):
	
	tween_visibility(self,true)
	offset/=3
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel()
	card_button.position.x = -card_button.custom_minimum_size.x/2
	tween.tween_property(card_button,"anchor_left",0.5+offset,0.8)
	tween.tween_property(card_button,"anchor_right",0.5+offset,0.8)
	pass

func remove_card():
	tween_visibility(self,false)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel()
	tween.tween_property(card_button,"anchor_left",1,0.8)
	tween.tween_property(card_button,"anchor_right",1,0.8)
	await tween.finished
	reset_card()

func reset_card():
	card_button.disabled = false
	card_texture.texture = base_tex
	mutation_name.text = ""
	stats.text = ""
	card_button.position.x = 0
	card_button.anchor_left = 0
	card_button.anchor_right = 0
	card_button.offset_left = 0
	card_button.offset_right = 0
	card_button.scale = Vector2.ONE

func assign_texture(mutation:MutationData):
	var tex:Texture = Global.assign_texture(mutation)
	card_texture.texture = tex
	mutation_name.text = mutation.name
	stats.text = Global.get_mutation_description(mutation)
	
	

func disable_card_and_reveal():
	assign_texture(mutation_type)
	anim_card()
	card_button.disabled = true
	card_button.set_pressed_no_signal(true)

func anim_card():
	card_texture.pivot_offset = card_texture.size/2
	var rand_degree:int = randi_range(5,20)
	var rand_sign:int = [1,-1].pick_random()
	var tween: = create_tween()
	
	tween.tween_property(card_button,"rotation_degrees",rand_degree*rand_sign,0.2)
	tween.tween_property(card_button,"rotation_degrees",0,0.2)
	pass

func _on_card_pressed() -> void:
	assign_texture(mutation_type)
	SignalBus.mutation_selected.emit(mutation_type)
	print(mutation_type.name)
	pass # Replace with function body.


func _on_card_button_mouse_entered() -> void:
	if card_button.disabled:return
	tween_scale(true,card_button,0.2,1.2)
	anim_card()
	pass # Replace with function body.


func _on_card_button_mouse_exited() -> void:
	if card_button.disabled:return
	tween_scale(true,card_button,0.2,1)
	anim_card()
