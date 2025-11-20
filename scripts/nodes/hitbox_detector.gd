extends Area2D
class_name HitboxDetector


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
## Emitted when a [HitBox] object is detected entering and/or exiting the collision area.
signal detected(hitbox : HitBox)

enum TriggerCondition {
	## Emit [signal detected] when [HitBox] enters collision area.
	ENTERED=0,
	## Emit [signal detected] when [HitBox] exits collision area.
	EXITED=1,
	## Emit [signal detected] when [HitBox] enters and/or exits collision area.
	BOTH=2
}
# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## Determins the condition in which [HitboxDetector] emits the [signal detected]
## signal.
@export var trigger : TriggerCondition = TriggerCondition.ENTERED

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ValidCondition(cond : TriggerCondition) -> bool:
	return cond == trigger or trigger == TriggerCondition.BOTH

# ------------------------------------------------------------------------------
# Handlers Methods
# ------------------------------------------------------------------------------
func _on_area_entered(area : Area2D) -> void:
	if not (_ValidCondition(TriggerCondition.ENTERED) and area is HitBox): return
	detected.emit(area)

func _on_area_exited(area : Area2D) -> void:
	if not (_ValidCondition(TriggerCondition.EXITED) and area is HitBox): return
	detected.emit(area)
