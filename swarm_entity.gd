class_name SwarmEntity extends Node3D

var velocity : Vector3
var perching : bool = false
var perch_timer : float = 0.0
var perching_time = randf_range(1.0, 5.0)
var animation_player : AnimationPlayer
var animation : Animation

func _ready():
	animation_player = $scene/AnimationPlayer
	animation = animation_player.get_animation('Animation')
	animation_player.set_current_animation('Animation')
	animation_player.seek(randf_range(2.5, 7.4))
	animation_player.play()
	
func _process(delta):
	if perching:
		animation.loop_mode = Animation.LOOP_NONE
		perch_timer -= delta
		if perch_timer < 0:
			perching = false
			animation.loop_mode = Animation.LOOP_LINEAR
			animation_player.seek(2.0)
			animation_player.play()
	else:
		if animation_player.current_animation_position > 7.4:
			animation_player.seek(2.5)

func perch():
	perching = true
	perch_timer = perching_time
