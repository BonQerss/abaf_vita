extends Control

var currentChar = 0
var currentRoom = 0
var currentScare = 0
var currentPoster = 0
var currentDev = 0
var zoomState = 0
var seenFriend = false
var friendTextTime = - 1
var friendEyeTime = - 1
var scrollLock = false
var itemTargetY = 0

func _ready():
	$CharSection / ScrollCharacters.get_v_scrollbar().modulate = Color(0, 0, 0, 0)
	$CenterContainer / VBoxContainer / CharButton.mouse_filter = MOUSE_FILTER_STOP
	if not SceneControl.finaleComplete:
		$CenterContainer / VBoxContainer / DevButton.modulate.a = 0.25
		$CenterContainer / VBoxContainer / RoomButton.modulate.a = 0.25
		$CenterContainer / VBoxContainer / PosterButton.modulate.a = 0.25
	else:
		$CenterContainer / VBoxContainer / RoomButton.mouse_filter = MOUSE_FILTER_STOP
		$CenterContainer / VBoxContainer / PosterButton.mouse_filter = MOUSE_FILTER_STOP
		$CenterContainer / VBoxContainer / DevButton.mouse_filter = MOUSE_FILTER_STOP
	_on_CharButton_pressed()
	$BiteySpritey.play("biting")
	$ExtrasLabel / SodaStuff / SodaWinTxt.text = str(SceneControl.sodaWon)
	if SceneControl.musicOn:
		$ExtrasMusic.play()

func _process(delta):
	$CharSection / ScrollBit.position.y = 360 + $CharSection / ScrollCharacters.scroll_vertical / 2.28
	
	if not seenFriend and not SceneControl.friendFaded and currentChar == 4 and not SceneControl.finaleComplete:
		if ($CharSection / ScrollCharacters.scroll_vertical > 720):
			$CharsLabel.text = "Lewis"
			friendTextTime = 0
			seenFriend = true
			$CharSection / ScrollCharacters / Control / CharSprite / AnimationPlayer.play("NextChar")
	
	
	if friendTextTime >= 0:
		if friendTextTime >= 0.06:
			$CharsLabel.text = "Paper Friend"
			friendTextTime = - 1
		else:
			friendTextTime += delta
	
	if seenFriend and not SceneControl.friendFaded and $CharSection / ScrollCharacters.scroll_vertical < 420:
		$CharSection / ScrollCharacters / Control / CharSprite.play("friend3")
		SceneControl.friendFaded = true
		seenFriend = false
	
	if scrollLock:
		if $CharSection / ScrollCharacters.scroll_vertical > 0:
			$CharSection / ScrollCharacters.scroll_vertical = lerp($CharSection / ScrollCharacters.scroll_vertical, 0, delta * 6)
		else:
			$CharSection / ScrollCharacters.mouse_filter = MOUSE_FILTER_STOP
			$CharSection / ScrollCharacters.scroll_vertical_enabled = true
			scrollLock = false
	
	
	if itemTargetY > 0:
		$BiteySpritey.position.y = lerp($BiteySpritey.position.y, itemTargetY, delta * 6)
		$BiteySpritey.look_at(Vector2(960, itemTargetY))
		if abs($BiteySpritey.position.y - itemTargetY) <= 1:
			itemTargetY = 0

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("ui_mouse_right"):
		if zoomState == 2:
			$RoomSection / RoomSprite / AnimationPlayer.play("ZoomOut")
			$RoomSection / RoomClickLab.visible = false
			zoomState = 3
			$RoomSection / RoomClick / CamZoom2.play()

