extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_IDLE : StringName = &"idle"
const ANIM_WIGGLE : StringName = &"wiggle"
const ANIM_DROP : StringName = &"drop"
const ANIM_RESET : StringName = &"reset"

enum PlatformState {IDLE=0, WIGGLE=1, DROP=2, RESET=3}
# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var stable_time : float = 1.0
@export var drop_delay : float = 1.0
@export var reset_delay : float = 1.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _delay : float = 0.0
var _state : PlatformState = PlatformState.IDLE

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _anim_player: AnimSpritePlayer = %AnimPlayer

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _delay > 0.0:
		_delay -= delta
		if _delay <= 0.0:
			match _state:
				PlatformState.IDLE:
					_anim_player.play(ANIM_WIGGLE)
					_state = PlatformState.WIGGLE
					_delay = drop_delay
				PlatformState.WIGGLE:
					_anim_player.play(ANIM_DROP)
					_state = PlatformState.DROP
				PlatformState.DROP:
					_anim_player.play(ANIM_RESET)
					_state = PlatformState.RESET

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_trigger_area_body_entered(body: Node2D) -> void:
	if body.is_in_group(Game.GROUP_PLAYER):
		_delay = stable_time

func _on_trigger_area_body_exited(body: Node2D) -> void:
	if body.is_in_group(Game.GROUP_PLAYER):
		if _state == PlatformState.IDLE or _state == PlatformState.WIGGLE:
			_delay = 0.0
			_anim_player.play.call_deferred(ANIM_IDLE)
			_state = PlatformState.IDLE

func _on_anim_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		ANIM_DROP:
			_delay = reset_delay
		ANIM_RESET:
			_anim_player.play.call_deferred(ANIM_IDLE)
			_state = PlatformState.IDLE
