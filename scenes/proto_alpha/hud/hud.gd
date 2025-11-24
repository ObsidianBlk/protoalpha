extends MarginContainer


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@onready var _health_progress: ProgressBar = %HealthProgress
@onready var _lbl_lives: Label = %LBL_Lives

@onready var _boss_bar: PanelContainer = %BossBar
@onready var _boss_progress: ProgressBar = %BossProgress
@onready var _grower: Grower = %Grower


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_boss_bar.visible = false
	Relay.health_changed.connect(_on_health_changed)
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

func _on_boss_dead() -> void:
	_grower.close()
	#_boss_bar.visible = false
