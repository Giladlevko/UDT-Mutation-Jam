extends UI
class_name TEXT_BOX
@onready var label: RichTextLabel = $Panel/MarginContainer/Label
@onready var end_label: RichTextLabel = $Panel/end_label
@export var text_name_to_display:String
@export var dialog_data: DialogData
var speed:float = 30
signal dialog_finished
signal line_finished
signal input_pressed
var effect_start:String
var effect_end:String
var dialog_ended:bool



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0
	line_finished.connect(on_line_finished)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("DASH"):
		#play_dialog("Mutation Intro","wave")
	pass


func select_text(id: String)->DialogLine:
	if dialog_data.entries.has(id):
		return dialog_data.entries[id]
	return null


func play_dialog(dialog_name:String,effect:String = "wave"):
	reset_text()
	tween_visibility(self,true)
	dialog_ended = false
	await vis_changed
	if effect !="": set_effect(effect)
	var text_lines:DialogLine = select_text(dialog_name)
	for line in text_lines.lines:
		display_text(line,effect)
		await line_finished
		if line != text_lines.lines[-1]:
			await input_pressed
	
	dialog_ended = true
	

func get_reveal_dur(message:String)->float:
	return message.length()/speed


var line_tween:Tween
func display_text(message:String,effect:String = ""):
	if !line_tween or !line_tween.is_valid():line_tween = create_tween()
	line_tween.set_speed_scale(1)
	tween_visibility(end_label,false)
	label.visible_ratio = 0
	label.text = effect_start + message + effect_end
	var dur: = get_reveal_dur(message)
	line_tween.tween_property(label,"visible_ratio",1,dur)
	await line_tween.finished
	line_finished.emit()
	

func on_line_finished():
	tween_visibility(end_label,true)

func reset_text():
	label.text = ""
	label.visible_ratio = 0
	tween_visibility(end_label,false)

func reset_effect():
	effect_start = ""
	effect_end = ""

func set_effect(effect:String):
	effect_start = "["+effect+"]"
	effect_end = "[/"+effect+"]"

func _input(event):
	if !dialog_ended:
		if event.is_action_pressed("Continue Dialog") and line_tween:
			if line_tween.is_running():
				line_tween.set_speed_scale(100)
				label.visible_ratio = 1
				await line_tween.finished
				await line_finished
			input_pressed.emit()
			print("Moving to next dialog line!")
	else:
		if event.is_action_pressed("Continue Dialog"):
			tween_visibility(self,false)
			dialog_finished.emit()
