class_name SaveManagerService
extends Node

# gdlint: disable=max-returns

## Coordinates versioned JSON saving and loading for the local prototype.
##
## The manager does not own player state. It finds the current player safely,
## asks existing components for their save data, and restores data through those
## components' public load interfaces.

signal status_message_requested(message: String)
signal save_completed(save_path: String)
signal load_completed(save_path: String)

const SAVE_FILE_PATH: String = "user://savegame.json"
const SAVE_VERSION: int = 3
const OLDEST_SUPPORTED_SAVE_VERSION: int = 1
const PLAYER_GROUP: StringName = &"players"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.echo:
			return

	if event.is_action_pressed(&"save_game"):
		save_game()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"load_game"):
		load_game()
		get_viewport().set_input_as_handled()


## Collects current player data and writes it to user://savegame.json.
func save_game() -> bool:
	var player: Node3D = _find_player()
	if player == null:
		_report_failure(
			"Player could not be found",
			"SaveManager could not find a Node3D in the 'players' group."
		)
		return false

	var health_component: HealthComponent = _find_health_component(player)
	var progression_component: PlayerProgression = _find_progression_component(player)
	var quest_log: PlayerQuestLog = _find_quest_log(player)
	var inventory: PlayerInventory = _find_inventory(player)
	var wallet: PlayerWallet = _find_wallet(player)
	if not _validate_required_components(
		health_component, progression_component, quest_log, inventory, wallet, "saved"
	):
		return false

	var save_data: Dictionary = {
		"save_version": SAVE_VERSION,
		"player":
		{
			"position":
			{
				"x": player.global_position.x,
				"y": player.global_position.y,
				"z": player.global_position.z,
			},
			"current_health": health_component.get_current_health(),
			"maximum_health": health_component.get_maximum_health(),
		},
		"progression": progression_component.get_save_data(),
		"quests": quest_log.get_save_data(),
		"inventory": inventory.get_save_data(),
		"wallet": wallet.get_save_data(),
	}

	var json_text: String = JSON.stringify(save_data, "\t")
	if json_text.is_empty():
		_report_failure("Game could not be saved", "SaveManager produced an empty JSON string.")
		return false

	var save_file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file == null:
		_report_failure(
			"Game could not be saved",
			(
				"SaveManager could not open '%s' for writing. Error: %s"
				% [SAVE_FILE_PATH, error_string(FileAccess.get_open_error())]
			)
		)
		return false

	save_file.store_string(json_text)
	save_file.flush()
	var write_error: Error = save_file.get_error()
	save_file.close()

	if write_error != OK:
		_report_failure(
			"Game could not be saved",
			(
				"SaveManager failed while writing '%s'. Error: %s"
				% [SAVE_FILE_PATH, error_string(write_error)]
			)
		)
		return false

	print("Game saved to: %s" % ProjectSettings.globalize_path(SAVE_FILE_PATH))
	status_message_requested.emit("Game saved")
	save_completed.emit(SAVE_FILE_PATH)
	return true


## Reads, validates, and restores user://savegame.json.
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		_report_failure("No save file found", "SaveManager found no file at '%s'." % SAVE_FILE_PATH)
		return false

	var save_file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if save_file == null:
		_report_failure(
			"Save file could not be read",
			(
				"SaveManager could not open '%s' for reading. Error: %s"
				% [SAVE_FILE_PATH, error_string(FileAccess.get_open_error())]
			)
		)
		return false

	var json_text: String = save_file.get_as_text()
	var read_error: Error = save_file.get_error()
	save_file.close()

	if read_error != OK:
		_report_failure(
			"Save file could not be read",
			(
				"SaveManager failed while reading '%s'. Error: %s"
				% [SAVE_FILE_PATH, error_string(read_error)]
			)
		)
		return false

	if json_text.strip_edges().is_empty():
		_report_failure(
			"Save file could not be read",
			"SaveManager found an empty save file at '%s'." % SAVE_FILE_PATH
		)
		return false

	var json_parser: JSON = JSON.new()
	var parse_error: Error = json_parser.parse(json_text)
	if parse_error != OK:
		_report_failure(
			"Save file could not be read",
			(
				"SaveManager could not parse JSON at line %d: %s"
				% [
					json_parser.get_error_line(),
					json_parser.get_error_message(),
				]
			)
		)
		return false

	var parsed_data: Variant = json_parser.data
	if not parsed_data is Dictionary:
		_report_failure(
			"Save file could not be read", "SaveManager expected the JSON root to be a Dictionary."
		)
		return false

	var save_data: Dictionary = parsed_data
	var save_version: int = _read_int(save_data, "save_version", -1, "save root")
	if save_version < OLDEST_SUPPORTED_SAVE_VERSION or save_version > SAVE_VERSION:
		_report_failure(
			"Save version is not supported",
			(
				"SaveManager supports versions %d through %d but found %d."
				% [OLDEST_SUPPORTED_SAVE_VERSION, SAVE_VERSION, save_version]
			)
		)
		return false

	var player: Node3D = _find_player()
	if player == null:
		_report_failure(
			"Player could not be found",
			"SaveManager could not find a Node3D in the 'players' group."
		)
		return false

	var health_component: HealthComponent = _find_health_component(player)
	var progression_component: PlayerProgression = _find_progression_component(player)
	var quest_log: PlayerQuestLog = _find_quest_log(player)
	var inventory: PlayerInventory = _find_inventory(player)
	var wallet: PlayerWallet = _find_wallet(player)
	if not _validate_required_components(
		health_component, progression_component, quest_log, inventory, wallet, "loaded"
	):
		return false

	var player_data: Dictionary = _read_dictionary(save_data, "player", "save root")
	var progression_data: Dictionary = _read_dictionary(save_data, "progression", "save root")
	var quest_data: Dictionary = _read_dictionary(save_data, "quests", "save root")
	var inventory_data: Dictionary = {}
	if save_version >= 2:
		inventory_data = _read_dictionary(save_data, "inventory", "save root")
	else:
		push_warning(
			"SaveManager is loading version 1 without inventory data; starter defaults will be used."
		)

	var wallet_data: Dictionary = {}
	if save_version >= 3:
		wallet_data = _read_dictionary(save_data, "wallet", "save root")
	else:
		push_warning(
			"SaveManager is loading an older save without wallet data; zero gold will be used."
		)

	_restore_player_position(player, player_data)
	health_component.load_save_data(player_data)
	progression_component.load_save_data(progression_data)
	quest_log.load_save_data(quest_data)
	inventory.load_save_data(inventory_data)
	wallet.load_save_data(wallet_data)

	print("Game loaded from: %s" % ProjectSettings.globalize_path(SAVE_FILE_PATH))
	status_message_requested.emit("Game loaded")
	load_completed.emit(SAVE_FILE_PATH)
	return true