func SwitchChar():
	match (currentChar):
		0:
			$CharsLabel.text = "Talkshow Freddy"
			$CharSection / ScrollCharacters / Control / CharSprite.play("default")
			$CharSection / ScrollCharacters / Control / CharSprite.position.y = 680
			$NextButton.visible = true
			$PrevButton.visible = false
			$CharSection / ScrollCharacters.scroll_vertical = 0
		1:
			$CharsLabel.text = "Talkshow Bonnie"
			$CharSection / ScrollCharacters / Control / CharSprite.play("bon")
			$CharSection / ScrollCharacters / Control / CharSprite.position.y = 725
			$NextButton.visible = true
			$PrevButton.visible = true
			$CharSection / ScrollCharacters.scroll_vertical = 0
		2:
			$CharsLabel.text = "Talkshow Chica"
			$CharSection / ScrollCharacters / Control / CharSprite.play("chic")
			$CharSection / ScrollCharacters / Control / CharSprite.position.y = 654
			$NextButton.visible = true
			$PrevButton.visible = true
			$CharSection / ScrollCharacters.scroll_vertical = 0
		3:
			$CharsLabel.text = "Talkshow Foxy"
			$CharSection / ScrollCharacters / Control / CharSprite.play("fox")
			$CharSection / ScrollCharacters / Control / CharSprite.position.y = 660
			$PrevButton.visible = true
			$NextButton.visible = true
			$CharSection / ScrollCharacters.scroll_vertical = 0
		4:
			if SceneControl.finaleComplete:
				$CharsLabel.text = "Threadbear"
				$CharSection / ScrollCharacters / Control / CharSprite.play("tb")
				$CharSection / ScrollCharacters / Control / CharSprite.position.y = 680
				$CharSection / ScrollCharacters.scroll_vertical = 0
			else:
				$CharsLabel.text = "Paper Friend"
				if not SceneControl.friendFaded and not seenFriend:
					$CharSection / ScrollCharacters / Control / CharSprite.play("friend1")
					$CharSection / ScrollCharacters.scroll_vertical = 0
				else:
					if not seenFriend:
						$CharSection / ScrollCharacters / Control / CharSprite.play("friend3")
					else:
						$CharSection / ScrollCharacters / Control / CharSprite.play("friend2")
				$CharSection / ScrollCharacters / Control / CharSprite.position.y = 815
			$NextButton.visible = false
			$PrevButton.visible = true
	
	if SceneControl.finaleComplete or not (SceneControl.friendFaded and currentChar == 4):
		$CharSection / ScrollBack.visible = true
		$CharSection / ScrollBit.visible = true

func SwitchRoom():
	match (currentRoom):
		0:
			$CharsLabel.text = "Office - Left"
			$RoomSection / RoomSprite.play("default")
			$PrevButton.visible = false
			$NextButton.visible = true
		1:
			$CharsLabel.text = "Office - Front"
			$RoomSection / RoomSprite.play("front")
			$PrevButton.visible = true
			$NextButton.visible = true
		2:
			$CharsLabel.text = "Show Stage"
			$RoomSection / RoomSprite.play("1")
			$PrevButton.visible = true
			$NextButton.visible = true
		3:
			$CharsLabel.text = "Dining Area"
			$RoomSection / RoomSprite.play("2")
			$PrevButton.visible = true
			$NextButton.visible = true
		4:
			$CharsLabel.text = "Foxy's Lab"
			$RoomSection / RoomSprite.play("3")
			$PrevButton.visible = true
			$NextButton.visible = true
		5:
			$CharsLabel.text = "Center Hall"
			$RoomSection / RoomSprite.play("4")
			$PrevButton.visible = true
			$NextButton.visible = true
		6:
			$CharsLabel.text = "Kitchen"
			$RoomSection / RoomSprite.play("5")
			$PrevButton.visible = true
			$NextButton.visible = true
		7:
			$CharsLabel.text = "Party Room A"
			$RoomSection / RoomSprite.play("6")
			$PrevButton.visible = true
			$NextButton.visible = true
		8:
			$CharsLabel.text = "Party Room B"
			$RoomSection / RoomSprite.play("7")
			$PrevButton.visible = true
			$NextButton.visible = true
		9:
			$CharsLabel.text = "Closet"
			$RoomSection / RoomSprite.play("8")
			$PrevButton.visible = true
			$NextButton.visible = true
		10:
			$CharsLabel.text = "Back Stage"
			$RoomSection / RoomSprite.play("9")
			$PrevButton.visible = true
			$NextButton.visible = true
		11:
			$CharsLabel.text = "Vent Outlet"
			$RoomSection / RoomSprite.play("_10")
			$PrevButton.visible = true
			$NextButton.visible = false

