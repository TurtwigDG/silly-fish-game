extends CharacterBody2D

@export var tetherDistance : float
@export var moveSpeed : float
var currentDir : Vector2

@export var stunWindow : float
@export var knockbackWindow : float
@export var knockbackSpeed : float
var stunTimer : float
var stunned : bool

@export var collectionArea : Area2D
@export var sprite : AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentDir = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	currentDir = currentDir.normalized()
	stunned = false
	
	collectionArea.body_entered.connect(on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !stunned:
		if abs(global_position.x - get_parent().get_parent().position.x) > tetherDistance:
			currentDir.x *= -1 
		if abs(global_position.y - get_parent().get_parent().position.y) > tetherDistance:
			currentDir.y *= -1
		
		velocity = currentDir * moveSpeed
	else:
		stunTimer += delta
		if stunTimer <= knockbackWindow:
			velocity = currentDir * knockbackSpeed
		else:
			velocity = Vector2.ZERO
			sprite.rotation = 0
		if stunTimer >= stunWindow:
			queue_free()
		
	move_and_slide()

func take_hit():
	stunned = true
	stunTimer = 0
	sprite.rotation = currentDir.angle()
	
	print(position)
	
func on_body_entered(collision) -> void:
	if collision.name == "Player" and stunned and stunTimer >= knockbackWindow:
		collision.call_deferred("recover_fish")
		queue_free()