## Returns the virtual save path used by this manager.
func get_save_path() -> String:
	return SAVE_FILE_PATH


func _find_player() -> Node3D:
	var player_node: Node = get_tree().get_first_node_in_group(PLAYER_GROUP)
	if player_node is Node3D:
		return player_node as Node3D

	return null


func _find_health_component(player: Node) -> HealthComponent:
	for child_node: Node in player.get_children():
		if child_node is HealthComponent:
			return child_node as HealthComponent

	return null


func _find_progression_component(player: Node) -> PlayerProgression:
	for child_node: Node in player.get_children():
		if child_node is PlayerProgression:
			return child_node as PlayerProgression

	return null


func _find_quest_log(player: Node) -> PlayerQuestLog:
	for child_node: Node in player.get_children():
		if child_node is PlayerQuestLog:
			return child_node as PlayerQuestLog

	return null


func _find_inventory(player: Node) -> PlayerInventory:
	for child_node: Node in player.get_children():
		if child_node is PlayerInventory:
			return child_node as PlayerInventory

	return null


func _find_wallet(player: Node) -> PlayerWallet:
	for child_node: Node in player.get_children():
		if child_node is PlayerWallet:
			return child_node as PlayerWallet

	return null


func _validate_required_components(
	health_component: HealthComponent,
	progression_component: PlayerProgression,
	quest_log: PlayerQuestLog,
	inventory: PlayerInventory,
	wallet: PlayerWallet,
	operation_past_tense: String
) -> bool:
	var missing_components: PackedStringArray = []
	if health_component == null:
		missing_components.append("HealthComponent")
	if progression_component == null:
		missing_components.append("PlayerProgression")
	if quest_log == null:
		missing_components.append("PlayerQuestLog")
	if inventory == null:
		missing_components.append("PlayerInventory")
	if wallet == null:
		missing_components.append("PlayerWallet")

	if missing_components.is_empty():
		return true

	_report_failure(
		"Game could not be %s" % operation_past_tense,
		"SaveManager is missing required player components: %s" % ", ".join(missing_components)
	)
	return false


func _restore_player_position(player: Node3D, player_data: Dictionary) -> void:
	var position_data: Dictionary = _read_dictionary(player_data, "position", "player data")
	if position_data.is_empty():
		return

	var fallback_position: Vector3 = player.global_position
	var restored_position: Vector3 = Vector3(
		_read_float(position_data, "x", fallback_position.x, "player position"),
		_read_float(position_data, "y", fallback_position.y, "player position"),
		_read_float(position_data, "z", fallback_position.z, "player position")
	)

	if player is CharacterBody3D:
		var character_body: CharacterBody3D = player as CharacterBody3D
		character_body.velocity = Vector3.ZERO

	player.global_position = restored_position


func _read_dictionary(data: Dictionary, key: String, context: String) -> Dictionary:
	if not data.has(key):
		push_warning(
			"SaveManager found no '%s' Dictionary in %s; current values remain." % [key, context]
		)
		return {}

	var value: Variant = data[key]
	if value is Dictionary:
		return value

	push_warning(
		(
			"SaveManager expected '%s' in %s to be a Dictionary; current values remain."
			% [key, context]
		)
	)
	return {}


func _read_int(data: Dictionary, key: String, fallback: int, context: String) -> int:
	if not data.has(key):
		push_warning("SaveManager found no '%s' value in %s; using %d." % [key, context, fallback])
		return fallback

	var value: Variant = data[key]
	if value is int or value is float:
		return int(value)

	push_warning(
		"SaveManager expected '%s' in %s to be numeric; using %d." % [key, context, fallback]
	)
	return fallback


func _read_float(data: Dictionary, key: String, fallback: float, context: String) -> float:
	if not data.has(key):
		push_warning(
			"SaveManager found no '%s' value in %s; using %.3f." % [key, context, fallback]
		)
		return fallback

	var value: Variant = data[key]
	if value is int or value is float:
		return float(value)

	push_warning(
		"SaveManager expected '%s' in %s to be numeric; using %.3f." % [key, context, fallback]
	)
	return fallback


func _report_failure(user_message: String, developer_message: String) -> void:
	push_warning(developer_message)
	status_message_requested.emit(user_message)
