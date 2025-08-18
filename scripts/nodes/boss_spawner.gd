@tool
extends Area2D
class_name BossSpawner


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_file("*.scn", "*.tscn") var boss_path : String = ""


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	reset()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, 2.0, Color.AQUA)


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _SpawnBoss() -> void:
	if boss_path.is_empty():
		print_debug("Boss Spawner missing boss scene path.")
		return
	
	var parent : Node2D = get_parent()
	if parent == null:
		print_debug("Failed to get spawner's parent scene.")
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
	
	parent.add_child(boss)
	boss.global_position = global_position


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func reset() -> void:
	if Engine.is_editor_hint(): return
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node2D) -> void:
	if body.is_in_group(Game.GROUP_PLAYER):
		body_entered.disconnect(_on_body_entered)
		_SpawnBoss.call_deferred()
