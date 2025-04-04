extends Control

onready var labText1 = $CenterContainer / VBoxContainer / BeginButton / BeginLabel.text
onready var labText2 = "Continue " + str(SceneControl.currentLevel)
onready var labText3 = $OptionsButton / BeginLabel.text
onready var biteStartX = $BiteySpritey.position.x

var itemHover = false
var itemCurrent = 1
var itemTargetY = 0.0
var mouseNear = false
var doneButtonLoad = false
var doneButtonLoadTime = - 1

var trophyTime = 0
var trophyActive = 0
var glintTime = - 1
var glintActTime = - 1
var deleteTime = - 1
var finaleGlitch = 0
var whichFinaleText = 0

var sceneChanging = false
var volumeChecked = false

var rand = RandomNumberGenerator.new()
var secret = 0
var finaleAlpha = 1.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	if SceneControl.currentLevel > 0 or (SceneControl.currentLevel == 0 and SceneControl.devMode):
		$CenterContainer / VBoxContainer / ContinueButton.visible = true
	else:
		$CenterContainer / VBoxContainer / ContinueButton.visible = false
	
	if SceneControl.gameComplete:
		$Trophies.visible = true
		$Trophies / Trophy1.visible = true
		$Trophies / Trophy1Button.visible = true
		$CenterContainer / VBoxContainer / ExtrasButton.visible = true
		$CenterContainer / VBoxContainer / FinaleButton.visible = true
	else:
		$Trophies / Trophy1.visible = false
		$Trophies / Trophy1Button.visible = false
		$CenterContainer / VBoxContainer / ExtrasButton.visible = false
		$CenterContainer / VBoxContainer / FinaleButton.visible = false
	if SceneControl.finaleComplete:
		$Trophies / Trophy2.visible = true
		$Trophies / Trophy2Button.visible = true
		$CenterContainer / VBoxContainer / ChallengeButton.visible = true
	else:
		$Trophies / Trophy2.visible = false
		$Trophies / Trophy2Button.visible = false
		$CenterContainer / VBoxContainer / ChallengeButton.visible = false
	if SceneControl.beatChallenge1 and SceneControl.beatChallenge2 and SceneControl.beatChallenge3 and SceneControl.beatChallenge4 and SceneControl.beatChallenge5 and SceneControl.beatChallenge6:
		$Trophies / Trophy3.visible = true
		$Trophies / Trophy3Button.visible = true
	else:
		$Trophies / Trophy3.visible = false
		$Trophies / Trophy3Button.visible = false
	
	$selArrow.position.y = $CenterContainer / VBoxContainer / BeginButton / BeginLabel.rect_global_position.y + 58
	if SceneControl.inCutscene == 0:
		$CenterContainer / VBoxContainer / ContinueButton / BeginLabel.text = "Continue " + str(SceneControl.currentLevel)
	elif SceneControl.inCutscene == 1:
		$CenterContainer / VBoxContainer / ContinueButton / BeginLabel.text = "Continue 2B"
	else:
		$CenterContainer / VBoxContainer / ContinueButton / BeginLabel.text = "Continue 3B"
	if SceneControl.devMode:
		$Version.text += " (DEV MODE ON)"
	if not SceneControl.fullScreen:
		$Options / CenterContainer / VBoxContainer / HBoxContainer2 / CheckBox.pressed = false
	if SceneControl.tutorialReplay:
		$Options / CenterContainer / VBoxContainer / HBoxContainer3 / CheckBoxBorder.pressed = true
	if not SceneControl.musicOn:
		$Options / CenterContainer / VBoxContainer / HBoxContainer4 / CheckBoxMusic.pressed = false
	else:
		$MenuMusic.play()
	
	if not SceneControl.gameComplete:
		match (SceneControl.currentLevel):
			0:
				$MenuBack.play("default")
			1:
				$MenuBack.play("2")
			2:
				$MenuBack.play("3")
			3:
				$MenuBack.play("4")
	else:
		if not SceneControl.finaleComplete:
			$MenuBack.play("5")
		else:
			$MenuBack.play("6")
	
	
	if SceneControl.gameComplete:
		$SodaStuff / SodaWinTxt.text = str(SceneControl.sodaWon)
		$SodaStuff.visible = true
	else:
		$SodaStuff.visible = false
	
	
	if SceneControl.customVolume < 0:
		$Options / CenterContainer / VBoxContainer / HBoxContainer / VolumeSlider.value = 100 - ((SceneControl.customVolume / - 80) / 0.01)
		if $Options / CenterContainer / VBoxContainer / HBoxContainer / VolumeSlider.value > 0:
			$Options / CenterContainer / VBoxContainer / HBoxContainer / Version2.text = "VOLUME (" + str($Options / CenterContainer / VBoxContainer / HBoxContainer / VolumeSlider.value) + "%)"
		else:
			$Options / CenterContainer / VBoxContainer / HBoxContainer / Version2.text = "VOLUME (MUTED)"
	volumeChecked = true
	
	rand.randomize()
	secret = rand.randi_range(0, 3000)
	print(secret)
	
	if SceneControl.currentLevel >= 2 or SceneControl.gameComplete:
		if secret == 85:
			$SuitOvr.visible = true
			$SuitOvr / AnimationPlayer.play("SuitFade")
		elif secret == 2345:
			$SecretSprite.play("default")
			$SecretSprite / AnimationPlayer.play("SecretOut")
			$SecretSprite / AudioStreamPlayer.play()
		elif secret == 2346:
			$SecretSprite.play("fredFig")
			$SecretSprite / AnimationPlayer.play("SecretOut")
			$SecretSprite / AudioStreamPlayer.play()
		elif secret == 2347:
			$SecretSprite.play("figures")
			$SecretSprite / AnimationPlayer.play("SecretOut")
			$SecretSprite / AudioStreamPlayer.play()
	
	doneButtonLoadTime = 0

