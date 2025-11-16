@tool
extends Node2D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const _TARGET_METHOD : StringName = &"teleport_to"

const ANIM_IDLE : StringName = &"idle"
const ANIM_ACTIVE : StringName = &"active"
const ANIM_DISCHARGING : StringName = &"discharging"

const AUDIO_DISCHARGING : StringName = &"discharging"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var active : bool = true:						set=set_active
@export var destination_marker : Marker2D = null
@export var sound_sheet : SoundSheet = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _target : Node2D = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _aplayer: AnimSpritePlayer = %APlayer
@onready var _chirper: Node = %Chirper

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_active(a : bool) -> void:
	if a != active:
		active = a
		if _aplayer != null:
			_aplayer.play(ANIM_ACTIVE if active else ANIM_IDLE)
		if _chirper != null:
			_chirper.enabled = active

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_aplayer.play(ANIM_ACTIVE if active else ANIM_IDLE)
	_chirper.enabled = active

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _TeleportTarget() -> void:
	if destination_marker == null or _target == null: return
	_target.teleport_to(destination_marker.global_position)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_detector_body_entered(body: Node2D) -> void:
	if body == null or not active: return
	if _aplayer.current_animation == ANIM_DISCHARGING: return
	
	if body.has_method(_TARGET_METHOD):
		_target = body
		_aplayer.play(ANIM_DISCHARGING)
		if _chirper != null:
			_chirper.enabled = false
		if sound_sheet != null:
			sound_sheet.play(AUDIO_DISCHARGING)


func _on_detector_body_exited(body: Node2D) -> void:
	if body == _target:
		_target = null

func _on_anim_sprite_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == ANIM_DISCHARGING:
		_aplayer.play(ANIM_ACTIVE if active else ANIM_IDLE)
		_chirper.enabled = active
