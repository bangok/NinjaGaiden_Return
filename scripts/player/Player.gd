# res://scripts/player/Player.gd
extends CharacterBody2D

class_name Player

@export var data: PlayerData

# 组件解耦引用
@onready var input: InputComponent = $Components/InputComponent
@onready var movement: MovementComponent = $Components/MovementComponent
@onready var animation: AnimationComponent = $Components/AnimationComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $Visual/AnimatedSprite2D

# 状态节点引用
@onready var idle_state: IdleState = $StateMachine/IdleState
@onready var run_state: RunState = $StateMachine/RunState
@onready var jump_state: JumpState = $StateMachine/JumpState
@onready var fall_state: FallState = $StateMachine/FallState

# 【规范化数据】面向方向：1.0 为右，-1.0 为左
var facing_direction: float = 1.0

func _ready() -> void:
	movement.initialize(self)
	animation.initialize(animated_sprite)
	# 状态机此时会在其内部的 _ready() 中自动、安全地处理初始状态的进入

func _process(delta: float) -> void:
	input.update_input() 
	input.update_buffer(delta) 
	state_machine.update(delta) 

func _physics_process(delta: float) -> void:
	movement.apply_gravity(delta) 
	state_machine.physics_update(delta) 
	
	# 还原你之前保留的像素完美对齐代码
	position = position.round() 

# 【企业级公共接口】唯一改变朝向的方法
# 任何状态、任何组件想让玩家转头，必须调用此方法
func set_facing_direction(direction: float) -> void:
	if direction == 0:
		return
		
	# 规范化方向值为 1 或 -1
	facing_direction = 1.0 if direction > 0 else -1.0
	
	# 通过视觉组件通知贴图翻转，而不是在物理组件里硬编码
	animation.flip_sprite(facing_direction)
