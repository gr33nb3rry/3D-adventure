extends Node3D

var direction : Vector3
var target : Node3D
var is_following := false
var ricochet_count := 0
var speed := 1.0

const TIME_TO_DEATH := 7.0
const TIME_TO_DEATH_FOLLOW := 30.0

func _ready() -> void:
	ricochet_count = Stats.acid_ricochet_count
	apply_optimization()
	await get_tree().create_timer(1.0).timeout
	await get_tree().create_timer(TIME_TO_DEATH if !is_following else TIME_TO_DEATH_FOLLOW).timeout
	death()

func apply_optimization() -> void:
	$Mesh.visible = !Stats.optimized_cum
	$Sprite.visible = Stats.optimized_cum
	if Stats.optimized_cum:
		$Sprite.texture = Stats.get_acid_texture()

func _process(delta: float) -> void:
	if is_following:
		if target != null:
			if global_position.distance_squared_to(target.global_position) < 1.23: kill_cum(target)
			global_position += (target.global_position - global_position).normalized() * Stats.acid_speed * speed * delta
		else:
			death()
	else:
		global_position += direction * Stats.acid_speed * speed * delta

func kill_cum(cum:Node3D) -> void:
	cum.death()
	Stats.cum_count += (1 + Stats.cum_bonus) * (1 if Stats.wave_duration == 60.0 else 3)
	$/root/World/Canvas.update_cums()
	if ricochet_count <= 0:
		death()
	else:
		var nearest_cum = get_nearest_cum()
		if nearest_cum == null: 
			death()
			return
		if !is_following:
			direction = (nearest_cum.global_position - global_position).normalized()
		else:
			nearest_cum.follow()
		target = nearest_cum
		ricochet_count -= 1
		speed = 0.5

func death() -> void:
	queue_free()

func _on_area_area_entered(area: Area3D) -> void:
	if !is_following and area.get_parent().is_in_group("Cum"): 
		kill_cum(area.get_parent())
	elif is_following and area.get_parent().is_in_group("Cum") and area.get_parent() == target:
		kill_cum(area.get_parent())

func get_nearest_cum() -> Node3D:
	var nearest : Node3D
	var last_distance := 10000000.0
	for cum in get_tree().get_nodes_in_group("Cum"):
			if !cum.is_followed and cum.is_active and global_position.distance_squared_to(cum.global_position) < last_distance:
				last_distance = global_position.distance_squared_to(cum.global_position)
				nearest = cum
	return nearest
