extends CharacterBody3D

@export var sensitivity: float = 0.01
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var ray = $pivot/Camera3D/RayCast3D

signal on_death
var gold_count = 0
@export var max_health: float = 100
@onready var health = max_health
func take_damage(amount):
	health = max(0, health-amount)
	if health == 0:
		on_death.emit()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _init():
	Globals.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		var look_dir = event.relative 
		rotation.y -= look_dir.x * sensitivity
		$pivot.rotation.x = clamp($pivot.rotation.x - look_dir.y * sensitivity, -1.5, 1.5)

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
