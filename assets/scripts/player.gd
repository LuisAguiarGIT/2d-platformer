extends CharacterBody2D

const GRAVITY = 1000

@export var speed : int = 300
@export var jump : int = -400
@export var jump_horizontal : int = 100

enum State { Idle, Run, Jump, Falling }

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var current_state : State

func _ready() -> void:
	current_state = State.Idle

func _physics_process(delta: float) -> void:
	player_falling(delta)
	player_idle()
	player_run()
	player_jump(delta)

	move_and_slide()
	
	player_animations()
	player_flip()


func player_falling(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		if current_state == State.Jump and velocity.y > 0:
			current_state = State.Falling
		elif current_state != State.Jump:
			current_state = State.Falling

func player_idle() -> void:
	if is_on_floor():
		current_state = State.Idle;

func player_run() -> void:
	var direction := input_movement()
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if direction != 0 and is_on_floor():
		current_state = State.Run
		animated_sprite_2d.flip_h = false if direction > 0 else true

func player_animations():
	match current_state:
		State.Idle:
			animated_sprite_2d.play("idle")
		State.Run:
			animated_sprite_2d.play("run")
		State.Jump:
			animated_sprite_2d.play("jump")
		State.Falling:
			animated_sprite_2d.play("fall")

func player_jump(delta):
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump
		current_state = State.Jump
	
	if not is_on_floor() and current_state == State.Jump:
		var direction := input_movement()
		velocity.x += direction * jump_horizontal * delta

func player_flip() -> void:
	var direction := input_movement()
	if direction != 0:
		animated_sprite_2d.flip_h = direction < 0
		
func input_movement() -> float:
	return Input.get_axis("Left", "Right")
