class_name DeathUI
extends CanvasLayer

## Presents the player death message, black fades, and respawn-protection label.

signal fade_to_black_finished
signal fade_from_black_finished

var _fade_tween: Tween = null

@onready var _death_root: Control = %DeathRoot
@onready var _black_overlay: ColorRect = %BlackOverlay
@onready var _death_message_container: CenterContainer = %DeathMessageContainer
@onready var _protection_label: Label = %ProtectionLabel


func _ready() -> void:
	reset_ui_immediately()


func _exit_tree() -> void:
	_kill_fade_tween()


func show_death_screen() -> void:
	_kill_fade_tween()
	_death_root.visible = true
	_death_message_container.visible = true
	_protection_label.visible = false
	_set_black_alpha(0.0)


func fade_to_black(duration_seconds: float) -> void:
	_kill_fade_tween()
	_death_root.visible = true
	_fade_tween = create_tween()
	_fade_tween.set_trans(Tween.TRANS_SINE)
	_fade_tween.set_ease(Tween.EASE_IN_OUT)
	_fade_tween.tween_property(
		_black_overlay,
		"color:a",
		1.0,
		maxf(duration_seconds, 0.01)
	)
	_fade_tween.tween_callback(Callable(self, "_emit_fade_to_black_finished"))


func prepare_for_fade_back() -> void:
	_death_message_container.visible = false
	_set_black_alpha(1.0)


func fade_from_black(duration_seconds: float) -> void:
	_kill_fade_tween()
	_death_root.visible = true
	_fade_tween = create_tween()
	_fade_tween.set_trans(Tween.TRANS_SINE)
	_fade_tween.set_ease(Tween.EASE_IN_OUT)
	_fade_tween.tween_property(
		_black_overlay,
		"color:a",
		0.0,
		maxf(duration_seconds, 0.01)
	)
	_fade_tween.tween_callback(Callable(self, "_emit_fade_from_black_finished"))


func show_respawn_protection() -> void:
	_death_root.visible = true
	_death_message_container.visible = false
	_set_black_alpha(0.0)
	_protection_label.visible = true


func hide_respawn_protection() -> void:
	_protection_label.visible = false
	if _black_overlay.color.a <= 0.001 and not _death_message_container.visible:
		_death_root.visible = false


func reset_ui_immediately() -> void:
	_kill_fade_tween()
	if _death_root == null:
		return
	_death_message_container.visible = false
	_protection_label.visible = false
	_set_black_alpha(0.0)
	_death_root.visible = false


func _emit_fade_to_black_finished() -> void:
	fade_to_black_finished.emit()


func _emit_fade_from_black_finished() -> void:
	fade_from_black_finished.emit()


func _set_black_alpha(alpha: float) -> void:
	var overlay_color: Color = _black_overlay.color
	overlay_color.a = clampf(alpha, 0.0, 1.0)
	_black_overlay.color = overlay_color


func _kill_fade_tween() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null
