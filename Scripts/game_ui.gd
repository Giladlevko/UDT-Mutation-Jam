extends UI

@onready var pause: Button = $MarginContainer/pause_button_cont/VBoxContainer/pause

@onready var resume: Button = $MarginContainer/pause_menu/panel/VBoxContainer/resume
@onready var back_to_main: Button = $MarginContainer/pause_menu/panel/VBoxContainer/back_to_main
@onready var text_box: TEXT_BOX = $text_cont/TextBox

@onready var time_label: Label = $MarginContainer/pause_button_cont/VBoxContainer/Panel/time_label

const MUT_CARD = preload("res://Scenes/mutation_card.tscn")
@onready var countdown_label: Label = $MarginContainer/countdown_cont/countdown_label
@onready var countdown_cont: MarginContainer = $MarginContainer/countdown_cont
@onready var pause_menu: MarginContainer = $MarginContainer/pause_menu

@onready var dash_bar: ProgressBar = $MarginContainer/dash_cont/dash_bar

@onready var mutation_display_1: TextureRect = $MarginContainer/mutation_display/HBoxContainer/TextureRect/mutation_1
@onready var mutation_display_2: TextureRect = $MarginContainer/mutation_display/HBoxContainer/TextureRect2/mutation_2

@onready var message_label: Label = $MarginContainer/message_cont/message_panel/message_label
@onready var message_panel: Panel = $MarginContainer/message_cont/message_panel

@onready var skip_mut_selec: Button = $MarginContainer/mutation_menu/skip_cont/skip_mut_selec

@onready var card_cont: MarginContainer = $MarginContainer/mutation_menu/card_cont

@onready var mutation_menu: Control = $MarginContainer/mutation_menu
@onready var accept_choice: Button = $MarginContainer/mutation_menu/mut_button_cont/accept_choice
@onready var mut_button_cont: MarginContainer = $MarginContainer/mutation_menu/mut_button_cont
@onready var mutation_delet_display: DEL_MUT_DISPLAY = $MarginContainer/mutation_menu/delete_mut_cont/mutation_delet_display

@onready var mutation_song: AudioStreamPlayer = $songs/mutation_song

@onready var game_length: Timer = $game_length
@onready var back_to_main_from_death: Button = $death_cont/Panel/VBoxContainer/back_to_main
@onready var restart_but: Button = $death_cont/Panel/VBoxContainer/restart_but
@onready var death_cont: MarginContainer = $death_cont

var mutations_just_removed:Array[MutationData]

var in_countdown:bool

signal countdown_finished
signal message_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().paused:get_tree().paused = false
	message_label.text = ""
	message_panel.modulate.a = 0
	buttons = [pause,resume,back_to_main,back_to_main_from_death,restart_but,skip_mut_selec]
	countdown_label.text = ""
	enter_trans()
	connect_buttons()
	accept_choice.mouse_entered.connect(button_mouse_entered.bind(accept_choice,1.1,0.2))
	accept_choice.mouse_exited.connect(button_mouse_exited.bind(accept_choice,0.2))
	
	SignalBus.start_dash_cooldown.connect(dash_cooldown)
	SignalBus.init_mutation_selection.connect(next_phase)
	SignalBus.mutation_selected.connect(add_mutation)
	SignalBus.display_message.connect(display_message)
	SignalBus.remove_mutation_from_diplay.connect(on_mutation_removed)
	SignalBus.reset_game.connect(on_player_death)
	message_finished.connect(display_awaiting_messages)
	song_on(song,-15,5)
	
	if Global.phase_index == 1:
		call_deferred("handle_intro")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("Debug Test"):
		#next_phase()
	
	var minutes:int = round(game_length.time_left)/60
	var sec:int = round(game_length.time_left) - minutes*60
	time_label.text = str(minutes)+" : "+str(sec)
	
	#if Input.is_action_just_pressed("DOWN"):
		#remove_cards()
	pass


func handle_intro():
	await get_tree().create_timer(0.01).timeout
	get_tree().set_deferred("paused",true)
	text_box.play_dialog("Game Intro")
	await text_box.dialog_finished
	countdown()
	await countdown_finished
	get_tree().paused = false
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
func display_message(message:String,display_time:float = 1.5):
	if !message_tweening:
		message_tweening = true
		message_label.text = message
		var new_panel_length = (
			(message.length()-message.count(" "))*
			message_label.get_theme_font_size("font_size")
			)
		message_panel.custom_minimum_size.x = new_panel_length
		
		var tween = create_tween()
		tween.tween_property(message_panel,"modulate",Color(1,1,1,1),0.2)
		tween.tween_interval(display_time)
		tween.tween_property(message_panel,"modulate",Color(1,1,1,0),0.2)
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
	on_game_reset()
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
	print(player_mut)
	var mutation_copy:Array[MutationData] = Global.ALL_MUTATIONS.duplicate()
	print(mutation_copy)
	mutation_copy = mutation_copy.filter(
		func (x):return !player_mut.has(x) and !mutations_just_removed.has(x)
		)
	mutations_just_removed.clear()
	mutation_copy.shuffle()
	if mutation_copy.is_empty():push_error("No Mutations To assign to cards!")
	var offset:float = 1.0
	for card:MUTATION_CARD in card_cont.get_children():
		card.mutation_type = mutation_copy.pop_back()
		for m:MutationData in mutation_copy:
			print(m.name)
		print()
		card.move_card(offset)
		await get_tree().create_timer(0.4).timeout
		offset-=1

