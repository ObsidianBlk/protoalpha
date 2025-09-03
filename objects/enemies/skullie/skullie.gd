extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_IDLE : StringName = &"idle"
const ANIM_IDLE_BLINK : StringName = &"idle_blink"
const ANIM_FLY : StringName = &"fly"
const ANIM_SPINELESS : StringName = &"spineless"
const ANIM_ATTACK : StringName = &"attack"
const ANIM_DEATH : StringName = &"death"

const SPRITE_SIZE : Vector2 = Vector2(16, 16)
const PLAYER_POSITION_OFFSET : Vector2 = Vector2(0.0, 16.0)

enum EState {IDLE=0, FLY=1, SHOOT=2, DIVE=3, DEAD=4}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 60.0
@export var idle_time : float = 2.0
@export var dive_delay : float = 0.5
@export var weapon : Weapon = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _state : EState = EState.IDLE
var _state_changed : bool = false
var _has_spine : bool = true

var _fly_direction : float = 0.0
var _entered_screen : bool = false

var _dive_tween : Tween = null
var _player : WeakRef = weakref(null)

var _idle_action : WeightedRandomCollection = WeightedRandomCollection.new([
	{
		WeightedRandomCollection.DICT_KEY_ID: &"none",
		WeightedRandomCollection.DICT_KEY_WEIGHT: 100.0
	},
	{
		WeightedRandomCollection.DICT_KEY_ID: &"blink",
		WeightedRandomCollection.DICT_KEY_WEIGHT: 4.0
	}
])

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite: AnimatedSprite2D = %ASprite

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _process(_delta: float) -> void:
	if is_equal_approx(_fly_direction, 0.0):
		_GetFlyDirection()
		_sprite.flip_h = _fly_direction < 0.0

	if _IsOnScreen():
		_entered_screen = true
	elif _entered_screen:
		queue_free()

func _physics_process(delta: float) -> void:
	match _state:
		EState.IDLE:
			_ProcIdle(delta)
		EState.FLY:
			_ProcFly(delta)
		EState.SHOOT:
			_ProcShoot(delta)
		EState.DIVE:
			_ProcDive(delta)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _IsOnScreen() -> bool:
	if _sprite == null: return false
	
	var viewport : Viewport = get_viewport()
	if viewport != null:
		var cam : Camera2D = viewport.get_camera_2d()
		if cam != null:
			var camera_rect : Rect2 = Rect2(
				cam.global_position - (Game.SCREEN_RESOLUTION * 0.5),
				Game.SCREEN_RESOLUTION
			)
			var self_rect : Rect2 = Rect2(global_position - (SPRITE_SIZE * 0.5), SPRITE_SIZE)
			return camera_rect.intersects(self_rect)
	return false

func _GetFlyDirection() -> void:
	for n : Node in get_tree().get_nodes_in_group(Game.GROUP_PLAYER):
		if n is CharacterActor2D:
			_fly_direction = sign(n.global_position.x - global_position.x)

func _SetState(s : EState) -> void:
	if s != _state:
		_state = s
		_state_changed = true

func _ProcIdle(delta : float) -> void:
	if idle_time > 0.0:
		var action : StringName = _idle_action.get_random()
		if action == &"blink":
			_sprite.play("idle_blink")
		idle_time -= delta
		if idle_time <= 0.0:
			_SetState(EState.FLY)

func _ProcFly(delta : float) -> void:
	if _state_changed:
		_state_changed = false
		_sprite.play(ANIM_FLY if _has_spine else ANIM_SPINELESS)
	global_position += Vector2(speed * _fly_direction, 0.0) * delta


func _ProcShoot(delta : float) -> void:
	if _state_changed:
		_state_changed = false
		if weapon != null:
			_sprite.play(ANIM_ATTACK)

func _ProcDive(delta : float) -> void:
	var player : CharacterBody2D = _player.get_ref()
	if player == null:
		_SetState(EState.FLY)
		return
	
	if _state_changed:
		_state_changed = false
		_GetFlyDirection()
		_sprite.flip_h = _fly_direction < 0.0
		var target_y : float = player.global_position.y - PLAYER_POSITION_OFFSET.y
		var duration : float = abs(target_y - global_position.y) / (speed * 0.25)
		_dive_tween = create_tween()
		_dive_tween.set_ease(Tween.EASE_OUT)
		_dive_tween.set_trans(Tween.TRANS_ELASTIC)
		_dive_tween.tween_property(self, "global_position:y", target_y, duration)
		_dive_tween.finished.connect(_on_dive_tween_finished, CONNECT_ONE_SHOT)
	global_position += Vector2(speed * _fly_direction, 0.0) * delta

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_component_health_dead() -> void:
	if _sprite == null: return
	_SetState(EState.DEAD)
	_sprite.play(ANIM_DEATH)

func _on_component_health_hit() -> void:
	pass # Replace with function body.

func _on_sprite_animation_finished() -> void:
	if _sprite == null: return
	match _sprite.animation:
		ANIM_IDLE_BLINK:
			if _state == EState.IDLE:
				_sprite.play(ANIM_IDLE)
		ANIM_ATTACK:
			if _player != null:
				var player : CharacterBody2D = _player.get_ref()
				if player != null:
					weapon.look_at(player.global_position - PLAYER_POSITION_OFFSET)
					weapon.press_trigger(get_parent())
					get_tree().create_timer(dive_delay).timeout.connect(_on_dive_trigger_timeout)
					_has_spine = false
			_SetState(EState.FLY)
		ANIM_DEATH:
			queue_free.call_deferred()

func _on_dive_trigger_timeout() -> void:
	_SetState(EState.DIVE)

func _on_dive_tween_finished() -> void:
	_dive_tween = null
	_SetState(EState.FLY)

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group(Game.GROUP_PLAYER) and _has_spine:
		_player = weakref(body)
		_SetState(EState.SHOOT)

func _on_player_detector_body_exited(body: Node2D) -> void:
	pass
