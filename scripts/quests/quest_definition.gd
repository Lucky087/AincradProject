class_name QuestDefinition
extends Resource

## Defines reusable quest content without storing one player's runtime state.

@export_category("Identity")
@export var quest_id: StringName = &""
@export var title: String = "Untitled Quest"
@export_multiline var description: String = ""

@export_category("Objective")
@export var objective_id: StringName = &""
@export var objective_label: String = "Complete objective"
@export_range(1, 1000000, 1) var objective_target: int = 1

@export_category("Reward")
@export_range(0, 100000000, 1) var experience_reward: int = 0


## Returns whether the definition contains the minimum required data.
func is_valid_definition() -> bool:
	return (
		not quest_id.is_empty()
		and not title.is_empty()
		and not objective_id.is_empty()
		and objective_target > 0
	)


## Formats the objective for HUD and dialogue use.
func get_objective_text(current_progress: int) -> String:
	var safe_progress: int = clampi(
		current_progress,
		0,
		maxi(objective_target, 1)
	)
	return "%s: %d / %d" % [
		objective_label,
		safe_progress,
		maxi(objective_target, 1),
	]
