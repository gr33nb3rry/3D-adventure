extends RigidBody3D

@export var camera_pivot : Node3D
@export var groundCast : RayCast3D

var closest_force : Vector3
var surface_position : Vector3
var is_stuck_to_surface : bool

var mouse_sensitivity := 0.3
var mouse_delta : Vector2
var camera_x_rotation : float

@export var auto_orient_speed := 0.5
@export var jump_impulse := 50.0

var speed := 100.0
var g_scale := 50.0
var velocity_limit := 5.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _physics_process(delta: float) -> void:
	closest_force = Vector3.ZERO
	#linear_velocity = Vector3.ZERO
	#linear_velocity = Vector3(
	#	clamp(linear_velocity.x, -velocity_limit, velocity_limit), 
	#	clamp(linear_velocity.y, -velocity_limit, velocity_limit), 
	#	clamp(linear_velocity.z, -velocity_limit, velocity_limit))
	$/root/World2/Canvas/Debug.text = str(linear_velocity)
	var planet = $/root/World2/Planet
	
	var d = global_position - planet.global_position
	var force = (-d.normalized() * (20.0*30.0*30.0) / d.length_squared()).normalized();
	apply_central_force(force * g_scale)
	
	
	#process_movement_inputs(delta)
	#process_auto_orientation(delta)
	mouse_delta = Vector2.ZERO

func process_movement_inputs(delta:float) -> void:
	var movement := Vector3.ZERO
	var forward := -global_transform.basis.z
	var left = -global_transform.basis.x
	var up = global_transform.basis.y
	if Input.is_action_pressed("move_forward"): movement += forward
	if Input.is_action_pressed("move_back"): movement -= forward
	if Input.is_action_pressed("move_left"): movement += left
	if Input.is_action_pressed("move_right"): movement -= left
	print(get_ground().GetRelativeVelocityToSurface(global_position, linear_velocity).length())
	var should_stick_to_surface : bool = movement == Vector3.ZERO && get_ground() != null && get_ground().GetRelativeVelocityToSurface(global_position, linear_velocity).length() < 0.2
	should_stick_to_surface = false
	if should_stick_to_surface:
		if is_stuck_to_surface:
			global_position = get_ground().to_global(surface_position)
		else:
			surface_position = get_ground().to_local(global_position)
			is_stuck_to_surface = true
	else:
		is_stuck_to_surface = false
	
	if movement != Vector3.ZERO:
		apply_central_force(movement.normalized() * speed)
	if groundCast.is_colliding() and Input.is_action_just_released("jump"):
		apply_central_impulse(jump_impulse * up)
	
func process_auto_orientation(delta: float) -> void:
	angular_velocity = Vector3.ZERO
	angular_damp = 10.0
	var in_zero_g = closest_force == Vector3.ZERO
	if in_zero_g:
		var dx = lerp(0.0, -camera_x_rotation, auto_orient_speed * delta)
		camera_x_rotation += dx
		camera_pivot.rotate_x(deg_to_rad(-dx))
		rotate(camera_pivot.global_transform.basis.x, deg_to_rad(dx))
	else:
		var up_direction = -closest_force.normalized()
		var orientation_direction = Quaternion(global_transform.basis.y, up_direction) * global_transform.basis.get_rotation_quaternion()
		if groundCast.is_colliding():
			angular_velocity = get_ground().constant_angular_velocity.project(up_direction)
			angular_damp = 0.0
			global_rotation = orientation_direction.normalized().get_euler()
		else:
			var rotation = global_transform.basis.get_rotation_quaternion().slerp(orientation_direction.normalized(), auto_orient_speed * delta)
			global_rotation = rotation.get_euler()
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta += event.relative
	
	
func get_ground() -> StaticBody3D:
	return $/root/World2/Planet
	var hit = groundCast.get_collider()
	if hit is StaticBody3D: return hit
	else: return null
