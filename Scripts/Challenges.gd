extends Control



var currentChallenge = 5
var aiTime = 0
var whichAI = 0; var amtAI = 0
var prevCustomAct = [0, 0, 0, 0, 0]
var fromChallenge = false

var itemSelected = false
var itemTargetY = 0

var basketTime = - 1
var rand = RandomNumberGenerator.new()


func _ready():
	rand.randomize()
	$CenterContainer / VBoxContainer / ChalButton.mouse_filter = MOUSE_FILTER_STOP
	$CenterContainer / VBoxContainer / ChalButton2.mouse_filter = MOUSE_FILTER_STOP
	$CenterContainer / VBoxContainer / ChalButton3.mouse_filter = MOUSE_FILTER_STOP
	$CenterContainer / VBoxContainer / ChalButton4.mouse_filter = MOUSE_FILTER_STOP
	$CenterContainer / VBoxContainer / ChalButton5.mouse_filter = MOUSE_FILTER_STOP
	$CenterContainer / VBoxContainer / ChalButton6.mouse_filter = MOUSE_FILTER_STOP
	$CenterContainer / VBoxContainer / ChalButton7.mouse_filter = MOUSE_FILTER_STOP
	
	if SceneControl.musicOn:
		$ChallengeMusic.play()
	
	if SceneControl.currentLevel >= 5:
		fromChallenge = true
		print("From challenge")
	$star.visible = false
	
	match (SceneControl.currentLevel):
		5:
			_on_ChalButton_pressed()
		8:
			_on_ChalButton2_pressed()
		7:
			_on_ChalButton3_pressed()
		9:
			_on_ChalButton4_pressed()
		6:
			_on_ChalButton5_pressed()
		10:
			_on_ChalButton6_pressed()
		11:
			_on_ChalButton7_pressed()
		_:
			_on_ChalButton_pressed()
	$BiteySpritey.play("biting")
	
	
	if SceneControl.beatChallenge1:
		$GridContainer / Reward1.visible = true
	else:
		$GridContainer / Reward1.visible = false
	if SceneControl.beatChallenge2:
		$GridContainer / Reward2.visible = true
		basketTime = 0
	else:
		$GridContainer / Reward2.visible = false
	if SceneControl.beatChallenge3:
		$GridContainer / Reward3.visible = true
	else:
		$GridContainer / Reward3.visible = false
	if SceneControl.beatChallenge4:
		$GridContainer / Reward4.visible = true
	else:
		$GridContainer / Reward4.visible = false
	if SceneControl.beatChallenge5:
		$GridContainer / Reward5.visible = true
	else:
		$GridContainer / Reward5.visible = false
	if SceneControl.beatChallenge6:
		$GridContainer / Reward6.visible = true
	else:
		$GridContainer / Reward6.visible = false
	if SceneControl.beatChallenge20:
		$Reward20.visible = true
	else:
		$Reward20.visible = false
	if SceneControl.beatChallenge0:
		$Reward0.visible = true
	else:
		$Reward0.visible = false

func _process(delta):
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and currentChallenge == 5:
		if $EnemyDisplay / AIButtons / FredAIButtonR.get_global_rect().has_point(get_global_mouse_position()):
			whichAI = 0
			amtAI = 1
		elif $EnemyDisplay / AIButtons / FredAIButtonL.get_global_rect().has_point(get_global_mouse_position()):
			whichAI = 0
			amtAI = - 1
		elif $EnemyDisplay / AIButtons / BonAIButtonR.get_global_rect().has_point(get_global_mouse_position()):
			whichAI = 1
			amtAI = 1
		elif $EnemyDisplay / AIButtons / BonAIButtonL.get_global_rect().has_point(get_global_mouse_position()):
			whichAI = 1
			amtAI = - 1
		elif $EnemyDisplay / AIButtons / ChicAIButtonR.get_global_rect().has_point(get_global_mouse_position()):
			whichAI = 2
			amtAI = 1
		elif $EnemyDisplay / AIButtons / ChicAIButtonL.get_global_rect().has_point(get_global_mouse_position()):
			whichAI = 2
			amtAI = - 1
		elif $EnemyDisplay / AIButtons / FoxAIButtonR.get_global_rect().has_point(get_global_mouse_position()):
			whichAI = 3
			amtAI = 1
		elif $EnemyDisplay / AIButtons / FoxAIButtonL.get_global_rect().has_point(get_global_mouse_position()):
			whichAI = 3
			amtAI = - 1
		elif $EnemyDisplay / AIButtons / TbAIButtonR.get_global_rect().has_point(get_global_mouse_position()):
			whichAI = 4
			amtAI = 1
		elif $EnemyDisplay / AIButtons / TbAIButtonL.get_global_rect().has_point(get_global_mouse_position()):
			whichAI = 4
			amtAI = - 1
		else:
			whichAI = 0
			amtAI = 0
		if aiTime >= 0 and amtAI != 0:
			if aiTime >= 0.1:
				whichAIButton(whichAI, amtAI)
			else:
				aiTime += delta
	
	
	if itemTargetY > 0:
		$BiteySpritey.position.y = lerp($BiteySpritey.position.y, itemTargetY, delta * 6)
		$BiteySpritey.look_at(Vector2(960, itemTargetY))
		if abs($BiteySpritey.position.y - itemTargetY) <= 1:
			itemTargetY = 0
	
	if basketTime >= 0:
		if basketTime >= 0.04:
			$GridContainer / Reward2 / BasketSprite.frame = rand.randi_range(0, 4)
			basketTime = 0
		else:
			basketTime += delta

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _on_ReadyButton_pressed():
	
	SceneControl.currentLevel = currentChallenge
	SceneTransition.NextScene("res://Scenes/Main.tscn", self)
	HideChallengeButtons()
	SceneControl.dialRepeat = false

