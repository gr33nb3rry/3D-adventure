extends Node3D

var is_opened := false

func open() -> void:
	var t = get_tree().create_tween().set_parallel(true)
	t.tween_property($Mesh, "position:y", 0, 0.5)
	t.tween_property($Mesh, "rotation_degrees:y", 0, 0.5)
	$Audio.play()
	
func close() -> void:
	var t = get_tree().create_tween().set_parallel(true)
	t.tween_property($Mesh, "position:y", -1.7, 0.5)
	t.tween_property($Mesh, "rotation_degrees:y", 180, 0.5)
	
func _on_area_body_entered(body: Node3D) -> void:
	if $/root/World.wave_timer <= 0 and body.name == "Player":
		$/root/World/Canvas.open_market()
