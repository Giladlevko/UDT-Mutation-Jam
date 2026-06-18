extends UI
class_name DEL_MUT_DISPLAY
@onready var mutation_1_tex: TextureRect = $Panel/VBoxContainer/HBoxContainer/mut_but_1/mutation_1
@onready var mutation_2_tex: TextureRect = $Panel/VBoxContainer/HBoxContainer/mut_but_2/mutation_2
@onready var mut_but_1: Button = $Panel/VBoxContainer/HBoxContainer/mut_but_1
@onready var mut_but_2: Button = $Panel/VBoxContainer/HBoxContainer/mut_but_2
var mut_1:MutationData
var mut_2:MutationData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mutation_1_tex.texture = null
	mutation_2_tex.texture = null
	buttons = [mut_but_1,mut_but_2]
	SignalBus.init_mutation_selection.connect(assign_mut_to_texture)
	mutation_2_tex.tooltip_text = "Empty"
	mutation_1_tex.tooltip_text = "Empty"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func assign_mut_to_texture():
	mutation_2_tex.texture = null
	mutation_1_tex.texture = null
	if !Global.player:return
	for mut:MutationData in Global.player.current_mutations:
		if !mutation_1_tex.texture:
			mutation_1_tex.texture = Global.assign_texture(mut)
			mut_1 = mut
			mutation_1_tex.tooltip_text = Global.get_mutation_description(mut)
		elif !mutation_2_tex.texture:
			mutation_2_tex.texture = Global.assign_texture(mut)
			mut_2 = mut
			mutation_2_tex.tooltip_text = Global.get_mutation_description(mut)
		


func _on_mut_but_2_pressed() -> void:
	if !mut_2:return
	SignalBus.remove_mutation_from_diplay.emit(mut_2)
	mut_2 = null
	mutation_2_tex.texture = null
	mutation_2_tex.tooltip_text = "Empty"
	pass # Replace with function body.


func _on_mut_but_1_pressed() -> void:
	if !mut_1:return
	SignalBus.remove_mutation_from_diplay.emit(mut_1)
	mutation_1_tex.tooltip_text = "Empty"
	mut_1 = null
	mutation_1_tex.texture = null
	pass # Replace with function body.
