extends UI
@onready var start: Button = $MarginContainer/VBoxContainer/buttons/start
@onready var credits: Button = $MarginContainer/VBoxContainer/buttons/credits
@onready var quit: Button = $MarginContainer/VBoxContainer/buttons/quit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons = [start,credits,quit]
	connect_buttons()
	enter_trans()
	song_on(song,-15,3)
	pass # Replace with function body.d


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	handle_scene_transition("res://Scenes/level_1.tscn")
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	darken_screen()
	await vis_changed
	get_tree().quit()
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	handle_scene_transition("res://Scenes/credits.tscn")
	pass # Replace with function body.
