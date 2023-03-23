extends Button

var next_scene = load("res://level/moon.tscn")

func _init():
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func start_game():
	get_tree().change_scene_to_packed(next_scene)
