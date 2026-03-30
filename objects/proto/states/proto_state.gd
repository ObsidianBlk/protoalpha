#@tool
extends ActorState
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
const ANIM_TELEPORT_IN : StringName = &"teleport_in"
const ANIM_TELEPORT_OUT : StringName = &"teleport_out"
const ANIM_FAULT_DASH_FORM : StringName = &"fault_arrow_form"
const ANIM_FAULT_DASH_EXIT : StringName = &"fault_arrow_exit"

const TRANS_CORE : String = "core"
const TRANS_ATTACK : String = "attack"
const TRANS_CLIMB : String = "climb"
const ONCE_FIRE : int = 1

const TRANS_ACTION_HURT : String = "hurt"
const TRANS_ACTION_DEAD_SPAWN : String = "dead_spawn"
const TRANS_ACTION_TELEPORT : String = "teleport"
const TRANS_ACTION_SPECIAL_FAULT_DASH : String = "sp_fault_dash"

const APARAM_TRANSITION : String = "parameters/transition/transition_request"
const APARAM_TRANSITION_CURRENT : String = "parameters/transition/current_state"
const APARAM_TRANS_ACTION : String = "parameters/actions/transition_request"
const APARAM_TRANS_ACTION_CURRENT : String = "parameters/actions/current_state"
const APARAM_ONCE_INTERRUPT : String = "parameters/interrupt/request"
#const APARAM_ONCE_HURT : String = "parameters/hurt/request"
#const APARAM_ONCE_SPAWN : String = "parameters/spawn_dead/request"
#const APARAM_ONCE_TELEPORT : String = "parameters/teleport_override/request"

const AUDIO_JUMP : StringName = &"jump"
const AUDIO_LAND : StringName = &"land"
const AUDIO_HURT : StringName = &"hurt"
const AUDIO_SPAWN : StringName = &"spawn"
const AUDIO_EXPLODE : StringName = &"explode"
const AUDIO_TELEPORT : StringName = &"teleport"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var interactor : Interactor2D = null
