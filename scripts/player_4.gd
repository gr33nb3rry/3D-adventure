extends CharacterBody3D

@onready var model : Node3D = $Model
@onready var animation_tree : AnimationTree = $Model/Sophia/AnimationTree

@onready var planet = $/root/World2/Planet

var jump_buffer := 0.0
const ROTATION_SPEED := 10.0
const JUMP_VELOCITY := 20.0

func _physics_process(delta: float) -> void:
	%Debug.text = str(Engine.get_frames_per_second())
	
	var d = global_position - planet.global_position
	var gravity_force = (-d.normalized()).normalized()
	jump_buffer = clamp((jump_buffer - delta * 10.0), 0.0, 50.0)
	velocity = gravity_force * 10.0 + global_transform.basis.y * jump_buffer
	
	if jump_buffer <= 10.0:
		animation_tree["parameters/conditions/fall"] = true
	
	var up_direction = -gravity_force.normalized()
	var orientation_direction = Quaternion(global_transform.basis.y, up_direction) * global_transform.basis.get_rotation_quaternion()
	var rotation = global_transform.basis.get_rotation_quaternion().slerp(orientation_direction.normalized(), 5.0 * delta)
	global_rotation = rotation.get_euler()
	
	
	var movement := Vector3.ZERO
	var forward : Vector3 = -$CamRoot/CamYaw.global_transform.basis.z
	var right : Vector3 = $CamRoot/CamYaw.global_transform.basis.x
	var up : Vector3 = global_transform.basis.y
	var direction = Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	forward *= direction.y
	right *= direction.x
	movement += forward + right
	if movement != Vector3.ZERO:
		if jump_buffer == 0.0: animation_tree["parameters/conditions/run"] = true
		$Look/Point.position = Vector3(direction.x, 0, -direction.y)
		$Model/Sophia.rotation.y = lerp_angle($Model/Sophia.rotation.y, $CamRoot/CamYaw.rotation.y + deg_to_rad(180), ROTATION_SPEED * delta)
		var model_transform = model.transform.interpolate_with(model.transform.looking_at($Look/Point.position), ROTATION_SPEED * delta)
		model.transform = model_transform

		velocity += movement.normalized() * 5.0
	elif jump_buffer == 0.0: animation_tree["parameters/conditions/idle"] = true
	
	move_and_slide()

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	elif Input.is_action_just_pressed("jump") and jump_buffer == 0.0: 
		jump_buffer = JUMP_VELOCITY
		animation_tree["parameters/conditions/jump"] = true
