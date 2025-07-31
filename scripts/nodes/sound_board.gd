extends Node
class_name SoundBoard


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var polyphony = 32:					set=set_polyphony
@export var bus : StringName = &"Master"
@export var streams : Dictionary[StringName, AudioStream] = {}


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _asp : AudioStreamPlayer = null

# ------------------------------------------------------------------------------
# Static Private Variables
# ------------------------------------------------------------------------------
static var _instance : SoundBoard = null

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_polyphony(p : int) -> void:
	if p > 0 and p != polyphony:
		polyphony = p
		_UpdateASP()

func set_bus(b : StringName) -> void:
	if b != bus and AudioServer.get_bus_index(b) >= 0:
		bus = b
		_UpdateASP()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_asp = AudioStreamPlayer.new()
	add_child(_asp)
	_asp.stream = AudioStreamPolyphonic.new()
	_UpdateASP()

func _enter_tree() -> void:
	if _instance == null:
		_instance = self

func _exit_tree() -> void:
	if _instance == self:
		_instance = null

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateASP() -> void:
	if _asp == null: return
	_asp.bus = bus
	_asp.stream.polyphony = polyphony

# ------------------------------------------------------------------------------
# Public Static Methods
# ------------------------------------------------------------------------------
static func Get() -> SoundBoard:
	return _instance

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func play(stream : AudioStream) -> void:
	pass
