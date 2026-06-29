extends StaticBody2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const CHARGE_AMOUNT = 2
const ANIM_IDLE : StringName = &"idle"
const ANIM_ACTIVE : StringName = &"active"

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	Game.State.change_current_energy_level(CHARGE_AMOUNT)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_detector_body_entered(body: Node2D) -> void:
	_sprite.play(ANIM_ACTIVE)
	set_physics_process(true)


func _on_detector_body_exited(body: Node2D) -> void:
	_sprite.play(ANIM_IDLE)
	set_physics_process(false)
