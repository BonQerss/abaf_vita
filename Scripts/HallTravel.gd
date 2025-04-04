extends Node2D

var hallStep = 0
var roomIn = 0
var foxDodged = false
var foxTime = - 1

func _ready():
	SceneControl.inCutscene = 2

func _process(delta):
	
	if foxTime >= 0:
		if foxTime >= 1.2:
			FoxAttack()
		else:
			foxTime += delta

func _physics_process(delta):
	$Center.position.y = lerp($Center.position.y, $MouseRefRect.rect_position.y, delta * 4)
	

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _on_HideButton_pressed():
	if hallStep == 0:
		hallStep += 1
		$HideButton.visible = false
		$UnhideButton.visible = true
		$ForwardButton.visible = false
		print("Hiding behind the banner")

func _on_ForwardButton_pressed():
	if hallStep == 0:
		hallStep = 3
		$ForwardButton.visible = false
		$FadeRect / AnimationPlayer.play("FadeNext")
		\
\
\
\
\
\
		"\n		print(\"FOXY ATTACK!\")\n		SceneControl.whoScare = 4\n		SceneControl.failReason = 12\n		if get_tree().change_scene(\"res://Scenes/GameOver.tscn\") != OK:\n			print(\"Scene load fail\")\n		"
	elif hallStep == 2:
		\
\
\
\
\
\
\
		"\n		hallStep += 1\n		$ForwardButton.visible = false\n		$LeaveButton.visible = true\n		$DuckButton.visible = true\n		$HallBack.play(\"exit\")\n		print(\"Moving forward\")\n		"
		pass

func _on_UnhideButton_pressed():
	if hallStep == 1:
		hallStep += 1
		$ForwardButton.visible = true
		$UnhideButton.visible = false
		print("Leaving banner")

func _on_LeaveButton_pressed():
	if hallStep == 4:
		FoxAttack()
		\
\
\
\
\
\
		"\n		print(\"BONNIE ATTACK!\")\n		SceneControl.whoScare = 2\n		SceneControl.failReason = 13\n		if get_tree().change_scene(\"res://Scenes/GameOver.tscn\") != OK:\n			print(\"Scene load fail\")\n		"
	else:
		SceneControl.inCutscene = 0
		SceneControl.gameComplete = true
		SaveData.WriteData()
		SceneTransition.NextScene("res://Scenes/WinGame.tscn", self)

func _on_DuckButton_pressed():
	if hallStep == 4:
		hallStep += 1
		$LeaveButton.visible = false
		$DuckButton.visible = false
		$UnduckButton.visible = true
		foxTime = - 1
		print("Ducking from Foxy")

func _on_UnduckButton_pressed():
	if hallStep == 5:
		hallStep += 1
		$UnduckButton.visible = false
		$LeaveButton.visible = true
		print("Standing back up")

func FoxAttack():
	print("FOXY ATTACK!")
	SceneControl.whoScare = 4
	SceneControl.failReason = 12
	if get_tree().change_scene("res://Scenes/GameOver.tscn") != OK:
		print("Scene load fail")
	$LeaveButton.visible = false
	$DuckButton.visible = false
	foxTime = - 1

func ToCorner():
	hallStep = 4
	foxTime = 0
	$LeaveButton.visible = true
	$DuckButton.visible = true
	$HallBack.play("exit")
	print("Moving forward")

func _on_DownArea2D_mouse_entered():
	print("Area entered")
	if $MouseRefRect.rect_position.y == 540:
		$MouseRefRect.rect_position.y = 945
