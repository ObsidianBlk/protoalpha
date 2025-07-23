extends Node
class_name ComponentHealth


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal health_changed(health : int, max_health : int)
signal hit()
signal healed()
signal dead()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var max_health : int = 100:			set=set_max_health
@export var health : int = 100:				set=set_health

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_max_health(mh : int) -> void:
	if mh > 0 and mh != max_health:
		max_health = mh
		if max_health < health:
			health = max_health
		health_changed.emit(health, max_health)

func set_health(h : int) -> void:
	if h != health:
		health = max(0, min(max_health, h))
		health_changed.emit(health, max_health)


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func hurt(amount : int) -> void:
	if amount > 0:
		health -= amount
		if health <= 0:
			dead.emit()
		else: hit.emit()

func heal(amount : int) -> void:
	if amount > 0:
		health += amount
		healed.emit()
