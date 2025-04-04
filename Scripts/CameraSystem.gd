extends Node2D

var camActive = false
var camStop = false
var animStop = true
var currentCam = 1
var camFroze = false; var camBackup = false
var camStates = {"orderA": false, "orderB": false, "ordersDelivered": 0, "fanState": 0, "door5": false, "door6": false, "door7": false, "kitState": 0, 
"door5Halt": false, "door6Halt": false, "door7Halt": false}

var fan = {"drop": false, "time": - 1, "state": 0, "chop": false, "haunted": false}

var door_5 = false; var door_6 = false; var door_7 = false
var door5_Time = - 1; var door6_Time = - 1; var door7_Time = - 1; var service_Time = - 1
var door5_Halt = false; var door6_Halt = false; var door7_Halt = false
var doorBlock_Time = - 1

var serviceLight = false; var mouseInService = false

var camRef = false
var refTime = - 1
var refTimeMax = 3
var camTbActive = false; var prevTbCam = 0; var camTbIncoming = false
var conveyorJam = false

var mouseInside = false
var lockCam = false; var lockButtons = false


var orderCam1 = false; var orderCam2 = false
var orderA = false; var orderB = false
var ordersDelivered = 0
var orderConfirm = false
var randomDestinations = [0, 0, 0, 0]
var destinationsDelivered = {"stage": false, "dining": false, "lab": false, "hall": false, "closet": false, "backstage": false}
var kitOrderState = 0


var toolDisconnect = {"door6": false, "door7": false, "refresh": false, "service": false}
var randCam = RandomNumberGenerator.new()
var secretCam = {"val": 0, "foxAct": false, "hallFree": true, "doorKnock": 0}
var camIceTime = - 1; var camIceMax = 12; var camIceMult = 1
var usingShocker = false

signal device_on(deviceOn)
signal disable_interface(camsOn)
signal enable_interface()
signal disable_bend(bendOn)
signal air_on(airOn)
signal get_room_state()
signal cam_reload()
signal check_chop()
signal refresh_tb(isAttach)
signal fan_scare()
signal disconnect_tool()
signal vent_shock()
signal hide_shocker(isHide)
signal check_secret()

func _ready():
	randCam.randomize()
	$CamVis / static1.play()
	$CamVis.set_animation("cam1")
	$CamVis / CamOverlays / VidBox / AnimationPlayer.stop(false)
	$CamVis / CamOverlays / FbCams / AudioStreamPlayer2.volume_db = - 16
	if SceneControl.currentLevel == 1:
		$CamVis / CamButtons / Cam10.visible = false
	else:
		$CamVis / CamButtons / Cam10.visible = true
	if SceneControl.currentLevel == 10 or SceneControl.currentLevel == 8:
		$CamVis / CamOverlays / KitOrd1 / KitOrd4.visible = true
		$CamVis / CamOverlays / KitOrd2 / KitOrd4.visible = true
		if SceneControl.currentLevel == 10:
			$CamVis / CamOverlays / KitOrd1 / KitOrd5.visible = true
			$CamVis / CamOverlays / KitOrd2 / KitOrd5.visible = true
		else:
			$CamVis / CamOverlays / KitOrd1 / KitOrd5.visible = false
			$CamVis / CamOverlays / KitOrd2 / KitOrd5.visible = false
	else:
		$CamVis / CamOverlays / KitOrd1 / KitOrd4.visible = false
		$CamVis / CamOverlays / KitOrd1 / KitOrd5.visible = false
		$CamVis / CamOverlays / KitOrd2 / KitOrd4.visible = false
		$CamVis / CamOverlays / KitOrd2 / KitOrd5.visible = false
	camIceMax = randCam.randi_range(20, 35)
	if SceneControl.currentLevel != 9:
		$CamVis / AudioStreamPlayer3.play()
	else:
		$CamVis / AudioStreamPlayer4.play()

func _process(delta):
	if mouseInside and get_viewport().get_mouse_position().y < 960 and camStop and animStop:
		mouseInside = false
		if not lockCam:
			$Area2D / camhit.visible = true
		camStop = false
	if fan.time >= 0:
		if fan.time > 1.5:
			$CamVis / CamToolButtons / VentButton.modulate = Color(1, 1, 1, 1)
			$CamVis / CamToolButtons / VentButton.disabled = false
			fan.time = - 1
		else:
			fan.time += delta
	if camRef:
		if refTime > refTimeMax:
			camRef = false
			refTime = - 1
			$CamVis / CamButtons.visible = true
			$CamVis / CamToolButtons / RefreshButton.modulate = Color(1, 1, 1, 1)
			$CamVis / BlockCam2.visible = false
			$CamVis / CamToolButtons / RefreshButton / AudioStreamPlayer.stop()
			$CamVis / static1 / AudioStreamPlayer.stop()
		else:
			refTime += delta
	if door5_Time >= 0:
		if door5_Time > 2:
			$CamVis / CamToolButtons / Door5Button.modulate = Color(1, 1, 1, 1)
			$CamVis / CamToolButtons / Door5Button.disabled = false
			
			
			
			
			door5_Time = - 1
		else:
			door5_Time += delta
	if door6_Time >= 0:
		if door6_Time > 2:
			$CamVis / CamToolButtons / Door6Button.modulate = Color(1, 1, 1, 1)
			$CamVis / CamToolButtons / Door6Button.disabled = false
			
			
			
			if door_6:
				pass
			else:
				if orderCam1:
					if currentCam == 6:
						$CamVis / CamToolButtons / ConfirmButton.visible = true
						$CamVis / CamToolButtons / Door6Button.visible = false
						$AudioStreamPlayer2D7.stop()
				else:
					pass
			
			door6_Time = - 1
		else:
			door6_Time += delta
	if door7_Time >= 0:
		if door7_Time > 2:
			$CamVis / CamToolButtons / Door7Button.modulate = Color(1, 1, 1, 1)
			$CamVis / CamToolButtons / Door7Button.disabled = false
			if door_7:
				pass
			else:
				if orderCam2:
					if currentCam == 7:
						$CamVis / CamToolButtons / ConfirmButton.visible = true
						$CamVis / CamToolButtons / Door7Button.visible = false
						$AudioStreamPlayer2D7.stop()
				else:
					pass
			door7_Time = - 1
		else:
			door7_Time += delta
	if service_Time >= 0:
		if service_Time > 2:
			$CamVis / CamToolButtons / ServiceButton.modulate = Color(1, 1, 1, 1)
			$CamVis / CamToolButtons / ServiceButton.disabled = false
			service_Time = - 1
		else:
			service_Time += delta
	if doorBlock_Time > - 1:
		if doorBlock_Time > 0.3:
			doorBlock_Time = - 1
			$CamVis / BlockCam3.visible = false
			$CamVis / static1 / AudioStreamPlayer.stop()
		else:
			doorBlock_Time += delta
	
	if camIceTime >= 0:
		if camIceTime >= camIceMax:
			$CamVis / CamOverlays / CamIce / AnimationPlayer.play("CamFreezing")
			$CamVis / CamOverlays / CamIce / IceAudio.play()
			camIceTime = - 1
		else:
			camIceTime += delta
	
	if $CamVis / CamOverlays / FbCams / AudioStreamPlayer3.playing:
		$CamVis / CamOverlays / FbCams / AudioStreamPlayer3.pitch_scale = rand_range(0.25, 0.4)



func _on_Area2D_mouse_entered():
	if not lockCam and not mouseInside:
		if not camActive:
			$Area2D / AudioStreamPlayer.play()
			emit_signal("disable_interface", true)
			$MonitorAnim.play("open")
			$MonitorAnim.visible = true
			$Area2D / camhit.visible = false
			mouseInside = true
			camStop = true
			animStop = false
			$CamVis / CamOverlays / VentFan / AudioStreamPlayer.volume_db = - 6
			if SceneControl.currentLevel == 7:
				emit_signal("hide_shocker", true)
		else:
			$Area2D / AudioStreamPlayer2.play()
			$MonitorAnim.play("close")
			$CamVis.visible = false
			$Area2D / camhit.visible = false
			emit_signal("disable_bend", false)
			mouseInside = true
			camStop = true
			animStop = false
			$CamVis / AudioStreamPlayer.stop()
			$CamVis / AudioStreamPlayer2.stop()
			$CamVis / CamOverlays / VentFan / AudioStreamPlayer.volume_db = - 12
			if camBackup and not $CamVis / BlockCam4.visible:
				emit_signal("device_on", - 1)
			if serviceLight:
				$CamVis / CamOverlays / ServiceSprite / AudioStreamPlayer.volume_db = - 80
			if camRef:
				$CamVis / CamToolButtons / RefreshButton / AudioStreamPlayer.volume_db = - 80
				$CamVis / static1 / AudioStreamPlayer.volume_db = - 80
			$CamVis / AudioStreamPlayer3.volume_db = - 80
			$CamVis / AudioStreamPlayer4.volume_db = - 80
			if $CamVis / CamOverlays / FbCams / AudioStreamPlayer2.playing:
				$CamVis / CamOverlays / FbCams / AudioStreamPlayer2.volume_db = - 16
			if $CamVis / FbBlock / AudioStreamPlayer.playing:
				$CamVis / FbBlock / AudioStreamPlayer.volume_db = - 10
			if $CamVis / CamOverlays / FbCams / AudioStreamPlayer3.playing:
				$CamVis / CamOverlays / FbCams / AudioStreamPlayer3.stop()
			emit_signal("check_secret")