signal removed_cards
func remove_cards():
	for card:MUTATION_CARD in card_cont.get_children():
		card.remove_card()
		await get_tree().create_timer(0.2).timeout
	removed_cards.emit()


func get_current_mutations()->Array[MutationData]:
	if Global.player:
		return Global.player.current_mutations
	else: return []

func add_mutation(mutation:MutationData):
	if mutation_display_2.texture == null:
		mutation_display_2.texture = Global.assign_texture(mutation)
	elif mutation_display_1.texture == null:
		mutation_display_1.texture = Global.assign_texture(mutation)
	else:
		display_message("Mutations are Full!")
		
		push_error("Both Displays Are None Empty. Cannot assign new mutation!")
		return
	if Global.player:
		assert(!Global.player.current_mutations.has(mutation),"Already holding "+mutation.name)
		Global.player.add_mutation(mutation)
	print(mutation.name," Added!")
	reveal_cards(mutation)
	
	pass

func on_mutation_removed(mut:MutationData):
	mutations_just_removed.append(mut)
	display_message(mut.name+" removed!")
	Global.player.remove_mutation(mut)
	var mut_tex:Texture = Global.assign_texture(mut)
	if mutation_display_1.texture == mut_tex:
		mutation_display_1.texture = null
	elif mutation_display_2.texture == mut_tex:
		mutation_display_2.texture = null
	pass

func reveal_cards(selected_mut:MutationData):
	var cards:Array = card_cont.get_children()
	var unselected_mutations:Array[MutationData]
	cards.reverse()
	for card:MUTATION_CARD in cards:
		if card.mutation_type !=selected_mut:
			unselected_mutations.append(card.mutation_type)
			Global.enemies_mutation = unselected_mutations.duplicate()
		card.disable_card_and_reveal()
		await get_tree().create_timer(0.1).timeout
	on_mutation_selection_end(selected_mut,unselected_mutations)
	pass

#mutation menu initialization
func on_init_mut_select():
	mutation_delet_display.assign_mut_to_texture()
	mutation_menu_transotion(true)
	await vis_changed
	tween_visibility(mutation_delet_display,true,0.2)
	text_box.play_dialog("Mutation Intro")
	await text_box.dialog_finished
	tween_visibility(mut_button_cont,true)
	pass

func mut_name_to_txt(mutation:MutationData)->String:
	print(mutation.txt_color)
	print(mutation.rgb_color_for_text)
	mutation.txt_color = "#"+mutation.rgb_color_for_text.to_html(false)
	return "[color="+mutation.txt_color+"]"+"[shake]"+mutation.name+"[/shake][/color]"


func on_mutation_selection_end(selected_mut:MutationData,unselected_mutations:Array[MutationData]):
	var text_lines:DialogLine = DialogLine.new()
	text_lines.speaker = "Game"
	text_lines.lines = [
		mut_name_to_txt(selected_mut)+" Selected!",
		mut_name_to_txt(unselected_mutations[0])+" and "+mut_name_to_txt(unselected_mutations[1])+
		" will apply to the enemies on the next wave!"
	]
	text_box.dialog_data.entries["Mutation Selection End"]=text_lines
	text_box.play_dialog("Mutation Selection End")
	await text_box.dialog_finished
	tween_visibility(mut_button_cont,true)
	pass

var cards_displayed:bool
func _on_accept_choice_pressed() -> void:
	click_sfx.play()
	if Global.player:
		if Global.player.current_mutations.size()>1 and !cards_displayed:
			display_message("You are holding too many Mutations!")
			display_message("Remove at least one Mutation by clicking on its icon!")
			return
	tween_visibility(mut_button_cont,false)
	await vis_changed
	
	if !cards_displayed:
		tween_visibility(skip_mut_selec,false)
		tween_visibility(mutation_delet_display,false)
		await vis_changed
		await get_tree().create_timer(0.3).timeout
		display_cards()
		cards_displayed = true
	else:
		cards_displayed = false
		remove_cards()
		await removed_cards
		mutation_menu_transotion(false)
		pass

func mutation_menu_transotion(to_visible:bool):
	if to_visible: 
		song_off(song)
		await volume_changed
		song_on(mutation_song)
		
		
	else:
		song_off(mutation_song)
		await volume_changed
		song_on(song)
		
		
	get_tree().paused = to_visible
	darken_screen()
	await vis_changed
	if !to_visible:SignalBus.reset_level.emit()
	tween_visibility(skip_mut_selec,to_visible)
	await vis_changed
	tween_visibility(mutation_menu,to_visible)
	await vis_changed
	lighten_screen()
	await vis_changed
	if !to_visible:game_length.start()


func _on_game_length_timeout() -> void:
	game_length.stop()
	display_message("Eliminate the enemies to get to the next phase!",3)
	SignalBus.game_timer_finished.emit()
	pass # Replace with function body.

func next_phase():
	Global.enemies_mutation.clear()
	on_init_mut_select()

func on_game_reset(to_scene:String = "res://Scenes/main_menu.tscn"):
	Global.rooms.clear()
	Global.phase_index = 1
	Global.enemies_mutation.clear()
	handle_scene_transition(to_scene)

func on_player_death():
	get_tree().paused = true
	tween_visibility(death_cont,true)

func _on_restart_but_pressed() -> void:
	on_game_reset("res://Scenes/level_1.tscn")
	pass # Replace with function body.


func _on_skip_mut_selec_pressed() -> void:
	text_box._on_skip_button_pressed()
	mutation_menu_transotion(false)
