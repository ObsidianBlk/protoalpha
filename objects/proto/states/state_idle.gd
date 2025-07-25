extends ProtoState

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ACTION_NONE : StringName = &"None"
const ACTION_CHANGE : StringName = &"Change"

const FRAME_IDLE_A : int = 0
const FRAME_IDLE_B : int = 1

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var state_move : StringName = &""
@export var state_jump : StringName = &""
@export var state_climb : StringName = &""
@export var state_fall : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _weighted_action : WeightedRandomCollection = null

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_weighted_action = WeightedRandomCollection.new()
	_weighted_action.add_entry(ACTION_NONE, 1000.0)
	_weighted_action.add_entry(ACTION_CHANGE, 1.0)

# ------------------------------------------------------------------------------
# Virtual Methods
# ------------------------------------------------------------------------------
func enter(payload : Variant = null) -> void:
	if proto == null:
		pop()
		return
	
	var wep : Weapon = proto.get_weapon()
	if not wep.reloaded.is_connected(_on_reloaded):
		wep.reloaded.connect(_on_reloaded)
	
	proto.velocity = Vector2.ZERO
	if wep.is_triggered():
		proto.play_animation(ANIM_SHOOT_STAND)
	else:
		proto.play_animation(ANIM_IDLE_A)

func exit() -> void:
	if proto == null: return
	
	var wep : Weapon = proto.get_weapon()
	if wep == null: return
	
	if wep.reloaded.is_connected(_on_reloaded):
		wep.reloaded.disconnect(_on_reloaded)

func update(_delta : float) -> void:
	if proto == null: return
	if not proto.get_weapon().is_triggered():
		var action : StringName = _weighted_action.get_random()
		var cur_anim : StringName = proto.get_current_animation()
		if action == ACTION_CHANGE:
			proto.play_animation(ANIM_IDLE_B if cur_anim == ANIM_IDLE_A else ANIM_IDLE_A)

func physics_update(_delta : float) -> void:
	if proto == null: return
	if not proto.is_on_ladder():
		proto.velocity.y = proto.get_gravity().y
	else: proto.velocity.y = 0.0
	
	proto.move_and_slide()
	if not proto.is_on_surface():
		if not state_fall.is_empty():
			swap_to(state_fall)

func handle_input(event : InputEvent) -> void:
	if proto == null: return

	if event_one_of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		var move_direction : Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
		if not is_equal_approx(move_direction.y, 0.0) and proto.is_on_ladder():
			swap_to(state_climb)
		else:
			swap_to(state_move, move_direction)
	elif event.is_action_pressed(&"jump"):
		swap_to(state_jump)
	elif event.is_action(&"shoot"):
		var wep : Weapon = proto.get_weapon()
		if event.is_pressed():
			if wep.can_shoot():
				proto.play_animation(ANIM_SHOOT_STAND)
				wep.press_trigger(proto.get_parent())
		else:
			if proto.get_current_animation() == ANIM_SHOOT_STAND:
				proto.play_animation(ANIM_IDLE_A)
			wep.release_trigger()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_reloaded() -> void:
	if proto == null: return
	proto.play_animation(ANIM_IDLE_A)