func _on_VentButton_pressed():
	if not fan.haunted:
		if not lockButtons:
			if fan.state == 0 or fan.state == 2:
				fan.time = 0
				UpdateFanState()
				$CamVis / CamToolButtons / VentButton.modulate = Color(1, 1, 1, 0.25)
				$CamVis / CamToolButtons / VentButton.disabled = true
				$CamVis / CamToolButtons / AudioStreamPlayer.play()
	else:
		emit_signal("fan_scare")
		print("SCARE!")

func UpdateFanState():
	match (fan.state):
		0:
			fan.state = 1
			fan.drop = true
			emit_signal("device_on", 2)
			$CamVis / CamToolButtons / VentButton / DoorLab.text = "DISABLE\nFAN"
			$CamVis / CamButtons / Cam10 / CamDoor.visible = true
			emit_signal("air_on", true)
			print("Fan dropping")
			if fan.chop:
				lockCam = true
				emit_signal("check_chop")
				if not camFroze:
					$CamVis / CamOverlays / ChopSprite.visible = true
				$CamVis / CamOverlays / ChopSprite.play("chop")
				$CamVis / CamOverlays / FredCams / AudioStreamPlayer3.play(0.1)
			if not camFroze:
				$CamVis / CamOverlays / VentFan.visible = true
			$CamVis / CamOverlays / VentFan.play("drop")
			$CamVis / CamOverlays / VentFan / AudioStreamPlayer.play()
			$CamVis / CamOverlays / VentFan / AudioStreamPlayer2.play()
		1:
			fan.state = 2
			fan.drop = false
			print("Fan dropped")
		2:
			fan.state = 3
			fan.drop = true
			emit_signal("device_on", - 2)
			$CamVis / CamToolButtons / VentButton / DoorLab.text = "ENABLE\nFAN"
			$CamVis / CamButtons / Cam10 / CamDoor.visible = false
			$CamVis / CamOverlays / VentFan.play("lift")
			print("Fan raising")
			$CamVis / CamOverlays / VentFan / AudioStreamPlayer.stop()
			$CamVis / CamOverlays / VentFan / AudioStreamPlayer2.stop()
			$CamVis / CamOverlays / VentFan / AudioStreamPlayer3.play()
		3:
			fan.state = 0
			fan.drop = false
			print("Fan raised")
			emit_signal("air_on", false)
			if not camFroze:
				$CamVis / CamOverlays / VentFan.visible = false
	if not camFroze:
		camStates.fanState = fan.state

func _on_RefreshButton_pressed():
	if not camRef:
		camRef = true
		refTime = 0
		if SceneControl.currentLevel != 9:
			refTimeMax = 2.5
		else:
			refTimeMax = 3.0
		$CamVis / CamToolButtons / RefreshButton.modulate = Color(1, 1, 1, 0.25)
		$CamVis / CamButtons.visible = false
		$CamVis / BlockCam2.visible = true
		$CamVis / CamToolButtons / AudioStreamPlayer.play()
		$CamVis / static1 / AudioStreamPlayer.play()
	if camFroze:
		refTimeMax = 7
		CamUnfreeze()
		if SceneControl.currentLevel != 9:
			camBackup = true
			emit_signal("device_on", 1)
			$CamVis.play("cam9_5")
			if $CamVis / CamOverlays / FoxCams.animation == "cam9_4":
				$CamVis / CamOverlays / FoxCams.play("cam9_6")
				$CamVis / CamOverlays / FoxCams.position = Vector2( - 575, 249)
			if $CamVis / CamToolButtons / DisconnectButton.visible:
				$CamVis / CamToolButtons / DisconnectButton.visible = false
	if camTbActive:
		refTimeMax = 6
		emit_signal("refresh_tb", true)
		camTbActive = false
		$CamVis / CamOverlays / FbCams / AudioStreamPlayer3.stop()
	if camTbIncoming:
		emit_signal("refresh_tb", false)
		camTbIncoming = false
		$CamVis / CamOverlays / FbCams / AudioStreamPlayer3.stop()
	if SceneControl.currentLevel == 9:
		$CamVis / CamOverlays / CamIce / AnimationPlayer.play("RESET")
		camIceTime = 0
		camIceMax = randCam.randi_range(45, 55) * camIceMult
	$CamVis / CamToolButtons / RefreshButton / AudioStreamPlayer.play(rand_range(0.0, 3.0))

func _on_MonitorAnim_animation_finished():
	if not camActive:
		if not lockCam:
			$CamVis.visible = true
			emit_signal("get_room_state")
			$CamVis / CamDot.play()
			$CamVis / CamButtons / CamSel / AnimationPlayer.play("idle")
			emit_signal("disable_bend", true)
			camActive = true
			animStop = true
			if orderCam1 or orderCam2 or (orderConfirm and SceneControl.currentLevel == 8):
				$Area2D / camhit / AnimationPlayer.play("RESET")
			$CamVis / Blipy / AnimationPlayer.play("bliping")
			$CamVis / CamButtons / AudioStreamPlayer.play()
			$CamVis / AudioStreamPlayer.play()
			if camBackup and not $CamVis / BlockCam4.visible:
				emit_signal("device_on", 1)
			if currentCam == 5:
				$CamVis / AudioStreamPlayer3.volume_db = - 22
				$CamVis / AudioStreamPlayer4.volume_db = - 22
				if serviceLight:
					$CamVis / CamOverlays / ServiceSprite / AudioStreamPlayer.volume_db = - 2
			$CamVis / CamToolButtons / RefreshButton / AudioStreamPlayer.volume_db = - 6
			$CamVis / static1 / AudioStreamPlayer.volume_db = - 8
			if currentCam == 10:
				$CamVis / CamOverlays / FbCams / AudioStreamPlayer2.volume_db = - 4
			if currentCam == 9 and camTbIncoming:
				$CamVis / CamOverlays / FbCams / AudioStreamPlayer3.play()
			$CamVis / FbBlock / AudioStreamPlayer.volume_db = - 1
			if SceneControl.currentLevel == 7 and currentCam == 10:
				$CamVis / CamToolButtons / VentShockButton.visible = true
	else:
		$MonitorAnim.visible = false
		$CamVis / CamDot.stop()
		$CamVis / CamButtons / CamSel / AnimationPlayer.stop()
		camActive = false
		animStop = true
		emit_signal("enable_interface")
		if SceneControl.currentLevel == 7:
			emit_signal("hide_shocker", false)
		if orderCam1 or orderCam2 or (orderConfirm and SceneControl.currentLevel == 8):
			$Area2D / camhit / AnimationPlayer.play("OrderUp")
		if $CamVis / CamOverlays / DressDoor.visible:
			secretCam.val = 0
			$CamVis / CamOverlays / DressDoor.visible = false


func _on_camSwitch_pressed():
	SetSel(1)
	$CamVis.set_animation("cam1")
	emit_signal("get_room_state")
	$CamVis / CamButtons / CamSel.rect_position = Vector2($CamVis / CamButtons / Cam01.position.x + - 35, $CamVis / CamButtons / Cam01.position.y + - 35)
	$CamVis / CamName.text = "SHOW STAGE"
	$CamVis / CamButtons / Cam01 / TextBox / CamDir.visible = true
	if destinationsDelivered.stage:
		if orderConfirm and randomDestinations[ordersDelivered] == 4:
			$CamVis / CamRandButtons / randOrder1.visible = true
		else:
			SetHuntText(1)
		$CamVis / CamOverlays / BasketStage.visible = true

