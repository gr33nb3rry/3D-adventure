extends Node3D

@onready var cum : PackedScene = preload("res://scenes/cum.tscn")
@onready var cums_container = $Cums

var is_in_game := false

var wave : int = 0
var wave_timer : int = 60
var new_wave_delay := 5

var ad_timer := 0

func start_new_game() -> void:
	$Canvas/Start.visible = false
	$Canvas/Crosshair.visible = true
	$Canvas/VBox.visible = true
	$Canvas/Weapon.visible = true
	$Canvas/StatsLabel.visible = true
	$Canvas/TaskLabel.visible = true
	$Canvas/WaveDuration.visible = true
	$Canvas/SwitchWeaponButton.visible = true
	$CameraPivot/Camera.current = false
	Stats.default()
	$Canvas.refresh_upgrades()
	$Canvas.update_cums()
	$Canvas.update_turrel()
	$Canvas.update_weapon()
	$Player.scale = Vector3(Stats.player_size, Stats.player_size, Stats.player_size)
	is_in_game = true
	wave = 0
	wave_timer = 1
	$WaveTimer.start()
	CrazySDK.start_gameplay()
	Engine.time_scale = Stats.game_speed
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func end_game() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Engine.time_scale = Stats.game_speed
	is_in_game = false
	if wave - 1 > Stats.highscore: Stats.highscore = wave - 1
	CrazySDK.save_data()
	$Canvas.update_start()
	$CumTimer.stop()
	$WaveTimer.stop()
	for c in get_tree().get_nodes_in_group("Cum"): c.death()
	for t in get_tree().get_nodes_in_group("Turrel"): t.death()
	$Egg/Mesh.mesh.material.set("shader_parameter/_specular_smoothness", 0.5)
	$Egg/Mesh.mesh.material.set("shader_parameter/_specular_strength", 0.055)
	$Egg/Mesh.mesh.material.set("shader_parameter/_glossiness", 0.165)
	$Egg/Mesh.mesh.material.set("shader_parameter/_rim_size", 0.3)
	$Egg/Mesh.mesh.material.set("shader_parameter/color", Color(1.0, 0.56, 0.67, 1.0))

func wave_start() -> void:
	wave += 1
	wave_timer = Stats.wave_duration
	$CumTimer.wait_time = clamp(6.12132 - 0.207972 * wave, 1.0, 10.0)
	$WaveTimer.start()
	$CumTimer.start()
	$Canvas.update_wave()
	$Canvas.update_task()
	$Market.close()

func wave_end():
	$CumTimer.stop()
	for c in get_tree().get_nodes_in_group("Cum"): c.death()
	$Canvas.update_task()
	$Market.open()
	
func wave_timer_next() -> void:
	wave_timer -= 1
	if wave_timer > 0: 
		ad_timer = clamp(ad_timer - 1, 0, 300)
		if ad_timer == 0: increase_wave_duration()
	$Canvas.update_wave()
	if wave_timer == 0: 
		wave_end()
		CrazySDK.happy_time()
	if wave_timer == -new_wave_delay - 1: wave_start()
	
func decrease_wave_duration() -> void:
	Stats.wave_duration = 30.0
	if Stats.wave_duration > 30.0: wave_timer = clamp(wave_timer - 30, 1, 30)
	ad_timer += 300
func increase_wave_duration() -> void:
	Stats.wave_duration = 60.0

func i_am_cumming() -> void:
	var t = get_tree().create_tween()
	t.tween_property($WorldEnvironment.environment, "background_energy_multiplier", 1.0, 0.5)
	t.tween_property($WorldEnvironment.environment, "background_energy_multiplier", 0.6, 0.5)
	var so_much_cum = clamp(3.4 * wave - 1.73333, 1, 100)
	var gap = float(so_much_cum) / 2.0
	#var distance : float = clamp(2.52517 * so_much_cum + 247.9, 250.0, 500.0)
	var distance : float = 200.0 + gap
	var position_angle := 0.5
	var position_pivot = Vector3(randf_range(-position_angle,position_angle), 1.0, randf_range(-position_angle,position_angle)) * distance
	for i in so_much_cum:
		var white_sauce = cum.instantiate()
		cums_container.add_child(white_sauce)
		white_sauce.global_position = position_pivot + Vector3(randf_range(-gap,gap), randf_range(-gap,gap), randf_range(-gap,gap))

func pregnant(cum:Node3D) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$WaveTimer.stop()
	$CumTimer.stop()
	for c in get_tree().get_nodes_in_group("Cum"): c.death()
	var pregnant_time := 1.0
	var t = get_tree().create_tween().set_parallel(true)
	t.tween_property($Egg/Mesh.mesh.material, "shader_parameter/_specular_smoothness", 0.0, pregnant_time)
	t.tween_property($Egg/Mesh.mesh.material, "shader_parameter/_specular_strength", 0.075, pregnant_time)
	t.tween_property($Egg/Mesh.mesh.material, "shader_parameter/_glossiness", 0.1, pregnant_time)
	t.tween_property($Egg/Mesh.mesh.material, "shader_parameter/_rim_size", 0.5, pregnant_time)
	t.tween_property($Egg/Mesh.mesh.material, "shader_parameter/color", Color.WHITE, pregnant_time)
	$Canvas/Crosshair.visible = false
	await get_tree().create_timer(pregnant_time + 1.0).timeout
	$Canvas/Pregnant.visible = true
	$Canvas/Pregnant/VBox/HighscoreLabel.visible = wave - 1 > Stats.highscore
	Engine.time_scale = 0.25
