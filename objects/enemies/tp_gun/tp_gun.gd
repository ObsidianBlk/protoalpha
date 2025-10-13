@tool
extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ANIM_IDLE : StringName = &"idle"
const ANIM_CHARGE : StringName = &"charge"
const ANIM_TELEPORT_IN : StringName = &"teleport_in"
const ANIM_TELEPORT_OUT : StringName = &"teleport_out"

const PRE_CHARGE_TIME : float = 1.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var flipped : bool = false:								set=set_flipped
@export var idle_time : float = 1.0
@export_range(-90.0, 90.0) var weapon_angle : float = 0.0:		set=set_weapon_angle
@export var projectile_container : Node2D = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _active : bool = false
var _dead : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _viz: Node2D = %Viz
@onready var _sprite: AnimatedSprite2D = %ASprite
@onready var _weapon: Weapon = %Weapon
@onready var _hitbox: HitBox = %HitBox
@onready var _explosion_fire: Node2D = %ExplosionFire


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_flipped(f : bool) -> void:
	if f != flipped:
		flipped = f
		queue_redraw()
		if _viz != null:
			_viz.scale.x = -1.0 if flipped else 1.0

func set_weapon_angle(a : float) -> void:
	a = clampf(a, -90.0, 90.0)
	if not is_equal_approx(weapon_angle, a):
		weapon_angle = a
		queue_redraw()
		if _weapon != null:
			_weapon.rotation_degrees = weapon_angle

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_sprite.visible = Engine.is_editor_hint()
	_viz.scale.x = -1.0 if flipped else 1.0
	_weapon.rotation_degrees = weapon_angle
	if not Engine.is_editor_hint():
		_Start()

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	var to : Vector2 = Vector2.RIGHT.rotated(deg_to_rad(weapon_angle)) * 20.0
	draw_line(Vector2.ZERO, to, Color.AQUA, 1.0, true)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Die() -> void:
	if _dead: return
	_sprite.visible = false
	_explosion_fire.explode()
	_dead = true
	await _explosion_fire.finished
	queue_free()

func _Start() -> void:
	if _active: return
	_active = true
	await get_tree().create_timer(idle_time).timeout
	_sprite.play(ANIM_TELEPORT_IN)
	_sprite.visible = true

func _AttackStage() -> void:
	if not _active: return
	await get_tree().create_timer(PRE_CHARGE_TIME).timeout
	_sprite.play(ANIM_CHARGE)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_dead() -> void:
	_Die.call_deferred()

func _on_animation_finished() -> void:
	match _sprite.animation:
		ANIM_TELEPORT_IN:
			_sprite.play(ANIM_IDLE)
			_hitbox.disable_hitbox(false)
			_AttackStage.call_deferred()
		ANIM_TELEPORT_OUT:
			_active = false
			_Start()
		ANIM_CHARGE:
			if projectile_container != null and _weapon != null:
				_weapon.press_trigger(projectile_container)
			_sprite.play(ANIM_TELEPORT_OUT)
			_hitbox.disable_hitbox(true)
