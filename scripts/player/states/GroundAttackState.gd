# res://scripts/player/states/GroundAttackState.gd
extends State

class_name GroundAttackState

func enter(_msg: Dictionary = {}) -> void:
	# 1. 瞬间停止移动，施加攻击硬直
	player.movement.stop() 
	# 2. 播放地面攻击动画
	player.animation.play("attack")

func update(_delta: float) -> void:
	# 【核心机制】：依靠动画播放完毕来解除硬直
	var sprite = player.animation.sprite
	if sprite.animation == "attack" and not sprite.is_playing():
		# 动画结束，根据当前按键方向决定恢复为站立还是跑步
		if player.input.move_direction != 0:
			state_machine.change_state(player.run_state)
		else:
			state_machine.change_state(player.idle_state)

func physics_update(_delta: float) -> void:
	player.movement.stop() # 持续锁死 X 轴
	
	# 防错边缘判定：如果在平台边缘挥刀滑落，直接切入失衡下落
	if not player.is_on_floor():
		state_machine.change_state(player.fall_state, {"imbalance": true})
		return
		
	player.move_and_slide()
