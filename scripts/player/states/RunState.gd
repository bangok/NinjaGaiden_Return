# res://scripts/player/states/RunState.gd
extends State

class_name RunState

func enter(_msg: Dictionary = {}) -> void:
	player.animation.play("run")

func physics_update(_delta: float) -> void:
	
	# 触发剑术备战 (急停进入架势)
	if Input.is_action_pressed("special_move"):
		state_machine.change_state(state_machine.get_node("SwordReadyState"))
		return
	
	# 触发地面忍术
	if Input.is_action_just_pressed("ninjutsu"):
		state_machine.change_state(state_machine.get_node("GroundNinjutsuState"))
		return
	
	# 触发地面攻击 (修正了获取状态节点的路径)
	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("GroundAttackState"))
		return
		
	# 【核心修复：踩空坠落判定】
	if not player.is_on_floor():
		state_machine.change_state(player.fall_state, {"imbalance": true})
		return
		
	# 触发下蹲 (奔跑时按 S 瞬间急停下蹲)
	if Input.is_action_pressed("nav_down"):
		state_machine.change_state(state_machine.get_node("CrouchState"))
		return
		
	if player.input.consume_jump():
		state_machine.change_state(player.jump_state)
		return
		
	var move_dir = player.input.move_direction
	if move_dir == 0:
		state_machine.change_state(player.idle_state)
		return
		
	# 正常的地面移动与转向
	player.set_facing_direction(move_dir)
	player.movement.move(move_dir)
	player.move_and_slide()
