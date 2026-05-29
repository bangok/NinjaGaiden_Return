extends State

var speed = 300

func enter():
	anim.play("run")   # 注意：你还需要创建一个 "run" 动画

func physics_update(delta):
	var direction = Input.get_axis("nav_left", "nav_right")
	if direction == 0:
		state_machine.change_state(get_node("../Idle"))
	else:
		player.velocity.x = direction * speed
	player.move_and_slide()
