extends Node2D

var tempTime = 0
var inPos = false
var screwStates = {"s1": 0, "s2": 0, "s3": 0, "s4": 0, "s5": 0, "s6": 0, "s7": 0, "s8": 0, "s9": 0}
var screwsNeeded = true
var screwPicked = false
var rustyOutAmt = 0
var screwPlaceAmt = 0
var allRustyRemoved = false

var redirectOn = false
var mouseInRedirect = false

var bonState = 0
var bonWaiting = false

var bonTime = 0
var redirectTime = 0
var scareStart = false

var mouseRel = 0.0
var mouseRefY = - 1.0
var mouseClickDist = 0.0
var newMouseClick = false
var inArea = false
var turnBye = false
var mouseInUp = false
var mouseInDown = false

func _ready():
	SceneControl.inCutscene = 1
	$Center / ScrewButton.visible = false
	$Center / ScrewBox.visible = false
	$Center / ScrewHold.visible = false
	
	if ((get_global_mouse_position().y - $Center.position.y) <= - 377):
		mouseInUp = true
		$Center / TurnUp / AnimationPlayer.play("FadeTurn")
	elif ((get_global_mouse_position().y - $Center.position.y) >= 377):
		mouseInDown = true
		$Center / TurnDown / AnimationPlayer.play("FadeTurn")
	
	if not SceneControl.firstTurn:
		$Center / SkipLab.visible = false
	if not SceneControl.firstDirect:
		$TipBox.visible = false

func _process(delta):
	\
\
\
\
\
\
\
	"\n	if Input.is_action_pressed(\"ui_up\"):\n		$Center.position.y -= delta * 400\n		$Center.position.y = clamp($Center.position.y, 640, 1200)\n	elif Input.is_action_pressed(\"ui_down\"):\n		$Center.position.y += delta * 400\n		$Center.position.y = clamp($Center.position.y, 640, 1200)\n	"
	
	if $RedirectButton.get_global_rect().has_point(get_global_mouse_position()):
		if not mouseInRedirect:
			mouseInRedirect = true
	else:
		if mouseInRedirect:
			mouseInRedirect = false
			if redirectOn:
				StopRedirectButton()
	
	
	if bonState == 1:
		if bonTime >= 4 and screwsNeeded:
			if not redirectOn:
				bonState = 20
				print("Bonnie ATTACK")
				SceneControl.whoScare = 2
				SceneControl.failReason = 10
				$Conveyor_Dark / AnimationPlayer.play("ScareFlicker")
			else:
				bonState = 2
				bonTime = 0
				redirectTime = 0
				$Conveyor_Dark / AnimationPlayer.play("FlickerEnemy")
				$BonConveyor.play("peekOut")
				bonWaiting = false
				$AudioStreamPlayer2D3.play()
				print("Bonnie blocked 1.")
		else:
			bonTime += delta
		
		if redirectOn and bonWaiting:
			if redirectTime >= 1:
				bonTime = 4
			else:
				redirectTime += delta
	
	
	if bonState == 3:
		if bonTime >= 3:
			if not redirectOn:
				bonState = 20
				print("Bonnie ATTACK")
				SceneControl.whoScare = 2
				SceneControl.failReason = 10
				$Conveyor_Dark / AnimationPlayer.play("ScareFlicker")
			else:
				bonState = 4
				bonTime = 0
				redirectTime = 0
				$Conveyor_Dark / AnimationPlayer.play("FlickerEnemy")
				$BonConveyor.play("peekSideOut")
				bonWaiting = false
				$AudioStreamPlayer2D3.volume_db = - 6
				$AudioStreamPlayer2D3.play()
				print("Bonnie blocked 2.")
		else:
			bonTime += delta
		
		if redirectOn and bonWaiting:
			if redirectTime >= 1:
				bonTime = 3
			else:
				redirectTime += delta
	
	
	if bonState == 5:
		if bonTime >= 2:
			if not redirectOn:
				bonState = 20
				print("Bonnie ATTACK")
				SceneControl.whoScare = 2
				SceneControl.failReason = 10
				$Conveyor_Dark / AnimationPlayer.play("ScareFlicker")
			else:
				bonState = 6
				bonTime = 0
				redirectTime = 0
				$Conveyor_Dark / AnimationPlayer.play("FlickerEnemy2")
				$BonConveyor.play("peekFarOut")
				bonWaiting = false
				$AudioStreamPlayer2D4.play()
				print("Bonnie blocked 3.")
		else:
			bonTime += delta
		
		if redirectOn and bonWaiting:
			if redirectTime >= 1:
				bonTime = 2
			else:
				redirectTime += delta
	
	if screwPicked:
		$Center / ScrewHold.position = Vector2(get_viewport().get_mouse_position().x - 960, get_viewport().get_mouse_position().y - 540)
	
	if mouseInUp and ((get_global_mouse_position().y - $Center.position.y) >= - 325):
		mouseInUp = false
		if $MouseRefRect.rect_position.y > 640:
			$Center / TurnUp / AnimationPlayer.play_backwards("FadeTurn")
	
	if mouseInDown and ((get_global_mouse_position().y - $Center.position.y) <= 325):
		mouseInDown = false
		if $MouseRefRect.rect_position.y < 1400:
			$Center / TurnDown / AnimationPlayer.play_backwards("FadeTurn")
	
	if not mouseInUp and ((get_global_mouse_position().y - $Center.position.y) < - 325):
		_on_UpArea2D_mouse_entered()
	
	if not mouseInDown and ((get_global_mouse_position().y - $Center.position.y) > 325):
		_on_DownArea2D_mouse_entered()

