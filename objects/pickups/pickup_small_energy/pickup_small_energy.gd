extends PickupBody2D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ENERGY_VALUE : int = 32


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _relay: ComponentRelay = %ComponentRelay


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_detected(_hitbox : HitBox) -> void:
	if sound_sheet != null:
		sound_sheet.play(AUDIO)
	Game.State.change_current_energy_level(ENERGY_VALUE)
	_relay.energy_changed(Game.State.get_special())
	queue_free.call_deferred()
