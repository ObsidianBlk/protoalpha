extends Node2D


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _mobile_enabled : bool = false


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	_mobile_enabled = false # This is most likely redundant
	for feature : String in ["mobile", "web_android", "web_ios"]:
		if OS.has_feature(feature):
			_mobile_enabled = true
			break

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_visibility_changed() -> void:
	if visible and not _mobile_enabled:
		visible = false
