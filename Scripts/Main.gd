extends Node2D


var conveyorOn = true; var mouseInConveyor = false; var conveyorAnimState = 0
var lightOn = true
var pistolFire = false
var coolDown = false




var rand = RandomNumberGenerator.new()
var timeLevel = {"current": 2, "prep": 74, "send": 58}

var timeConv = 0; var timeLight = - 1
var timeFred = 0; var timeBon = 0; var timeChic = 0; var timeFox = 0; var timeFb = 0
var timeFanFred = 0; var timeFanFb = 0; var timeFanFbMax = 3.0
var timeLightBon = 0; var timeLightFb = 0
var timeFredDoor = 0; var timeChicDoor = 0; var timeFbDoor = 0
var timeBonService = 0; var timeFoxService = 0
var timeFbCamBuff = - 1; var timeFbBuffMax = 0.8; var timeFbAttach = 0
var timeFire = - 1; var timeCamBlock = - 1
var timeEventBuffer = - 1
var fbGlitch_Time = - 1; var fbCamGlitch_Time = 0; var fbVent_Time = - 1
var halluGlitchTime = - 1



var fred = {"activity": 0, "x": 0, "y": 0, "loop": 2, "loopPath": 2, "pathLast": 1, "headless": false}
var bon = {"activity": 0, "x": 0, "y": 0, "loop": 3, "loopPath": 2, "pathLast": 2, "side": 0, "window": false}
var chic = {"activity": 0, "x": 0, "y": 0, "loop": 3, "loopPath": 2, "pathLast": 1, "firePos": false}
var fox = {"activity": 0, "x": 2, "y": 0, "loop": 1}
var fb = {"activity": 0, "x": 1, "y": 0, "loop": 2, "loopPath": 2, "pathLast": 1, "side": 0, "attach": false, "seen": false, "attachSteps": 2, "attachWait": false, "attachLoop": 0, "jam": false}
var conveyorWho = 0; var conveyorPos = 0; var conveyorAudioPos = 0


var camPos = {"fred": [0, 0], "bon": [0, 0], "chic": [0, 0], "fox": [2, 0], "fb": [1, 0]}
var camHeadless = false
var camFroze = false





var orderStates = {"step": [0, 0], "maxStep": 2, "confirm": false, "destination": 0}
var gameStates = {"over": true, "win": false, "tutorial": false, "tutorialStep": 0}
var tempCurrentLevel = 0
var hauntSteps = - 1
var hauntWho = 0
var hauntPending = 0
var challengeIndex = - 1
var scareSide = 0











func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	randomize()
	rand.randomize()
	if SceneControl.currentLevel <= 4:
		if SceneControl.currentLevel > 0 and ( not SceneControl.dialRepeat or SceneControl.tutorialReplay):
			gameStates.tutorial = true
		else:
			gameStates.tutorial = false
	if SceneControl.currentLevel > 5 and ( not SceneControl.dialRepeat or SceneControl.tutorialReplay) and SceneControl.currentLevel != 11:
			gameStates.tutorial = true
	if SceneControl.currentLevel == 1:
		$OfficeOverlays / LightBox.visible = true
	if SceneControl.currentLevel > 1:
		$OfficeOverlays / OrderLightBase.play("new")
	if SceneControl.currentLevel == 6:
		$Center / OrangeBuffer.visible = true
		$OfficeOverlays / LeverSprite.play("oos")
	elif SceneControl.currentLevel == 9:
		$Center / ColdBuffer.visible = true
	$Center / UserInterface / CameraSystem / CamVis / CamRandButtons.visible = false
	$Center / UserInterface / Shocker.visible = false
	LevelSetup()
	$MiniStatic.play("default")
	tempCurrentLevel = SceneControl.currentLevel
	
	
	fb.attachSteps = 5000
	fb.attachLoop = rand.randi_range(0, 1)

func _process(delta):
	#print("Static RAM:", OS.get_static_memory_usage())
	#print("Dynamic RAM:", OS.get_dynamic_memory_usage())
	if not gameStates.over and orderStates.step[1] >= 0:
		
		if fred.activity > 0 and not (conveyorWho == 1 and conveyorOn):
			if timeFred <= 0:
				MoveFred()
			else:
				timeFred -= delta
		
		
		if bon.activity > 0 and not (conveyorWho == 2 and conveyorOn):
			if timeBon <= 0:
				MoveBon()
			else:
				timeBon -= delta
		
		
		if chic.activity > 0 and not (conveyorWho == 3 and conveyorOn):
			if timeChic <= 0:
				MoveChic()
			else:
				timeChic -= delta
		
		
		if fox.activity > 0 and not (conveyorWho == 4 and conveyorOn):
			if timeFox <= 0:
				MoveFox()
			else:
				timeFox -= delta
		
		
		if fb.activity > 0 and not fb.jam:
			if timeFb <= 0:
				MoveFb()
			else:
				if not fb.attach and not fb.attachWait:
					timeFb -= delta
		
		
		if orderStates.step != [orderStates.maxStep, 2] and conveyorOn and not orderStates.confirm and not $Center / UserInterface / DialogueSystem.visible and not fb.jam:
			if timeLevel.current <= 0:
				if not ($Center / UserInterface / CameraSystem.door_5 and orderStates.step[1] == 0):
					UpdateOrderState(1)
				else:
					timeLevel.current = 2
					print("Kitchen blocking order")
			else:
				timeLevel.current -= delta
	
	
	if timeLight >= 0 and not $Center.powerLock:
		if timeLight > 2:
			timeLight = - 1
			if not lightOn:
				$OfficePowerOvers / LightButtonSprite.play("default")
				$OfficePowerOvers / LightButtonSprite.visible = true
			else:
				$OfficePowerOvers / LightButtonSprite.visible = false
			if not $Center / UserInterface / CameraSystem.camActive:
				$RoomInterface.EnableLightButton()
		else:
			timeLight += delta
	
	
	if $Center / UserInterface / CameraSystem.fan.state > 0:
		if fred.x == 9:
			if timeFanFred > 2:
				timeFred = 0
				timeFanFred = 0
			else:
				timeFanFred += delta
	elif timeFanFred > 0:
		timeFanFred = 0
	
	
	if $Center / UserInterface / CameraSystem.fan.state > 0:
		if fb.x == 9:
			if timeFanFb > timeFanFbMax:
				timeFb = 0
				timeFanFb = 0
				timeFanFbMax = rand.randf_range(2.4, 3.6)
			else:
				timeFanFb += delta
	elif timeFanFb > 0:
		timeFanFb = 0
	
	
	if not lightOn:
		
		if bon.window and bon.y == 1:
			if timeLightBon > 1.2:
				timeBon = 0
				timeLightBon = 0
			else:
				timeLightBon += delta
	
	
	if $Center / UserInterface / CameraSystem.door_6:
		if fred.x == 5 and fred.y == 8:
			if timeFredDoor > 3.2:
				print("Freddy door time limit hit")
				timeFred = 0
				timeFredDoor = 0
			else:
				timeFredDoor += delta
	elif timeFredDoor > 0:
		timeFredDoor = 0
	
	
	if $Center / UserInterface / CameraSystem.door_7:
		if chic.x == 6 and chic.y == 1:
			if timeChicDoor > 3.2:
				print("Chica door time limit hit")
				timeChic = 0
				timeChicDoor = 0
			else:
				timeChicDoor += delta
	elif timeChicDoor > 0:
		timeChicDoor = 0
	
	
	if (($Center / UserInterface / CameraSystem.door_6 and fb.x == 5) or ($Center / UserInterface / CameraSystem.door_7 and fb.x == 6)) and fb.y == 0:
		if timeFbDoor > 3.2:
			print("Threadbear door time limit hit")
			timeFb = 0
			timeFbDoor = 0
		else:
			timeFbDoor += delta
	elif timeFbDoor > 0:
		timeFbDoor = 0
	
	
	
	if $Center / UserInterface / CameraSystem.door_5:
		if bon.x == 4:
			if timeBonService > 3.2:
				print("Bon service time limit hit")
				timeBon = 0
				timeBonService = 0
			else:
				timeBonService += delta
	elif timeBonService > 0:
		timeBonService = 0
	
	
	
	if $Center / UserInterface / CameraSystem.door_5:
		if fox.x == 4:
			if timeFoxService > 3.2:
				print("Fox service time limit hit")
				timeFox = 0
				timeFoxService = 0
			else:
				timeFoxService += delta
	elif timeFoxService > 0:
		timeFoxService = 0
	
	
	if $OfficePowerOvers / FbPowerGlare.visible:
		$OfficePowerOvers / FbPowerGlare.position.x = lerp($OfficePowerOvers / FbPowerGlare.position.x, $Center.position.x, delta)
		$OfficePowerOvers / FbPowerGlare / AudioStreamPlayer.pitch_scale = rand_range(0.2, 0.35)
	
	
	if fb.x == 9:
		$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams / AudioStreamPlayer2.pitch_scale = rand_range(0.2, 0.35)
	
	
	if fb.x == 9 and $Center / UserInterface / CameraSystem.camActive and $Center / UserInterface / CameraSystem.currentCam == 10:
		if fbVent_Time > 0.03:
			if hauntWho != 6:
				if $Center / UserInterface / CameraSystem.fan.state != 2:
					$Center / UserInterface / CameraSystem / CamVis.frame = rand_range(0, 6)
				else:
					$Center / UserInterface / CameraSystem / CamVis.frame = rand_range(0, 4)
			else:
				$Center / UserInterface / CameraSystem / CamVis.frame = 0
			fbVent_Time = 0
		else:
			fbVent_Time += delta
	
	
	if fb.x == 8 and $Center / UserInterface / CameraSystem.camActive:
		if fbCamGlitch_Time > 0.03:
			$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.frame = rand.randi_range(0, 3)
			$Center / UserInterface / CameraSystem / CamVis / CamButtons / Cam09.modulate.a = rand_range(0.25, 1.0)
			fbCamGlitch_Time = 0
		else:
			fbCamGlitch_Time += delta
	
	
	if $Center / UserInterface / CameraSystem.camRef:
		if fox.x == 8 and fox.y == 2:
			timeFox = 0
		if fb.y == 3:
			timeFb = 0
	
	
	if $Center.powerAmt >= 100 and not $Center.powerLock:
		PowerLock(true)
	
	
	if $Center.powerLock and $Center.powerStr >= 0:
		PowerLock(false)
	
	if timeCamBlock >= 0:
		if timeCamBlock >= 1:
			$Center / UserInterface / CameraSystem / CamVis / BlockCam.visible = false
			$Center / UserInterface / CameraSystem / CamVis / AudioStreamPlayer2.stop()
			$Center / UserInterface / CameraSystem / CamVis / static1 / AudioStreamPlayer.stop()
			timeCamBlock = - 1
		else:
			timeCamBlock += delta
	
	if timeEventBuffer >= 0:
		if timeEventBuffer > 1.6:
			SceneControl.dialRepeat = false
			gameStates.tutorialStep += 1
			$Center / UserInterface / DialogueSystem / Walkie / AnimationPlayer.play("Enter")
			$Center / UserInterface / DialogueSystem / DialogueBox / Subtitles.SetDialText(gameStates.tutorialStep)
			TutorialLock(true)
			timeEventBuffer = - 1
		else:
			timeEventBuffer += delta
	
	if $TvFbs.visible:
		if fbGlitch_Time >= 0:
			if fbGlitch_Time > 0.04:
				if not $Center / UserInterface / CameraSystem / CamVis / FbBlock.animation == "crawlIn":
					$Center / UserInterface / CameraSystem / CamVis / FbBlock.frame = rand_range(0, 5)
				$TvFbs / TvFb1.frame = rand_range(0, 5)
				$TvFbs / TvFb2.frame = rand_range(0, 5)
				$TvFbs / TvFb3.frame = rand_range(0, 5)
				$TvFbs / TvFb4.frame = rand_range(0, 5)
				$TvFbs / TvFb5.frame = rand_range(0, 5)
				$TvFbs / TvFb6.frame = rand_range(0, 5)
				fbGlitch_Time = 0
			else:
				fbGlitch_Time += delta
	
	if fb.attachWait and $Center / UserInterface / CameraSystem / CamVis.visible:
		StartAttachTb()
	
	
	$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D6.position.x = clamp(($Center.position.x - 960), 0, 1900)
	
	if gameStates.over:
		$Center / JumpscareSprite.rotation_degrees = $Center / Camera2D.rotation_degrees
	
	
	if $Center.scareTurn:
		if scareSide == 1:
			$Center.position.x = lerp($Center.position.x, 960, delta * 10)
			$Center / JumpscareSprite.position.x = - ($Center.position.x - 960)
		elif scareSide == 2:
			$Center.position.x = lerp($Center.position.x, 3180, delta * 10)
			$Center / JumpscareSprite.position.x = - ($Center.position.x - 3180)
	
	
	if halluGlitchTime >= 0:
		if halluGlitchTime >= 0.1:
			$Center / UserInterface / Hallucinations / HalluSprite.frame = rand.randi_range(0, 2)
			halluGlitchTime = 0
		else:
			halluGlitchTime += delta
	
	if $OfficeOverlays / WhisperHaunt1_2D.playing:
		$OfficeOverlays / WhisperHaunt1_2D.pitch_scale = rand_range(0.9, 1.0)

func _input(event):
	if event.is_action_pressed("ui_skip"):
		if SceneControl.currentLevel == 0 or SceneControl.devMode:
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			chic.activity = 20
			chic.x = 3
			chic.y = 1
			timeChic = 2
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
	
	if event.is_action_pressed("ui_mouse_left") and $Center.pistol.active and not $Center.pistol.fired and not gameStates.over:
		if chic.x == 11 and chic.y == 1 and $Center.pistol.eye:
			pistolFire = true
			$BackBufferCopy / AnimationPlayer.play("RESET")
			if not $Center.powerLock:
				$RoomInterface / ToolButtons / LightButton.visible = true
			$Center.pistol.lock = false
			$ChicDesk.play("leave_1")
			$ChicDesk / AnimationPlayer.play("ChicHit")
			$Center / UserInterface / FoamPistol / AudioStreamPlayer2D3.stop()
			$Center / UserInterface / FoamPistol / AudioStreamPlayer2D.play()
			$RoomInterface / AudioStreamPlayer2D.play()
			timeChic = rand.randi_range(3, 5)
			$ChicDesk / EyeArea / CollisionShape2D.disabled = true
			SceneControl.sodaWon += 1
			print("Pistol fired at chica.")
		else:
			print("Pistol fired at air.")
		$Center / UserInterface / FoamPistol / PistolSprite.play("fire")
		$Center / UserInterface / FoamPistol / AimSprite.visible = false
		$Center.pistol.fired = true
		$Center.pistol.lock = true
		$Center / UserInterface / UIText / FireTxt.visible = false
		$Center / UserInterface / UIText / FireTxt.text = "\nRight click: Exit"
		$RoomInterface / ToolButtons / PistolButton / AudioStreamPlayer.play()