func _on_camSwitch2_pressed():
	SetSel(2)
	$CamVis.set_animation("cam2")
	emit_signal("get_room_state")
	$CamVis / CamButtons / CamSel.rect_position = Vector2($CamVis / CamButtons / Cam02.position.x + - 35, $CamVis / CamButtons / Cam02.position.y + - 35)
	$CamVis / CamName.text = "DINING AREA"
	$CamVis / CamButtons / Cam02 / TextBox / CamDir.visible = true
	$CamVis / SecretCamButtons / CowmanButton.visible = true
	$CamVis / SecretCamButtons / BurgButton.visible = true
	$CamVis / SecretCamButtons / MouseyButton.visible = true
	$CamVis / SecretCamButtons / WeeButton.visible = true
	$CamVis / SecretCamButtons / OuuchButton.visible = true
	$CamVis / SecretCamButtons / HappyButton.visible = true
	if destinationsDelivered.dining:
		if orderConfirm and randomDestinations[ordersDelivered] == 5:
			$CamVis / CamRandButtons / randOrder2.visible = true
		else:
			SetHuntText(1)
		$CamVis / CamOverlays / BasketDining.visible = true

func _on_camSwitch3_pressed():
	SetSel(3)
	$CamVis.set_animation("cam3")
	emit_signal("get_room_state")
	$CamVis / CamButtons / CamSel.rect_position = Vector2($CamVis / CamButtons / Cam03.position.x + - 35, $CamVis / CamButtons / Cam03.position.y + - 35)
	$CamVis / CamName.text = "FOXY'S LAB"
	$CamVis / CamButtons / Cam03 / TextBox / CamDir.visible = true
	if destinationsDelivered.lab:
		if orderConfirm and randomDestinations[ordersDelivered] == 6:
			$CamVis / CamRandButtons / randOrder3.visible = true
		else:
			SetHuntText(1)
		$CamVis / CamOverlays / BasketLab.visible = true

func _on_camSwitch4_pressed():
	SetSel(4)
	$CamVis.set_animation("cam4")
	emit_signal("get_room_state")
	$CamVis / CamButtons / CamSel.rect_position = Vector2($CamVis / CamButtons / Cam04.position.x + - 35, $CamVis / CamButtons / Cam04.position.y + - 35)
	$CamVis / CamName.text = "CENTER HALL"
	$CamVis / CamButtons / Cam04 / TextBox / CamDir.visible = true
	if destinationsDelivered.hall:
		if orderConfirm and randomDestinations[ordersDelivered] == 7:
			$CamVis / CamRandButtons / randOrder4.visible = true
		else:
			SetHuntText(1)
		$CamVis / CamOverlays / BasketHall.visible = true
	if secretCam.val == 185 and secretCam.hallFree and not destinationsDelivered.hall:
		$CamVis / CamOverlays / GoldenIdea.visible = true

func _on_camSwitch5_pressed():
	SetSel(5)
	$CamVis.set_animation("cam5")
	emit_signal("get_room_state")
	$CamVis / CamButtons / CamSel.rect_position = Vector2($CamVis / CamButtons / Cam05.position.x + - 35, $CamVis / CamButtons / Cam05.position.y + - 35)
	$CamVis / CamName.text = "KITCHEN"
	$CamVis / CamButtons / Cam05 / TextBox / CamDir.visible = true
	if not toolDisconnect.service and not conveyorJam:
		
		$CamVis / CamToolButtons / Door5Button.visible = true
	$CamVis / CamOverlays / ServiceSprite.visible = true
	$CamVis / CamOverlays / ManagerHat.visible = true
	
	if SceneControl.currentLevel == 10:
		if camStates.kitState <= 6:
			$CamVis / CamOverlays / KitOrd1.visible = true
		if camStates.kitState <= 15:
			$CamVis / CamOverlays / KitOrd2.visible = true
		if camStates.kitState <= 18:
			$CamVis / CamOverlays / KitOrd3.visible = true
	elif SceneControl.currentLevel == 8:
		if camStates.kitState <= 3:
			$CamVis / CamOverlays / KitOrd1.visible = true
		if camStates.kitState <= 9:
			$CamVis / CamOverlays / KitOrd2.visible = true
		if camStates.kitState <= 12:
			$CamVis / CamOverlays / KitOrd3.visible = true
	else:
		if camStates.kitState <= 0:
			$CamVis / CamOverlays / KitOrd1.visible = true
		if camStates.kitState <= 3:
			$CamVis / CamOverlays / KitOrd2.visible = true
		if camStates.kitState <= 6:
			$CamVis / CamOverlays / KitOrd3.visible = true
	
	$CamVis / CamOverlays / KitLevs.visible = true
	$CamVis / CamOverlays / KitOrdPanel.visible = true
	if not camFroze:
		if SceneControl.currentLevel != 9:
			$CamVis / CamOverlays / ManagerHat / AnimationPlayer.play("idle")
		else:
			$CamVis / CamOverlays / ManagerHat / AnimationPlayer.play("idleCold")
	if serviceLight:
		$CamVis / CamOverlays / ServiceSprite / AudioStreamPlayer.volume_db = - 2
	if camStates.door5:
		$CamVis / CamOverlays / doorCam5.visible = true
	$CamVis / AudioStreamPlayer3.volume_db = - 22
	$CamVis / AudioStreamPlayer4.volume_db = - 22
	SetHuntText(1)

func _on_camSwitch6_pressed():
	SetSel(6)
	$CamVis.set_animation("cam6")
	emit_signal("get_room_state")
	$CamVis / CamButtons / CamSel.rect_position = Vector2($CamVis / CamButtons / Cam06.position.x + - 35, $CamVis / CamButtons / Cam06.position.y + - 35)
	$CamVis / CamName.text = "PARTY ROOM A"
	$CamVis / CamButtons / Cam06 / TextBox / CamDir.visible = true
	$CamVis / SecretCamButtons / Bon2Button.visible = true
	$CamVis / SecretCamButtons / Fred2Button.visible = true
	$CamVis / SecretCamButtons / Chic2Button.visible = true
	$CamVis / SecretCamButtons / Sb2Button.visible = true
	if camStates.door6:
		$CamVis / CamOverlays / doorCam6.visible = true
	if not orderCam1 or door6_Halt:
		if not toolDisconnect.door6 and not conveyorJam:
			$CamVis / CamToolButtons / Door6Button.visible = true
	else:
		$CamVis / CamToolButtons / ConfirmButton.visible = true
	if camStates.ordersDelivered >= 1 and not camStates.door6Halt and SceneControl.currentLevel != 8:
		$CamVis / CamOverlays / OrderParty_A.visible = true
	if secretCam.val == 225:
		$CamVis / CamOverlays / partyAPostA.visible = true
	elif secretCam.val == 226:
		$CamVis / CamOverlays / partyAPostB.visible = true
	elif secretCam.val == 227:
		$CamVis / CamOverlays / partyAPostC.visible = true
	SetHuntText(1)

func _on_camSwitch7_pressed():
	SetSel(7)
	$CamVis.set_animation("cam7")
	emit_signal("get_room_state")
	$CamVis / CamButtons / CamSel.rect_position = Vector2($CamVis / CamButtons / Cam07.position.x + - 35, $CamVis / CamButtons / Cam07.position.y + - 35)
	$CamVis / CamName.text = "PARTY ROOM B"
	$CamVis / CamButtons / Cam07 / TextBox / CamDir.visible = true
	$CamVis / SecretCamButtons / FredButton.visible = true
	$CamVis / SecretCamButtons / BonButton.visible = true
	$CamVis / SecretCamButtons / FbButton.visible = true
	$CamVis / SecretCamButtons / SbButton.visible = true
	$CamVis / SecretCamButtons / FunButton.visible = true
	if camStates.door7:
		$CamVis / CamOverlays / doorCam7.visible = true
	if not orderCam2 or door7_Halt:
		if not toolDisconnect.door7 and not conveyorJam:
			$CamVis / CamToolButtons / Door7Button.visible = true
	else:
		$CamVis / CamToolButtons / ConfirmButton.visible = true
	if camStates.ordersDelivered >= 2 and not camStates.door7Halt and SceneControl.currentLevel != 8:
		$CamVis / CamOverlays / OrderParty_B.visible = true
	if secretCam.val == 455:
		$CamVis / CamOverlays / bonCut.visible = true
	elif secretCam.val == 456:
		$CamVis / CamOverlays / fredCut.visible = true
	elif secretCam.val == 457:
		$CamVis / CamOverlays / bonCut.visible = true
		$CamVis / CamOverlays / fredCut.visible = true
	SetHuntText(1)

