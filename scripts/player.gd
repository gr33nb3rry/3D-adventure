extends CharacterBody3D

@onready var animation_tree = $Model/AnimationTree

const SPEED := 5.0
const JUMP_VELOCITY := 7.0
var sensitivity := 0.2

var moving_speed := 0
var is_running := false
var is_crouching := false
var is_falling := false
var is_able_to_move := true
var is_able_to_jump := true
var player_init_rotation : float
var rotation_speed := 8

var jump_status := 0 # 0 - IDLE  1 - JUMP  2 - FALLING  3 - IDLE HEAVY
var last_y_velocity := 0.0
var ray_distance : float

var moving_path := "parameters/Moving/blend_position"
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var cam_root = $CamRoot
@onready var camera = $CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	elif Input.is_action_just_pressed("run"):
		is_running = true
	elif Input.is_action_just_released("run"):
		is_running = false
	elif Input.is_action_just_pressed("crouch") and is_on_floor():
		is_crouching = !is_crouching
		animation_tree["parameters/playback"].travel("Crouching" if is_crouching else "Moving")
		moving_path = "parameters/"+("Crouching" if is_crouching else "Moving")+"/blend_position"
		
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player_init_rotation = rotation.y
	
func _physics_process(delta):
	SimpleGrass.set_player_position(global_position)
	if !is_on_floor():
		velocity.y -= gravity * delta
		last_y_velocity = velocity.y
	elif is_on_floor() and jump_status == 2:
		landing()
	if !is_on_floor():
		falling()
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and is_able_to_jump:
		jump()
	if !is_able_to_move: return
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = ($CamRoot/CamYaw.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction *= -1

	if cam_root.is_aiming:
		$Model.rotation.y = lerp_angle($Model.rotation.y, cam_root.get_node("CamYaw").rotation.y, rotation_speed * delta)
		
	elif direction != Vector3.ZERO:
		var target_rotation = atan2(direction.x, direction.z) - player_init_rotation
		$Model.rotation.y = lerp_angle($Model.rotation.y, target_rotation, rotation_speed * delta)
		
		
	ray_distance = $RayCastDown.global_transform.origin.distance_to($RayCastDown.get_collision_point())
	change_velocity(direction, delta)
	move_and_slide()

func change_velocity(direction, delta):
	var blend_speed = delta * 2.0
	if direction and is_running:
		velocity.x = direction.x * SPEED * 2
		velocity.z = direction.z * SPEED * 2
		var current_blend = animation_tree[moving_path]
		animation_tree[moving_path] = clamp(current_blend+blend_speed, 0, 1)
	elif direction and not is_running:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		var current_blend = animation_tree[moving_path]
		if current_blend > 0.5:
			animation_tree[moving_path] = clamp(current_blend-blend_speed, 0, 1)
		else:
			animation_tree[moving_path] = clamp(current_blend+blend_speed, 0, 0.5)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		var current_blend = animation_tree[moving_path]
		animation_tree[moving_path] = clamp(current_blend-blend_speed, 0, 1)

func jump():
	jump_status = 1
	is_able_to_move = false
	is_able_to_jump = false
	await get_tree().create_timer(0.5).timeout
	is_able_to_move = true
	velocity.y = JUMP_VELOCITY
	await get_tree().create_timer(0.1).timeout
	jump_status = 2
func falling():
	if ray_distance >= 3.0:
	#if velocity.y <= -5.0:
		is_able_to_jump = false
		jump_status = 2
func landing():
	jump_status = 0 if last_y_velocity > -10.0 else 3
	is_able_to_move = false
	is_able_to_jump = false
	await get_tree().create_timer(0.0 if last_y_velocity > -10.0 else 0.6).timeout
	is_able_to_move = true
	is_able_to_jump = true
