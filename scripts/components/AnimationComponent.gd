# res://scripts/components/AnimationComponent.gd
extends Node

class_name AnimationComponent

var sprite: AnimatedSprite2D

func initialize(animated_sprite: AnimatedSprite2D) -> void:
	sprite = animated_sprite

func play(animation_name: String) -> void:
	if not sprite:
		return
		
	# 【企业级容灾】安全检测：如果在动画资源库里根本找不到这个名字，则拦截并打印警告，不执行播放
	if not sprite.sprite_frames.has_animation(animation_name):
		push_warning("【动画组件警告】尝试播放不存在的动画: '" + animation_name + "'，请检查 AnimatedSprite2D 资源配置。")
		return
		
	# 状态检查：如果当前正在播放该动画，则不重复触发
	if sprite.animation == animation_name and sprite.is_playing():
		return
		
	sprite.play(animation_name)

# 视觉翻转接口
func flip_sprite(direction: float) -> void:
	if not sprite:
		return
	sprite.flip_h = (direction < 0)
