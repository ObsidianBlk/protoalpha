@tool
extends State
class_name ProtoState

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_CLIMB : StringName = &"climb"
const ANIM_FALL : StringName = &"fall"
const ANIM_IDLE_A : StringName = &"idle_a"
const ANIM_IDLE_B : StringName = &"idle_b"
const ANIM_JUMP : StringName = &"jump"
const ANIM_RUN : StringName = &"run"
const ANIM_DEAD : StringName = &"dead"
const ANIM_SHOOT_RUN : StringName = &"shoot_run"
const ANIM_SHOOT_STAND : StringName = &"shoot_stand"
const ANIM_SHOOT_AIR : StringName = &"shoot_air"
const ANIM_HURT_GROUND : StringName = &"hurt_ground"
const ANIM_HURT_AIR : StringName = &"hurt_air"
const ANIM_SPAWN : StringName = &"spawn"


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _proto : CharacterBody2D = null

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func event_one_of(event : InputEvent, actions : Array[StringName], allow_echo : bool = false) -> bool:
	if allow_echo or not event.is_echo():
		for action : StringName in actions:
			if event.is_action(action): return true
	return false

func get_proto_node() -> CharacterBody2D:
	if _proto == null:
		var host : Node = get_host()
		if host is CharacterBody2D:
			_proto = host
	return _proto