func LevelSetup():
	
	match (SceneControl.currentLevel):
		0:
			print("Demo level starting")
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			fred.activity = 0
			bon.activity = 0
			chic.activity = 0
			fox.activity = 0
			fb.activity = 0
			
			
			timeFred = rand.randi_range(4, 7)
			timeBon = rand.randi_range(4, 7)
			timeChic = rand.randi_range(4, 7)
			timeFox = rand.randi_range(4, 7)
			timeFb = rand.randi_range(4, 7)
		1:
			print("Level 1 starting")
			
			bon.activity = 3
			chic.activity = 4
			
			
			
			timeBon = rand.randi_range(65, 85)
			
			timeChic = rand.randi_range(120, 140)
			$OfficeOverlays / OrderTray.play("default")
		2:
			print("Level 2 starting")
			gameStates.tutorialStep = 2
			
			fred.activity = 3
			bon.activity = 5
			chic.activity = 3
			
			
			timeFred = rand.randi_range(60, 70)
			timeBon = rand.randi_range(9, 12)
			timeChic = rand.randi_range(115, 130)
			$OfficeOverlays / OrderTray.play("food2")
		3:
			print("Level 3 starting")
			gameStates.tutorialStep = 4
			
			fred.activity = 6
			bon.activity = 2
			chic.activity = 6
			fox.activity = 4
			
			
			timeFred = rand.randi_range(12, 20)
			timeBon = rand.randi_range(175, 190)
			timeChic = rand.randi_range(110, 130)
			timeFox = rand.randi_range(35, 50)
			$OfficeOverlays / OrderTray.play("food3")
		4:
			print("Level 4 starting")
			gameStates.tutorialStep = 6
			
			fred.activity = 4
			bon.activity = 4
			chic.activity = 5
			fox.activity = 3
			fb.activity = 5
			
			
			timeFred = rand.randi_range(120, 150)
			timeBon = rand.randi_range(6, 12)
			timeChic = rand.randi_range(15, 30)
			
			timeFox = rand.randi_range(80, 100)
			
			timeFb = rand.randi_range(65, 75)
			$OfficeOverlays / OrderTray.play("food4")
		5:
			
			print("Custom level starting")
			challengeIndex = 0
			
			
			timeFred = rand.randi_range(4, 12)
			timeBon = rand.randi_range(4, 12)
			timeChic = rand.randi_range(4, 12)
			timeFox = rand.randi_range(4, 12)
			timeFb = rand.randi_range(4, 12)
			if SceneControl.customActivity == [0, 0, 0, 0, 0]:
				$OfficeOverlays / OrderTray.play("food5")
			elif SceneControl.customActivity == [20, 20, 20, 20, 20]:
				$OfficeOverlays / OrderTray.play("puppets3")
			else:
				$OfficeOverlays / OrderTray.play("slip")
		6:
			
			print("Out of Service challenge starting")
			challengeIndex = 4
			gameStates.tutorialStep = 8
			
			
			timeFred = rand.randi_range(64, 72)
			timeBon = rand.randi_range(84, 96)
			timeChic = rand.randi_range(12, 24)
			timeFox = rand.randi_range(52, 68)
			$OfficeOverlays / OrderTray.play("puppets1")
		7:
			
			print("Haunting Roulette challenge starting")
			challengeIndex = 2
			gameStates.tutorialStep = 9
			hauntSteps = rand.randi_range(1, 2)
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			timeFred = rand.randi_range(24, 36)
			timeBon = rand.randi_range(48, 64)
			timeChic = rand.randi_range(6, 12)
			timeFox = rand.randi_range(110, 140)
			$OfficeOverlays / OrderTray.play("empty")
		8:
			
			print("Basket Hunt challenge starting")
			challengeIndex = 1
			gameStates.tutorialStep = 10
			orderStates.maxStep = 4
			
			timeLevel.prep = 25
			timeLevel.send = 20
			
			
			$Center / UserInterface / CameraSystem.randomDestinations = [4, 5, 6, 7, 11, 12]
			$Center / UserInterface / CameraSystem.randomDestinations.shuffle()
			orderStates.destination = $Center / UserInterface / CameraSystem.randomDestinations[0]
			$Center / UserInterface / CameraSystem / CamVis / CamRandButtons.visible = true
			$Center / UserInterface / DialogueSystem / Walkie.play("blind")
			$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ManagerHat.play("bag")
			
			
			
			timeFred = rand.randi_range(72, 84)
			timeBon = rand.randi_range(20, 32)
			timeFb = rand.randi_range(144, 180)
			$OfficeOverlays / OrderTray.play("food5")
		9:
			
			print("Cold Kitchen challenge starting")
			challengeIndex = 3
			gameStates.tutorialStep = 11
			$Center / UserInterface / DialogueSystem / Walkie.play("muffs")
			$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ManagerHat.play("muffs")
			
			
			timeFred = rand.randi_range(30, 70)
			timeBon = rand.randi_range(14, 24)
			timeChic = rand.randi_range(45, 75)
			timeFb = rand.randi_range(125, 155)
			$OfficeOverlays / OrderTray.play("snowFred")
		10:
			
			print("Lunch Rush challenge starting")
			challengeIndex = 5
			gameStates.tutorialStep = 12
			orderStates.maxStep = 6
			
			timeLevel.prep = 30
			timeLevel.send = 20
			
			
			timeFred = rand.randi_range(46, 62)
			timeBon = rand.randi_range(34, 46)
			timeChic = rand.randi_range(6, 14)
			timeFox = rand.randi_range(64, 72)
			timeFb = rand.randi_range(84, 96)
			$OfficeOverlays / OrderTray.play("clock")
		11:
			
			print("Final Course challenge starting")
			challengeIndex = 6
			gameStates.tutorialStep = 13
			
			
			
			
			
			timeFred = rand.randi_range(108, 132)
			timeBon = rand.randi_range(24, 36)
			timeChic = rand.randi_range(8, 16)
			timeFox = rand.randi_range(96, 104)
			timeFb = rand.randi_range(172, 196)
			$OfficeOverlays / OrderTray.play("puppets2")
	
	if SceneControl.currentLevel >= 5:
		
		fred.activity = SceneControl.customActivity[0]
		bon.activity = SceneControl.customActivity[1]
		chic.activity = SceneControl.customActivity[2]
		fox.activity = SceneControl.customActivity[3]
		fb.activity = SceneControl.customActivity[4]
	
	
	if not gameStates.tutorial:
		gameStates.over = false
		timeLevel.current = timeLevel.prep
		UpdateOrderState(2)
	else:
		orderStates.step[1] = - 1
		$Center / UserInterface / DialogueSystem / DialogueBox / Subtitles.SetDialText(gameStates.tutorialStep)
		TutorialLock(true)
		$OfficeOverlays / OrderSprite.play("off")
	$DeskSprite.play()
	$MiniStatic / ClearPlayer.play("mod")
	$MiniStatic / MiniStatPlayer.play("Moving")
	if fox.activity > 0:
		$Center / UserInterface / CameraSystem.secretCam.foxAct = true

func MoveFred():
	
	var prevRoom = fred.x
	var prevDepth = fred.y
	var randSel = 0
	
	match (fred.x):
		0:
			fred.x = 1
			$Center / AudioStreamPlayer2.play()
		1:
			fred.x = 3
		3:
			if fred.y == 0:
				randSel = rand.randi_range(1, 3)
				if randSel == 1:
					if fred.loop > 0:
						if chic.x != 6:
							fred.x = 6
						fred.loop -= 1
					else:
						fred.x = 5
						fred.loop = 1
				else:
					fred.x = 5
			else:
				if fb.x != 9:
					fred.x = 9
					fred.y = 0
					if hauntSteps > 0 and $Center / UserInterface / CameraSystem.fan.state == 0:
						CheckHaunt(1)
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams / AudioStreamPlayer.play()
				else:
					pass
		5:
			
			
			
			
			
			
			
			if fred.y == 0:
				randSel = rand.randi_range(1, 7)
				
				
				if fred.pathLast == clamp(randSel, 1, 2):
					fred.loopPath -= 1
				else:
					fred.loopPath = 3
				
				
				if fred.loopPath <= 0:
					if randSel == 1:
							randSel = 2
					else:
							randSel = 1
					fred.loopPath = 3
				
				
				if randSel == 1:
					fred.y = 8
				else:
					fred.y = 1
				
				fred.pathLast = clamp(randSel, 1, 2)
				$Center / AudioStreamPlayer.play()
			else:
				if fred.y == 1:
					if not (fb.x == 3 and fb.y == 2):
						fred.x = 3
					else:
						pass
				else:
					if not $Center / UserInterface / CameraSystem.door_6 and conveyorOn and $ConveyorOverlays / ConveyorIdle / AnimationPlayer.current_animation != "TurnOn":
						if conveyorWho == 0:
							fred.x = 10
							fred.y = 0
							if not fred.headless:
								StartConveyor(1, 0)
							else:
								StartConveyor(1, 1)
							if hauntSteps > 0:
								CheckHaunt(3)
						else:
							pass
					else:
						randSel = rand.randi_range(1, 3)
						if randSel == 1:
							fred.x = 1
						else:
							fred.x = 3
						fred.y = 0
						fred.loop = 1
						print("Freddy: Blocked door/conveyor")
						if not conveyorOn and conveyorWho == 0:
							$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("EnemyFlicker")
		6:
			fred.x = 3
		9:
			if $Center / UserInterface / CameraSystem.fan.state > 0 or (hauntWho == 1 and $Center.shocker.shockHaunt):
				if fred.y <= 1:
					randSel = rand.randi_range(1, 3)
					if randSel == 1:
						fred.x = 1
					else:
						fred.x = 3
					fred.y = 0
				else:
					randSel = rand.randi_range(1, 2)
					if randSel == 1:
						fred.x = 5
					else:
						if not (chic.x == 6 and chic.y == 0):
							fred.x = 6
						else:
							fred.x = 5
					
					if not fred.headless and hauntWho != 1:
						fred.headless = true
						if not $Center / UserInterface / CameraSystem.camFroze:
							camHeadless = true
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("headless")
						$RoomInterface / SecretButtons / DeadFredButton.visible = true
						print("Freddy: Knocked head off. He's angry!")
					
					fred.y = 0
				print("Freddy: Blocked")
				$Center / UserInterface / CameraSystem.fan.chop = false
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams / AudioStreamPlayer4.play()
			else:
				if fred.y == 0:
					if SceneControl.currentLevel < 3 and fred.activity < 10:
						
						fred.y = 1
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams / AudioStreamPlayer2.play()
					else:
						fred.y = 2
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams / AudioStreamPlayer2.play()
						if not fred.headless:
							$Center / UserInterface / CameraSystem.fan.chop = true
					if hauntSteps > 0 and hauntWho != 1:
						CheckHaunt(1)
				else:
					if hauntWho != 1:
						SceneControl.failReason = 2
						print("Freddy: Office (JUMPSCARE) - Vent")
						if not fred.headless:
							jumpscare(1)
						else:
							jumpscare(6)
						fred.x = 11
						fred.y = 0
					else:
						jumpscare(12)
		10:
			if not conveyorOn or ((hauntWho == 3 and $Center.shocker.shockHaunt) and conveyorWho == 1) or hauntPending == 4:
				randSel = rand.randi_range(1, 3)
				if randSel == 1:
					fred.x = 1
				else:
					fred.x = 3
				fred.loop = 1
				print("Freddy: Blocked")
				if not (hauntWho == 3 and conveyorWho == 1) and hauntPending != 4:
					$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("EnemyFlicker")
				else:
					HideConvEnemy()
				SoundHandle(2)
				if hauntPending == 4:
					hauntPending = 0
			else:
				if hauntWho != 3:
					fred.x = 11
					if not fred.headless:
						SceneControl.failReason = 1
					else:
						SceneControl.failReason = 7
					print("Freddy: Office (JUMPSCARE) - Conveyor")
					if not fred.headless:
						jumpscare(8)
					else:
						jumpscare(7)
				else:
					jumpscare(14)
	
	if not $Center / UserInterface / CameraSystem.camFroze:
		camPos.fred[0] = fred.x
		camPos.fred[1] = fred.y
		if camPos.fred[0] == 9 and camPos.fred[1] > 0:
			UpdateRoomState(camPos.fred[0])
			
		elif not (camPos.fred[0] == prevRoom and camPos.fred[1] == prevDepth):
			
			UpdateRoomState(camPos.fred[0])
			UpdateRoomState(prevRoom)
	
	if not fred.headless:
		if fred.x == 10:
			timeFred = 12
		else:
			timeFred = rand.randi_range(4, (6 + (4 - (orderStates.step[1] / 2)))) * (20 / fred.activity)
	else:
		if fred.x == 10:
			timeFred = 10
		else:
			timeFred = rand.randi_range(2, (3 + (4 - (orderStates.step[1] / 2)))) * (20 / fred.activity)
	
	

func MoveBon():
	
	var prevRoom = bon.x
	var randSel = 0
	
	match (bon.x):
		0:
			
			bon.x = 1
			$Center / AudioStreamPlayer3.play()
		1:
			if bon.y == 0:
				
				randSel = rand.randi_range(1, 2)
				if randSel == 1:
					bon.x = 3
				else:
					if fox.x == 8:
						bon.x = 3
					else:
						bon.x = 8
			else:
				bon.x = 3
				bon.y = 0
		3:
			
			
			
			
			
			randSel = rand.randi_range(1, 2)
			
			if bon.y == 0:
				
				if bon.pathLast == randSel:
					bon.loopPath -= 1
				else:
					bon.loopPath = 2
				
				
				if bon.loopPath <= 0:
					if randSel == 1:
							randSel = 2
					else:
							randSel = 1
					bon.loopPath = 2
				
				
				if randSel == 1:
					if fox.x == 4:
						pass
					else:
						bon.x = 4
				else:
					bon.x = 7
				
				if randSel == 1:
					bon.pathLast = randSel
				$Center / AudioStreamPlayer.play()
			elif bon.y == 1:
				
				if bon.side == 1:
					$BonOffice / AnimationPlayer.play("LeaveFront")
				elif bon.side == 2:
					if not (hauntWho == 4 or hauntPending == 2):
						$BonOffice / AnimationPlayer.play("LeaveRight")
					else:
						$BonOffice.play("shock")
						$BonOffice / AnimationPlayer.play("LeaveHaunt")
				else:
					$BonOffice / AnimationPlayer.play("LeaveLeft")
				if not lightOn or (hauntWho == 4 and $Center.shocker.shockHaunt) or hauntPending == 2:
					bon.y = 2
					$RoomInterface / AudioStreamPlayer2D.play()
					if hauntPending == 2:
						hauntPending = 0
					print("Bonnie: Blocked")
				else:
					
					bon.y = 5
					$RoomInterface / AudioStreamPlayer2D.play()
			elif bon.y == 2:
				
				randSel = rand.randi_range(1, 2)
				if randSel == 1:
					bon.x = 1
				else:
					bon.x = 3
				bon.y = 0
				bon.window = false
			else:
				if not hauntWho == 4:
					bon.y = 8
					bon.x = 11
					SceneControl.failReason = 3
					print("Bonnie: Office (JUMPSCARE)")
					jumpscare(2)
				else:
					print("Light: Office (JUMPSCARE)")
					jumpscare(15)
		4:
			
			if not $Center / UserInterface / CameraSystem.door_5 and conveyorOn and $ConveyorOverlays / ConveyorIdle / AnimationPlayer.current_animation != "TurnOn":
				if conveyorWho == 0:
					bon.x = 10
					bon.y = 0
					StartConveyor(2, 0)
					if hauntSteps > 0:
						CheckHaunt(3)
				else:
					pass
			else:
				randSel = rand.randi_range(1, 2)
				if randSel == 1:
					bon.x = 1
				else:
					bon.x = 3
				bon.loop = 2
				print("Bonnie: Blocked")
				if not conveyorOn and conveyorWho == 0:
					$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("EnemyFlicker")
		7:
			
			randSel = rand.randi_range(1, 2)
			
			if randSel == 1 and bon.loop > 0:
				bon.loop -= 1
			else:
				bon.x = 3
				bon.y = 1
				bon.loop = 3
				if hauntSteps > 0 and lightOn:
					CheckHaunt(4)
				if SceneControl.currentLevel != 1:
					bon.side = rand.randi_range(1, 3)
				else:
					bon.side = rand.randi_range(1, 2)
				if hauntWho == 4:
					bon.side = 2
				if bon.side == 1:
					if lightOn:
						$BonOffice.play("front")
					else:
						$BonOffice.play("dark_2")
					$BonOffice / AnimationPlayer.play("EnterFront")
				elif bon.side == 2:
					if lightOn:
						$BonOffice.play("default")
					else:
						$BonOffice.play("dark_1")
					$BonOffice / AnimationPlayer.play("EnterRight")
				else:
					if lightOn:
						$BonOffice.play("left")
					else:
						$BonOffice.play("dark_3")
					$BonOffice / AnimationPlayer.play("EnterLeft")
				$RoomInterface / AudioStreamPlayer2D2.play()
				print("Bonnie special!")
		8:
			
			bon.x = 1
			bon.y = 1
		10:
			if not conveyorOn or ((hauntWho == 3 and $Center.shocker.shockHaunt) and conveyorWho == 2) or hauntPending == 4:
				randSel = rand.randi_range(1, 2)
				if randSel == 1:
					bon.x = 1
				else:
					bon.x = 3
				bon.loop = 2
				print("Bonnie: Blocked")
				if not (hauntWho == 3 and conveyorWho == 2) and hauntPending != 4:
					$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("EnemyFlicker")
				else:
					HideConvEnemy()
				SoundHandle(2)
				if hauntPending == 4:
					hauntPending = 0
			else:
				if hauntWho != 3:
					bon.x = 11
					SceneControl.failReason = 1
					print("Bonnie: Office (JUMPSCARE) - Conveyor")
					jumpscare(9)
				else:
					jumpscare(14)
	
	if not $Center / UserInterface / CameraSystem.camFroze:
		camPos.bon[0] = bon.x
		camPos.bon[1] = bon.y
		if bon.x != prevRoom:
			UpdateRoomState(camPos.bon[0])
			UpdateRoomState(prevRoom)
	
	if bon.x == 10:
		timeBon = 12
	elif bon.x == 3 and (bon.y == 1 or bon.y == 2):
		
		timeBon = rand.randi_range(6, 8) * (20 / bon.activity)
	elif bon.x == 3 and bon.y == 5:
		
		timeBon = rand.randi_range(6, 8)
		print("Jump pad timing start")
	else:
		timeBon = rand.randi_range(4, (6 + (4 - (orderStates.step[1] / 2)))) * (20 / bon.activity)
	
	
	