func _physics_process(delta):
	if mouseClickDist > 0:
		pass
	
	if not scareStart:
		$Center.position.y = lerp($Center.position.y, $MouseRefRect.rect_position.y, delta * 4)
	else:
		$Center.position.y = lerp($Center.position.y, 770, delta * 4)
	
	\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
	"\n	if Input.is_action_just_pressed(\"ui_up\"):\n		if $MouseRefRect.rect_position.y == 1080:\n			$MouseRefRect.rect_position.y = 640\n		elif $MouseRefRect.rect_position.y == 1400:\n			$MouseRefRect.rect_position.y = 1080\n		if !turnBye:\n			#$Center/SkipLab/AnimationPlayer.play(\"bye\")\n			turnBye = true\n	\n	if Input.is_action_just_pressed(\"ui_down\"):\n		if $MouseRefRect.rect_position.y == 640:\n			$MouseRefRect.rect_position.y = 1080\n		elif $MouseRefRect.rect_position.y == 1080:\n			$MouseRefRect.rect_position.y = 1400\n		if !turnBye:\n			#$Center/SkipLab/AnimationPlayer.play(\"bye\")\n			turnBye = true\n	"
	\
\
\
\
\
\
\
\
\
\
\
	"\n	if Input.is_action_pressed(\"ui_mouse_right\"):\n		$MouseRefRect.rect_position.y = clamp(get_global_mouse_position().y, 640, 1400)\n		if !newMouseClick:\n			newMouseClick = true\n		#$Center.position.y = clamp(-sign($Center.position.y - get_global_mouse_position().y) * abs(get_global_mouse_position().y - $Center.position.y) + 1080, 640, 1400)\n		#$Center.position.y = clamp(lerp($Center.position.y, $MouseRefRect.rect_position.y, delta * 1), 640, 1400)\n	\n	if Input.is_action_just_released(\"ui_mouse_right\"):\n		if newMouseClick:\n			newMouseClick = false\n	"
	\
\
\
\
\
\
\
\
\
	"\n	mouseRel = clamp((abs($Center.position.y - get_global_mouse_position().y) - 8), 0, 1080) * 3\n	if mouseRefY == -1:\n		mouseRefY = get_global_mouse_position().y\n		print(mouseRefY)\n		print(mouseRel)\n	$Center.position.y += ((delta * mouseRel) * -sign($Center.position.y - get_global_mouse_position().y))\n	#$Center.position.y = clamp($Center.position.y, 540, 1620)\n	$Center.position.y = clamp($Center.position.y, 640, 1400)\n	"

