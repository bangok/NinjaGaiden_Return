# res://scripts/player/states/AirAttackState.gd
extends State

class_name AirAttackState

var is_imbalance: bool = false

func enter(msg: Dictionary = {}) -> void:
	is_imbalance = msg.get("imbalance", false)
	
	# 1. 核心优化：瞬间强制播放攻击动画的第一帧
	player.animation.play("air_attack")
	
	# 2. 核心解耦：【超低空拔刀保障机制】
	# 在这里，我们提前面向下一阶段的战斗系统。当进入状态的这一帧，
	# 哪怕下一帧就要落地，我们也必须在这里【立刻】激活刀光或伤害检测（Hitbox）！
	# 这样就能确保“落地前一小段距离按下攻击”绝对能斩杀敌人。
	_trigger_instant_hit()

func update(_delta: float) -> void:
	# 如果空中挥刀未完但踩到了地面，直接强制中断并恢复地面姿态（忍龙经典落地取消硬直）
	if player.is_on_floor():
		state_machine.change_state(player.idle_state)
		return

	# 攻击动画正常播放结束，退回到下落状态
	var sprite = player.animation.sprite
	if sprite.animation == "air_attack" and not sprite.is_playing():
		state_machine.change_state(player.fall_state, {"imbalance": is_imbalance})

func physics_update(_delta: float) -> void:
	var move_dir = player.input.move_direction
	
	# 保持经典的空中惯性移动（绝不转身铁律）
	if move_dir != 0:
		if move_dir != player.facing_direction:
			is_imbalance = true
			player.velocity.x = move_dir * player.data.walk_speed * player.data.imbalance_speed_factor
		else:
			player.velocity.x = move_dir * player.data.walk_speed
	else:
		player.movement.stop()
		
	player.move_and_slide()

# 这是一个预留的内部函数，用于实现瞬间伤害结算
func _trigger_instant_hit() -> void:
	# 提示：这里未来会写入开启 Hitbox 碰撞框的代码
	# 目前可以先打印一条日志，测试它在超低空时的响应速度
	print("【系统测试】空中斩击判定框已在第1帧瞬间绽放！")
