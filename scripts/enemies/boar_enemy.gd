class_name BoarEnemy
extends CharacterBody3D

# gdlint: disable=max-returns

## Controls the first hostile primitive enemy.
##
## The boar idles near its spawn, detects one player through the `players`
## group, chases in the open greybox area, performs one validated melee hit,
## reacts to damage through HealthComponent, dies, and respawns at its spawn.

enum EnemyState {
	IDLE,
	CHASING,
	ATTACKING,
	HURT,
	RETURNING,
	DEAD,
}

@export_category("Identity")
@export var enemy_id: StringName = &"wild_boar"

@export_category("Targeting")
@export var player_group: StringName = &"players"
@export_range(1.0, 50.0, 0.5) var detection_range: float = 9.0
@export_range(1.0, 60.0, 0.5) var disengage_range: float = 13.0
@export_range(1.0, 80.0, 0.5) var maximum_leash_distance: float = 14.0
@export_range(0.1, 5.0, 0.1) var player_search_interval_seconds: float = 0.5

@export_category("Movement")
@export_range(0.1, 20.0, 0.1) var movement_speed: float = 3.2
@export_range(0.1, 50.0, 0.1) var movement_acceleration: float = 12.0
@export_range(0.1, 30.0, 0.1) var rotation_speed: float = 9.0
@export_range(0.05, 2.0, 0.05) var spawn_arrival_distance: float = 0.35

@export_category("Attack")
@export_range(0.1, 1000.0, 0.5) var attack_damage: float = 12.0
@export_range(0.5, 6.0, 0.1) var attack_stop_distance: float = 1.75
@export_range(0.5, 8.0, 0.1) var maximum_attack_hit_distance: float = 2.25
@export_range(0.05, 2.0, 0.05) var attack_windup_seconds: float = 0.25
@export_range(0.05, 2.0, 0.05) var attack_recovery_seconds: float = 0.3
@export_range(0.1, 10.0, 0.1) var attack_cooldown_seconds: float = 1.2
@export_range(0.05, 1.5, 0.05) var attack_lunge_distance: float = 0.45

@export_category("Rewards")
@export_range(0, 1000000, 1) var experience_reward: int = 40
@export_range(0, 1000000, 1) var gold_reward: int = 12
@export var loot_item_id: StringName = &"boar_tusk"
@export_range(1, 999, 1) var loot_quantity: int = 1
@export_range(0.0, 1.0, 0.01) var loot_drop_chance: float = 0.5
@export var loot_pickup_scene: PackedScene
@export var loot_spawn_offset: Vector3 = Vector3(0.0, 0.15, 0.0)
@export var loot_random_seed: int = 1337

@export_category("Reaction and Respawn")
@export_range(0.05, 2.0, 0.05) var hit_reaction_seconds: float = 0.18
@export_range(0.5, 60.0, 0.5) var respawn_delay_seconds: float = 5.0

@export_category("Required Nodes")
@export var health_component_path: NodePath = NodePath("HealthComponent")
@export var body_collision_path: NodePath = NodePath("CollisionShape3D")
@export var attack_pivot_path: NodePath = NodePath("AttackPivot")
@export var visual_root_path: NodePath = NodePath("AttackPivot/VisualRoot")
@export var hurtbox_path: NodePath = NodePath("Hurtbox")
@export var status_label_path: NodePath = NodePath("StatusLabel")
@export var attack_cooldown_timer_path: NodePath = NodePath("AttackCooldownTimer")
@export var hit_reaction_timer_path: NodePath = NodePath("HitReactionTimer")
@export var respawn_timer_path: NodePath = NodePath("RespawnTimer")

var _health_component: HealthComponent = null
var _body_collision: CollisionShape3D = null
var _attack_pivot: Node3D = null
var _visual_root: Node3D = null
var _hurtbox: Area3D = null
var _status_label: Label3D = null
var _attack_cooldown_timer: Timer = null
var _hit_reaction_timer: Timer = null
var _respawn_timer: Timer = null

