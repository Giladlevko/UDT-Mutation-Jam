extends Node


enum mutations{FIRE,ICE,SHIELD,QUICK,SPLIT_PROJECTILE,}

func switch_scenes(new_scene_path:String):
	var current_scene = get_tree().current_scene
	current_scene.queue_free()
	var new_scene = load(new_scene_path).instantiate()
	print(new_scene)
	get_tree().root.add_child(new_scene)
	current_scene = new_scene
	get_tree().current_scene = current_scene