func SwitchPoster():
	match (currentPoster):
		0:
			$CharsLabel.text = "Freddy Poster"
			$PosterSection / PosterSprite.play("default")
			$PrevButton.visible = false
			$NextButton.visible = true
		1:
			$CharsLabel.text = "Bonnie Poster"
			$PosterSection / PosterSprite.play("post2")
			$PrevButton.visible = true
			$NextButton.visible = true
		2:
			$CharsLabel.text = "Chica Poster"
			$PosterSection / PosterSprite.play("post3")
			$PrevButton.visible = true
			$NextButton.visible = true
		3:
			$CharsLabel.text = "Foxy Poster"
			$PosterSection / PosterSprite.play("post4")
			$PrevButton.visible = true
			$NextButton.visible = true
		4:
			$CharsLabel.text = "Fredbear Poster"
			$PosterSection / PosterSprite.play("post6")
			$PrevButton.visible = true
			$NextButton.visible = true
		5:
			$CharsLabel.text = "Celebrate Poster"
			$PosterSection / PosterSprite.play("post5")
			$PrevButton.visible = true
			$NextButton.visible = false

func SwitchDev():
	match (currentDev):
		0:
			$CharsLabel.text = "Making Freddy"
			$DevSection / DevSprite.play("default")
			$PrevButton.visible = false
			$NextButton.visible = true
		1:
			$CharsLabel.text = "Making Freddy"
			$DevSection / DevSprite.play("dev2")
			$PrevButton.visible = true
			$NextButton.visible = true
		2:
			$CharsLabel.text = "Making Freddy"
			$DevSection / DevSprite.play("dev3")
			$PrevButton.visible = true
			$NextButton.visible = true
		3:
			$CharsLabel.text = "Making Freddy"
			$DevSection / DevSprite.play("dev4")
			$PrevButton.visible = true
			$NextButton.visible = true
		4:
			$CharsLabel.text = "Making Freddy"
			$DevSection / DevSprite.play("dev5")
			$PrevButton.visible = true
			$NextButton.visible = true
		5:
			$CharsLabel.text = "Making Freddy"
			$DevSection / DevSprite.play("dev6")
			$PrevButton.visible = true
			$NextButton.visible = true
		6:
			$CharsLabel.text = "Making Bonnie"
			$DevSection / DevSprite.play("dev7")
			$PrevButton.visible = true
			$NextButton.visible = true
		7:
			$CharsLabel.text = "Making Bonnie"
			$DevSection / DevSprite.play("dev8")
			$PrevButton.visible = true
			$NextButton.visible = true
		8:
			$CharsLabel.text = "Making Bonnie"
			$DevSection / DevSprite.play("dev9")
			$PrevButton.visible = true
			$NextButton.visible = true
		9:
			$CharsLabel.text = "Making Bonnie"
			$DevSection / DevSprite.play("dev_10")
			$PrevButton.visible = true
			$NextButton.visible = true
		10:
			$CharsLabel.text = "Making Chica"
			$DevSection / DevSprite.play("dev_11")
			$PrevButton.visible = true
			$NextButton.visible = true
		11:
			$CharsLabel.text = "Making Chica"
			$DevSection / DevSprite.play("dev_13")
			$PrevButton.visible = true
			$NextButton.visible = true
		12:
			$CharsLabel.text = "Making Foxy (Close-up)"
			$DevSection / DevSprite.play("dev_14")
			$PrevButton.visible = true
			$NextButton.visible = true
		13:
			$CharsLabel.text = "Making Foxy (Close-up)"
			$DevSection / DevSprite.play("dev_15")
			$PrevButton.visible = true
			$NextButton.visible = true
		14:
			$CharsLabel.text = "Making Threadbear"
			$DevSection / DevSprite.play("dev_16")
			$PrevButton.visible = true
			$NextButton.visible = true
		15:
			$CharsLabel.text = "Making Threadbear"
			$DevSection / DevSprite.play("dev_17")
			$PrevButton.visible = true
			$NextButton.visible = true
		16:
			$CharsLabel.text = "Making Threadbear"
			$DevSection / DevSprite.play("dev_18")
			$PrevButton.visible = true
			$NextButton.visible = true
		17:
			$CharsLabel.text = "Scrapped Threadbear Position"
			$DevSection / DevSprite.play("dev_23")
			$PrevButton.visible = true
			$NextButton.visible = true
		18:
			$CharsLabel.text = "Early Office Testing"
			$DevSection / DevSprite.play("dev_19")
			$PrevButton.visible = true
			$NextButton.visible = true
		19:
			$CharsLabel.text = "Early Office Testing"
			$DevSection / DevSprite.play("dev_20")
			$PrevButton.visible = true
			$NextButton.visible = true
		20:
			$CharsLabel.text = "Chica Planning"
			$DevSection / DevSprite.play("dev_21")
			$PrevButton.visible = true
			$NextButton.visible = true
		21:
			$CharsLabel.text = "Chica Testing"
			$DevSection / DevSprite.play("dev_22")
			$PrevButton.visible = true
			$NextButton.visible = false