func _process(delta):
	if not itemHover:
		if get_global_mouse_position().distance_to($BiteySpritey.position + Vector2(130, 0)) < 150 and not mouseNear:
			mouseNear = true
			$BiteySpritey.flip_h = true
		elif get_global_mouse_position().distance_to($BiteySpritey.position + Vector2(130, 0)) >= 150 and mouseNear:
			mouseNear = false
			$BiteySpritey.flip_h = false
			$BiteySpritey.rotation_degrees = 0
		if $BiteySpritey.position.x < biteStartX:
			$BiteySpritey.position.x = lerp($BiteySpritey.position.x, biteStartX, delta * 5)
	
	if not itemHover and mouseNear:
		$BiteySpritey.look_at(get_global_mouse_position())
	
	if itemTargetY > 0:
		$BiteySpritey.position.y = lerp($BiteySpritey.position.y, itemTargetY, delta * 5)
		$BiteySpritey.look_at(Vector2(960, itemTargetY))
		$BiteySpritey.rotation_degrees = $BiteySpritey.rotation_degrees - 180
		if abs($BiteySpritey.position.y - itemTargetY) <= 1:
			itemTargetY = 0
	
	$BiteySpritey2.position.y = $BiteySpritey.position.y
	
	if $Trophies / Trophy1.visible:
		trophyTime += delta
		$Trophies / Trophy1.rotation_degrees = sin(trophyTime * 1.8) * 8
	
	if $Trophies / Trophy2.visible:
		trophyTime += delta
		$Trophies / Trophy2.rotation_degrees = sin(trophyTime * 1.8) * 8
	
	if $Trophies / Trophy3.visible:
		trophyTime += delta
		$Trophies / Trophy3.rotation_degrees = sin(trophyTime * 1.8) * 8
	
	if deleteTime >= 0:
		if deleteTime >= 3:
			SceneControl.currentLevel = 0
			SceneControl.gameComplete = false
			SceneControl.finaleComplete = false
			SceneControl.inCutscene = 0
			SceneControl.prevLevel = 0
			SceneControl.dialRepeat = false
			SceneControl.sodaWon = 0
			SceneControl.friendFaded = false
			SceneControl.beatChallenge1 = false
			SceneControl.beatChallenge2 = false
			SceneControl.beatChallenge3 = false
			SceneControl.beatChallenge4 = false
			SceneControl.beatChallenge5 = false
			SceneControl.beatChallenge6 = false
			SceneControl.beatChallenge20 = false
			SceneControl.beatChallenge0 = false
			SaveData.WriteData()
			deleteTime = - 1
			
			print("Deletey time")
			$ResetData.visible = false
			HideButtons()
			SceneTransition.NextScene("res://Scenes/Warning.tscn", self)
		else:
			deleteTime += delta
			$ResetData.text = "Resetting data in " + str(int(ceil(3 - deleteTime))) + "..."
	
	if SceneControl.gameComplete and not SceneControl.finaleComplete:
		if finaleGlitch > 0.02:
			SetFinaleText()
			finaleGlitch = 0
		else:
			finaleGlitch += delta
	
	finaleAlpha = $CenterContainer / VBoxContainer / FinaleButton / BeginLabel.modulate.a
	
	if not doneButtonLoad:
		if doneButtonLoadTime > 0.01:
			$CenterContainer / VBoxContainer / BeginButton.mouse_filter = MOUSE_FILTER_STOP
			$CenterContainer / VBoxContainer / ContinueButton.mouse_filter = MOUSE_FILTER_STOP
			$CenterContainer / VBoxContainer / FinaleButton.mouse_filter = MOUSE_FILTER_STOP
			$CenterContainer / VBoxContainer / ExtrasButton.mouse_filter = MOUSE_FILTER_STOP
			$CenterContainer / VBoxContainer / ChallengeButton.mouse_filter = MOUSE_FILTER_STOP
			$OptionsButton.mouse_filter = MOUSE_FILTER_STOP
			doneButtonLoad = true
			doneButtonLoadTime = - 1
		else:
			doneButtonLoadTime += delta
	
	if glintTime >= 0 and glintActTime >= 0:
		if glintTime >= 0.1:
			CreateGlint()
			glintTime = 0
		else:
			glintTime += delta
	
	if glintActTime >= 0:
		if glintActTime >= 0.4:
			glintTime = - 1
			glintActTime = - 1
		else:
			glintActTime += delta
	
	if OS.window_fullscreen and not $Options / CenterContainer / VBoxContainer / HBoxContainer2 / CheckBox.pressed:
		$Options / CenterContainer / VBoxContainer / HBoxContainer2 / CheckBox.pressed = true
	elif not OS.window_fullscreen and $Options / CenterContainer / VBoxContainer / HBoxContainer2 / CheckBox.pressed:
		$Options / CenterContainer / VBoxContainer / HBoxContainer2 / CheckBox.pressed = false

