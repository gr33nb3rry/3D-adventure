extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 1

func _physics_process2(delta: float) -> void:
	velocity = global_position.direction_to(Vector3.ZERO) * delta * 50.0
	
	move_and_slide()

func _physics_process(delta: float) -> void:
	var normal = $RayCastDown.get_collision_normal()
	velocity = global_position.direction_to(Vector3.ZERO) * delta * 50.0
		
	var xform = align_with_y(global_transform, normal)
	global_transform = global_transform.interpolate_with(xform, 0.1)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	$/root/World2/Canvas/Debug.text = str(direction)
	if direction and is_on_floor():
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

	move_and_slide()


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
