extends CanvasLayer

@onready var debug_label: Label = $Debug
@onready var cums_label: Label = $HBox/Cums/Label
@onready var gun = $/root/World/Player/Model/Main/Gun

func _ready() -> void:
	update_cums()
	update_weapon()

	
func update_cums() -> void:
	cums_label.text = str(Stats.cum_count)

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
