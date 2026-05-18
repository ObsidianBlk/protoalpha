extends Node2D


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var always_enabled : bool = false

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _mobile_enabled : bool = false

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_always_enabled(e : bool) -> void:
	if always_enabled != e:
		always_enabled = e
		_on_visibility_changed()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	#_mobile_enabled = false # This is most likely redundant
	#for feature : String in ["mobile", "web_android", "web_ios"]:
		#if OS.has_feature(feature):
			#_mobile_enabled = true
			#break

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _IsMobileEnabled() -> bool:
	if always_enabled: return true
	for feature : String in ["mobile", "web_android", "web_ios"]:
		if OS.has_feature(feature):
			return true
	return false

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_visibility_changed() -> void:
	if visible and not _IsMobileEnabled():
		visible = false
