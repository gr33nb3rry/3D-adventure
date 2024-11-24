extends Control

@onready var world = $/root/World
@onready var canvas = $/root/World/Canvas

func _ready() -> void:
	CrazySDK.load_data()
	await get_tree().create_timer(0.1).timeout
	reparent(get_tree().get_root())

func loading(to:String) -> void:
	world.process_mode = Node.PROCESS_MODE_DISABLED
	$Canvas/Texture.visible = true
	$Canvas/Texture.mouse_filter = MOUSE_FILTER_STOP
	CrazySDK.stop_gameplay()
	CrazySDK.start_loading()
	var delay : float = randf_range(0.5, 1.5)
	await get_tree().create_timer(delay).timeout
	if to == "game": load_game()
	elif to == "start": load_start()
	CrazySDK.start_gameplay()
	CrazySDK.stop_loading()
	Engine.time_scale = Stats.game_speed
	world.process_mode = Node.PROCESS_MODE_INHERIT
	$Canvas/Texture.visible = false
	$Canvas/Texture.mouse_filter = MOUSE_FILTER_IGNORE
	

func load_game() -> void:
	canvas.get_node("Start").visible = false
	canvas.get_node("Crosshair").visible = true
	canvas.get_node("VBox").visible = true
	canvas.get_node("Weapon").visible = true
	canvas.get_node("StatsLabel").visible = true
	canvas.get_node("NotificationLabel").visible = true
	canvas.get_node("VBox/TaskLabel").visible = true
	canvas.get_node("WaveDuration").visible = true
	canvas.get_node("SwitchWeaponButton").visible = true
	world.get_node("CameraPivot/Camera").current = false
	Stats.default()
	canvas.update_stats()
	canvas.refresh_upgrades()
	canvas.update_cums()
	canvas.update_turrel()
	canvas.update_weapon()
	world.get_node("Player").scale = Vector3(Stats.player_size, Stats.player_size, Stats.player_size)
	world.is_in_game = true
	world.wave = 0
	world.wave_timer = 1
	world.egg_health = Stats.egg_hp
	canvas.bonus_cost = 1
	world.get_node("WaveTimer").start()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func load_start() -> void:
	canvas.get_node("Start").visible = true
	canvas.get_node("Pause").visible = false
	canvas.get_node("Pregnant").visible = false
	canvas.get_node("Completed").visible = false
	canvas.get_node("Crosshair").visible = false
	canvas.get_node("VBox").visible = false
	canvas.get_node("Weapon").visible = false
	canvas.get_node("StatsLabel").visible = false
	canvas.get_node("NotificationLabel").visible = false
	canvas.get_node("VBox/TaskLabel").visible = false
	canvas.get_node("WaveDuration").visible = false
	canvas.get_node("SwitchWeaponButton").visible = false
	world.get_node("CameraPivot/Camera").current = true
	world.end_game()
