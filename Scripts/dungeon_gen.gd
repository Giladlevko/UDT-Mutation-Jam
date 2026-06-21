extends Node2D
class_name DUNGEON_GENERATOR
@export var room_amount:int = 4
const DUNG_ROOM = preload("res://Scenes/dungeon_room.tscn")
const DUNG_HALLWAY = preload("res://Scenes/dungeon_hallway.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	var current_hall_way:DUNGEON_HALLWAY
	var current_room:DUNGEON_ROOM

	while(room_amount>0):
		if current_hall_way:
			var room = DUNG_ROOM.instantiate()
			current_room = current_hall_way.add_dungeon_room(room)
			room_amount-=1
			#await get_tree().create_timer(1).timeout
			current_hall_way = null
		elif current_room:
			var hall = DUNG_HALLWAY.instantiate()
			current_hall_way = current_room.add_dungeon_hallway(hall)
			assert(current_hall_way)
			#await get_tree().create_timer(1).timeout
			current_room = null
			pass
		else:
			var room = DUNG_ROOM.instantiate()
			add_child(room)
			room.global_position = global_position
			current_room = room
			room_amount-=1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
