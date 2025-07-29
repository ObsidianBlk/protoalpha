@tool
extends Node2D
class_name ComponentVisual

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _anims_to_nodes : Dictionary[StringName, Array] = {}
var _nodes_to_anims : Dictionary[StringName, PackedStringArray] = {}

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	for child in get_children():
		_on_child_entered_tree(child)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _AddAnimLookup(anim_name : StringName, n : Node) -> void:
	if not anim_name in _anims_to_nodes:
		_anims_to_nodes[anim_name] = []
	var idx : int = _anims_to_nodes[anim_name].find(n)
	if idx < 0:
		_anims_to_nodes[anim_name].append(n)

func _RemoveAnimLookup(anim_name : StringName, n : Node) -> void:
	if anim_name in _anims_to_nodes:
		var idx : int = _anims_to_nodes[anim_name].find(n)
		if idx >= 0:
			_anims_to_nodes[anim_name].remove_at(idx)
			if _anims_to_nodes[anim_name].size() <= 0:
				_anims_to_nodes.erase(anim_name)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_anim_sprite_frames_changed(sprt : AnimatedSprite2D) -> void:
	# Clear out any previously tabled animations for this node
	if sprt.name in _nodes_to_anims:
		for anim_name in _nodes_to_anims[sprt.name]:
			_RemoveAnimLookup(anim_name, sprt)
		_nodes_to_anims.erase(sprt.name)
	
	# Setup tables for animations from this node.
	if sprt.sprite_frames != null:
		var anims : PackedStringArray = sprt.sprite_frames.get_animation_names()
		for anim_name : StringName in anims:
			_AddAnimLookup(anim_name, sprt)
		_nodes_to_anims[sprt.name] = anims

func _on_child_entered_tree(child : Node) -> void:
	if child is AnimatedSprite2D:
		if not child.sprite_frames_changed.is_connected(_on_anim_sprite_frames_changed.bind(child)):
			child.sprite_frames_changed.connect(_on_anim_sprite_frames_changed.bind(child))
			_on_anim_sprite_frames_changed(child)

func _on_child_exiting_tree(child : Node) -> void:
	if child is AnimatedSprite2D:
		if child.sprite_frames_changed.is_connected(_on_anim_sprite_frames_changed.bind(child)):
			child.sprite_frames_changed.disconnect(_on_anim_sprite_frames_changed.bind(child))
