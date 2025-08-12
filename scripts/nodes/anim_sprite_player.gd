@tool
extends AnimationPlayer
class_name AnimSpritePlayer


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var animated_sprite : AnimatedSprite2D = null
@export_tool_button("Generate") var generate : Callable = _Generate


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ClearExistingAnimationLibraries() -> void:
	if not Engine.is_editor_hint(): return
	var libs : Array[StringName] = get_animation_library_list()
	for lib_name : StringName in libs:
		remove_animation_library(lib_name)

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
	
	var sf : SpriteFrames = animated_sprite.sprite_frames
	var anim_list : PackedStringArray = sf.get_animation_names()
	if anim_list.size() > 0:
		_ClearExistingAnimationLibraries()
		var anim_library : AnimationLibrary = AnimationLibrary.new()
		for anim_name : StringName in sf.get_animation_names():
			var frame_count : int = sf.get_frame_count(anim_name)
			if frame_count <= 0: continue # Skip animation if there are no frames
			
			var animation : Animation = Animation.new()
			
			var anim_name_track : int = animation.add_track(Animation.TYPE_VALUE)
			animation.track_set_path(anim_name_track, get_path_to(animated_sprite))
			animation.track_insert_key(anim_name_track, 0.0, anim_name)
			
			var frame_track : int = animation.add_track(Animation.TYPE_VALUE)
			var time : float = 0.0
			for frame : int in range(frame_count):
				animation.track_insert_key(frame_track, time, frame)
				time += sf.get_frame_duration(anim_name, frame)
			animation.length = time
			if sf.get_animation_loop(anim_name):
				animation.loop_mode = Animation.LOOP_LINEAR
			
			anim_library.add_animation(anim_name, animation)
		
		add_animation_library(animated_sprite.name, anim_library)
