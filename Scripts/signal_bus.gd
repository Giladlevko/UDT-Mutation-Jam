extends Node

signal start_dash_cooldown(dur:float)
signal dash_ready
signal display_cards()
signal mutation_selected(mutation:MutationData)
signal init_mutation_selection()
signal display_message(message:String,dur:float)
signal remove_mutation_from_diplay(mutation:MutationData)
signal room_added(corners:Global.room_corners)
signal reset_level()
signal reset_game()
signal game_timer_finished()
