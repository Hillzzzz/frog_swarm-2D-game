extends CharacterBody2D

@export var SPEED: float = 70.0
@export var DAMAGE_TO_PLAYER: int = 3       # damage per tick
@export var GOLD_REWARD: int = 1            # gold on frog death
@export var TICK_INTERVAL: float = 0.5      # seconds between damage ticks

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var chasing: bool = false
var player: CharacterBody2D = null

# --- NEW: continuous damage state ---
var _player_in_hitbox: bool = false
var _tick_accum: float = 0.0
var _dead: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var frames: SpriteFrames = anim.sprite_frames

const ANIM_IDLE := "idle"
const ANIM_JUMP := "jump"
const ANIM_DEATH := "death"

func _ready() -> void:
	if frames and frames.has_animation(ANIM_IDLE):
		anim.play(ANIM_IDLE)

func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	# chase
	if chasing and is_instance_valid(player) and not _dead:
		var dir := (player.global_position - global_position).normalized()
		velocity.x = dir.x * SPEED
		anim.flip_h = velocity.x > 0.0
		if anim.animation != ANIM_DEATH and frames and frames.has_animation(ANIM_JUMP):
			if anim.animation != ANIM_JUMP:
				anim.play(ANIM_JUMP)
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		if anim.animation != ANIM_DEATH and frames and frames.has_animation(ANIM_IDLE):
			if anim.animation != ANIM_IDLE:
				anim.play(ANIM_IDLE)

	move_and_slide()

	# --- continuous damage while in hitbox ---
	if _player_in_hitbox and is_instance_valid(player) and not _dead:
		_tick_accum += delta
		if _tick_accum >= TICK_INTERVAL:
			Game.damage_player(DAMAGE_TO_PLAYER)
			_tick_accum = 0.0

func _on_player_detection_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.name == "Player":
		player = body as CharacterBody2D
		chasing = true

func _on_player_detection_body_exited(body: Node) -> void:
	if body == player:
		chasing = false
		player = null

# Death trigger: your existing Area2D -> body_entered
func _on_player_death_body_entered(body: Node) -> void:
	if _dead: return
	if body.name == "Player":
		print("frog died -> +1 gold")
		Game.add_gold(1)
		_dead = true
		_player_in_hitbox = false
		_tick_accum = 0.0
		if frames and frames.has_animation(ANIM_DEATH):
			if anim.animation != ANIM_DEATH:
				anim.play(ANIM_DEATH)
			await anim.animation_finished
		queue_free()

# Hitbox: start/stop ticking while player overlaps
func _on_player_death_2_body_entered(body: Node2D) -> void:
	if _dead: return
	if body.name == "Player":
		_player_in_hitbox = true
		if player == null and body is CharacterBody2D:
			player = body as CharacterBody2D
		# optional: immediate first hit
		# Game.damage_player(DAMAGE_TO_PLAYER)

func _on_player_death_2_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		_player_in_hitbox = false
		_tick_accum = 0.0
