extends UI
@onready var pause: Button = $MarginContainer/pause_button_cont/pause
@onready var resume: Button = $MarginContainer/pause_menu/NinePatchRect/VBoxContainer/resume
@onready var back_to_main: Button = $MarginContainer/pause_menu/NinePatchRect/VBoxContainer/back_to_main
const MUT_CARD = preload("res://Scenes/mutation_card.tscn")
@onready var countdown_label: Label = $MarginContainer/countdown_cont/countdown_label
@onready var countdown_cont: MarginContainer = $MarginContainer/countdown_cont
@onready var pause_menu: MarginContainer = $MarginContainer/pause_menu

@onready var dash_bar: ProgressBar = $MarginContainer/dash_cont/dash_bar

@onready var mutation_display_1: TextureRect = $MarginContainer/mutation_display/HBoxContainer/TextureRect/mutation_1
@onready var mutation_display_2: TextureRect = $MarginContainer/mutation_display/HBoxContainer/TextureRect2/mutation_2

@onready var message_label: Label = $MarginContainer/message_cont/message_label

@onready var card_cont: MarginContainer = $MarginContainer/mutation_menu/card_cont

@onready var mutation_menu: MarginContainer = $MarginContainer/mutation_menu


var in_countdown:bool
signal countdown_finished
signal message_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	message_label.text = ""
	buttons = [pause,resume,back_to_main]
	countdown_label.text = ""
	enter_trans()
	SignalBus.start_dash_cooldown.connect(dash_cooldown)
	SignalBus.init_mutation_selection.connect(on_init_mut_select)
	SignalBus.mutation_selected.connect(add_mutation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("DASH"):
		display_cards()
	if Input.is_action_just_pressed("DOWN"):
		remove_cards()
	pass



func countdown(sec:int = 3):
	in_countdown = true
	countdown_label.text = str(sec)
	countdown_cont.pivot_offset = countdown_cont.size/2
	countdown_label.pivot_offset = countdown_label.size / 2
	countdown_label.scale = Vector2(0,0)
	for i in range(1,sec+1):
		var tween = create_tween()
		countdown_label.text = str(sec+1-i)
		tween.tween_property(countdown_label,"scale",1*Vector2(1,1),0.25)
		tween.tween_interval(0.5)
		tween.tween_property(countdown_label,"scale",0*Vector2(1,1),0.25)
		await tween.finished
		tween.kill()
	countdown_label.text = ""
	in_countdown = false
	countdown_finished.emit()


func _on_pause_pressed() -> void:
	if !get_tree().paused:
		tween_visibility(pause_menu,true)
		get_tree().paused = true
	else:
		if !in_countdown:
			tween_visibility(pause_menu,false)
			countdown()
			await countdown_finished
			get_tree().paused = false
	pass # Replace with function body.


var message_tweening:bool
var messages_to_tween:Array[String] = []
func display_message(message:String):
	if !message_tweening:
		message_label.text = message
		message_tweening = true
		var tween = create_tween()
		tween.tween_property(message_label,"modulate",Color(1,1,1,1),0.2)
		tween.tween_interval(1.5)
		tween.tween_property(message_label,"modulate",Color(1,1,1,0),0.2)
		await tween.finished
		message_tweening = false
		message_finished.emit()
	else:
		if messages_to_tween.has(message):return
		messages_to_tween.append(message)

func display_awaiting_messages():
	if messages_to_tween.is_empty(): return
	var next_message = messages_to_tween.pop_front()
	display_message(next_message)

func _on_back_to_main_pressed() -> void:
	handle_scene_transition("res://Scenes/main_menu.tscn")
	pass # Replace with function body.


func dash_cooldown(dur:float):
	tween_visibility(dash_bar,true)
	dash_bar.value = dash_bar.max_value
	var tween = create_tween()
	tween.tween_property(dash_bar,"value",dash_bar.min_value,dur)
	await get_tree().create_timer(clamp(dur-0.2,0,dur)).timeout
	tween_visibility(dash_bar,false)
	await tween.finished
	SignalBus.dash_ready.emit()
	
	
const CARD_AMOUNT = 3
func display_cards():
	var player_mut:Array[MutationData] = get_current_mutations()
	var mutation_copy:Array[MutationData] = Global.ALL_MUTATIONS.duplicate()
	mutation_copy.filter(func (x):return !player_mut.has(x))
	mutation_copy.shuffle()
	var offset:float = 1.0
	for card:MUTATION_CARD in card_cont.get_children():
		card.mutation_type = mutation_copy.pop_back()
		for m:MutationData in mutation_copy:
			print(m.name)
		print()
		card.move_card(offset)
		await get_tree().create_timer(0.4).timeout
		offset-=1

func remove_cards():
	for card:MUTATION_CARD in card_cont.get_children():
		card.remove_card()
		await get_tree().create_timer(0.2).timeout
	

func get_current_mutations()->Array[MutationData]:
	if Global.player:
		return Global.player.current_mutations
	else: return []

func add_mutation(mutation:MutationData):
	
	if mutation_display_1.texture == null:
		mutation_display_1.texture = Global.assign_texture(mutation)
	elif mutation_display_2.texture == null:
		mutation_display_2.texture = Global.assign_texture(mutation)
	else:
		display_message("Mutations are Full!")
		
		push_error("Both Displays Are None Empty. Cannot assign new mutation!")
		return
	if Global.player:
		Global.player.current_mutations.append(mutation)
	display_message(mutation.name+" selected!")
	print(mutation.name," Added!")
	reveal_cards()
	pass

func reveal_cards():
	var cards:Array = card_cont.get_children()
	cards.reverse()
	for card:MUTATION_CARD in cards:
		card.disable_card_and_reveal()
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(3).timeout
	remove_cards()
	pass

func on_init_mut_select():
	tween_visibility(mutation_menu,true)
	await vis_changed
	display_message("Wave Completed!\nTime to Choose a Mutation!")
	await message_finished
	display_cards()
	pass
