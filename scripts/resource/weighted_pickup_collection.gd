@tool
extends WeightedCollection
class_name WeightedPickupCollection


# ------------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------
const _DEFAULT_WEIGHT : float = 1.0

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func _set_collection(c : Dictionary[StringName, float]) -> void:
	super._set_collection(c)
	if _collection.size() != Game.PICKUP_LUT.size():
		for key : StringName in Game.PICKUP_LUT.keys():
			if not key in _collection:
				insert(key, _DEFAULT_WEIGHT)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _init() -> void:
	for key : StringName in Game.PICKUP_LUT.keys():
		insert(key, _DEFAULT_WEIGHT)

func _get(property: StringName) -> Variant:
	if has(property):
		return get_weight(property)
	return null

func _set(property: StringName, value: Variant) -> bool:
	if has(property) and typeof(value) == TYPE_FLOAT:
		insert(property, value)
		return true
	return false

func _get_property_list() -> Array[Dictionary]:
	var arr : Array[Dictionary] = []
	for key : StringName in Game.PICKUP_LUT.keys():
		arr.append({
			"name": key,
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_EDITOR
		})
	return arr
