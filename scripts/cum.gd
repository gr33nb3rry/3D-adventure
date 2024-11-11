extends Node3D

@onready var egg = $/root/World/Egg
const SPEED := 10.0

var direction : Vector3
var is_followed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	direction = (egg.global_position - global_position).normalized()
	$Mesh.look_at(egg.global_position, Vector3.UP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += direction * SPEED * delta

func oh_fuck_yeah_baby() -> void:
	process_mode = PROCESS_MODE_DISABLED
	#queue_free()

func _on_area_body_entered(body: Node3D) -> void:
	if body.name == "Egg": oh_fuck_yeah_baby()
