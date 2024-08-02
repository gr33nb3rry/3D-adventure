extends Node3D

signal set_cam_rotation(_cam_rotation : float)
@export var player : CharacterBody3D
@onready var yaw_node = $CamYaw
@onready var pitch_node = $CamYaw/CamPitch
@onready var spring_arm = $CamYaw/CamPitch/SpringArm3D
@onready var arm = $"../Model/Node/Skeleton3D/ArmIk"
@onready var camera = $CamYaw/CamPitch/SpringArm3D/Camera3D
var yaw : float = 0
var pitch : float = 0
var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07
var yaw_acceleration : float = 15
var pitch_acceleration : float = 15
var pitch_max : float = 75
var pitch_min : float = -55
var tween : Tween
var position_offset : Vector3 = Vector3(0, 1, 0)
var position_offset_target : Vector3 = Vector3(0, 1, 0)

var is_aiming := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#spring_arm.add_excluded_object(player.get_rid())
	#top_level = true
	arm.start()
	$"../Model/Node/Skeleton3D/HandIK".start()

func _input(event):
	if Input.is_action_just_pressed("aim"):
		is_aiming = true
		aim(true)
	elif Input.is_action_just_released("aim"):
		is_aiming = false
		aim(false)
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity


func _physics_process(delta):
	#position_offset = lerp(position_offset, position_offset_target, 4 * delta)
	#global_position = lerp(global_position, player.global_position + position_offset, 18 * delta)
	
	pitch = clamp(pitch, pitch_min, pitch_max)
	
	#yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	#pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	if is_aiming:
		$"../Model/ArmPivot".rotation_degrees.x = pitch_node.rotation_degrees.x
	#if you don't want to lerp, set them directly
	yaw_node.rotation_degrees.y = yaw
	pitch_node.rotation_degrees.x = pitch
	
func aim(value:bool):
	var camera_tween = get_tree().create_tween()
	camera_tween.set_parallel(true)
	#camera.position.z = -0.25 if value else 2.5
	#$CamYaw/CamPitch/SpringArm3D.spring_length = 0 if value else 3
	#position_offset_target = Vector3(0, 0.666, 0) if value else Vector3(0, 1, 0)
	#camera_tween.tween_property($CamYaw/CamPitch/SpringArm3D, "global_position", $"../FP".global_position if value else Vector3.ZERO, 0.25)
	#camera_tween.tween_property(camera, "h_offset", 0.9 if value else 0, 0.25)
	#camera_tween.tween_property(camera, "fov", 55 if value else 75, 0.25)
	camera_tween.tween_property(arm, "interpolation", 1 if value else 0, 0.25)
	$/root/World/Canvas/CenterContainer/Crosshair.visible = value