func _input(event):
	if event.is_action_pressed("ui_mouse_right") and screwPicked:
		screwPicked = false
		$Center / ScrewHold.position = Vector2(851, 0)
		$Center / ScrewHold.scale = Vector2(1, 1)
		$ScrewButtons / AudioStreamPlayer4.play()
		print("Dropped screw")
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _on_ScrewButton_pressed():
	if screwsNeeded and not screwPicked:
		screwPicked = true
		$Center / ScrewHold.scale = Vector2(0.5, 0.5)
		$ScrewButtons / AudioStreamPlayer3.play()
		print("New screw picked up.")

func _on_S1Button_pressed():
	if screwPicked and screwStates.s1 == 0:
		screwStates.s1 = 1
		$ScrewSprites / screw1_new.visible = true
		ScrewPlace()
		print("Screw 1 placed.")

func _on_S2Button_pressed():
	if screwPicked and screwStates.s2 == 0:
		screwStates.s2 = 1
		$ScrewSprites / screw2_new.visible = true
		ScrewPlace()
		print("Screw 2 placed.")

func _on_S3Button_pressed():
	if screwPicked and screwStates.s3 == 0:
		screwStates.s3 = 1
		$ScrewSprites / screw3_new.visible = true
		ScrewPlace()
		print("Screw 3 placed.")

func _on_S4Button_pressed():
	if screwPicked and screwStates.s4 == 0:
		screwStates.s4 = 1
		$ScrewSprites / screw4_new.visible = true
		ScrewPlace()
		print("Screw 4 placed.")

func _on_S5Button_pressed():
	if screwPicked:
		
		if screwStates.s5 == 0:
			print("Rusty screw here, beat it.")
		elif screwStates.s5 == 1:
			screwStates.s5 = 2
			$ScrewSprites / screw5_new.visible = true
			ScrewPlace()
			print("Screw 5 placed.")
	else:
		if screwStates.s5 == 0:
			screwStates.s5 = 1
			$ScrewSprites / screw5.visible = false
			print("Screw 5 (rusty) removed.")
			ScrewRemove()

func _on_S6Button_pressed():
	if screwPicked:
		
		if screwStates.s6 == 0:
			print("Rusty screw here, beat it.")
		elif screwStates.s6 == 1:
			screwStates.s6 = 2
			$ScrewSprites / screw6_new.visible = true
			ScrewPlace()
			print("Screw 6 placed.")
	else:
		if screwStates.s6 == 0:
			screwStates.s6 = 1
			$ScrewSprites / screw6.visible = false
			print("Screw 6 (rusty) removed.")
			ScrewRemove()

func _on_S7Button_pressed():
	if screwPicked:
		
		if screwStates.s7 == 0:
			print("Rusty screw here, beat it.")
		elif screwStates.s7 == 1:
			screwStates.s7 = 2
			$ScrewSprites / screw7_new.visible = true
			ScrewPlace()
			print("Screw 7 placed.")
	else:
		if screwStates.s7 == 0:
			screwStates.s7 = 1
			$ScrewSprites / screw7.visible = false
			print("Screw 7 (rusty) removed.")
			ScrewRemove()

func _on_S8Button_pressed():
	if screwPicked:
		
		if screwStates.s8 == 0:
			print("Rusty screw here, beat it.")
		elif screwStates.s8 == 1:
			screwStates.s8 = 2
			$ScrewSprites / screw8_new.visible = true
			ScrewPlace()
			print("Screw 8 placed.")
	else:
		if screwStates.s8 == 0:
			screwStates.s8 = 1
			$ScrewSprites / screw8.visible = false
			print("Screw 8 (rusty) removed.")
			ScrewRemove()