func _on_ExitButton_pressed():
	SceneControl.customActivity = [0, 0, 0, 0, 0]
	SceneTransition.NextScene("res://Scenes/Menu.tscn", self)
	HideChallengeButtons()

func HideChallengeButtons():
	$ReadyButton.mouse_filter = MOUSE_FILTER_IGNORE
	$ExitButton.mouse_filter = MOUSE_FILTER_IGNORE

func _on_ChalButton_pressed():
	$CustomLabel.text = "Challenges - Custom"
	$DescLab.text = "Custom: Enter activity levels for the animatronics."
	$EnemyDisplay / AIButtons.visible = true
	currentChallenge = 5
	if not fromChallenge:
		prevCustomAct = SceneControl.customActivity
		SceneControl.customActivity = [0, 0, 0, 0, 0]
	else:
		fromChallenge = false
	for i in range(0, 5):
		UpdateActivity(i)
	itemTargetY = $CenterContainer / VBoxContainer / ChalButton.rect_position.y + 225
	if SceneControl.beatChallenge20:
		$star.position.x = 582
		$star.visible = true
	else:
		$star.visible = false

func _on_ChalButton2_pressed():
	$CustomLabel.text = "Challenges - Basket Hunt"
	$DescLab.text = "Basket Hunt: Find misplaced food baskets around the building."
	$EnemyDisplay / AIButtons.visible = false
	currentChallenge = 8
	if not fromChallenge:
		prevCustomAct = SceneControl.customActivity
		SceneControl.customActivity = [10, 10, 0, 0, 5]
	else:
		fromChallenge = false
	for i in range(0, 5):
		UpdateActivity(i)
	itemTargetY = $CenterContainer / VBoxContainer / ChalButton2.rect_position.y + 225
	if SceneControl.beatChallenge1:
		$star.position.x = 700
		$star.visible = true
	else:
		$star.visible = false

func _on_ChalButton3_pressed():
	$CustomLabel.text = "Challenges - Haunting Roulette"
	$DescLab.text = "Haunting Roulette: The animatronics may haunt your tools."
	$EnemyDisplay / AIButtons.visible = false
	currentChallenge = 7
	if not fromChallenge:
		prevCustomAct = SceneControl.customActivity
		SceneControl.customActivity = [10, 5, 10, 5, 0]
	else:
		fromChallenge = false
	for i in range(0, 5):
		UpdateActivity(i)
	itemTargetY = $CenterContainer / VBoxContainer / ChalButton3.rect_position.y + 225
	if SceneControl.beatChallenge2:
		$star.position.x = 838
		$star.visible = true
	else:
		$star.visible = false

func _on_ChalButton4_pressed():
	$CustomLabel.text = "Challenges - Cold Kitchen"
	$DescLab.text = "Cold Kitchen: The cameras keep freezing. It's very cold."
	$EnemyDisplay / AIButtons.visible = false
	currentChallenge = 9
	if not fromChallenge:
		prevCustomAct = SceneControl.customActivity
		SceneControl.customActivity = [10, 10, 5, 0, 5]
	else:
		fromChallenge = false
	for i in range(0, 5):
		UpdateActivity(i)
	itemTargetY = $CenterContainer / VBoxContainer / ChalButton4.rect_position.y + 225
	if SceneControl.beatChallenge3:
		$star.position.x = 704
		$star.visible = true
	else:
		$star.visible = false