func MoveChic():
	
	var prevRoom = chic.x
	var randSel = 0
	
	match (chic.x):
		0:
			chic.x = 1
			$Center / AudioStreamPlayer3.play()
		1:
			chic.x = 3
		3:
			
			
			
			
			
			randSel = rand.randi_range(1, 2)
			
			if chic.y == 0:
				
				
				
				if chic.pathLast == randSel:
					chic.loopPath -= 1
				else:
					chic.loopPath = 2
				
				
				if chic.loopPath <= 0:
					if randSel == 1:
						randSel = 2
					else:
						randSel = 1
					chic.loopPath = 2
				
				
				if randSel == 1:
					chic.x = 6
					if fred.x == 6:
						timeFred = 0
				else:
					chic.x = 7
				
				chic.pathLast = randSel
				$Center / AudioStreamPlayer.play()
			else:
				if fb.x != 11:
					chic.x = 11
					chic.y = 0
					if lightOn:
						$ChicDesk.play("default")
						
						$ChicDesk.modulate = Color(1, 1, 1, 1)
					else:
						$ChicDesk.play("dark_1")
					$ChicDesk / AnimationPlayer.play("ChicEnter")
					$ChicDesk / EyeArea / AnimationPlayer.play("RESET")
					$ChicDesk.position.x = rand.randi_range(3092, 3260)
					$BackBufferCopy / FocusRect.material.set_shader_param("blur_center", Vector2((($ChicDesk.position.x - 3092) / (3260 - 3092)) * 0.08 + 0.46, 0.53))
					print($ChicDesk.position.x)
					print($BackBufferCopy / FocusRect.material.get_shader_param("blur_center"))
					$RoomInterface / AudioStreamPlayer2D2.play()
					if hauntSteps > 0 and not $Center.pistol.active:
						CheckHaunt(2)
				else:
					pass
		6:
			
			randSel = rand.randi_range(1, 2)
			
			if chic.y == 0:
				if randSel == 1 and chic.loop > 0:
					chic.loop -= 1
				else:
					chic.y = 1
					chic.loop = 3
			else:
				if not $Center / UserInterface / CameraSystem.door_7 and conveyorOn and $ConveyorOverlays / ConveyorIdle / AnimationPlayer.current_animation != "TurnOn":
					if conveyorWho == 0:
						chic.x = 10
						chic.y = 0
						StartConveyor(3, 0)
						if hauntSteps > 0:
							CheckHaunt(3)
					else:
						pass
				else:
					randSel = rand.randi_range(1, 2)
					if randSel == 1:
						chic.x = 1
					else:
						chic.x = 3
					chic.y = 0
					chic.loop = 2
					print("Chica: Blocked (Door/conveyor)")
					if not conveyorOn and conveyorWho == 0:
						$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("EnemyFlicker")
		7:
			if bon.x == 3 and bon.y == 1:
				pass
			else:
				chic.x = 3
				chic.y = 1
		10:
			if not conveyorOn or ((hauntWho == 3 and $Center.shocker.shockHaunt) and conveyorWho == 3) or hauntPending == 4:
				randSel = rand.randi_range(1, 2)
				if randSel == 1:
					chic.x = 1
				else:
					chic.x = 3
				chic.loop = 2
				print("Chica: Blocked")
				if not (hauntWho == 3 and conveyorWho == 3) and hauntPending != 4:
					$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("EnemyFlicker")
				else:
					HideConvEnemy()
				SoundHandle(2)
				if hauntPending == 4:
					hauntPending = 0
			else:
				if hauntWho != 3:
					chic.x = 11
					SceneControl.failReason = 1
					print("Chica: Office (JUMPSCARE)")
					jumpscare(10)
				else:
					jumpscare(14)
		11:
			if chic.y == 0:
				if not lightOn or (hauntWho == 2 and $Center.shocker.shockHaunt) or hauntPending == 3:
					chic.firePos = false
					print("Chica: Blocked w/light on")
					if not (hauntWho == 2 or hauntPending == 3):
						if not lightOn:
							$ChicDesk.modulate = Color(0, 0, 0, 1)
						$ChicDesk.play("leave_4")
						$ChicDesk / AnimationPlayer.play("ChicLeave")
					else:
						$ChicDesk.play("shock")
						$ChicDesk / AnimationPlayer.play("ChicLeaveHaunt")
					pistolFire = false
					chic.y = 6
					$RoomInterface / AudioStreamPlayer2D.play()
					if hauntPending == 3:
						hauntPending = 0
				else:
					if hauntWho != 2:
						$ChicDesk.play("leave_3")
						$ChicDesk / AnimationPlayer.play("ChicLeave4")
						chic.y = 9
						chic.firePos = false
						print("Chica is sneaking")
					else:
						jumpscare(13)
			elif chic.y == 1:
				if pistolFire:
					print("Chica: Blocked")
					$ChicDesk / AnimationPlayer.play("ChicLeave2")
					pistolFire = false
					chic.y = 7
				else:
					chic.y = 8
					$ChicDesk.play("leave_2")
					$ChicDesk / AnimationPlayer.play("ChicLeave3")
					$BackBufferCopy / AnimationPlayer.play("RESET")
					$RoomInterface / AudioStreamPlayer2D.play()
					$RoomInterface / ToolButtons / LightButton.visible = true
					$Center.pistol.lock = false
					$Center / UserInterface / FoamPistol / AudioStreamPlayer2D2.play()
					if $Center.pistol.active:
						$Center / UserInterface / UIText / FireTxt.text = "Left click: Fire\nRight click: Exit"
					print("Here comes Chica.")
				$ChicDesk / EyeArea / CollisionShape2D.disabled = true
				$Center / UserInterface / FoamPistol / AudioStreamPlayer2D3.stop()
			elif chic.y == 6 or chic.y == 7:
				randSel = rand.randi_range(1, 2)
				if randSel == 1:
					chic.x = 1
				else:
					chic.x = 3
				chic.loop = 2
				chic.y = 0
			elif chic.y == 8:
				SceneControl.failReason = 5
				print("Chica: Office (JUMPSCARE)")
				jumpscare(3)
			elif chic.y == 9:
				print("Chica: Office (JUMPSCARE)")
				jumpscare(3)
				SceneControl.failReason = 4
				print("Scare from 1st position")
	
	if not $Center / UserInterface / CameraSystem.camFroze:
		camPos.chic[0] = chic.x
		camPos.chic[1] = chic.y
		if chic.x != prevRoom or chic.x == 6 and chic.y == 1:
			UpdateRoomState(camPos.chic[0])
			UpdateRoomState(prevRoom)
	
	if chic.x == 11 and chic.y == 0:
		
		timeChic = rand.randi_range(12, 15)
	elif chic.x == 10:
		timeChic = 12
	elif chic.y == 6 or chic.y == 8:
		timeChic = 12
	elif chic.y == 9:
		timeChic = rand.randi_range(6, 10)
	else:
		timeChic = rand.randi_range(4, (6 + (4 - (orderStates.step[1] / 2)))) * (20 / chic.activity)
	

func MoveFox():
	
	var prevRoom = fox.x
	var randSel = 0
	
	match (fox.x):
		1:
			randSel = rand.randi_range(1, 2)
			if randSel == 1 and fox.loop > 0:
				fox.loop -= 1
			else:
				if bon.x != 8:
					if not $Center / UserInterface / CameraSystem.camFroze and not $Center / UserInterface / CameraSystem.camBackup:
						fox.x = 8
					else:
						fox.x = 8
						fox.y = 3
					fox.loop = 2
					$Center / AudioStreamPlayer.play()
				else:
					pass
		2:
			if fox.y == 0:
				fox.y = 1
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams / AudioStreamPlayer.play()
			else:
				fox.x = 1
				fox.y = 0
		3:
			fox.x = 4
		4:
			
			if not $Center / UserInterface / CameraSystem.door_5 and conveyorOn and $ConveyorOverlays / ConveyorIdle / AnimationPlayer.current_animation != "TurnOn":
				if conveyorWho == 0:
					fox.x = 10
					fox.y = 0
					StartConveyor(4, 1)
					if hauntSteps > 0:
						CheckHaunt(3)
				else:
					pass
			else:
				randSel = rand.randi_range(1, 2)
				if randSel == 1:
					fox.x = 2
					fox.y = 1
				else:
					fox.x = 1
					fox.y = 0
				fox.loop = 2
				print("Foxy: Blocked")
				if not conveyorOn and conveyorWho == 0:
					$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("EnemyFlicker")
		8:
			if fox.y < 3:
				if fox.y == 1:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / VidBox.play("orange")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / VidBox / AnimationPlayer.play("Warning")
				if fox.y == 2:
					if $Center / UserInterface / CameraSystem.camRef:
						randSel = rand.randi_range(1, 2)
						if randSel == 1:
							fox.y = 3
							print("Foxy: Angry chosen")
						else:
							fox.x = 2
							fox.y = 1
							print("Foxy: Lab chosen")
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams / AudioStreamPlayer2.play()
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / VidBox.play("default")
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / VidBox / AnimationPlayer.play("Normal")
						print("Foxy: Cam blocked")
					else:
						print("Foxy: Cameras frozen")
						$Center / UserInterface / CameraSystem.CamFreeze()
						fox.loop = 0
						fox.y += 1
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams / AudioStreamPlayer3.play()
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / VidBox.play("red")
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / VidBox / AnimationPlayer.play("Danger")
				else:
					if fb.x != 8:
						fox.y += 1
			else:
				fox.x = 3
				fox.y = 0
		10:
			if not conveyorOn or ((hauntWho == 3 and $Center.shocker.shockHaunt) and conveyorWho == 4) or hauntPending == 4:
				randSel = rand.randi_range(1, 2)
				if randSel == 1:
					fox.x = 2
					fox.y = 1
				else:
					fox.x = 1
					fox.y = 0
				fox.loop = 2
				print("Foxy: Blocked")
				if not (hauntWho == 3 and conveyorWho == 4) and hauntPending != 4:
					$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("EnemyFlicker")
				else:
					HideConvEnemy()
					
				SoundHandle(2)
				if hauntPending == 4:
					hauntPending = 0
			else:
				if hauntWho != 3:
					fox.x = 11
					if $Center / UserInterface / CameraSystem.camFroze or $Center / UserInterface / CameraSystem.camBackup:
						SceneControl.failReason = 6
					else:
						SceneControl.failReason = 9
					print("Foxy: Office (JUMPSCARE)")
					jumpscare(4)
				else:
					jumpscare(14)
	
	if not $Center / UserInterface / CameraSystem.camFroze:
		camPos.fox[0] = fox.x
		camPos.fox[1] = fox.y
		if fox.x != prevRoom or camPos.fox[0] == 2 or camPos.fox[0] == 8:
			UpdateRoomState(camPos.fox[0])
			UpdateRoomState(prevRoom)
	
	if fox.x == 10:
		timeFox = 10
	else:
		timeFox = rand.randi_range(4, (6 + (4 - (orderStates.step[1] / 2)))) * (20 / fox.activity)
	

func MoveFb():
	
	var prevRoom = fb.x
	var prevDepth = fb.y
	var randSel = 0
	
	
	
	
	
	
	
	
	
	
	match (fb.x):
		1:
			if fb.y == 0:
				fb.y = 1
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams / AudioStreamPlayer.play()
				if SceneControl.currentLevel == 4:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams / AudioStreamPlayer.play()
			else:
				
				
				
				
				
				if fb.attachLoop <= 0 and not $Center / UserInterface / CameraSystem.camFroze and not $Center / UserInterface / CameraSystem.camBackup and not (fox.x == 8 and fox.y > 0) and SceneControl.currentLevel != 9:
					$Center / UserInterface / CameraSystem.camTbIncoming = true
					fb.x = 8
					fb.attachLoop = rand.randi_range(1, 2)
					$Center / UserInterface / CameraSystem / CamVis / CamButtons / Cam09 / WarnFroze.visible = true
					$Center / UserInterface / CameraSystem / CamVis / CamButtons / Cam09 / WarnFroze.play("default")
					if $Center / UserInterface / CameraSystem / CamVis.visible and $Center / UserInterface / CameraSystem.currentCam == 9:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams / AudioStreamPlayer3.play()
				else:
					fb.x = 3
					if fb.attachLoop > 0:
						fb.attachLoop -= 1
				fb.y = 0
				
				\
\
\
\
\
\
\
				"\n				if randSel == 0 && !$Center/UserInterface/CameraSystem.camFroze && !$Center/UserInterface/CameraSystem.camBackup && fox.x != 8:\n					$Center/UserInterface/CameraSystem.camTbIncoming = true\n					fb.x = 8\n				else:\n					fb.x = 3\n				fb.y = 0\n				"
				
				\
