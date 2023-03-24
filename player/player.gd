extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 3
const RECOIL_SPEED = 2.0

var local_velocity = Vector3.ZERO
@onready var ray = $pivot/Camera3D/RayCast3D

var death_screen = preload("res://player/death_screen.tscn")
func show_death_screen():
	get_tree().change_scene_to_packed(death_screen)

signal on_death
var gold_count = 0
@export var max_health: float = 100
@onready var health = max_health
func take_damage(amount):
	$AudioStreamPlayer3D2.play()
	health = max(0, health-amount)
	if health == 0:
		on_death.emit()
		Globals.score = gold_count
		set_process(false)
		set_physics_process(false)
		$AnimationPlayer.play("death")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _init():
	Globals.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		var look_dir = event.relative 
		rotation.y -= look_dir.x * Globals.sensitivity
		$pivot.rotation.x = clamp($pivot.rotation.x - look_dir.y * Globals.sensitivity, -1.5, 1.5)
	if not $Menu.visible and (event.is_action_pressed("ui_menu") or event.is_action_pressed("ui_cancel")):
		$Menu.visible = true
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Globals.player.set_process_input(false)
		Globals.player.set_process(false)
		Globals.player.set_physics_process(false)

@onready var was_on_floor = is_on_floor()

func _physics_process(delta):
	
	
	# Add the gravity.
	if not is_on_floor():
		local_velocity.y -= gravity * delta
		if was_on_floor:
			$AnimationPlayer.play("lower")
	else:
		local_velocity.y = 0
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			local_velocity.y = JUMP_VELOCITY
			$AnimationPlayer.play("jump")
		elif $AnimationPlayer.current_animation != "lower":
			local_velocity.y -= JUMP_VELOCITY
			$AnimationPlayer.play("lower")
			
	was_on_floor = is_on_floor()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		local_velocity.x = direction.x * SPEED
		local_velocity.z = direction.z * SPEED
		if not $AnimationPlayer.is_playing() and is_on_floor():
			$AnimationPlayer.play("walk")
	else:
		local_velocity.x = move_toward(local_velocity.x, 0, SPEED)
		local_velocity.z = move_toward(local_velocity.z, 0, SPEED)
	
	if $AnimationPlayer.is_playing() and local_velocity.length() < 0.001:
		$AnimationPlayer.stop()
	
	velocity = impulse_velocity + local_velocity
	move_and_slide()


func _on_timer_timeout():
	Globals.score = gold_count
	set_process(false)
	set_physics_process(false)
	$AnimationPlayer.play("timeup")

@onready var impulse_tween = null
var impulse_velocity = Vector3.ZERO
func _on_gun_shots_fired(count):
	if count > 1:
		if impulse_tween:
			impulse_tween.kill()
		impulse_tween = create_tween()
		impulse_tween.set_ease(Tween.EASE_IN)
		impulse_tween.tween_property(self, "impulse_velocity", Vector3.ZERO, 2).from($pivot/Camera3D/RayCast3D.global_transform.basis.z * SPEED * count)
		
