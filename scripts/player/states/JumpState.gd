# res://scripts/player/states/JumpState.gd
extends State

class_name JumpState

func enter(_msg: Dictionary = {}) -> void:
	player.animation.play("jump")
	player.movement.jump()

func update(_delta: float) -> void:
	# 触发空中攻击
	if Input.is_action_just_pressed("attack"):
		var move_dir = player.input.move_direction
		var air_imbalance = false
		# 【预空判】如果在触发攻击的瞬间按着反方向，直接以失衡状态切入攻击
		if move_dir != 0 and move_dir != player.facing_direction:
			air_imbalance = true
			
		state_machine.change_state(state_machine.get_node("AirAttackState"), {"imbalance": air_imbalance})
		return
		
	# 触发空中忍术
	if Input.is_action_just_pressed("ninjutsu"):
		var move_dir = player.input.move_direction
		var air_imbalance = false # 如果是 FallState，改成 = is_imbalance
		
		# 预空判：触发瞬间按着反方向，直接以失衡状态切入
		if move_dir != 0 and move_dir != player.facing_direction:
			air_imbalance = true
			
		state_machine.change_state(state_machine.get_node("AirNinjutsuState"), {"imbalance": air_imbalance})
		return

	if player.movement.is_falling():
		state_machine.change_state(player.fall_state, {"imbalance": false})
		return

func physics_update(_delta: float) -> void:
	var move_dir = player.input.move_direction
	
	# 【空中剑术修正】按住 L 且 按下了面朝方向
	if Input.is_action_pressed("special_move"):
		if move_dir != 0 and move_dir == player.facing_direction:
			state_machine.change_state(state_machine.get_node("SwordDashState"))
			return

	# 【核心铁律】取消所有转身代码
	if move_dir != 0:
		if move_dir != player.facing_direction:
			player.velocity.x = move_dir * player.data.walk_speed * player.data.imbalance_speed_factor
			state_machine.change_state(player.fall_state, {"imbalance": true})
			player.move_and_slide()
			return
		else:
			player.movement.move(move_dir)
	else:
		player.movement.stop()
		
	player.move_and_slide()
