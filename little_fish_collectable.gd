extends Node2D

@export var upgradeName : String
@export var collider : Area2D

@export var knockbackSpeed : float

var collected : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collider.body_entered.connect(_on_body_entered)
	collected = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_node("AnimatedSprite2D").play("idle")
	
func _on_body_entered(collision) -> void:
	if collision.has_method("unlock_upgrade") and !collected:
		if !collision.is_shark_dash():
			collision.set_knockback_vars(collision.position - global_position, knockbackSpeed)
		else:
			collision.unlock_upgrade(upgradeName)
			visible = false
			collected = true
		
func _get_state():
	return collected
	
func _set_state(value : bool):
	collected = value
	if value == true:
		visible = false