var _player: Node3D = null
var _player_health: HealthComponent = null
var _state: EnemyState = EnemyState.IDLE
var _spawn_transform: Transform3D = Transform3D.IDENTITY
var _attack_pivot_rest_transform: Transform3D = Transform3D.IDENTITY
var _visual_root_rest_transform: Transform3D = Transform3D.IDENTITY
var _gravity: float = 9.8
var _player_search_time_remaining: float = 0.0
var _attack_tween: Tween = null
var _feedback_tween: Tween = null
var _attack_is_active: bool = false
var _is_dead: bool = false
var _experience_reward_granted: bool = false
var _gold_reward_granted: bool = false
var _quest_progress_reported: bool = false
var _loot_drop_processed: bool = false
var _loot_random: RandomNumberGenerator = RandomNumberGenerator.new()
var _setup_is_valid: bool = false


func _ready() -> void:
	_setup_is_valid = _resolve_required_nodes()
	if not _setup_is_valid:
		set_physics_process(false)
		return

	if disengage_range < detection_range:
		push_warning(
			"BoarEnemy disengage_range was smaller than detection_range. "
			+ "It has been raised to match detection_range."
		)
		disengage_range = detection_range

	if maximum_attack_hit_distance < attack_stop_distance:
		push_warning(
			"BoarEnemy maximum_attack_hit_distance was smaller than "
			+ "attack_stop_distance. It has been raised to match."
		)
		maximum_attack_hit_distance = attack_stop_distance

	_spawn_transform = global_transform
	_attack_pivot_rest_transform = _attack_pivot.transform
	_visual_root_rest_transform = _visual_root.transform
	_gravity = float(
		ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	)
	if loot_random_seed == 0:
		_loot_random.randomize()
	else:
		_loot_random.seed = loot_random_seed

	_health_component.health_changed.connect(_on_health_changed)
	_health_component.damage_taken.connect(_on_damage_taken)
	_health_component.died.connect(_on_died)
	_hit_reaction_timer.timeout.connect(_on_hit_reaction_timer_timeout)
	_respawn_timer.timeout.connect(_on_respawn_timer_timeout)

	_find_player()
	_set_state(EnemyState.IDLE)
	_update_status_label()


func _physics_process(delta: float) -> void:
	if not _setup_is_valid or _is_dead:
		return

	_refresh_player_reference(delta)
	_apply_gravity(delta)

	if not _hit_reaction_timer.is_stopped():
		_stop_horizontal_movement(delta)
		move_and_slide()
		return

	if _attack_is_active:
		_stop_horizontal_movement(delta)
		_face_player(delta)
		move_and_slide()
		return

	_update_state_from_distances()

	match _state:
		EnemyState.IDLE:
			_stop_horizontal_movement(delta)
		EnemyState.CHASING:
			_update_chase(delta)
		EnemyState.RETURNING:
			_update_return_to_spawn(delta)
		_:
			_stop_horizontal_movement(delta)

	move_and_slide()


func _exit_tree() -> void:
	_kill_tween(_attack_tween)
	_kill_tween(_feedback_tween)


func _update_state_from_distances() -> void:
	if not _has_living_player():
		if _horizontal_distance_to(_spawn_transform.origin) > spawn_arrival_distance:
			_set_state(EnemyState.RETURNING)
		else:
			_set_state(EnemyState.IDLE)
		return

	var distance_from_spawn: float = _horizontal_distance_to(
		_spawn_transform.origin
	)
	var distance_to_player: float = _horizontal_distance_to(
		_player.global_position
	)

	if distance_from_spawn > maximum_leash_distance:
		_set_state(EnemyState.RETURNING)
		return

	if distance_to_player > disengage_range:
		if distance_from_spawn > spawn_arrival_distance:
			_set_state(EnemyState.RETURNING)
		else:
			_set_state(EnemyState.IDLE)
		return

	if distance_to_player <= detection_range:
		_set_state(EnemyState.CHASING)


func _update_chase(delta: float) -> void:
	if not _has_living_player():
		_set_state(EnemyState.RETURNING)
		return

	var distance_to_player: float = _horizontal_distance_to(
		_player.global_position
	)

	if distance_to_player <= attack_stop_distance:
		_stop_horizontal_movement(delta)
		_face_player(delta)

		if _attack_cooldown_timer.is_stopped():
			_start_attack()
		return

	_move_toward_position(_player.global_position, delta)


