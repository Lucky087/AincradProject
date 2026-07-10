class_name Interactable
extends StaticBody3D

## Base class for objects the player can target and interact with.
##
## Future NPCs, doors, chests, pickups, shops, quest objects, and floor
## teleporters can inherit from this class and override the methods below.

@export_multiline var interaction_prompt: String = "Press E to interact"


## Returns whether this object can currently be interacted with.
func is_interaction_available(_interactor: Node3D) -> bool:
	return true


## Returns the prompt shown while this object is targeted.
func get_interaction_prompt(_interactor: Node3D) -> String:
	return interaction_prompt


## Performs the interaction and returns optional text for the interaction UI.
func interact(_interactor: Node3D) -> String:
	push_warning(
		"Interactable '%s' does not override interact()." % name
	)
	return ""