func _on_BeginButton_pressed():
	if SceneControl.currentLevel >= 1:
		$NewConfirm.visible = true
	else:
		if not sceneChanging:
			$NewConfirm.visible = false
			SceneControl.currentLevel = 1
			SceneControl.prevLevel = SceneControl.currentLevel
			SaveData.WriteData()
			SceneTransition.NextScene("res://Scenes/Intro.tscn", self)
			SoundController.PlayClick()

func _on_ContinueButton_pressed():
	if not sceneChanging:
		if SceneControl.inCutscene == 0:
			SceneTransition.NextScene("res://Scenes/Main.tscn", self)
		elif SceneControl.inCutscene == 1:
			SceneTransition.NextScene("res://Scenes/ConveyorRepair.tscn", self)
		elif SceneControl.inCutscene == 2:
			SceneTransition.NextScene("res://Scenes/HallTravel.tscn", self)
		SoundController.PlayClick()
		HideButtons()
		sceneChanging = true

func _on_OptionsButton_pressed():
	if SceneControl.fullScreen:
		$Options / CenterContainer / VBoxContainer / HBoxContainer2 / CheckBox.pressed = true
	else:
		$Options / CenterContainer / VBoxContainer / HBoxContainer2 / CheckBox.pressed = false
	$Options.visible = true
	SoundController.PlayClick()

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("ui_mouse_left") and mouseNear and not $Options.visible:
		$BiteySpritey / AnimationPlayer.play("Attack2")
		if not $BiteySpritey / AudioStreamPlayer.playing:
			$BiteySpritey / AudioStreamPlayer.play()
	
	if Input.is_action_just_pressed("ui_del"):
		deleteTime = 0
		$ResetData / AudioStreamPlayer.play()
		print("Starting delete")
	
	if Input.is_action_just_released("ui_del"):
		deleteTime = - 1
		$ResetData.text = "Hold \"Delete\" to reset data"
		print("Stopping delete")