func _update_return_to_spawn(delta: float) -> void:
	var distance_to_spawn: float = _horizontal_distance_to(
		_spawn_transform.origin
	)

	if distance_to_spawn <= spawn_arrival_distance:
		global_position.x = _spawn_transform.origin.x
		global_position.z = _spawn_transform.origin.z
		rotation.y = _spawn_transform.basis.get_euler().y
		_stop_horizontal_movement(delta)
		_set_state(EnemyState.IDLE)
		return

	_move_toward_position(_spawn_transform.origin, delta)


func _move_toward_position(target_position: Vector3, delta: float) -> void:
	var direction: Vector3 = target_position - global_position
	direction.y = 0.0

	if direction.length_squared() <= 0.0001:
		_stop_horizontal_movement(delta)
		return

	direction = direction.normalized()
	var desired_velocity: Vector3 = direction * movement_speed
	velocity.x = move_toward(
		velocity.x,
		desired_velocity.x,
		movement_acceleration * delta
	)
	velocity.z = move_toward(
		velocity.z,
		desired_velocity.z,
		movement_acceleration * delta
	)
	_rotate_toward_direction(direction, delta)


func _stop_horizontal_movement(delta: float) -> void:
	velocity.x = move_toward(
		velocity.x,
		0.0,
		movement_acceleration * delta
	)
	velocity.z = move_toward(
		velocity.z,
		0.0,
		movement_acceleration * delta
	)


func _rotate_toward_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() <= 0.0001:
		return

	var target_yaw: float = atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(
		rotation.y,
		target_yaw,
		minf(rotation_speed * delta, 1.0)
	)


func _face_player(delta: float) -> void:
	if not _has_living_player():
		return

	var direction: Vector3 = _player.global_position - global_position
	direction.y = 0.0
	_rotate_toward_direction(direction.normalized(), delta)


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = 0.0
		return

	velocity.y -= _gravity * delta


func _start_attack() -> void:
	if _attack_is_active or _is_dead or not _has_living_player():
		return

	_attack_is_active = true
	_set_state(EnemyState.ATTACKING)
	_kill_tween(_attack_tween)
	_attack_pivot.transform = _attack_pivot_rest_transform

	_attack_tween = create_tween()
	_attack_tween.set_trans(Tween.TRANS_QUAD)
	_attack_tween.set_ease(Tween.EASE_OUT)
	_attack_tween.tween_property(
		_attack_pivot,
		"position:z",
		_attack_pivot_rest_transform.origin.z - attack_lunge_distance,
		attack_windup_seconds
	)
	_attack_tween.tween_callback(Callable(self, "_apply_attack_damage"))
	_attack_tween.tween_property(
		_attack_pivot,
		"position:z",
		_attack_pivot_rest_transform.origin.z,
		attack_recovery_seconds
	)
	_attack_tween.tween_callback(Callable(self, "_finish_attack"))


func _apply_attack_damage() -> void:
	if _is_dead or not _attack_is_active or not _has_living_player():
		return

	var distance_to_player: float = _horizontal_distance_to(
		_player.global_position
	)
	if distance_to_player > maximum_attack_hit_distance:
		return

	if not _has_clear_attack_line():
		return

	_player_health.apply_damage(attack_damage, self)


func _finish_attack() -> void:
	if _attack_pivot != null:
		_attack_pivot.transform = _attack_pivot_rest_transform

	_attack_is_active = false

	if _is_dead:
		return

	_attack_cooldown_timer.start(attack_cooldown_seconds)
	_update_state_from_distances()


func _cancel_attack() -> void:
	_kill_tween(_attack_tween)
	_attack_tween = null
	_attack_is_active = false

	if _attack_pivot != null:
		_attack_pivot.transform = _attack_pivot_rest_transform


func _has_clear_attack_line() -> bool:
	if _player == null:
		return false

	var ray_start: Vector3 = global_position + Vector3.UP * 0.7
	var ray_end: Vector3 = _player.global_position + Vector3.UP * 0.8
	var exclusions: Array[RID] = [get_rid()]
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		ray_start,
		ray_end,
		1,
		exclusions
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(
		query
	)
	if result.is_empty():
		return false

	var collider_value: Variant = result.get("collider")
	return collider_value == _player


