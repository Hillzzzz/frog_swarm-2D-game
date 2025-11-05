extends Node

const SAVE_PATH := "user://savegame.json"

func save_game() -> void:
	# Make sure Game.gd has these exact properties:
	# var PlayerHP: int = 100
	# var Gold: int = 0
	var data := {
		"PlayerHP": Game.PlayerHP,
		"Gold": Game.Gold
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Game saved to ", SAVE_PATH)


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found at ", SAVE_PATH)
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var data = JSON.parse_string(text)
	if typeof(data) == TYPE_DICTIONARY:
		# Use the same key names you saved with ("PlayerHP" and "Gold")
		Game.PlayerHP = int(data.get("PlayerHP", Game.PlayerHP))
		Game.Gold = int(data.get("Gold", Game.Gold))
		print("Game loaded: HP=", Game.PlayerHP, " Gold=", Game.Gold)
	else:
		push_error("Save file corrupted or invalid JSON.")
