extends AnimationPlayer

func _input(event):
	if event.is_action_pressed("ui_menu") or event.is_action_pressed("ui_cancel"):
		play("start")
