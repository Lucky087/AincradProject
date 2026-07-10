class_name PlayerWallet
extends Node

## Owns one player's non-negative gold balance.
##
## Other systems request changes through add_gold() and spend_gold(). SaveManager
## coordinates persistence through the component's public save-data methods.

signal gold_changed(previous_gold: int, current_gold: int, change_amount: int)

@export_category("New Game Defaults")
@export_range(0, 1000000000, 1) var starting_gold: int = 0

var _current_gold: int = 0


func _ready() -> void:
	_current_gold = maxi(starting_gold, 0)


## Returns the current non-negative gold balance.
func get_current_gold() -> int:
	return _current_gold


## Adds positive gold and returns the amount actually added.
func add_gold(amount: int) -> int:
	if amount <= 0:
		if amount < 0:
			push_warning("PlayerWallet cannot add a negative gold amount.")
		return 0

	var previous_gold: int = _current_gold
	_current_gold = mini(_current_gold + amount, 1000000000)
	var added_gold: int = _current_gold - previous_gold
	if added_gold > 0:
		gold_changed.emit(previous_gold, _current_gold, added_gold)
	return added_gold


## Returns whether the player can afford the requested non-negative amount.
func can_afford(amount: int) -> bool:
	return amount >= 0 and _current_gold >= amount


## Spends exactly amount gold and returns whether the purchase succeeded.
func spend_gold(amount: int) -> bool:
	if amount < 0:
		push_warning("PlayerWallet cannot spend a negative gold amount.")
		return false
	if amount == 0:
		return true
	if not can_afford(amount):
		return false

	var previous_gold: int = _current_gold
	_current_gold -= amount
	gold_changed.emit(previous_gold, _current_gold, -amount)
	return true


## Returns stable wallet data for SaveManager.
func get_save_data() -> Dictionary:
	return {"current_gold": _current_gold}


## Restores wallet data. Missing or invalid data safely becomes zero gold.
func load_save_data(data: Dictionary) -> void:
	var restored_gold: int = 0
	if data.has("current_gold"):
		var saved_value: Variant = data["current_gold"]
		if saved_value is int or saved_value is float:
			restored_gold = maxi(int(saved_value), 0)
		else:
			push_warning("PlayerWallet expected saved current_gold to be numeric; using 0.")
	else:
		push_warning("PlayerWallet found no saved current_gold; using 0.")

	var previous_gold: int = _current_gold
	_current_gold = restored_gold
	gold_changed.emit(previous_gold, _current_gold, _current_gold - previous_gold)
