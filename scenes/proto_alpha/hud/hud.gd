extends MarginContainer


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@onready var _player_info: VBoxContainer = %PlayerInfo

@onready var _health_progress: ProgressBar = %HealthProgress
@onready var _energy_progress: ProgressBar = %EnergyProgress
@onready var _lbl_lives: Label = %LBL_Lives
@onready var _special_icon: TextureRect = %SpecialIcon

@onready var _boss_bar: PanelContainer = %BossBar
@onready var _boss_progress: ProgressBar = %BossProgress
@onready var _grower: Grower = %Grower


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_boss_bar.visible = false
	Relay.player_rect_changed.connect(_on_player_rect_changed)
	Relay.health_changed.connect(_on_health_changed)
	Relay.energy_changed.connect(_on_energy_changed)
	Relay.special_selected.connect(_on_special_selected)
	Relay.boss_health_changed.connect(_on_health_changed.bind(true))
	Relay.boss_dead.connect(_on_boss_dead)
	Relay.boss_removed.connect(_on_boss_dead)
	Game.State.changed.connect(_on_game_state_changed)
	_on_game_state_changed()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_game_state_changed() -> void:
	_lbl_lives.text = "%d"%[Game.State.lives]

func _on_player_rect_changed(pr : Rect2) -> void:
	if _player_info == null: return
	var pir : Rect2 = _player_info.get_rect()
	pir.position = Vector2(
		get_theme_constant("margin_left"),
		get_theme_constant("margin_top")
	)
	if pir.intersects(pr):
		_player_info.size_flags_vertical = Control.SIZE_SHRINK_END
	else:
		_player_info.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

func _on_special_selected(special : GameState.Special) -> void:
	_special_icon.texture = Game.Get_Special_Icon(special)

func _on_health_changed(health : int, max_health : int, is_boss : bool = false) -> void:
	var health_f : float = float(health)
	if is_boss:
		if not _boss_bar.visible:
			var max_f : float = float(max_health)
			_boss_progress.max_value = max_f
			_grower.open()
		_boss_progress.value = health_f
	else:
		_health_progress.value = health_f

func _on_energy_changed(special : GameState.Special) -> void:
	if Game.State == null or _energy_progress == null: return
	var energy : int = Game.State.get_energy_level(special)
	var eprog : float = (float(energy) / float(GameState.MAX_ENERGY)) * 100.0
	_energy_progress.value = eprog

func _on_boss_dead() -> void:
	_grower.close()
	#_boss_bar.visible = false