func _refresh_player_reference(delta: float) -> void:
	if _has_valid_player_reference():
		return

	_player_search_time_remaining -= delta
	if _player_search_time_remaining > 0.0:
		return

	_player_search_time_remaining = player_search_interval_seconds
	_find_player()


func _find_player() -> void:
	_player = null
	_player_health = null

	var player_node: Node = get_tree().get_first_node_in_group(player_group)
	if not player_node is Node3D:
		return

	_player = player_node as Node3D
	_player_health = _find_health_component(_player)

	if _player_health == null:
		push_warning(
			"BoarEnemy found a player group member without a HealthComponent."
		)


func _has_valid_player_reference() -> bool:
	return (
		_player != null
		and is_instance_valid(_player)
		and _player_health != null
		and is_instance_valid(_player_health)
	)


func _has_living_player() -> bool:
	return _has_valid_player_reference() and _player_health.is_alive()


func _find_health_component(start_node: Node) -> HealthComponent:
	if start_node is HealthComponent:
		return start_node as HealthComponent

	for child_node: Node in start_node.get_children():
		if child_node is HealthComponent:
			return child_node as HealthComponent

	return null


func _horizontal_distance_to(target_position: Vector3) -> float:
	var offset: Vector3 = target_position - global_position
	offset.y = 0.0
	return offset.length()


func _set_state(new_state: EnemyState) -> void:
	if _state == new_state:
		return

	_state = new_state
	_update_status_label()


func _update_status_label() -> void:
	if _status_label == null or _health_component == null:
		return

	_status_label.text = "Wild Boar\nHP: %d / %d\n%s" % [
		roundi(_health_component.get_current_health()),
		roundi(_health_component.get_maximum_health()),
		_get_state_display_name(),
	]


func _get_state_display_name() -> String:
	var display_name: String = "Unknown"

	match _state:
		EnemyState.IDLE:
			display_name = "Idle"
		EnemyState.CHASING:
			display_name = "Chasing"
		EnemyState.ATTACKING:
			display_name = "Attacking"
		EnemyState.HURT:
			display_name = "Hit"
		EnemyState.RETURNING:
			display_name = "Returning"
		EnemyState.DEAD:
			display_name = "Defeated"

	return display_name


func _play_hit_feedback() -> void:
	_kill_tween(_feedback_tween)
	_visual_root.transform = _visual_root_rest_transform

	_feedback_tween = create_tween()
	_feedback_tween.set_trans(Tween.TRANS_QUAD)
	_feedback_tween.set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_property(
		_visual_root,
		"scale",
		Vector3(1.12, 0.82, 1.12),
		0.06
	)
	_feedback_tween.tween_property(
		_visual_root,
		"scale",
		_visual_root_rest_transform.basis.get_scale(),
		maxf(hit_reaction_seconds - 0.06, 0.05)
	)


func _play_death_feedback() -> void:
	_kill_tween(_feedback_tween)
	_attack_pivot.transform = _attack_pivot_rest_transform
	_visual_root.transform = _visual_root_rest_transform

	_feedback_tween = create_tween()
	_feedback_tween.set_trans(Tween.TRANS_QUAD)
	_feedback_tween.set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_property(
		_attack_pivot,
		"rotation:z",
		deg_to_rad(82.0),
		0.3
	)


func _on_health_changed(
	_previous_health: float,
	_current_health: float,
	_maximum_health: float
) -> void:
	_update_status_label()


func _on_damage_taken(_amount: float, _source: Node) -> void:
	if _health_component == null or not _health_component.is_alive():
		return

	_cancel_attack()
	_set_state(EnemyState.HURT)
	_stop_horizontal_movement(1.0)
	_play_hit_feedback()
	_hit_reaction_timer.start(hit_reaction_seconds)

	if _attack_cooldown_timer.is_stopped():
		_attack_cooldown_timer.start(attack_cooldown_seconds)


func _on_died(source: Node) -> void:
	if _is_dead:
		return

	_is_dead = true
	_set_state(EnemyState.DEAD)
	_cancel_attack()
	velocity = Vector3.ZERO
	_attack_cooldown_timer.stop()
	_hit_reaction_timer.stop()
	_hurtbox.monitorable = false
	_body_collision.set_deferred("disabled", true)
	_award_experience_to_killing_player(source)
	_award_gold_to_killing_player(source)
	_report_quest_progress_to_killing_player(source)
	_try_spawn_loot_for_killing_player(source)
	_play_death_feedback()
	_respawn_timer.start(respawn_delay_seconds)