func _on_camSwitch8_pressed():
	SetSel(8)
	$CamVis.set_animation("cam8")
	emit_signal("get_room_state")
	$CamVis / CamButtons / CamSel.rect_position = Vector2($CamVis / CamButtons / Cam08.position.x + - 35, $CamVis / CamButtons / Cam08.position.y + - 35)
	$CamVis / CamName.text = "CLOSET"
	$CamVis / CamButtons / Cam08 / TextBox / CamDir.visible = true
	$CamVis / SecretCamButtons / BroomButton.visible = true
	$CamVis / SecretCamButtons / BoogButton.visible = true
	$CamVis / SecretCamButtons / BoohooButton.visible = true
	if destinationsDelivered.closet:
		if orderConfirm and randomDestinations[ordersDelivered] == 11:
			$CamVis / CamRandButtons / randOrder5.visible = true
		else:
			SetHuntText(1)
		$CamVis / CamOverlays / BasketCloset.visible = true

func _on_camSwitch9_pressed():
	SetSel(9)
	$CamVis.set_animation("cam9")
	emit_signal("get_room_state")
	$CamVis / CamButtons / CamSel.rect_position = Vector2($CamVis / CamButtons / Cam09.position.x + - 35, $CamVis / CamButtons / Cam09.position.y + - 35)
	$CamVis / CamName.text = "BACK STAGE"
	#$CamVis / CamButtons / Cam09 / TextBox / CamDir.visible = true
	$CamVis / SecretCamButtons / MrfaceButton.visible = true
	$CamVis / SecretCamButtons / BiteyBackButton.visible = true
	$CamVis / SecretCamButtons / BiteyBackButton2.visible = true
	$CamVis / SecretCamButtons / AchooButton.visible = true
	$CamVis / SecretCamButtons / DoorDressButton.visible = true
	if not camBackup and (SceneControl.currentLevel >= 3 or SceneControl.currentLevel == 0):
		if not toolDisconnect.refresh:
			$CamVis / CamToolButtons / RefreshButton.visible = true
	$CamVis / CamOverlays / VidBox.visible = true
	if not camFroze:
		$CamVis / CamOverlays / VidBox / AnimationPlayer.play()
	if destinationsDelivered.backstage:
		if orderConfirm and randomDestinations[ordersDelivered] == 12:
			$CamVis / CamRandButtons / randOrder6.visible = true
		else:
			SetHuntText(1)
		$CamVis / CamOverlays / BasketBackstage.visible = true
	if camTbIncoming:
		$CamVis / CamOverlays / FbCams / AudioStreamPlayer3.play()
	if secretCam.val == 82 and not camFroze and not secretCam.foxAct:
		$CamVis / CamOverlays / DressDoor.visible = true

func _on_camSwitch10_pressed():
	SetSel(10)
	$CamVis.set_animation("cam_10")
	emit_signal("get_room_state")
	$CamVis / CamButtons / CamSel.rect_position = Vector2($CamVis / CamButtons / Cam10.position.x + - 35, $CamVis / CamButtons / Cam10.position.y + - 35)
	$CamVis / CamName.text = "VENT OUTLET"
	$CamVis / CamButtons / Cam10 / TextBox / CamDir.visible = true
	$CamVis / CamToolButtons / VentButton.visible = true
	if camStates.fanState > 0:
		if not camFroze:
			$CamVis / CamOverlays / VentFan.visible = true
		else:
			$CamVis / CamOverlays / VentFanFroze.visible = true
	$CamVis / VentMask.visible = true
	$CamVis / CamOver.modulate.a = 0.24
	$CamVis / CamOverlays / FbCams / AudioStreamPlayer2.volume_db = - 4
	$CamVis / ShockBlockRect1.visible = false
	SetHuntText(1)
	if SceneControl.currentLevel == 7:
		$CamVis / CamToolButtons / VentShockButton.visible = true

func SetSel( var num):
	$CamVis / CamButtons / CamSel / AnimationPlayer.stop()
	$CamVis / CamButtons / CamSel / AnimationPlayer.play("idle")
	
	match (currentCam):
		1:
			$CamVis / CamButtons / Cam01 / TextBox / CamDir.visible = false
			if destinationsDelivered.stage:
				$CamVis / CamRandButtons / randOrder1.visible = false
				$CamVis / CamOverlays / BasketStage.visible = false
		2:
			$CamVis / CamButtons / Cam02 / TextBox / CamDir.visible = false
			$CamVis / SecretCamButtons / CowmanButton.visible = false
			$CamVis / SecretCamButtons / BurgButton.visible = false
			$CamVis / SecretCamButtons / MouseyButton.visible = false
			$CamVis / SecretCamButtons / WeeButton.visible = false
			$CamVis / SecretCamButtons / OuuchButton.visible = false
			$CamVis / SecretCamButtons / HappyButton.visible = false
			if destinationsDelivered.dining:
				$CamVis / CamRandButtons / randOrder2.visible = false
				$CamVis / CamOverlays / BasketDining.visible = false
		3:
			$CamVis / CamButtons / Cam03 / TextBox / CamDir.visible = false
			if destinationsDelivered.lab:
				$CamVis / CamRandButtons / randOrder3.visible = false
				$CamVis / CamOverlays / BasketLab.visible = false
		4:
			$CamVis / CamButtons / Cam04 / TextBox / CamDir.visible = false
			if destinationsDelivered.hall:
				if $CamVis / CamOverlays / GoldenIdea.visible:
					$CamVis / CamOverlays / GoldenIdea.visible = false
				$CamVis / CamRandButtons / randOrder4.visible = false
				$CamVis / CamOverlays / BasketHall.visible = false
			if $CamVis / CamOverlays / GoldenIdea.visible:
				$CamVis / CamOverlays / GoldenIdea.visible = false
		5:
			$CamVis / CamButtons / Cam05 / TextBox / CamDir.visible = false
			if camStates.door5:
				$CamVis / CamOverlays / doorCam5.visible = false
			$CamVis / CamToolButtons / Door5Button.visible = false
			$CamVis / CamToolButtons / Door5Button.visible = false
			$CamVis / CamOverlays / ServiceSprite.visible = false
			$CamVis / CamOverlays / ManagerHat.visible = false
			$CamVis / CamOverlays / ManagerHat / AnimationPlayer.stop(false)
			$CamVis / CamOverlays / KitOrd1.visible = false
			$CamVis / CamOverlays / KitOrd2.visible = false
			$CamVis / CamOverlays / KitOrd3.visible = false
			$CamVis / CamOverlays / KitLevs.visible = false
			$CamVis / CamOverlays / KitOrdPanel.visible = false
			if serviceLight:
				$CamVis / CamOverlays / ServiceSprite / AudioStreamPlayer.volume_db = - 80
			if $CamVis / CamToolButtons / DisconnectButton.visible:
				$CamVis / CamToolButtons / DisconnectButton.visible = false
			$CamVis / AudioStreamPlayer3.volume_db = - 80
			$CamVis / AudioStreamPlayer4.volume_db = - 80
		6:
			$CamVis / CamButtons / Cam06 / TextBox / CamDir.visible = false
			if camStates.door6:
				$CamVis / CamOverlays / doorCam6.visible = false
			$CamVis / CamToolButtons / Door6Button.visible = false
			$CamVis / CamToolButtons / ConfirmButton.visible = false
			if ordersDelivered >= 1 and SceneControl.currentLevel != 8:
				$CamVis / CamOverlays / OrderParty_A.visible = false
			$CamVis / SecretCamButtons / Bon2Button.visible = false
			$CamVis / SecretCamButtons / Fred2Button.visible = false
			$CamVis / SecretCamButtons / Chic2Button.visible = false
			$CamVis / SecretCamButtons / Sb2Button.visible = false
			if $CamVis / CamToolButtons / DisconnectButton.visible:
				$CamVis / CamToolButtons / DisconnectButton.visible = false
			if $CamVis / CamOverlays / partyAPostA.visible:
				$CamVis / CamOverlays / partyAPostA.visible = false
			if $CamVis / CamOverlays / partyAPostB.visible:
				$CamVis / CamOverlays / partyAPostB.visible = false
			if $CamVis / CamOverlays / partyAPostC.visible:
				$CamVis / CamOverlays / partyAPostC.visible = false
		7:
			$CamVis / CamButtons / Cam07 / TextBox / CamDir.visible = false
			if camStates.door7:
				$CamVis / CamOverlays / doorCam7.visible = false
			$CamVis / CamToolButtons / Door7Button.visible = false
			$CamVis / CamToolButtons / ConfirmButton.visible = false
			if ordersDelivered >= 2 and SceneControl.currentLevel != 8:
				$CamVis / CamOverlays / OrderParty_B.visible = false
			$CamVis / SecretCamButtons / FredButton.visible = false
			$CamVis / SecretCamButtons / BonButton.visible = false
			$CamVis / SecretCamButtons / FbButton.visible = false
			$CamVis / SecretCamButtons / SbButton.visible = false
			$CamVis / SecretCamButtons / FunButton.visible = false
			if $CamVis / CamToolButtons / DisconnectButton.visible:
				$CamVis / CamToolButtons / DisconnectButton.visible = false
			if $CamVis / CamOverlays / bonCut.visible:
				$CamVis / CamOverlays / bonCut.visible = false
			if $CamVis / CamOverlays / fredCut.visible:
				$CamVis / CamOverlays / fredCut.visible = false
		8:
			$CamVis / CamButtons / Cam08 / TextBox / CamDir.visible = false
			$CamVis / SecretCamButtons / BroomButton.visible = false
			$CamVis / SecretCamButtons / BoogButton.visible = false
			$CamVis / SecretCamButtons / BoohooButton.visible = false
			if destinationsDelivered.closet:
				$CamVis / CamRandButtons / randOrder5.visible = false
				$CamVis / CamOverlays / BasketCloset.visible = false
		9:
			#$CamVis / CamButtons / Cam09 / TextBox / CamDir.visible = false
			$CamVis / CamToolButtons / RefreshButton.visible = false
			$CamVis / CamOverlays / WireBlow.visible = false
			$CamVis / CamOverlays / VidBox.visible = false
			$CamVis / CamOverlays / VidBox / AnimationPlayer.stop(false)
			$CamVis / SecretCamButtons / MrfaceButton.visible = false
			$CamVis / SecretCamButtons / BiteyBackButton.visible = false
			$CamVis / SecretCamButtons / BiteyBackButton2.visible = false
			$CamVis / SecretCamButtons / AchooButton.visible = false
			$CamVis / SecretCamButtons / DoorDressButton.visible = false
			if destinationsDelivered.backstage:
				$CamVis / CamRandButtons / randOrder6.visible = false
				$CamVis / CamOverlays / BasketBackstage.visible = false
			if $CamVis / CamToolButtons / DisconnectButton.visible:
				$CamVis / CamToolButtons / DisconnectButton.visible = false
			if $CamVis / CamOverlays / DressDoor.visible:
				$CamVis / CamOverlays / DressDoor.visible = false
			if $CamVis / CamOverlays / FbCams / AudioStreamPlayer3.playing:
				$CamVis / CamOverlays / FbCams / AudioStreamPlayer3.stop()
		10:
			$CamVis / CamButtons / Cam10 / TextBox / CamDir.visible = false
			$CamVis / CamToolButtons / VentButton.visible = false
			$CamVis / CamOverlays / VentFan.visible = false
			$CamVis / CamOverlays / VentFanFroze.visible = false
			$CamVis / VentMask.visible = false
			$CamVis / CamOver.modulate.a = 0.63
			if $CamVis / CamOverlays / FbCams / AudioStreamPlayer2.playing:
				$CamVis / CamOverlays / FbCams / AudioStreamPlayer2.volume_db = - 16
			if SceneControl.currentLevel == 7:
				$CamVis / CamToolButtons / VentShockButton.visible = false
	
	currentCam = num
	secretCam.val = randCam.randi_range(0, 1500)
	
	SetHuntText(0)
	$CamVis / Blipy / AnimationPlayer.stop()
	$CamVis / Blipy / AnimationPlayer.play("bliping")
	$CamVis / CamButtons / AudioStreamPlayer.play()

