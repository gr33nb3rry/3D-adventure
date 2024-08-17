extends Node3D

const BULLET = preload("res://scenes/bullet.tscn")

func shoot(target):
	$AnimationPlayer.stop()
	$AnimationPlayer.play("shoot")
	var bullet = BULLET.instantiate()
	$/root/World.add_child(bullet)
	bullet.global_position = $BulletPos.global_position
	bullet.transform.basis = global_transform.basis
	#bullet.get_node("Pivot").scale = Vector3(Stats.bullet_size, Stats.bullet_size, Stats.bullet_size)
	if target != null:
		#bullet.direction = (target - bullet.global_position).normalized()
		bullet.direction = Vector3(0,0,1)
	else:
		bullet.direction = Vector3(0,0,1)
