extends CharacterBody2D

@onready var target_indicator: TextureRect = $TextureRect

# STATS
@export var max_health: int = 30
@export var move_speed: float = 80.0
var current_health: int
var is_dead: bool = false

# COMBAT
@export var attack_damage: int = 3
@export var attack_speed: float = 1.5
@export var attack_range: float = 40.0
@export var aggro_range: float = 120.0
@export var leash_distance: float = 200.0

var target: Node = null
var attack_timer: float = 0.0
var in_combat: bool = false

# RETURN SYSTEM
var spawn_position: Vector2
var is_returning: bool = false

# INIT
func _ready() -> void:
	current_health = max_health
	spawn_position = global_position
	target = get_tree().get_first_node_in_group("player")

	if target_indicator:
		target_indicator.visible = false

# MAIN LOOP
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	update_aggro()

	if is_returning:
		handle_return()
	elif in_combat:
		handle_combat(delta)
	else:
		velocity = Vector2.ZERO

	move_and_slide()

# AGGRO
func update_aggro() -> void:
	if is_dead or in_combat or is_returning:
		return

	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")
		if target == null:
			return

	var dist := global_position.distance_to(target.global_position)

	if dist <= aggro_range:
		enter_combat()

# COMBAT STATE
func enter_combat() -> void:
	if in_combat:
		return

	in_combat = true
	is_returning = false
	attack_timer = 0.0

	print(name, "entered combat")

func exit_combat() -> void:
	if not in_combat:
		return

	in_combat = false
	attack_timer = 0.0

	print(name, "exited combat")

# COMBAT LOOP
func handle_combat(delta: float) -> void:
	var dist_from_spawn := global_position.distance_to(spawn_position)

	if dist_from_spawn > leash_distance:
		start_return()
		return

	if target == null or not is_instance_valid(target):
		exit_combat()
		return

	handle_chase()
	handle_attack(delta)

# CHASE
func handle_chase() -> void:
	var dist := global_position.distance_to(target.global_position)

	if dist <= attack_range:
		velocity = Vector2.ZERO
		return

	var dir: Vector2 = (target.global_position - global_position).normalized()
	velocity = dir * move_speed

# RETURN SYSTEM
func start_return() -> void:
	if is_returning:
		return

	is_returning = true
	in_combat = false
	attack_timer = 0.0

	print(name, "is evading attacks")
	print(name, "is returning to spawn")

func handle_return() -> void:
	var dist := global_position.distance_to(spawn_position)

	if dist < 10.0:
		global_position = spawn_position
		finish_return()
		return

	var dir: Vector2 = (spawn_position - global_position).normalized()
	velocity = dir * move_speed

func finish_return() -> void:
	is_returning = false
	velocity = Vector2.ZERO
	current_health = max_health

	print(name, "returned to spawn")

# ATTACK
func handle_attack(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return

	var dist := global_position.distance_to(target.global_position)

	if dist > attack_range:
		return

	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_timer = attack_speed
		perform_attack()

func perform_attack() -> void:
	if target == null or not is_instance_valid(target):
		return

	var dist := global_position.distance_to(target.global_position)

	if dist > attack_range:
		return

	if target.has_method("take_damage"):
		target.take_damage(attack_damage)

# DAMAGE
func take_damage(amount: int) -> void:
	if is_returning:
		print(name, "is evading (no damage)")
		return

	if current_health <= 0:
		return

	current_health = max(current_health - amount, 0)

	print(name, "HP:", current_health)

	enter_combat()

	if current_health == 0:
		die()

func die() -> void:
	if is_dead:
		return

	is_dead = true

	print(name, "died")

	exit_combat()

	if TargetManager.current_target == self:
		TargetManager.clear_target()

	queue_free()

# TARGET VISUAL
func set_targeted(value: bool) -> void:
	if target_indicator:
		target_indicator.visible = value
