extends Area3D


func _on_body_entered(_body):
	Globals.player.gold_count += 1
	$AnimationPlayer.play("pickup")
	$AudioStreamPlayer.play()
