extends Button

var next_scene = preload("res://level/moon.tscn")

func start_game():
	get_tree().change_scene_to_packed(next_scene)