func _on_hit_reaction_timer_timeout() -> void:
	if _is_dead:
		return

	_visual_root.transform = _visual_root_rest_transform
	_update_state_from_distances()


func _on_respawn_timer_timeout() -> void:
	_is_dead = false
	_experience_reward_granted = false
	_gold_reward_granted = false
	_quest_progress_reported = false
	_loot_drop_processed = false
	global_transform = _spawn_transform
	velocity = Vector3.ZERO
	_attack_pivot.transform = _attack_pivot_rest_transform
	_visual_root.transform = _visual_root_rest_transform
	_body_collision.set_deferred("disabled", false)
	_hurtbox.monitorable = true
	_health_component.reset_health()
	_set_state(EnemyState.IDLE)
	_find_player()


func _award_experience_to_killing_player(source: Node) -> void:
	if _experience_reward_granted or experience_reward <= 0:
		return

	var progression_component: PlayerProgression = (
		_find_player_progression_from_source(source)
	)
	if progression_component == null:
		if source != null:
			push_warning(
				"BoarEnemy was defeated, but the killing source did not "
				+ "resolve to a player with PlayerProgression. No XP awarded."
			)
		return

	_experience_reward_granted = true
	var applied_experience: int = progression_component.add_experience(
		experience_reward
	)
	print(
		"Wild Boar reward: requested %d XP, applied %d XP."
		% [experience_reward, applied_experience]
	)


func _award_gold_to_killing_player(source: Node) -> void:
	if _gold_reward_granted or gold_reward <= 0:
		return

	_gold_reward_granted = true
	var wallet: PlayerWallet = _find_player_wallet_from_source(source)
	if wallet == null:
		push_warning(
			"BoarEnemy could not resolve the killing player's PlayerWallet. No gold awarded."
		)
		return

	var applied_gold: int = wallet.add_gold(gold_reward)
	print(
		"Wild Boar reward: requested %d gold, applied %d gold."
		% [gold_reward, applied_gold]
	)


func _try_spawn_loot_for_killing_player(source: Node) -> void:
	if _loot_drop_processed:
		return
	_loot_drop_processed = true

	if loot_drop_chance <= 0.0 or loot_item_id.is_empty() or loot_quantity <= 0:
		return
	if _loot_random.randf() >= loot_drop_chance:
		return
	if loot_pickup_scene == null:
		push_warning("BoarEnemy rolled loot but has no loot_pickup_scene configured.")
		return

	var player_root: Node = _find_player_root_from_source(source)
	if player_root == null:
		push_warning("BoarEnemy rolled loot but could not resolve the killing player.")
		return

	var pickup_node: Node = loot_pickup_scene.instantiate()
	if not pickup_node is WorldItemPickup:
		push_warning("BoarEnemy loot_pickup_scene root is not WorldItemPickup.")
		pickup_node.queue_free()
		return

	var pickup: WorldItemPickup = pickup_node as WorldItemPickup
	pickup.configure_pickup(loot_item_id, loot_quantity, player_root)
	var pickup_parent: Node = get_parent()
	if pickup_parent == null:
		pickup_parent = get_tree().current_scene
	if pickup_parent == null:
		push_warning("BoarEnemy could not find a parent for its loot pickup.")
		pickup.queue_free()
		return

	pickup_parent.add_child(pickup)
	pickup.global_position = global_position + loot_spawn_offset


func set_loot_random_seed(seed_value: int) -> void:
	loot_random_seed = seed_value
	if seed_value == 0:
		_loot_random.randomize()
	else:
		_loot_random.seed = seed_value


func _find_player_wallet_from_source(source: Node) -> PlayerWallet:
	var player_root: Node = _find_player_root_from_source(source)
	if player_root == null:
		return null

	for child_node: Node in player_root.get_children():
		if child_node is PlayerWallet:
			return child_node as PlayerWallet
	return null


