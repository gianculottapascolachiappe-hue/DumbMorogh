extends CharacterBody2D

# =========================================================
# MOVEMENT SETTINGS
# =========================================================
@export var speed: float = 200.0

@export var input_left: String = "move_left"
@export var input_right: String = "move_right"
@export var input_up: String = "move_up"
@export var input_down: String = "move_down"

var last_direction: Vector2 = Vector2.DOWN


# =========================================================
# COMBAT SETTINGS
# =========================================================
@export var attack_damage: int = 5
@export var attack_speed: float = 1.2  # seconds between attacks

var is_attacking: bool = false
var attack_timer: float = 0.0


# =========================================================
# ANIMATION
# =========================================================
@export var idle_anim: String = "idle"
@export var walk_anim: String = "walk"

var current_anim: String = ""


# =========================================================
# NODE REFERENCES
# =========================================================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine


# =========================================================
# INIT
# =========================================================
func _ready() -> void:
	state_machine.init(self)


# =========================================================
# MAIN LOOP
# =========================================================
func _physics_process(delta: float) -> void:
	state_machine.update(delta)
	move_and_slide()

	if is_attacking:
		handle_auto_attack(delta)


# =========================================================
# MOVEMENT
# =========================================================
func apply_movement(dir: Vector2) -> void:
	velocity = dir.normalized() * speed

	if dir != Vector2.ZERO:
		last_direction = dir


# =========================================================
# AUTO ATTACK SYSTEM
# =========================================================
func start_attack() -> void:
	var target = TargetManager.current_target

	if target == null:
		print("No target selected")
		return

	is_attacking = true
	attack_timer = 0.0
	print("Auto-attack started")


func stop_attack() -> void:
	is_attacking = false
	print("Auto-attack stopped")


func handle_auto_attack(delta: float) -> void:
	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_timer = attack_speed
		perform_attack()


func perform_attack() -> void:
	var target = TargetManager.current_target

	if target == null:
		stop_attack()
		return

	if target.has_method("take_damage"):
		target.take_damage(attack_damage)


# =========================================================
# INPUT
# =========================================================
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		start_attack()


# =========================================================
# ANIMATION SYSTEM
# =========================================================
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
