extends Control

@onready var progress_bar: ProgressBar = $Center/ProgressBar

var is_full : bool = true

# Called when the node enters the scene tree for the first time.
func shoot() -> void:
	is_full = false
	progress_bar.value = 0.5
	var t = get_tree().create_tween()
	t.tween_property(progress_bar, "value", 10, Stats.gun_cooldown).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(Stats.gun_cooldown).timeout
	is_full = true