\
\
\
\
\
\
\
				"\n				if randSel == 0:\n					fb.x = 3\n					fb.y = 0\n				else:\n					$Center/UserInterface/CameraSystem.camTbIncoming = true\n					fb.x = 8\n					fb.y = 0\n				"
		3:
			
			if fb.y == 0:
				
				randSel = rand.randi_range(0, 1)
				
				if fb.pathLast == randSel:
					fb.loopPath -= 1
				else:
					fb.loopPath = 2
				
				if fb.loopPath <= 0:
					print("Threadbear: Max path loop reached")
					if randSel == 0:
						randSel = 1
					else:
						randSel = 0
					fb.loopPath = 2
				
				fb.pathLast = randSel
				
				if randSel == 0:
					fb.y = 1
					print("Threadbear: On vent path")
				else:
					fb.y = 3
					print("Threadbear: On jam path")
				
				\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
				"\n				if randSel == 0:\n					randSel = rand.randi_range(0, 1)\n					if randSel == 1:\n						fb.x = 4\n					else:\n						fb.x = 7\n					print(\"Threadbear: Entering Adjacent Room\")\n				else:\n					randSel = rand.randi_range(0, 1)\n					if randSel == 0:\n						fb.x = 5\n					else:\n						fb.x = 6\n					print(\"Threadbear: Entering Party Room\")\n				"
				
			elif fb.y == 1:
				
				
				
				if not (fred.x == 3 and fred.y > 0):
					
					fb.y = 2
				else:
					pass
			elif fb.y == 2:
				if fred.x != 9:
					
					fb.x = 9
					fb.y = 0
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams / AudioStreamPlayer2.play()
					if not ($Center / UserInterface / CameraSystem / CamVis.visible and $Center / UserInterface / CameraSystem.currentCam == 10):
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams / AudioStreamPlayer2.volume_db = - 16
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams / AudioStreamPlayer2.play()
					
				else:
					pass
			else:
				randSel = rand.randi_range(0, 1)
				if randSel == 0:
					fb.x = 5
				else:
					fb.x = 6
				fb.y = 0
				
		5, 6:
			if fb.y == 0:
				if ((fb.x == 5 and not $Center / UserInterface / CameraSystem.door_6) or (fb.x == 6 and not $Center / UserInterface / CameraSystem.door_7)) and conveyorOn and $ConveyorOverlays / ConveyorIdle / AnimationPlayer.current_animation != "TurnOn":
					if conveyorWho == 0:
						fb.y = 1
						fb.jam = true
						conveyorWho = 5
						UpdateOrderState(0)
						$Center / UserInterface / CameraSystem.conveyorJam = true
						$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / Door5Button.visible = false
						$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / Door6Button.visible = false
						$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / Door7Button.visible = false
						if $Center / UserInterface / CameraSystem.door_5:
							$Center / UserInterface / CameraSystem._on_Door5Button_pressed()
						if $Center / UserInterface / CameraSystem.door_6:
							$Center / UserInterface / CameraSystem._on_Door6Button_pressed()
						if $Center / UserInterface / CameraSystem.door_7:
							$Center / UserInterface / CameraSystem._on_Door7Button_pressed()
						$ConveyorOverlays / WhoConveyor / AnimationPlayer.play("RESET")
						$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D10.play()
						print("Threadbear: Jamming conveyor!")
					else:
						pass
				else:
					randSel = rand.randi_range(0, 1)
					if randSel == 0:
						fb.x = 1
						fb.y = 1
					else:
						
						
						
						
						fb.x = 7
						fb.y = 0
					print("Threadbear: Blocked door/conveyor")
					if not conveyorOn and conveyorWho == 0:
						$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("EnemyFlicker")
			else:
				randSel = rand.randi_range(0, 1)
				if randSel == 0:
					fb.x = 1
					fb.y = 1
				else:
					
					
					
					
					fb.x = 7
					fb.y = 0
				print("Threadbear: Unjammed")
		8:
			
			if fb.y == 0:
				if $Center / UserInterface / CameraSystem / CamVis.visible:
					StartAttachTb()
					print("Threadbear attached")
				else:
					fb.attachWait = true
					
				fb.y = 1
			else:
				fb.x = 1
				fb.y = 1
				$Center / UserInterface / CameraSystem / CamVis / CamButtons / Cam09.modulate.a = 1.0
				$Center / UserInterface / CameraSystem / CamVis / CamButtons / Cam09 / WarnFroze.visible = false
				$Center / UserInterface / CameraSystem / CamVis / CamButtons / Cam09 / WarnFroze.stop()
				
		9:
			
			if $Center / UserInterface / CameraSystem.fan.state > 0 or hauntWho == 6:
				randSel = rand.randi_range(0, 1)
				if randSel == 0:
					fb.x = 1
					fb.y = 1
				else:
					
					
					
					
					fb.x = 7
					fb.y = 0
				if hauntWho == 6:
					StopHaunt()
				print("Threadbear: Blocked")
			else:
				SceneControl.failReason = 11
				print("Threadbear: Office (JUMPSCARE)")
				jumpscare(11)
				fb.x = 11
				fb.y = 8
			$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams / AudioStreamPlayer2.stop()
		11:
			pass
			\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
			"\n			if fb.y == 0:\n				# Enters block position\n				fb.y = 1\n				print(\"Threadbear: In block position\")\n			elif fb.y == 1:\n				if fb.side == 1:\n						$FbOffice/AnimationPlayer.play(\"FbLeave\")\n				else:\n					$FbOffice/AnimationPlayer.play(\"FbLeave2\")\n				if !lightOn || hauntWho == 5:\n					fb.y = 2\n					$RoomInterface/AudioStreamPlayer2D.play()\n					if hauntWho == 5:\n						StopHaunt()\n					print(\"Threadbear: Blocked\")\n				else:\n					fb.y = 3\n					$RoomInterface/AudioStreamPlayer2D.play()\n					print(\"Threadbear: Here he comes!\")\n			elif fb.y == 2:\n				randSel = rand.randi_range(0, 1)\n				if randSel == 0:\n					fb.x = 1\n					fb.y = 1\n				else:\n					fb.x = 3\n					fb.y = 0\n				print(\"Threadbear: Blocked\")\n			elif fb.y == 3:\n				SceneControl.failReason = 8\n				print(\"Threadbear: Office (JUMPSCARE)\")\n				fb.y = 4\n				jumpscare(5)\n				#gameStates.over = true\n			"
		4, 7:
			
			randSel = rand.randi_range(0, 1)
			if randSel == 0:
				randSel = 5
			else:
				if fb.loop <= 0:
					randSel = 5
					print("TB loop resetting")
				else:
					
					fb.loop -= 1
			
			if randSel == 5:
				fb.x = 3
				fb.y = 0
				\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
				"\n				if fb.x == 4:\n					#randSel = rand.randi_range(0, 1)\n					#if randSel == 0:\n					#	fb.x = 5\n					#else:\n					#	fb.x = 6\n					fb.x = 3\n					fb.y = 3\n					print(\"Threadbear: Entering Party Room Path\")\n				else:\n					fb.x = 3\n					fb.y = 1\n					print(\"Threadbear: Entering Vent Path\")\n				fb.loop = 1\n				"
	\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
	"\n		7:\n			randSel = rand.randi_range(0, 1)\n			if randSel == 0:\n				randSel = 5\n			else:\n				if fb.loop <= 0:\n					randSel = 5\n				else:\n					fb.loop -= 1\n			\n			if randSel == 5:\n				if chic.x != 11:\n					fb.x = 11\n					fb.y = 0\n					fb.loop = 2\n					if lightOn:\n						pass\n					else:\n						$OfficePowerOvers/FbPowerGlare.position.x = $Center.position.x\n						$OfficePowerOvers/FbPowerGlare.visible = true\n						$OfficePowerOvers/FbPowerGlare/AnimationPlayer.play(\"FrameSelect\")\n						$OfficePowerOvers/FbPowerGlare/AudioStreamPlayer.play()\n					fb.side = rand.randi_range(1, 2)\n					if fb.side == 1:\n						if lightOn:\n							$FbOffice.play(\"default\")\n						else:\n							$FbOffice.play(\"dark1\")\n						$FbOffice/AnimationPlayer.play(\"FbEnter\")\n					else:\n						if lightOn:\n							$FbOffice.play(\"side\")\n						else:\n							$FbOffice.play(\"dark2\")\n						$FbOffice/AnimationPlayer.play(\"FbEnter2\")\n					$RoomInterface/AudioStreamPlayer2D2.play()\n					if hauntSteps > 0 && lightOn:\n						CheckHaunt(5)\n					print(\"Threadbear: Entering office\")\n				else:\n					pass\n		"
	
	\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
	"\n	# ORIGINAL PATH, UNBLOCK IF NEW ONE IS BAD\n	# Path idea: Dining > Hall > (Party A, Party B) > Hall 2 (Split!)\n	# Split 1: Hall 2 > Closet (Loop) > Office > Scare\n	# Split 2: Hall 2 > Hall vent (Loop) > Vent Core > Scare\n	# Needs testing\n	match (fb.x):\n		1:\n			if fb.y == 0:\n				fb.y = 1\n				$Center/UserInterface/CameraSystem/CamVis/CamOverlays/FoxCams/AudioStreamPlayer.play()\n				if SceneControl.currentLevel == 4:\n					$Center/UserInterface/CameraSystem/CamVis/CamOverlays/FbCams/AudioStreamPlayer.play()\n			else:\n				fb.x = 3\n				fb.y = 0\n		3:\n			# Hall\n			if fb.y == 0:\n				randSel = rand.randi_range(0, 2)\n				if randSel == 0:\n					fb.x = 4\n				elif randSel == 1:\n					fb.x = 5\n				else:\n					fb.x = 6\n				fb.y = 0\n			elif fb.y == 1:\n				# 2nd time, split\n				\n				randSel = rand.randi_range(0, 1)\n				\n				if fb.pathLast == randSel:\n					fb.loopPath -= 1\n				else:\n					fb.loopPath = 2\n				\n				if fb.loopPath <= 0:\n					if randSel == 0:\n						randSel = 1\n					else:\n						randSel = 0\n					fb.loopPath = 2\n				\n				if randSel == 0:\n					fb.x = 7\n					fb.y = 0\n				else:\n					if !(fred.x == 3 && fred.y > 0):\n						# Check if fred in vent opening\n						fb.y = 2\n					else:\n						pass\n				\n				fb.pathLast = randSel\n			else:\n				# Hall vent\n				randSel = rand.randi_range(0, 1)\n				if randSel == 0:\n					randSel = 5\n				else:\n					if fb.loop <= 0:\n						randSel = 5\n					else:\n						fb.loop -= 1\n				\n				if randSel == 5:\n					fb.x = 9\n					fb.y = 0\n					fb.loop = 2\n					$Center/UserInterface/CameraSystem/CamVis/CamOverlays/FredCams/AudioStreamPlayer2.play()\n					if !$Center/UserInterface/CameraSystem/CamVis.visible:\n						$Center/UserInterface/CameraSystem/CamVis/CamOverlays/FbCams/AudioStreamPlayer2.volume_db = -16\n					$Center/UserInterface/CameraSystem/CamVis/CamOverlays/FbCams/AudioStreamPlayer2.play()\n					if hauntSteps > 0 && $Center/UserInterface/CameraSystem.fan.state == 0:\n						CheckHaunt(6)\n					print(\"Threadbear: Entering vent\")\n		5:\n			if !$Center/UserInterface/CameraSystem.door_6 && conveyorOn:\n				if conveyorWho == 0:\n					fb.x = 10\n					fb.y = 0\n					conveyorWho = 5\n					SoundHandle(1)\n					UpdateOrderState(0)\n					#StartConveyor(1, 0)\n					#if hauntSteps > 0:\n					#	CheckHaunt(3)\n				else:\n					pass\n			else:\n				fb.x = 3\n				fb.y = 1\n				fb.loop = 1\n				print(\"Threadbear: Blocked door/conveyor\")\n				if !conveyorOn && conveyorWho == 0:\n					$ConveyorOverlays/ConveyorIdle/AnimationPlayer.play(\"EnemyFlicker\")\n			\n			#fb.x = 3\n			#fb.y = 1\n		7:\n			randSel = rand.randi_range(0, 1)\n			if randSel == 0:\n				randSel = 5\n			else:\n				if fb.loop <= 0:\n					randSel = 5\n				else:\n					fb.loop -= 1\n			\n			if randSel == 5:\n				if chic.x != 11:\n					fb.x = 11\n					fb.y = 0\n					fb.loop = 2\n					if lightOn:\n						pass\n					else:\n						$OfficePowerOvers/FbPowerGlare.position.x = $Center.position.x\n						$OfficePowerOvers/FbPowerGlare.visible = true\n						$OfficePowerOvers/FbPowerGlare/AnimationPlayer.play(\"FrameSelect\")\n						$OfficePowerOvers/FbPowerGlare/AudioStreamPlayer.play()\n					fb.side = rand.randi_range(1, 2)\n					if fb.side == 1:\n						if lightOn:\n							$FbOffice.play(\"default\")\n						else:\n							$FbOffice.play(\"dark1\")\n						$FbOffice/AnimationPlayer.play(\"FbEnter\")\n					else:\n						if lightOn:\n							$FbOffice.play(\"side\")\n						else:\n							$FbOffice.play(\"dark2\")\n						$FbOffice/AnimationPlayer.play(\"FbEnter2\")\n					$RoomInterface/AudioStreamPlayer2D2.play()\n					if hauntSteps > 0 && lightOn:\n						CheckHaunt(5)\n					print(\"Threadbear: Entering office\")\n				else:\n					pass\n		9:\n			# He has just one stage in vent, slow though, longer audio cue\n			if $Center/UserInterface/CameraSystem.fan.state > 0 || hauntWho == 6:\n				randSel = rand.randi_range(0, 1)\n				if randSel == 0:\n					fb.x = 1\n					fb.y = 1\n				else:\n					fb.x = 3\n					fb.y = 0\n				if hauntWho == 6:\n					StopHaunt()\n				print(\"Threadbear: Blocked\")\n			else:\n				SceneControl.failReason = 11\n				print(\"Threadbear: Office (JUMPSCARE)\")\n				jumpscare(11)\n				fb.x = 11\n				fb.y = 8\n				#gameStates.over = true\n			$Center/UserInterface/CameraSystem/CamVis/CamOverlays/FbCams/AudioStreamPlayer2.stop()\n		11:\n			if fb.y == 0:\n				# Enters block position\n				fb.y = 1\n				print(\"Threadbear: In block position\")\n			elif fb.y == 1:\n				if fb.side == 1:\n						$FbOffice/AnimationPlayer.play(\"FbLeave\")\n				else:\n					$FbOffice/AnimationPlayer.play(\"FbLeave2\")\n				if !lightOn || hauntWho == 5:\n					fb.y = 2\n					$RoomInterface/AudioStreamPlayer2D.play()\n					if hauntWho == 5:\n						StopHaunt()\n					print(\"Threadbear: Blocked\")\n				else:\n					fb.y = 3\n					$RoomInterface/AudioStreamPlayer2D.play()\n					print(\"Threadbear: Here he comes!\")\n			elif fb.y == 2:\n				randSel = rand.randi_range(0, 1)\n				if randSel == 0:\n					fb.x = 1\n					fb.y = 1\n				else:\n					fb.x = 3\n					fb.y = 0\n				print(\"Threadbear: Blocked\")\n			elif fb.y == 3:\n				SceneControl.failReason = 8\n				print(\"Threadbear: Office (JUMPSCARE)\")\n				fb.y = 4\n				jumpscare(5)\n				#gameStates.over = true\n		4, 6:\n			#4, 5, 6:\n			fb.x = 3\n			fb.y = 1\n	\n	# New attach stuff\n	if fb.attachSteps > 0:\n		if fb.attachSteps == 1:\n			timeFbBuffMax = rand.randf_range(0.4, 0.8)\n			fb.attachSteps = 0\n			print(\"Threadbear: Attach ready!\")\n		else:\n			fb.attachSteps -= 1\n	"
	
	
	if fb.seen and not (fb.x == prevRoom and fb.y == prevDepth):
		fb.seen = false
	
	if not $Center / UserInterface / CameraSystem.camFroze:
		camPos.fb[0] = fb.x
		camPos.fb[1] = fb.y
		if not (camPos.fb[0] == prevRoom and camPos.fb[1] == prevDepth):
			UpdateRoomState(camPos.fb[0])
			UpdateRoomState(prevRoom)
	
	if fb.x == 11:
		if fb.y < 3:
			timeFb = rand.randi_range(6, 8) * (20 / fb.activity)
		else:
			
			timeFb = rand.randi_range(6, 8)
	elif fb.x == 9:
		
		timeFb = (rand.randi_range(4, (6 + (4 - (orderStates.step[1] / 2)))) * (20 / fb.activity) + 6)
		
	else:
		timeFb = rand.randi_range(4, (6 + (4 - (orderStates.step[1] / 2)))) * (20 / fb.activity)
	
	

