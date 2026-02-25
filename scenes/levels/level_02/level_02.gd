extends Level


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DEFRAG_SIGNAL_SHIFT_TOGGLE : StringName = &"toggle_room_shift"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var boss_shift_manager : ShiftManager = null

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _boss_spawned(boss : CharacterActor2D) -> void:
	if boss_shift_manager == null or boss == null: return
	if boss.has_signal(DEFRAG_SIGNAL_SHIFT_TOGGLE):
		if not boss.is_connected(DEFRAG_SIGNAL_SHIFT_TOGGLE, _on_toggle_shift):
			boss.connect(DEFRAG_SIGNAL_SHIFT_TOGGLE, _on_toggle_shift)

func _boss_despawning(boss : CharacterActor2D) -> void:
	if boss == null: return
	if boss.has_signal(DEFRAG_SIGNAL_SHIFT_TOGGLE):
		if boss.is_connected(DEFRAG_SIGNAL_SHIFT_TOGGLE, _on_toggle_shift):
			boss.disconnect(DEFRAG_SIGNAL_SHIFT_TOGGLE, _on_toggle_shift)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_toggle_shift() -> void:
	if boss_shift_manager == null: return
	if boss_shift_manager.is_processing():
		boss_shift_manager.finish()
	else:
		boss_shift_manager.start()
