extends Label

func _ready() -> void:
	text = "HP " + str(Game.PlayerHP)
	Game.stats_changed.connect(_on_stats_changed)

func _on_stats_changed() -> void:
	text = "HP " + str(Game.PlayerHP)
	print("HP label update ->", Game.PlayerHP)
