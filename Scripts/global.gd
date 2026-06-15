extends Node

const FIRE_MUTATION = preload("res://Scripts/Mutations/fire_mutation.tres")
const ICE_MUTATION = preload("res://Scripts/Mutations/ice_mutation.tres")
const QUICK_MUTATION = preload("res://Scripts/Mutations/quick_mutation.tres")
const SHIELD_MUTATION = preload("res://Scripts/Mutations/shield_mutation.tres")
const SPLIT_PROJECTILE = preload("res://Scripts/Mutations/split_projectile.tres")

enum mutations{FIRE,ICE,SHIELD,QUICK,SPLIT_PROJECTILE,}

const ALL_MUTATIONS:Array[MutationData] = [
	FIRE_MUTATION,ICE_MUTATION,QUICK_MUTATION,SHIELD_MUTATION,SPLIT_PROJECTILE
	]

func switch_scenes(new_scene_path:String):
	var current_scene = get_tree().current_scene
	current_scene.queue_free()
	var new_scene = load(new_scene_path).instantiate()
	print(new_scene)
	get_tree().root.add_child(new_scene)
	current_scene = new_scene
	get_tree().current_scene = current_scene
