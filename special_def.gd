@tool
extends Resource
class_name SpecialDef

# --------------------------------------------------------------------------
# Export Variables
# --------------------------------------------------------------------------
## The name of the Special ability
@export var special_name : String = "":
	set=set_special_name
## The icon that represents this Special
@export var icon : Texture2D = null:
	set=set_icon
## The game level that must be finished to unlock this Special.
@export var unlock_level : int = 0:
	set=set_unlock_level
## The [WeaponDef] associated with this Special.[br]
## [b]Note:[/b] If empty, this Special is assumed to be an action. 
@export var weapon_definition : WeaponDef = null:
	set=set_weapon_definition
## If [code]true[/code] then all energy costs associated with this Special,
## whether from [property action_energy_cost] or from any defined [WeaponDef]
## will be ignored.
@export var has_infinite_energy : bool = false:
	set=set_has_infinite_energy
## The cost of this action in energy points.[br]
## [b]Note:[/b] Ignored if [property weapon_definition] is defined.
@export var action_energy_cost : int = 0:
	set=set_action_energy_cost
## The [SoundSheet] containing the audio stream(s) used when the special is triggered.
@export var sound_sheet : SoundSheet = null

# --------------------------------------------------------------------------
# Settings
# --------------------------------------------------------------------------
func set_special_name(n : String) -> void:
	special_name = n
	changed.emit()

func set_icon(ico : Texture2D) -> void:
	if icon != ico:
		icon = ico
		changed.emit()

func set_unlock_level(l : int) -> void:
	if l >= 0:
		unlock_level = l
		changed.emit()

func set_weapon_definition(w : WeaponDef) -> void:
	if weapon_definition != w:
		_DisconnectWeaponDef()
		weapon_definition = w
		_ConnectWeaponDef()
		notify_property_list_changed()
		changed.emit()

func set_has_infinite_energy(h : bool) -> void:
	if has_infinite_energy != h:
		has_infinite_energy = h
		notify_property_list_changed()
		changed.emit()

func set_action_energy_cost(e : int) -> void:
	if e > 0:
		action_energy_cost = e
		changed.emit()

# --------------------------------------------------------------------------
# Override Methods
# --------------------------------------------------------------------------
func _validate_property(property: Dictionary) -> void:
	if property.name == "action_energy_cost":
		property.usage = PROPERTY_USAGE_DEFAULT
		if weapon_definition != null or has_infinite_energy:
			property.usage = PROPERTY_USAGE_STORAGE

# --------------------------------------------------------------------------
# Private Methods
# --------------------------------------------------------------------------
func _ConnectWeaponDef() -> void:
	if weapon_definition == null: return
	if not weapon_definition.changed.is_connected(changed.emit):
		weapon_definition.changed.connect(changed.emit)

func _DisconnectWeaponDef() -> void:
	if weapon_definition == null: return
	if weapon_definition.changed.is_connected(changed.emit):
		weapon_definition.changed.disconnect(changed.emit)

# --------------------------------------------------------------------------
# Public Methods
# --------------------------------------------------------------------------
func is_action() -> bool:
	return weapon_definition == null