func _on_CheckBox_pressed():
	if OS.window_fullscreen:
		SceneControl.SetWindowSmall()
	else:
		SceneControl.SetWindowLarge()
	$Options / CenterContainer / VBoxContainer / HBoxContainer / VolumeSlider / AudioStreamPlayer.play()

func _on_CheckBoxBorder_pressed():
	SceneControl.tutorialReplay = not SceneControl.tutorialReplay

func _on_VolumeSlider_value_changed(value):
	if volumeChecked:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), ((100 - value) * 0.01) * - 80)
		SceneControl.customVolume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
		if value > 0:
			$Options / CenterContainer / VBoxContainer / HBoxContainer / Version2.text = "VOLUME (" + str(value) + "%)"
			$Options / CenterContainer / VBoxContainer / HBoxContainer / VolumeSlider / AudioStreamPlayer.play()
		else:
			$Options / CenterContainer / VBoxContainer / HBoxContainer / Version2.text = "VOLUME (MUTED)"

func _on_CheckBoxMusic_pressed():
	SceneControl.musicOn = not SceneControl.musicOn
	$MenuMusic.playing = not $MenuMusic.playing

func _on_BeginButton_mouse_entered():
	itemCurrent = 0
	ItemSelected()
	$CenterContainer / VBoxContainer / BeginButton / BeginLabel / AnimationPlayer.play("Selected")

func _on_BeginButton_mouse_exited():
	ItemDeselected()
	$CenterContainer / VBoxContainer / BeginButton / BeginLabel / AnimationPlayer.play("RESET")

func _on_ContinueButton_mouse_entered():
	itemCurrent = 1
	ItemSelected()
	$CenterContainer / VBoxContainer / ContinueButton / BeginLabel / AnimationPlayer.play("Selected")
	
func _on_ContinueButton_mouse_exited():
	ItemDeselected()
	$CenterContainer / VBoxContainer / ContinueButton / BeginLabel / AnimationPlayer.play("RESET")

func _on_OptionsButton_mouse_entered():
	$OptionsButton / BeginLabel / AnimationPlayer.play("Selected")
	SoundController.PlayHover()

func _on_OptionsButton_mouse_exited():
	ItemDeselected()
	$OptionsButton / BeginLabel / AnimationPlayer.play("RESET")

func _on_BackButton_pressed():
	$Options.visible = false
	$Options / BackButton / BackLabel.modulate.a = 1.0
	SaveData.WriteData()
	SoundController.PlayClick()

func ItemSelected():
	itemHover = true
	mouseNear = false
	$BiteySpritey.rotation_degrees = 0
	$BiteySpritey.play("biting")
	$BiteySpritey / AnimationPlayer.play("Attack")
	$BiteySpritey2.play("biting")
	$BiteySpritey2 / AnimationPlayer.play("Attack")
	$BiteySpritey.flip_h = false
	$CenterContainer / VBoxContainer / BeginButton / BeginLabel.text = labText1
	$OptionsButton / BeginLabel.text = labText3
	match (itemCurrent):
		0:
			itemTargetY = $CenterContainer / VBoxContainer / BeginButton / BeginLabel.rect_global_position.y + 58
		1:
			itemTargetY = $CenterContainer / VBoxContainer / ContinueButton / BeginLabel.rect_global_position.y + 58
		2:
			itemTargetY = $CenterContainer / VBoxContainer / FinaleButton / BeginLabel.rect_global_position.y + 58
		3:
			itemTargetY = $CenterContainer / VBoxContainer / ExtrasButton / BeginLabel.rect_global_position.y + 58
		4:
			itemTargetY = $CenterContainer / VBoxContainer / ChallengeButton / BeginLabel.rect_global_position.y + 58
	SoundController.PlayHover()

func ItemDeselected():
	itemHover = false
	$BiteySpritey.play("default")
	$BiteySpritey / AnimationPlayer.stop()
	$BiteySpritey2.play("default")
	$BiteySpritey2 / AnimationPlayer.play("RESET")

func _on_BackButton_mouse_entered():
	$Options / BackButton / BackLabel.modulate.a = 0.25
	SoundController.PlayHover()

