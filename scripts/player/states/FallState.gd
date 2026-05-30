extends State

class_name FallState


func enter() -> void:
	player.animation.play("fall")
	print("进入 Fall")


func update(_delta: float) -> void:

	if player.is_on_floor():

		if player.input.move_direction != 0:

			state_machine.change_state(
				player.run_state
			)

		else:

			state_machine.change_state(
				player.idle_state
			)


func physics_update(_delta: float) -> void:

	player.movement.move(
		player.input.move_direction
	)


func exit() -> void:

	print("离开 Fall")
