extends Node2D

var playerRef : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerRef = get_parent().get_node("Player")
	
	for enemy in get_node("EnemyContainer").get_children():
		enemy.assign_player(playerRef)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
