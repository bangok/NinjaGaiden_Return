# res://scripts/player/states/WallState.gd
extends State

class_name WallState

@export var wall_jump_push_force: float = 170.0
@export var wall_jump_height_factor: float = 0.7

# 【新增配置】：爬墙的移动速度
@export var climb_speed: float = 50.0

var is_casting: bool = false
var wall_normal_x: float = 0.0 

func enter(_msg: Dictionary = {}) -> void:
	is_casting = false
	player.velocity = Vector2.ZERO
	player.animation.play("wall_idle")
	
	if player.is_on_wall():
		wall_normal_x = player.get_wall_normal().x
		player.set_facing_direction(-wall_normal_x)

func update(_delta: float) -> void:
	if is_casting:
		var sprite = player.animation.sprite
		if (sprite.animation == "wall_ninjutsu" or sprite.animation == "wall_ninjutsu_backward") and not sprite.is_playing():
			is_casting = false
			player.animation.play("wall_idle")
		return

	# 1. 蹬墙跳 (保持不变)
	if Input.is_action_just_pressed("jump"):
		if player.input.move_direction == sign(wall_normal_x):
			player.velocity.x = wall_normal_x * wall_jump_push_force
			player.velocity.y = -player.data.jump_force * wall_jump_height_factor
			player.set_facing_direction(wall_normal_x)
			
			state_machine.change_state(player.jump_state, {"wall_jump": true})
			player.input.consume_jump() 
			return

	# 2. 墙上释放忍术 (保持不变)
	if Input.is_action_just_pressed("ninjutsu"):
		is_casting = true
		if player.input.move_direction == sign(wall_normal_x):
			player.animation.play("wall_ninjutsu_backward")
		else:
			player.animation.play("wall_ninjutsu")
		return

#func physics_update(_delta: float) -> void:
	## 依然牢牢吸附墙面，禁止左右位移
	#player.velocity.x = 0
	#
	## 【核心修改：上下攀爬逻辑】
	#if not is_casting:
		## 计算上下方向键的输入轴（按上为 -1，按下为 1，不按为 0）
		#var climb_dir = 0.0
		#if Input.is_action_pressed("nav_up"):
			#climb_dir -= 1.0
		#if Input.is_action_pressed("nav_down"):
			#climb_dir += 1.0
			#
		## 赋予垂直速度
		#player.velocity.y = climb_dir * climb_speed
		#
		## 【动画状态机微调】：根据有没有移动，智能切换攀爬与静止动画
		#if climb_dir != 0:
			#player.animation.play("wall_climb")
		#else:
			#player.animation.play("wall_idle")
	#else:
		## 释放忍术期间，强制静止悬停[cite: 5]
		#player.velocity.y = 0 
		#
	#player.move_and_slide()
#
	## 边缘与退出条件判定[cite: 5]
	#if not player.is_on_wall():
		## 极佳手感体验：如果往上爬出了墙顶，会自然切换到下落状态，此时按住前方向键可以直接翻上平台！[cite: 5]
		#state_machine.change_state(player.fall_state, {"imbalance": false})
		#return
		#
	#if player.is_on_floor():
		## 如果往下爬踩到了地面，自动恢复站立[cite: 5]
		#state_machine.change_state(player.idle_state)
		#return

func physics_update(_delta: float) -> void:
	# 依然牢牢吸附墙面，禁止左右位移
	player.velocity.x = 0
	
	var climb_dir = 0.0
	if not is_casting:
		if Input.is_action_pressed("nav_up"):
			climb_dir -= 1.0
		if Input.is_action_pressed("nav_down"):
			climb_dir += 1.0
			
		player.velocity.y = climb_dir * climb_speed
		
		if climb_dir != 0:
			player.animation.play("wall_climb")
		else:
			player.animation.play("wall_idle")
	else:
		player.velocity.y = 0 
		
	# 1. 【核心机制】：在执行移动前，悄悄记录下当前绝对安全的位置
	var safe_position = player.global_position
		
	player.move_and_slide()

	# 2. 【墙顶拦截防飘】：如果玩家正在往上爬，且由于到顶导致 move_and_slide 之后脱离了墙壁
	if climb_dir < 0 and not player.is_on_wall():
		# 瞬间把角色拉回到上一帧还在墙上的安全位置
		player.global_position = safe_position
		player.velocity.y = 0
		player.animation.play("wall_idle") # 强制切换回静止抓墙动画
		return # 【极其重要】直接结束函数，死死拦截掉后面切换到 FallState 的逻辑！

	# 3. 正常的边缘与退出条件判定（如下滑到底或者松手）
	if not player.is_on_wall():
		state_machine.change_state(player.fall_state, {"imbalance": false})
		return
		
	if player.is_on_floor():
		state_machine.change_state(player.idle_state)
		return
