extends Node2D

var overTime = 0
var reasonTxt = ""
var randSel = 0
var lastSel = 0

var tips = [
	
	["Reason not sent"], 
	
	
	["Stop the conveyor if it's acting strange.", "Look out for the glistening eye of an animatronic.", "Check to make sure no one is sneaking onto the conveyor.", "Hear something in the conveyor?"], 
	
	
	
	["Have you cleaned the vents lately?", "Are the vents supposed to make that sound?"], 
	
	["Bonnie saw you, but did you see him?", "Animatronics may lose their senses in the dark.", "Do you ever feel like you're being watched?"], 
	
	["Chica snuck by you.", "Have a duel with Chica for a chance to win a free soda!", "Animatronics may lose their senses in the dark."], 
	
	["You have to be quick on the draw.", "Aim right between the eyes."], 
	
	["Don't let Foxy bite the backstage wires.", "Refreshing the cameras may cause a shock.", "Keep an eye on Foxy."], 
	
	["Freddy lost his head.", "Be careful when you clean the vents.", "Did you hear something?"], 
	
	["Threadbear was watching you.", "Threadbear stays low for attacks."], 
	
	["Foxy might attack when disturbed.", "Foxy will use the conveyor if disturbed.", "Foxy doesn't like being shocked."], 
	
	
	["Bonnie snuck inside.", "Have you used every tool in the conveyor?"], 
	
	["Remember to watch the vents.", "The vents are old, but don't often clatter."], 
	
	
	["Foxy was waiting for you.", "Forget to check on someone?", "You're in Foxy's way.", "The red monster awaits."], 
]

var tipsCustom = [
	
	["Reason not sent (custom)"], 
	
	["Wrong order?", "This food really has a bite to it.", "Eye see you in the dark.", "What's this robot doing in my soup?"], 
	
	["We have a dust bear issue.", "Lay down!"], 
	
	["What's in that cranberry juice?", "Passed by the watchman...", "Love your new suit!"], 
	
	["Chica peeka.", "You're the sandwich this time."], 
	
	["It was high noon, weren't you ready?", "Nice hat."], 
	
	["The quick red fox jumps on the lazy worker.", "Robot foxes have a keen sense for important wires."], 
	
	["It's amazing that Freddy can live without his head, you know?", "It's time he gets that bath.", "When suits attack."], 
	
	["He's everywhere.", "Get this bear muzzled."], 
	
	["The quick red fox jumps on the lazy worker.", "Science is for nerds."], 
	
	["This shouldn't be in custom night.", "eeeeee"], 
	
	["He's everywhere.", "Something's crawling in the vents.", "Get this bear muzzled.", "Those vents must be fumigated."], 
	
	["Freddy was haunting the fan.", "Watch your fingers.", "Brought to you by Ferdinand's Fan Shop."], 
	
	["Chica was haunting the pistol.", "Anyone can double-cross you.", "Hope you like eyepatches."], 
	
	["Someone was haunting the conveyor lever.", "STOP!", "Almost had leverage."], 
	
	["Bonnie was haunting the light button.", "Don't touch.", "Not so bright now, huh?"]
]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$FlyParticles2D.emitting = true
	
	match (SceneControl.whoScare):
		1, 8:
			$BackgroundSprite.play("default")
		2, 9:
			$BackgroundSprite.play("bon")
		3, 10:
			$BackgroundSprite.play("chic")
		4:
			$BackgroundSprite.play("fox")
		5, 11:
			$BackgroundSprite.play("fb")
			$BackgroundSprite / FbEyes / AnimationPlayer.play("FbEyeFlick")
		6, 7:
			$BackgroundSprite.play("fred2")
		12:
			$BackgroundSprite.play("fan")
		13:
			$BackgroundSprite.play("pistol")
		14:
			$BackgroundSprite.play("convLev")
		15:
			$BackgroundSprite.play("light")
			$BackgroundSprite / LightOvr / AnimationPlayer.play("LightFlicko")
	
	print(SceneControl.tipSelects)
	
	if SceneControl.currentLevel < 5:
		reasonTxt = tips[SceneControl.failReason][SceneControl.tipSelects[SceneControl.failReason]]
	else:
		reasonTxt = tipsCustom[SceneControl.failReason][SceneControl.tipSelects[SceneControl.failReason]]
	
	
	if SceneControl.currentLevel < 5:
		if SceneControl.tipSelects[SceneControl.failReason] >= (tips[SceneControl.failReason].size() - 1):
			SceneControl.tipSelects[SceneControl.failReason] = 0
		else:
			SceneControl.tipSelects[SceneControl.failReason] += 1
	else:
		if SceneControl.tipSelects[SceneControl.failReason] >= (tipsCustom[SceneControl.failReason].size() - 1):
			SceneControl.tipSelects[SceneControl.failReason] = 0
		else:
			SceneControl.tipSelects[SceneControl.failReason] += 1
	
	print(SceneControl.tipSelects)
	
	
	if SceneControl.currentLevel < 5:
		$VBoxContainer / ChallengeButton.visible = false
		$VBoxContainer.rect_position.y = 863
	else:
		$VBoxContainer / ChallengeButton.visible = true
		$VBoxContainer.rect_position.y = 759
	

func _process(delta):
	overTime += delta
	
	if overTime >= 500:
		SceneTransition.NextScene("res://Scenes/Menu.tscn", self)

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _on_RetryButton_pressed():
	if SceneControl.inCutscene == 0:
		SceneTransition.NextScene("res://Scenes/Main.tscn", self)
	elif SceneControl.inCutscene == 1:
		SceneTransition.NextScene("res://Scenes/ConveyorRepair.tscn", self)
	elif SceneControl.inCutscene == 2:
		SceneTransition.NextScene("res://Scenes/HallTravel.tscn", self)
	SoundController.PlayClick()
	HideButtons()

func _on_MenuButton_pressed():
	if SceneControl.currentLevel >= 5:
		SceneControl.customActivity = [0, 0, 0, 0, 0]
	SceneTransition.NextScene("res://Scenes/Menu.tscn", self)
	SoundController.PlayClick()
	HideButtons()

func _on_ChallengeButton_pressed():
	SceneTransition.NextScene("res://Scenes/Challenges.tscn", self)
	SoundController.PlayClick()
	HideButtons()

func _on_RetryButton_mouse_entered():
	$VBoxContainer / RetryButton / ResumeLabel.modulate.a = 0.25
	SoundController.PlayHover()

func _on_RetryButton_mouse_exited():
	$VBoxContainer / RetryButton / ResumeLabel.modulate.a = 1.0

func _on_MenuButton_mouse_entered():
	$VBoxContainer / MenuButton / ResumeLabel.modulate.a = 0.25
	SoundController.PlayHover()

func _on_MenuButton_mouse_exited():
	$VBoxContainer / MenuButton / ResumeLabel.modulate.a = 1.0

func _on_ChallengeButton_mouse_entered():
	$VBoxContainer / ChallengeButton / ResumeLabel.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ChallengeButton_mouse_exited():
	$VBoxContainer / ChallengeButton / ResumeLabel.modulate.a = 1.0

func TextEnterFinished():
	$TipText.StartTip(reasonTxt)
	$TipText.doneDial = false
	$VBoxContainer / AnimationPlayer.play("RESET")

func StartOverFlick():
	$OverLabel / AnimationPlayer.play("Flicker")

func HideButtons():
	$VBoxContainer / RetryButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$VBoxContainer / MenuButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$VBoxContainer / ChallengeButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
