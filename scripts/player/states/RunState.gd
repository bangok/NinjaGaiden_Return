extends State

class_name RunState


func enter() -> void:
	player.animation.play("run")
	print("进入 Run")


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

	if player.input.move_direction == 0:

		state_machine.change_state(
			player.idle_state
		)


func physics_update(_delta: float) -> void:

	player.movement.move(
		player.input.move_direction
	)


func exit() -> void:

	print("离开 Run")
