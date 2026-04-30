extends CharacterBody2D

@export var max_health: int = 30
var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Enemy HP:", current_health)

	if current_health <= 0:
		die()

func die() -> void:
	print("Enemy died")
	queue_free()