func _on_BackButton_mouse_exited():
	$Options / BackButton / BackLabel.modulate.a = 1.0

func _on_TestSkipButton1_pressed():
	SceneControl.currentLevel = 2
	SceneControl.prevLevel = SceneControl.currentLevel
	labText2 = "Continue " + str(SceneControl.currentLevel)
	$CenterContainer / VBoxContainer / ContinueButton / BeginLabel.text = "Continue " + str(SceneControl.currentLevel)

func _on_TestSkipButton2_pressed():
	SceneControl.currentLevel = 3
	SceneControl.prevLevel = SceneControl.currentLevel
	labText2 = "Continue " + str(SceneControl.currentLevel)
	$CenterContainer / VBoxContainer / ContinueButton / BeginLabel.text = "Continue " + str(SceneControl.currentLevel)

func _on_TestSkipButton3_pressed():
	SceneControl.currentLevel = 1
	SceneControl.prevLevel = SceneControl.currentLevel
	labText2 = "Continue " + str(SceneControl.currentLevel)
	$CenterContainer / VBoxContainer / ContinueButton / BeginLabel.text = "Continue " + str(SceneControl.currentLevel)

func _on_YesButton_pressed():
	if not sceneChanging:
		$NewConfirm.visible = false
		SceneControl.currentLevel = 1
		SceneControl.prevLevel = SceneControl.currentLevel
		SceneControl.dialRepeat = false
		SaveData.WriteData()
		SceneTransition.NextScene("res://Scenes/Intro.tscn", self)
		HideButtons()
		sceneChanging = true

func _on_NoButton_pressed():
	$NewConfirm.visible = false

func HideButtons():
	$CenterContainer / VBoxContainer / BeginButton.mouse_filter = MOUSE_FILTER_IGNORE
	$CenterContainer / VBoxContainer / ContinueButton.mouse_filter = MOUSE_FILTER_IGNORE
	$CenterContainer / VBoxContainer / FinaleButton.mouse_filter = MOUSE_FILTER_IGNORE
	$CenterContainer / VBoxContainer / ExtrasButton.mouse_filter = MOUSE_FILTER_IGNORE
	$CenterContainer / VBoxContainer / ChallengeButton.mouse_filter = MOUSE_FILTER_IGNORE
	$OptionsButton.mouse_filter = MOUSE_FILTER_IGNORE

func _on_FinaleButton_pressed():
	if not sceneChanging:
		SceneControl.currentLevel = 4
		SceneTransition.NextScene("res://Scenes/Main.tscn", self)
		SoundController.PlayClick()
		HideButtons()
		sceneChanging = true

func _on_FinaleButton_mouse_entered():
	itemCurrent = 2
	ItemSelected()
	$CenterContainer / VBoxContainer / FinaleButton / BeginLabel / AnimationPlayer.play("Selected")

func _on_FinaleButton_mouse_exited():
	ItemDeselected()
	finaleAlpha = 1.0
	$CenterContainer / VBoxContainer / FinaleButton / BeginLabel / AnimationPlayer.play("RESET")

func _on_ExtrasButton_pressed():
	if not sceneChanging:
		SceneTransition.NextScene("res://Scenes/Extras.tscn", self)
		SoundController.PlayClick()
		HideButtons()
		sceneChanging = true

func _on_ExtrasButton_mouse_entered():
	itemCurrent = 3
	ItemSelected()
	$CenterContainer / VBoxContainer / ExtrasButton / BeginLabel / AnimationPlayer.play("Selected")

func _on_ExtrasButton_mouse_exited():
	ItemDeselected()
	$CenterContainer / VBoxContainer / ExtrasButton / BeginLabel / AnimationPlayer.play("RESET")

func _on_ChallengeButton_pressed():
	if not sceneChanging:
		SceneTransition.NextScene("res://Scenes/Challenges.tscn", self)
		SoundController.PlayClick()
		HideButtons()
		sceneChanging = true

func _on_ChallengeButton_mouse_entered():
	itemCurrent = 4
	ItemSelected()
	$CenterContainer / VBoxContainer / ChallengeButton / BeginLabel / AnimationPlayer.play("Selected")

func _on_ChallengeButton_mouse_exited():
	ItemDeselected()
	$CenterContainer / VBoxContainer / ChallengeButton / BeginLabel / AnimationPlayer.play("RESET")

