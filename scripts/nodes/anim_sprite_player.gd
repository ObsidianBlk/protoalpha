@tool
extends AnimationPlayer
class_name AnimSpritePlayer

## Utility class that can generate animations connected to corresponding AnimatedSprite2D animations.
##
## AnimSpritePlayer's primary purpose is to generate animations that connect to
## corresponding animations defined in an AnimatedSprite2D node. This can be very
## useful if the desire is to use said animations inside an AnimationTree (which only
## works with AnimationPlayer animations and not AnimatedSprite2D animations).
## [br][br]
## Beyond it's ability to generate animations from AnimatedSprite2D, this node is
## and can be used exactly like any other AnimationPlayer node.


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
## The [AnimatedSprite2D] node from which to generate animations.
@export var animated_sprite : AnimatedSprite2D = null
## If defined, will only import given animation.
@export var target_animation : StringName = &""
## If [code]true[/code], all non-default animation libraries will be cleared.
@export var clear_existing_libraries: bool = false
## If [code]true[/code], will generate animations into the default animation library.
@export var use_default_animation_library : bool = true
## Custom name for animation library (if not using the default library).[br][br]
## [b]NOTE:[/b] If left blank and [member use_default_animation_library] is [code]false[/code],
## the node name of the assigned [AnimatedSprite2D] will be used as the
## library name.
@export var library_name : StringName = ""

@export_tool_button("Generate") var generate : Callable = _Generate


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ClearExistingAnimationLibraries() -> void:
	# Clears out existing animation libraries except the default one.
	if not Engine.is_editor_hint(): return
	var libs : Array[StringName] = get_animation_library_list()
	for lib_name : StringName in libs:
		if not lib_name.is_empty():
			remove_animation_library(lib_name)

func _ClearAnimationLibrary(lib : AnimationLibrary) -> void:
	# Removes all existing animations from the given AnimationLibrary object.
	var anims : Array[StringName] = lib.get_animation_list()
	for anim_name : StringName in anims:
		lib.remove_animation(anim_name)

func _ClearAnimationFromLibrary(lib : AnimationLibrary, anim_name : StringName) -> void:
	if lib.has_animation(anim_name):
		lib.remove_animation(anim_name)

func _GetAnimationLibraryOrNew(lib_name : StringName) -> AnimationLibrary:
	# Given <library_name>, returns an existing AnimationLibrary under the given name
	# or returns a new AnimationLibrary.
	if has_animation_library(lib_name):
		return get_animation_library(lib_name)
	return AnimationLibrary.new()

func _StoreLibraryIfNotExists(lib_name : StringName, lib : AnimationLibrary) -> void:
	# Will store the given AnimationLibrary if no AnimationLibrary already exists
	# with the given <library_name>
	if not has_animation_library(lib_name):
		add_animation_library(lib_name, lib)

func _GetNodePathToAnimSprite() -> NodePath:
	if animated_sprite != null:
		var root : Node = get_node_or_null(root_node)
		if root != null:
			return root.get_path_to(animated_sprite)
	return NodePath("")

func _PortAnimation(lib : AnimationLibrary, sf : SpriteFrames, node_path : NodePath, anim_name : StringName) -> void:
	# Get the frames
	var frame_count : int = sf.get_frame_count(anim_name)
	if frame_count <= 0: return # Skip animation if there are no frames
	# Get the speed/frames per second.
	var fps : float = sf.get_animation_speed(anim_name)
	
	# Time to build an animation!
	var animation : Animation = Animation.new()
	
	# Create a track to change AnimatedSprite2D:animation to the animation
	# we'll be... animating! :D
	var anim_name_track : int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(anim_name_track, "%s:animation"%[node_path])
	animation.track_insert_key(anim_name_track, 0.0, anim_name)
	
	# Create a track for the animation frames.
	var frame_track : int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(frame_track, "%s:frame"%[node_path])
	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
	
	# This <time> variable helps up keep track of the overall time and
	# (as this is accumulative) the keyframe we're working on.
	var time : float = 0.0
	# Looping through the frames! Wheeeee!
	for frame : int in range(frame_count):
		# For each keyframe (<time>) we simple store the <frame> index!
		animation.track_insert_key(frame_track, time, frame)
		# Adjust the time based on the frame's duration divided by the
		# defined speed/fps of the animation.
		time += sf.get_frame_duration(anim_name, frame) / fps
	
	# Done with the loop, now tell the animation how long it actually is!
	# (Which should just be the accumlated <time> value!)
	animation.length = time
	
	# Tell the animation if it's looping!
	if sf.get_animation_loop(anim_name):
		animation.loop_mode = Animation.LOOP_LINEAR
	
	# Add the animation to the AnimationLibrary under the same name
	# as appeared in the AnimatedSprite2D:SpriteFrames resource.
	lib.add_animation(anim_name, animation)


func _Generate() -> void:
	# This is where we kick the tires and light the fires!
	# That is to say... this is where we generate the animations from the given
	# AnimatedSprite2D node!
	
	if not Engine.is_editor_hint():
		# Complain and bail if this method is, somehow, being called from
		# runtime! We shouldn't need to do this at run time!
		printerr("Cannot generate animations outside of engine.")
		return
	if animated_sprite == null:
		# Complain and bail if we weren't assigned an AnimatedSprite2D node!
		printerr("Missing Animated Sprite.")
		return
	if animated_sprite.sprite_frames == null:
		# Complain and bail if the AnimatedSprite2D node is missing a
		# SpriteFrames resource!
		printerr("Animated Sprite missing sprite frames")
		return
	
	#var node_path : NodePath = owner.get_path_to(animated_sprite)
	var node_path : NodePath = _GetNodePathToAnimSprite()
	if node_path.is_empty():
		# Complain and bail if we don't have a path to the AnimatedSprite2D
		printerr("Path to ", animated_sprite.name, " is empty.")
		return

	var sf : SpriteFrames = animated_sprite.sprite_frames
	var anim_list : PackedStringArray = sf.get_animation_names()
	
	# Make sure we actually have animations in that SpriteFrames resource!
	if anim_list.size() > 0:
		
		# First... let's clean house, if asked for.
		if clear_existing_libraries:
			_ClearExistingAnimationLibraries()
		
		# Next obtain or create the AnimationLibrary we'll be packing with
		# animations!
		if not use_default_animation_library and library_name.is_empty():
			library_name = animated_sprite.name
		var anim_library : AnimationLibrary = _GetAnimationLibraryOrNew(
			"" if use_default_animation_library else library_name
		)
		
		if anim_library == null:
			# Complain and bail if we, somehow, didn't get an AnimationLibrary
			printerr("Failed to obtain an animation library.")
			return
		
		if not target_animation.is_empty():
			if sf.has_animation(target_animation):
				_ClearAnimationFromLibrary(anim_library, target_animation)
				_PortAnimation(anim_library, sf, node_path, target_animation)
		else:
			_ClearAnimationLibrary(anim_library)
			# Loop through each animation in the AnimatedSprite2D:SpriteFrames resource.
			for anim_name : StringName in sf.get_animation_names():
				_PortAnimation(anim_library, sf, node_path, anim_name)
		
		# Finally, store the AnimationLibrary if no library exists under the given name.
		_StoreLibraryIfNotExists(
			"" if use_default_animation_library else library_name,
			anim_library
		)
