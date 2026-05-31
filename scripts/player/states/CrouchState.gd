# res://scripts/player/states/CrouchState.gd
extends State

class_name CrouchState

func enter(_msg: Dictionary = {}) -> void:
	# 瞬间停止移动，并播放下蹲动画
	player.movement.stop()
	player.animation.play("crouch")
	
	# TODO: 未来在这里添加缩小 HurtBox (受击框) 的逻辑

func physics_update(_delta: float) -> void:
	
	# 触发地面忍术
	if Input.is_action_just_pressed("ninjutsu"):
		state_machine.change_state(state_machine.get_node("GroundNinjutsuState"))
		return
	
	# 1. 触发下蹲攻击
	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("CrouchAttackState"))
		return

	# 2. 边缘防错：如果在平台边缘滑落，直接切入失衡下落
	if not player.is_on_floor():
		state_machine.change_state(player.fall_state, {"imbalance": true})
		return
		
	# 3. 核心机制：松开下蹲键，恢复站立或奔跑
	if not Input.is_action_pressed("nav_down"):
		if player.input.move_direction != 0:
			state_machine.change_state(player.run_state)
		else:
			state_machine.change_state(player.idle_state)
		return
		
	# 保持锁死 X 轴
	player.movement.stop()
	player.move_and_slide()

# 当离开下蹲状态时（无论是站起还是起跳）
func exit() -> void:
	# TODO: 未来在这里添加恢复 HurtBox (受击框) 默认高度的逻辑
	pass