func UpdateRoomState( var room):
	
	if room == $Center / UserInterface / CameraSystem.currentCam - 1 and $Center / UserInterface / CameraSystem / CamVis.visible:
		$Center / UserInterface / CameraSystem / CamVis / BlockCam.visible = true
		$Center / UserInterface / CameraSystem / CamVis / AudioStreamPlayer2.play(rand_range(0.0, 4.0))
		$Center / UserInterface / CameraSystem / CamVis / static1 / AudioStreamPlayer.play()
		timeCamBlock = 0
	
	
	if room == $Center / UserInterface / CameraSystem.currentCam - 1 and $Center / UserInterface / CameraSystem.camActive:
		UpdateCamVis()
	
	if room == 3 and $Center / UserInterface / CameraSystem.secretCam.hallFree:
		$Center / UserInterface / CameraSystem.secretCam.hallFree = false
		if $Center / UserInterface / CameraSystem / CamVis / CamOverlays / GoldenIdea.visible:
			$Center / UserInterface / CameraSystem / CamVis / CamOverlays / GoldenIdea.visible = false
		print("Hall free locked")

func UpdateCamVis():
	
	
	
	
	var viewing = $Center / UserInterface / CameraSystem.currentCam - 1
	
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.visible = false
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.visible = false
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.visible = false
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.visible = false
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.visible = false
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbShadow.visible = false
	
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / WireBlow.visible = false
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbPit / AnimationPlayer.play("RESET")
	
	
	if camPos.fred[0] == viewing:
		match (viewing):
			0:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("stage")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.position = Vector2(96, - 150)
			1:
				if not camHeadless:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam2_1")
				else:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam2_1b")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.position = Vector2(454, - 245)
			3:
				if camPos.fred[1] == 0:
					if not camHeadless:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam4_1")
					else:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam4_1b")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.position = Vector2( - 207, 286)
				else:
					if not camHeadless:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam4_2")
					else:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam4_2b")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.position = Vector2( - 133, - 401)
			5:
				if camPos.fred[1] == 0:
					if not camHeadless:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam6_1")
					else:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam6_1b")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.position = Vector2( - 159, 248)
				elif camPos.fred[1] == 1:
					if not camHeadless:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam6_2")
					else:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam6_2b")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.position = Vector2( - 281, - 283)
				else:
					if not camHeadless:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam6_3")
					else:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam6_3b")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.position = Vector2(426, - 156)
			6:
				if not camHeadless:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam7_1")
				else:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.play("cam7_1b")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.position = Vector2(342, 280)
			9:
				if camPos.fred[1] == 0:
					if not camHeadless:
						$Center / UserInterface / CameraSystem / CamVis.play("cam_10_1")
					else:
						$Center / UserInterface / CameraSystem / CamVis.play("cam_10_4")
					
				elif camPos.fred[1] == 1:
					$Center / UserInterface / CameraSystem / CamVis.play("cam_10_2")
					
				else:
					if not camHeadless:
						if not $Center / UserInterface / CameraSystem.camFroze:
							$Center / UserInterface / CameraSystem / CamVis.play("cam_10_3")
						else:
							$Center / UserInterface / CameraSystem / CamVis.play("cam_10")
					else:
						$Center / UserInterface / CameraSystem / CamVis.play("cam_10_5")
					
		if camPos.fred[0] != 9:
			$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FredCams.visible = true
	
	
	if camPos.bon[0] == viewing:
		match (viewing):
			0:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.play("stage")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.position = Vector2( - 480, 0)
			1:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.play("cam2_2")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.position = Vector2( - 158, - 337)
			3:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.play("cam4_3")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.position = Vector2( - 441, - 45)
			4:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.play("cam5_1")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.position = Vector2( - 147, 183)
			7:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.play("cam8_1")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.position = Vector2( - 186, 13)
			8:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.play("cam9_7")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.position = Vector2( - 238, 42)
		if not (camPos.bon[0] == 3 and camPos.bon[1] > 0):
			$Center / UserInterface / CameraSystem / CamVis / CamOverlays / BonCams.visible = true
	
	
	if camPos.chic[0] == viewing:
		match (viewing):
			0:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.play("stage")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.position = Vector2(480, 0)
			1:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.play("cam2_3")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.position = Vector2( - 547, - 249)
			3:
				if camPos.chic[1] == 0:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.play("cam4_4")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.position = Vector2( - 130, - 7)
				else:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.play("cam4_5")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.position = Vector2( - 511, - 241)
			4:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.position = Vector2(567, - 79)
			6:
				if camPos.chic[1] == 0:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.play("cam7_2")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.position = Vector2(322, 234)
				else:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.play("cam7_3")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.position = Vector2(97, - 94)
			7:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.play("cam8_2")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.position = Vector2(244, 160)
		$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChicCams.visible = true
	
	
	if camPos.fox[0] == viewing:
		match (viewing):
			1:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.play("cam2_4")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.position = Vector2( - 13, - 311)
			2:
				if camPos.fox[1] == 0:
					$Center / UserInterface / CameraSystem / CamVis.play("cam3")
				elif camPos.fox[1] == 1:
					$Center / UserInterface / CameraSystem / CamVis.play("cam3_1")
			3:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.play("cam4_6")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.position = Vector2(434, 258)
			4:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.play("cam5_2")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.position = Vector2(353, 61)
			8:
				if camPos.fox[1] == 0:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.play("cam9_1")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.position = Vector2( - 568, 256)
				elif camPos.fox[1] == 1:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.play("cam9_2")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.position = Vector2( - 459, 176)
				elif camPos.fox[1] == 2:
					$Center / UserInterface / CameraSystem / CamVis.play("cam9_3")
					if $Center / UserInterface / CameraSystem.camFroze:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / WireBlow.visible = true
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / VidBox.play("red")
				else:
					if not $Center / UserInterface / CameraSystem.camBackup:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.play("cam9_4")
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.position = Vector2( - 76, 133)
					else:
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.play("cam9_6")
						$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.position = Vector2( - 575, 249)
		if camPos.fox[0] != 2 and ( not (camPos.fox[0] == 8 and camPos.fox[1] > 1) or (camPos.fox[0] == 8 and camPos.fox[1] > 2)):
			$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FoxCams.visible = true
	elif viewing == 2:
		$Center / UserInterface / CameraSystem / CamVis.play("cam3_2")
	
	
	if camPos.fb[0] == viewing:
		match (viewing):
			0:
				pass
			1:
				if camPos.fb[1] > 0:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam2_5")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2( - 782, - 282)
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbPit.play("default")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbPit / AnimationPlayer.play("PitIdle")
			2:
				pass
			3:
				if camPos.fb[1] == 0:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam4_9")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2( - 318, 30)
				elif camPos.fb[1] == 1:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam4_7")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2( - 318, 34)
				elif camPos.fb[1] == 2:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam4_8")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2( - 159, - 265)
				elif camPos.fb[1] == 3:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam4_10")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2( - 318, 30)
			4:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam5_3")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2( - 43, 322)
			5:
				if camPos.fb[1] == 0:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam6_5")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2(43, - 50)
				else:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam6_7")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2(192, - 244)
			6:
				if camPos.fb[1] == 0:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam7_5")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2(11, 32)
				else:
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam7_7")
					$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2(23, - 294)
			7:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam8_3")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2( - 124, 356)
			8:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.play("cam9_8")
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.position = Vector2(349, 9)
			9:
				$Center / UserInterface / CameraSystem / CamVis.play("cam_10_6")
		
		if not (camPos.fb[0] == 1 and camPos.fb[1] == 0) and camPos.fb[0] != 9:
			$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams.visible = true
			if camPos.fb[0] == 8:
				$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbShadow.visible = true
		
		if not (fb.x == 1 and fb.y == 0) and camPos.fb[0] != 9 and fb.attachSteps <= 0:
			if not fb.attach and not fb.seen:
				if timeFbCamBuff < 0:
					timeFbCamBuff = 0
					
	
	if viewing == 8 and not (camPos.fox[0] == 8 and camPos.fox[1] == 2):
		if not $Center / UserInterface / CameraSystem.camBackup:
			$Center / UserInterface / CameraSystem / CamVis.play("cam9")
		else:
			$Center / UserInterface / CameraSystem / CamVis.play("cam9_5")
	elif viewing == 9 and camPos.fred[0] != 9 and camPos.fb[0] != 9:
		$Center / UserInterface / CameraSystem / CamVis.play("cam_10")
	elif viewing == 1 and camPos.fb[0] > 1:
		$Center / UserInterface / CameraSystem / CamVis.play("cam2_6")
		$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbPit.play("out")
		$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbPit / AnimationPlayer.play("PitIdle")

func _on_CameraSystem_cam_reload():
	camPos.fred = [fred.x, fred.y]
	camPos.bon = [bon.x, bon.y]
	camPos.chic = [chic.x, chic.y]
	camPos.fox = [fox.x, fox.y]
	camPos.fb = [fb.x, fb.y]
	camHeadless = fred.headless
	UpdateCamVis()


func _on_ConveyorButton_pressed():
	
	if not coolDown and SceneControl.currentLevel != 6 and not ((hauntPending == 4 or $Center.shocker.active) and not $Center.powerLock):
		if $ConveyorOverlays / ConveyorIdle / AnimationPlayer.current_animation == "EnemyFlicker":
			HideConvEnemy()
		conveyorOn = not conveyorOn
		coolDown = true
		if not conveyorOn and not $Center.powerLock:
			if hauntWho != 3:
				conveyorAnimState = 1
				$Center.UpdatePowerSystem(6)
				UpdateOrderState(0)
				$OfficeOverlays / LeverSprite.play("flipOn")
				if not fb.jam:
					$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("ShutDown")
				else:
					$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("ShutDownJam")
				$RoomInterface / ToolButtons / ConveyorButton / AudioStreamPlayer.play()
				
				if conveyorWho > 0:
					match (conveyorWho):
						1:
							timeFred = 2
							if not fred.headless:
								SoundHandle(5)
							else:
								SoundHandle(4)
						2:
							timeBon = 2
							SoundHandle(5)
						3:
							timeChic = 2
							SoundHandle(5)
						4:
							timeFox = 2
							SoundHandle(4)
					$ConveyorOverlays / WhoConveyor / AnimationPlayer.stop(false)
				if not fb.jam:
					$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D.play()
				else:
					$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D9.play()
				$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D6.stop()
				$ConveyorOverlays / WhoConveyor / WhoEyes.visible = false
			else:
				jumpscare(14)
		else:
			conveyorAnimState = 3
			$Center.UpdatePowerSystem( - 6)
			if not fb.jam:
				UpdateOrderState(2)
			$OfficeOverlays / LeverSprite.play("flipOff")
			if not $ConveyorOverlays / ConveyorIdle / AnimationPlayer.current_animation == "EnemyFlicker":
				$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("TurnOn")
			else:
				FlickerDone()
			$RoomInterface / ToolButtons / ConveyorButton / AudioStreamPlayer2.play()
			if conveyorWho > 0:
				match (conveyorWho):
					1:
						timeFred = 10
						if not fred.headless:
							SoundHandle(1)
						else:
							SoundHandle(3)
					2:
						timeBon = 10
						SoundHandle(1)
					3:
						timeChic = 10
						SoundHandle(1)
					4:
						timeFox = 10
						SoundHandle(3)
			$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D.stop()
			$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D6.play()
			$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D9.stop()
	elif $Center.shocker.active:
		if hauntWho == 3:
			$Center.HauntedShock()
	else:
		if hauntPending != 4:
			if not (conveyorAnimState == 1 or conveyorAnimState == 3):
				if not $OfficeOverlays / LeverCool / AudioStreamPlayer.playing:
					$OfficeOverlays / LeverCool / AudioStreamPlayer.play()

func _on_FoodButton_pressed():
	if not gameStates.over and orderStates.step == [orderStates.maxStep, 2] and lightOn:
		gameStates.win = true
		$Center / UserInterface / UIText.visible = false
		$Center / UserInterface / CameraSystem.visible = false
		$RoomInterface / ToolButtons.visible = false
		$Center / UserInterface / WinTxt / AnimationPlayer.play("WinFade")
		$Center / UserInterface / WinTxt.visible = true
		$OfficeOverlays / OrderTray / AnimationPlayer.play("RESET")
		$OfficeOverlays / OrderRandTray / AnimationPlayer.play("RESET")
		$Center / UserInterface / HitRight.visible = false
		$Center / UserInterface / HitLeft.visible = false
		orderStates.step = [0, 0]
		$Center / UserInterface / CameraSystem.UpdateOrderCam(4)
		_on_ConfirmButton_pressed()
		orderStates.destination = 0
		if tempCurrentLevel == 2:
			SceneControl.inCutscene = 1
		SceneControl.AdvanceLevel()
		gameStates.over = true
		ResetLevel(1)
		
		if SceneControl.currentLevel == 7:
			$Center / JumpscareSprite.scale = Vector2(2, 2)
			$Center / JumpscareSprite.z_index = - 1
			$Center / JumpscareSprite.play("basket")
			$Center / JumpscareSprite.visible = true
			$OfficeOverlays / OrderTray / AnimationPlayer.play("RESET")
			$Center / UserInterface / WinTxt.visible = false
			$Center / UserInterface / Shocker.visible = false
			SoundController.PlayScare(9)
		else:
			if not SceneControl.performant:
				$Center / UserInterface / ConfettiParticles.visible = true
				$Center / UserInterface / ConfettiParticles.emitting = true
			else:
				$Center / UserInterface / ConfettiParticlesCPU.visible = true
				$Center / UserInterface / ConfettiParticlesCPU.emitting = true
			if not SceneControl.performant:
				$Center / UserInterface / HatParticles.visible = true
				$Center / UserInterface / HatParticles.emitting = true
			else:
				$Center / UserInterface / HatParticlesCPU.visible = true
				$Center / UserInterface / HatParticlesCPU.emitting = true
			$Center / UserInterface / AmbiencePlayer_quiet.stop()
			$Center / UserInterface / AmbiencePlayer_drone1.stop()
			$Center / UserInterface / AmbiencePlayer_ghosts.stop()
			$RoomInterface / ToolButtons / FoodButton / AudioStreamPlayer.play()
			$Center / UserInterface / WinTxt / AudioStreamPlayer.play()
		
		print("Level completed.")

