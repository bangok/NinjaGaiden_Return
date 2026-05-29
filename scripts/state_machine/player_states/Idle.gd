extends State

func enter():
	anim.play("idle") # 播放你创建的站立动画

func physics_update(delta):
	var direction = Input.get_axis("nav_left", "nav_right")
	if direction != 0:
		state_machine.change_state(get_node("../Run"))
	else:
		player.velocity.x = 0
	player.move_and_slide()