func LockButtonInputs( var lock):
	if lock:
		lockButtons = true
		$CamVis / CamToolButtons.visible = false
	else:
		lockButtons = false
		$CamVis / CamToolButtons.visible = true

func _on_Door5Button_pressed():
	if not door_5:
		$CamVis / CamButtons / Cam05 / CamDoor.visible = true
		if not camFroze:
			$CamVis / CamOverlays / doorCam5.play("close")
			$CamVis / CamOverlays / doorCam5.visible = true
		$CamVis / CamToolButtons / Door5Button / DoorLab.text = "DISABLE\nDOOR"
		$CamVis / CamToolButtons / AudioStreamPlayer2.play()
		emit_signal("device_on", 2)
		door_5 = not door_5
		TimeoutButton(3)
	else:
		$CamVis / CamButtons / Cam05 / CamDoor.visible = false
		if not camFroze:
			$CamVis / CamOverlays / doorCam5.play("open")
		$CamVis / CamToolButtons / Door5Button / DoorLab.text = "ENABLE\nDOOR"
		$CamVis / CamToolButtons / AudioStreamPlayer3.play()
		emit_signal("device_on", - 2)
		door_5 = not door_5
		TimeoutButton(3)
	if not camFroze:
		doorBlock_Time = 0
		camStates.door5 = door_5

func _on_Door6Button_pressed():
	if not door_6:
		$CamVis / CamButtons / Cam06 / CamDoor.visible = true
		if not camFroze:
			$CamVis / CamOverlays / doorCam6.play("close")
			$CamVis / CamOverlays / doorCam6.visible = true
			$CamVis / CamOverlays / OrderParty_A.modulate = Color(1, 0.54, 0.42, 1)
		$CamVis / CamToolButtons / Door6Button / DoorLab.text = "DISABLE\nDOOR"
		$CamVis / CamToolButtons / AudioStreamPlayer2.play()
		emit_signal("device_on", 2)
		door_6 = not door_6
		TimeoutButton(1)
	else:
		$CamVis / CamButtons / Cam06 / CamDoor.visible = false
		if not camFroze:
			$CamVis / CamOverlays / doorCam6.play("open")
			$CamVis / CamOverlays / OrderParty_A.modulate = Color(1, 1, 1, 1)
		$CamVis / CamToolButtons / Door6Button / DoorLab.text = "ENABLE\nDOOR"
		$CamVis / CamToolButtons / AudioStreamPlayer3.play()
		emit_signal("device_on", - 2)
		door_6 = not door_6
		TimeoutButton(1)
		if door6_Halt:
			UpdateOrderCam(1)
			door6_Halt = false
			if not camFroze:
				camStates.door6Halt = door6_Halt
	if not camFroze:
		doorBlock_Time = 0
		camStates.door6 = door_6

func _on_Door7Button_pressed():
	if not door_7:
		$CamVis / CamButtons / Cam07 / CamDoor.visible = true
		if not camFroze:
			$CamVis / CamOverlays / doorCam7.play("close")
			$CamVis / CamOverlays / doorCam7.visible = true
			$CamVis / CamOverlays / OrderParty_B.modulate = Color(1, 0.54, 0.42, 1)
		$CamVis / CamToolButtons / Door7Button / DoorLab.text = "DISABLE\nDOOR"
		$CamVis / CamToolButtons / AudioStreamPlayer2.play()
		emit_signal("device_on", 2)
		door_7 = not door_7
		TimeoutButton(2)
	else:
		$CamVis / CamButtons / Cam07 / CamDoor.visible = false
		if not camFroze:
			$CamVis / CamOverlays / doorCam7.play("open")
			$CamVis / CamOverlays / OrderParty_B.modulate = Color(1, 1, 1, 1)
		$CamVis / CamToolButtons / Door7Button / DoorLab.text = "ENABLE\nDOOR"
		$CamVis / CamToolButtons / AudioStreamPlayer3.play()
		emit_signal("device_on", - 2)
		door_7 = not door_7
		TimeoutButton(2)
		if door7_Halt:
			UpdateOrderCam(2)
			door7_Halt = false
			if not camFroze:
				camStates.door7Halt = door7_Halt
	if not camFroze:
		doorBlock_Time = 0
		camStates.door7 = door_7

func _on_ServiceButton_pressed():
	if not serviceLight:
		serviceLight = true
		emit_signal("device_on", 2)
		$CamVis / CamToolButtons / ServiceButton.modulate = Color(1, 1, 1, 0.25)
		if not camFroze:
			$CamVis / CamOverlays / ServiceSprite / AnimationPlayer.play("ServiceLightOn")
		$CamVis / CamOverlays / ServiceSprite / AudioStreamPlayer.play()
		$CamVis / CamOverlays / ServiceSprite / AudioStreamPlayer.volume_db = - 2
		$CamVis / CamToolButtons / ServiceButton / DoorLab.text = "DISABLE\nLIGHT"
		$CamVis / CamButtons / Cam05 / CamDoor.visible = true
		TimeoutButton(3)
		print("Service light on")
	else:
		$CamVis / CamToolButtons / ServiceButton / DoorLab.text = "ENABLE\nLIGHT"
		StopServiceButton()
		TimeoutButton(3)

