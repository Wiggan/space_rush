extends Node3D

@onready var bullet = preload("res://gun/bullet/bullet.tscn")

var shots = [
	$Filling003,
	$Filling,
	$Filling002,
	$Filling001,
]

func _input(_event):
	if Input.is_action_just_pressed("shoot"):
		for shot in shots:
			if not shot.on_cooldown:
				shot.on_fire()
				$"../AnimationPlayer".play("Shoot")
				$AudioStreamPlayer3D.play()
				$AudioStreamPlayer3D2.play()
				var bullet_instance = bullet.instantiate()
				add_sibling(bullet_instance)
				if Globals.player.ray.is_colliding():
					bullet_instance.call_deferred("look_at", Globals.player.ray.get_collision_point())
				else:
					bullet_instance.global_transform.basis.z = -global_transform.basis.z
				bullet_instance.global_position = $CPUParticles3D.global_position
				return
