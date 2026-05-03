extends CharacterBody2D

# =========================================================
# MOVEMENT
# =========================================================
@export var speed: float = 200.0
var move_input: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN

# =========================================================
# HEALTH
# =========================================================
@export var max_health: int = 100
var current_health: int
var is_dead: bool = false

# =========================================================
# COMBAT
# =========================================================
@export var attack_damage: int = 5
@export var attack_speed: float = 1.2
@export var attack_range: float = 40.0

var _last_range_fail: bool = false
var _last_facing_fail: bool = false
var is_attacking: bool = false
var attack_timer: float = 0.0
var current_target: Node = null

# =========================================================
# DEBUG (NO SPAM)
# =========================================================
@export var debug_enabled: bool = true

var _last_target: Node = null
var _last_attack_state: bool = false
var _last_velocity: Vector2 = Vector2.ZERO


# =========================================================
# NODES
# =========================================================
@onready var sprite: AnimatedSprite2D = $PlayerAnimation
@onready var player_state_machine: Node = $PlayerStateMachine


# =========================================================
# INIT
# =========================================================
func _ready() -> void:
	current_health = max_health
	player_state_machine.init(self)

	_log("🟢 Player ready HP: " + str(current_health))


# =========================================================
# MAIN LOOP
# =========================================================
func _physics_process(delta: float) -> void:

	_handle_input()
	_apply_movement()
	move_and_slide()

	player_state_machine.update(delta)

	# SINGLE SOURCE OF TRUTH
	current_target = TargetManager.get_target()

	# AUTO ATTACK START
	if current_target != null and not is_attacking:
		start_attack()

	if is_attacking:
		handle_auto_attack(delta)

	_debug_state_changes()


# =========================================================
# INPUT
# =========================================================
func get_mouse_target() -> Node:
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_point(query, 1)

	if result.size() > 0:
		return result[0].collider

	return null


func _handle_input() -> void:
	move_input = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	if move_input != Vector2.ZERO:
		last_direction = move_input.normalized()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		var target = get_mouse_target()

		if target == null:
			_log("⚠️ No target under mouse")
			return

		TargetManager.set_target(target)


# =========================================================
# MOVEMENT
# =========================================================
func _apply_movement() -> void:
	velocity = move_input.normalized() * speed


# =========================================================
# COMBAT
# =========================================================
func start_attack() -> void:
	var target = TargetManager.current_target

	if target == null:
		_log("⚠️ start_attack failed (no target)")
		return

	current_target = target
	is_attacking = true
	attack_timer = 0.0

	_log("⚔️ Attack START → " + target.name)


func handle_auto_attack(delta: float) -> void:
	if current_target == null or not is_instance_valid(current_target):
		_log("❌ Invalid target → stop attack")
		stop_attack()
		return

	if TargetManager.current_target != current_target:
		_log("❌ Target changed → stop attack")
		stop_attack()
		return

	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_timer = attack_speed
		perform_attack()


func perform_attack() -> void:
	if current_target == null or not is_instance_valid(current_target):
		return

	var dist := global_position.distance_to(current_target.global_position)

	# =========================================================
	# RANGE CHECK DEBUG (edge-triggered)
	# =========================================================
	if dist > attack_range:
		if not _last_range_fail:
			print("📏 You are too far away from target | dist:", dist)
			_last_range_fail = true
		return
	else:
		_last_range_fail = false

	# =========================================================
	# FACING CHECK DEBUG (edge-triggered)
	# =========================================================
	var to_target: Vector2 = (current_target.global_position - global_position).normalized()
	var facing: Vector2 = last_direction.normalized()

	if facing.dot(to_target) < 0.5:
		if not _last_facing_fail:
			print("🧭 You are facing the wrong direction!")
			_last_facing_fail = true
		return
	else:
		_last_facing_fail = false

	# =========================================================
	# SUCCESS CASE (optional but useful)
	# =========================================================
	print("⚔️ Attack landed →", current_target.name)

	if current_target.has_method("take_damage"):
		current_target.take_damage(attack_damage)


func stop_attack() -> void:
	is_attacking = false
	current_target = null
	attack_timer = 0.0

	_log("🛑 Attack stopped")


# =========================================================
# HEALTH
# =========================================================
func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health = max(current_health - amount, 0)

	print("💥 Player took", amount, "damage | HP:", current_health)

	enter_combat()

	if current_health <= 0:
		die()


func die() -> void:
	is_dead = true
	current_health = 0

	stop_attack()
	velocity = Vector2.ZERO

	print("💀 Player died")


# =========================================================
# COMBAT HOOKS
# =========================================================
func enter_combat() -> void:
	pass


func exit_combat() -> void:
	stop_attack()


# =========================================================
# DEBUG SYSTEM (EVENT-BASED ONLY)
# =========================================================
func _debug_state_changes() -> void:
	if not debug_enabled:
		return

	# TARGET CHANGE
	if current_target != _last_target:
		print("🎯 Target →", current_target)
		_last_target = current_target

	# ATTACK STATE CHANGE
	if is_attacking != _last_attack_state:
		print("⚔️ Attacking →", is_attacking)
		_last_attack_state = is_attacking

	# MOVEMENT CHANGE (only meaningful change)
	if velocity.distance_to(_last_velocity) > 5.0:
		print("🏃 Velocity →", velocity)
		_last_velocity = velocity


func _log(msg: String) -> void:
	if debug_enabled:
		print(msg)


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
