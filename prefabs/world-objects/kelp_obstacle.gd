extends Node2D

@export var collider : Area2D
@export var damage : int
@export var knockbackSpeed : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collider.body_entered.connect(on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_node("AnimatedSprite2D").play("idle")
	
func on_body_entered(collision) -> void:
	if collision.name == "Player":
		if !collision.is_shark_dash():
			collision.lose_fish(damage)
			collision.set_knockback_vars(collision.position - global_position, knockbackSpeed)
		else:
			queue_free()
		
