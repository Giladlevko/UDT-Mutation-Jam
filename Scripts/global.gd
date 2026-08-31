extends Node

var enemies_health_visible:bool = false

const FIRE_MUTATION = preload("res://Scripts/Mutations/fire_mutation.tres")
const ICE_MUTATION = preload("res://Scripts/Mutations/ice_mutation.tres")
const QUICK_MUTATION = preload("res://Scripts/Mutations/quick_mutation.tres")
const SHIELD_MUTATION = preload("res://Scripts/Mutations/shield_mutation.tres")
const SPLIT_PROJECTILE = preload("res://Scripts/Mutations/split_projectile.tres")
const HEALTH_MUTATION = preload("res://Scripts/Mutations/health_mutation.tres")
enum mutations{FIRE,ICE,SHIELD,QUICK,SPLIT_PROJECTILE,HEALTH_MUTATION}

const ALL_MUTATIONS:Array[MutationData] = [
	FIRE_MUTATION,ICE_MUTATION,QUICK_MUTATION,SHIELD_MUTATION,SPLIT_PROJECTILE,HEALTH_MUTATION
	]

const mutation_textures:Dictionary = {
	"FIRE": "res://Assets/sprites/UI/mutations/fire.png",
	"ICE": "res://Assets/sprites/UI/mutations/ice.png",
	"SPLIT": "res://Assets/sprites/UI/mutations/split.png",
	"SPEED": "res://Assets/sprites/UI/mutations/speed.png",
	"SHIELD": "res://Assets/sprites/UI/mutations/shield.png",
	"HEALTH": "res://Assets/sprites/UI/mutations/health_vis.png"
}

const MUTATION_DESCRIPTIONS:Dictionary = {
	"FIRE": "-Fire Damage Recived\n-Freeze Time\n+Speed",
	"ICE":"+Fire Damage Recived\n-Freeze Time\n+Strength\n+Shield\n-Speed",
	"SPEED":"-Health\n-Freeze Time\n-Strength\n+Speed",
	"SHIELD":"+Health\n-Speed\n+Shield",
	"SPLIT":"+Bullet Split\n+Fire Rate\n+Split Chance",
	"HEALTH":"+Health\n+Enemies Health Is\nVisible"
}

var player:PLAYER

var rooms:Array[room_corners]

var phase_index:int = 1

var enemies_mutation:Array[MutationData]

func _ready() -> void:
	SignalBus.room_added.connect(on_room_added)
	

func match_mutation_name_to_short_name(short_name:String):
	match short_name :
		"Fire Mutation":return "FIRE"
		"Ice Mutation": return "ICE"
		"Quick Mutation": return "SPEED"
		"Split Mutation": return "SPLIT"
		"Shield Mutation": return "SHIELD"
		"Health Mutation":return "HEALTH"

func assign_texture(mutation:MutationData)->Texture:
	var texture_path:String
	if !mutation:return
	var short_name = match_mutation_name_to_short_name(mutation.name)
	texture_path = mutation_textures[short_name]
	return load(texture_path)

func get_mutation_description(mutation:MutationData)->String:
	var short_name = match_mutation_name_to_short_name(mutation.name)
	return MUTATION_DESCRIPTIONS[short_name]


class room_corners:
	func _init(TL:Vector2i,TR:Vector2i,BR:Vector2i,BL:Vector2i) -> void:
		top_left = TL
		top_right = TR
		bot_right = BR
		bot_left = BL
	var top_left:Vector2i
	var top_right:Vector2i
	var bot_right:Vector2i
	var bot_left:Vector2i
	func has_point(point:Vector2)->bool:
		if point.x < top_right.x and point.x > top_left.x:
			if point.y > top_left.y and point.y < bot_left.y:
				return true
		return false

func on_room_added(room:room_corners):
	rooms.append(room)
	pass



func switch_scenes(new_scene_path:String):
	var current_scene = get_tree().current_scene
	current_scene.queue_free()
	var new_scene = load(new_scene_path).instantiate()
	print(new_scene)
	get_tree().root.add_child(new_scene)
	current_scene = new_scene
	get_tree().current_scene = current_scene
