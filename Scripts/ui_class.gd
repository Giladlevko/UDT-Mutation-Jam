extends Control
class_name UI

@export var click_sfx:AudioStreamPlayer
@export var hover_sfx:AudioStreamPlayer
@export var song:AudioStreamPlayer

@export var dark_screen:ColorRect
var buttons:Array[Button] = []
signal vis_changed

func enter_trans():
	if get_tree().paused: get_tree().paused = false
	lighten_screen()

func connect_buttons(dur:float = 0.2,scale_size:float = 1.3):
	for button in buttons:
		
		button.mouse_entered.connect(button_mouse_entered.bind(button,scale_size,dur))
		button.mouse_exited.connect(button_mouse_exited.bind(button,dur))
		button.pressed.connect(base_button_pressed)

func base_button_pressed():
	assert(click_sfx != null)
	click_sfx.play()
	pass

func button_mouse_entered(button:Button,scale_size:float,dur:float):
	
	var enlarge:bool = true
	tween_scale(enlarge,button,dur,scale_size)
	assert(hover_sfx != null)
	hover_sfx.play()
	pass

func button_mouse_exited(button:Button,dur:float):
	var enlarge:bool = false
	tween_scale(enlarge,button,dur)
	pass

func darken_screen(dur:float = 0.4):
	assert(dark_screen != null)
	tween_visibility(dark_screen,true,dur)


func lighten_screen(dur:float = 0.4):
	assert(dark_screen != null)
	tween_visibility(dark_screen,false,dur)
	

func tween_music(val:float,dur:float = 0.4):
	assert(song != null)
	var tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(song,"volume_linear",val,dur)

func tween_visibility(node:Control,to_visible:bool,dur:float = 0.3):
	var tween = create_tween()
	var target_color:Color
	node.visible = true
	if to_visible:
		node.modulate.a = 0
		target_color = Color(1,1,1,1)
	else: 
		node.modulate.a = 1
		target_color = Color(1,1,1,0)
	tween.tween_property(node,"modulate",target_color,dur)
	await tween.finished
	vis_changed.emit()
	node.visible = to_visible
	

func tween_scale(enlarge:bool,node:Control,dur:float = 0.2,to_scale:float = 1.3):
	node.pivot_offset = node.size/2
	var tween = create_tween()
	if !enlarge: to_scale = 1
	tween.tween_property(node,"scale",to_scale*Vector2.ONE,dur)


func handle_scene_transition(next_scene:String):
	darken_screen()
	await vis_changed
	Global.switch_scenes(next_scene)
