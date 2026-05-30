extends State

class_name IdleState



func enter():
	player.animation.play("idle")
	print("进入 Idle")
	
func physics_update(_delta):

	player.movement.move(
		player.input.move_direction
	)

func update(_delta):

	if !player.is_on_floor():

		state_machine.change_state(
			player.fall_state
		)

		return

	if player.is_on_floor() \
	and player.input.consume_jump():

		state_machine.change_state(
			player.jump_state
		)

		return

	if player.input.move_direction != 0:

		state_machine.change_state(
			player.run_state
		)


func exit() -> void:

	print("离开 Idle")
