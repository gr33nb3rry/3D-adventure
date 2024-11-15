extends Node3D

func _on_area_body_entered(body: Node3D) -> void:
	if $/root/World.wave_timer <= 0 and body.name == "Player":
		$/root/World/Canvas.open_market()
