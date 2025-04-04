extends Node

var save_path = "user://save.dat"

var keyNames = ["scottAI", "edward5", "turbo", "PlayPA2020NowOnSteam", "volume", "superVisuals", "pop", "pickles2", "chal1", "chal2", "chal3", "chal4", "chal5", "chal6", "chal20", "borderless", "rolly", "music"]

func WriteData():
	var data = {
		keyNames[0]: SceneControl.prevLevel, 
		keyNames[1]: SceneControl.gameComplete, 
		keyNames[2]: SceneControl.inCutscene, 
		keyNames[3]: 4.99, 
		keyNames[4]: SceneControl.customVolume, 
		keyNames[5]: SceneControl.fullScreen, 
		keyNames[6]: SceneControl.sodaWon, 
		keyNames[7]: SceneControl.finaleComplete, 
		keyNames[8]: SceneControl.beatChallenge1, 
		keyNames[9]: SceneControl.beatChallenge2, 
		keyNames[10]: SceneControl.beatChallenge3, 
		keyNames[11]: SceneControl.beatChallenge4, 
		keyNames[12]: SceneControl.beatChallenge5, 
		keyNames[13]: SceneControl.beatChallenge6, 
		keyNames[14]: SceneControl.beatChallenge20, 
		keyNames[15]: SceneControl.tutorialReplay, 
		keyNames[16]: SceneControl.beatChallenge0, 
		keyNames[17]: SceneControl.musicOn
	}
	
	var file = File.new()
	if file.open(save_path, File.WRITE) == OK:
		file.store_var(data)
		print("Writing data")
		file.close()

func ReadData():
	var file = File.new()
	if file.file_exists(save_path):
		if file.open(save_path, File.READ) == OK:
			var player_data = file.get_var()
			print("Reading data")
			file.close()
			
			if not SceneControl.devMode:
				for i in range(keyNames.size()):
					if player_data.has(keyNames[i]):
						SceneControl.set(keyNames[i], player_data[keyNames[i]])
				
				if SceneControl.prevLevel > 3:
					SceneControl.prevLevel = 3
				SceneControl.currentLevel = SceneControl.prevLevel
			else:
				print("Developer mode active, skipping level enforcement")
	else:
		print("Save file not yet written")
