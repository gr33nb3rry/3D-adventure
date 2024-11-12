extends Node3D

@onready var camera = $/root/World/Player/CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D
const SPEED := 30.0

var direction : Vector3
var target : Node3D
var is_following := false
var ricochet_count := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#await get_tree().create_timer(5.0).timeout
	#death()

func update_size(size:float) -> void:
	scale = Vector3(size,size,size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_following:
		if target != null:
			global_position += (target.global_position - global_position).normalized() * SPEED * delta
		else:
			death()
	else:
		global_position += direction * SPEED * delta

func kill_cum(cum:Node3D) -> void:
	cum.queue_free()
	if ricochet_count == 0:
		death()
	elif is_following:
		var nearest_cum = get_nearest_cum()
		if nearest_cum == null: 
			death()
			return
		nearest_cum.follow()
		target = nearest_cum
		ricochet_count -= 1

func death() -> void:
	queue_free()

func _on_area_area_entered(area: Area3D) -> void:
	if !is_following and area.get_parent().is_in_group("Cum"): 
		kill_cum(area.get_parent())
	elif is_following and area.get_parent().is_in_group("Cum") and area.get_parent() == target:
		kill_cum(area.get_parent())

func get_nearest_cum() -> Node3D:
	var nearest : Node3D
	var last_distance := 500000.0
	for cum in get_tree().get_nodes_in_group("Cum"):
			if !cum.is_followed and global_position.distance_squared_to(cum.global_position) < last_distance:
				last_distance = global_position.distance_squared_to(cum.global_position)
				nearest = cum
	return nearest
