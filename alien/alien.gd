extends RigidBody3D

@onready var bullet = preload("res://alien/projectile.tscn")

enum States {
	Idle,
	RandomWalking,
	Hunting,
	Shooting,
	MeleeAttacking
}

const AGGRO_RANGE = 45
const ATTACK_RANGE = 2
const SMOOTH_SPEED = 8.0

@export var velocity = 2.5
var state = States.Idle
var cooldown = false

signal on_death

@export var max_health: float = 100
@onready var health = max_health
func take_damage(amount):
	health = max(0, health-amount)
	$Death.play()
	if health == 0:
		on_death.emit()
		set_process(false)
		set_physics_process(false)
		$CollisionShape3D.set_deferred("disabled", true)
		$AnimationTree["parameters/StateMachine/playback"].travel("Death")
		$CleanUpTimer.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if state in [States.Hunting, States.MeleeAttacking, States.Shooting]:
		$HeadBone/Node3D.look_at(Globals.player.global_position)
	else:
		$HeadBone/Node3D.rotation = $HeadBone.rotation
		
	if $NavigationAgent3D.is_navigation_finished() and state == States.RandomWalking:
		$AnimationTree.set("parameters/StateMachine/conditions/Running", false)
		$AnimationTree.set("parameters/StateMachine/conditions/Idle", true)
		action_done()
		return
		
	if state in [States.Idle, States.Shooting, States.MeleeAttacking]:
		$AnimationTree.set("parameters/StateMachine/conditions/Running", false)
		$AnimationTree.set("parameters/StateMachine/conditions/Idle", true)
		var look_at_target = Globals.player.global_position
		look_at_target.y = global_position.y
		look_at(look_at_target)
		return 
		
	var next_path_position : Vector3 = $NavigationAgent3D.get_next_path_position()
	var current_agent_position : Vector3 = global_transform.origin
	var new_velocity : Vector3 = (next_path_position - current_agent_position).normalized() * velocity
	$NavigationAgent3D.set_velocity(new_velocity)

	var targ = next_path_position - global_position
	rotation.y = lerp_angle(rotation.y, atan2(-targ.x, -targ.z), 1)#delta * SMOOTH_SPEED)



func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	set_linear_velocity(safe_velocity)
var time_spent_in_state = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_spent_in_state += delta
	if state == States.Idle or state == States.RandomWalking:
		if not cooldown and global_position.distance_to(Globals.player.global_position) < AGGRO_RANGE:
			time_spent_in_state = 0
			if randf() > 0.6:
				state = States.Hunting
				$AnimationTree.set("parameters/StateMachine/conditions/Running", true)
				$AnimationTree.set("parameters/StateMachine/conditions/Idle", false)
				$NavigationAgent3D.set_target_position(Globals.player.global_position)
				$Hunt.play()
			else:
				state = States.Shooting
				$AnimationTree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				$Shoot.play()
		elif state == States.Idle:
			if time_spent_in_state > 1: 
				state = States.RandomWalking
				$AnimationTree.set("parameters/StateMachine/conditions/Running", true)
				$AnimationTree.set("parameters/StateMachine/conditions/Idle", false)
				$NavigationAgent3D.set_target_position(global_position + Vector3((randf() - 0.5) * 5, 0, (randf() - 0.5) * 5))
	elif state == States.Hunting:
		if time_spent_in_state > 0.5:
				$NavigationAgent3D.set_target_position(Globals.player.global_position)
				time_spent_in_state = 0
				if randf() > 0.9:
					$AnimationTree.set("parameters/Shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
					$Shoot.play()
		if global_position.distance_to(Globals.player.global_position) < ATTACK_RANGE:
				state = States.MeleeAttacking
				time_spent_in_state = 0
				$AnimationTree.set("parameters/StateMachine/conditions/Running", false)
				$AnimationTree.set("parameters/StateMachine/conditions/Idle", true)
				$AnimationTree.set("parameters/Melee/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)	
		
func action_done():
	time_spent_in_state = 0
	state = States.Idle
	$AnimationTree.set("parameters/StateMachine/conditions/Running", false)
	$AnimationTree.set("parameters/StateMachine/conditions/Idle", true)
	$CooldownTimer.start()
	cooldown = true

func shoot():
	var bullet_instance = bullet.instantiate()
	add_sibling(bullet_instance)
	bullet_instance.call_deferred("look_at", Globals.player.global_position)
	bullet_instance.global_position = $RootBone.global_position


func _on_cooldown_timer_timeout():
	cooldown = false


func _on_clean_up_timer_timeout():
	queue_free()
	
func hit_player():
	if global_position.distance_to(Globals.player.global_position) < ATTACK_RANGE:
		Globals.player.take_damage(30)
