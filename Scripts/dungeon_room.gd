extends Node2D
class_name DUNGEON_ROOM

@export var tile_map: TileMapLayer
@export var polygon: Polygon2D

@export var room_amount:int = 5
@export var max_length_mult:int = 30
@export var min_length_mult:int = 10
@export var nav_reg: NavigationRegion2D

@export var total_dungeon_rooms:int = 2

var tile_size:int

var max_length:int = 1
var min_length:int = 1

var room_v_size:int
var room_h_size:int
var top_left_corner:Vector2
var top_right_corner:Vector2
var bot_left_corner:Vector2
var bot_right_corner:Vector2
var entrence_to_room:Vector2i = Vector2i(-1000,-1000)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_size = tile_map.tile_set.tile_size.x
	init_room_size()
	init_room()
	#if total_dungeon_rooms>0:
		#await get_tree().process_frame
		#add_dungeon_hallway()
	pass # Replace with function body.

func init_room_size():
	max_length = max_length_mult*tile_size
	min_length = min_length_mult*tile_size
	room_v_size = randi_range(min_length,max_length)
	room_h_size = randi_range(min_length,max_length)
	room_h_size = snapped(room_h_size,tile_size)
	room_v_size = snapped(room_v_size,tile_size)

func init_room(draw_tiles:bool = true):
	top_left_corner = Vector2i(-room_h_size/tile_size/2,-room_v_size/tile_size/2)*tile_size
	top_right_corner = Vector2i(room_h_size/tile_size/2,-room_v_size/tile_size/2)*tile_size
	
	bot_left_corner = Vector2i(-room_h_size/tile_size/2,room_v_size/tile_size/2)*tile_size
	bot_right_corner = Vector2i(room_h_size/tile_size/2,room_v_size/tile_size/2)*tile_size
	
	#top_left_corner = snap_to_tile(top_left_corner)
	#top_right_corner = snap_to_tile(top_right_corner)
	#bot_left_corner = snap_to_tile(bot_left_corner)
	#bot_right_corner = snap_to_tile(bot_right_corner)
	
	var points:PackedVector2Array = [top_left_corner,top_right_corner,bot_right_corner,bot_left_corner]
	#for i in points.size():
		#points[i] = Vector2(snap_to_tile(points[i]))
	polygon.polygon = points
	var new_nav_mesh = NavigationPolygon.new()
	new_nav_mesh.add_outline(points)
	nav_reg.navigation_polygon = new_nav_mesh
	nav_reg.bake_navigation_polygon()
	if draw_tiles:
		draw_room()

func draw_room():
	place_tiles_from_two_points(top_left_corner,top_right_corner)
	place_tiles_from_two_points(top_left_corner,bot_left_corner)
	place_tiles_from_two_points(bot_left_corner,bot_right_corner)
	place_tiles_from_two_points(top_right_corner,bot_right_corner)
	

func snap_to_tile(point:Vector2i)->Vector2i:
	point.x = snappedi(point.x,tile_size)
	point.y = snappedi(point.y,tile_size)
	return point

func place_tiles_from_two_points(a:Vector2i,b:Vector2i,remove_tile:bool = false):
	var tile_id = 0
	a = tile_map.local_to_map(a)
	b = tile_map.local_to_map(b)
	var direction:Vector2i
	var offset_dir:Vector2i = Vector2i.ONE
	if a.x == b.x: 
		direction = Vector2i(0,sign(b.y-a.y))
		offset_dir.y = sign(b.y-a.y)
	elif a.y == b.y: 
		direction = Vector2i(sign(b.x-a.x),0)
		offset_dir.x = sign(b.x-a.x)
	else:
		push_error("Trying to place a diagonal line!")
		return
	var current:Vector2i = a
	
	while (current!= b):
		#var coord: = tile_map.local_to_map(current)

		if remove_tile:tile_id=-1
		tile_map.set_cell(current,tile_id,Vector2i(1,1),0)
		current+=direction
	
	tile_map.set_cell(b,tile_id,Vector2i(1,1),0)
	pass

func rand_wall():
	var walls:Array[Array] = [
		[top_right_corner,bot_right_corner],[bot_left_corner,bot_right_corner],
		[top_left_corner,bot_left_corner],[top_left_corner,top_right_corner]
		]
	var walls_copy = walls.filter(filter_walls)
	return walls_copy.pick_random()

