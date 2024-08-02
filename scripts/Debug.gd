extends Label

func _process(_delta):
	text = str(Engine.get_frames_per_second())
	text += '\n'
	text += str($/root/World/Player.velocity.y)
	text += '\n'
	text += str($/root/World/Player.is_on_floor())
	text += '\n'
	text += str($/root/World/Player.jump_status)
	text += '\n'
	text += str($/root/World/Player.last_y_velocity)
	text += '\n'
	text += str($/root/World/Player.ray_distance)
