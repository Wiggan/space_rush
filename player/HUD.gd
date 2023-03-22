extends Control

var time_text_format = "TIME: %d:%02d"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$HBoxContainer/HealthBar.value = Globals.player.health
	$HBoxContainer2/GoldCount.text = str(Globals.player.gold_count)
	$Time.text = time_text_format % [floor($"../Timer".time_left / 60), int($"../Timer".time_left) % 60]
