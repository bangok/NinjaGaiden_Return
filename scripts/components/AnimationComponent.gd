extends Node

class_name AnimationComponent

var sprite: AnimatedSprite2D


func initialize(animated_sprite: AnimatedSprite2D) -> void:

	sprite = animated_sprite


func play(animation_name: String) -> void:

	if sprite.animation == animation_name \
	and sprite.is_playing():
		return

	sprite.play(animation_name)
