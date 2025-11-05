extends Area2D

@export var HEAL_AMOUNT: int = 5

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		# Heal the player, clamped via Game.set_hp()
		Game.set_hp(Game.PlayerHP + HEAL_AMOUNT)

		# Cute float-and-fade animation
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position - Vector2(0, 35), 0.35)
		tween.tween_property(self, "modulate:a", 0.0, 0.25)
		tween.tween_callback(queue_free)
