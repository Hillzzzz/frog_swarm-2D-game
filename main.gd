extends Node2D


# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	Utils.save_game()
	Utils.load_game()
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")
