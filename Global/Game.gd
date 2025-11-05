extends Node

const START_HP := 20          # starting HP for each run
const WIN_GOLD := 8           # gold needed to win

var PlayerHP: int = START_HP
var Gold: int = 0
signal stats_changed

var _won := false
var _instructions_hidden := false

func _ready() -> void:
	print("Game started")

# ----- Public API -----
func set_hp(v: int) -> void:
	PlayerHP = clamp(v, 0, 9999)
	stats_changed.emit()

func add_gold(n: int) -> void:
	Gold = max(0, Gold + n)
	stats_changed.emit()

	# Hide instructions on first coin
	if not _instructions_hidden and Gold >= 1:
		_hide_instruction_label()
		_instructions_hidden = true

	_check_win_condition()

func damage_player(n: int) -> void:
	set_hp(PlayerHP - abs(n))

func reset_run() -> void:
	# Call this before starting a new game or when returning to main
	PlayerHP = START_HP
	Gold = 0
	_won = false
	_instructions_hidden = false
	stats_changed.emit()

# ----- Win flow -----
func _check_win_condition() -> void:
	if _won:
		return
	if Gold >= WIN_GOLD:
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
	# Reset state so the next run starts fresh
	reset_run()
	get_tree().change_scene_to_file("res://main.tscn")

# ----- UI helpers -----
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
