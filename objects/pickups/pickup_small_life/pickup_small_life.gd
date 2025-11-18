extends CharacterBody2D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const HEALTH_VALUE : int = 5

const AUDIO : StringName = &"pickup"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var sound_sheet : SoundSheet = null

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity = get_gravity()
		move_and_slide()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_detector_area_entered(area: Area2D) -> void:
	if area is HitBox:
		if sound_sheet != null:
			sound_sheet.play(AUDIO)
		area.heal(HEALTH_VALUE)
		queue_free.call_deferred()
