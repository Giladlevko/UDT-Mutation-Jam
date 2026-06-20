extends Resource
class_name MutationData
@export var name: String = "Mutation"
@export var health_mult:float = 1.0
@export var fire_damage_mult: float = 1.0
@export var freeze_time_mult: float = 1.0
@export var attack_power_mult: float = 1.0
@export var speed_mult: float = 1.0
@export var protection_bonus: int = 0
@export var enemies_health_vis:bool
@export_range(1,4) var projectile_mult:int = 1
@export var projectile_cool_mult:float = 1.0
@export_range(0.1,1.0,0.1) var projectile_chance_to_split = 0.1
@export var rgb_color_for_text:Color
var txt_color:String = "#"+rgb_color_for_text.to_html(false)
