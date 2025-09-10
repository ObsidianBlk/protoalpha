@tool
extends MobInfo
class_name BlockieInfo

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const PROPS : Dictionary[StringName, Variant] = {
	&"flip_h":false,
	&"steps_from_center":1
}

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _get(property: StringName) -> Variant:
	if property in properties:
		return properties[property]
	if property in PROPS:
		return PROPS[property]
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property in PROPS:
		if typeof(value) == typeof(PROPS[property]):
			properties[property] = value
			return true
	return false

func _get_property_list() -> Array[Dictionary]:
	var arr : Array[Dictionary] = []
	for prop : StringName in PROPS:
		arr.append({
			&"name": prop,
			&"type": typeof(PROPS[prop])
		})
	return arr

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func draw_editor_display(n : Node2D) -> void:
	if not Engine.is_editor_hint(): return
	var steps_from_center = 1
	if &"steps_from_center" in properties:
		steps_from_center = properties[&"steps_from_center"]
	var dist : float = 16.0 * steps_from_center
	n.draw_line(Vector2(-dist, -4.0), Vector2(dist, -4.0), Game.GUIDE_COLOR_MATCHING_AXIS, 1.0, true)
	n.draw_line(Vector2(-dist, -8.0), Vector2(-dist, 0.0), Game.GUIDE_COLOR_APPOSING_AXIS, 1.0, true)
	n.draw_line(Vector2(dist, -8.0), Vector2(dist, 0.0), Game.GUIDE_COLOR_APPOSING_AXIS, 1.0, true)
