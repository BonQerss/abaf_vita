extends Node2D

var frontFace = true; var turning = false
var lockView = false
var turnSpeed = 0.72; var mouseRel = 0.0
var bulbHold = false
var scareTurn = false

var mouseRight = false; var mouseLeft = false

var pistol = {"active": false, "fired": false, "lock": false, "eye": false, "haunted": false}
var shocker = {"active": false, "timeShock": - 1, "shockAmt": 16, "overHaunted": 0, "shockHaunt": false, "overLatest": 0}
var hauntedTool = 0

var powerAmt = 0; var powerStr = 1; var powerUsers = 0; var powerLock = false; var timePower = 0
var powerReduce = 1.0

export  var powerSat = 0
var colorBase = Color(1, 1, 1, 1); var colorNew = Color(1, 1, 1, 1)

var timeAmbience = 45; var whichAmbience = 0

signal start_fire()
signal end_fire()
signal pistol_activated(act)
signal pistol_scare()
signal shocker_activated(act)
signal haunted_shock()

func _ready():
	if not SceneControl.firstRight:
		$UserInterface / HitRight / turn.visible = false

func _process(delta):
	if not scareTurn:
		if turning and not $TurnTween.is_active():
			turning = false
			frontFace = not frontFace
			if SceneControl.firstRight and not frontFace:
				SceneControl.firstRight = false
				$UserInterface / HitRight / turn.visible = false
		if mouseRight:
			if not turning and not lockView and not $UserInterface / CameraSystem / MonitorAnim.visible and frontFace:
				$TurnTween.interpolate_property(self, "position:x", position.x, 3180, turnSpeed, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
				$TurnTween.start()
				turning = true
				if SceneControl.firstRight:
					$TurnTween.interpolate_property($UserInterface / HitRight / turn, "modulate", Color(1, 1, 1, 0.59), Color(1, 1, 1, 0), turnSpeed, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
					$TurnTween.start()
		elif mouseLeft:
			if not turning and not lockView and not $UserInterface / CameraSystem / MonitorAnim.visible and not frontFace:
				$TurnTween.interpolate_property(self, "position:x", position.x, 960, turnSpeed, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
				$TurnTween.start()
				turning = true
	
	if powerStr > 1:
		if timePower <= 0:
			UpdatePowerLevel(true)
		else:
			timePower -= delta
		
		if $UserInterface / UIText / PowerTxt / AnimationPlayer.is_playing():
			$UserInterface / UIText / PowerTxt.set("custom_colors/font_color", colorBase.linear_interpolate(colorNew, powerSat / 100.0))
			$UserInterface / UIText / PowerTxt / AnimationPlayer.playback_speed = pow(2, ((powerStr - 1) / 5))
	else:
		if powerAmt > 0:
			if timePower <= 0:
				UpdatePowerLevel(false)
			else:
				timePower -= delta
	
	if powerStr >= 0:
		if powerAmt > 0 and not $UserInterface / UIText / PowerTxt / AnimationPlayer.is_playing():
			if powerStr > 1:
				$UserInterface / UIText / PowerTxt / AnimationPlayer.play("SatAnim")
			else:
				$UserInterface / UIText / PowerTxt / AnimationPlayer.play("ModAnim")
				$UserInterface / UIText / PowerTxt / AnimationPlayer.playback_speed = 1.0
		elif powerAmt == 0 and $UserInterface / UIText / PowerTxt / AnimationPlayer.is_playing():
			$UserInterface / UIText / PowerTxt / AnimationPlayer.stop()
			$UserInterface / UIText / PowerTxt.modulate.a = 1.0
	
	if pistol.active:
		var mouseTarget = Vector2(get_global_mouse_position())
		mouseTarget.y = clamp(get_global_mouse_position().y, 300, 1030)
		if $UserInterface / FoamPistol.position.distance_to(mouseTarget - position + Vector2(960, 540)) > 0.5:
			var dir = mouseTarget - $UserInterface / FoamPistol.position - position + Vector2(960, 540)
			var normDir = dir.normalized()
			var dirDist = dir.length()
			$UserInterface / FoamPistol.move_and_slide(normDir * 14.0 * min(750, dirDist))
			
	
	if shocker.active:
		var mouseTarget = Vector2(get_viewport().get_mouse_position())
		mouseTarget.y = clamp(get_viewport().get_mouse_position().y, 300, 1030)
		if $UserInterface / Shocker / ShockerHold.position.distance_to(mouseTarget - position + Vector2(960, 540)) > 0.5:
			var dir = mouseTarget - $UserInterface / Shocker / ShockerHold.position
			var normDir = dir.normalized()
			var dirDist = dir.length()
			$UserInterface / Shocker / ShockerHold.move_and_slide(normDir * 14.0 * min(750, dirDist))
	
	if bulbHold:
		$UserInterface / BulbFresh.position = get_viewport().get_mouse_position()
	
	
	if not $UserInterface / DialogueSystem.visible:
		if timeAmbience <= 0:
			NextAmbience()
		else:
			timeAmbience -= delta
	
	
	if shocker.timeShock >= 0:
		if shocker.timeShock >= 0.8:
			UpdatePowerSystem( - shocker.shockAmt)
			$UserInterface / Shocker / ShockerHold / AimSprite.self_modulate.a = 1.0
			$UserInterface / CameraSystem / CamVis / CamToolButtons / VentShockButton.modulate.a = 1.0
			shocker.timeShock = - 1
		else:
			shocker.timeShock += delta

func _input(event):
	if event.is_action_pressed("ui_mouse_left"):
		if shocker.active and shocker.timeShock == - 1 and not powerLock:
			StartShock()
	
	if event.is_action_pressed("ui_mouse_right"):
		if pistol.active and not pistol.lock:
			pistol.active = false
			lockView = false
			pistol.fired = false
			$UserInterface / CameraSystem.lockCam = false
			$UserInterface / FoamPistol.visible = false
			$UserInterface / UIText / FireTxt.visible = false
			$UserInterface / CameraSystem.visible = true
			$UserInterface / FoamPistol / PistolSprite.play("default")
			$UserInterface / FoamPistol / AimSprite.visible = true
			$UserInterface / UIText / FireTxt.text = "Left click: Fire\nRight click: Exit"
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			emit_signal("pistol_activated", false)
			emit_signal("end_fire")
			$UserInterface / FoamPistol / AudioStreamPlayer2D.position = Vector2(250, 1800)
			if SceneControl.currentLevel == 7:
				$UserInterface / Shocker.visible = true
		elif shocker.active:
			$UserInterface / CameraSystem.lockCam = false
			$UserInterface / Shocker / ShockerSprite.visible = true
			$UserInterface / Shocker / ShockerButton.visible = true
			lockView = false
			shocker.active = false
			shocker.overHaunted = 0
			$UserInterface / CameraSystem.usingShocker = false
			$UserInterface / Shocker / ShockerHold.visible = false
			$UserInterface / CameraSystem / CamVis / CamToolButtons / VentButton.disabled = false
			$UserInterface / UIText / ShockTxt.visible = false
			$UserInterface / CameraSystem / CamVis / ShockBlockRect1.visible = false
			$UserInterface / CameraSystem / CamVis / ShockBlockRect2.visible = false
			$UserInterface / CameraSystem / Area2D.visible = true
			shocker.overHaunted = 0
			$UserInterface / Shocker / ShockerHold / AimSprite / AnimationPlayer.play("RESET")
			$UserInterface / Shocker / ShockerButton / AudioStreamPlayer2.play()
			emit_signal("shocker_activated", false)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event.is_action_pressed("ui_skip_dial"):
		if $UserInterface / DialogueSystem / DialogueBox / Subtitles.walkX:
			_on_WalkButton_pressed()

func _on_HitRight_mouse_entered():
	mouseRight = true

func _on_HitLeft_mouse_entered():
	mouseLeft = true

func _on_HitRight_mouse_exited():
	mouseRight = false

func _on_HitLeft_mouse_exited():
	mouseLeft = false

func _on_PistolButton_pressed():
	if not shocker.active:
		if not pistol.haunted:
			pistol.active = true
			lockView = true
			$UserInterface / CameraSystem.lockCam = true
			$UserInterface / FoamPistol.position = Vector2(get_global_mouse_position().x - position.x + 960, get_global_mouse_position().y)
			$UserInterface / FoamPistol.visible = true
			$UserInterface / UIText / FireTxt.visible = true
			$UserInterface / CameraSystem.visible = false
			emit_signal("pistol_activated", true)
			emit_signal("start_fire")
			$UserInterface / FoamPistol / AimSprite / AnimationPlayer.play("RESET")
			$UserInterface / FoamPistol / AudioStreamPlayer2D.position = Vector2(250, 0)
			if SceneControl.currentLevel == 7:
				$UserInterface / Shocker.visible = false
		else:
			emit_signal("pistol_scare")
			print("Pistol scare!")
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		if pistol.haunted:
			HauntedShock()

func UpdatePowerSystem(strength):
	if powerStr >= 0:
		powerStr += strength
		
		if powerAmt < 100 and strength > 1.0:
			UpdatePowerLevel(true)
		
		if powerStr == 1 or ((powerStr - strength) == 1):
			$UserInterface / UIText / PowerTxt / AnimationPlayer.stop()
			$UserInterface / UIText / PowerTxt.modulate.a = 1.0

func UpdatePowerLevel(addOn):
	if powerStr >= 0:
		if addOn:
			
			timePower = 1.2 / (powerStr + (powerAmt / 20))
			
			powerAmt += 1
		else:
			
			timePower = (1.8 * powerReduce) / (powerStr + (powerAmt / 20))
			powerAmt -= 1
		
		if powerAmt < 100:
			if powerAmt < 1:
				$UserInterface / UIText / PowerTxt.text = "POWER LOAD:\n" + "NEUTRAL"
				$UserInterface / UIText / PowerTxt.set("custom_colors/font_color", Color(1, 1, 1, 1))
			elif powerAmt < 33:
				$UserInterface / UIText / PowerTxt.text = "POWER LOAD:\n" + "LOW (" + str(powerAmt) + "%)"
				colorBase = Color(1, 1, 1, 1)
				colorNew = Color(1, 0.85, 0.2, 1)
			elif powerAmt < 66:
				$UserInterface / UIText / PowerTxt.text = "POWER LOAD:\n" + "MEDIUM (" + str(powerAmt) + "%)"
				colorBase = Color(1, 0.85, 0.2, 1)
				colorNew = Color(1, 0.45, 0.1, 1)
			else:
				$UserInterface / UIText / PowerTxt.text = "POWER LOAD:\n" + "HIGH (" + str(powerAmt) + "%)"
				colorBase = Color(1, 0.45, 0.1, 1)
				colorNew = Color(1, 0.1, 0.0, 1)
			
			if powerAmt > 0:
				$UserInterface / UIText / PowerTxt.set("custom_colors/font_color", colorBase.linear_interpolate(colorNew, 0.5))
		else:
			$UserInterface / UIText / PowerTxt.text = "POWER LOAD:\nOVERLOAD (" + str(powerAmt) + "%)"
			$UserInterface / UIText / PowerTxt / AnimationPlayer.stop()
			$UserInterface / UIText / PowerTxt.set("custom_colors/font_color", Color(1, 0.1, 0.0, 1))
			if $UserInterface / CameraSystem.camBackup:
				$UserInterface / CameraSystem / CamVis / BlockCam4.visible = true
				$UserInterface / CameraSystem / CamVis / CamButtons / Cam09 / CamDoor.visible = false
			powerStr = - 1
			timePower = 0.1
	else:
		if powerAmt > 1:
			timePower = clamp(((3.0 / powerAmt) * powerReduce), 0.1, 20)
			powerAmt -= 1
			$UserInterface / UIText / PowerTxt.text = "POWER LOAD:\nOVERLOAD (" + str(powerAmt) + "%)"
		else:
			powerStr = 1
			timePower = 0
			if $UserInterface / CameraSystem.camBackup:
				$UserInterface / CameraSystem / CamVis / BlockCam4.visible = false
				$UserInterface / CameraSystem / CamVis / CamButtons / Cam09 / CamDoor.visible = true
				if $UserInterface / CameraSystem / CamVis.visible:
					_on_CameraSystem_device_on(1)

func _on_CameraSystem_disable_bend(bendOn):
	$roomBend.visible = not bendOn

func _on_CameraSystem_device_on(deviceOn):
	UpdatePowerSystem(deviceOn)

func _on_AnimationPlayer_animation_finished(_WinFade):
	$UserInterface / WinTxt.visible = false

func _on_Subtitles_pages_finished():
	$UserInterface / DialogueSystem / Walkie / AnimationPlayer.play("Exit")
	$UserInterface / DialogueSystem / Walkie / AudioStreamPlayer.play()
	$UserInterface / DialogueSystem / DialogueBox / Subtitles.walkX = false
	$UserInterface / DialogueSystem / WalkX.visible = false
	if SceneControl.currentLevel == 9:
		$UserInterface / DialogueSystem / DialogueBox / Subtitles / mgr18Player.stop()

func _on_Subtitles_chars_finished():
	$UserInterface / DialogueSystem / DialogueBox / ArrowSprite / AnimationPlayer.play("ArrowNext")
	$UserInterface / DialogueSystem / Walkie / AnimationPlayer.stop()
	$UserInterface / DialogueSystem / Walkie / AnimationPlayer.advance(0)
	if SceneControl.currentLevel == 9:
		$UserInterface / DialogueSystem / DialogueBox / Subtitles / mgr18Player.stop()

func _on_Subtitles_chars_started( var whichImg):
	$UserInterface / DialogueSystem / DialogueBox / ArrowSprite / AnimationPlayer.play("RESET")
	if SceneControl.currentLevel != 9:
		$UserInterface / DialogueSystem / Walkie / AnimationPlayer.play("WalkieIdle")
	else:
		$UserInterface / DialogueSystem / Walkie / AnimationPlayer.play("WalkieShiver")
	if whichImg > 0:
		$UserInterface / DialogueSystem / TutImgSprite / AnimationPlayer.play("Reveal")
		match (whichImg):
			1:
				$UserInterface / DialogueSystem / TutImgSprite.play("default")
			2:
				$UserInterface / DialogueSystem / TutImgSprite.play("2")
			3:
				$UserInterface / DialogueSystem / TutImgSprite.play("3")
			4:
				$UserInterface / DialogueSystem / TutImgSprite.play("4")
			5:
				$UserInterface / DialogueSystem / TutImgSprite.play("5")
			6:
				$UserInterface / DialogueSystem / TutImgSprite.play("6")
			7:
				$UserInterface / DialogueSystem / TutImgSprite.play("7")
			8:
				$UserInterface / DialogueSystem / TutImgSprite.play("8")
			9:
				$UserInterface / DialogueSystem / TutImgSprite.play("9")
			10:
				$UserInterface / DialogueSystem / TutImgSprite.play("10")
			11:
				$UserInterface / DialogueSystem / TutImgSprite.play("11")
			12:
				$UserInterface / DialogueSystem / TutImgSprite.play("12")
			13:
				$UserInterface / DialogueSystem / TutImgSprite.play("13")
			14:
				$UserInterface / DialogueSystem / TutImgSprite.play("14")
			15:
				$UserInterface / DialogueSystem / TutImgSprite.play("15")
			16:
				$UserInterface / DialogueSystem / TutImgSprite.play("16")
			17:
				$UserInterface / DialogueSystem / TutImgSprite.play("17")
	else:
		if $UserInterface / DialogueSystem / TutImgSprite.visible:
			$UserInterface / DialogueSystem / TutImgSprite / AnimationPlayer.play("Conceal")

func _on_EyeArea_area_entered(area):
	if pistol.active and area.name == "AimArea2D":
		pistol.eye = true
		$UserInterface / FoamPistol / AimSprite / AnimationPlayer.play("FireAble")
		print("Area enter eyes")

func _on_EyeArea_area_exited(area):
	if pistol.active and area.name == "AimArea2D":
		pistol.eye = false
		$UserInterface / FoamPistol / AimSprite / AnimationPlayer.play("RESET")
		print("Area leave eyes")

func _on_PistolSprite_animation_finished():
	if $UserInterface / FoamPistol / PistolSprite.animation == "fire":
		pistol.lock = false
		$UserInterface / UIText / FireTxt.visible = true

func ResetPower():
	powerAmt = 0
	powerStr = 1
	powerUsers = 0
	powerLock = false
	timePower = 0
	$UserInterface / UIText / PowerTxt.text = "POWER LOAD:\n" + "NEUTRAL"
	$UserInterface / UIText / PowerTxt.set("custom_colors/font_color", Color(1, 1, 1, 1))

func SetDefaults():
	
	powerAmt = 0
	powerStr = 1
	powerUsers = 0
	powerLock = false
	timePower = 0

func _on_WalkButton_mouse_entered():
	if $UserInterface / DialogueSystem / DialogueBox / Subtitles.walkX:
		$UserInterface / DialogueSystem / WalkX.visible = true

func _on_WalkButton_mouse_exited():
	$UserInterface / DialogueSystem / WalkX.visible = false

func _on_WalkButton_pressed():
	if $UserInterface / DialogueSystem / DialogueBox / Subtitles.walkX:
		_on_Subtitles_pages_finished()
		$UserInterface / DialogueSystem / DialogueBox / Subtitles.startDial = false
		$UserInterface / DialogueSystem / DialogueBox / Subtitles.readyNext = false
		$UserInterface / DialogueSystem / TutImgSprite / AnimationPlayer.play("RESET")
		$UserInterface / DialogueSystem / DialogueBox / Subtitles / mgrStatic.stop()

func _on_CameraSystem_disconnect_tool():
	powerReduce -= 0.16

func PickTalkie():
	if SceneControl.currentLevel != 9:
		$UserInterface / DialogueSystem / Walkie / AnimationPlayer.play("WalkieIdle")
	else:
		$UserInterface / DialogueSystem / Walkie / AnimationPlayer.play("WalkieShiver")
		$UserInterface / DialogueSystem / DialogueBox / Subtitles / mgr18Player.play()

func NextAmbience():
	match (whichAmbience):
		0:
			$UserInterface / AmbiencePlayer_quiet.play()
			$UserInterface / AmbiencePlayer_quiet.volume_db = - 14
			timeAmbience = 140
			print("Starting quiet ambience")
		1:
			$UserInterface / AmbiencePlayer_drone1.play()
			if SceneControl.currentLevel == 1:
				timeAmbience = 120
				$UserInterface / AmbiencePlayer_ghosts.volume_db = - 46
			elif SceneControl.currentLevel == 2:
				timeAmbience = 110
				$UserInterface / AmbiencePlayer_ghosts.volume_db = - 42
			else:
				timeAmbience = 100
				$UserInterface / AmbiencePlayer_ghosts.volume_db = - 38
			FadeAmbienceOut()
			print("Starting drone ambience")
		2:
			$UserInterface / AmbiencePlayer_ghosts.play()
			timeAmbience = 200
			print("Starting ghost ambience")
		_:
			timeAmbience = 200
	whichAmbience += 1

func FadeAmbienceOut():
	$UserInterface / AmbienceTween.interpolate_property($UserInterface / AmbiencePlayer_quiet, "volume_db", - 14, - 80, 12.0, 1, Tween.EASE_IN, 0)
	$UserInterface / AmbienceTween.start()

func FadeAmbienceIn():
	$UserInterface / AmbienceTween.interpolate_property($UserInterface / AmbiencePlayer_quiet, "volume_db", - 80, - 14, 20.0, 1, Tween.EASE_IN, 0)
	$UserInterface / AmbienceTween.start()

func _on_AmbienceTween_tween_completed(_object, _key):
	if whichAmbience < 2:
		$UserInterface / AmbiencePlayer_quiet.stop()
	else:
		pass

func _on_ShockerButton_pressed():
	
	shocker.active = true
	$UserInterface / Shocker / ShockerSprite.visible = false
	$UserInterface / Shocker / ShockerButton.visible = false
	$UserInterface / UIText / ShockTxt.visible = true
	
	$UserInterface / CameraSystem.lockCam = true
	$UserInterface / Shocker / ShockerHold.position = Vector2(get_global_mouse_position().x - position.x + 960, get_global_mouse_position().y)
	$UserInterface / Shocker / ShockerHold.visible = true
	$UserInterface / CameraSystem.usingShocker = true
	if not ($UserInterface / CameraSystem.currentCam == 10):
		$UserInterface / CameraSystem / CamVis / ShockBlockRect1.visible = true
	$UserInterface / CameraSystem / CamVis / ShockBlockRect2.visible = true
	$UserInterface / CameraSystem / Area2D.visible = false
	$UserInterface / Shocker / ShockerButton / AudioStreamPlayer.play()
	emit_signal("shocker_activated", true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func SetHaunt( var who):
	hauntedTool = who

func _on_VentButton_mouse_entered():
	if shocker.active:
		$UserInterface / Shocker / ShockerHold / AimSprite / AnimationPlayer.play("shockable")
		shocker.overHaunted = 1

func _on_VentButton_mouse_exited():
	if shocker.overHaunted == 1:
		$UserInterface / Shocker / ShockerHold / AimSprite / AnimationPlayer.play("RESET")
		shocker.overHaunted = 0

func _on_PistolButton_mouse_entered():
	if shocker.active:
		$UserInterface / Shocker / ShockerHold / AimSprite / AnimationPlayer.play("shockable")
		shocker.overHaunted = 2

func _on_PistolButton_mouse_exited():
	if shocker.overHaunted == 2:
		$UserInterface / Shocker / ShockerHold / AimSprite / AnimationPlayer.play("RESET")
		shocker.overHaunted = 0

func _on_ConveyorButton_mouse_entered():
	if shocker.active:
		$UserInterface / Shocker / ShockerHold / AimSprite / AnimationPlayer.play("shockable")
		shocker.overHaunted = 3

func _on_ConveyorButton_mouse_exited():
	if shocker.overHaunted == 3:
		$UserInterface / Shocker / ShockerHold / AimSprite / AnimationPlayer.play("RESET")
		shocker.overHaunted = 0

func _on_LightButton_mouse_entered():
	if shocker.active:
		$UserInterface / Shocker / ShockerHold / AimSprite / AnimationPlayer.play("shockable")
		shocker.overHaunted = 4

func _on_LightButton_mouse_exited():
	if shocker.overHaunted == 4:
		$UserInterface / Shocker / ShockerHold / AimSprite / AnimationPlayer.play("RESET")
		shocker.overHaunted = 0

func StartShock():
	shocker.timeShock = 0
	UpdatePowerSystem(shocker.shockAmt)
	$UserInterface / Shocker / ShockerHold / AimSprite.self_modulate.a = 0.2
	$UserInterface / CameraSystem / CamVis / CamToolButtons / VentShockButton.modulate.a = 0.25
	$UserInterface / Shocker / ShockerHold / ShockerDevice.play("shock")
	$UserInterface / Shocker / ShockerHold / AudioStreamPlayer.play()

func HauntedShock():
	shocker.shockHaunt = true
	emit_signal("haunted_shock")

func _on_CameraSystem_vent_shock():
	if shocker.timeShock == - 1 and not powerLock:
		if $UserInterface / CameraSystem.fan.haunted:
			HauntedShock()
		StartShock()

func _on_ShockerDevice_animation_finished():
	if $UserInterface / Shocker / ShockerHold / ShockerDevice.animation == "shock":
		$UserInterface / Shocker / ShockerHold / ShockerDevice.play("default")