func _on_ServiceButton_button_up():
	pass

func StopServiceButton():
	serviceLight = false
	emit_signal("device_on", - 2)
	$CamVis / CamToolButtons / ServiceButton.modulate = Color(1, 1, 1, 1)
	if not camFroze:
		$CamVis / CamOverlays / ServiceSprite / AnimationPlayer.play("ServiceLightOff")
	else:
		$CamVis / CamOverlays / ServiceSprite / AudioStreamPlayer.stop()
	$CamVis / CamButtons / Cam05 / CamDoor.visible = false
	print("Service light off")

func CamFreeze():
	camFroze = true
	$CamVis / static1.playing = false
	$CamVis / static1 / AnimationPlayer.stop(false)
	$CamVis / LinesBuffer / scanline1 / AnimationPlayer.stop(false)
	$CamVis / LinesBuffer / scanline2 / AnimationPlayer.stop(false)
	$CamVis / LinesBuffer / scanline3 / AnimationPlayer.stop(false)
	$CamVis / StaticShad.material.set_shader_param("speed", 0)
	$CamVis / ScanlinesBuffer / camTv.material.set_shader_param("movement", 0)
	$CamVis / CamDot.visible = false
	$CamVis / CamButtons / Cam09 / WarnFroze.visible = true
	$CamVis / CamButtons / Cam09 / WarnFroze.play("default")
	if SceneControl.currentLevel != 9:
		$CamVis / CamRec.text = "CAMERAS FROZEN"
		$CamVis / CamRec.modulate = Color(1, 0, 0, 0.69)
		$CamVis / CamToolButtons / RefreshButton / RefreshLab.text = "ENABLE\nBACKUP"
		if currentCam == 9:
			$CamVis / CamOverlays / WireBlow.visible = true
			$CamVis / CamToolButtons / RefreshButton.visible = true
	else:
		$CamVis / CamRec.text = "CAMERAS FROZEN"
		$CamVis / CamRec.modulate = Color(0, 0.8, 1, 0.69)
	$CamVis / CamRec.rect_position.x = - 917
	$CamVis / CamOverlays / VentFan.visible = false
	$CamVis / CamOverlays / ManagerHat / AnimationPlayer.stop(false)
	if fan.state > 0:
		$CamVis / CamOverlays / VentFanFroze.animation = $CamVis / CamOverlays / VentFan.animation
		$CamVis / CamOverlays / VentFanFroze.frame = $CamVis / CamOverlays / VentFan.frame
		$CamVis / CamOverlays / VentFanFroze.stop()
		if currentCam == 10:
			$CamVis / CamOverlays / VentFanFroze.visible = true
			$CamVis / CamOverlays / VentFan.visible = false
	$CamVis / CamOverlays / VidBox / AnimationPlayer.stop(false)

func CamUnfreeze():
	camFroze = false
	$CamVis / static1.playing = true
	$CamVis / static1 / AnimationPlayer.play()
	$CamVis / LinesBuffer / scanline1 / AnimationPlayer.play()
	$CamVis / LinesBuffer / scanline2 / AnimationPlayer.play()
	$CamVis / LinesBuffer / scanline3 / AnimationPlayer.play()
	$CamVis / StaticShad.material.set_shader_param("speed", 2)
	$CamVis / ScanlinesBuffer / camTv.material.set_shader_param("movement", 6)
	$CamVis / CamDot.visible = true
	$CamVis / CamButtons / Cam09 / WarnFroze.visible = false
	$CamVis / CamButtons / Cam09 / WarnFroze.stop()
	if SceneControl.currentLevel != 9:
		$CamVis / CamRec.text = "REC - BACKUP"
		$CamVis / CamRec.rect_position.x = - 865
		$CamVis / CamRec.modulate = Color(1, 0.52, 0, 0.69)
		$CamVis / CamToolButtons / RefreshButton.visible = false
		$CamVis / CamButtons / Cam09 / CamDoor.visible = true
	else:
		$CamVis / CamRec.text = "REC"
		$CamVis / CamRec.modulate = Color(1, 1, 1, 0.69)
	$CamVis / CamToolButtons.visible = true
	$CamVis / CamRec.rect_position.x = - 865
	$CamVis / CamOverlays / VentFanFroze.visible = false
	$CamVis / CamOverlays / WireBlow.visible = false
	$CamVis / CamOverlays / ServiceSprite / AnimationPlayer.play("RESET")
	emit_signal("cam_reload")
	camStates.door5 = door_5
	camStates.door6 = door_6
	camStates.door7 = door_7
	camStates.ordersDelivered = ordersDelivered
	camStates.fanState = fan.state
	camStates.kitState = kitOrderState
	camStates.door6Halt = door6_Halt
	camStates.door7Halt = door7_Halt
	
	UpdateKitState()
	
	if door_6:
		$CamVis / CamOverlays / OrderParty_A.modulate = Color(1, 0.54, 0.42, 1)
	else:
		$CamVis / CamOverlays / OrderParty_A.modulate = Color(1, 1, 1, 1)
	if door_7:
		$CamVis / CamOverlays / OrderParty_B.modulate = Color(1, 0.54, 0.42, 1)
	else:
		$CamVis / CamOverlays / OrderParty_B.modulate = Color(1, 1, 1, 1)
	if SceneControl.currentLevel == 10:
		if ordersDelivered >= 2:
			$CamVis / CamOverlays / OrderParty_A / OrderParty_A2.visible = true
		if ordersDelivered >= 4:
			$CamVis / CamOverlays / OrderParty_A / OrderParty_A3.visible = true
		if ordersDelivered >= 3:
			$CamVis / CamOverlays / OrderParty_B / OrderParty_B2.visible = true
		if ordersDelivered >= 5:
			$CamVis / CamOverlays / OrderParty_B / OrderParty_B3.visible = true
	$CamVis / CamOverlays / VidBox / AnimationPlayer.play()

