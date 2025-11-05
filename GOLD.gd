extends Label

func _ready() -> void:
	text = "GOLD " + str(Game.Gold)
	Game.stats_changed.connect(_on_stats_changed)

func _on_stats_changed() -> void:
	text = "GOLD " + str(Game.Gold)
	print("GOLD label update ->", Game.Gold)
