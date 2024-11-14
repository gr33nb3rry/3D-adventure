extends Node3D

@onready var cum : PackedScene = preload("res://scenes/cum.tscn")
@onready var cums_container = $Cums

@onready var cum_material : ShaderMaterial = preload("res://materials/cum_material.tres")

func i_am_cumming() -> void:
	var distance : float = randf_range(270.0, 500.0)
	var position_pivot = Vector3(randf_range(-1.0,1.0), randf_range(0.0,1.0), randf_range(-1.0,1.0)) * distance
	var so_much_cum = randi_range(3, 100)
	var gap = float(so_much_cum) / 2.0
	for i in so_much_cum:
		var white_sauce = cum.instantiate()
		cums_container.add_child(white_sauce)
		white_sauce.global_position = position_pivot + Vector3(randf_range(-gap,gap), randf_range(-gap,gap), randf_range(-gap,gap))

func pregnant(cum:Node3D) -> void:
	$CumTimer.stop()
	for c in get_tree().get_nodes_in_group("Cum"):
		c.death()
	#$Egg/Mesh.material_override = cum_material
	var t = get_tree().create_tween().set_parallel(true)
	t.tween_property($Egg/Mesh.mesh.material, "shader_parameter/_specular_smoothness", 0.0, 1.0)
	t.tween_property($Egg/Mesh.mesh.material, "shader_parameter/_specular_strength", 0.075, 1.0)
	t.tween_property($Egg/Mesh.mesh.material, "shader_parameter/_glossiness", 0.1, 1.0)
	t.tween_property($Egg/Mesh.mesh.material, "shader_parameter/_rim_size", 0.5, 1.0)
	t.tween_property($Egg/Mesh.mesh.material, "shader_parameter/color", Color.WHITE, 1.0)