func UpdateOrderCam( var orderNum):
	match (orderNum):
		1:
			orderCam1 = true
			$CamVis / CamButtons / Cam06 / CamDoor.texture = load("res://Sprites/Cameras/orderDot.png")
			$CamVis / CamButtons / Cam06 / CamDoor.visible = true
			ordersDelivered += 1
			if not door_6:
				$AudioStreamPlayer2D7.stop()
				if currentCam == 6:
					$CamVis / CamToolButtons / ConfirmButton.visible = true
					$CamVis / CamToolButtons / Door6Button.visible = false
					if not camFroze:
						$CamVis / CamOverlays / OrderParty_A.visible = true
						if SceneControl.currentLevel == 10:
							if ordersDelivered >= 2:
								$CamVis / CamOverlays / OrderParty_A / OrderParty_A2.visible = true
							if ordersDelivered >= 4:
								$CamVis / CamOverlays / OrderParty_A / OrderParty_A3.visible = true
						doorBlock_Time = 0
						$CamVis / BlockCam3.visible = true
						if camActive:
							$CamVis / static1 / AudioStreamPlayer.play()
				else:
					if not camFroze:
						if SceneControl.currentLevel == 10:
							if ordersDelivered >= 2:
								$CamVis / CamOverlays / OrderParty_A / OrderParty_A2.visible = true
							if ordersDelivered >= 4:
								$CamVis / CamOverlays / OrderParty_A / OrderParty_A3.visible = true
			else:
				door6_Halt = true
				if not camFroze:
					camStates.door6Halt = door6_Halt
				$AudioStreamPlayer2D7.play()
				print("Order witheld!")
			if not camFroze:
				camStates.ordersDelivered = ordersDelivered
		2:
			orderCam2 = true
			$CamVis / CamButtons / Cam07 / CamDoor.texture = load("res://Sprites/Cameras/orderDot.png")
			$CamVis / CamButtons / Cam07 / CamDoor.visible = true
			ordersDelivered += 1
			if not door_7:
				$AudioStreamPlayer2D7.stop()
				if currentCam == 7:
					$CamVis / CamToolButtons / ConfirmButton.visible = true
					$CamVis / CamToolButtons / Door7Button.visible = false
					if not camFroze:
						$CamVis / CamOverlays / OrderParty_B.visible = true
						if SceneControl.currentLevel == 10:
							if ordersDelivered >= 3:
								$CamVis / CamOverlays / OrderParty_B / OrderParty_B2.visible = true
							if ordersDelivered >= 5:
								$CamVis / CamOverlays / OrderParty_B / OrderParty_B3.visible = true
						doorBlock_Time = 0
						$CamVis / BlockCam3.visible = true
						if camActive:
							$CamVis / static1 / AudioStreamPlayer.play()
				else:
					if not camFroze:
						if SceneControl.currentLevel == 10:
							if ordersDelivered >= 3:
								$CamVis / CamOverlays / OrderParty_B / OrderParty_B2.visible = true
							if ordersDelivered >= 5:
								$CamVis / CamOverlays / OrderParty_B / OrderParty_B3.visible = true
			else:
				door7_Halt = true
				if not camFroze:
					camStates.door7Halt = door7_Halt
				$AudioStreamPlayer2D7.play()
				print("Order witheld!")
			if not camFroze:
				camStates.ordersDelivered = ordersDelivered
		3:
			$CamVis / CamButtons / orderDot3.visible = true
		4:
			
			orderCam1 = false
			orderCam2 = false
			ordersDelivered = 0
			camStates.ordersDelivered = 0
			$CamVis / CamOverlays / OrderParty_A.visible = false
			$CamVis / CamOverlays / OrderParty_B.visible = false
			$CamVis / CamButtons / orderDot3.visible = false
			kitOrderState = 0
			camStates.kitState = 0
			$CamVis / CamButtons / Cam10.visible = true
			if currentCam == 5:
				$CamVis / CamOverlays / KitOrd1.visible = false
				$CamVis / CamOverlays / KitOrd2.visible = false
				$CamVis / CamOverlays / KitOrd3.visible = false
				$CamVis / CamOverlays / KitLevs.play("default")
			camStates.fanState = 0
			if door5_Time >= 0:
				door5_Time = 2
			if door6_Time >= 0:
				door6_Time = 2
			if door7_Time >= 0:
				door7_Time = 2
			if service_Time >= 0:
				service_Time = 2
			$AudioStreamPlayer2D7.stop()
			if doorBlock_Time >= 0:
				doorBlock_Time = 1
			camRef = false
			refTime = - 1
		5:
			
			kitOrderState += 1
			UpdateKitState()
		6:
			
			$AudioStreamPlayer2D7.stop()
			if currentCam == (randomDestinations[ordersDelivered] - 3):
				match (currentCam):
					1:
						$CamVis / CamRandButtons / randOrder1.visible = true
						$CamVis / CamOverlays / BasketStage.visible = true
					2:
						$CamVis / CamRandButtons / randOrder2.visible = true
						$CamVis / CamOverlays / BasketDining.visible = true
					3:
						$CamVis / CamRandButtons / randOrder3.visible = true
						$CamVis / CamOverlays / BasketLab.visible = true
					4:
						$CamVis / CamRandButtons / randOrder4.visible = true
						$CamVis / CamOverlays / BasketHall.visible = true
					8:
						$CamVis / CamRandButtons / randOrder5.visible = true
						$CamVis / CamOverlays / BasketCloset.visible = true
					9:
						$CamVis / CamRandButtons / randOrder6.visible = true
						$CamVis / CamOverlays / BasketBackstage.visible = true
				if not camFroze:
					doorBlock_Time = 0
					$CamVis / BlockCam3.visible = true
					if camActive:
						$CamVis / static1 / AudioStreamPlayer.play()
			match (randomDestinations[ordersDelivered] - 3):
					1:
						destinationsDelivered.stage = true
						
					2:
						destinationsDelivered.dining = true
						
					3:
						destinationsDelivered.lab = true
						
					4:
						destinationsDelivered.hall = true
						
					8:
						destinationsDelivered.closet = true
						
					9:
						destinationsDelivered.backstage = true
						
			
			if not camFroze:
				camStates.ordersDelivered = ordersDelivered
			orderConfirm = true
			$CamVis / CamHunt.visible = true
	
	if orderNum != 5:
		if ((orderCam1 or orderCam2) or (orderNum == 6)) and not camActive:
			$Area2D / camhit / AnimationPlayer.play("OrderUp")

func UpdateKitState():
	
	if not camFroze:
		camStates.kitState = kitOrderState
		if SceneControl.currentLevel == 10:
			
			if camStates.kitState > 18:
				$CamVis / CamOverlays / KitLevs.play("lev3")
			elif camStates.kitState > 15:
				$CamVis / CamOverlays / KitLevs.play("lev2")
			elif camStates.kitState > 12:
				$CamVis / CamOverlays / KitLevs.play("lev1")
			elif camStates.kitState > 9:
				$CamVis / CamOverlays / KitLevs.play("lev2")
			elif camStates.kitState > 6:
				$CamVis / CamOverlays / KitLevs.play("lev1")
			elif camStates.kitState > 3:
				$CamVis / CamOverlays / KitLevs.play("lev2")
			elif camStates.kitState > 0:
				$CamVis / CamOverlays / KitLevs.play("lev1")
			if camActive and currentCam == 5:
				if ((camStates.kitState - 1) % 3) == 0:
					doorBlock_Time = 0
					$CamVis / BlockCam3.visible = true
					$CamVis / static1 / AudioStreamPlayer.play()
			if camStates.kitState > 0:
				$CamVis / CamOverlays / KitOrd1 / KitOrd5.visible = false
			if camStates.kitState > 3:
				$CamVis / CamOverlays / KitOrd1 / KitOrd4.visible = false
			if camStates.kitState > 6:
				$CamVis / CamOverlays / KitOrd1.visible = false
			if camStates.kitState > 9:
				$CamVis / CamOverlays / KitOrd2 / KitOrd5.visible = false
			if camStates.kitState > 12:
				$CamVis / CamOverlays / KitOrd2 / KitOrd4.visible = false
			if camStates.kitState > 15:
				$CamVis / CamOverlays / KitOrd2.visible = false
			if camStates.kitState > 18:
				$CamVis / CamOverlays / KitOrd3.visible = false
		elif SceneControl.currentLevel == 8:
			
			if camStates.kitState > 12:
				$CamVis / CamOverlays / KitLevs.play("lev3")
			elif camStates.kitState > 9:
				$CamVis / CamOverlays / KitLevs.play("lev2")
			elif camStates.kitState > 6:
				$CamVis / CamOverlays / KitLevs.play("lev1")
			elif camStates.kitState > 3:
				$CamVis / CamOverlays / KitLevs.play("lev2")
			elif camStates.kitState > 0:
				$CamVis / CamOverlays / KitLevs.play("lev1")
			if camActive and currentCam == 5:
				if ((camStates.kitState - 1) % 3) == 0:
					doorBlock_Time = 0
					$CamVis / BlockCam3.visible = true
					$CamVis / static1 / AudioStreamPlayer.play()
			if camStates.kitState > 0:
				$CamVis / CamOverlays / KitOrd1 / KitOrd4.visible = false
			if camStates.kitState > 3:
				$CamVis / CamOverlays / KitOrd1.visible = false
			if camStates.kitState > 6:
				$CamVis / CamOverlays / KitOrd2 / KitOrd4.visible = false
			if camStates.kitState > 9:
				$CamVis / CamOverlays / KitOrd2.visible = false
			if camStates.kitState > 12:
				$CamVis / CamOverlays / KitOrd3.visible = false
		else:
			
			if camStates.kitState > 6:
				$CamVis / CamOverlays / KitLevs.play("lev3")
			elif camStates.kitState > 3:
				$CamVis / CamOverlays / KitLevs.play("lev2")
			elif camStates.kitState > 0:
				$CamVis / CamOverlays / KitLevs.play("lev1")
			if camActive and currentCam == 5:
				if ((camStates.kitState - 1) % 3) == 0:
					doorBlock_Time = 0
					$CamVis / BlockCam3.visible = true
					$CamVis / static1 / AudioStreamPlayer.play()
				if camStates.kitState > 0:
					$CamVis / CamOverlays / KitOrd1.visible = false
				if camStates.kitState > 3:
					$CamVis / CamOverlays / KitOrd2.visible = false
				if camStates.kitState > 6:
					$CamVis / CamOverlays / KitOrd3.visible = false
		
		if (camStates.kitState % 3) == 0:
				$CamVis / CamOverlays / KitOrdPanel.play("default")
		elif ((camStates.kitState - 1) % 3) == 0:
			$CamVis / CamOverlays / KitOrdPanel.play("pan2")
		else:
			$CamVis / CamOverlays / KitOrdPanel.play("pan3")

func TimeoutButton( var which):
	if which == 1:
		$CamVis / CamToolButtons / Door6Button.modulate = Color(1, 1, 1, 0.25)
		$CamVis / CamToolButtons / Door6Button.disabled = true
		door6_Time = 0
	elif which == 2:
		$CamVis / CamToolButtons / Door7Button.modulate = Color(1, 1, 1, 0.25)
		$CamVis / CamToolButtons / Door7Button.disabled = true
		door7_Time = 0
	elif which == 3:
		
		
		
		$CamVis / CamToolButtons / Door5Button.modulate = Color(1, 1, 1, 0.25)
		$CamVis / CamToolButtons / Door5Button.disabled = true
		door5_Time = 0

