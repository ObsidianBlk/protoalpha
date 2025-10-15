@tool
extends Resource
class_name WeaponDef


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
enum Type {PROJECTILE=0, BEAM=1}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The type of weapon
@export var type : Type = Type.PROJECTILE:					set=set_type
## The name of the weapon
@export var name : StringName = "Weapon":					set=set_weapon_name
## A representative icon
@export var icon : Texture2D = null:						set=set_icon
## A [SoundSheed] object containing the audio effects for the weapon.
@export var sound_sheet : SoundSheet = null:				set=set_sound_sheet
@export_group("Projectile Info")
## The scene for the projectile projected from the weapon.
@export var projectile : PackedScene = null:				set=set_projectile
## If [code]charging=false[/code], represents the rate of fire of the projectiles.
## [br]If [code]charging=true[/code], represents the time required to charge the projectile before it will fire.
@export var rate_of_fire : float = 1.0:						set=set_rate_of_fire
## If [code]false[/code] a projectile can only be fired as often as [code]rate_of_fire[/code] specified.
## [br]If [code]true[/code] a projectile will only be ejected after [code]rate_of_fire[/code] time has ellapsed.
@export var charging : bool = false:						set=set_charging
## Determins if a weapon is semi-automatic ([code]false[/code], trigger must be pressed for each shot)
## [br]or automatic ([code]true[/code], projectiles will be emitted based on [rate_of_fire]).
@export var automatic : bool = false:						set=set_automatic


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_type(t : Type) -> void:
	if t != type:
		type = t
		changed.emit()

func set_weapon_name(n : StringName) -> void:
	if n != name:
		name = n
		changed.emit()

func set_icon(ico : Texture2D) -> void:
	if ico != icon:
		icon = ico
		changed.emit()

func set_sound_sheet(s : SoundSheet) -> void:
	if s != sound_sheet:
		_DisconnectSoundSheet()
		sound_sheet = s
		_ConnectSoundSheet()
		changed.emit()

func set_projectile(p : PackedScene) -> void:
	if projectile != p:
		projectile = p
		changed.emit()

func set_rate_of_fire(rof : float) -> void:
	if rof > 0.0:
		rate_of_fire = rof
		changed.emit()

func set_charging(c : bool) -> void:
	if charging != c:
		charging = c
		changed.emit()

func set_automatic(a : bool) -> void:
	if a != automatic:
		automatic = a
		changed.emit()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectSoundSheet() -> void:
	if sound_sheet == null: return
	if not sound_sheet.changed.is_connected(_on_sub_resource_changed):
		sound_sheet.changed.connect(_on_sub_resource_changed)

func _DisconnectSoundSheet() -> void:
	if sound_sheet == null: return
	if sound_sheet.changed.is_connected(_on_sub_resource_changed):
		sound_sheet.changed.disconnect(_on_sub_resource_changed)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_projectile_instance() -> Projectile:
	if projectile != null:
		var p : Node = projectile.instantiate()
		if p is Projectile:
			return p
		p.queue_free()
	return null

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_sub_resource_changed() -> void:
	changed.emit()