func _on_LightButton_pressed():
	if (timeLight == - 1 and not $Center.pistol.active and not $Center.shocker.active) or ($Center.powerLock and not lightOn):
		if lightOn:
			if hauntWho != 4 and hauntWho != 5:
				
				$OfficeSprite.play("outage")
				$DeskSprite.play("deskOut")
				$BackSprite.play("out")
				$OfficeOverlays.visible = false
				$Center.UpdatePowerSystem(2)
				$RoomInterface.DisableInterface(true)
				if not SceneControl.performant:
					$OfficePowerOvers / LightParticles.visible = true
					$OfficePowerOvers / LightParticles.emitting = true
				else:
					$OfficePowerOvers / LightParticlesCPU.visible = true
					$OfficePowerOvers / LightParticlesCPU.emitting = true
				timeLight = 0
				if (bon.x == 3 and bon.y == 1) or bon.window:
					if bon.side == 1:
						$BonOffice.play("dark_2")
					elif bon.side == 2:
						$BonOffice.play("dark_1")
					else:
						$BonOffice.play("dark_3")
				if chic.x == 11:
					
					if chic.y == 0:
						$ChicDesk.play("dark_1")
					elif $ChicDesk.animation == "leave_1" or $ChicDesk.animation == "leave_2" or $ChicDesk.animation == "leave_3" or $ChicDesk.animation == "leave_4":
						$ChicDesk.modulate = Color(0, 0, 0, 1)
				if fb.x == 11:
					$OfficePowerOvers / FbPowerGlare.position.x = $Center.position.x
					$OfficePowerOvers / FbPowerGlare.visible = true
					$OfficePowerOvers / FbPowerGlare / AudioStreamPlayer.play()
					if fb.side == 1:
						$FbOffice.play("dark1")
					else:
						$FbOffice.play("dark2")
					$OfficePowerOvers / FbPowerGlare / AnimationPlayer.play("FrameSelect")
				lightOn = not lightOn
				if not conveyorOn:
					_on_ConveyorButton_pressed()
				$Center / UserInterface / CameraSystem / MonitorAnim.modulate = Color(0.18, 0.24, 0.49, 1)
				$RoomInterface / ToolButtons / LightButton / AudioStreamPlayer.play()
				$OfficeOverlays / LightRef / AudioStreamPlayer2D.stop()
				$DeskSprite / AudioStreamPlayer2D.stop()
				
				if SceneControl.currentLevel == 7:
					$Center / UserInterface / Shocker.visible = false
				if $OfficePowerOvers / Tree.visible:
					$OfficePowerOvers / Tree.modulate = Color(0, 0, 0, 1)
				
			else:
				jumpscare(15)
		else:
			
			$OfficeSprite.play("default")
			$DeskSprite.play("default")
			$BackSprite.play("default")
			$OfficeOverlays.visible = true
			$Center.UpdatePowerSystem( - 2)
			if orderStates.step != [orderStates.maxStep, 2]:
				$RoomInterface.DisableInterface(false)
			else:
				$RoomInterface.EnableFood()
				$RoomInterface.EnablePistol()
			$RoomInterface.DisableLightButton()
			$OfficePowerOvers / LightButtonSprite.play("light2")
			timeLight = 0
			if (bon.x == 3 and bon.y == 1) or bon.window:
				if bon.side == 1:
					$BonOffice.play("front")
				elif bon.side == 2:
					$BonOffice.play("default")
				else:
					$BonOffice.play("left")
			if bon.window:
				timeLightBon = 0
			if chic.x == 11:
				if chic.y == 0:
					$ChicDesk.play("default")
				$ChicDesk.modulate = Color(1, 1, 1, 1)
			if fb.x == 11:
				timeLightFb = 0
			if $FbOffice.visible:
				if fb.side == 1:
					$FbOffice.play("default")
				else:
					$FbOffice.play("side")
			if $OfficePowerOvers / FbPowerGlare.visible:
				$OfficePowerOvers / FbPowerGlare.visible = false
				$OfficePowerOvers / FbPowerGlare / AnimationPlayer.stop()
				$OfficePowerOvers / FbPowerGlare / AudioStreamPlayer.stop()
			lightOn = not lightOn
			$Center / UserInterface / CameraSystem / MonitorAnim.modulate = Color(1, 1, 1, 1)
			$OfficeOverlays / LightRef / AudioStreamPlayer2D.play()
			$DeskSprite / AudioStreamPlayer2D.play()
			$RoomInterface / ToolButtons / LightButton / AudioStreamPlayer3.play()
			if SceneControl.currentLevel == 7 and not gameStates.over:
				$Center / UserInterface / Shocker.visible = true
			if $OfficePowerOvers / Tree.visible:
					$OfficePowerOvers / Tree.modulate = Color(1, 1, 1, 1)
		$RoomInterface / ToolButtons / LightButton / AudioStreamPlayer2.play()
	elif $Center.shocker.active:
		if hauntWho == 4:
			$Center.HauntedShock()

func _on_LightBoxButton_pressed():
	
	$Center.bulbHold = true
	$Center / UserInterface / BulbFresh.visible = true
	$RoomInterface.EnableLightBox(false)
	$OfficeOverlays / LightBox.visible = false
	$Center / UserInterface / BulbSpot.visible = true
	$RoomInterface / LightBoxButton / AudioStreamPlayer.play()

func _on_BulbSpot_pressed():
	$Center.bulbHold = false
	$Center / UserInterface / BulbFresh.visible = false
	$Center / UserInterface / BulbSpot.visible = false
	$Center / UserInterface / DialogueSystem / Walkie / AnimationPlayer.play("Enter")
	$Center / UserInterface / DialogueSystem / DialogueBox / Subtitles.SetDialText(2)
	UpdateOrderState(0)
	$OfficeOverlays / OrderLight / AnimationPlayer.play("RESET")
	$OfficeOverlays / OrderLight.play("new")
	$OfficeOverlays / OrderLightBase.play("new")
	if not SceneControl.performant:
		$OfficeOverlays / BulbSmoke.emitting = false
		$OfficeOverlays / BulbSmoke.visible = false
	else:
		$OfficeOverlays / BulbSmokeCPU.emitting = false
		$OfficeOverlays / BulbSmokeCPU.visible = false
	$OfficeOverlays / OrderSprite / AudioStreamPlayer2D4.stop()
	gameStates.tutorialStep = 2
	$RoomInterface / LightBoxButton / AudioStreamPlayer2.play()
	TutorialLock(true)

func _on_ConfirmButton_pressed():
	if $Center / UserInterface / CameraSystem.orderCam1 or $Center / UserInterface / CameraSystem.orderCam2:
		$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / AudioStreamPlayer.play()
	
	if orderStates.destination == 0:
		$Center / UserInterface / CameraSystem.orderCam1 = false
		if $Center / UserInterface / CameraSystem.currentCam == 6 and SceneControl.currentLevel != 6 and not $Center / UserInterface / CameraSystem.toolDisconnect.door6 and not fb.jam:
			$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / Door6Button.visible = true
		$Center / UserInterface / CameraSystem / CamVis / CamButtons / Cam06 / CamDoor.visible = false
		$Center / UserInterface / CameraSystem / CamVis / CamButtons / Cam06 / CamDoor.texture = load("res://Sprites/Cameras/miniDoor2.png")
		$Center / UserInterface / CameraSystem.TimeoutButton(1)
	elif orderStates.destination == 1:
		$Center / UserInterface / CameraSystem.orderCam2 = false
		if $Center / UserInterface / CameraSystem.currentCam == 7 and SceneControl.currentLevel != 6 and not $Center / UserInterface / CameraSystem.toolDisconnect.door7 and not fb.jam:
			$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / Door7Button.visible = true
		$Center / UserInterface / CameraSystem / CamVis / CamButtons / Cam07 / CamDoor.visible = false
		$Center / UserInterface / CameraSystem / CamVis / CamButtons / Cam07 / CamDoor.texture = load("res://Sprites/Cameras/miniDoor2.png")
		$Center / UserInterface / CameraSystem.TimeoutButton(2)
	else:
		$Center / UserInterface / CameraSystem / CamVis / CamButtons / orderDot3.visible = false
	$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / ConfirmButton.visible = false
	orderStates.confirm = false
	if SceneControl.currentLevel != 10 and SceneControl.currentLevel != 8:
		orderStates.destination += 1
	else:
		$Center / UserInterface / CameraSystem.orderConfirm = false
		if orderStates.destination == 1 and ((orderStates.step[0] + 1) != orderStates.maxStep):
			orderStates.destination = 0
		else:
			orderStates.destination += 1
	
	timeLevel.current = 0

func _on_EnterRepairButton_pressed():
	SceneTransition.NextScene("res://Scenes/ConveyorRepair.tscn", self)

func _on_EnterHallButton_pressed():
	SceneTransition.NextScene("res://Scenes/WinGame.tscn", self)

func _on_HonkButton_pressed():
	if not $Center / UserInterface / CameraSystem.camActive and not $Center.pistol.active and lightOn and not $OfficeOverlays.winkPlay:
		$OfficeOverlays / FredWink.frame = 0
		$OfficeOverlays / FredWink.play()
		$RoomInterface / HonkButton / AudioStreamPlayer.stop()
		$RoomInterface / HonkButton / AudioStreamPlayer2.stop()
		$RoomInterface / HonkButton / AudioStreamPlayer3.stop()
		match ($OfficeOverlays.whichHonk):
			0:
				$RoomInterface / HonkButton / AudioStreamPlayer.play()
			1:
				$RoomInterface / HonkButton / AudioStreamPlayer2.play()
			2:
				$RoomInterface / HonkButton / AudioStreamPlayer3.play()
		if $OfficeOverlays.whichHonk < 2:
			$OfficeOverlays.whichHonk += 1
		else:
			$OfficeOverlays.whichHonk = 0
		print($OfficeOverlays.whichHonk)
		$OfficeOverlays.winkPlay = true

func _on_Center_start_fire():
	if chic.firePos:
		chic.y = 1
		
		if chic.activity <= 6:
			timeChic = rand.randf_range(2.5, 3)
		elif chic.activity <= 10:
			timeChic = rand.randf_range(2.0, 2.4)
		else:
			timeChic = rand.randf_range(1.8, 2.2)
		$ChicDesk.play("attack")
		$ChicDesk / EyeArea / AnimationPlayer.play("EyeAttack")
		chic.firePos = false
		$Center.pistol.lock = true
		$BackBufferCopy / AnimationPlayer.play("IntenseIdle")
		$ChicDesk / EyeArea / CollisionShape2D.disabled = false
		$RoomInterface / ToolButtons / LightButton.visible = false
		$Center / UserInterface / FoamPistol / AudioStreamPlayer2D3.play()
		$Center / UserInterface / UIText / FireTxt.text = "\nLeft click: Fire"
		print("Fire started")

func _on_CameraSystem_get_room_state():
	UpdateCamVis()

func UpdateOrderState( var advance):
	
	
	
	if advance == 1:
		if orderStates.step[1] < 2:
			orderStates.step[1] += 1
		else:
			orderStates.step[1] = 0
		$Center / UserInterface / CameraSystem.UpdateOrderCam(5)
		$OfficeOverlays / OrderSprite / AudioStreamPlayer2D.play()
		
		
		if orderStates.destination == 0 and orderStates.step[1] == 2:
			$Center / UserInterface / CameraSystem.UpdateOrderCam(1)
			orderStates.confirm = true
			CheckAIUpdate(1)
		elif orderStates.destination == 1 and orderStates.step[1] == 2:
			$Center / UserInterface / CameraSystem.UpdateOrderCam(2)
			orderStates.confirm = true
			CheckAIUpdate(2)
		elif orderStates.step == [orderStates.maxStep, 2]:
			print("Food delivered.")
			if SceneControl.currentLevel != 8:
				$OfficeOverlays / OrderTray / AnimationPlayer.play("DropOrder")
				$RoomInterface / ToolButtons / FoodButton.rect_position = Vector2(702, 767)
			else:
				$OfficeOverlays / OrderRandTray / AnimationPlayer.play("DropRand")
				$RoomInterface / ToolButtons / FoodButton.rect_position = Vector2(2310, 119)
				$RoomInterface / ToolButtons / FoodButton.visible = true
			$RoomInterface.DisableConveyor()
			$RoomInterface / ToolButtons / ConveyorButton.visible = false
			$Center / UserInterface / CameraSystem.UpdateOrderCam(3)
			$OfficeOverlays / OrderLight / AnimationPlayer.play("lightOn")
			if SceneControl.currentLevel == 1:
				$OfficeOverlays / OrderLight.play("default")
			else:
				$OfficeOverlays / OrderLight.play("new")
			$OfficeOverlays / AudioStreamPlayer2D.play()
			$OfficeOverlays / OrderSprite / orderLight.play()
		elif SceneControl.currentLevel == 8 and orderStates.step[1] == 2:
			match ($Center / UserInterface / CameraSystem.randomDestinations[$Center / UserInterface / CameraSystem.ordersDelivered]):
				4:
					$Center / UserInterface / CameraSystem.UpdateOrderCam(6)
					orderStates.confirm = true
				5:
					$Center / UserInterface / CameraSystem.UpdateOrderCam(6)
					orderStates.confirm = true
				6:
					$Center / UserInterface / CameraSystem.UpdateOrderCam(6)
					orderStates.confirm = true
				7:
					$Center / UserInterface / CameraSystem.UpdateOrderCam(6)
					orderStates.confirm = true
				11:
					$Center / UserInterface / CameraSystem.UpdateOrderCam(6)
					orderStates.confirm = true
				12:
					$Center / UserInterface / CameraSystem.UpdateOrderCam(6)
					orderStates.confirm = true
			if orderStates.step[0] == 0:
				$Center / UserInterface / CameraSystem / CamVis / OrderLab.visible = true
	
	
	if advance > 0:
		if orderStates.step[1] == 0:
			if advance == 1:
				orderStates.step[0] += 1
				$Center / UserInterface / UIText / LevelTxt.modulate = Color(1, 1, 1, 1)
				$Center / UserInterface / CameraSystem / Area2D / camhit / AnimationPlayer.play("RESET")
				timeLevel.current = timeLevel.prep
				$OfficeOverlays / OrderSprite / orderNote1.play()
			$OfficeOverlays / OrderSprite.play("1")
		elif orderStates.step[1] == 1:
			$OfficeOverlays / OrderSprite.play("2")
			if advance == 1:
				timeLevel.current = timeLevel.send
				$OfficeOverlays / OrderSprite / orderNote2.play()
		else:
			$OfficeOverlays / OrderSprite.play("3")
			$Center / UserInterface / UIText / LevelTxt.modulate = Color(1, 0.99, 0.2, 1)
			if advance == 1:
				if orderStates.step != [orderStates.maxStep, 2]:
					$OfficeOverlays / OrderSprite / orderNote3.play()
				else:
					$OfficeOverlays / OrderSprite / orderNote4.play()
		$Center / UserInterface / UIText / LevelTxt.modulate.a = 1
		$Center / UserInterface / UIText / LevelTxt2.modulate.a = 1
	else:
		if not fb.jam:
			$Center / UserInterface / UIText / LevelTxt.modulate = Color(1, 1, 1, 0.5)
			$Center / UserInterface / UIText / LevelTxt2.modulate = Color(1, 1, 1, 0.5)
		else:
			$Center / UserInterface / UIText / LevelTxt.modulate = Color(1, 0, 0, 0.8)
			$Center / UserInterface / UIText / LevelTxt2.modulate = Color(1, 0, 0, 0.8)
		$OfficeOverlays / OrderSprite.play("off")
	
	if advance == 2 and orderStates.step == [0, 0] and timeLevel.current == timeLevel.prep:
		if SceneControl.currentLevel == 9:
			$Center / UserInterface / CameraSystem.camIceTime = 0
		$OfficeOverlays / OrderSprite / orderNote1.play()
		$OfficeOverlays / OrderSprite / AudioStreamPlayer2D.play()
		if SceneControl.currentLevel == 7:
			$Center / UserInterface / Shocker.visible = true
	
	
	
	
	
	
	
	UpdateLabels()

func CheckAIUpdate( var which):
	
	if which == 1:
		match (SceneControl.currentLevel):
			1:
				pass
			2:
				fred.activity = 6
				bon.activity = 8
				chic.activity = 5
			3:
				fred.activity = 10
				bon.activity = 6
				chic.activity = 8
				fox.activity = 8
			4:
				bon.activity = 9
				chic.activity = 9
				fox.activity = 5
				fb.activity = 10
			6:
				fred.activity = 7
				fox.activity = 8
			7:
				
				bon.activity = 8
				chic.activity = 12
			9:
				fred.activity = 12
				bon.activity = 12
				$Center / UserInterface / CameraSystem.camIceMult = 0.8
			10:
				if orderStates.step[0] == 2:
					
					
					
					
					
					
					pass
				elif orderStates.step[0] == 4:
					
					
					bon.activity = 12
					chic.activity = 12
					fox.activity = 12
					
	else:
		match (SceneControl.currentLevel):
			1:
				bon.activity = 6
				chic.activity = 8
			2:
				fred.activity = 8
				bon.activity = 10
				chic.activity = 6
			3:
				fred.activity = 12
				bon.activity = 3
				chic.activity = 10
				fox.activity = 6
			4:
				fred.activity = 8
				bon.activity = 10
				chic.activity = 12
				fox.activity = 7
				fb.activity = 12
			6:
				fred.activity = 9
				bon.activity = 7
				chic.activity = 12
				
			7:
				fred.activity = 12
				bon.activity = 10
				
				fox.activity = 8
			9:
				bon.activity = 14
				chic.activity = 7
				fb.activity = 7
				$Center / UserInterface / CameraSystem.camIceMult = 0.5

