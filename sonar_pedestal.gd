extends Node2D

@export var recoveryArea : Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	recoveryArea.body_entered.connect(on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_node("AnimatedSprite2D").play("idle")

func on_body_entered(collision) -> void:
	if collision.name == "Player":
		collision.call_deferred("regroup_fish")
		recoveryArea.get_node("AnimatedSprite2D").play("sonar")
