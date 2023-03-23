extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var ray = $pivot/Camera3D/RayCast3D

var death_screen = preload("res://player/death_screen.tscn")
func show_death_screen():
	get_tree().change_scene_to_packed(death_screen)

signal on_death
var gold_count = 0
@export var max_health: float = 1
@onready var health = max_health
func take_damage(amount):
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
		velocity.y -= gravity * delta
		if was_on_floor:
			$AnimationPlayer.play("lower")

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			$AnimationPlayer.play("jump")
		elif $AnimationPlayer.current_animation != "lower":
			velocity.y = -JUMP_VELOCITY
			$AnimationPlayer.play("lower")
			
	was_on_floor = is_on_floor()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if not $AnimationPlayer.is_playing() and is_on_floor():
			$AnimationPlayer.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if $AnimationPlayer.is_playing() and velocity.length() < 0.001:
		$AnimationPlayer.stop()
	
	
	move_and_slide()


func _on_timer_timeout():
	Globals.score = gold_count
	set_process(false)
	set_physics_process(false)
	$AnimationPlayer.play("timeup")