func _report_quest_progress_to_killing_player(source: Node) -> void:
	if _quest_progress_reported or enemy_id.is_empty():
		return

	# The death callback is already protected by _is_dead. This second gate keeps
	# quest progress explicitly limited to one report per spawned boar life.
	_quest_progress_reported = true

	var quest_log: PlayerQuestLog = _find_player_quest_log_from_source(source)
	if quest_log == null:
		return

	var applied_progress: int = quest_log.record_objective_progress(enemy_id, 1)
	if applied_progress > 0:
		print(
			"Wild Boar quest progress: reported %s once."
			% enemy_id
		)


func _find_player_quest_log_from_source(source: Node) -> PlayerQuestLog:
	var player_root: Node = _find_player_root_from_source(source)
	if player_root == null:
		return null

	for child_node: Node in player_root.get_children():
		if child_node is PlayerQuestLog:
			return child_node as PlayerQuestLog

	push_warning(
		"Player group member '%s' has no PlayerQuestLog child."
		% player_root.name
	)
	return null


func _find_player_progression_from_source(
	source: Node
) -> PlayerProgression:
	var player_root: Node = _find_player_root_from_source(source)
	if player_root == null:
		return null

	for child_node: Node in player_root.get_children():
		if child_node is PlayerProgression:
			return child_node as PlayerProgression

	push_warning(
		"Player group member '%s' has no PlayerProgression child."
		% player_root.name
	)
	return null


func _find_player_root_from_source(source: Node) -> Node:
	if source == null or not is_instance_valid(source):
		return null

	var current_node: Node = source
	while current_node != null:
		if current_node.is_in_group(player_group):
			return current_node
		current_node = current_node.get_parent()

	return null


func _resolve_required_nodes() -> bool:
	var is_valid: bool = true

	var health_node: Node = get_node_or_null(health_component_path)
	if health_node is HealthComponent:
		_health_component = health_node as HealthComponent
	else:
		push_error("BoarEnemy is missing its HealthComponent.")
		is_valid = false

	var body_collision_node: Node = get_node_or_null(body_collision_path)
	if body_collision_node is CollisionShape3D:
		_body_collision = body_collision_node as CollisionShape3D
	else:
		push_error("BoarEnemy is missing its body CollisionShape3D.")
		is_valid = false

	var attack_pivot_node: Node = get_node_or_null(attack_pivot_path)
	if attack_pivot_node is Node3D:
		_attack_pivot = attack_pivot_node as Node3D
	else:
		push_error("BoarEnemy is missing AttackPivot.")
		is_valid = false

	var visual_node: Node = get_node_or_null(visual_root_path)
	if visual_node is Node3D:
		_visual_root = visual_node as Node3D
	else:
		push_error("BoarEnemy is missing VisualRoot.")
		is_valid = false

	var hurtbox_node: Node = get_node_or_null(hurtbox_path)
	if hurtbox_node is Area3D:
		_hurtbox = hurtbox_node as Area3D
	else:
		push_error("BoarEnemy is missing its Hurtbox Area3D.")
		is_valid = false

	var label_node: Node = get_node_or_null(status_label_path)
	if label_node is Label3D:
		_status_label = label_node as Label3D
	else:
		push_error("BoarEnemy is missing StatusLabel.")
		is_valid = false

	var cooldown_timer_node: Node = get_node_or_null(
		attack_cooldown_timer_path
	)
	if cooldown_timer_node is Timer:
		_attack_cooldown_timer = cooldown_timer_node as Timer
	else:
		push_error("BoarEnemy is missing AttackCooldownTimer.")
		is_valid = false

	var hit_timer_node: Node = get_node_or_null(hit_reaction_timer_path)
	if hit_timer_node is Timer:
		_hit_reaction_timer = hit_timer_node as Timer
	else:
		push_error("BoarEnemy is missing HitReactionTimer.")
		is_valid = false

	var respawn_timer_node: Node = get_node_or_null(respawn_timer_path)
	if respawn_timer_node is Timer:
		_respawn_timer = respawn_timer_node as Timer
	else:
		push_error("BoarEnemy is missing RespawnTimer.")
		is_valid = false

	return is_valid


func _kill_tween(tween: Tween) -> void:
	if tween != null and tween.is_valid():
		tween.kill()
