extends Node3D

@onready var camera = $/root/World/Player/CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D
const SPEED := 30.0

var direction : Vector3
var target : Node3D
var is_following := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#await get_tree().create_timer(5.0).timeout
	#death()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_following:
		if target != null:
			global_position += (target.global_position - global_position).normalized() * SPEED * delta
		else:
			death()
	else:
		global_position += direction * SPEED * delta

func kill_cum(cum:Node3D) -> void:
	cum.queue_free()
	death()

func death() -> void:
	queue_free()

func _on_area_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("Cum"): kill_cum(area.get_parent())