func _on_ExitButton_pressed():
	$NextButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$PrevButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$ExitButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CenterContainer / VBoxContainer / CharButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CenterContainer / VBoxContainer / DevButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CharSection / ScrollCharacters.scroll_vertical_enabled = false
	SceneTransition.NextScene("res://Scenes/Menu.tscn", self)

func _on_ExitButton_mouse_entered():
	$ExitButton.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ExitButton_mouse_exited():
	$ExitButton.modulate.a = 1

func _on_NextButton_pressed():
	if $CharSection.visible:
		if currentChar < 4 and not $CharSection / ScrollCharacters / Control / CharSprite / AnimationPlayer.is_playing():
			currentChar += 1
			$CharSection / ScrollCharacters / Control / CharSprite / AnimationPlayer.play("NextChar")
			SoundController.PlayHover()
	elif $DevSection.visible:
		if currentDev < 21:
			currentDev += 1
			SwitchDev()
			SoundController.PlayHover()
	elif $PosterSection.visible:
		if currentPoster < 6:
			currentPoster += 1
			SwitchPoster()
			SoundController.PlayHover()
	elif $RoomSection.visible:
		if currentRoom < 11:
			currentRoom += 1
			SwitchRoom()
			SoundController.PlayHover()

func _on_PrevButton_pressed():
	if $CharSection.visible:
		if seenFriend:
			SceneControl.friendFaded = true
			seenFriend = false
		if currentChar > 0 and not $CharSection / ScrollCharacters / Control / CharSprite / AnimationPlayer.is_playing():
			currentChar -= 1
			$CharSection / ScrollCharacters / Control / CharSprite / AnimationPlayer.play("NextChar")
			SoundController.PlayHover()
	elif $DevSection.visible:
		if currentDev > 0:
			currentDev -= 1
			SwitchDev()
			SoundController.PlayHover()
	elif $PosterSection.visible:
		if currentPoster > 0:
			currentPoster -= 1
			SwitchPoster()
			SoundController.PlayHover()
	elif $RoomSection.visible:
		if currentRoom > 0:
			currentRoom -= 1
			SwitchRoom()
			SoundController.PlayHover()

func _on_CharButton_pressed():
	if seenFriend:
		SceneControl.friendFaded = true
		seenFriend = false
	if $CharSection.visible and currentChar > 0:
		$CharSection / ScrollCharacters / Control / CharSprite / AnimationPlayer.play("NextChar")
		currentChar = 0
	else:
		SwitchChar()
	$ExtrasLabel.text = "Extras - Characters"
	$CharSection.visible = true
	$RoomSection.visible = false
	$DevSection.visible = false
	$PosterSection.visible = false
	$NextButton.rect_position.x = 1555
	$PrevButton.rect_position.x = 700
	$CharSection / ScrollCharacters.scroll_vertical = 0
	itemTargetY = $CenterContainer / VBoxContainer / CharButton.rect_position.y + 352

func _on_DevButton_pressed():
	if $DevSection.visible:
		currentDev = 0
	$ExtrasLabel.text = "Extras - Development"
	$CharSection.visible = false
	$RoomSection.visible = false
	$DevSection.visible = true
	$PosterSection.visible = false
	$NextButton.rect_position.x = 1690
	$PrevButton.rect_position.x = 625
	SwitchDev()
	itemTargetY = $CenterContainer / VBoxContainer / DevButton.rect_position.y + 352

func _on_CharButton_mouse_entered():
	$CenterContainer / VBoxContainer / CharButton.modulate.a = 0.25
	SoundController.PlayHover()

