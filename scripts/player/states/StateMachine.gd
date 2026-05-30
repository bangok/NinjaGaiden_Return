# res://scripts/player/states/StateMachine.gd
extends Node

class_name StateMachine

# 在检查器中直接指定初始状态节点
@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	# 1. 严格等待父节点 Player 完全准备好
	await owner.ready
	
	# 2. 自动化收集并绑定所有子状态
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.player = owner as Player
			child.state_machine = self

	# 3. 【企业级防错初始化】
	if initial_state:
		current_state = initial_state
	elif states.has("idlestate"):
		# 兜底：如果在检查器里忘拖了，代码自动抓取名为 IdleState 的子节点，保证不崩溃
		initial_state = states["idlestate"]
		current_state = initial_state
		push_warning("提示：你忘记在检查器中拖配置了，状态机已自动绑定 IdleState 兜底。")
	
	# 最终激活状态
	if current_state:
		current_state.enter()
	else:
		push_error("错误：StateMachine 无法找到任何可用的初始状态！")


func change_state(new_state: State, msg: Dictionary = {}) -> void:
	if not new_state or current_state == new_state:
		return
		
	if current_state:
		current_state.exit()
		
	current_state = new_state
	current_state.enter(msg)

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
