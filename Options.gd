extends Node

enum Qualities {
	MINIMAL,
	LOW,
	NORMAL,
	HIGH,
	ULTRA
}
var quality_level : int:
	set(value):
		quality_level = value
		update_quality()
		
var fxaa := true:
	set(value):
		fxaa = value
		update_fxaa()
var vsync := true:
	set(value):
		vsync = value
		update_vsync()

func _ready():
	quality_level = Qualities.LOW
	
func update_quality() -> void:
	var quality_settings := {
		"directional_shadow_sizes": [8192, 8192, 8192, 16384, 16384],
		"positional_shadow_sizes": [2048, 4096, 4096, 8192, 16384],
		"directional_shadow_filters": [3, 3, 4, 4, 5],
		"positional_shadow_filters": [1, 1, 2, 3, 4],
		"volumetric_fog": [false, true, true, true, true],
		"volumetric_fog_sizes": [32, 32, 64, 128, 256],
		"volumetric_fog_filter": [false, false, false, true, true],
		"bicubic_glow": [false, false, false, true, true], # (?)
		"ssil": [false, false, true, true, true],
		"sdfgi_ray_counts": [0, 1, 1, 2, 3],
		"sdfgi_cascades": [2, 3, 3, 4, 4],
		"taa": [false, false, true, true, true]
	}
		
	RenderingServer.directional_shadow_atlas_set_size(quality_settings["directional_shadow_sizes"][quality_level], true)
	RenderingServer.directional_soft_shadow_filter_set_quality(quality_settings["directional_shadow_filters"][quality_level])
	# - RenderingServer.positional_soft_shadow_filter_set_quality(quality_settings["positional_shadow_sizes"][quality_level])
	# - get_viewport().positional_shadow_atlas_size = quality_settings["positional_shadow_filters"][quality_level]
	
	$/root/World/WorldEnvironment.environment.volumetric_fog_enabled = quality_settings["volumetric_fog"][quality_level]
	RenderingServer.environment_set_volumetric_fog_volume_size(quality_settings["volumetric_fog_sizes"][quality_level], 64)
	RenderingServer.environment_set_volumetric_fog_filter_active(quality_settings["volumetric_fog_filter"][quality_level])
	
	RenderingServer.environment_glow_set_use_bicubic_upscale(quality_settings["bicubic_glow"][quality_level])
	$/root/World/WorldEnvironment.environment.ssil_enabled = quality_settings["ssil"][quality_level]
	RenderingServer.environment_set_sdfgi_ray_count(quality_settings["sdfgi_ray_counts"][quality_level])
	$/root/World/WorldEnvironment.environment.sdfgi_cascades = quality_settings["sdfgi_cascades"][quality_level]
	get_viewport().use_taa = quality_settings["taa"][quality_level]
	
func update_fxaa():
	get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if fxaa else Viewport.SCREEN_SPACE_AA_DISABLED
func update_vsync():
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
func _input(_event):
	if Input.is_key_pressed(KEY_1): quality_level = Qualities.MINIMAL
	elif Input.is_key_pressed(KEY_2): quality_level = Qualities.LOW
	elif Input.is_key_pressed(KEY_3): quality_level = Qualities.NORMAL
	elif Input.is_key_pressed(KEY_4): quality_level = Qualities.HIGH
	elif Input.is_key_pressed(KEY_5): quality_level = Qualities.ULTRA
	
	elif Input.is_key_pressed(KEY_0): fxaa = !fxaa
	elif Input.is_key_pressed(KEY_Q): vsync = !vsync
