extends CanvasLayer

@onready var debug_label: Label = $Debug
@onready var cums_label: Label = $VBox/HBox/Cums/Label
@onready var turrels_label: Label = $VBox/HBox/Turrels/Label
@onready var stats_label: RichTextLabel = $StatsLabel
@onready var wave_label: Label = $VBox/HBox/WaveLabel
@onready var wave_timer_label: Label = $VBox/HBox/WaveTimerLabel
@onready var new_wave_timer_label: Label = $VBox/NewWaveTimerLabel
@onready var task_label: RichTextLabel = $VBox/TaskLabel
@onready var highscore_label: RichTextLabel = $Start/VBox/HighscoreLabel
@onready var ad_timer_label: Label = $WaveDuration/DurationLabel


@onready var gun = $/root/World/Player/Model/Main/Gun
@onready var player = $/root/World/Player

var is_stats_visible := false
var is_paused := false

var upgrades = {
	"Turrel": [0, 10, 20, 1.5, 20],
	"GunFollow": [0, 1, 5, 1, 5],
	"GunCooldown": [0, 20, 6, 1.3, 6],
	"TurrelFollow": [0, 1, 50, 1, 50],
	"TurrelCooldown": [0, 30, 6, 1.3, 6],
	"AcidSpeed": [0, 50, 5, 1.3, 5],
	"AcidRicochet":[0, 3, 100, 10, 100],
	"PlayerSize": [0, 25, 5, 1.5, 5]
}
var settings = {
	"AntiAliasing": [2, 2, "q"],
	"Shadows": [2, 3, "t_q"],
	"Sounds": [1, 1, "t"],
	"FPS": [0, 1, "t"],
	"Cum": [0, 1, "t"]
}
var skins = {
	"Orange": {"score":0, "color1":Color(1, 0.734, 0.389),"color2":Color(0.523, 0.259, 0)},
	"Cyan": {"score":3, "color1":Color(0, 0.858, 0.612),"color2":Color(0.334, 0.261, 1)},
	"Envy": {"score":7, "color1":Color(0.616, 0.893, 0),"color2":Color(0, 0.371, 0.301)},
	"Sweety": {"score":12, "color1":Color(1, 0.626, 0.694),"color2":Color(0.723, 0, 0.515)},
	"Smelly": {"score":20, "color1":Color(0.747, 0.358, 0.17),"color2":Color(0.249, 0.051, 0)},
	"Bloody": {"score":35, "color1":Color(1, 0.384, 0.488),"color2":Color(0.118, 0, 0.06)},
	"Luxury": {"score":60, "color1":Color(0.851, 0.716, 0.406),"color2":Color(0.187, 0.104, 0.022)},
	"The Blackest": {"score":100, "color1":Color(0.251, 0.247, 0.287),"color2":Color(0, 0, 0)},
}
var current_skin : String = "Orange"
var is_fps_showing : bool = false
func _ready() -> void:
	update_start()
	update_skins()
	update_passive_skills()
	
func _process(delta: float) -> void:
	if !is_fps_showing: return
	debug_label.text = str(Engine.get_frames_per_second())

func go_to_main_menu() -> void:
	if is_paused: pause()
	$/root/Loading.loading("start")
	
func update_start() -> void:
	highscore_label.text = "[wave amp=50.0 freq=2.0 connected=1][center]highscore " + str(Stats.highscore) + "[/center][/wave]"
	for s in $Settings/VBox/Grid.get_children():
		setup_settings(s.name)
		
func update_cums() -> void:
	cums_label.text = str(Stats.cum_count)
func update_turrel() -> void:
	turrels_label.text = str(Stats.turrel_count)
	
func update_wave() -> void:
	wave_label.text = "wave " + str($/root/World.wave)
	if $/root/World.wave_timer >= 0:
		wave_timer_label.text = str($/root/World.wave_timer / 60).pad_zeros(2) + ":" + str($/root/World.wave_timer % 60).pad_zeros(2)
	if $/root/World.wave_timer <= 0:
		new_wave_timer_label.visible = true
		new_wave_timer_label.text = "next wave in " + str(($/root/World.new_wave_delay + $/root/World.wave_timer) / 60).pad_zeros(2) + ":" + str(($/root/World.new_wave_delay + $/root/World.wave_timer) % 60).pad_zeros(2)
	else: new_wave_timer_label.visible = false
	update_ad()
