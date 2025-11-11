extends CharacterBody2D
class_name CharacterActor2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal weapon_fired()
signal weapon_reloaded()
signal animation_finished(animation_name : StringName)
signal dead()
signal request_state(state : StringName, payload : Variant)


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var alive : bool = true:						set=set_alive
@export var flip_h : bool = false:						set=flip
@export var animation_tree : AnimationTree = null:		set=set_animation_tree
@export var ladder_detector : LadderDetector = null:	set=set_ladder_detector
@export var weapon : Weapon = null:						set=set_weapon
@export var sound_sheet : SoundSheet = null

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_alive(a : bool) -> void:
	if a != alive:
		alive = a
		if not alive:
			dead.emit()

func set_animation_tree(at : AnimationTree) -> void:
	if at != animation_tree:
		_DisconnectAnimationTree()
		animation_tree = at
		_ConnectAnimationTree()

func set_ladder_detector(ld : LadderDetector) -> void:
	if ld != ladder_detector:
		_DisconnectLadderDetector()
		ladder_detector = ld
		_ConnectLadderDetector()

func set_weapon(w : Weapon) -> void:
	if weapon != w:
		_DisconnectWeapon()
		weapon = w
		_ConnectWeapon()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectAnimationTree() -> void:
	if animation_tree == null: return
	if not animation_tree.animation_finished.is_connected(_on_anim_tree_animation_finished):
		animation_tree.animation_finished.connect(_on_anim_tree_animation_finished)

func _DisconnectAnimationTree() -> void:
	if animation_tree == null: return
	if animation_tree.animation_finished.is_connected(_on_anim_tree_animation_finished):
		animation_tree.animation_finished.disconnect(_on_anim_tree_animation_finished)


func _ConnectWeapon() -> void:
	if weapon == null: return
	if not weapon.fired.is_connected(_on_actor_weapon_fired):
		weapon.fired.connect(_on_actor_weapon_fired)
	if not weapon.reloaded.is_connected(_on_actor_weapon_reloaded):
		weapon.reloaded.connect(_on_actor_weapon_reloaded)

func _DisconnectWeapon() -> void:
	if weapon == null: return
	if weapon.fired.is_connected(_on_actor_weapon_fired):
		weapon.fired.disconnect(_on_actor_weapon_fired)
	if weapon.reloaded.is_connected(_on_actor_weapon_reloaded):
		weapon.reloaded.disconnect(_on_actor_weapon_reloaded)


func _ConnectLadderDetector() -> void:
	if ladder_detector == null: return
	if not ladder_detector.ladder_entered.is_connected(_on_ladder_entered):
		ladder_detector.ladder_entered.connect(_on_ladder_entered)
	if not ladder_detector.ladder_exited.is_connected(_on_ladder_exited):
		ladder_detector.ladder_exited.connect(_on_ladder_exited)

func _DisconnectLadderDetector() -> void:
	if ladder_detector == null: return
	if ladder_detector.ladder_entered.is_connected(_on_ladder_entered):
		ladder_detector.ladder_entered.disconnect(_on_ladder_entered)
	if ladder_detector.ladder_exited.is_connected(_on_ladder_exited):
		ladder_detector.ladder_exited.disconnect(_on_ladder_exited)

# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------
func spawn_at(spawn_position : Vector2, _spawn_payload : Dictionary = {}) -> void:
	global_position = spawn_position

func hide_sprite(_hide : bool) -> void:
	pass

func die() -> void:
	if alive:
		alive = false

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func flip(enable : bool) -> void:
	flip_h = enable

func is_flipped() -> bool:
	return flip_h

func is_on_ladder() -> bool:
	if ladder_detector != null:
		return ladder_detector.is_on_ladder()
	return false

func is_on_surface() -> bool:
	return is_on_floor() or is_on_ladder()

func is_dead() -> bool:
	return not alive

func set_tree_param(param : String, value : Variant) -> void:
	if animation_tree == null: return
	animation_tree.set(param, value)

func get_tree_param(param : String) -> Variant:
	if animation_tree != null:
		return animation_tree.get(param)
	return null

func is_tree_param(param : String, value : Variant) -> bool:
	if animation_tree != null:
		var tree_val : Variant = get_tree_param(param)
		if typeof(tree_val) == typeof(value):
			return tree_val == value
	return false

# ------------------------------------------------------------------------------
# "Virtual" Handler Methods
# ------------------------------------------------------------------------------
func _on_actor_weapon_fired() -> void:
	weapon_fired.emit()

func _on_actor_weapon_reloaded() -> void:
	weapon_reloaded.emit()

func _on_anim_tree_animation_finished(anim_name : StringName) -> void:
	animation_finished.emit(anim_name)

func _on_ladder_entered() -> void:
	pass

func _on_ladder_exited() -> void:
	pass
