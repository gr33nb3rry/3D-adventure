extends Node3D

@onready var cum : PackedScene = preload("res://scenes/cum.tscn")
@onready var cums_container = $Cums

var is_in_game := false

var wave : int = 0
var wave_timer : int = 60
var new_wave_delay := 5
var ad_timer := 0
var egg_health := 1

func start_new_game() -> void:
	$/root/Loading.loading("game")

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
	if wave <= 3: new_wave_delay = 10
	elif wave <= 10: new_wave_delay = 7
	elif wave <= 25: new_wave_delay = 5
	else: new_wave_delay = 3
	$CumTimer.wait_time = clamp(6.0 - 0.1 * ((wave-1)/1.6), 1.0, 10.0)
	$WaveTimer.start()
	$CumTimer.start()
	$Canvas.update_wave()
	$Canvas.update_task()
	$Market.close()

func wave_end():
	if wave > 0:
		Stats.star_count += 1
		CrazySDK.save_data()
		$Canvas.update_stars()
	$CumTimer.stop()
	for c in get_tree().get_nodes_in_group("Cum"): c.death_end_wave()
	for a in get_tree().get_nodes_in_group("Acid"): a.death()
	$Canvas.update_task()
	$Canvas.update_cums()
	$Market.open()
	if wave == 100: $Canvas.open_complete()
	
func wave_timer_next() -> void:
	wave_timer -= 1
	if wave_timer > 0: 
		ad_timer = clamp(ad_timer - 1, 0, 180)
		if ad_timer == 0: increase_wave_duration()
	$Canvas.update_wave()
	if wave_timer == 0: 
		wave_end()
		CrazySDK.happy_time()
	if wave_timer == -new_wave_delay - 1: wave_start()
	
func decrease_wave_duration() -> void:
	$Canvas/WaveDuration/Button.disabled = true
	if Stats.wave_duration > 30 and wave_timer >= 45: wave_timer = clamp(wave_timer - 30, 1, 30)
	Stats.wave_duration = 30
	ad_timer += 180
func increase_wave_duration() -> void:
	$Canvas/WaveDuration/Button.disabled = false
	Stats.wave_duration = 60

var lost_cums := 0
func i_am_cumming() -> void:
	var t = get_tree().create_tween()
	t.tween_property($WorldEnvironment.environment, "background_energy_multiplier", 1.0, 0.5)
	t.tween_property($WorldEnvironment.environment, "background_energy_multiplier", 0.6, 0.5)
	var so_much_cum = clamp(int(2.0 * (float(wave)/1.6)), 1, 150)
	var add_speed : float = 1.0
	if get_tree().get_node_count_in_group("Cum") + so_much_cum > Stats.cum_limit:
		var available : int = clamp(Stats.cum_limit - get_tree().get_node_count_in_group("Cum"), 0, Stats.cum_limit)
		var lost : int = clamp(so_much_cum - available, 0, so_much_cum)
		so_much_cum -= lost
		lost_cums += lost
	elif lost_cums > 0:
		var error : int = 10
		if lost_cums < so_much_cum - error:
			so_much_cum += lost_cums
			lost_cums = 0
			var available : int = clamp(Stats.cum_limit - get_tree().get_node_count_in_group("Cum"), 0, Stats.cum_limit)
			var lost : int = clamp(so_much_cum - available, 0, so_much_cum)
			so_much_cum -= lost
			lost_cums += lost
		elif lost_cums < so_much_cum + error:
			add_speed = 2.0
			lost_cums = 0
		else:
			add_speed = 4.0
			lost_cums = 0
	if so_much_cum == 0: return
	var gap = float(so_much_cum) / 2.0
	var distance : float = 200.0 + gap
	var position_angle := 0.5
	var position_pivot = Vector3(randf_range(-position_angle,position_angle), 1.0, randf_range(-position_angle,position_angle)) * distance
	$Audio.play()
	for i in so_much_cum:
		var white_sauce = cum.instantiate()
		cums_container.add_child(white_sauce)
		white_sauce.global_position = position_pivot + Vector3(randf_range(-gap,gap), randf_range(-gap,gap), randf_range(-gap,gap))
		white_sauce.bonus_speed = add_speed
func pregnant() -> void:
	egg_health -= 1
	$Canvas.update_task()
	if egg_health == 0:
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
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Canvas/Pregnant.visible = true
		$Canvas/Pregnant/VBox/HighscoreLabel.visible = wave - 1 > Stats.highscore
		Engine.time_scale = 0.25
