extends Node3D

@onready var acid = preload("res://scenes/acid.tscn")
@onready var acids_container = $/root/World/Acids

func _ready() -> void:
	rotate_to_ground()

func rotate_to_ground() -> void:
	look_at(Vector3.ZERO, Vector3.UP)
	if global_position.x != 0 or global_position.z != 0: rotation_degrees.x += 90
	var direction = $GroundPivot.global_position.normalized()
	global_position = direction * (30.0 - $GroundPivot.position.y)
	
func shoot() -> void:
	$/root/World/Canvas/Debug.text = str(get_tree().get_node_count_in_group("Cum"))
	if get_tree().get_node_count_in_group("Cum") == 0: return
	var a = acid.instantiate()
	acids_container.add_child(a)
	a.global_position = $Mesh/AcidMesh.global_position
	var nearest_cum = get_nearest_cum()
	nearest_cum.is_followed = true
	a.target = nearest_cum
	a.is_following = true
	
func get_nearest_cum() -> Node3D:
	var is_first := true
	var nearest : Node3D
	for cum in get_tree().get_nodes_in_group("Cum"):
		if is_first:
			is_first = false
			nearest = cum
		else:
			if !cum.is_followed and global_position.distance_squared_to(cum.global_position) < global_position.distance_squared_to(nearest.global_position):
				nearest = cum
	return nearest
