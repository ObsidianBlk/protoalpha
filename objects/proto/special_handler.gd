extends ProtoState


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var weapon : Weapon = null
@export_subgroup("Special", "special_")
@export var special_state_fault_dash : StringName = &""

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_weapon(w : Weapon) -> void:
	if weapon != w:
		_DisconnectWeapon()
		weapon = w
		_ConnectWeapon()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectWeapon() -> void:
	if weapon == null: return
	if not weapon.reloaded.is_connected(_on_reloaded):
		weapon.reloaded.connect(_on_reloaded)

func _DisconnectWeapon() -> void:
	if weapon == null: return
	if weapon.reloaded.is_connected(_on_reloaded):
		weapon.reloaded.disconnect(_on_reloaded)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func handle(triggered : bool) -> void:
	if actor == null or weapon == null: return
	
	if weapon.weapon_def != null:
		if triggered:
			if weapon.can_shoot():
				actor.set_tree_param(APARAM_TRANSITION, TRANS_ATTACK)
				weapon.press_trigger(actor.get_parent())
		else:
			if actor.is_tree_param(APARAM_TRANSITION_CURRENT, TRANS_ATTACK):
				actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)
			weapon.release_trigger()
	else:
		var special : GameState.Special = actor.get_special()
		match special:
			GameState.Special.FAULT_DASH:
				if special_state_fault_dash.is_empty(): return
				if Game.State.use_special(special):
					swap_to(special_state_fault_dash)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_reloaded() -> void:
	if actor == null or weapon == null: return
	if not weapon.is_triggered():
		actor.set_tree_param(APARAM_TRANSITION, TRANS_CORE)
