class_name HealthComponent
extends Node

## Stores and changes health for one actor.
##
## This component is intentionally independent from player, enemy, combat,
## animation, UI, saving, and networking code.

signal health_changed(
	previous_health: float,
	current_health: float,
	maximum_health: float
)
signal damage_taken(amount: float, source: Node)
signal health_restored(amount: float, source: Node)
signal died(source: Node)

@export_category("Health")
@export_range(1.0, 100000.0, 1.0) var maximum_health: float = 100.0
@export var start_at_maximum_health: bool = true
@export_range(0.0, 100000.0, 1.0) var starting_health: float = 100.0
@export var is_invulnerable: bool = false

var _current_health: float = 0.0
var _is_initialized: bool = false


func _ready() -> void:
	_initialize_health()


## Returns the actor's current health.
func get_current_health() -> float:
	_ensure_initialized()
	return _current_health


## Returns the actor's configured maximum health.
func get_maximum_health() -> float:
	_ensure_initialized()
	return maximum_health


## Returns current health as a value from 0.0 to 1.0.
func get_health_ratio() -> float:
	_ensure_initialized()
	return _current_health / maximum_health


## Returns true while the actor has more than zero health.
func is_alive() -> bool:
	_ensure_initialized()
	return _current_health > 0.0


## Applies positive damage and returns the amount actually removed.
func apply_damage(amount: float, source: Node = null) -> float:
	_ensure_initialized()

	if amount <= 0.0 or is_invulnerable or not is_alive():
		return 0.0

	var previous_health: float = _current_health
	_current_health = clampf(_current_health - amount, 0.0, maximum_health)
	var applied_damage: float = previous_health - _current_health

	health_changed.emit(previous_health, _current_health, maximum_health)
	damage_taken.emit(applied_damage, source)

	if _current_health <= 0.0:
		died.emit(source)

	return applied_damage


## Restores positive health and returns the amount actually restored.
func restore_health(amount: float, source: Node = null) -> float:
	_ensure_initialized()

	if amount <= 0.0 or not is_alive():
		return 0.0

	var previous_health: float = _current_health
	_current_health = clampf(_current_health + amount, 0.0, maximum_health)
	var restored_amount: float = _current_health - previous_health

	if restored_amount <= 0.0:
		return 0.0

	health_changed.emit(previous_health, _current_health, maximum_health)
	health_restored.emit(restored_amount, source)
	return restored_amount


## Restores the actor to maximum health, including after death.
func reset_health() -> void:
	_ensure_initialized()

	var previous_health: float = _current_health
	_current_health = maximum_health

	if not is_equal_approx(previous_health, _current_health):
		health_changed.emit(previous_health, _current_health, maximum_health)


func _initialize_health() -> void:
	maximum_health = maxf(maximum_health, 1.0)

	if start_at_maximum_health:
		_current_health = maximum_health
	else:
		_current_health = clampf(starting_health, 0.0, maximum_health)

	_is_initialized = true


func _ensure_initialized() -> void:
	if not _is_initialized:
		_initialize_health()
