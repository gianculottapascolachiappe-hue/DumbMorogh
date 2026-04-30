extends CharacterBody2D

# =========================================================
# MOVEMENT
# =========================================================
@export var speed: float = 200.0

@export var input_left: String = "move_left"
@export var input_right: String = "move_right"
@export var input_up: String = "move_up"
@export var input_down: String = "move_down"

var last_direction: Vector2 = Vector2.DOWN


# =========================================================
# HEALTH
# =========================================================
@export var max_health: int = 100
var current_health: int = 0
var is_dead: bool = false


# =========================================================
# COMBAT (ATTACK)
# =========================================================
@export var attack_damage: int = 5
@export var attack_speed: float = 1.2

var is_attacking: bool = false
var attack_timer: float = 0.0
var current_attack_target: Node = null
var combat_state := {
	"in_combat": false,
	"combat_timer": 0.0,
	"combat_timeout": 5.0
}

# =========================================================
# COMBAT STATE
# =========================================================
var in_combat: bool = false
@export var combat_timeout: float = 5.0
var combat_timer: float = 0.0


# =========================================================
# ANIMATION
# =========================================================
@export var idle_anim: String = "idle"
@export var walk_anim: String = "walk"

var current_anim: String = ""


# =========================================================
# NODES
# =========================================================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine


# =========================================================
# LIFECYCLE
# =========================================================
func _ready() -> void:
	current_health = max_health
	state_machine.init(self)


func _physics_process(delta: float) -> void:
	state_machine.update(delta)
	move_and_slide()

	if is_attacking:
		handle_auto_attack(delta)

	if in_combat:
		handle_combat_state(delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		start_attack()


# =========================================================
# MOVEMENT
# =========================================================
func apply_movement(dir: Vector2) -> void:
	velocity = dir.normalized() * speed

	if dir != Vector2.ZERO:
		last_direction = dir


# =========================================================
# HEALTH
# =========================================================
func take_damage(amount: int) -> void:
	if is_dead:
		return

	CombatUtils.enter_combat(self, combat_state)

	current_health -= amount
	current_health = max(current_health, 0)

	print("Player HP:", current_health)

	if current_health == 0:
		die()


func die() -> void:
	is_dead = true
	current_health = 0

	print("Player died")

	stop_attack()
	velocity = Vector2.ZERO


# =========================================================
# COMBAT STATE
# =========================================================
func on_enter_combat() -> void:
	print("Player entered combat")


func on_exit_combat() -> void:
	stop_attack()
	print("Player exited combat")


func handle_combat_state(delta: float) -> void:
	combat_timer -= delta

	combat_state.combat_timer -= delta

	if combat_state.combat_timer <= 0.0:
		CombatUtils.exit_combat(self, combat_state)


# =========================================================
# ATTACK SYSTEM
# =========================================================
func start_attack() -> void:
	var target = TargetManager.current_target

	if target == null:
		return

	CombatUtils.enter_combat(self, combat_state)

	current_attack_target = target
	is_attacking = true
	attack_timer = 0.0

	print("Auto-attack started on:", target.name)


func handle_auto_attack(delta: float) -> void:
	var target = TargetManager.current_target

	if target != current_attack_target:
		stop_attack()
		return

	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_timer = attack_speed
		perform_attack()


func perform_attack() -> void:
	var target = TargetManager.current_target

	if target == null:
		stop_attack()
		return

	if not is_instance_valid(target):
		stop_attack()
		return

	if target.has_method("take_damage"):
		target.take_damage(attack_damage)


func stop_attack() -> void:
	is_attacking = false
	current_attack_target = null
	print("Auto-attack stopped")


# =========================================================
# ANIMATION
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
