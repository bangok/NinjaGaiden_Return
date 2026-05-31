# res://scripts/player/states/FallState.gd
extends State

class_name FallState

var is_imbalance: bool = false

func enter(msg: Dictionary = {}) -> void:
	is_imbalance = msg.get("imbalance", false)
	
	if is_imbalance:
		player.animation.play("fall_imbalance")
	else:
		player.animation.play("fall")

func update(_delta: float) -> void:
	# 触发空中攻击
	if Input.is_action_just_pressed("attack"):
		var move_dir = player.input.move_direction
		var air_imbalance = is_imbalance
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

	if player.is_on_floor():
		if player.input.move_direction != 0:
			state_machine.change_state(player.run_state)
		else:
			state_machine.change_state(player.idle_state)

func physics_update(_delta: float) -> void:
	var move_dir = player.input.move_direction
	
	# 【空中剑术修正】按住 L 且 按下了面朝方向
	if Input.is_action_pressed("special_move"):
		if move_dir != 0 and move_dir == player.facing_direction:
			state_machine.change_state(state_machine.get_node("SwordDashState"))
			
	
	if is_imbalance:
		if move_dir != 0:
			if move_dir != player.facing_direction:
				player.velocity.x = move_dir * player.data.walk_speed * player.data.imbalance_speed_factor
			else:
				player.velocity.x = move_dir * player.data.walk_speed
		else:
			player.movement.stop()
	else:
		# 【核心修复】普通的平衡下落中，如果按了反方向，原地转为失衡，拒绝转身！
		if move_dir != 0:
			if move_dir != player.facing_direction:
				is_imbalance = true
				player.animation.play("fall_imbalance")
				player.velocity.x = move_dir * player.data.walk_speed * player.data.imbalance_speed_factor
			else:
				player.movement.move(move_dir)
		else:
			player.movement.stop()
			
	player.move_and_slide()

func exit() -> void:
	print("离开 Fall")