func _on_ChalButton5_pressed():
	$CustomLabel.text = "Challenges - Out of Service"
	$DescLab.text = "Out of Service: The conveyor lever is permanently broken."
	$EnemyDisplay / AIButtons.visible = false
	currentChallenge = 6
	if not fromChallenge:
		prevCustomAct = SceneControl.customActivity
		SceneControl.customActivity = [5, 10, 10, 5, 0]
	else:
		fromChallenge = false
	for i in range(0, 5):
		UpdateActivity(i)
	itemTargetY = $CenterContainer / VBoxContainer / ChalButton5.rect_position.y + 225
	if SceneControl.beatChallenge4:
		$star.position.x = 750
		$star.visible = true
	else:
		$star.visible = false

func _on_ChalButton6_pressed():
	$CustomLabel.text = "Challenges - Lunch Rush"
	$DescLab.text = "Lunch Rush: Orders are piling up! Keep up with the demand."
	$EnemyDisplay / AIButtons.visible = false
	currentChallenge = 10
	if not fromChallenge:
		prevCustomAct = SceneControl.customActivity
		SceneControl.customActivity = [10, 10, 10, 10, 10]
	else:
		fromChallenge = false
	for i in range(0, 5):
		UpdateActivity(i)
	itemTargetY = $CenterContainer / VBoxContainer / ChalButton6.rect_position.y + 225
	if SceneControl.beatChallenge5:
		$star.position.x = 673
		$star.visible = true
	else:
		$star.visible = false

func _on_ChalButton7_pressed():
	$CustomLabel.text = "Challenges - Full Course"
	$DescLab.text = "Full Course: Freddy and Friends are serving a heaping helping of fun!"
	
	
	
	
	
	
	$EnemyDisplay / AIButtons.visible = false
	currentChallenge = 11
	if not fromChallenge:
		prevCustomAct = SceneControl.customActivity
		SceneControl.customActivity = [20, 20, 20, 20, 20]
	else:
		fromChallenge = false
	for i in range(0, 5):
		UpdateActivity(i)
	itemTargetY = $CenterContainer / VBoxContainer / ChalButton7.rect_position.y + 225
	if SceneControl.beatChallenge6:
		$star.position.x = 700
		$star.visible = true
	else:
		$star.visible = false

func UpdateActivity( var who):
	$EnemyDisplay / AIFred.text = str(SceneControl.customActivity[0])
	$EnemyDisplay / AIBon.text = str(SceneControl.customActivity[1])
	$EnemyDisplay / AIChic.text = str(SceneControl.customActivity[2])
	$EnemyDisplay / AIFox.text = str(SceneControl.customActivity[3])
	$EnemyDisplay / AITB.text = str(SceneControl.customActivity[4])
	
	
	
	
	
	
	match (who):
		0:
			if prevCustomAct[who] == 0 and SceneControl.customActivity[who] > 0:
				$EnemyDisplay / FredIcon / AnimationPlayer.play_backwards("GoGrey")
				$EnemyDisplay / FredIcon.play()
			elif prevCustomAct[who] > 0 and SceneControl.customActivity[who] == 0:
				$EnemyDisplay / FredIcon / AnimationPlayer.play("GoGrey")
				$EnemyDisplay / FredIcon.stop()
		1:
			if prevCustomAct[who] == 0 and SceneControl.customActivity[who] > 0:
				$EnemyDisplay / BonIcon / AnimationPlayer.play_backwards("GoGrey")
				$EnemyDisplay / BonIcon.play()
			elif prevCustomAct[who] > 0 and SceneControl.customActivity[who] == 0:
				$EnemyDisplay / BonIcon / AnimationPlayer.play("GoGrey")
				$EnemyDisplay / BonIcon.stop()
		2:
			if prevCustomAct[who] == 0 and SceneControl.customActivity[who] > 0:
				$EnemyDisplay / ChicIcon / AnimationPlayer.play_backwards("GoGrey")
				$EnemyDisplay / ChicIcon.play()
			elif prevCustomAct[who] > 0 and SceneControl.customActivity[who] == 0:
				$EnemyDisplay / ChicIcon / AnimationPlayer.play("GoGrey")
				$EnemyDisplay / ChicIcon.stop()
		3:
			if prevCustomAct[who] == 0 and SceneControl.customActivity[who] > 0:
				$EnemyDisplay / FoxIcon / AnimationPlayer.play_backwards("GoGrey")
				$EnemyDisplay / FoxIcon.play()
			elif prevCustomAct[who] > 0 and SceneControl.customActivity[who] == 0:
				$EnemyDisplay / FoxIcon / AnimationPlayer.play("GoGrey")
				$EnemyDisplay / FoxIcon.stop()
		4:
			if prevCustomAct[who] == 0 and SceneControl.customActivity[who] > 0:
				$EnemyDisplay / TbIcon / AnimationPlayer.play_backwards("GoGrey")
				$EnemyDisplay / TbIcon.play()
			elif prevCustomAct[who] > 0 and SceneControl.customActivity[who] == 0:
				$EnemyDisplay / TbIcon / AnimationPlayer.play("GoGrey")
				$EnemyDisplay / TbIcon.stop()

