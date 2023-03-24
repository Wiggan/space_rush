extends Node3D

@onready var bullet = preload("res://gun/bullet/bullet.tscn")

signal shots_fired(count: int)

@onready var shots = [
	$gun/Filling003,
	$gun/Filling,
	$gun/Filling002,
	$gun/Filling001,
]

func shoot(shot, origin, forward):
	shot.on_fire()
	$AnimationPlayer.play("Shoot")
	$gun/AudioStreamPlayer3D.play()
	$gun/AudioStreamPlayer3D2.play()
	var bullet_instance = bullet.instantiate()
	$gun.add_sibling(bullet_instance)
	bullet_instance.global_position = origin
	bullet_instance.global_transform.basis.z = forward

const radius = 0.6
var offsets = [
	Vector3.ZERO, 
	Vector3(-0.5*radius, 0.866*radius, 0),
	Vector3(radius, 0, 0),
	Vector3(-0.5*radius, -0.866*radius, 0)
]
	
func _input(_event):
	var forward = -global_transform.basis.z
	if Globals.player.ray.is_colliding():
		forward = $gun/CPUParticles3D.global_transform.looking_at(Globals.player.ray.get_collision_point()).basis.z
	var shot_count = 0
	if Input.is_action_just_pressed("shoot"):
		for shot in shots:
			if not shot.on_cooldown:
				shoot(shot, $gun/CPUParticles3D.global_position, forward)
				shot_count += 1
				return
	
	if Input.is_action_just_pressed("quad"):
		for shot in shots:
			if not shot.on_cooldown:
				shoot(shot, $gun/CPUParticles3D.global_transform.translated_local(offsets[shot_count]).origin, forward)
				shot_count += 1
				
	if shot_count:
		shots_fired.emit(shot_count)
