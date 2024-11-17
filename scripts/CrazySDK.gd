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
	
	if JavaScriptBridge.eval("(function() { return localStorage.getItem('highscore') !== null; })();"):
		Stats.highscore = int(JavaScriptBridge.eval("localStorage.getItem('highscore');"))
	if JavaScriptBridge.eval("(function() { return localStorage.getItem('stars') !== null; })();"):
		Stats.star_count = int(JavaScriptBridge.eval("localStorage.getItem('stars');"))
	if JavaScriptBridge.eval("(function() { return localStorage.getItem('skin') !== null; })();"):
		$/root/World/Canvas.current_skin = str(JavaScriptBridge.eval("localStorage.getItem('skin');"))
	if JavaScriptBridge.eval("(function() { return localStorage.getItem('gun_f') !== null; })();"):
		$/root/World/Canvas.upgrades["GunFollow"][0] = int(JavaScriptBridge.eval("localStorage.getItem('gun_f');"))
	if JavaScriptBridge.eval("(function() { return localStorage.getItem('turrel_f') !== null; })();"):
		$/root/World/Canvas.upgrades["TurrelFollow"][0] = int(JavaScriptBridge.eval("localStorage.getItem('turrel_f');"))
	$/root/World/Canvas.update_start()
	$/root/World/Canvas.apply_skin($/root/World/Canvas.current_skin)
	
	
func start_gameplay() -> void:
	if not OS.has_feature("crazygames"): return
	SDK.game.gameplayStart()
func stop_gameplay() -> void:
	if not OS.has_feature("crazygames"): return
	SDK.game.gameplayStop()
func start_loading() -> void:
	if not OS.has_feature("crazygames"): return
	SDK.game.sdkGameLoadingStart()
func stop_loading() -> void:
	if not OS.has_feature("crazygames"): return
	SDK.game.sdkGameLoadingStop()
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
	JavaScriptBridge.eval("localStorage.setItem('highscore', "+str(Stats.highscore)+");")
	JavaScriptBridge.eval("localStorage.setItem('stars', "+str(Stats.star_count)+");")
	JavaScriptBridge.eval("localStorage.setItem('skin', '"+str($/root/World/Canvas.current_skin)+"');")
	JavaScriptBridge.eval("localStorage.setItem('gun_f', "+str($/root/World/Canvas.upgrades["GunFollow"][0])+");")
	JavaScriptBridge.eval("localStorage.setItem('turrel_f', "+str($/root/World/Canvas.upgrades["TurrelFollow"][0])+");")
