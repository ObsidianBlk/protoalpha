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
@export var state_fall : StringName = &""
@export var state_shoot : StringName = &""

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
	var proto : CharacterBody2D = get_proto_node()
	if proto == null:
		pop()
	proto.velocity = Vector2.ZERO
	
	if sprite != null:
		sprite.play(ANIM_IDLE_A)

func update(_delta : float) -> void:
	var proto : CharacterBody2D = get_proto_node()
	if proto == null: return
	var action : StringName = _weighted_action.get_random()
	if action == ACTION_CHANGE:
		sprite.play(ANIM_IDLE_B if sprite.animation == ANIM_IDLE_A else ANIM_IDLE_A)

func physics_update(_delta : float) -> void:
	var proto : CharacterBody2D = get_proto_node()
	proto.velocity.y = proto.get_gravity().y
	proto.move_and_slide()
	if not proto.is_on_floor():
		if not state_fall.is_empty():
			swap_to(state_fall)

func handle_input(event : InputEvent) -> void:
	if event_one_of(event, [&"move_left", &"move_right", &"move_up", &"move_down"]):
		var move_direction : Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
		swap_to(state_move, move_direction)
	elif event.is_action_pressed(&"jump"):
		swap_to(state_jump)
	elif event.is_action_pressed(&"shoot"):
		swap_to(state_shoot)
