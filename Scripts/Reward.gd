extends Control


var rewardTime = 0
var basketTime = - 1
var rand = RandomNumberGenerator.new()

func _ready():
	rand.randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	match (SceneControl.currentLevel):
		5:
			if SceneControl.customActivity == [20, 20, 20, 20, 20]:
				$RewardLabel.text = "a Fredbear Finger Puppet!"
				$DescLab.text = "He's watching you."
				$RewardSprite.play("20")
			elif SceneControl.customActivity == [0, 0, 0, 0, 0]:
				$RewardLabel.text = "a Paper Roll!"
				$DescLab.text = "You deserve this."
				$RewardSprite.play("roll")
			else:
				$RewardLabel.text = "a Yellow Slip!"
				$DescLab.text = "\"Isn't that neat?\" - Phone Guy"
				$RewardSprite.play("slip")
		6:
			$RewardLabel.text = "Freddy and Bonnie Finger Puppets!"
			if not SceneControl.beatChallenge6:
				$DescLab.text = "Tell a story!"
			else:
				$DescLab.text = "Tell another story!"
			$RewardSprite.play("6")
		7:
			$RewardLabel.text = "a Haunted Basket!"
			$DescLab.text = "Watch out."
			$RewardSprite.play("2")
			basketTime = 0
		8:
			$RewardLabel.text = "a Grilled Boot!"
			$DescLab.text = "It's a little chewy."
			$RewardSprite.play("default")
		9:
			$RewardLabel.text = "a Snow Freddy!"
			$DescLab.text = "Beware the yellow one."
			$RewardSprite.play("4")
		10:
			$RewardLabel.text = "a Talkshow Bonnie Clock!"
			$DescLab.text = "Time is valuable."
			$RewardSprite.play("5")
		11:
			$RewardLabel.text = "Foxy and Chica Finger Puppets!"
			if not SceneControl.beatChallenge4:
				$DescLab.text = "Tell a story!"
			else:
				$DescLab.text = "Tell another story!"
			$RewardSprite.play("7")

func _process(delta):
	if rewardTime >= 0:
		if rewardTime >= 60:
			SceneTransition.NextScene("res://Scenes/Challenges.tscn", self)
			rewardTime = - 1
		else:
			rewardTime += delta
	
	if basketTime >= 0:
		if basketTime >= 0.04:
			$RewardSprite.frame = rand.randi_range(0, 4)
			basketTime = 0
		else:
			basketTime += delta

func _on_ContinueButton_pressed():
	SceneTransition.NextScene("res://Scenes/Challenges.tscn", self)
	SoundController.PlayClick()
	$ContinueButton.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_ContinueButton_mouse_entered():
	$ContinueButton.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ContinueButton_mouse_exited():
	$ContinueButton.modulate.a = 1.0

func FadeInDone():
	$AudioStreamPlayer3.play()
