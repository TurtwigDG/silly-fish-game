extends CharacterBody2D

var moveDir : Vector2
@export var slowSwimSpeed : float
@export var fastSwimSpeed : float
var currentSwimSpeed : float

@export var sharkDashSpeed : float
@export var sharkSwimSpeed : float

@export var dashSpeed : float
@export var dashWindow : float
var dashTimer : float
@export var dashCooldownWindow : float
var dashCooldownTimer : float

@export var spriteContainer : Node2D
@export var sprite : AnimatedSprite2D
@export var sfxSource : Node2D

var upgrades : Dictionary

@export var maxFishCount : int
var currentFishCount : int
@export var fishObject : PackedScene

var bubbleVelocity : Vector2

var knockbackTimer : float
@export var knockbackWindow : float
var knockbackDir : Vector2
var knockbackSpeed : float

@export var invincibilityWindow : float
var invincibilityTimer : float

@export var sonarChargeWindow : float
@export var sonarActiveWindow : float
var sonarActiveTimer : float
var sonarChargeTimer : float
var sonarCharging : bool

@export var sonarHitbox : Area2D

@export var hatLight : PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	knockbackTimer = 1000
	dashTimer = 1000
	dashCooldownTimer = 1000
	invincibilityTimer = 1000
	sonarActiveTimer = 1000
	sonarChargeTimer = 0
	currentSwimSpeed = slowSwimSpeed
	upgrades = {"Sonar": false, "Shark": true}
	
	regroup_fish()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	dashTimer += delta
	dashCooldownTimer += delta
	knockbackTimer += delta
	invincibilityTimer += delta
	sonarActiveTimer += delta
	
	if Input.is_action_just_pressed("sonar") and !sonarCharging and upgrades["Sonar"]:
		sonarChargeTimer = 0
		sonarCharging = true
	
	if Input.is_action_pressed("sonar") and sonarActiveTimer >= sonarActiveWindow and sonarCharging:
		sonarChargeTimer += delta
		if sonarChargeTimer >= sonarChargeWindow:
			sonarChargeTimer = 0
			sonarActiveTimer = 0
			sonarCharging = false
		
	if Input.is_action_just_released("sonar"):
		sonarChargeTimer = 0
		sonarCharging = false
		
	if sonarActiveTimer <= sonarActiveWindow:
		sfxSource.get_node("Sonar").play()
		sonarHitbox.get_node("AnimatedSprite2D").play("sonar")
		for littleFish in sonarHitbox.get_overlapping_bodies():
			print("Overlap: " + littleFish.name)
			if littleFish.has_method("little_fish_recover"):
				print("LittleFish")
				littleFish.little_fish_recover(self)
	else:
		sonarHitbox.get_node("AnimatedSprite2D").play("default")
	
	if dashTimer > dashWindow and sonarActiveTimer >= sonarActiveWindow and !sonarCharging:
		moveDir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
		moveDir = moveDir.normalized()
	elif sonarActiveTimer <= sonarActiveWindow or sonarCharging:
		moveDir = Vector2.ZERO
		
	
	if Input.is_action_just_pressed("dash") and dashCooldownTimer >= dashCooldownWindow and bubbleVelocity == Vector2.ZERO:
		sfxSource.get_node("Dash").play()
		dashTimer = 0
		dashCooldownTimer = 0
		if !upgrades["Shark"]:
			currentSwimSpeed = fastSwimSpeed
		else:
			spriteContainer.get_node("SharkBackdrop").get_node("AnimatedSprite2D").visible = true
			spriteContainer.get_node("SharkBackdrop").get_node("AnimatedSprite2D").play("dash")
			currentSwimSpeed = sharkSwimSpeed
		
	if Input.is_action_just_released("dash"):
		spriteContainer.get_node("SharkBackdrop").get_node("AnimatedSprite2D").visible = false
		currentSwimSpeed = slowSwimSpeed
		
	update_sprite()
	handle_animations()
	
	if moveDir != Vector2.ZERO and sfxSource.get_node("Swim").playing == false:
		if currentSwimSpeed == fastSwimSpeed:
			sfxSource.get_node("Swim").pitch_scale = 2 + randf_range(-0.2, 0.2)
		else:
			sfxSource.get_node("Swim").pitch_scale = 1 + randf_range(-0.1, 0.1)
		sfxSource.get_node("Swim").play()
	
	if knockbackTimer >= knockbackWindow:
		if !upgrades["Shark"] and dashTimer <= dashWindow:
			velocity = moveDir * dashSpeed
		elif upgrades["Shark"] and dashTimer <= dashWindow:
			velocity = moveDir * sharkDashSpeed
		else:
			velocity = moveDir * currentSwimSpeed
	else:
		velocity = knockbackDir * knockbackSpeed
	
	velocity += bubbleVelocity
	
	move_and_slide()

