extends Node3D

signal set_cam_rotation(_cam_rotation : float)
@export var player : CharacterBody3D
@onready var yaw_node = $CamYaw
@onready var pitch_node = $CamYaw/CamPitch
@onready var spring_arm = $CamYaw/CamPitch/SpringArm3D
@onready var camera = $CamYaw/CamPitch/SpringArm3D/Camera3D

var yaw : float = 0
var pitch : float = 0
var yaw_sensitivity : float = 0.09
var pitch_sensitivity : float = 0.07
var yaw_acceleration : float = 15
var pitch_acceleration : float = 15
var pitch_max : float = 75
var pitch_min : float = -55
var position_offset : Vector3 = Vector3(0, 1, 0)
var position_offset_target : Vector3 = Vector3(0, 1, 0)

var sensitivity := 1.0
var is_smooth := false
var is_aiming := false

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spring_arm.add_excluded_object(player.get_rid())
	$CamYaw/CamPitch/SpringArm3D/Camera3D/Ray.add_exception(player)
	$CamYaw/CamPitch/SpringArm3D/Camera3D/Ray.add_exception_rid($"../Model/Main/Gun")
	#top_level = true
	
func get_sensitivity() -> float:
	if sensitivity > 1.0: return sensitivity * 2.0
	return sensitivity * 1.0
	
func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity * get_sensitivity()
		pitch += -event.relative.y * pitch_sensitivity * get_sensitivity()

func _process(delta: float) -> void:
	var view = Input.get_vector("view_left", "view_right", "view_down", "view_up")
	yaw += -view.x * yaw_sensitivity * yaw_acceleration * 30.0 * get_sensitivity() * delta
	pitch += view.y * pitch_sensitivity * pitch_acceleration * 30.0 * get_sensitivity() * delta

func _physics_process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: 
		pitch = clamp(pitch, pitch_min, pitch_max)
		if is_smooth:
			yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
			pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
		else:
			yaw_node.rotation_degrees.y = yaw
			pitch_node.rotation_degrees.x = pitch
	
