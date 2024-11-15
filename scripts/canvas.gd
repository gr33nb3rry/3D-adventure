extends CanvasLayer

@onready var debug_label: Label = $Debug
@onready var cums_label: Label = $HBox/Cums/Label
@onready var turrels_label: Label = $HBox/Turrels/Label
@onready var stats_label: RichTextLabel = $StatsLabel
@onready var wave_label: Label = $HBox/WaveLabel
@onready var wave_timer_label: Label = $HBox/WaveTimerLabel

@onready var gun = $/root/World/Player/Model/Main/Gun

var is_stats_visible := false

func _ready() -> void:
	update_cums()
	update_turrel()
	update_weapon()

func update_cums() -> void:
	cums_label.text = str(Stats.cum_count)
func update_turrel() -> void:
	turrels_label.text = str(Stats.turrel_count)
	
func update_wave() -> void:
	wave_label.text = "wave " + str($/root/World.wave)
	var minutes = $/root/World.wave_timer / 60
	var remaining_seconds = $/root/World.wave_timer % 60
	wave_timer_label.text = str(minutes).pad_zeros(2) + ":" + str(remaining_seconds).pad_zeros(2)
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

[/tabl
"
	else:
		stats_label.text = "[center][color=675f54]<tab> to show stats[/color][/center]"
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("show_hide_stats"):
		is_stats_visible = !is_stats_visible
		update_stats()