func PowerLock( var lock):
	if lock:
		$Center.powerLock = true
		if not conveyorOn:
			coolDown = false
			_on_ConveyorButton_pressed()
			print("Locking conveyor")
		if not lightOn:
			_on_LightButton_pressed()
		if $Center / UserInterface / CameraSystem.fan.state == 1 or $Center / UserInterface / CameraSystem.fan.state == 2:
			$Center / UserInterface / CameraSystem.fan.state = 2
			$Center / UserInterface / CameraSystem.UpdateFanState()
		if $Center / UserInterface / CameraSystem.door_5:
			$Center / UserInterface / CameraSystem._on_Door5Button_pressed()
		if $Center / UserInterface / CameraSystem.door_6:
			$Center / UserInterface / CameraSystem._on_Door6Button_pressed()
		if $Center / UserInterface / CameraSystem.door_7:
			$Center / UserInterface / CameraSystem._on_Door7Button_pressed()
		if $Center / UserInterface / CameraSystem.serviceLight:
			$Center / UserInterface / CameraSystem._on_ServiceButton_pressed()
		$Center / UserInterface / CameraSystem.LockButtonInputs(true)
		$RoomInterface.DisableConveyor()
		$RoomInterface.DisableLightButton()
		$OfficePowerOvers / LightButtonSprite.play("light2")
		$OfficePowerOvers / LightButtonSprite.visible = true
		$RoomInterface / ToolButtons / ConveyorButton.visible = false
		$RoomInterface / ToolButtons / LightButton.visible = false
	else:
		if orderStates.step != [orderStates.maxStep, 2]:
			$Center / UserInterface / CameraSystem.LockButtonInputs(false)
			$RoomInterface.EnableConveyor()
			$RoomInterface.EnableLightButton()
			$RoomInterface / ToolButtons / ConveyorButton.visible = true
		$Center / UserInterface / CameraSystem.LockButtonInputs(false)
		$OfficePowerOvers / LightButtonSprite.visible = false
		$RoomInterface / ToolButtons / LightButton.visible = true
		$Center.powerLock = false
		
		print("power unlocked")

func ChicEnterFire():
	chic.firePos = true
	print("Entered fire position")
	if hauntPending != 3:
		if $Center.pistol.active and not $Center.pistol.fired:
			_on_Center_start_fire()

func BonAtWindow():
	timeBon = rand.randi_range(6, 8) * (20 / bon.activity)
	bon.window = true

func FlickerDone():
	if conveyorWho > 0:
		$ConveyorOverlays / WhoConveyor / AnimationPlayer.play()
		$ConveyorOverlays / WhoConveyor / WhoEyes.visible = true
	$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("RESET")

func ConvNext():
	print("Frame advanced")
	conveyorPos += 1

func HideConvEnemy():
	$ConveyorOverlays / ConveyorBack.play("default")
	$ConveyorOverlays / WhoConveyor.visible = false
	$ConveyorOverlays / WhoConveyor / AnimationPlayer.play("RESET")
	conveyorAudioPos = 0
	conveyorWho = 0
	conveyorPos = 0

func StartConveyor(conveyorIn, how):
	match (conveyorIn):
		1:
			if not fred.headless:
				$ConveyorOverlays / WhoConveyor.play("fred")
				$ConveyorOverlays / WhoConveyor / WhoEyes.play("fred_eyes")
			else:
				$ConveyorOverlays / WhoConveyor.play("fred_head")
				$ConveyorOverlays / WhoConveyor / WhoEyes.play("default")
		2:
			$ConveyorOverlays / WhoConveyor.play("default")
			$ConveyorOverlays / WhoConveyor / WhoEyes.play("bon_eyes")
		3:
			$ConveyorOverlays / WhoConveyor.play("chica")
			$ConveyorOverlays / WhoConveyor / WhoEyes.play("chica_eyes")
		4:
			$ConveyorOverlays / WhoConveyor.play("foxy")
			$ConveyorOverlays / WhoConveyor / WhoEyes.play("fox_eyes")
	conveyorWho = conveyorIn
	$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D7.play()
	if how == 0:
		$ConveyorOverlays / WhoConveyor / AnimationPlayer.play("Enter")
		SoundHandle(1)
	else:
		$ConveyorOverlays / WhoConveyor / AnimationPlayer.play("Enter_Rush")
		SoundHandle(3)
	$ConveyorOverlays / WhoConveyor.visible = true
	$ConveyorOverlays / WhoConveyor / WhoEyes.visible = true

func EnemyEndConveyor():
	
	match (conveyorWho):
		1:
			MoveFred()
		2:
			MoveBon()
		3:
			MoveChic()
		4:
			MoveFox()
	$ConveyorOverlays / WhoConveyor.visible = false
	$ConveyorOverlays / WhoConveyor / WhoEyes.rotation_degrees = 0

func jumpscare( var character):
	if not gameStates.over:
		$Center / JumpscareSprite.z_index = 1
		match (character):
			1:
				
				$Center / JumpscareSprite.play("default")
			2:
				
				$Center / JumpscareSprite.play("bon")
			3:
				
				$Center / JumpscareSprite.play("chic")
			4:
				
				$Center / JumpscareSprite.play("foxLeft")
				scareSide = 1
			5:
				
				$Center / JumpscareSprite.play("FBFront")
			6:
				
				$Center / JumpscareSprite.play("fredHeadFront")
			7:
				
				$Center / JumpscareSprite.play("fredHeadLeft")
				scareSide = 1
			8:
				
				$Center / JumpscareSprite.play("fredLeft")
				scareSide = 1
			9:
				
				$Center / JumpscareSprite.play("bonLeft")
				scareSide = 1
			10:
				
				$Center / JumpscareSprite.play("chicLeft")
				scareSide = 1
			11:
				
				$Center / JumpscareSprite.play("FBFront2")
			12:
				
				$Center / JumpscareSprite.scale = Vector2(2, 2)
				$Center / JumpscareSprite.play("fan")
				SceneControl.failReason = 12
			13:
				
				$Center / JumpscareSprite.scale = Vector2(2, 2)
				$Center / JumpscareSprite.play("pistol")
				$OfficeOverlays / PistolSprite.visible = false
				scareSide = 2
				SceneControl.failReason = 13
			14:
				
				$Center / JumpscareSprite.scale = Vector2(2, 2)
				$Center / JumpscareSprite.z_index = - 1
				$Center / JumpscareSprite.play("convLever")
				$OfficeOverlays / LeverSprite.play("scare")
				$ConveyorOverlays / WhoConveyor / WhoEyes.visible = false
				scareSide = 1
				SceneControl.failReason = 14
			15:
				
				$Center / JumpscareSprite.scale = Vector2(2, 2)
				
				$Center / JumpscareSprite.play("light")
				$DeskSprite.play("buttonGone")
				scareSide = 2
				SceneControl.failReason = 15
		
		$Center / JumpscareSprite.visible = true
		$Center.lockView = true
		$Center / UserInterface / CameraSystem.DropCamCheck()
		SceneControl.whoScare = character
		
		$Center / UserInterface / HitRight.visible = false
		$Center / UserInterface / HitLeft.visible = false
		$Center / UserInterface / UIText.visible = false
		$Center / UserInterface / CameraSystem / Area2D.visible = false
		
		if $Center.pistol.active:
			$Center / UserInterface / FoamPistol.visible = false
			$Center / UserInterface / UIText / FireTxt.visible = false
			$Center.pistol.lock = true
		
		$Center / UserInterface / Shocker.visible = false
		$Center / UserInterface / Shocker.modulate.a = 0.0
		
		
		if character == 4:
			$Center / JumpscareSprite / AnimationPlayer.play("Scare2")
		elif character == 14 or character == 15:
			$Center / JumpscareSprite / AnimationPlayer.play("ScareTools")
		else:
			if scareSide == 0 or scareSide == 2:
				$Center / JumpscareSprite / AnimationPlayer.play("Scare")
			else:
				$Center / JumpscareSprite / AnimationPlayer.play("Scare3")
		$Center / ControlInd / BackRect.visible = true
		
		
		if (character == 5 or character == 11):
			SoundController.PlayScare(3)
		elif (character == 6 or character == 7):
			SoundController.PlayScare(4)
		elif character == 12:
			SoundController.PlayScare(5)
		elif character == 13:
			SoundController.PlayScare(6)
		elif character == 14:
			SoundController.PlayScare(7)
		elif character == 15:
			SoundController.PlayScare(8)
		else:
			if scareSide == 0:
				SoundController.PlayScare(1)
			else:
				
				SoundController.PlayScare(1)
		
		if ($Center.position.x > 960 and scareSide == 1) or ($Center.position.x < 3180 and scareSide == 2):
			
			$Center.turning = false
			$Center.scareTurn = true
			$Center / TurnTween.stop_all()
		
		gameStates.over = true
		
		if not lightOn:
			$Center.powerLock = true
			_on_LightButton_pressed()
		
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		$Center / UserInterface / PauseMenu.ableAccess = false

func _on_ChopSprite_animation_finished():
	MoveFred()
	$Center / UserInterface / CameraSystem.lockCam = false
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChopSprite.visible = false
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChopSprite.play("default")
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / ChopSprite.stop()
	$OfficeOverlays / FredHead.visible = true
	if $Center / UserInterface / CameraSystem.currentCam == 10:
		$Center / UserInterface / CameraSystem / CamVis / BlockCam.visible = true
		$Center / UserInterface / CameraSystem / CamVis / static1 / AudioStreamPlayer.play()
		timeCamBlock = 0
		UpdateCamVis()
	print("Chop done")

func _on_LeverSprite_animation_finished():
	if $OfficeOverlays / LeverSprite.animation != "scare":
		if not conveyorOn:
			$OfficeOverlays / LeverSprite.play("on")
			coolDown = false
			conveyorAnimState = 2
		else:
			if $OfficeOverlays / LeverSprite.animation == "flipOff":
				print("cooldown start")
				$OfficeOverlays / LeverCool / AnimationPlayer.play("CoolDown")
				conveyorAnimState = 0

func _on_Subtitles_dialog_finished():
	TutorialLock(false)

func _on_ChicDesk_animation_finished():
	if $ChicDesk.animation == "attack":
		$ChicDesk.play("twitch")

func OrderLightDone():
	$OfficeOverlays / OrderLight / AnimationPlayer.play("lightIdle")

func LevelCompleteEnd():
	if tempCurrentLevel <= 3:
		if tempCurrentLevel == 1:
			$OfficeOverlays / OrderLight / AnimationPlayer.play("LightExplode")
			$OfficeOverlays / OrderLight.play("explode")
			$OfficeOverlays / OrderLight.visible = false
			$OfficeOverlays / OrderLightBase.play("broken")
			$OfficeOverlays / BulbExplode.play("default")
			$OfficeOverlays / BulbExplode.visible = true
			if not SceneControl.performant:
				$OfficeOverlays / BulbSmoke.visible = true
				$OfficeOverlays / BulbSmoke.emitting = true
			else:
				$OfficeOverlays / BulbSmokeCPU.visible = true
				$OfficeOverlays / BulbSmokeCPU.emitting = true
			timeEventBuffer = 0
			$OfficeOverlays / OrderSprite / AudioStreamPlayer2D3.play()
			$OfficeOverlays / OrderSprite / AudioStreamPlayer2D4.play()
		elif tempCurrentLevel == 2:
			$Center / AudioStreamPlayer4.play()
			timeEventBuffer = 0
		else:
			UpdateOrderState(0)
			$OfficeOverlays / OrderLight / AnimationPlayer.play("RESET")
			$OfficeOverlays / OrderLight.play("default")
			SceneControl.dialRepeat = false
			gameStates.tutorialStep += 1
			$Center / UserInterface / DialogueSystem / Walkie / AnimationPlayer.play("Enter")
			$Center / UserInterface / DialogueSystem / DialogueBox / Subtitles.SetDialText(gameStates.tutorialStep)
			TutorialLock(true)
		$OfficeOverlays / OrderSprite / orderLight.stop()
	else:
		if tempCurrentLevel == 3:
			
			pass
		elif tempCurrentLevel == 4:
			SceneTransition.NextScene("res://Scenes/Escape.tscn", self)
		else:
			if tempCurrentLevel == 11:
				SceneTransition.NextScene("res://Scenes/TheEnd.tscn", self)
			else:
				SceneTransition.NextScene("res://Scenes/Reward.tscn", self)
	tempCurrentLevel = SceneControl.currentLevel

func TutorialLock( var lock):
	if lock:
		$Center / UserInterface / UIText / LevelTxt.modulate = Color(1, 1, 1, 1)
		$Center / UserInterface / UIText / LevelTxt2.modulate = Color(1, 1, 1, 1)
		$Center / UserInterface / UIText / LevelTxt.text = "Manager's\nMeeting"
		$Center / UserInterface / UIText / LevelTxt2.text = ""
		
		$Center / UserInterface / UIText / PowerTxt.visible = false
		$Center / UserInterface / UIText.visible = true
		$Center / UserInterface / CameraSystem.visible = false
		$RoomInterface / ToolButtons.visible = false
		$OfficePowerOvers / LightButtonSprite.visible = true
		$OfficePowerOvers / LightButtonSprite.play("light2")
		$Center / UserInterface / HitRight.visible = false
		$Center / UserInterface / HitLeft.visible = false
		$Center / UserInterface / DialogueSystem / Walkie / AnimationPlayer.play("Enter")
	else:
		print(gameStates.tutorialStep)
		$Center / UserInterface / DialogueSystem.visible = false
		$Center / UserInterface / HitRight.visible = true
		$Center / UserInterface / HitLeft.visible = true
		$RoomInterface.DisableInterface(false)
		if gameStates.tutorialStep == 1:
			
			$RoomInterface.EnableLightBox(true)
		elif gameStates.tutorialStep == 3:
			
			$RoomInterface.EnableRepairEnter(true)
		elif gameStates.tutorialStep == 5:
			$RoomInterface.EnableHallEnter(true)
			
			print("END OF CORE LEVELS")
		else:
			
			$Center / UserInterface / CameraSystem.visible = true
			$RoomInterface / ToolButtons.visible = true
			$OfficePowerOvers / LightButtonSprite.visible = false
			$Center / UserInterface / UIText / LevelTxt2.visible = true
			$Center / UserInterface / UIText / PowerTxt.visible = true
			$Center / UserInterface / UIText.visible = true
			orderStates.step[1] = 0
			gameStates.over = false
			gameStates.win = false
			timeLevel.current = timeLevel.prep
			SceneControl.dialRepeat = true
			$RoomInterface.EnableConveyor()
			UpdateOrderState(2)
			$OfficeOverlays / OrderSprite.play("1")
			$RoomInterface / ToolButtons / ConveyorButton.visible = true
			$RoomInterface / ToolButtons / LightButton.visible = true
			if gameStates.tutorialStep == 2:
				ResetLevel(2)

func FinishedCooldown():
	$OfficeOverlays / LeverCool / AnimationPlayer.play("RESET")
	$OfficeOverlays / LeverCool / AudioStreamPlayer2D.stop()
	coolDown = false

