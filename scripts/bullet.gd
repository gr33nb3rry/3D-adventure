extends Node3D

var direction : Vector3
@onready var ray = $Pivot/RayCast3D

func _ready():
	ray.add_exception($/root/World/Player)

func _process(delta):
	global_position += transform.basis * direction * Stats.bullet_speed * delta



func _on_area_3d_body_entered(body):
	var hit = body
	queue_free()
