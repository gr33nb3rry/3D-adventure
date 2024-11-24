extends Node

var cum_count : int = 10
var turrel_count : int = 5

var highscore : int = 0
var game_speed : float = 1.0
var wave_duration : int = 60
var optimized_cum : bool = false
var star_count : int = 0
var cum_limit : int = 5000

var gun_is_following : bool = false
var turrel_is_following : bool = false
var acid_ricochet_count : int = 0
var gun_cooldown : float = 1.0
var acid_speed : float = 30.0
var player_size : float = 1.0
var turrel_cooldown : float = 5.0
var egg_hp : int = 1
var cum_bonus : int = 0

func default() -> void:
	cum_count = 10
	turrel_count = 0
	acid_ricochet_count = 0
	gun_cooldown = 1.0
	acid_speed = 30.0
	player_size = 1.0
	turrel_cooldown = 5.0

func get_acid_texture() -> Texture:
	match $/root/World/Canvas.current_skin:
		"Orange": return load("res://images/acid.png")
		"Cyan": return load("res://images/acid2.png")
		"Envy": return load("res://images/acid3.png")
		"Sweety": return load("res://images/acid4.png")
		"Smelly": return load("res://images/acid5.png")
		"Bloody": return load("res://images/acid6.png")
		"Luxury": return load("res://images/acid7.png")
		"The Blackest": return load("res://images/acid8.png")
	return load("res://images/acid.png")
		