func update_sprite() -> void:
	if invincibilityTimer <= invincibilityWindow:
		sprite.visible = !sprite.visible
	else:
		sprite.visible = true
	
	if moveDir != Vector2.ZERO:
		spriteContainer.rotation = moveDir.angle()
		if moveDir.x < 0:
			sprite.flip_v = true
			spriteContainer.get_node("SharkBackdrop").get_node("AnimatedSprite2D").flip_v = true
		else:
			sprite.flip_v = false
			spriteContainer.get_node("SharkBackdrop").get_node("AnimatedSprite2D").flip_v = false
		for fish in get_node("FishContainer").get_children():
			fish.sprite.rotation = moveDir.angle()
			if moveDir.x < 0:
				fish.sprite.flip_v = true
			else:
				fish.sprite.flip_v = false
			
func handle_animations() -> void:
	if !upgrades["Sonar"]:
		hatLight.visible = false
		if dashTimer <= dashWindow:
			sprite.play("dash")
		elif moveDir != Vector2.ZERO:
			sprite.play("swim")
		else:
			sprite.play("idle")
	else:
		hatLight.visible = true
		if dashTimer <= dashWindow:
			sprite.play("dashHat")
		elif moveDir != Vector2.ZERO:
			sprite.play("swimHat")
		else:
			sprite.play("idleHat")
		
	for fish in get_node("FishContainer").get_children():
		if moveDir != Vector2.ZERO:
			fish.sprite.play("swim")
		else:
			fish.sprite.play("idle")
			
func regroup_fish() -> void:
	for fish in get_node("FishContainer").get_children():
		get_node("FishContainer").remove_child(fish)
		fish.queue_free()
	
	for i in range(maxFishCount):	
		var tempFish = fishObject.instantiate()
		get_node("FishContainer").add_child(tempFish)
		tempFish.position = Vector2.ZERO
	
	currentFishCount = maxFishCount
	
func get_fish(num : int) -> void:
	maxFishCount += num
	currentFishCount += num
	
	print(maxFishCount)
	
	for i in range(num):
		var tempFish = fishObject.instantiate()
		get_node("FishContainer").add_child(tempFish)
		tempFish.position = Vector2.ZERO
	
func recover_fish() -> void:
	currentFishCount += 1
	
	var tempFish = fishObject.instantiate()
	get_node("FishContainer").add_child(tempFish)
	tempFish.position = Vector2.ZERO
	
	
func lose_fish(num : int) -> void:
	print("HIT")
	if currentFishCount > 0:
		for i in range(num):
			if currentFishCount != 0:
				var tempFish = get_node("FishContainer").get_child(0)
				get_node("FishContainer").remove_child(tempFish)
				tempFish.position = position
				tempFish.take_hit()
				call_deferred("reparent_fish", tempFish)
				currentFishCount -= 1
			else:
				currentFishCount = 0
				return
	else:
		pass
		# die

func set_bubble_velocity(newVelocity) -> void:
	bubbleVelocity = newVelocity
	
func set_knockback_vars(direction, speed) -> void:
	invincibilityTimer = 0
	knockbackDir = direction.normalized()
	knockbackSpeed = speed
	knockbackTimer = 0

func is_shark_dash() -> bool:
	return dashTimer <= dashWindow and upgrades["Shark"]
	
func is_invincible() -> bool:
	return invincibilityTimer <= invincibilityWindow
	
func reparent_fish(tempFish) -> void:
	get_parent().add_child(tempFish)

func unlock_upgrade(upgradeString) -> void:
	if upgradeString == "LittleFish":
		call_deferred("get_fish", 1)
	else:
		upgrades[upgradeString] = true
