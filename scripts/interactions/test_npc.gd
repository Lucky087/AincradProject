class_name TestNpc
extends Interactable

## Primitive placeholder NPC that returns one line of dialogue.

@export var speaker_name: String = "Town Guide"
@export_multiline var dialogue_line: String = (
	"Welcome! The city gate is still being built."
)


func interact(_interactor: Node3D) -> String:
	return "%s: %s" % [speaker_name, dialogue_line]
