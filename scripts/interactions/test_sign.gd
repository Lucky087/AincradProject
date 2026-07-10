class_name TestSign
extends Interactable

## Simple reusable sign used to test interaction messages.

@export_multiline var sign_message: String = (
	"The road ahead leads toward the first field."
)


func interact(_interactor: Node3D) -> String:
	return sign_message
