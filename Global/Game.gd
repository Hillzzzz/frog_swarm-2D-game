extends Node

var PlayerHP: int = 20
var Gold: int = 0
signal stats_changed

var _won := false
var _instructions_hidden := false  # track if we've already hidden it

func _ready() -> void:
	print("Game started")

func set_hp(v: int) -> void:
	PlayerHP = clamp(v, 0, 9999)
	stats_changed.emit()

func add_gold(n: int) -> void:
	Gold = max(0, Gold + n)
	stats_changed.emit()

	# Hide the instruction label the first time gold increases
	if not _instructions_hidden and Gold >= 1:
		_hide_instruction_label()
		_instructions_hidden = true

	_check_win_condition()

func damage_player(n: int) -> void:
	set_hp(PlayerHP - abs(n))

func _check_win_condition() -> void:
	if _won:
		return
	if Gold >= 8:
		_won = true
		print("🎉 You Win! 🎉")
		await _show_win_message_and_return()

func _show_win_message_and_return() -> void:
	var label: Label = null

	var scene := get_tree().current_scene
	if scene:
		label = scene.get_node_or_null("UI/WinLabel")
	if label == null:
		label = get_node_or_null("/root/World/UI/WinLabel")

	if label:
		label.text = "YOU WIN!"
		label.visible = true

	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://main.tscn")

# --- NEW FUNCTION ---
func _hide_instruction_label() -> void:
	var scene := get_tree().current_scene
	var instr_label: Label = null
	if scene:
		instr_label = scene.get_node_or_null("UI/instruction")
	if instr_label == null:
		instr_label = get_node_or_null("/root/World/UI/instruction")

	if instr_label:
		instr_label.visible = false
		print("Instruction label hidden after first gold")
