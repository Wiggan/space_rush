extends MeshInstance3D

var on_cooldown: bool = false
var tween

func shape(value):
	set_blend_shape_value(0, value)

func cooled_down():
	on_cooldown = false

func on_fire():
	if not on_cooldown:
		on_cooldown = true
		tween = create_tween()
		tween.parallel().tween_method(shape, 1.0, 0.0, 2.0)
		tween.parallel().tween_callback(cooled_down).set_delay(2)
