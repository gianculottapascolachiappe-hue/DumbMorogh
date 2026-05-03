extends CharacterBody2D


# =========================================================
# NODES / REFERENCES
# =========================================================
@onready var target_indicator: TextureRect = $TextureRect
@onready var sprite: AnimatedSprite2D = $EnemyAnimation
@onready var ai_state_machine: Node = $AIStateMachine


# =========================================================
# ANIMATION / DIRECTION
# =========================================================
@export var idle_anim: String = "idle"
@export var walk_anim: String = "walk"
@export var attack_anim: String = "attack"

var last_direction: Vector2 = Vector2.DOWN
var is_attacking: bool = false


# =========================================================
# STATS
# =========================================================
@export var max_health: int = 30
@export var move_speed: float = 80.0

var current_health: int
var is_dead: bool = false


# =========================================================
# COMBAT SETTINGS
# =========================================================
@export var attack_damage: int = 3
@export var attack_speed: float = 1.5
@export var attack_range: float = 40.0
@export var aggro_range: float = 120.0
@export var leash_distance: float = 200.0


# =========================================================
# COMBAT STATE
# =========================================================
var target: Node = null
var attack_timer: float = 0.0
var in_combat: bool = false


# =========================================================
# RETURN / RESET SYSTEM
# =========================================================
var spawn_position: Vector2
var is_returning: bool = false


# =========================================================
# DEBUG FLAGS (anti spam)
# =========================================================
var _last_target: Node = null
var _was_moving: bool = false
var _combat_logged: bool = false


# =========================================================
# INITIALIZATION
# =========================================================
func _ready() -> void:
	current_health = max_health

	ai_state_machine.init(self)

	spawn_position = global_position
	target = get_tree().get_first_node_in_group("player")

	if target_indicator:
		target_indicator.visible = false

	sprite.animation_finished.connect(_on_animation_finished)

	print("👹 Enemy spawned | HP:", current_health)


# =========================================================
# MAIN LOOP
# =========================================================
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	ai_state_machine.update(delta)

	update_aggro()

	if is_returning:
		handle_return()
	elif in_combat:
		handle_combat(delta)
	else:
		velocity = Vector2.ZERO

	# movement debug (ONLY on change)
	var moving := velocity.length() > 1.0
	if moving != _was_moving:
		_was_moving = moving
		if moving:
			print("🏃 Enemy started moving")
		else:
			print("🧍 Enemy stopped moving")

	if moving:
		last_direction = velocity.normalized()

	move_and_slide()


# =========================================================
# MOVEMENT (KEEP THIS)
# =========================================================
func apply_movement(dir: Vector2) -> void:
	velocity = dir.normalized() * move_speed

	if dir != Vector2.ZERO:
		last_direction = dir


# =========================================================
# AGGRO SYSTEM (EVENT ONLY)
# =========================================================
func update_aggro() -> void:
	if is_dead or in_combat or is_returning:
		return

	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")

		if target != _last_target:
			_last_target = target
			print("🎯 Enemy acquired target:", target)

		if target == null:
			return

	var dist := global_position.distance_to(target.global_position)

	if dist <= aggro_range:
		if not _combat_logged:
			_combat_logged = true
			print("👀 Enemy entered aggro range")
		enter_combat()


# =========================================================
# COMBAT STATE
# =========================================================
func enter_combat() -> void:
	if in_combat:
		return

	in_combat = true
	is_returning = false
	attack_timer = 0.0

	print("⚔️ Enemy entered combat")


func exit_combat() -> void:
	if not in_combat:
		return

	in_combat = false
	attack_timer = 0.0
	_combat_logged = false

	print("🛑 Enemy exited combat")


# =========================================================
# COMBAT LOOP
# =========================================================
func handle_combat(delta: float) -> void:
	var dist_from_spawn := global_position.distance_to(spawn_position)

	if dist_from_spawn > leash_distance:
		print("🏃 Enemy leash triggered")
		start_return()
		return

	if target == null or not is_instance_valid(target):
		print("❌ Enemy lost target")
		exit_combat()
		return

	handle_chase()
	handle_attack(delta)


# =========================================================
# CHASE
# =========================================================
func handle_chase() -> void:
	var dist := global_position.distance_to(target.global_position)

	if dist <= attack_range:
		velocity = Vector2.ZERO
		return

	var dir: Vector2 = (target.global_position - global_position).normalized()
	velocity = dir * move_speed


# =========================================================
# RETURN
# =========================================================
func start_return() -> void:
	if is_returning:
		return

	is_returning = true
	in_combat = false
	attack_timer = 0.0

	print("🏃 Enemy returning to spawn")


func handle_return() -> void:
	var dist := global_position.distance_to(spawn_position)

	if dist < 10.0:
		global_position = spawn_position
		finish_return()
		return

	var dir := (spawn_position - global_position).normalized()
	velocity = dir * move_speed


func finish_return() -> void:
	is_returning = false
	velocity = Vector2.ZERO
	current_health = max_health

	print("🔄 Enemy reset at spawn")


# =========================================================
# ATTACK SYSTEM (EVENT SAFE)
# =========================================================
func handle_attack(delta: float) -> void:
	if is_attacking:
		return

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
		print("❌ Attack aborted (invalid target)")
		return

	var dist := global_position.distance_to(target.global_position)

	if dist > attack_range:
		print("❌ Attack missed (out of range)")
		return

	is_attacking = true
	print("⚔️ Enemy attack START")

	play_animation(attack_anim, last_direction)


func apply_attack_damage() -> void:
	if target == null or not is_instance_valid(target):
		return

	var dist := global_position.distance_to(target.global_position)

	if dist > attack_range:
		print("❌ Attack hit frame missed (out of range)")
		return

	if target.has_method("take_damage"):
		print("💥 Enemy deals", attack_damage, "damage")
		target.take_damage(attack_damage)


func _on_animation_finished() -> void:
	if sprite.animation.begins_with("attack"):
		print("💢 Enemy attack finished")
		apply_attack_damage()
		is_attacking = false


# =========================================================
# DAMAGE SYSTEM
# =========================================================
func take_damage(amount: int) -> void:
	if is_returning or is_dead:
		return

	current_health = max(current_health - amount, 0)

	print("❤️ Enemy HP:", current_health)

	enter_combat()

	if current_health <= 0:
		die()


func die() -> void:
	if is_dead:
		return

	is_dead = true

	print("💀 Enemy died")

	exit_combat()

	if TargetManager.current_target == self:
		TargetManager.clear_target()

	queue_free()


# =========================================================
# TARGET VISUAL
# =========================================================
func set_targeted(value: bool) -> void:
	if target_indicator:
		target_indicator.visible = value


# =========================================================
# ANIMATION
# =========================================================
func play_animation(action: String, dir: Vector2) -> void:
	var anim = action + "_" + _get_direction_name(dir)

	if sprite.animation == anim:
		return

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
