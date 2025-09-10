@tool
extends Resource
class_name MobInfo


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var mob_name : String = "":								set=set_mob_name
@export_multiline var description : String = "":				set=set_description
@export_file("*.scn", "*.tscn") var mob_scene : String = "":	set=set_mob_scene
@export var sprite_reference : Texture2D = null:				set=set_sprite_reference
@export var icon : Texture2D = null:							set=set_icon
@export var properties : Dictionary[StringName, Variant] = {}

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_mob_name(n : String) -> void:
	if n != mob_name:
		mob_name = n
		changed.emit()

func set_description(d : String) -> void:
	if d != description:
		description = d
		changed.emit()

func set_mob_scene(s : String) -> void:
	if (s.is_empty() or s.is_valid_filename() or _IsUID(s)) and s != mob_scene:
		mob_scene = s
		changed.emit()

func set_sprite_reference(s : Texture2D) -> void:
	if s != sprite_reference:
		sprite_reference = s
		changed.emit()

func set_icon(i : Texture2D) -> void:
	if i != icon:
		icon = i
		changed.emit()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _IsUID(s : String) -> bool:
	if not s.is_empty():
		return s.begins_with("uid://")
	return false

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_scene_instance() -> Node2D:
	if not mob_scene.is_empty():
		var scene : PackedScene = load(mob_scene)
		if scene != null:
			var n : Node = scene.instantiate()
			if n is Node2D:
				for property : StringName in properties:
					if property in n and typeof(n[property]) == typeof(properties[property]):
						n[property] = properties[property]
				return n
			n.queue_free()
	return null

func draw_editor_display(n : Node2D) -> void:
	pass
