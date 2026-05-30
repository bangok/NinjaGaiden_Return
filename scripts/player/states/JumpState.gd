extends State

class_name JumpState



func enter() -> void:

	player.animation.play("jump")
	player.movement.jump()
	print("进入 Jump")


func update(_delta: float) -> void:

	if player.movement.is_falling():

		state_machine.change_state(
			player.fall_state
		)


func physics_update(_delta: float) -> void:

	player.movement.move(
		player.input.move_direction
	)


func exit() -> void:

	print("离开 Jump")
