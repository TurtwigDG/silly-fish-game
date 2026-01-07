extends Node2D

@export var wanderYRange : float
@export var wanderXRange : float
@export var attackYRange : float
@export var attackXRange : float

@export var wanderSwimSpeed : float
@export var attackSwimSpeed : float

@export var dashRange : float
@export var dashSpeed : float
@export var dashWindow : float
@export var chargeWindow : float
@export var rechargeWindow : float
var dashTimer : float

@export var damage : int
@export var knockbackSpeed : float

var aiState : int
# state 0: wander
# state 1: attack
# state 2: dash

var wanderPoint : Vector2
var tetherPoint : Vector2
var dashDir : Vector2

var playerRef : Node2D

@export var sprite : AnimatedSprite2D
@export var hurtbox : Area2D
@export var hitbox : Area2D

var hasHit : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	aiState = 0
	dashTimer = 1000
	tetherPoint = global_position
	wanderPoint = tetherPoint
	
	hurtbox.body_entered.connect(on_hurtbox_entered)
	hitbox.body_entered.connect(on_hitbox_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playerRef != null:
		dashTimer += delta
		
		
		if aiState == 0:
			sprite.play("idle")
			if (abs(playerRef.position.x - tetherPoint.x) <= attackXRange) and (abs(playerRef.position.y - tetherPoint.y) <= attackYRange):
				aiState = 1
			if global_position.distance_to(wanderPoint) <= 1:
				wanderPoint = Vector2(tetherPoint.x + randf_range(-1 * wanderXRange, wanderXRange), tetherPoint.y + randf_range(-1 * wanderYRange, wanderYRange))
			else:
				sprite.rotation = (wanderPoint - global_position).angle()
				hitbox.rotation = (wanderPoint - global_position).angle()
				if wanderPoint.x - global_position.x < 0:
					sprite.flip_v = true
				else:
					sprite.flip_v = false
				global_position += (wanderPoint - global_position).normalized() * delta * wanderSwimSpeed
			
		elif aiState == 1:
			sprite.play("idle")
			if (abs(playerRef.position.x - tetherPoint.x) > attackXRange) or (abs(playerRef.position.y - tetherPoint.y) > attackYRange):
				aiState = 0
			elif global_position.distance_to(playerRef.position) <= dashRange:
				dashDir = global_position.direction_to(playerRef.position)
				dashTimer = 0
				aiState = 2
			else:
				sprite.rotation = (playerRef.position - global_position).angle()
				hitbox.rotation = (playerRef.position - global_position).angle()
				
				if playerRef.position.x - global_position.x < 0:
					sprite.flip_v = true
				else:
					sprite.flip_v = false
				global_position += global_position.direction_to(playerRef.position) * delta * attackSwimSpeed
		
		elif aiState == 2:
			sprite.play("dash")
			sprite.rotation = dashDir.angle()
			if dashTimer <= chargeWindow:
				hasHit = false
			elif dashTimer <= dashWindow:
				if !hasHit:
					for body in hitbox.get_overlapping_bodies():
						if body.name == "Player":
							if !body.is_invincible():
								print("HIT ON STAY")
								body.lose_fish(damage)
								body.set_knockback_vars(body.position - global_position, knockbackSpeed)
								hasHit = true
				global_position += dashDir * dashSpeed * delta
			elif dashTimer <= rechargeWindow:
				pass
			else:
				aiState = 0
	
func assign_player(reference) -> void:
	playerRef = reference
	
func on_hurtbox_entered(collision) -> void:
	if collision.name == "Player":
		print("HIT ON HURTBOX")
		if !collision.is_shark_dash():
			if !collision.is_invincible() and (aiState != 2 or (aiState == 2 and (dashTimer >= dashWindow or dashTimer <= chargeWindow))):
				collision.set_knockback_vars(collision.position - global_position, knockbackSpeed)
		else:
			queue_free()
			
func on_hitbox_entered(collision) -> void:
	if collision.name == "Player" and (aiState == 2 and dashTimer <= dashWindow and dashTimer >= chargeWindow):
		if !collision.is_invincible() and !hasHit:
			print("HIT ON ENTER")
			collision.lose_fish(damage)
			collision.set_knockback_vars(collision.position - global_position, knockbackSpeed)
			hasHit = true