func _on_CameraSystem_enable_interface():
	if timeLight == - 1:
			$RoomInterface.EnableLightButton()
	if lightOn:
		$RoomInterface.EnableFood()
		if orderStates.step != [orderStates.maxStep, 2]:
			$RoomInterface.EnableConveyor()
		$RoomInterface.EnablePistol()
	$RoomInterface / SecretButtons.visible = true

func SoundHandle( var which):
	match (which):
		1:
			
			$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D2.play(conveyorAudioPos)
		2:
			
			$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D2.stop()
			$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D5.stop()
			$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D4.play()
		3:
			
			$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D5.play(conveyorAudioPos)
		4:
			
			conveyorAudioPos = $ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D5.get_playback_position()
			$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D5.stop()
		5:
			
			conveyorAudioPos = $ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D2.get_playback_position()
			$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D2.stop()

func ResetLevel( var resetType):
	if resetType == 1:
		
		if conveyorWho > 0:
			HideConvEnemy()
			SoundHandle(2)
			SoundHandle(4)
			$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D2.stop()
		$BonOffice / AnimationPlayer.play("RESET")
		$ChicDesk / AnimationPlayer.play("RESET")
		
		if $Center / UserInterface / CameraSystem.door_5:
			$Center / UserInterface / CameraSystem._on_Door5Button_pressed()
		if $Center / UserInterface / CameraSystem.door_6:
			$Center / UserInterface / CameraSystem._on_Door6Button_pressed()
		if $Center / UserInterface / CameraSystem.door_7:
			$Center / UserInterface / CameraSystem._on_Door7Button_pressed()
		if $Center / UserInterface / CameraSystem.fan.state == 1 or $Center / UserInterface / CameraSystem.fan.state == 2:
			$Center / UserInterface / CameraSystem.fan.state = 2
			$Center / UserInterface / CameraSystem.UpdateFanState()
		if $Center / UserInterface / CameraSystem.serviceLight:
			$Center / UserInterface / CameraSystem._on_ServiceButton_pressed()
		$Center.SetDefaults()
		$Center.ResetPower()
		print("Level reset")
	elif resetType == 2:
		
		print("Resetting character states")
		bon.x = 0
		bon.y = 0
		camPos.bon = [0, 0]
		bon.loop = 3
		bon.loopPath = 3
		bon.pathLast = 2
		bon.side = 0
		bon.window = false
		$BonOffice / AnimationPlayer.play("RESET")
		chic.x = 0
		chic.y = 0
		camPos.chic = [0, 0]
		chic.loop = 3
		chic.loopPath = 0
		chic.pathLast = 1
		chic.firePos = false
		$Center.powerStr = 1
		$ConveyorOverlays / ConveyorBack.play("default")
		gameStates.tutorial = false
		UpdateCamVis()
		LevelSetup()
		$Center / UserInterface / CameraSystem.UpdateKitState()
		if $Center / UserInterface / CameraSystem.currentCam == 10:
			$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / VentButton.visible = true
		$Center.timeAmbience = 0
		$Center.whichAmbience = 0
		print("Enemies cleared")

func _on_FbBlock_animation_finished():
	if $Center / UserInterface / CameraSystem / CamVis / FbBlock.animation == "crawlIn":
		$Center / UserInterface / CameraSystem / CamVis / FbBlock.play("default")

func FbGlareFrame():
	$OfficePowerOvers / FbPowerGlare.frame = rand_range(0, 5)

func _on_JumpscareSprite_animation_finished():
	if $Center / JumpscareSprite.animation == "basket":
		SceneTransition.NextScene("res://Scenes/Reward.tscn", self)
	else:
		if get_tree().change_scene("res://Scenes/GameOver.tscn") != OK:
			print("Scene load fail")

func _on_CameraSystem_check_chop():
	if $Center / UserInterface / CameraSystem / CamVis / BlockCam.visible:
		timeCamBlock = 1

func _on_randOrder1_pressed():
	$Center / UserInterface / CameraSystem / CamVis / CamRandButtons / randOrder1.visible = false
	ConfirmRandOrder()

func _on_randOrder2_pressed():
	$Center / UserInterface / CameraSystem / CamVis / CamRandButtons / randOrder2.visible = false
	ConfirmRandOrder()

func _on_randOrder3_pressed():
	$Center / UserInterface / CameraSystem / CamVis / CamRandButtons / randOrder3.visible = false
	ConfirmRandOrder()

func _on_randOrder4_pressed():
	$Center / UserInterface / CameraSystem / CamVis / CamRandButtons / randOrder4.visible = false
	ConfirmRandOrder()

func _on_randOrder5_pressed():
	$Center / UserInterface / CameraSystem / CamVis / CamRandButtons / randOrder5.visible = false
	ConfirmRandOrder()

func _on_randOrder6_pressed():
	$Center / UserInterface / CameraSystem / CamVis / CamRandButtons / randOrder6.visible = false
	ConfirmRandOrder()

func ConfirmRandOrder():
	$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / AudioStreamPlayer.play()
	
	$Center / UserInterface / CameraSystem.orderConfirm = false
	
	orderStates.confirm = false
	
	$Center / UserInterface / CameraSystem.ordersDelivered += 1
	orderStates.destination = $Center / UserInterface / CameraSystem.randomDestinations[$Center / UserInterface / CameraSystem.ordersDelivered]
	
	
	
	$Center / UserInterface / CameraSystem / CamVis / CamHunt.visible = false
	$Center / UserInterface / CameraSystem.SetHuntText(1)
	if $Center / UserInterface / CameraSystem / CamVis / OrderLab.visible:
		$Center / UserInterface / CameraSystem / CamVis / OrderLab.visible = false
	if not $Center / UserInterface / CameraSystem.camFroze:
		$Center / UserInterface / CameraSystem.doorBlock_Time = 0
		$Center / UserInterface / CameraSystem / CamVis / BlockCam3.visible = true
		if $Center / UserInterface / CameraSystem.camActive:
			$Center / UserInterface / CameraSystem / CamVis / static1 / AudioStreamPlayer.play()
	timeLevel.current = 0

func CheckHaunt( var who):
	if hauntSteps == 1:
		hauntSteps = 0
		hauntWho = who
		match (who):
			1:
				$Center / UserInterface / CameraSystem.fan.haunted = true
				$Center / UserInterface / Hallucinations / HalluSprite.play("default")
				$OfficeOverlays / WhisperHaunt1_2D.position.x = 2000
				$Center.SetHaunt(1)
				
			2:
				$Center.pistol.haunted = true
				$Center / UserInterface / Hallucinations / HalluSprite.play("pistol")
				$OfficeOverlays / WhisperHaunt1_2D.position.x = 3150
				$Center.SetHaunt(2)
				
			3:
				$Center / UserInterface / Hallucinations / HalluSprite.play("conv")
				$OfficeOverlays / WhisperHaunt1_2D.position.x = 540
				$Center.SetHaunt(3)
				
			4:
				$Center / UserInterface / Hallucinations / HalluSprite.play("light")
				$OfficeOverlays / WhisperHaunt1_2D.position.x = 3200
				$Center.SetHaunt(4)
				
			5:
				$Center / UserInterface / Hallucinations / HalluSprite.play("light")
				$OfficeOverlays / WhisperHaunt1_2D.position.x = 3200
				$Center.SetHaunt(4)
				
			6:
				$Center / UserInterface / CameraSystem.fan.haunted = true
				$Center / UserInterface / Hallucinations / HalluSprite.play("default")
				$OfficeOverlays / WhisperHaunt1_2D.position.x = 2000
				$Center.SetHaunt(1)
				
		$OfficeOverlays / WhisperHaunt1_2D.play()
		halluGlitchTime = 0
		$Center / UserInterface / Hallucinations / AnimationPlayer.play("Hallu")
		$Center / HalluBuffer / AnimationPlayer.play("GreyStart")
		$Center / UserInterface / Hallucinations / HauntSting.play()
		print("The haunting begins.")
	else:
		hauntSteps -= 1
	

func StopHaunt():
	match (hauntWho):
		1:
			MoveFred()
		2:
			if chic.firePos and chic.x == 11 and chic.y == 0:
				pass
			else:
				hauntPending = 3
			MoveChic()
			$ChicDesk / HauntChicTween.interpolate_property($ChicDesk, "position:y", $ChicDesk.position.y, 620, 0.8, Tween.TRANS_QUAD, Tween.EASE_IN)
			$ChicDesk / HauntChicTween.start()
		3:
			$ConveyorOverlays / WhoConveyor / AnimationPlayer.play("HauntEyes")
			$ConveyorOverlays / WhoConveyor / ConvHauntTween.interpolate_property($ConveyorOverlays / WhoConveyor, "position", $ConveyorOverlays / WhoConveyor.position, Vector2(745, 516), 0.5, Tween.TRANS_QUAD, Tween.EASE_IN)
			$ConveyorOverlays / WhoConveyor / ConvHauntTween.start()
			hauntPending = 4
		4:
			if bon.window and bon.x == 3 and bon.y == 1:
				pass
			else:
				hauntPending = 2
			MoveBon()
			$BonOffice / BonHauntTween.interpolate_property($BonOffice, "position", $BonOffice.position, Vector2(3890, 730), 0.8, Tween.TRANS_QUAD, Tween.EASE_IN)
			$BonOffice / BonHauntTween.start()
	hauntSteps = rand.randi_range(1, 3)
	hauntWho = 0
	$Center.SetHaunt(0)
	$Center / UserInterface / CameraSystem.fan.haunted = false
	$Center.pistol.haunted = false
	$OfficeOverlays / WhisperHaunt1_2D.stop()
	HalluDone()
	$Center / UserInterface / Shocker / ShockerHold / AudioStreamPlayer2.play()
	$Center / UserInterface / Shocker / ShockerHold / AimSprite / AnimationPlayer.play("RESET")
	$Center.shocker.shockHaunt = false
	$Center / HalluBuffer / AnimationPlayer.play("GreyStop")
	$Center / UserInterface / Shocker / ShockerButton / AudioStreamPlayer3.play()
	print("Haunting stopped")

func HalluDone():
	$Center / UserInterface / Hallucinations / AnimationPlayer.play("RESET")
	halluGlitchTime = - 1

func _on_CameraSystem_fan_scare():
	jumpscare(12)

func _on_Center_pistol_scare():
	jumpscare(13)

func UnJam():
	$ConveyorOverlays / ConveyorIdle / AnimationPlayer.play("LightFlicker")
	$Center / UserInterface / CameraSystem.conveyorJam = false
	timeFb = 0
	fb.jam = false
	conveyorWho = 0
	if $Center / UserInterface / CameraSystem.currentCam == 5:
		$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / Door5Button.visible = true
	if $Center / UserInterface / CameraSystem.currentCam == 6 and not $Center / UserInterface / CameraSystem.toolDisconnect.door6:
		$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / Door6Button.visible = true
	elif $Center / UserInterface / CameraSystem.currentCam == 7 and not $Center / UserInterface / CameraSystem.toolDisconnect.door7:
		$Center / UserInterface / CameraSystem / CamVis / CamToolButtons / Door7Button.visible = true
	$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D.play()
	$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D4.play()
	$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D8.play()
	$ConveyorOverlays / ConveyorIdle / AudioStreamPlayer2D9.stop()
	UpdateLabels()
	$Center / UserInterface / UIText / LevelTxt.modulate = Color(1, 1, 1, 0.5)
	$Center / UserInterface / UIText / LevelTxt2.modulate = Color(1, 1, 1, 0.5)

func _on_CameraSystem_refresh_tb( var isAttach):
	if isAttach:
		timeFbAttach = 0
		fb.attach = false
		timeFb = 0
		$Center / UserInterface / CameraSystem / CamVis / BlockCamFb / AnimationPlayer.play("blockOut")
		$MiniStatic / AudioStreamPlayer2D2.stop()
		$Center / UserInterface / CameraSystem / CamVis / FbBlock / AnimationPlayer.play("FadeOut")
		print("Threadbear detatched")
		$Center / UserInterface / CameraSystem / CamVis / CamRec.rect_position.x = - 865
		$Center / UserInterface / CameraSystem / CamVis / CamDot.visible = true
		$Center / UserInterface / CameraSystem / CamVis / CamRec.text = "REC"
		$Center / UserInterface / CameraSystem / CamVis / CamRec.modulate = Color(1, 1, 1, 0.69)
	else:
		fb.y = 1
		timeFb = 0
		print("Threadbear blocked Backstage")

func StartAttachTb():
	$Center / UserInterface / CameraSystem / CamVis / FbBlock / AnimationPlayer.play("FadeIn")
	fb.attach = true
	timeFbAttach = 1
	timeFbCamBuff = - 1
	fbGlitch_Time = 0
	$Center / UserInterface / CameraSystem / CamVis / FbBlock.position.x = rand_range( - 257, 257)
	$Center / UserInterface / CameraSystem / CamVis / FbBlock.play("crawlIn")
	$Center / UserInterface / CameraSystem / CamVis / BlockCamFb / AnimationPlayer.play("blockIn")
	$MiniStatic / AudioStreamPlayer2D2.play()
	$Center / UserInterface / CameraSystem / CamVis / FbBlock / AudioStreamPlayer.play()
	if $Center / UserInterface / CameraSystem.currentCam != 9:
		$Center / UserInterface / CameraSystem._on_camSwitch9_pressed()
	$Center / UserInterface / CameraSystem / CamVis / CamButtons.visible = false
	$Center / UserInterface / CameraSystem.camTbActive = true
	$Center / UserInterface / CameraSystem.camTbIncoming = false
	$Center / UserInterface / CameraSystem / CamVis / CamOverlays / FbCams / AudioStreamPlayer3.stop()
	$Center / UserInterface / CameraSystem / CamVis / CamRec.text = "CONNECTION ERROR"
	$Center / UserInterface / CameraSystem / CamVis / CamRec.rect_position.x = - 917
	$Center / UserInterface / CameraSystem / CamVis / CamDot.visible = false
	$Center / UserInterface / CameraSystem / CamVis / CamRec.modulate = Color(1, 0, 0, 0.69)
	fb.attachWait = false

func UpdateLabels():
	if not fb.jam:
		
		
		
		
		match (orderStates.step[1]):
			0:
				$Center / UserInterface / UIText / LevelTxt.text = "PREPARING"
			1:
				$Center / UserInterface / UIText / LevelTxt.text = "SENDING"
			2:
				$Center / UserInterface / UIText / LevelTxt.text = "DELIVERED"
		$Center / UserInterface / UIText / LevelTxt.text += "\nORDER " + str(orderStates.step[0] + 1)
		if SceneControl.currentLevel < 5:
			
			if SceneControl.currentLevel == 4:
				$Center / UserInterface / UIText / LevelTxt2.text = "FINAL COURSE"
			else:
				$Center / UserInterface / UIText / LevelTxt2.text = "COURSE " + str(SceneControl.currentLevel)
		else:
			if challengeIndex == 0:
				
				$Center / UserInterface / UIText / LevelTxt2.text = "CUSTOM"
			else:
				
				$Center / UserInterface / UIText / LevelTxt2.text = "CHALLENGE " + str(challengeIndex)
	else:
		
		$Center / UserInterface / UIText / LevelTxt.text = "CONVEYOR\nJAMMED"
		$Center / UserInterface / UIText / LevelTxt2.text = ""

func _on_Center_haunted_shock():
	StopHaunt()

func _on_PistolButton_pressed():
	if not $Center.shocker.active:
		$OfficeOverlays / PistolSprite.visible = false

func _on_CameraSystem_hide_shocker(isHide):
	if lightOn:
		if isHide:
			$Center / UserInterface / Shocker.visible = false
		else:
			$Center / UserInterface / Shocker.visible = true

func _on_OfficeOverlays_pumpkin_on():
	$OfficePowerOvers / PumpkinLight / AnimationPlayer.play("PumpkinFlicker")

func _on_OfficeOverlays_tree_on():
	$OfficePowerOvers / Tree.visible = true
