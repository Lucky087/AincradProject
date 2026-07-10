class_name TestChest
extends Interactable

## One-use primitive chest for testing stateful interactions.

@export_multiline var opened_message: String = (
	"You opened the chest. It is empty for now."
)
@export_range(0.05, 2.0, 0.05) var opening_duration_seconds: float = 0.35
@export_range(1.0, 150.0, 1.0) var lid_open_angle_degrees: float = 105.0

var _is_open: bool = false
var _lid_pivot: Node3D = null


func _ready() -> void:
	var lid_node: Node = get_node_or_null("LidPivot")
	if lid_node is Node3D:
		_lid_pivot = lid_node as Node3D
	else:
		push_error(
			"TestChest requires a Node3D child named 'LidPivot'."
		)


func is_interaction_available(_interactor: Node3D) -> bool:
	return not _is_open


func interact(_interactor: Node3D) -> String:
	if _is_open:
		return "The chest is already open."

	_is_open = true
	_open_lid()
	return opened_message


func _open_lid() -> void:
	if _lid_pivot == null:
		push_warning("The chest opened, but its lid node is missing.")
		return

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		_lid_pivot,
		"rotation:x",
		deg_to_rad(lid_open_angle_degrees),
		opening_duration_seconds
	)
