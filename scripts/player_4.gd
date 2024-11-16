extends CharacterBody3D

@onready var model : Node3D = $Model
@onready var model_main: Node3D = $Model/Main
@onready var cam_yaw: Node3D = $CamRoot/CamYaw


@onready var egg = $/root/World/Egg

const SPEED := 15.0
const ROTATION_SPEED := 10.0
var is_running := false
var is_active := true

func _physics_process(delta: float) -> void:
	if !is_active: return
	var d = global_position - egg.global_position
	var gravity_force = (-d.normalized()).normalized()
	velocity = gravity_force * 10.0
	
	var up_direction = -gravity_force.normalized()
	var orientation_direction = Quaternion(global_transform.basis.y, up_direction) * global_transform.basis.get_rotation_quaternion()
	var rotation = global_transform.basis.get_rotation_quaternion().slerp(orientation_direction.normalized(), 5.0 * delta)
	global_rotation = rotation.get_euler()
	
	var movement := Vector3.ZERO
	var forward : Vector3 = -cam_yaw.global_transform.basis.z
	var right : Vector3 = cam_yaw.global_transform.basis.x
	var up : Vector3 = global_transform.basis.y
	var direction = Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	forward *= direction.y
	right *= direction.x
	movement += forward + right
	if movement != Vector3.ZERO:
		$Look/Point.position = Vector3(direction.x, 0, -direction.y)
		model_main.rotation.y = lerp_angle(model_main.rotation.y, cam_yaw.rotation.y + deg_to_rad(180), ROTATION_SPEED * delta)
		var model_transform = model.transform.interpolate_with(model.transform.looking_at($Look/Point.position), ROTATION_SPEED * delta)
		model.transform = model_transform
		velocity += movement.normalized() * SPEED * Stats.player_size
	is_running = movement != Vector3.ZERO
	move_and_slide()


func _on_area_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("Cum"): 
		area.get_parent().death()
		Stats.cum_count += 1
		$/root/World/Canvas.update_cums()
