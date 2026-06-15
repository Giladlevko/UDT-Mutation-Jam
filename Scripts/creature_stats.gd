extends Resource
class_name CreatureStats

@export_group("Fire And Ice")
@export var damage_from_fire: float = 1.0
@export var freeze_time: float = 1.0

@export_group("Combat & Movement")
@export var attack_power: float = 10.0
@export var speed: float = 200.0
@export var health:float = 100
@export var protection_from_damage: int = 0

@export_group("Projectile")
@export var projectile_amount:int = 1
@export var projectile_cooldown:float = 0.2
@export_range(0.1,1.0,0.1) var projectile_chance_to_split = 0.1
