extends UI
@onready var pause: Button = $MarginContainer/pause_button_cont/pause
@onready var resume: Button = $MarginContainer/pause_menu/NinePatchRect/VBoxContainer/resume
@onready var back_to_main: Button = $MarginContainer/pause_menu/NinePatchRect/VBoxContainer/back_to_main

@onready var countdown_label: Label = $MarginContainer/countdown_cont/countdown_label
@onready var countdown_cont: MarginContainer = $MarginContainer/countdown_cont
@onready var pause_menu: MarginContainer = $MarginContainer/pause_menu

@onready var dash_bar: ProgressBar = $MarginContainer/dash_cont/dash_bar


var in_countdown:bool
signal countdown_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons = [pause,resume,back_to_main]
	countdown_label.text = ""
	enter_trans()
	SignalBus.start_dash_cooldown.connect(dash_cooldown)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	else:
		if !in_countdown:
			tween_visibility(pause_menu,false)
			countdown()
			await countdown_finished
			get_tree().paused = false
	pass # Replace with function body.


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
	
	
