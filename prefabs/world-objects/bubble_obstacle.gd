extends Node2D

@export var collider : Area2D
@export var direction : Vector2
@export var bubbleSpeed : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collider.body_entered.connect(on_body_entered)
	collider.body_exited.connect(on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func on_body_entered(collision) -> void:
	if collision.name == "Player":
		collision.set_bubble_velocity(bubbleSpeed * direction)
		
		
func on_body_exited(collision) -> void:
	if collision.name == "Player":
		collision.set_bubble_velocity(Vector2.ZERO)
