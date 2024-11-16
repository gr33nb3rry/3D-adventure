extends Node3D

@onready var aim_ray : RayCast3D = $/root/World/Player/CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D/Ray
@onready var camera = $/root/World/Player/CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D
@onready var player = $/root/World/Player
const ACID = preload("res://scenes/acid.tscn")
@onready var acids_container = $/root/World/Acids
const TURREL = preload("res://scenes/turrel.tscn")
@onready var turrels_container = $/root/World/Turrels
@onready var gun_progress = $/root/World/Canvas/VBox/HBox/Gun
@onready var audio: AudioStreamPlayer3D = $Audio
@onready var canvas = $/root/World/Canvas
const BLASTER_SOUND = preload("res://sounds/acid_start.tres")
const BUILDER_SOUND = preload("res://sounds/builder.tres")

const ROTATION_SPEED := 10.0

enum Weapons {
	BLASTER,
	BUILDER
}

var current_weapon : int = Weapons.BLASTER

func _process(delta: float) -> void:
	var pos = player.get_node("GunPos").global_position
	global_position = pos
	global_rotation = lerp(global_rotation, camera.global_rotation, ROTATION_SPEED * delta)

func shoot() -> void:
	if !player.is_active: return
	if !gun_progress.is_full: return
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return
	if aim_ray.is_colliding() and aim_ray.get_collider().name == "Egg": return
	audio.stream = BLASTER_SOUND
	audio.play()
	var a = ACID.instantiate()
	acids_container.add_child(a)
	a.global_position = global_position
	if aim_ray.is_colliding() and aim_ray.get_collider() is Area3D and aim_ray.get_collider().get_parent().is_in_group("Cum"):
		a.target = aim_ray.get_collider().get_parent()
		if !Stats.gun_is_following:
			a.direction = (aim_ray.get_collider().global_position - global_position).normalized()
		else: aim_ray.get_collider().get_parent().follow()
		a.is_following = Stats.gun_is_following
	else:
		a.direction = (camera.global_position + -camera.global_transform.basis.z * 500.0 - global_position).normalized()
	gun_progress.shoot()
	
func build() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return
	if !aim_ray.is_colliding(): return
	if aim_ray.get_collider().name != "Egg": return
	if Stats.turrel_count < 1: return
	Stats.turrel_count -= 1
	audio.stream = BUILDER_SOUND
	audio.play()
	canvas.update_turrel()
	var t = TURREL.instantiate()
	turrels_container.add_child(t)
	t.global_position = aim_ray.get_collision_point()
	t.rotate_to_ground()

func change_weapon() -> void:
	current_weapon += 1
	if current_weapon >= Weapons.size(): current_weapon = 0
	$Blaster.visible = current_weapon == Weapons.BLASTER
	$Builder.visible = current_weapon == Weapons.BUILDER
	$/root/World/Canvas.update_weapon()
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("change_weapon"):
		change_weapon()
	if Input.is_action_just_pressed("gun"):
		if current_weapon == Weapons.BLASTER: shoot()
		elif current_weapon == Weapons.BUILDER: build()