func DropCamCheck():
	
	if camActive or ( not camActive and $MonitorAnim.visible):
		$MonitorAnim.play("close")
		$CamVis.visible = false
		emit_signal("disable_bend", false)
		mouseInside = true
		camStop = true
		animStop = false
	else:
		pass
	lockCam = true
	$Area2D / camhit.visible = false

func _on_VentFan_animation_finished():
	if fan.state == 1:
		$CamVis / CamOverlays / VentFan.play("default")
		UpdateFanState()
		print("Drop end")
	elif fan.state == 3:
		$CamVis / CamOverlays / VentFan.stop()
		UpdateFanState()
		print("Lift end")


func _on_FredButton_pressed():
	if not $CamVis / SecretCamButtons / FredButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / FredButton / AudioStreamPlayer.play()

func _on_BonButton_pressed():
	if not $CamVis / SecretCamButtons / BonButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / BonButton / AudioStreamPlayer.play()

func _on_MrfaceButton_pressed():
	if not $CamVis / SecretCamButtons / MrfaceButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / MrfaceButton / AudioStreamPlayer.play()

func _on_BiteyBackButton_pressed():
	if not $CamVis / SecretCamButtons / BiteyBackButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / BiteyBackButton / AudioStreamPlayer.play()

func _on_BiteyBackButton2_pressed():
	if not $CamVis / SecretCamButtons / BiteyBackButton2 / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / BiteyBackButton2 / AudioStreamPlayer.play()

func _on_AchooButton_pressed():
	if not $CamVis / SecretCamButtons / AchooButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / AchooButton / AudioStreamPlayer.play()

func _on_DoorDressButton_pressed():
	if secretCam.val != 82:
		if not $CamVis / SecretCamButtons / DoorDressButton / AudioStreamPlayer.playing and not $CamVis / SecretCamButtons / DoorDressButton / AudioStreamPlayer3.playing:
			if secretCam.doorKnock == 2:
				$CamVis / SecretCamButtons / DoorDressButton / AudioStreamPlayer3.play()
				secretCam.doorKnock = 0
			else:
				secretCam.doorKnock += 1
				$CamVis / SecretCamButtons / DoorDressButton / AudioStreamPlayer.play()
	else:
		if not $CamVis / SecretCamButtons / DoorDressButton / AudioStreamPlayer2.playing:
			$CamVis / SecretCamButtons / DoorDressButton / AudioStreamPlayer2.play()

func _on_FbButton_pressed():
	if not $CamVis / SecretCamButtons / FbButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / FbButton / AudioStreamPlayer.play()

func _on_SbButton_pressed():
	if not $CamVis / SecretCamButtons / SbButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / SbButton / AudioStreamPlayer.play()

func _on_FunButton_pressed():
	if not $CamVis / SecretCamButtons / FunButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / FunButton / AudioStreamPlayer.play()

func _on_Bon2Button_pressed():
	if secretCam.val != 227:
		if not $CamVis / SecretCamButtons / Bon2Button / AudioStreamPlayer.playing:
			$CamVis / SecretCamButtons / Bon2Button / AudioStreamPlayer.play()
	else:
		if not $CamVis / SecretCamButtons / Bon2Button / AudioStreamPlayer2.playing:
			$CamVis / SecretCamButtons / Bon2Button / AudioStreamPlayer2.play()

func _on_Fred2Button_pressed():
	if secretCam.val != 226:
		if not $CamVis / SecretCamButtons / Fred2Button / AudioStreamPlayer.playing:
			$CamVis / SecretCamButtons / Fred2Button / AudioStreamPlayer.play()
	else:
		if not $CamVis / SecretCamButtons / Fred2Button / AudioStreamPlayer2.playing:
			$CamVis / SecretCamButtons / Fred2Button / AudioStreamPlayer2.play()

func _on_Chic2Button_pressed():
	if secretCam.val != 225:
		if not $CamVis / SecretCamButtons / Chic2Button / AudioStreamPlayer.playing:
			$CamVis / SecretCamButtons / Chic2Button / AudioStreamPlayer.play()
	else:
		if not $CamVis / SecretCamButtons / Chic2Button / AudioStreamPlayer2.playing:
			$CamVis / SecretCamButtons / Chic2Button / AudioStreamPlayer2.play()

func _on_Sb2Button_pressed():
	if not $CamVis / SecretCamButtons / Sb2Button / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / Sb2Button / AudioStreamPlayer.play()

func _on_BroomButton_pressed():
	if not $CamVis / SecretCamButtons / BroomButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / BroomButton / AudioStreamPlayer.play()

func _on_CowmanButton_pressed():
	pass

func _on_BurgButton_pressed():
	if not $CamVis / SecretCamButtons / BurgButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / BurgButton / AudioStreamPlayer.play()

func _on_MouseyButton_pressed():
	pass

func _on_WeeButton_pressed():
	if not $CamVis / SecretCamButtons / WeeButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / WeeButton / AudioStreamPlayer.play()

func _on_OuuchButton_pressed():
	if not $CamVis / SecretCamButtons / OuuchButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / OuuchButton / AudioStreamPlayer.play()

func _on_HappyButton_pressed():
	if not $CamVis / SecretCamButtons / HappyButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / HappyButton / AudioStreamPlayer.play()

func _on_BoogButton_pressed():
	if not $CamVis / SecretCamButtons / BoogButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / BoogButton / AudioStreamPlayer.play()

func _on_BoohooButton_pressed():
	if not $CamVis / SecretCamButtons / BoohooButton / AudioStreamPlayer.playing:
		$CamVis / SecretCamButtons / BoohooButton / AudioStreamPlayer.play()

func _on_doorCam5_animation_finished():
	if $CamVis / CamOverlays / doorCam5.animation == "close":
		$CamVis / CamOverlays / doorCam5.play("default")
	elif $CamVis / CamOverlays / doorCam5.animation == "open":
		$CamVis / CamOverlays / doorCam5.visible = false

func _on_doorCam6_animation_finished():
	if $CamVis / CamOverlays / doorCam6.animation == "close":
		$CamVis / CamOverlays / doorCam6.play("default")
	elif $CamVis / CamOverlays / doorCam6.animation == "open":
		$CamVis / CamOverlays / doorCam6.visible = false

func _on_doorCam7_animation_finished():
	if $CamVis / CamOverlays / doorCam7.animation == "close":
		$CamVis / CamOverlays / doorCam7.play("default")
	elif $CamVis / CamOverlays / doorCam7.animation == "open":
		$CamVis / CamOverlays / doorCam7.visible = false

func _on_DisconnectButton_pressed():
	if currentCam == 5:
		toolDisconnect.service = true
		$CamVis / CamToolButtons / ServiceButton.visible = false
		if serviceLight:
			_on_ServiceButton_pressed()
		print("Disconnecting service light")
	elif currentCam == 6:
		toolDisconnect.door6 = true
		$CamVis / CamToolButtons / Door6Button.visible = false
		if door_6:
			_on_Door6Button_pressed()
		print("Disconnecting door 6")
	elif currentCam == 7:
		toolDisconnect.door7 = true
		$CamVis / CamToolButtons / Door7Button.visible = false
		if door_7:
			_on_Door6Button_pressed()
		print("Disconnecting door 7")
	elif currentCam == 9:
		toolDisconnect.refresh = true
		$CamVis / CamToolButtons / RefreshButton.visible = false
		print("Disabling refresh & backup")
	emit_signal("disconnect_tool")
	$CamVis / CamToolButtons / DisconnectButton.visible = false
	$CamVis / CamToolButtons / AudioStreamPlayer.play()

func CamIced():
	CamFreeze()

func SetHuntText( var which):
	if which == 0:
		$CamVis / CamHunt.text = "UNKNOWN DESTINATION ( ? )"
		$CamVis / CamHunt.modulate.a = 1.0
		$CamVis / OrderLab.modulate.a = 1.0
	else:
		$CamVis / CamHunt.text = "UNKNOWN DESTINATION ( X )"
		$CamVis / CamHunt.modulate.a = 0.25
		$CamVis / OrderLab.modulate.a = 0.25

func _on_VentShockButton_pressed():
	emit_signal("vent_shock")
