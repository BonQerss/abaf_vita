extends Node2D

var timeAware = 0.0
var inRight = false
var inLeft = false
var undistorted = false
var handStart = false
var turnHints = true
var endStart = false

var mouseRel = 0.0
var prevCenter = 0.0

var animDelay = 0.0

var timeTexts = - 1
var timeTextsMax = [2, 5, 7, 7, 7, 5, 7, 5]

var dialogTexts = ["", "Man 1: They should be all ready to go now.", "Man 2: Yeah mister, they haven't moved this good since yesteryear!", "Man 2: Like that whole thing with Chica shootin' an iron, what the world?", "Man 2: I ain't understand a lick of it, but it sure is somethin'. Thank you kindly.", "Man 1: It's been a pleasure.", "Man 2: Say, how about you stay around a bit? I cook a mean [unintelligible]", "Man 1: I have to go, sorry."]
var textIndex = 0

func _ready():
	if SceneControl.performant:
		$BackBufferCopy / BlurRect.visible = false
	$BonIdle.play("default")
	$ChicIdle.play("chicBack")
	$Center / ManLabel2.text = dialogTexts[textIndex]
	$Center / AudioStreamPlayer2.volume_db = - 80
	$Center / AudioStreamPlayer2.play()

func _process(delta):
	#print("Static RAM:", OS.get_static_memory_usage())
	#print("Dynamic RAM:", OS.get_dynamic_memory_usage())
	if timeAware >= 36.5:
		if not endStart:
			$FogRect / AnimationPlayer.play("EndDistort")
			$Center / Whail.play()
			endStart = true
	else:
		timeAware += delta
	
	if timeAware >= 18 and not handStart:
		$Center / FredHand / AnimationPlayer.play("HandUp")
		$Center / FredHand / AudioStreamPlayer2D.play()
		$Center / FredHand / AudioStreamPlayer.play()
		handStart = true
	
	prevCenter = $Center.position.x
	
	
	if undistorted:
		mouseRel = clamp((abs(get_global_mouse_position().x - $Center.position.x - 960) - 200), 0, 1920) * 1.5
		$Center.position.x += ((delta * mouseRel) * - sign($Center.position.x + 960 - get_global_mouse_position().x))
		$Center.position.x = clamp($Center.position.x, - 1420, 1420)
	
	$FogRect.rect_position.x = $Center.position.x
	$OutRect.rect_position.x = $Center.position.x
	$BackBufferCopy.position.x = $Center.position.x
	
	
	if animDelay >= 1.2:
		if $BonIdle.animation == "default":
			$BonIdle.play("bonBack")
			$ChicIdle.play("chicBack")
		else:
			$BonIdle.play("default")
			$ChicIdle.play("default")
		animDelay = 0
	else:
		animDelay += delta
	
	
	if timeTexts >= 0:
		if timeTexts > timeTextsMax[textIndex]:
			if textIndex < dialogTexts.size():
				textIndex += 1
				$Center / ManLabel2.text = dialogTexts[textIndex]
				timeTexts = 0
				ManText_dial_sound(textIndex)
			else:
				timeTexts = - 1
				$Center / ManLabel2.visible = false
		else:
			timeTexts += delta
	
	if prevCenter == $Center.position.x:
		$Center / AudioStreamPlayer2.volume_db = - 80
	else:
		$Center / AudioStreamPlayer2.volume_db = - 10
		if turnHints and undistorted:
			$Center / TurnRight / AnimationPlayer.play("TurnFades")
			turnHints = false

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _on_RightArea2D_mouse_entered():
	inRight = true

func _on_LeftArea2D_mouse_entered():
	inLeft = true

func _on_RightArea2D_mouse_exited():
	inRight = false

func _on_LeftArea2D_mouse_exited():
	inLeft = false

func UndistortDone():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	undistorted = true
	$Center / TurnLeft.visible = true
	$Center / TurnRight.visible = true
	timeTexts = 0
	$Center / ManText.StartTip()

func HandStuffA():
	$Center / FredHand.play("default")
	$Center / FredHand / AnimationPlayer.play("HandIdle")
	$Center / FredHand / AudioStreamPlayer2D2.play()

func HandStuffB():
	$Center / FredHand / AnimationPlayer.play("HandDown")
	$Center / FredHand / AudioStreamPlayer2D.play()

func EndDistortDone():
	SceneTransition.NextScene("res://Scenes/Menu.tscn", self)

func ManText_dial_sound(which):
	print(which)
	match (which):
		0:
			pass
		1:
			$ManSounds / AudioStreamPlayer2D5.play()
		2:
			$ManSounds / AudioStreamPlayer2D.play()
		3:
			$ManSounds / AudioStreamPlayer2D2.play()
		4:
			$ManSounds / AudioStreamPlayer2D3.play()
		5:
			$ManSounds / AudioStreamPlayer2D7.play()
			$ManSounds / AudioStreamPlayer.play()
		6:
			$ManSounds / AudioStreamPlayer2D4.play()
		7:
			$ManSounds / AudioStreamPlayer2D6.play()
