extends Area2D
class_name FallZone


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_enum("On_Enter:0", "On_Exit:1") var death_trigger : int = 0

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	collision_mask = Game.COLLISION_LAYER_PLAYER_HITBOX
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_area_entered(area : Area2D) -> void:
	if area is HitBox and death_trigger == 0:
		area.kill(true)

func _on_area_exited(area : Area2D) -> void:
	if area is HitBox and death_trigger == 1:
		area.kill(true)
