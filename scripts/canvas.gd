extends CanvasLayer

@onready var debug_label: Label = $Debug
@onready var cums_label: Label = $VBox/HBox/Cums/Label
@onready var turrels_label: Label = $VBox/HBox/Turrels/Label
@onready var stats_label: RichTextLabel = $StatsLabel
@onready var wave_label: Label = $VBox/HBox/WaveLabel
@onready var wave_timer_label: Label = $VBox/HBox/WaveTimerLabel
@onready var new_wave_timer_label: Label = $VBox/NewWaveTimerLabel

@onready var gun = $/root/World/Player/Model/Main/Gun
@onready var player = $/root/World/Player

var is_stats_visible := false
var is_paused := false

var upgrades = {
	"Turrel": [0, 10, 20, 1.2],
	"GunFollow": [0, 1, 5, 1],
	"GunCooldown": [0, 20, 6, 1.1],
	"TurrelFollow": [0, 1, 50, 1],
	"AcidSpeed": [0, 50, 5, 1.1],
	"AcidRicochet":[0, 3, 50, 2]
}

func _ready() -> void:
	update_cums()
	update_turrel()
	update_weapon()
	CrazySDK.SDK.game.gameplayStart()

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
	
func update_weapon() -> void:
	if gun.current_weapon == gun.Weapons.BLASTER:
		$Weapon.move_child($Weapon/Blaster, $Weapon.get_child_count() - 1)
		$Weapon/Builder.self_modulate = Color.DIM_GRAY
		$Weapon/Builder.self_modulate.a = 0.75
		$Weapon/Blaster.self_modulate = Color.WHITE
		$Weapon/Blaster.self_modulate.a = 1.0
		$Weapon/Builder.position.y = 75
		$Weapon/Blaster.position.y = 25
	elif gun.current_weapon == gun.Weapons.BUILDER:
		$Weapon.move_child($Weapon/Builder, $Weapon.get_child_count() - 1)
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
	if is_paused: CrazySDK.SDK.game.gameplayStop()
	else: CrazySDK.SDK.game.gameplayStart()
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
	
func buy_upgrade(button:String) -> void:
	if Stats.cum_count < upgrades[button][2]: return
	match button:
		"Turrel": Stats.turrel_count += 1
		"GunFollow": Stats.gun_is_following = true
		"GunCooldown": Stats.gun_cooldown -= 0.1
		"TurrelFollow": Stats.turrel_is_following = true
		"AcidSpeed": Stats.acid_speed += 5.0
		"AcidRicochet": Stats.acid_ricochet_count += 1	
	upgrades[button][0] += 1
	upgrades[button][2] = int(upgrades[button][2] * upgrades[button][3])
	update_stats()
	update_turrel()
	update_cums()
	update_market()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and !is_paused and player.is_active:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("show_hide_stats"):
		is_stats_visible = !is_stats_visible
		update_stats()
	elif Input.is_action_just_pressed("pause"):
		pause()
