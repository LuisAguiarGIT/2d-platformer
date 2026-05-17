extends CharacterBody2D

@export var patrol_points : Node
@export var speed : int = 1500
@export var wait_time : int = 3

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

const GRAVITY = 1000
const JUMP_VELOCITY = -400.0

enum State { Idle, Run }
var current_state : State
var direction : Vector2 = Vector2.LEFT
var number_of_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var current_point_position : int
var can_run : bool

func _ready():
	if patrol_points:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
			
		if number_of_points > 0:
			current_point = point_positions[current_point_position]
	else:
		print("No patrol points")

	timer.wait_time = wait_time
	current_state = State.Idle

func _physics_process(delta: float) -> void:
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_run(delta)
	move_and_slide()
	enemy_animations()


func enemy_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func enemy_idle(delta : float) -> void:
	if not can_run:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.Idle

func enemy_run(delta: float) -> void:
	if point_positions.is_empty():
		return
	
	if not can_run:
		return
	
	if abs(position.x - current_point.x) > 0.5:
		velocity.x = direction.x * speed * delta
		current_state = State.Run
	else:
		current_point_position += 1
	
		if current_point_position >= number_of_points:
			current_point_position = 0
		
		current_point = point_positions[current_point_position]
		
		if current_point.x > position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
		
		can_run = false
		timer.start()
		
	animated_sprite_2d.flip_h = direction.x > 0

func enemy_animations():
	if current_state == State.Idle and not can_run:
		animated_sprite_2d.play("idle")
	elif current_state == State.Run and can_run:
		animated_sprite_2d.play("run")

func _on_timer_timeout() -> void:
	can_run = true
