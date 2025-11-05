extends CharacterBody2D

@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0

@onready var anim: AnimationPlayer    = $AnimationPlayer
@onready var sprite: AnimatedSprite2D   = $"CollisionShape2D/AnimatedSprite2D"  # <- fixed path

func _ready() -> void:
	if anim and anim.has_animation("Idle"):
		anim.play("Idle")
	if sprite == null:
		push_error("Player: AnimatedSprite2D not found at CollisionShape2D/AnimatedSprite2D")
		Game.add_gold(1)       # should make GOLD label go to 1 immediately
		Game.damage_player(5)  # should make HP label go to 95 immediately
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if anim and anim.has_animation("jump") and anim.current_animation != "jump":
			anim.play("jump")

	# Horizontal movement + flip
	var direction := Input.get_axis("ui_left", "ui_right")  # -1, 0, 1
	if direction != 0:
		velocity.x = direction * SPEED
		if sprite:
			sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	# Animation state (AnimationPlayer drives clips)
	if not is_on_floor():
		if anim:
			if anim.has_animation("fall"):
				if anim.current_animation != "fall":
					anim.play("fall")
			elif anim.has_animation("jump"):
				if anim.current_animation != "jump":
					anim.play("jump")
	else:
		if anim:
			if direction != 0 and anim.has_animation("Run"):
				if anim.current_animation != "Run":
					anim.play("Run")
			elif anim.has_animation("Idle"):
				if anim.current_animation != "Idle":
					anim.play("Idle")

	move_and_slide()

	# Optional: restart if dead (uses your Game autoload)
	if Game.PlayerHP <= 0:
		Game.reset_run()
		get_tree().change_scene_to_file("res://main.tscn")
