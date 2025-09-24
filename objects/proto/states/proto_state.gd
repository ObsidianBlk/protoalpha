@tool
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

const TRANS_CORE : String = "core"
const TRANS_ATTACK : String = "attack"
const TRANS_CLIMB : String = "climb"
const ONCE_FIRE : int = 1

const APARAM_TRANSITION : String = "parameters/transition/transition_request"
const APARAM_ONCE_HURT : String = "parameters/hurt/request"
const APARAM_ONCE_SPAWN : String = "parameters/spawn_dead/request"

const AUDIO_JUMP : StringName = &"jump"
const AUDIO_LAND : StringName = &"land"
const AUDIO_HURT : StringName = &"hurt"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var interactor : Interactor2D = null
