class_name GoldUI
extends CanvasLayer

## Displays the player's wallet balance and refreshes through wallet signals.

@export var wallet_path: NodePath

var _wallet: PlayerWallet = null
var _gold_label: Label = null
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		return

	_wallet.gold_changed.connect(_on_gold_changed)
	_refresh_gold()


func _refresh_gold() -> void:
	if _wallet == null or _gold_label == null:
		return
	_gold_label.text = "Gold: %d" % _wallet.get_current_gold()


func _on_gold_changed(
	_previous_gold: int,
	_current_gold: int,
	_change_amount: int
) -> void:
	_refresh_gold()


func _resolve_required_nodes() -> bool:
	var wallet_node: Node = get_node_or_null(wallet_path)
	if wallet_node is PlayerWallet:
		_wallet = wallet_node as PlayerWallet
	else:
		push_error("GoldUI could not find PlayerWallet at: %s" % wallet_path)
		return false

	var label_node: Node = get_node_or_null("GoldPanel/MarginContainer/GoldLabel")
	if label_node is Label:
		_gold_label = label_node as Label
	else:
		push_error("GoldUI is missing GoldLabel.")
		return false

	return true
