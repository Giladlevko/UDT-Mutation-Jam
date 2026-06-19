extends DUNGEON_ROOM
class_name DUNGEON_HALLWAY
enum hallway_types{VERTICAL,HORIZONTAL}
@export var hallway_type:hallway_types = hallway_types.HORIZONTAL
@onready var nav_link: NavigationLink2D = $NavigationLink2D

var hallway_max_mult = 10
var hallway_min_mult = 5
var entry_point:Vector2
var exit_point:Vector2
var hallway_length:int = 1

var exit_corner_1:Vector2i
var exit_corner_2:Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = snap_to_tile(global_position)
	tile_size = tile_map.tile_set.tile_size.x
	max_length_mult = hallway_max_mult
	min_length_mult = hallway_min_mult
	min_length = min_length_mult * tile_size
	max_length = max_length_mult * tile_size
	room_h_size = randi_range(min_length,max_length)
	room_v_size = randi_range(min_length,max_length)
	room_h_size = snapped(room_h_size,tile_size)
	room_v_size = snapped(room_v_size,tile_size)
	check_type_fit()
	hallway_length = max(room_h_size,room_v_size)
	
	init_room(false)
	
	draw_hallway()
	pass # Replace with function body.

func draw_hallway():
	if hallway_type == hallway_types.HORIZONTAL:
		place_tiles_from_two_points(top_left_corner,top_right_corner)
		place_tiles_from_two_points(bot_left_corner,bot_right_corner)
		exit_point = (top_left_corner+bot_left_corner)/2
		entry_point = (top_right_corner+bot_right_corner)/2
	else:
		place_tiles_from_two_points(top_left_corner,bot_left_corner)
		place_tiles_from_two_points(top_right_corner,bot_right_corner)
		entry_point = (top_left_corner+top_right_corner)/2
		exit_point = (bot_left_corner+bot_right_corner)/2
	entry_point = snap_to_tile(entry_point)
	exit_point = snap_to_tile(exit_point)
func check_type_fit():
	if hallway_type == hallway_types.VERTICAL:
		if room_h_size>room_v_size:
			flip_lengths()
	elif hallway_type == hallway_types.HORIZONTAL:
		if room_v_size>room_h_size:
			flip_lengths()
	

func entrance_points():
	var width:int = min(room_h_size,room_v_size)
	var tile_amount = width/tile_size

func add_dungeon_room(room:DUNGEON_ROOM)->DUNGEON_ROOM:
	
	#room.total_dungeon_rooms=total_dungeon_rooms-1
	add_child(room)
	var offset_dir:Vector2 = to_local(exit_point).normalized()
	print("offset_dir: ",offset_dir," exit_point: ",to_local(exit_point))
	var width:int = min(room_h_size,room_v_size)
	var width_in_tiles:float = 1.0*width/tile_size
	var target_position:Vector2i = tile_map.local_to_map(to_local(exit_point))
	var offset:Vector2i
	if hallway_type==hallway_types.HORIZONTAL:
		var tile_count:float = room.room_h_size/tile_size
		print("room.room_h_size: ",room.room_h_size)
		offset.x = ((tile_count/2.0)*sign(offset_dir.x))
		#room.global_position=Vector2i(room.global_position) - snap_to_tile(offset_dir*((room.room_h_size/2)-tile_size/2))
	if hallway_type==hallway_types.VERTICAL:
		#room.global_position=Vector2i(room.global_position) - snap_to_tile(offset_dir*((room.room_v_size/2)-tile_size/2))
		var tile_count:float = room.room_v_size/tile_size
		print("room.room_v_size: ",room.room_v_size)
		offset.y = ((tile_count/2.0)*sign(offset_dir.y))
	print("offset ",offset)
	print("tile_map.local_to_map(to_local(exit_point)) ",tile_map.local_to_map(to_local(exit_point)))
	var final_map_pos:Vector2 = (target_position + (offset))
	var tile_center: = tile_map.map_to_local(final_map_pos)
	var tile_top_left:Vector2 = tile_center - Vector2(tile_size, tile_size) / 2.0
	room.global_position = ceil(to_global((tile_top_left)))
	#room.global_position = tile_map.map_to_local(final_map_pos)
	room.open_entrance(self,(exit_point))
	print("room.room_h_size % tile_size",room.room_h_size % tile_size)
	print("room.room_v_size % tile_size",room.room_v_size % tile_size)
	return room

func flip_lengths():
	var temp:int = room_h_size
	room_h_size = room_v_size
	room_v_size = temp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("Debug Test"):
		#for child in get_children():
			#if child is DUNGEON_ROOM:
				#child.queue_free()
		#add_dungeon_room()

	
	pass
