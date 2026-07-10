class_name PlayerProgression
extends Node

## Stores one player's current level and experience.
##
## Experience requirements use a deliberately simple linear formula:
## base_experience_per_level * current_level.

signal experience_changed(
	current_experience: int,
	experience_required_for_next_level: int,
	current_level: int
)
signal levelled_up(previous_level: int, current_level: int)

@export_category("Progression")
@export_range(1, 1000, 1) var starting_level: int = 1
@export_range(0, 100000000, 1) var starting_experience: int = 0
@export_range(1, 1000, 1) var maximum_level: int = 100
@export_range(1, 1000000, 1) var base_experience_per_level: int = 100

var _current_level: int = 1
var _current_experience: int = 0
var _experience_required_for_next_level: int = 100
var _is_initialized: bool = false


func _ready() -> void:
	_initialize_progression()


## Returns the player's current level.
func get_current_level() -> int:
	_ensure_initialized()
	return _current_level


## Returns experience carried within the current level.
func get_current_experience() -> int:
	_ensure_initialized()
	return _current_experience


## Returns the amount required to reach the next level.
## Returns zero when the player has reached the configured maximum level.
func get_experience_required_for_next_level() -> int:
	_ensure_initialized()
	return _experience_required_for_next_level


## Returns the configured maximum level.
func get_maximum_level() -> int:
	_ensure_initialized()
	return maximum_level


## Returns true when no further levels can be gained.
func is_at_maximum_level() -> bool:
	_ensure_initialized()
	return _current_level >= maximum_level


## Returns current-level progress as a value from 0.0 to 1.0.
func get_progress_ratio() -> float:
	_ensure_initialized()

	if is_at_maximum_level():
		return 1.0

	if _experience_required_for_next_level <= 0:
		return 0.0

	return clampf(
		float(_current_experience)
		/ float(_experience_required_for_next_level),
		0.0,
		1.0
	)


## Adds positive experience and returns the amount actually accepted.
##
## A large reward may advance several levels. Experience beyond the maximum
## level is discarded because there is no later level to progress toward.
func add_experience(amount: int) -> int:
	_ensure_initialized()

	if amount <= 0 or is_at_maximum_level():
		return 0

	var initial_level: int = _current_level
	var remaining_experience: int = amount
	var applied_experience: int = 0

	while remaining_experience > 0 and not is_at_maximum_level():
		var experience_needed: int = (
			_experience_required_for_next_level - _current_experience
		)

		if experience_needed <= 0:
			_advance_one_level()
			continue

		var experience_for_current_level: int = mini(
			remaining_experience,
			experience_needed
		)
		_current_experience += experience_for_current_level
		remaining_experience -= experience_for_current_level
		applied_experience += experience_for_current_level

		if _current_experience >= _experience_required_for_next_level:
			_advance_one_level()

	if applied_experience > 0:
		experience_changed.emit(
			_current_experience,
			_experience_required_for_next_level,
			_current_level
		)

	if _current_level > initial_level:
		var debug_message: String = (
			"Player gained %d XP and levelled from Level %d to Level %d. "
			+ "Current XP: %d / %d."
		) % [
			applied_experience,
			initial_level,
			_current_level,
			_current_experience,
			_experience_required_for_next_level,
		]
		print(debug_message)

	return applied_experience


## Calculates the requirement for a supplied level.
## Keeping the formula in one method makes it easy to replace later.
func calculate_experience_required_for_level(level: int) -> int:
	var safe_level: int = maxi(level, 1)
	var safe_base_experience: int = maxi(base_experience_per_level, 1)
	return safe_base_experience * safe_level


func _initialize_progression() -> void:
	maximum_level = maxi(maximum_level, 1)
	starting_level = clampi(starting_level, 1, maximum_level)
	starting_experience = maxi(starting_experience, 0)
	base_experience_per_level = maxi(base_experience_per_level, 1)

	_current_level = starting_level
	_current_experience = starting_experience
	_update_experience_requirement()
	_normalize_starting_experience()
	_is_initialized = true


func _normalize_starting_experience() -> void:
	while (
		_current_level < maximum_level
		and _current_experience >= _experience_required_for_next_level
	):
		_current_experience -= _experience_required_for_next_level
		_current_level += 1
		_update_experience_requirement()

	if _current_level >= maximum_level:
		_current_level = maximum_level
		_current_experience = 0
		_experience_required_for_next_level = 0


func _advance_one_level() -> void:
	if _current_level >= maximum_level:
		return

	var previous_level: int = _current_level
	_current_level += 1
	_current_experience = 0
	_update_experience_requirement()

	levelled_up.emit(previous_level, _current_level)


func _update_experience_requirement() -> void:
	if _current_level >= maximum_level:
		_experience_required_for_next_level = 0
		return

	_experience_required_for_next_level = (
		calculate_experience_required_for_level(_current_level)
	)


func _ensure_initialized() -> void:
	if not _is_initialized:
		_initialize_progression()
