extends Resource
class_name HitboxResource


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var ignore_health : bool = false:			set=set_ignore_health
## The amount of damage dealt to detected colliding [HitBox][br][br]
## A value of [code]-1[/code] will trigger an instant death to the colliding
## [HitBox] object (if that [HitBox] object has an assigned [ComponentHealth]
## object.
@export var damage : int = 0:						set=set_damage
## If [code]true[/code] damage will be dealt every [property invulnerability_time] seconds.
@export var continuous : bool = false:				set=set_continuous
## The amount of time (in seconds) this [HitBox] will not take damage after being hit.
@export var invulnerability_time : float = 1.0:		set=set_invulnerability_time


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_ignore_health(i : bool) -> void:
	if ignore_health != i:
		ignore_health = i
		changed.emit()

func set_damage(d : int) -> void:
	if damage != d:
		damage = d
		changed.emit()

func set_continuous(c : bool) -> void:
	if continuous != c:
		continuous = c
		changed.emit()

func set_invulnerability_time(i : float) -> void:
	if not is_equal_approx(invulnerability_time, i):
		invulnerability_time = i
		changed.emit()
