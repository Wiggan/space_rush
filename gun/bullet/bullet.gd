extends Area3D

var speed = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position = global_position + speed * global_transform.basis.z * delta
	global_rotate(global_transform.basis.z, delta * 0.1)


func _on_body_entered(body):
	set_physics_process(false)
	$AnimationPlayer.play("explode")
