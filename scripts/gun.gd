extends Node3D

@onready var aim_ray : RayCast3D = $/root/World/Player/CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D/Ray
@onready var camera = $/root/World/Player/CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D
@onready var acid = preload("res://scenes/acid.tscn")
@onready var acids_container = $/root/World/Acids
@onready var turrel = preload("res://scenes/turrel.tscn")
@onready var turrels_container = $/root/World/Turrels

var is_following : bool = false

func shoot() -> void:
	var a = acid.instantiate()
	acids_container.add_child(a)
	a.global_position = global_position
	if aim_ray.is_colliding() and aim_ray.get_collider() is Area3D and aim_ray.get_collider().get_parent().is_in_group("Cum"):
		a.target = aim_ray.get_collider()
		if !is_following:
			a.direction = (aim_ray.get_collider().global_position - global_position).normalized()
		else:
			a.follow()
		a.is_following = is_following
	else:
		a.direction = (-camera.global_transform.basis.z * 500.0 - global_position).normalized()

func build() -> void:
	if !aim_ray.is_colliding(): return
	var t = turrel.instantiate()
	turrels_container.add_child(t)
	t.global_position = aim_ray.get_collision_point()
	t.rotate_to_ground()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot()
	elif Input.is_action_just_pressed("build"):
		build()
