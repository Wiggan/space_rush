extends GridContainer

func _input(event):
	if event.is_action_pressed("ui_menu") or event.is_action_pressed("ui_cancel"):
			if get_tree().paused:
				_on_resume_pressed()
				
func _on_resume_pressed():
	$"../..".visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Globals.player.set_process_input(true)
	Globals.player.set_process(true)
	Globals.player.set_physics_process(true)


func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)


func _on_sens_slider_value_changed(value):
	Globals.sensitivity = value


func _on_brightness_slider_value_changed(value):
	$"../../../pivot/Camera3D".set("attributes/exposure_multiplier", value)


func _on_menu_visibility_changed():
	if $"../..".visible == true:
		pass
