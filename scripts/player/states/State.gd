# res://scripts/player/states/State.gd
extends Node

class_name State

# 预留给子类使用的公共引用
var player: Player
var state_machine: StateMachine

# 【核心修复】让基类中的 enter 明确声明允许接收一个可选的 Dictionary 参数
# _msg 前面带下划线是 Godot 规范，代表基类中暂不显式使用它，避免触发“未使用的变量”警告
func enter(_msg: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