func _on_S9Button_pressed():
	if screwPicked:
		
		if screwStates.s9 == 0:
			print("Rusty screw here, beat it.")
		elif screwStates.s9 == 1:
			screwStates.s9 = 2
			$ScrewSprites / screw9_new.visible = true
			ScrewPlace()
			print("Screw 9 placed.")
	else:
		if screwStates.s9 == 0:
			screwStates.s9 = 1
			$ScrewSprites / screw9.visible = false
			print("Screw 9 (rusty) removed.")
			ScrewRemove()

func CheckFinished():
	
	var amtFinished = 0
	for i in screwStates:
		if screwStates[i] > 0:
			amtFinished += screwStates[i]
	if rustyOutAmt >= 5 and not allRustyRemoved:
		allRustyRemoved = true
		$Center / ScrewButton.visible = true
		$Center / ScrewBox.visible = true
		$Center / ScrewHold.visible = true
		$Center / ScrewRusto.visible = false
		$Center / ScrewLab.text = "Screws Replaced\n" + str(screwPlaceAmt) + "/9"
		print("All rusty screws removed. Starting next section")
	if rustyOutAmt >= 4 and bonState == 0:
		
		bonState = 1
		$Conveyor_Dark / AnimationPlayer.play("FlickerEnemy")
		$BonConveyor.position = Vector2(1164, 1087)
		$BonConveyor.play("peekIn")
		$BonConveyor.visible = true
		bonWaiting = true
		$AudioStreamPlayer2D.play()
	if screwPlaceAmt >= 3 and bonState == 2:
		
		bonState = 3
		$Conveyor_Dark / AnimationPlayer.play("FlickerEnemy")
		$BonConveyor.position = Vector2(1032, 1127)
		$BonConveyor.play("peekSideIn")
		$BonConveyor.visible = true
		bonWaiting = true
		$AudioStreamPlayer2D.volume_db = - 6
		$AudioStreamPlayer2D.play()
	if screwPlaceAmt >= 7 and bonState == 4:
		
		bonState = 5
		$Conveyor_Dark / AnimationPlayer.play("FlickerEnemy")
		
		$BonConveyor.position = Vector2(960, 1123)
		$BonConveyor.play("peekFarIn")
		bonWaiting = true
		$AudioStreamPlayer2D2.play()
	if amtFinished >= screwStates.size() + 5 and bonState != 20:
		screwsNeeded = false
		SceneControl.inCutscene = 0
		SaveData.WriteData()
		$Center / ScrewButton.visible = false
		$Center / ScrewBox.visible = false
		$Center / ScrewHold.visible = false
		$RedirectButton.visible = false
		print("Minigame complete!")
		$Center / WinTxt / AnimationPlayer.play("WinFade")
		if not SceneControl.performant:
			$Center / ScrewParticles.visible = true
			$Center / ScrewParticles.emitting = true
		else:
			$Center / ScrewParticlesCPU.visible = true
			$Center / ScrewParticlesCPU.emitting = true
		$RedirectButton.disabled = true
		$Center / WinTxt / AudioStreamPlayer.play()
	if rustyOutAmt < 5:
		$Center / ScrewLab.text = "Screws Collected\n" + str(rustyOutAmt) + "/5"
	if rustyOutAmt == 1:
		$Center / SkipLab / AnimationPlayer.play("bye")
		if SceneControl.firstDirect:
			$TipBox / AnimationPlayer.play("TipOff")
			SceneControl.firstDirect = false

func _on_RedirectButton_button_up():
	if redirectOn:
		StopRedirectButton()

func _on_RedirectButton_pressed():
	if not redirectOn:
		redirectOn = true
		$MouseRefRect.rect_position.y = 1080
		$RedirectButton / AudioStreamPlayer.play()
		if not $RedirectSprite.animation == "default":
			var lastFrame = $RedirectSprite.frame
			$RedirectSprite.play("start")
			if lastFrame < 8:
				$RedirectSprite.frame = 8 - lastFrame
		else:
			$RedirectSprite.play("start")
	if SceneControl.firstDirect:
		$TipBox / AnimationPlayer.play("TipOff")
		SceneControl.firstDirect = false
	print("Redirect on")

