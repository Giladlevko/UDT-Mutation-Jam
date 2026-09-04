extends Node2D
class_name LEVEL_MANAGER
@onready var enemies_spawn_cool: Timer = $timers/enemies_spawn_cool

@onready var enemies: Node = $enemies

@onready var ammo_packs: Node = $ammo_packs

@onready var dungeon_generator: DUNGEON_GENERATOR = $dungeon_gen

@onready var player: PLAYER = $player

const ENEMY_SCENE = preload("res://Scenes/enemy.tscn")
const DUNGEON_GEN = preload("res://Scenes/dungeon_gen.tscn")
const AMMO_PACKET = preload("res://Scenes/ammo_pack.tscn")
var waiting_for_enemies_to_die:bool = false
var max_enemies_to_spawn:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.reset_level.connect(on_level_reset)
	SignalBus.game_timer_finished.connect(on_game_timer_end)
	SignalBus.low_ammo.connect(on_player_low_ammo)
	enemies_spawn_cool.wait_time = clamp(18-2*Global.phase_index,2,18)
	update_round_vars()
	enemy_spawn()
	pass # Replace with function body.

func update_round_vars():
	max_enemies_to_spawn = clamp(Global.phase_index*2,1,6)
	#25 bullets for each enemy
	Global.player_max_ammo = (max_enemies_to_spawn) * 25

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func rand_room()->Global.room_corners:
	var dungeon_rooms:Array[Global.room_corners] = Global.rooms.duplicate()
	dungeon_rooms.shuffle()
	var room:Global.room_corners = dungeon_rooms.pop_back()
	
	while(room.has_point(player.global_position) and dungeon_rooms.size()>0):
		room = dungeon_rooms.pop_back()
	if dungeon_rooms.size() == 1: push_warning("No Safe Rooms Unsafe Room Chosen")
	return room

func rand_pos(room_corners:Global.room_corners)->Vector2i:
	
	var mid_point:Vector2i = (room_corners.bot_left + room_corners.top_right)/2
	print("Spawn Point is ",mid_point)
	
	return mid_point


func on_player_low_ammo():
	SignalBus.display_message.emit("Find more bullets!")
	if (ammo_packs.get_child_count() == 0):
		add_ammo_pack()

func add_ammo_pack():
	var room:Global.room_corners = rand_room()
	var ammo_global_pos = rand_pos(room)
	var ammo_pack:AMMO_PACK = AMMO_PACKET.instantiate()
	ammo_packs.add_child(ammo_pack)
	ammo_pack.owner = self
	ammo_pack.global_position = ammo_global_pos

func add_enemy():
	var room:Global.room_corners = rand_room()
	var enemy_global_pos = rand_pos(room)
	var enemy:ENEMY = ENEMY_SCENE.instantiate()
	enemies.add_child(enemy)
	enemy.owner = self
	for mut:MutationData in Global.enemies_mutation:
		enemy.add_mutation(mut)
	enemy.global_position = enemy_global_pos
	
	pass

func enemy_spawn():
	var enemies_count:int = enemies.get_children().size()
	if enemies_count <= max_enemies_to_spawn:
		for i in max_enemies_to_spawn - enemies_count:
			add_enemy()
			
			#Chance to spawn ammo
		var ammo_spawn_chance:int = randi_range(1,100)
		if(ammo_spawn_chance > 85):
			add_ammo_pack()
			
	if !waiting_for_enemies_to_die:
		enemies_spawn_cool.start()
	pass


func _on_enemies_spawn_cool_timeout() -> void:
	enemy_spawn()

	
	pass # Replace with function body.


func on_game_timer_end():
	waiting_for_enemies_to_die = true
	if enemies.get_child_count()==0:
		SignalBus.init_mutation_selection.emit()
	if enemies.get_child_count()>=1:
		enemies_spawn_cool.stop()
		SignalBus.display_message.emit("Eliminate the enemies to get to the next phase!",3)
		
	pass

func on_level_reset():
	waiting_for_enemies_to_die = false
	Global.phase_index+=1
	
	Global.rooms.clear()
	dungeon_generator.queue_free()
	player.global_position = Vector2.ZERO
	for enemy:ENEMY in enemies.get_children():
		enemy.queue_free()
	for ammo:AMMO_PACK in ammo_packs.get_children():
		ammo.queue_free()
	var dungeon_gen = DUNGEON_GEN.instantiate()
	add_child(dungeon_gen)
	dungeon_gen.owner = self
	dungeon_gen.z_index = -1
	dungeon_generator = dungeon_gen
	update_round_vars()
	enemy_spawn()
	
	pass


func _on_enemies_child_exiting_tree(node: Node) -> void:
	#emits right before child is freed so need to check if enemy count is 1
	if waiting_for_enemies_to_die and enemies.get_child_count() <= 1:
		SignalBus.init_mutation_selection.emit()
	pass # Replace with function body.
