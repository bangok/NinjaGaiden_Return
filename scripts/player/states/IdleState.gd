# res://scripts/player/states/IdleState.gd
extends State

class_name IdleState

func enter(_msg: Dictionary = {}) -> void:
	player.animation.play("idle")

func physics_update(_delta: float) -> void:
	# 触发地面攻击 (修正了获取状态节点的路径)
	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("GroundAttackState"))
		return
	
	# 【核心修复：踩空坠落判定】
	if not player.is_on_floor():
		state_machine.change_state(player.fall_state, {"imbalance": true})
		return
		
	if player.input.consume_jump():
		state_machine.change_state(player.jump_state)
		return
		
	if player.input.move_direction != 0:
		state_machine.change_state(player.run_state)
		return
		
	player.movement.stop()
	player.move_and_slide()
