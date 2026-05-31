# res://scripts/player/states/SwordReadyState.gd
extends State

class_name SwordReadyState

func enter(_msg: Dictionary = {}) -> void:
	# 瞬间定身，进入居合/备战架势
	player.movement.stop()
	player.animation.play("sword_ready")

func physics_update(_delta: float) -> void:
	# 1. 核心退出机制：如果松开了 L 键，立刻解除备战
	if not Input.is_action_pressed("special_move"):
		if player.input.move_direction != 0:
			state_machine.change_state(player.run_state)
		else:
			state_machine.change_state(player.idle_state)
		return

	# 2. 核心触发机制：按着 L 的同时，按下了面朝方向的键
	var move_dir = player.input.move_direction
	if move_dir != 0 and move_dir == player.facing_direction:
		state_machine.change_state(state_machine.get_node("SwordDashState"))
		return

	# 3. 边缘坠落防错
	if not player.is_on_floor():
		state_machine.change_state(player.fall_state, {"imbalance": true})
		return

	player.movement.stop() # 保持 X 轴锁定
	player.move_and_slide()
