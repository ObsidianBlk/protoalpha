@tool
extends AnimationPlayer
class_name AnimSpritePlayer


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var animated_sprite : AnimatedSprite2D = null
@export var clear_existing_libraries: bool = false
@export var use_default_animation_library : bool = true
@export var library_name : StringName = ""
@export_tool_button("Generate") var generate : Callable = _Generate


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ClearExistingAnimationLibraries() -> void:
	if not Engine.is_editor_hint(): return
	var libs : Array[StringName] = get_animation_library_list()
	for lib_name : StringName in libs:
		if not lib_name.is_empty():
			remove_animation_library(lib_name)

func _ClearAnimationLibrary(lib : AnimationLibrary) -> void:
	var anims : Array[StringName] = lib.get_animation_list()
	for anim_name : StringName in anims:
		lib.remove_animation(anim_name)

func _GetAnimationLibraryOrNew(library_name : StringName) -> AnimationLibrary:
	if has_animation_library(library_name):
		return get_animation_library(library_name)
	return AnimationLibrary.new()

func _StoreLibraryIfNotExists(library_name : StringName, lib : AnimationLibrary) -> void:
	if not has_animation_library(library_name):
		add_animation_library(library_name, lib)

func _Generate() -> void:
	if not Engine.is_editor_hint():
		printerr("Cannot generate animations outside of engine.")
		return
	if animated_sprite == null:
		printerr("Missing Animated Sprite.")
		return
	if animated_sprite.sprite_frames == null:
		printerr("Animated Sprite missing sprite frames")
		return
	
	var node_path : NodePath = get_path_to(animated_sprite)
	if node_path.is_empty():
		printerr("Path to ", animated_sprite.name, " is empty.")
		return

	var sf : SpriteFrames = animated_sprite.sprite_frames
	var anim_list : PackedStringArray = sf.get_animation_names()
	if anim_list.size() > 0:
		if clear_existing_libraries:
			_ClearExistingAnimationLibraries()
		
		if not use_default_animation_library and library_name.is_empty():
			library_name = animated_sprite.name
		var anim_library : AnimationLibrary = _GetAnimationLibraryOrNew(
			"" if use_default_animation_library else library_name
		)
		
		if anim_library == null:
			printerr("Failed to obtain an animation library.")
			return
		_ClearAnimationLibrary(anim_library)
		
		for anim_name : StringName in sf.get_animation_names():
			var frame_count : int = sf.get_frame_count(anim_name)
			if frame_count <= 0: continue # Skip animation if there are no frames
			var fps : float = sf.get_animation_speed(anim_name)
			
			var animation : Animation = Animation.new()
			
			var anim_name_track : int = animation.add_track(Animation.TYPE_VALUE)
			animation.track_set_path(anim_name_track, "%s:animation"%[node_path])
			animation.track_insert_key(anim_name_track, 0.0, anim_name)
			
			var frame_track : int = animation.add_track(Animation.TYPE_VALUE)
			animation.track_set_path(frame_track, "%s:frame"%[node_path])
			animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
			
			var time : float = 0.0
			for frame : int in range(frame_count):
				animation.track_insert_key(frame_track, time, frame)
				time += sf.get_frame_duration(anim_name, frame) / fps
			animation.length = time
			if sf.get_animation_loop(anim_name):
				animation.loop_mode = Animation.LOOP_LINEAR
			
			anim_library.add_animation(anim_name, animation)
		
		_StoreLibraryIfNotExists(
			"" if use_default_animation_library else library_name,
			anim_library
		)
