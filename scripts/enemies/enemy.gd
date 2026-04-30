extends CharacterBody2D

# =========================================================
# HEALTH
# =========================================================
@export var max_health: int = 30
var current_health: int = 0


# =========================================================
# COMBAT (ATTACK)
# =========================================================
@export var attack_damage: int = 3
@export var attack_speed: float = 1.5

var is_attacking: bool = false
var attack_timer: float = 0.0
var target: Node = null
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
# LIFECYCLE
# =========================================================
func _ready() -> void:
	current_health = max_health


func _physics_process(delta: float) -> void:
	if is_attacking:
		handle_auto_attack(delta)

	if in_combat:
		handle_combat_state(delta)


# =========================================================
# HEALTH
# =========================================================
func take_damage(amount: int) -> void:
	if current_health <= 0:
		return

	CombatUtils.enter_combat(self, combat_state)

	current_health -= amount
	current_health = max(current_health, 0)

	print(name, "HP:", current_health)

	if current_health == 0:
		die()


func die() -> void:
	print("Enemy died")

	stop_attack()

	if TargetManager.current_target == self:
		TargetManager.clear_target()

	queue_free()


# =========================================================
# COMBAT STATE
# =========================================================
func on_enter_combat() -> void:
	print(name, "entered combat")

	is_attacking = true
	attack_timer = 0.0

	if target == null:
		target = get_tree().get_first_node_in_group("player")


func on_exit_combat() -> void:
	stop_attack()
	print(name, "exited combat")


func handle_combat_state(delta: float) -> void:
	combat_timer -= delta

	if combat_timer <= 0.0:
		CombatUtils.exit_combat(self, combat_state)


# =========================================================
# ATTACK SYSTEM
# =========================================================
func handle_auto_attack(delta: float) -> void:
	if target == null:
		stop_attack()
		return

	# stop if player dead
	if target.has_method("is_dead") and target.is_dead:
		stop_attack()
		return

	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_timer = attack_speed
		perform_attack()


func perform_attack() -> void:
	if target == null:
		return

	if target.has_method("take_damage"):
		target.take_damage(attack_damage)


func stop_attack() -> void:
	is_attacking = false
	target = null
	print(name, "stopped attacking")
