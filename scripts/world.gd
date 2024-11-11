extends Node3D

@onready var cum : PackedScene = preload("res://scenes/cum.tscn")
@onready var cums_container = $Cums

func i_am_cumming() -> void:
	var distance : float = randf_range(270.0, 500.0)
	var position_pivot = Vector3(randf_range(-1.0,1.0), randf_range(0.0,1.0), randf_range(-1.0,1.0)) * distance
	var so_much_cum = randi_range(3, 100)
	var gap = float(so_much_cum) / 2.0
	for i in so_much_cum:
		var white_sauce = cum.instantiate()
		cums_container.add_child(white_sauce)
		white_sauce.global_position = position_pivot + Vector3(randf_range(-gap,gap), randf_range(-gap,gap), randf_range(-gap,gap))
