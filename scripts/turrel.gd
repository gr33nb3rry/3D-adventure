extends Node3D

@onready var egg = $/root/World/Egg
@onready var acid = preload("res://scenes/acid.tscn")
@onready var acids_container = $/root/World/Acids
@onready var audio: AudioStreamPlayer3D = $Audio

func _ready() -> void:
	rotate_to_ground()

func rotate_to_ground() -> void:
	look_at(Vector3.ZERO, Vector3.UP)
	if global_position.x != 0 or global_position.z != 0: rotation_degrees.x += 90
	var direction = $GroundPivot.global_position.normalized()
	global_position = direction * (egg.get_node("Mesh").mesh.radius - $GroundPivot.position.y)
	
func shoot() -> void:
	if get_tree().get_node_count_in_group("Cum") == 0: return
	var a = acid.instantiate()
	acids_container.add_child(a)
	a.global_position = $Mesh/AcidMesh.global_position
	var nearest_cum = get_nearest_cum()
	if nearest_cum == null: return
	audio.play()
	if !Stats.turrel_is_following:
		a.direction = (nearest_cum.global_position - a.global_position).normalized()
	else:
		nearest_cum.follow()
	a.target = nearest_cum
	a.is_following = Stats.turrel_is_following
	
func get_nearest_cum() -> Node3D:
	var nearest : Node3D
	var last_distance := 500000.0
	for cum in get_tree().get_nodes_in_group("Cum"):
			if !cum.is_followed and global_position.distance_squared_to(cum.global_position) < last_distance:
				last_distance = global_position.distance_squared_to(cum.global_position)
				nearest = cum
	return nearest

func death() -> void:
	queue_free()
