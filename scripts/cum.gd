extends Node3D

@onready var egg = $/root/World/Egg
var speed := 10.0

var direction : Vector3
var is_followed := false
var is_active := true
var bonus_speed := 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_optimization()
	speed = 10.0 + float($/root/World.wave - 1) * 0.2
	await get_tree().create_timer(0.1).timeout
	direction = (egg.global_position - global_position).normalized()
	look_at(egg.global_position, Vector3.UP)

func apply_optimization() -> void:
	$Mesh.visible = !Stats.optimized_cum
	$Sprite.visible = Stats.optimized_cum

func _process(delta: float) -> void:
	global_position += direction * speed * bonus_speed * delta

func follow() -> void:
	is_followed = true

func oh_fuck_yeah_baby() -> void:
	speed /= 8.0
	is_active = false
	await get_tree().create_timer(1.0).timeout
	$/root/World.pregnant()

func death() -> void:
	queue_free()
func death_end_wave() -> void:
	if is_followed: (1 + Stats.cum_bonus) * (1 if Stats.wave_duration == 60.0 else 3)
	queue_free()

func _on_area_body_entered(body: Node3D) -> void:
	if body.name == "Egg": oh_fuck_yeah_baby()
