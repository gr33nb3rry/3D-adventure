extends Node

var SDK = null

var adStartedCallback
var adErrorCallback
var adFinishedCallback
var adCallbacks


func _ready() -> void:
	if not OS.has_feature("crazygames"): return
	var window = JavaScriptBridge.get_interface("window")
	SDK = window.CrazyGames.SDK
	adStartedCallback = JavaScriptBridge.create_callback(adStarted)
	adErrorCallback = JavaScriptBridge.create_callback(adError)
	adFinishedCallback = JavaScriptBridge.create_callback(adFinished)
	adCallbacks = JavaScriptBridge.create_object("Object")
	adCallbacks["adFinished"] = adFinishedCallback
	adCallbacks["adError"] = adErrorCallback
	adCallbacks["adStarted"] = adStartedCallback
	
	Stats.highscore = SDK.data.getItem("highscore")

func start_gameplay() -> void:
	if not OS.has_feature("crazygames"): return
	SDK.game.gameplayStart()
func stop_gameplay() -> void:
	if not OS.has_feature("crazygames"): return
	SDK.game.gameplayStop()
func happy_time() -> void:
	if not OS.has_feature("crazygames"): return
	SDK.game.happytime()

func adStarted(args):
	get_tree().paused = true

func adError(error):
	print("error: ", error)

func adFinished(args):
	get_tree().paused = false
	$/root/World.decrease_wave_duration()

func request_ad() -> void:
	SDK.ad.requestAd("rewarded", adCallbacks)

func save_data() -> void:
	if not OS.has_feature("crazygames"): return
	SDK.data.setItem("highscore", Stats.highscore)
