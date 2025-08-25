@tool
extends Node2D
class_name BossSpawner


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal spawned()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_file("*.scn", "*.tscn") var boss_path : String = ""
@export var spawn_container : Node2D = null

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	reset()

func _draw() -> void:
	if Engine.is_editor_hint():
		var r : float = 4.0
		var hr : float = r * 0.5
		var crown_y : float = -((r*2) + 1)
		draw_circle(Vector2(0, -r), r, Color.AQUA)
		_DrawTriangle(Vector2(0, crown_y), Vector2(r,r), Color.AQUA)
		_DrawTriangle(Vector2(-hr, crown_y), Vector2(r,r), Color.AQUA)
		_DrawTriangle(Vector2(hr, crown_y), Vector2(r,r), Color.AQUA)


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DrawTriangle(pos : Vector2, size : Vector2, color : Color) -> void:
	var vecs : PackedVector2Array = PackedVector2Array([
		Vector2(pos.x, pos.y - size.y),
		Vector2(pos.x + (size.x * 0.5), pos.y),
		Vector2(pos.x - (size.x * 0.5), pos.y)
	])
	draw_colored_polygon(vecs, color)

func _GetSpawnContainer() -> Node2D:
	if spawn_container == null:
		var parent : Node = get_parent()
		if parent is Node2D:
			return parent
		return null
	return spawn_container

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func reset() -> void:
	if Engine.is_editor_hint(): return

func spawn() -> void:
	if boss_path.is_empty():
		print_debug("Boss Spawner missing boss scene path.")
		return
	
	var container : Node2D = _GetSpawnContainer()
	if container == null:
		print_debug("Failed to get container node for boss spawn.")
		return
	
	var boss_scene : PackedScene = load(boss_path)
	if boss_scene == null:
		print_debug("Failed to load boss scene \"", boss_path, "\".")
		return
	
	var boss : Node = boss_scene.instantiate()
	if not boss is CharacterActor2D:
		print_debug("Instanced scene is not CharacterActor2D. Canceling Spawn!")
		boss.queue_free()
		return
	
	boss.add_to_group(Game.GROUP_BOSS)
	container.add_child(boss)
	boss.global_position = global_position
	spawned.emit()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