func update_ad() -> void:
	if $/root/World.ad_timer > 0:
		ad_timer_label.text = str($/root/World.ad_timer / 60).pad_zeros(2) + ":" + str($/root/World.ad_timer % 60).pad_zeros(2)
	else:
		ad_timer_label.text = "00:00"

func update_task() -> void:
	if $/root/World.wave_timer > 0:
		task_label.text = "[center]protect the egg[/center]"
	else:
		task_label.text = "[center]go to market[img=50]res://images/market.png[/img][/center]"
	
func update_weapon() -> void:
	if gun.current_weapon == gun.Weapons.BLASTER:
		$Weapon/TitleLabel.text = "[center][color=ffa224]BLASTER[/color][/center]"
		$Weapon.move_child($Weapon/Blaster, $Weapon.get_child_count() - 2)
		$Weapon/Builder.self_modulate = Color.DIM_GRAY
		$Weapon/Builder.self_modulate.a = 0.75
		$Weapon/Blaster.self_modulate = Color.WHITE
		$Weapon/Blaster.self_modulate.a = 1.0
		$Weapon/Builder.position.y = 75
		$Weapon/Blaster.position.y = 25
	elif gun.current_weapon == gun.Weapons.BUILDER:
		$Weapon/TitleLabel.text = "[center][color=ff3965]BUILDER[/color][/center]"
		$Weapon.move_child($Weapon/Builder, $Weapon.get_child_count() - 2)
		$Weapon/Blaster.self_modulate = Color.DIM_GRAY
		$Weapon/Blaster.self_modulate.a = 0.75
		$Weapon/Builder.self_modulate = Color.WHITE
		$Weapon/Builder.self_modulate.a = 1.0
		$Weapon/Blaster.position.y = 75
		$Weapon/Builder.position.y = 25

func update_stats() -> void:
	if is_stats_visible:
		stats_label.text = "[center][color=675f54]<tab> to hide stats[/color][/center]
	 [table=2]

	[cell][color=fceba5]gun cooldown[/color][/cell]
	[cell]"+str(Stats.gun_cooldown)+"[/cell]
	[cell][color=fceba5]gun follows target[/color][/cell]   
	[cell]"+("yes" if Stats.gun_is_following else "no")+"[/cell]
	[cell][color=ffa224]acid speed[/color][/cell]   
	[cell]"+str(Stats.acid_speed)+"[/cell]
	[cell][color=ffa224]acid ricochet count[/color][/cell]   
	[cell]"+str(Stats.acid_ricochet_count)+"[/cell]
	[cell][color=ff3965]turrel follow target[/color][/cell]   
	[cell]"+("yes" if Stats.turrel_is_following else "no")+"[/cell]

	[/table]"
	else:
		stats_label.text = "[center][color=675f54]<tab> to show stats[/color][/center]"
	
func pause() -> void:
	is_paused = !is_paused
	if is_paused: CrazySDK.stop_gameplay()
	else: CrazySDK.start_gameplay()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_CAPTURED)
	$Crosshair.visible = !is_paused
	$Pause.visible = is_paused
	get_tree().paused = is_paused
	
func open_market() -> void:
	player.is_active = false
	update_market()
	$Crosshair.visible = false
	$Market.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	
func close_market() -> void:
	player.is_active = true
	$Crosshair.visible = true
	$Market.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	
func update_market() -> void:
	for u in $Market/VBox/Grid.get_children():
		u.get_node("Stats/Label").text = str(upgrades[u.name][2]) + " " + str(upgrades[u.name][0]) + "/" + str(upgrades[u.name][1])
		u.disabled = upgrades[u.name][0] == upgrades[u.name][1]
		u.get_node("Stats/Label").visible = upgrades[u.name][0] != upgrades[u.name][1]
	
func update_passive_skills() -> void:
	for u in $Start/Skills.get_children():
		u.get_node("Stats/Label").text = str(upgrades[u.name][2]) + " " + str(upgrades[u.name][0]) + "/" + str(upgrades[u.name][1])
		u.disabled = upgrades[u.name][0] == upgrades[u.name][1]
		u.get_node("Stats/Label").visible = upgrades[u.name][0] != upgrades[u.name][1]
	
