extends CanvasLayer

var sceneTarget = ""
var sceneCurrent = ""
var timeLoad = -1.0
var doneFadeout = true
var loadMain = false
var startLoad = false

#onready var mainLevel: PackedScene = preload("res://Scenes/Main.tscn")

func NextScene(target, current_scene):
	sceneCurrent = current_scene
	loadMain = false
	sceneTarget = target
	$AnimationPlayer.play("FadeIn")
	doneFadeout = false
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP

	if target == "res://Scenes/Main.tscn":
		#OS.set_window_title("A Bite at Freddy's - Loading, stay put!")
		loadMain = true
		$ColorRect.get_node("BackSprite").get_node("ColdBuffer").visible = false
		if SceneControl.currentLevel < 5:
			if SceneControl.currentLevel == 4:
				$ColorRect.get_node("BackSprite").get_node("WarnLab1").text = "FINAL COURSE"
			else:
				$ColorRect.get_node("BackSprite").get_node("WarnLab1").text = "COURSE " + str(SceneControl.currentLevel)
		else:
			match SceneControl.currentLevel:
				5:
					$ColorRect.get_node("BackSprite").get_node("WarnLab1").text = "CUSTOM COURSE"
				6:
					$ColorRect.get_node("BackSprite").get_node("WarnLab1").text = "OUT OF SERVICE"
				7:
					$ColorRect.get_node("BackSprite").get_node("WarnLab1").text = "HAUNTING ROULETTE"
				8:
					$ColorRect.get_node("BackSprite").get_node("WarnLab1").text = "BASKET HUNT"
				9:
					$ColorRect.get_node("BackSprite").get_node("WarnLab1").text = "COLD KITCHEN"
					$ColorRect.get_node("BackSprite").get_node("ColdBuffer").visible = true
				10:
					$ColorRect.get_node("BackSprite").get_node("WarnLab1").text = "LUNCH RUSH"
				11:
					$ColorRect.get_node("BackSprite").get_node("WarnLab1").text = "FULL COURSE"
				_:
					$ColorRect.get_node("BackSprite").get_node("WarnLab1").text = "UNKNOWN CHALLENGE"
		
		match SceneControl.currentLevel:
			0, 1:
				$ColorRect.get_node("BackSprite").play("default")
				$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "Let's get to work."
			2:
				$ColorRect.get_node("BackSprite").play("2")
				$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "Onto the main course."
			3:
				$ColorRect.get_node("BackSprite").play("3")
				$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "Now we're cooking."
			4:
				$ColorRect.get_node("BackSprite").play("4")
				$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "One more to go."
			5:
				if SceneControl.customActivity == [20, 20, 20, 20, 20]:
					$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "You're DOOMED."
				elif SceneControl.customActivity == [0, 0, 0, 0, 0]:
					$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "Huh?"
				elif SceneControl.customActivity == [1, 9, 8, 3, 0]:
					$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "Where it all began."
				elif SceneControl.customActivity == [1, 9, 8, 5, 0]:
					$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = " "
				elif SceneControl.customActivity == [1, 9, 8, 7, 0]:
					$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "It wasn't us."
				else:
					$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "It's up to you."
			6:
				$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "Get resourceful."
			7:
				$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "Don't trust anything."
			8:
				$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "Sharp eyes required."
			9:
				$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "Keep things moving."
			10:
				$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "Act timely."
			11:
				$ColorRect.get_node("BackSprite").get_node("WarnLab2").text = "Beware your power."
		if SceneControl.currentLevel >= 5:
			$ColorRect.get_node("BackSprite").play("5")
			if SceneControl.customActivity[0] > 0:
				$ColorRect.get_node("BackSprite").get_node("Fred").visible = true
			if SceneControl.customActivity[1] > 0:
				$ColorRect.get_node("BackSprite").get_node("Bon").visible = true
			if SceneControl.customActivity[2] > 0:
				$ColorRect.get_node("BackSprite").get_node("Chic").visible = true
			if SceneControl.customActivity[3] > 0:
				$ColorRect.get_node("BackSprite").get_node("Fox").visible = true
			if SceneControl.customActivity[4] > 0:
				$ColorRect.get_node("BackSprite").get_node("Tb").visible = true
	elif target == "res://Scenes/Menu.tscn":
		SceneControl.currentLevel = SceneControl.prevLevel

func StartLoad():
	sceneCurrent.queue_free()
	if sceneTarget == "res://Scenes/Main.tscn":
		var nextScene = load(sceneTarget) as PackedScene
		if nextScene:
			get_tree().current_scene.queue_free()
			get_tree().change_scene_to(nextScene)
		else:
			print("Scene load failed")
	else:
		if get_tree().change_scene(sceneTarget) != OK:
			print("Scene load fail")

	$AnimationPlayer.play("FadeOut")
	OS.set_window_title("A Bite at Freddy's")
	loadMain = false

func FadedIn():
	if not loadMain:
		StartLoad()
	else:
		$AnimationPlayer.play("BiteOpen")

func FadedOut():
	doneFadeout = true
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$ColorRect.get_node("BackSprite").get_node("Fred").visible = false
	$ColorRect.get_node("BackSprite").get_node("Bon").visible = false
	$ColorRect.get_node("BackSprite").get_node("Chic").visible = false
	$ColorRect.get_node("BackSprite").get_node("Fox").visible = false
	$ColorRect.get_node("BackSprite").get_node("Tb").visible = false