func SetFinaleText():
	whichFinaleText = rand.randi_range(0, 250)
	match (whichFinaleText):
		2:
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.text = "Don't stare."
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.modulate = Color(1, 0.5, 0.5, finaleAlpha)
		3:
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.text = "You ready?"
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.modulate = Color(1, 1, 1, finaleAlpha)
		4:
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.text = "Let's face it."
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.modulate = Color(1, 1, 1, finaleAlpha)
		5:
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.text = "Bear this."
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.modulate = Color(1, 0.9, 0.6, finaleAlpha)
		6:
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.text = "One more bite."
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.modulate = Color(1, 0.7, 0.7, finaleAlpha)
		7:
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.text = "Experiment over."
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.modulate = Color(0.5, 0.7, 1, finaleAlpha)
		8:
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.text = "Left to rot again."
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.modulate = Color(0.5, 0.7, 1, finaleAlpha)
		9:
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.text = "Louie's awake."
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.modulate = Color(0.5, 0.7, 1, finaleAlpha)
		_:
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.text = "Final Course"
			$CenterContainer / VBoxContainer / FinaleButton / BeginLabel.modulate = Color(1, 1, 1, finaleAlpha)

func _on_Trophy1Button_pressed():
	trophyActive = 1
	CreateGlint()
	glintActTime = 0
	glintTime = 0
	$Trophies / TrophyGlint.play()

func _on_Trophy2Button_pressed():
	trophyActive = 2
	CreateGlint()
	glintActTime = 0
	glintTime = 0
	$Trophies / TrophyGlint.play()

func _on_Trophy3Button_pressed():
	trophyActive = 3
	CreateGlint()
	glintActTime = 0
	glintTime = 0
	$Trophies / TrophyGlint.play()

func CreateGlint():
	var glinty = preload("res://Scenes/TrophyGlint.tscn").instance()
	add_child(glinty)
	glinty.position.x = rand.randi_range( - 80, 80)
	glinty.position.y = rand.randi_range( - 60, 60)
	match (trophyActive):
		1:
			glinty.position.x += $Trophies / Trophy1.position.x
			glinty.position.y += $Trophies / Trophy1.position.y
		2:
			glinty.position.x += $Trophies / Trophy2.position.x
			glinty.position.y += $Trophies / Trophy2.position.y
		3:
			glinty.position.x += $Trophies / Trophy3.position.x
			glinty.position.y += $Trophies / Trophy3.position.y

func _on_SodaButton_pressed():
	if not $SodaStuff / SodaButton / AudioStreamPlayer.playing:
		$SodaStuff / SodaButton / AudioStreamPlayer.play()

func _on_SodaButton_mouse_entered():
	$SodaStuff / SodaWinLab.visible = true

func _on_SodaButton_mouse_exited():
	$SodaStuff / SodaWinLab.visible = false

func _on_VolumeSlider_mouse_entered():
	$Options / OptionDesc.text = "Volume: Game's master volume"

func _on_CheckBoxMusic_mouse_entered():
	$Options / OptionDesc.text = "Music: Plays on menus and win screens"

func _on_CheckBox_mouse_entered():
	$Options / OptionDesc.text = "Fullscreen: Maximizes game window"

func _on_CheckBoxBorder_mouse_entered():
	$Options / OptionDesc.text = "Tutorial replay: Tutorials will replay when restarting a level"

func _on_Trophy1Button_mouse_entered():
	$Trophies / TrophyName.text = "GAME COMPLETED"
	$Trophies / TrophyName.visible = true

func _on_Trophy2Button_mouse_entered():
	$Trophies / TrophyName.text = "FINAL COURSE COMPLETED"
	$Trophies / TrophyName.visible = true

func _on_Trophy3Button_mouse_entered():
	$Trophies / TrophyName.text = "CHALLENGES COMPLETED"
	$Trophies / TrophyName.visible = true

func _on_Trophy1Button_mouse_exited():
	$Trophies / TrophyName.visible = false

func _on_Trophy2Button_mouse_exited():
	$Trophies / TrophyName.visible = false

func _on_Trophy3Button_mouse_exited():
	$Trophies / TrophyName.visible = false
