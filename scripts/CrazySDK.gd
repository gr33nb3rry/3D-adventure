extends Node

var SDK = null

func _ready() -> void:
	if not OS.has_feature("crazygames"): return
	var window = JavaScriptBridge.get_interface("window")
	SDK = window.CrazyGames.SDK


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
