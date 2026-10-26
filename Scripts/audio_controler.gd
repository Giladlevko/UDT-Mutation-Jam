extends UI
class_name AUDIO_CONTROLER

@onready var sfx_slider: HSlider = $Panel/VBoxContainer/sfx_control/sfx_slider
@onready var music_slider: HSlider = $Panel/VBoxContainer/music_control/music_slider
@onready var music_title: Label = $Panel/VBoxContainer/music_control/title
@onready var sfx_title: Label = $Panel/VBoxContainer/sfx_control/title
@onready var global_title: Label = $Panel/VBoxContainer/global_control/title
@onready var global_slider: HSlider = $Panel/VBoxContainer/global_control/global_slider
@onready var ui_title: Label = $Panel/VBoxContainer/ui_control/title
@onready var ui_slider: HSlider = $Panel/VBoxContainer/ui_control/ui_slider

@onready var BASE_MUSIC_VOL:float = db_to_linear(0.0)
@onready var BASE_SFX_VOL:float = db_to_linear(0.0)
@onready var BASE_GLOBAL_VOL:float = db_to_linear(0.0)
@onready var BASE_UI_VOL:float = db_to_linear(0.0)

@onready var close_button: Button = $Panel/button_cont/close_button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons.push_back(close_button)
	connect_buttons()
	update_slider_to_real_audio()
	
	pass # Replace with function body.

func update_slider_to_real_audio():
	sfx_slider.value = Global.audio_value["SFX"]
	music_slider.value = Global.audio_value["Music"]
	ui_slider.value = Global.audio_value["UI"]
	global_slider.value = Global.audio_value["Global"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_music_slider_value_changed(value: float) -> void:
	music_title.text = "Music: " + str(int(round(value))) +"%"
	var index:int = AudioServer.get_bus_index("music")
	var vol_mult:float = music_slider.max_value/2.0
	var new_vol:float = BASE_MUSIC_VOL * (value / vol_mult)
	AudioServer.set_bus_volume_linear(index,new_vol)
	Global.audio_value["Music"] = int(value)


func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_title.text = "SFX: " + str(int(round(value))) +"%"
	var index:int = AudioServer.get_bus_index("sfx")
	var vol_mult:float = sfx_slider.max_value/2.0
	var new_vol:float = BASE_SFX_VOL * (value / vol_mult)
	AudioServer.set_bus_volume_linear(index,new_vol)
	Global.audio_value["SFX"] = int(value)


func _on_global_slider_value_changed(value: float) -> void:
	global_title.text = "Global: " + str(int(round(value))) +"%"
	var index:int = AudioServer.get_bus_index("Master")
	var vol_mult:float = global_slider.max_value/2.0
	var new_vol:float = BASE_GLOBAL_VOL * (value / vol_mult)
	AudioServer.set_bus_volume_linear(index,new_vol)
	Global.audio_value["Global"] = int(value)


func _on_ui_slider_value_changed(value: float) -> void:
	ui_title.text = "UI: " + str(int(round(value))) +"%"
	var index:int = AudioServer.get_bus_index("UI")
	var vol_mult:float = ui_slider.max_value/2.0
	var new_vol:float = BASE_UI_VOL * (value / vol_mult)
	AudioServer.set_bus_volume_linear(index,new_vol)
	Global.audio_value["UI"] = int(value)


func _on_close_button_pressed() -> void:
	tween_visibility(self,false)