func buy_upgrade(button:String) -> void:
	if Stats.cum_count < upgrades[button][2]: return
	match button:
		"Turrel": Stats.turrel_count += 1
		"GunFollow": Stats.gun_is_following = true
		"GunCooldown": Stats.gun_cooldown -= 0.1
		"TurrelFollow": Stats.turrel_is_following = true
		"TurrelCooldown": Stats.turrel_cooldown -= 0.1
		"AcidSpeed": Stats.acid_speed += 5.0
		"AcidRicochet": Stats.acid_ricochet_count += 1
		"PlayerSize": Stats.player_size += 0.2
	Stats.cum_count -= upgrades[button][2]
	player.scale = Vector3(Stats.player_size, Stats.player_size, Stats.player_size)
	get_tree().call_group("Turrel", "update_cooldown")
	
	upgrades[button][0] += 1
	if int(upgrades[button][2] * upgrades[button][3]) == upgrades[button][2]:
		upgrades[button][2] = int(upgrades[button][2] * upgrades[button][3]) + 1
	else:
		upgrades[button][2] = int(upgrades[button][2] * upgrades[button][3])
	update_stats()
	update_turrel()
	update_cums()
	update_market()
	update_passive_skills()
	
func refresh_upgrades() -> void:
	for u in upgrades:
		upgrades[u][0] = 0
		upgrades[u][2] = upgrades[u][4]
	
func decrease_wave_duration() -> void:
	CrazySDK.request_ad()
	
func change_weapon() -> void:
	gun.change_weapon()
	
func open_settings() -> void:
	player.is_active = false
	update_settings()
	$Settings.visible = true
	$Pause.visible = false
	$Start.visible = false
	
func close_settings() -> void:
	$Settings.visible = false
	player.is_active = true
	if $/root/World.is_in_game:
		$Pause.visible = true
	else:
		$Start.visible = true
	
func update_settings() -> void:
	for u in $Settings/VBox/Grid.get_children():
		var value
		match settings[u.name][0]:
			0: 
				match settings[u.name][2]:
					"t": value = "off"
					"q": value = "low"
					"t_q": value = "off"
			1: 
				match settings[u.name][2]:
					"t": value = "on"
					"q": value = "medium"
					"t_q": value = "low"
			2: 
				match settings[u.name][2]:
					"q": value = "high"
					"t_q": value = "medium"
			3: 
				match settings[u.name][2]:
					"q": value = "low"
					"t_q": value = "high"
		
		u.get_node("Label").text = value
		
func change_settings(s:String) -> void:
	settings[s][0] += 1
	if settings[s][0] > settings[s][1]: settings[s][0] = 0
	setup_settings(s)
	update_settings()
	
func setup_settings(s) -> void:
	match s:
		"AntiAliasing": 
			match settings[s][0]:
				0: get_viewport().msaa_3d = Viewport.MSAA_DISABLED
				1: get_viewport().msaa_3d = Viewport.MSAA_2X
				2: get_viewport().msaa_3d = Viewport.MSAA_4X
		"Shadows": 
			if settings[s][0] != 0: $"../Light".shadow_enabled = true
			match settings[s][0]:
				0: $"../Light".shadow_enabled = false
				1: RenderingServer.directional_shadow_atlas_set_size(1024, true)
				2: RenderingServer.directional_shadow_atlas_set_size(4096, true)
				3: RenderingServer.directional_shadow_atlas_set_size(8196, true)
		"Sounds": 
			var bus_idx = AudioServer.get_bus_index("Master")
			AudioServer.set_bus_mute(bus_idx, settings[s][0] == 0)
		"FPS":
			is_fps_showing = settings[s][0] == 1
			debug_label.visible = settings[s][0] == 1
		"Cum": 
			Stats.optimized_cum = settings[s][0] == 1
			get_tree().call_group("Cum", "apply_optimization")
	

	
func update_skins() -> void:
	get_node("Start/Skins/"+current_skin)
	for s in $Start/Skins.get_children():
		s.disabled = skins[s.name]["score"] > Stats.highscore
		s.get_node("Label").visible = skins[s.name]["score"] > Stats.highscore
		s.set("theme_override_colors/font_color", (Color.GOLD if s.name == current_skin else Color.WHITE))
	
func select_skin(s:String) -> void:
	current_skin = s
	apply_skin(s)
	update_skins()
	
func apply_skin(s:String):
	var color1 = skins[s]["color1"]
	var color2 = skins[s]["color2"]
	$"../Skin".mesh.material.set("shader_parameter/color", color1)
	$"../Skin".mesh.material.set("shader_parameter/shadow_color", color2)
	
func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("show_hide_stats"):
		is_stats_visible = !is_stats_visible
		update_stats()
	elif Input.is_action_just_pressed("pause") and player.is_active and $/root/World.is_in_game:
		pause()
	if Input.is_action_just_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
