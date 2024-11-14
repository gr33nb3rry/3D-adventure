extends Node3D

@onready var egg = $/root/World/Egg
var speed := 10.0

var direction : Vector3
var is_followed := false
var is_active := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	direction = (egg.global_position - global_position).normalized()
	$Mesh.look_at(egg.global_position, Vector3.UP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += direction * speed * delta

func follow() -> void:
	is_followed = true

func oh_fuck_yeah_baby() -> void:
	speed /= 4.0
	await get_tree().create_timer(1.0).timeout
	$/root/World.pregnant(self)

func death() -> void:
	speed /= 4.0
	#var t = get_tree().create_tween().set_parallel(true)
	#t.tween_property($Mesh, "transparency", 1.0, 1.0)
	#t.tween_property($Mesh/Tail, "transparency", 1.0, 1.0)
	#await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_area_body_entered(body: Node3D) -> void:
	if body.name == "Egg": oh_fuck_yeah_baby()