func StopRedirectButton():
	redirectOn = false
	var lastFrame = $RedirectSprite.frame
	$RedirectSprite.play("end")
	if lastFrame < 8:
		$RedirectSprite.frame = 8 - lastFrame
	$RedirectButton / AudioStreamPlayer2.play()
	print("Redirect let go")

func _on_DropButton_pressed():
	if screwPicked:
		screwPicked = false
		print("Dropped screw")

func _on_UpArea2D_mouse_entered():
	if not mouseInUp:
		print("Yuppo")
		if $MouseRefRect.rect_position.y == 1080:
			$MouseRefRect.rect_position.y = 640
			$Center / TurnUp / AnimationPlayer.play("FadeTurn")
		elif $MouseRefRect.rect_position.y == 1400:
			$MouseRefRect.rect_position.y = 1080
			$Center / TurnDown.modulate.a = 0.3
			$Center / TurnDown / AnimationPlayer.play_backwards("FadeTurn")
			$Center / TurnUp / AnimationPlayer.play("FadeTurn")
		mouseInUp = true
	if SceneControl.firstTurn:
		SceneControl.firstTurn = false

func _on_DownArea2D_mouse_entered():
	if not mouseInDown:
		if $MouseRefRect.rect_position.y == 640:
			$MouseRefRect.rect_position.y = 1080
			$Center / TurnUp / AnimationPlayer.play_backwards("FadeTurn")
			$Center / TurnDown / AnimationPlayer.play("FadeTurn")
		elif $MouseRefRect.rect_position.y == 1080:
			$MouseRefRect.rect_position.y = 1400
			$Center / TurnDown / AnimationPlayer.play("FadeTurn")
		mouseInDown = true
	if SceneControl.firstTurn:
		SceneControl.firstTurn = false

func ScrewRemove():
	rustyOutAmt += 1
	$ScrewButtons / AudioStreamPlayer2.pitch_scale = rand_range(0.99, 1.1)
	$ScrewButtons / AudioStreamPlayer2.play()
	CheckFinished()

func ScrewPlace():
	screwPicked = false
	$Center / ScrewHold.position = Vector2(851, 0)
	$Center / ScrewHold.scale = Vector2(1, 1)
	screwPlaceAmt += 1
	$Center / ScrewLab.text = "Screws Placed\n" + str(screwPlaceAmt) + "/9"
	$ScrewButtons / AudioStreamPlayer.pitch_scale = rand_range(0.99, 1.1)
	$ScrewButtons / AudioStreamPlayer.play()
	CheckFinished()

func _on_MoveUp_pressed():
	
	if $MouseRefRect.rect_position.y == 1080:
			$MouseRefRect.rect_position.y = 640
	elif $MouseRefRect.rect_position.y == 1400:
		$MouseRefRect.rect_position.y = 1080

func _on_MoveDown_pressed():
	
	if $MouseRefRect.rect_position.y == 640:
			$MouseRefRect.rect_position.y = 1080
	elif $MouseRefRect.rect_position.y == 1080:
		$MouseRefRect.rect_position.y = 1400

func BonSetEnter():
	if not bonWaiting:
		bonWaiting = true
	else:
		$BonConveyor.visible = false
		bonWaiting = false

func BeginScare():
	$ScarySprite.play("Scare")
	$BonConveyor.visible = false
	scareStart = true
	$Center / TurnUp.visible = false
	$Center / TurnDown.visible = false
	$TipBox.visible = false
	$Center / ScrewLab.visible = false
	$Center / ScrewBox.visible = false
	$Center / ScrewHold.visible = false
	$Center / Camera2D / AnimationPlayer.play("ScareRot")
	SoundController.PlayScare(1)

func ScareDone():
	
	
	pass

func WinDone():
	SceneTransition.NextScene("res://Scenes/Main.tscn", self)

func _on_ScarySprite_animation_finished():
	if $ScarySprite.animation == "Scare":
		if get_tree().change_scene("res://Scenes/GameOver.tscn") != OK:
			print("Scene load fail")
