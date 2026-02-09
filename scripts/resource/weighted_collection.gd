@tool
extends Resource
class_name WeightedCollection


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_storage var collection : Dictionary[StringName, float]:	set=_set_collection, get=_get_collection

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _collection : Dictionary[StringName, float] = {}
var _accum_list : Array[Dictionary] = []
var _accum_total : float = 0.0
var _dirty : bool = true

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func _set_collection(c : Dictionary[StringName, float]) -> void:
	_dirty = false
	_collection.clear()
	for key : StringName in c.keys():
		insert(key, c[key])

func _get_collection() -> Dictionary[StringName, float]:
	return _collection.duplicate()

# ------------------------------------------------------------------------------
# Static Constructor Methods
# ------------------------------------------------------------------------------
static func FromDictionary(d : Dictionary[StringName, float]) -> WeightedCollection:
	var wc : WeightedCollection = WeightedCollection.new()
	wc.collection = d
	return wc

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CompileAccumList() -> void:
	if not _dirty: return
	_accum_list.clear()
	_accum_total = 0.0
	for key : StringName in _collection.keys():
		_accum_total += _collection[key]
		_accum_list.append({
			"id": key,
			"accum": _accum_total
		})
	_dirty = false

func _GetIDFromAccumValue(aval : float) -> StringName:
	if not _accum_list.is_empty():
		for d : Dictionary in _accum_list:
			if d["accum"] > aval:
				return d["id"]
	return &""

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func size() -> int:
	return _collection.size()

func is_empty() -> bool:
	return _collection.is_empty()

func clear() -> void:
	_dirty = false
	_collection.clear()

func insert(item_name : StringName, weight : float) -> void:
	if item_name.is_empty(): return
	_collection[item_name] = maxf(0.0, weight)
	_dirty = true

func remove(item_name : StringName) -> void:
	if item_name in _collection:
		_collection.erase(item_name)
		_dirty = not _collection.is_empty()

func get_weight(item_name : StringName) -> float:
	if item_name in _collection:
		return _collection[item_name]
	return 0.0

func has(item_name : StringName) -> bool:
	return item_name in _collection

func rand_item() -> StringName:
	if _collection.size() > 0:
		_CompileAccumList()
		return _GetIDFromAccumValue(randf() * _accum_total)
	return &""

func rand_from_rng(rng : RandomNumberGenerator) -> StringName:
	if _collection.size() > 0 and rng != null:
		_CompileAccumList()
		return _GetIDFromAccumValue(rng.randf() * _accum_total)
	return &""
