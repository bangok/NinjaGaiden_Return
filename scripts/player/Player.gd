extends CharacterBody2D

class_name Player

@export var data: PlayerData

@onready var input: InputComponent = $Components/InputComponent
@onready var movement: MovementComponent = $Components/MovementComponent
@onready var animation: AnimationComponent = $Components/AnimationComponent

@onready var state_machine: StateMachine = $StateMachine

@onready var idle_state: IdleState = $StateMachine/IdleState
@onready var run_state: RunState = $StateMachine/RunState
@onready var jump_state: JumpState = $StateMachine/JumpState
@onready var fall_state: FallState = $StateMachine/FallState

@onready var animated_sprite: AnimatedSprite2D = \
	$Visual/AnimatedSprite2D


func _ready():

	movement.initialize(self)

	animation.initialize(
		animated_sprite
	)

	_initialize_states()

	state_machine.initialize(idle_state)


func _process(delta):

	input.update_input()

	input.update_buffer(delta)

	state_machine.update(delta)



	
func _physics_process(delta):

	movement.apply_gravity(delta)

	state_machine.physics_update(delta)

	move_and_slide()

	position = position.round()


func _initialize_states():

	var states = [
		idle_state,
		run_state,
		jump_state,
		fall_state
	]

	for state in states:

		state.player = self

		state.state_machine = state_machine
