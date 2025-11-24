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
var _weapon_signals : Array[Game.SigDef] = [
	Game.SigDef.new(&"reloaded", _on_reloaded)
]

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
	if actor == null:
		pop()
		return
	
	var wep : Weapon = actor.get_weapon()
	Game.Connect_Signals(wep, _weapon_signals)
	actor.velocity = Vector2.ZERO
	if typeof(payload) == TYPE_BOOL and payload == true:
		# This is a bit combersom but fuck it.
		var move_direction : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if not is_equal_approx(move_direction.length_squared(), 0.0):
			if not is_equal_approx(move_direction.y, 0.0) and actor.is_on_ladder():
				swap_to.call_deferred(state_climb)
			else:
				swap_to.call_deferred(state_move, move_direction)

func exit() -> void:
	if actor == null: return
	
	var wep : Weapon = actor.get_weapon()
	if wep == null: return
	Game.Disconnect_Signals(wep, _weapon_signals)

func update(_delta : float) -> void:
	if actor == null: return
	if not actor.get_weapon().is_triggered():
		var action : StringName = _weighted_action.get_random()
		#var cur_anim : StringName = actor.get_current_animation()
		#if action == ACTION_CHANGE:
			#actor.play_animation(ANIM_IDLE_B if cur_anim == ANIM_IDLE_A else ANIM_IDLE_A)

func physics_update(_delta : float) -> void:
	if actor == null: return
	if not actor.is_on_ladder():
		actor.velocity.y = actor.get_gravity().y
	else: actor.velocity.y = 0.0
	
	actor.move_and_slide()
	if not actor.is_on_surface():
		if not state_fall.is_empty():
			swap_to(state_fall)

func handle_input(event : InputEvent) -> void:
	if actor == null: return

	if Game.Event_One_Of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		var move_direction : Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
		if not is_equal_approx(move_direction.y, 0.0) and actor.is_on_ladder():
			swap_to(state_climb)
		else:
			swap_to(state_move, move_direction)
	elif event.is_action_pressed(&"jump"):
		swap_to(state_jump)
	elif event.is_action(&"shoot"):
		if event.is_pressed() and interactor != null and interactor.interactable_count() > 0:
			interactor.interact()
		else:
			var wep : Weapon = actor.get_weapon()
			if event.is_pressed():
				if wep.can_shoot():
					actor.set_tree_param(APARAM_TRANSITION, TRANS_ATTACK)
					wep.press_trigger(actor.get_parent())
			else:
				if actor.is_tree_param(APARAM_TRANSITION, TRANS_ATTACK):
					actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)
				wep.release_trigger()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_reloaded() -> void:
	if actor == null: return
	actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)
