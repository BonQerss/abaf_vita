extends Node

var devMode = false
var performant = true  # Vita only supports GLES2, so always performant

var currentLevel = 0
var gameComplete = false
var finaleComplete = false
var inCutscene = 0
var prevLevel = 0
var failReason = 0
var whoScare = 0

var dialRepeat = false

var tipSelects = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var customActivity = [0, 0, 0, 0, 0]

var firstTurn = true
var firstDirect = true

var customVolume = 0.0
var musicOn = true
var fullScreen = false  # Vita doesn't support windowed mode
var tutorialReplay = false
var windowOffset = false
var sodaWon = 0
var friendFaded = false
var firstRight = true

var beatChallenge1 = false
var beatChallenge2 = false
var beatChallenge3 = false
var beatChallenge4 = false
var beatChallenge5 = false
var beatChallenge6 = false
var beatChallenge20 = false
var beatChallenge0 = false

func _ready():
	Engine.set_target_fps(30)  # Limit to 30 FPS for stability on Vita
	print("Performant mode enabled, GLES2 required for PS Vita")
	
	SaveData.ReadData()
	if customVolume < 0:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), customVolume)
	
	#OS.set_window_title("A Bite at Freddy's")

func _process(_delta):
	if Input.is_action_just_pressed("ui_screen"):
		print("Fullscreen toggle ignored (not supported on Vita)")

func AdvanceLevel():
	if currentLevel == 3:
		gameComplete = true
	if currentLevel == 4:
		finaleComplete = true
	if currentLevel < 3:
		currentLevel += 1
		prevLevel = currentLevel
	
	if currentLevel >= 5:
		match (currentLevel):
			5:
				if SceneControl.customActivity == [20, 20, 20, 20, 20]:
					SceneControl.beatChallenge20 = true
				elif SceneControl.customActivity == [0, 0, 0, 0, 0]:
					SceneControl.beatChallenge0 = true
			6:
				SceneControl.beatChallenge4 = true
			7:
				SceneControl.beatChallenge2 = true
			8:
				SceneControl.beatChallenge1 = true
			9:
				SceneControl.beatChallenge3 = true
			10:
				SceneControl.beatChallenge5 = true
			11:
				SceneControl.beatChallenge6 = true
	SaveData.WriteData()
