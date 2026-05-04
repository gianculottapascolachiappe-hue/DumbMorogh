#Player.gd
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

	sprite.animation_finished.connect(_on_animation_finished)

	_log("🟢 Player ready HP: " + str(current_health))


# =========================================================
# MAIN LOOP
# =========================================================
func _physics_process(delta: float) -> void:

	_handle_input()
	_apply_movement()
	move_and_slide()

	player_state_machine.update(delta)

	current_target = TargetManager.get_target()

	_handle_attack_logic(delta)
	_debug_state_changes()


# =========================================================
# INPUT (movement ONLY affects facing)
# =========================================================
func _handle_input() -> void:
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if move_input != Vector2.ZERO:
		last_direction = move_input.normalized()


func _input(event: InputEvent) -> void:
	# ONLY TARGET SELECTION (NO ATTACK HERE)
	if event.is_action_pressed("attack"):
		var target = get_mouse_target()

		if target == null:
			_log("⚠️ No target under mouse")
			return

		TargetManager.set_target(target)
		_log("🎯 Target selected: " + str(target))


# =========================================================
# MOVEMENT
# =========================================================
func _apply_movement() -> void:
	velocity = move_input.normalized() * speed


# =========================================================
# ATTACK FLOW
# =========================================================
func _handle_attack_logic(delta: float) -> void:
	if current_target == null or not is_instance_valid(current_target):
		stop_attack()
		return

	if not is_attacking:
		attack_timer -= delta

		if attack_timer <= 0.0:
			_start_attack()


func _start_attack() -> void:
	if current_target == null:
		return

	var dist = global_position.distance_to(current_target.global_position)

	if dist > attack_range:
		return

	is_attacking = true
	attack_timer = attack_speed

	player_state_machine.change_state(player_state_machine.player_attack_state)

	_log("⚔️ Attack START → " + str(current_target.name))


func stop_attack() -> void:
	if is_attacking:
		_log("🛑 Attack stopped")

	is_attacking = false
	attack_timer = 0.0


# =========================================================
# DAMAGE RESOLUTION (called by animation end)
# =========================================================
func perform_attack() -> void:
	if current_target == null or not is_instance_valid(current_target):
		return

	var dist := global_position.distance_to(current_target.global_position)

	if dist > attack_range:
		print("📏 You are too far away from target | dist:", dist)
		return

	var to_target: Vector2 = (current_target.global_position - global_position).normalized()
	var facing: Vector2 = last_direction.normalized()

	if facing.dot(to_target) < 0.5:
		print("🧭 YOU ARE FACING THE WRONG DIRECTION!")

		# 🔥 FORCE RESET SO SYSTEM CAN RETRY
		is_attacking = false
		attack_timer = 0.0
		return

	print("⚔️ Attack landed →", current_target.name)

	if current_target.has_method("take_damage"):
		current_target.take_damage(attack_damage)


func _on_animation_finished() -> void:
	if sprite.animation.begins_with("attack"):
		perform_attack()
		is_attacking = false
		player_state_machine.change_state(player_state_machine.player_idle_state)

# =========================================================
# MOUSE TARGETING
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


# =========================================================
# DEBUG (EVENT BASED ONLY)
# =========================================================
func _debug_state_changes() -> void:
	if not debug_enabled:
		return

	if current_target != _last_target:
		print("🎯 Target →", current_target)
		_last_target = current_target

	if is_attacking != _last_attack_state:
		print("⚔️ Attacking →", is_attacking)
		_last_attack_state = is_attacking

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
