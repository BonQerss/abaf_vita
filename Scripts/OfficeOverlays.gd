extends Node2D

var winkPlay = false
var whichHonk = 0
var randOffice = RandomNumberGenerator.new()
var secretOffice = {"val": 0, "shadowSeen": false, "guySeen": false, "suitSeen": false}
var time = OS.get_datetime()

signal pumpkin_on()
signal tree_on()

func _ready():
	$Wavy.play()
	if not SceneControl.performant:
		$Particles2D.visible = true
		$Particles2D.emitting = true
	else:
		$Particles2DCPU.visible = true
		$Particles2DCPU.emitting = true
	$Particles2D2.emitting = true
	$Particles2D3.emitting = true
	if SceneControl.currentLevel == 9:
		if not SceneControl.performant:
			$Particles2D4.visible = true
			$Particles2D4.emitting = true
		else:
			$Particles2D4CPU.visible = true
			$Particles2D4CPU.emitting = true
	elif SceneControl.currentLevel == 8:
		$AudioStreamPlayer2D.position.x = 2800
	randOffice.randomize()
	if time["month"] == 10 and time["day"] >= 30:
		$Pumpkin.visible = true
		emit_signal("pumpkin_on")
	if time["month"] == 12 and (time["day"] == 24 or time["day"] == 25):
		emit_signal("tree_on")

func _on_Center_end_fire():
	$PistolSprite.visible = true

func _on_CameraSystem_air_on(airOn):
	if airOn:
		$Wavy.play("fast")
		$Particles2D.process_material.set("initial_velocity", 500.0)
	else:
		$Wavy.play("default")
		$Particles2D.process_material.set("initial_velocity", 60.0)

func _on_BulbExplode_animation_finished():
	$BulbExplode.visible = false

func _on_FredWink_animation_finished():
	winkPlay = false

func _on_CameraSystem_check_secret():
	secretOffice.val = randOffice.randi_range(1, 25000)
	
	if secretOffice.val == 5891 and not secretOffice.shadowSeen:
		$ShadowSprite / AnimationPlayer.play("ShadowOut")
		$ShadowSprite / AudioStreamPlayer2D.play()
		secretOffice.shadowSeen = true
	elif secretOffice.val == 2323 and not secretOffice.guySeen:
		$Guy / AnimationPlayer.play("GuySneak")
		secretOffice.guySeen = true
	elif secretOffice.val == 8585 and not secretOffice.suitSeen:
		$SuitShh / AnimationPlayer.play("Shhh")
		$SuitShh / AudioStreamPlayer.play()
		secretOffice.suitSeen = true
