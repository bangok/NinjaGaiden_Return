# res://scripts/player/states/SwordDashState.gd
extends State

class_name SwordDashState

# 突进速度倍率（你可以后期移到 PlayerData 里配置）
var dash_speed_multiplier: float = 2.5

func enter(_msg: Dictionary = {}) -> void:
	player.animation.play("sword_dash")
	
	# 给一个向前面朝方向的瞬间爆发速度
	player.velocity.x = player.facing_direction * player.data.walk_speed * dash_speed_multiplier
	
	# 【核心空战手感】：如果在空中触发，强制清除 Y 轴速度，实现无视重力的滞空突进
	if not player.is_on_floor():
		player.velocity.y = 0.0

func update(_delta: float) -> void:
	var sprite = player.animation.sprite
	# 动画播放完毕后，自动结束剑术动作
	if sprite.animation == "sword_dash" and not sprite.is_playing():
		if player.is_on_floor():
			state_machine.change_state(player.idle_state)
		else:
			# 结束后在空中自然恢复下落
			state_machine.change_state(player.fall_state, {"imbalance": false})

func physics_update(_delta: float) -> void:
	# 持续维持突进极速，禁止玩家中途变向
	player.velocity.x = player.facing_direction * player.data.walk_speed * dash_speed_multiplier
	
	if not player.is_on_floor():
		player.velocity.y = 0.0 # 持续锁死重力
		
	player.move_and_slide()