func filter_walls(a:Array)->bool:
	var mid_point:Vector2=(a[0]+a[1])/2
	if abs(mid_point.x - entrence_to_room.x)<16 or abs(mid_point.y - entrence_to_room.y)<16:
		return false
	return true
	pass

func rand_new_dun_pos(trans_wall:Array)->Vector2:
	var rand_pos:Vector2
	if trans_wall[0].x == trans_wall[1].x:
		rand_pos.y = randi_range(trans_wall[0].y*0.5,trans_wall[1].y*0.5)
		rand_pos.x = trans_wall[0].x
	elif trans_wall[0].y == trans_wall[1].y:
		rand_pos.x = randi_range(trans_wall[0].x*0.5,trans_wall[1].x*0.5)
		rand_pos.y = trans_wall[0].y

	rand_pos = tile_map.local_to_map(rand_pos)
	return rand_pos

func add_dungeon_hallway(passage:DUNGEON_HALLWAY)->DUNGEON_HALLWAY:
	if total_dungeon_rooms<=0:return
	var rand_wall = rand_wall()
	var rand_hall_pos:Vector2i = rand_new_dun_pos(rand_wall)
	var target_pos:Vector2i
	$Sprite2D.position = tile_map.map_to_local(rand_hall_pos)
	
	
	if rand_wall[0].x == rand_wall[1].x:
		passage.hallway_type = passage.hallway_types.HORIZONTAL
	elif rand_wall[0].y == rand_wall[1].y:
		passage.hallway_type = passage.hallway_types.VERTICAL
	passage.total_dungeon_rooms = total_dungeon_rooms
	add_child(passage)
	
	
	var wall_mid_point:Vector2 = (((rand_wall[0]+rand_wall[1])/2))
	target_pos = (rand_hall_pos)
	var hall_tiles = passage.hallway_length / tile_size
	var room_to_wall: Vector2 = (wall_mid_point).normalized()
	var offset:Vector2i = Vector2i.ZERO
	
	if passage.hallway_type == passage.hallway_types.HORIZONTAL:
		offset.x = sign(room_to_wall.x)*(hall_tiles/2.0)
	else:
		offset.y = sign(room_to_wall.y)*(hall_tiles/2.0)
	
	var final_map_pos: = target_pos + offset
	var tile_center: = tile_map.map_to_local(final_map_pos)
	var tile_top_left: = tile_center - Vector2(tile_size, tile_size) / 2.0
	passage.entry_point = (to_global(tile_map.map_to_local(target_pos)))
	passage.exit_point = passage.entry_point+passage.hallway_length*room_to_wall
	passage.global_position = to_global(tile_top_left)
	open_entrance(passage,passage.entry_point)
	passage.nav_link.start_position = passage.nav_link.to_local(passage.entry_point-2*tile_size*room_to_wall)
	passage.nav_link.end_position = passage.nav_link.to_local(passage.exit_point+2*tile_size*room_to_wall)
	return passage


func open_entrance(passage:DUNGEON_HALLWAY,global_connecting_point:Vector2):
	var connecting_point =to_local((global_connecting_point))
	var tile_con_point = tile_map.local_to_map(connecting_point)
	var width:int = min(passage.room_h_size,passage.room_v_size)
	var width_tiles_num:int = width/tile_size
	
	var entrance_dir:Vector2i
	if passage.hallway_type == passage.hallway_types.VERTICAL:
		entrance_dir = Vector2i(1,0)
	else:entrance_dir = Vector2i(0,1) 
	var edge_1:Vector2i = connecting_point -entrance_dir*width/2.0
	var edge_2:Vector2i = connecting_point + entrance_dir*width/2.0
	for i in range(width_tiles_num):
		var clear_pos = tile_con_point + (entrance_dir * (i-width_tiles_num/2))
		tile_map.set_cell(clear_pos, -1)
		if i == 0:
			entrence_to_room = tile_map.map_to_local(clear_pos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("Debug Test"):
		#for child in get_children():
			#if child is DUNGEON_HALLWAY:child.queue_free()
		#draw_room()
		#add_dungeon_hallway()
	pass
