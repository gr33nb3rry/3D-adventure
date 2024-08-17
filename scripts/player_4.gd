extends CharacterBody3D

@onready var model : Node3D = $Model
@onready var animation_tree : AnimationTree = $Model/sophia/AnimationTree

var jump_buffer := 0.0

func _physics_process(delta: float) -> void:
	var planet = $/root/World2/Planet
	
	var d = global_position - planet.global_position
	var gravity_force = (-d.normalized()).normalized()
	jump_buffer = clamp((jump_buffer - delta * 10.0), 0.0, 50.0)
	velocity = gravity_force * 10.0 + global_transform.basis.y * jump_buffer
	
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
		animation_tree["parameters/conditions/run"] = true
		model.look_at(global_position + movement, up)
		velocity += movement.normalized() * 10.0
	else: animation_tree["parameters/conditions/idle"] = true
	if Input.is_action_just_pressed("jump"): jump_buffer = 20.0
	move_and_slide()

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
