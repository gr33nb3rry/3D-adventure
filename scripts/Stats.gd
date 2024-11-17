extends Node

var cum_count : int = 0
var turrel_count : int = 5

var highscore : int = 0
var game_speed : float = 1.0
var wave_duration : float = 60.0
var optimized_cum : bool = true

var gun_is_following : bool = true
var turrel_is_following : bool = true
var acid_ricochet_count : int = 0
var gun_cooldown : float = 1.0
var acid_speed : float = 30.0
var player_size : float = 1.0

var turrel_cooldown : float = 6.0

func default() -> void:
	cum_count = 10
	turrel_count = 0
	gun_is_following = false
	turrel_is_following = false
	acid_ricochet_count = 0
	gun_cooldown = 1.0
	acid_speed = 30.0
	player_size = 1.0
	turrel_cooldown = 6.0
