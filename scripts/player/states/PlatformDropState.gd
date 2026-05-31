# res://scripts/player/states/PlatformDropState.gd
extends State

class_name PlatformDropState

var regrab_cooldown: float = 0.0 # 新增：防重抓冷却计时器

func enter(msg: Dictionary = {}) -> void:
	player.animation.play("fall")
	player.global_position.y += 4.0
	# 接收来自悬挂状态的冷却时间（如果是从下蹲穿透来，默认是 0.0）
	regrab_cooldown = msg.get("regrab_cooldown", 0.0)

func update(delta: float) -> void:
	# 实时衰减冷却时间
	if regrab_cooldown > 0:
		regrab_cooldown -= delta

	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(state_machine.get_node("AirAttackState"))
		return
		
	if Input.is_action_just_pressed("ninjutsu"):
		state_machine.change_state(state_machine.get_node("AirNinjutsuState"))
		return

	# 【核心修改】：如果穿透中途玩家松开了方向下键
	if not Input.is_action_pressed("nav_down"):
		# 只有当防重抓保护盾消失后（<=0），才允许触发头顶吸附雷达
		if regrab_cooldown <= 0:
			var head_sensor = player.get_node("HeadSensor") as RayCast2D
			if head_sensor:
				head_sensor.force_raycast_update()
				if head_sensor.is_colliding() and head_sensor.get_collider().is_in_group("hanging_platform"):
					state_machine.change_state(state_machine.get_node("HangState"))
					return
		
		# 如果还在保护期内，或者头顶没有吊台，顺滑转入 FallState，并把残余的冷却时间传过去继续保护
		state_machine.change_state(player.fall_state, {"imbalance": false, "regrab_cooldown": regrab_cooldown})
		return

	if player.is_on_floor():
		if player.input.move_direction != 0:
			state_machine.change_state(player.run_state)
		else:
			state_machine.change_state(player.idle_state)
		return

func physics_update(_delta: float) -> void:
	var move_dir = player.input.move_direction
	if move_dir != 0:
		player.movement.move(move_dir)
		player.set_facing_direction(move_dir)
	else:
		player.movement.stop()
		
	if player.is_on_wall() and player.velocity.x * player.get_wall_normal().x <= 0:
		state_machine.change_state(state_machine.get_node("WallState"))
		return

	player.move_and_slide()
