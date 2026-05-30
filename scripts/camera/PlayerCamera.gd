# res://scripts/camera/PlayerCamera.gd
extends Camera2D

class_name PlayerCamera

# 将其暴露在检查器中，方便以后在某些需要上下移动的特殊关卡（如爬塔）动态解锁
@export var lock_y: bool = true

# 记录场景开始时，摄像机应该保持的绝对垂直高度
var fixed_y: float = 0.0

func _ready() -> void:
	# 【核心机制】：断开与父节点（Player）的物理变换绑定
	# 开启后，摄像机虽然还是 Player 的子节点，但它的 global_position 将不再自动跟随父节点
	top_level = true
	
	# 记录初始的全局 Y 坐标
	fixed_y = global_position.y

func _physics_process(_delta: float) -> void:
	var target = get_parent()
	if target:
		# 1. 始终无缝跟随主角的水平 X 轴
		global_position.x = target.global_position.x
		
		# 2. 根据配置决定是否锁死 Y 轴
		if lock_y:
			global_position.y = fixed_y
		else:
			global_position.y = target.global_position.y