func _on_ChalButton_mouse_entered():
	$CenterContainer / VBoxContainer / ChalButton.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ChalButton_mouse_exited():
	$CenterContainer / VBoxContainer / ChalButton.modulate.a = 1

func _on_ChalButton2_mouse_entered():
	$CenterContainer / VBoxContainer / ChalButton2.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ChalButton2_mouse_exited():
	$CenterContainer / VBoxContainer / ChalButton2.modulate.a = 1

func _on_ChalButton3_mouse_entered():
	$CenterContainer / VBoxContainer / ChalButton3.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ChalButton3_mouse_exited():
	$CenterContainer / VBoxContainer / ChalButton3.modulate.a = 1

func _on_ChalButton4_mouse_entered():
	$CenterContainer / VBoxContainer / ChalButton4.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ChalButton4_mouse_exited():
	$CenterContainer / VBoxContainer / ChalButton4.modulate.a = 1

func _on_ChalButton5_mouse_entered():
	$CenterContainer / VBoxContainer / ChalButton5.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ChalButton5_mouse_exited():
	$CenterContainer / VBoxContainer / ChalButton5.modulate.a = 1

func _on_ChalButton6_mouse_entered():
	$CenterContainer / VBoxContainer / ChalButton6.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ChalButton6_mouse_exited():
	$CenterContainer / VBoxContainer / ChalButton6.modulate.a = 1

func _on_ChalButton7_mouse_entered():
	$CenterContainer / VBoxContainer / ChalButton7.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ChalButton7_mouse_exited():
	$CenterContainer / VBoxContainer / ChalButton7.modulate.a = 1

func _on_ExitButton_mouse_entered():
	$ExitButton.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ExitButton_mouse_exited():
	$ExitButton.modulate.a = 1

func _on_ReadyButton_mouse_entered():
	$ReadyButton.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ReadyButton_mouse_exited():
	$ReadyButton.modulate.a = 1


func _on_FredAIButtonR_pressed():
	whichAIButton(0, 1)

func _on_FredAIButtonL_pressed():
	whichAIButton(0, - 1)

func _on_BonAIButtonR_pressed():
	whichAIButton(1, 1)

func _on_BonAIButtonL_pressed():
	whichAIButton(1, - 1)

func _on_ChicAIButtonR_pressed():
	whichAIButton(2, 1)

func _on_ChicAIButtonL_pressed():
	whichAIButton(2, - 1)

func _on_FoxAIButtonR_pressed():
	whichAIButton(3, 1)

func _on_FoxAIButtonL_pressed():
	whichAIButton(3, - 1)

func _on_TbAIButtonR_pressed():
	whichAIButton(4, 1)

func _on_TbAIButtonL_pressed():
	whichAIButton(4, - 1)

func whichAIButton( var who,  var amt):
	if currentChallenge == 5:
		prevCustomAct[who] = SceneControl.customActivity[who]
		whichAI = who
		amtAI = amt
		if not (SceneControl.customActivity[whichAI] == 20 and amt > 0) and not (SceneControl.customActivity[whichAI] == 0 and amt < 0):
			SceneControl.customActivity[whichAI] += amtAI
			UpdateActivity(whichAI)
			aiTime = 0
			SoundController.PlayQuickClick()

func _on_BiteButton_pressed():
	$BiteySpritey / AudioStreamPlayer.play()

func _on_bootButton_pressed():
	if not $GridContainer / Reward1 / bootSound.playing:
		$GridContainer / Reward1 / bootSound.play()

func _on_snowButton_pressed():
	if not $GridContainer / Reward3 / snowSound.playing:
		$GridContainer / Reward3 / snowSound.play()

func _on_clockButton_pressed():
	if not $GridContainer / Reward5 / clockSound.playing:
		$GridContainer / Reward5 / clockSound.play()

func _on_paperButton_pressed():
	if not $Reward0 / paperSound.playing:
		$Reward0 / paperSound.play()

func _on_basketButton_pressed():
	if not $GridContainer / Reward2 / basketSound.playing:
		$GridContainer / Reward2 / basketSound.play()

func _on_fbButton_pressed():
	if not $Reward20 / fbSound.playing:
		$Reward20 / fbSound.play()

func _on_puppets1Button_pressed():
	if not $GridContainer / Reward4 / puppets1Sound.playing:
		$GridContainer / Reward4 / puppets1Sound.play()

func _on_puppets2Button_pressed():
	if not $GridContainer / Reward6 / puppets2Sound.playing:
		$GridContainer / Reward6 / puppets2Sound.play()