func _on_CharButton_mouse_exited():
	$CenterContainer / VBoxContainer / CharButton.modulate.a = 1

func _on_DevButton_mouse_entered():
	$CenterContainer / VBoxContainer / DevButton.modulate.a = 0.25
	SoundController.PlayHover()

func _on_DevButton_mouse_exited():
	$CenterContainer / VBoxContainer / DevButton.modulate.a = 1

func _on_PosterButton_pressed():
	if $PosterSection.visible:
		currentPoster = 0
	$ExtrasLabel.text = "Extras - Posters"
	$CharSection.visible = false
	$RoomSection.visible = false
	$DevSection.visible = false
	$PosterSection.visible = true
	$NextButton.rect_position.x = 1690
	$PrevButton.rect_position.x = 625
	SwitchPoster()
	itemTargetY = $CenterContainer / VBoxContainer / PosterButton.rect_position.y + 352

func _on_PosterButton_mouse_entered():
	$CenterContainer / VBoxContainer / PosterButton.modulate.a = 0.25
	SoundController.PlayHover()

func _on_PosterButton_mouse_exited():
	$CenterContainer / VBoxContainer / PosterButton.modulate.a = 1

func _on_RoomClick_pressed():
	$RoomSection / RoomSprite / AnimationPlayer.play("ZoomIn")
	zoomState = 1
	$CenterContainer / VBoxContainer / CharButton.disabled = true
	$CenterContainer / VBoxContainer / RoomButton.disabled = true
	$CenterContainer / VBoxContainer / PosterButton.disabled = true
	$CenterContainer / VBoxContainer / DevButton.disabled = true
	$ExitButton.disabled = true
	$RoomSection / RoomClick.visible = false
	$RoomSection / RoomClickLab.visible = false
	$BiteySpritey.visible = false
	$RoomSection / RoomClick / CamZoom1.play()

func _on_RoomButton_pressed():
	if $RoomSection.visible:
		currentRoom = 0
	$ExtrasLabel.text = "Extras - Rooms"
	$CharSection.visible = false
	$RoomSection.visible = true
	$DevSection.visible = false
	$PosterSection.visible = false
	$NextButton.rect_position.x = 1690
	$PrevButton.rect_position.x = 625
	SwitchRoom()
	itemTargetY = $CenterContainer / VBoxContainer / RoomButton.rect_position.y + 352

func _on_RoomButton_mouse_entered():
	$CenterContainer / VBoxContainer / RoomButton.modulate.a = 0.25
	SoundController.PlayHover()

func _on_RoomButton_mouse_exited():
	$CenterContainer / VBoxContainer / RoomButton.modulate.a = 1

func ZoomDone():
	$CenterContainer / VBoxContainer / CharButton.disabled = false
	$CenterContainer / VBoxContainer / RoomButton.disabled = false
	$CenterContainer / VBoxContainer / PosterButton.disabled = false
	$CenterContainer / VBoxContainer / DevButton.disabled = false
	$ExitButton.disabled = false
	$RoomSection / RoomClick.visible = true
	$RoomSection / RoomClickLab.visible = true
	$RoomSection / RoomClickLab.text = "Click to zoom in"
	$RoomSection / RoomClickLab.rect_position = Vector2(960, 809)
	zoomState = 0
	$BiteySpritey.visible = true

func ZoomedIn():
	zoomState = 2
	$RoomSection / RoomClickLab.text = "Right click to zoom out"
	$RoomSection / RoomClickLab.rect_position = Vector2(20, 1013)
	$RoomSection / RoomClickLab.visible = true

func _on_BiteButton_pressed():
	$BiteySpritey / AudioStreamPlayer.play()

func _on_SodaButton_pressed():
	if not $ExtrasLabel / SodaStuff / SodaButton / AudioStreamPlayer.playing:
		$ExtrasLabel / SodaStuff / SodaButton / AudioStreamPlayer.play()

func _on_SodaButton_mouse_entered():
	$ExtrasLabel / SodaStuff / SodaWinLab.visible = true

func _on_SodaButton_mouse_exited():
	$ExtrasLabel / SodaStuff / SodaWinLab.visible = false
