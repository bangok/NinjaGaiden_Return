# res://scripts/player/states/CrouchAttackState.gd
extends State

class_name CrouchAttackState

func enter(_msg: Dictionary = {}) -> void:
	player.movement.stop()
	player.animation.play("crouch_attack")

func update(_delta: float) -> void:
	# 动画播放完毕的结算逻辑
	var sprite = player.animation.sprite
	if sprite.animation == "crouch_attack" and not sprite.is_playing():
		# 【纯正操作手感】：优先判断是否还按着下蹲键
		if Input.is_action_pressed("nav_down"):
			state_machine.change_state(state_machine.get_node("CrouchState"))
		elif player.input.move_direction != 0:
			state_machine.change_state(player.run_state)
		else:
			state_machine.change_state(player.idle_state)

func physics_update(_delta: float) -> void:
	player.movement.stop() # 持续锁死 X 轴
	
	if not player.is_on_floor():
		state_machine.change_state(player.fall_state, {"imbalance": true})
		return
		
	player.move_and_slide()
