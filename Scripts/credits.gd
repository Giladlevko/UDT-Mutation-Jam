extends UI
@onready var back_to_main: Button = $Panel/MarginContainer/back_to_main


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons = [back_to_main]
	enter_trans()
	song_on(song,-15,3)
	connect_buttons()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_to_main_pressed() -> void:
	handle_scene_transition("res://Scenes/main_menu.tscn")
	pass # Replace with function body.
