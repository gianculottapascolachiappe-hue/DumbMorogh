extends CharacterBody2D

@export var speed: float = 200.0

@export var input_left: String = "move_left"
@export var input_right: String = "move_right"
@export var input_up: String = "move_up"
@export var input_down: String = "move_down"

@export var idle_anim: String = "idle"
@export var walk_anim: String = "walk"

var last_direction: Vector2 = Vector2.DOWN
var current_anim: String = ""

@onready var sprite: AnimatedSprite2D = $AnimateSprite2D
@onready var state_machine: Node = $StateMachine


func _ready() -> void:
	state_machine.init(self)


func _physics_process(delta: float) -> void:
	state_machine.update(delta)
	move_and_slide()


func apply_movement(dir: Vector2) -> void:
	velocity = dir.normalized() * speed
	if dir != Vector2.ZERO:
		last_direction = dir


func play_animation(action: String, dir: Vector2) -> void:
	var anim = action + "_" + _get_direction_name(dir)
	
	if anim == current_anim:
		return
	
	current_anim = anim
	sprite.play(anim)


func _get_direction_name(dir: Vector2) -> String:
	if dir == Vector2.ZERO:
		dir = Vector2.DOWN

	var angle = dir.angle()

	if angle >= -PI/8 and angle < PI/8:
		return "right"
	elif angle >= PI/8 and angle < 3*PI/8:
		return "down_right"
	elif angle >= 3*PI/8 and angle < 5*PI/8:
		return "down"
	elif angle >= 5*PI/8 and angle < 7*PI/8:
		return "down_left"
	elif angle >= 7*PI/8 or angle < -7*PI/8:
		return "left"
	elif angle >= -7*PI/8 and angle < -5*PI/8:
		return "up_left"
	elif angle >= -5*PI/8 and angle < -3*PI/8:
		return "up"
	elif angle >= -3*PI/8 and angle < -PI/8:
		return "up_right"

	return "down"
