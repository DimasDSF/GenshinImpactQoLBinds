#SingleInstance force
#MaxHotkeysPerInterval 50000
#MaxThreadsPerHotkey 1
SetBatchLines -1
SetMouseDelay, 5
SetStoreCapsLockMode, Off
CoordMode, Mouse, Screen

full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

global debug := 0

if (!debug)
{
	Progress,, By Viper, GIRebind Loading
	Loop, 100
	{
		Progress, %A_Index%
		Sleep, 15
	}
	Sleep, 1000
	Progress, Off
}

Random(minimum, maximum)
{
	Random, val, minimum, maximum
	return val
}

IsCursorVisible()
{
   StructSize := A_PtrSize + 16
   VarSetCapacity(InfoStruct, StructSize)
   NumPut(StructSize, InfoStruct)
   DllCall("GetCursorInfo", UInt, &InfoStruct)
   Result := NumGet(InfoStruct, 8)

   if Result != 0
      return 1
   else
      return 0
}

ValueInArray(value, arr)
{
	cindex := 0
	Loop % arr.Length()
	{
		cindex++
		if (arr[cindex] == value)
			return true
	}
	return false
}

PassChecks(windowcheck:=1, cursorcheck:="NOTSET", notinchatcheck:=1)
{
	if (cursorcheck = "NOTSET")
		cursorcheck:=[1, 1]
	if (windowcheck && !WinActive("ahk_class UnityWndClass")) ;ahk_exe GenshinImpact.exe
	{
		return 0
	}
	if (cursorcheck[1] && IsCursorVisible() != cursorcheck[2])
	{
		return 0
	}
	if (notinchatcheck)
	{
		ImageSearch, FoundX, FoundY, 860, 960, 1000, 1100, *50, *Trans0xFF0000 GenshinControlHints\ChatCheck.png
		if (ErrorLevel = 0)
		{
			return 0
		}
	}
	return 1
}

ClickAndReturn(x, y, shouldreturn:=true, precise:=false)
{
	MouseGetPos, startxpos, startypos
	if (precise)
		MouseMove, x, y, Random(3.0, 5.0)
	else
		MouseMove, x+Random(-5, 5), y+Random(-5, 5), Random(3.0, 5.0)
	Click
	if shouldreturn
	{
		Sleep, 200
		MouseMove, startxpos+Random(-10, 10), startypos+Random(-10, 10), Random(3.0, 5.0)
	}
	return
}

DevRect(x, y, xe, ye, col:="EB2B2B", transp:=80) {
	static n := 0
	n++
	w := xe - x
	h := ye - y
	Gui, devrect%n%:-Caption +E0x20 +AlwaysOnTop +ToolWindow
	Gui, devrect%n%:Color, %col%
	Gui +LastFound
	Gui, devrect%n%:Show, NA x%x% y%y% w%w% h%h%, devrect%n%
	WinSet, Transparent, %transp%, devrect%n%
	return n
}

DestroyDevRect(n) {
	Gui, devrect%n%:Destroy
}

DevText(x, y, DText:="", col:="FFFFFF", outlinecol:="000000", size:=20) {
	static tn := 0
	tn++
	Gui, devtext%tn%:-Caption +E0x20 +AlwaysOnTop +ToolWindow
	Gui, devtext%tn%:Color, 808000
	;Gui, devtext%tn%:Font, s%size%, Arial
	Gui, devtext%tn%:Font, s%size%
	; Outline
	Gui, devtext%tn%:Add, Text, xm ym c%outlinecol% BackgroundTrans, %DText%
	Gui, devtext%tn%:Add, Text, xm ym+4 c%outlinecol% BackgroundTrans, %DText%
	Gui, devtext%tn%:Add, Text, xm+4 ym c%outlinecol% BackgroundTrans, %DText%
	Gui, devtext%tn%:Add, Text, xm+4 ym+4 c%outlinecol% BackgroundTrans, %DText%
	Gui, devtext%tn%:Add, Text, xm+2 ym+2 c%col% BackgroundTrans, %DText%
	Gui +LastFound
	Gui, devtext%tn%:Show, NA x%x% y%y%, devtext%tn%
	GuiControl +BackgroundTrans, devtext%tn%
	WinSet, TransColor, 808000, devtext%tn%
	return tn
}

DestroyDevText(n) {
	Gui, devtext%n%:Destroy
}

*XButton2::
{
	Send {MButton down}
	KeyWait, XButton2
	Send {MButton up}
}
return

;Teapot Furniture Collision Skip
*XButton1::
{
	if !PassChecks()
		return
	ImageSearch, FoundX, FoundY, 0, 0, 150, 150, *50, *Trans0xFF0000 GenshinControlHints\TeapotBuildingSettings.png
	if (ErrorLevel != 0)
		return
	MouseGetPos, startxpos, startypos
	Click, down
	While (GetKeyState("XButton1", "P"))
	{
		MouseMove, Random(0, A_ScreenWidth), Random(0, A_ScreenHeight), 0.01
	}
	Sleep, 10
	MouseMove, startxpos+Random(-1.0, 1.0), startypos+Random(-1.0, 1.0), 0.1
	Sleep, 50
	Click, up
	return
}

~f::
{
	if !PassChecks(true, [true, false])
		return
	KeyWait, f, T0.2
	if (ErrorLevel = 1)
	{
		Loop
		{
			if not GetKeyState("f", "P")
				break
			Send {f down}
			Send {f up}
			Click, WheelDown
			Sleep, 15
			Send {f down}
			Send {f up}
			Click, WheelUp
			Sleep, 15
		}
	}
	return
}

~` & WheelUp::
DllCall("mouse_event", "UInt", 0x01, "UInt", 0, "UInt", -250)
return

~` & WheelDown::
DllCall("mouse_event", "UInt", 0x01, "UInt", 0, "UInt", 250)
return

FindAndClickConfirmButton(shouldreturn:=true)
{
	SearchData := [[0, (A_ScreenHeight // 2), A_ScreenWidth, A_ScreenHeight, "*50", "*TransBlack GenshinControlHints/Confirm.png", 6, 0]
		,[1400, 870, A_ScreenWidth, A_ScreenHeight, "*60", "*TransBlack GenshinControlHints/TPConfirm.png", 10, 3]
		,[1400, 950, A_ScreenWidth, A_ScreenHeight, "*50", "*TransBlack GenshinControlHints/Navigate.png", 10, 3]
		,[1440, 935, 1600, 1065, "*70", "*TransBlack GenshinControlHints/NavigateW.png", 80, 0]
		,[1040, 870, A_ScreenWidth, A_ScreenHeight, "*70", "*TransBlack GenshinControlHints/Obtain.png", 13, 0]
		,[1590, 327, 1750, 825, "*70", "*TransBlack GenshinControlHints/BPClaim.png", 40, 15]
		,[1600, 930, A_ScreenWidth, A_ScreenHeight, "*70", "*TransBlack GenshinControlHints/BPClaimAll.png", 40, -2]
		,[560, 720, 660, 785, "*70", "*TransBlack GenshinControlHints/UseCondensed.png", 27, 8]]
	
	Loop % SearchData.Length()
	{
		cdata := SearchData[A_Index]
		ImageSearch, FoundX, FoundY, cdata[1], cdata[2], cdata[3], cdata[4], % cdata[5] . cdata[6]
		if (ErrorLevel = 0)
		{
			ClickAndReturn(FoundX+cdata[7], FoundY+cdata[8], shouldreturn)
			return true
		}
	}
	return false
}

~r::
{
	if !PassChecks()
		return
	FindAndClickConfirmButton()
	return
}

IsInMapGUI()
{
	checkPositions := [[28, 427], [18, 428], [28, 417]]
	expectedColor := 0xEDE5DA
   
	Loop 3
	{
		PixelGetColor, PixCol, checkPositions[A_Index][1], checkPositions[A_Index][2], RGB
		if (PixCol != expectedColor)
		{
			if (debug)
			{
				devrhit1 := DevRect(checkPositions[A_Index][1]-3, checkPositions[A_Index][2]-3, checkPositions[A_Index][1]+3, checkPositions[A_Index][2]+3,,140)
				devhittext1 := DevText(40, 430, "Not in map | Pixel @ " . checkPositions[A_Index][1] . ":" . checkPositions[A_Index][2] . " is " . PixCol . " expected " . expectedColor)
				Sleep, 1000
				DestroyDevRect(devrhit1)
				DestroyDevText(devhittext1)
			}
			return 0
		}
	}
	return 1
}

FindFirstDialogOptionColorPixel(x1, y1, x2, y2)
{
	if (debug)
	{
		devr := DevRect(x1, y1, x2, y2, "FFD700")
		Sleep, 500
		DestroyDevRect(devr)
	}
	; Normal dialog option
	PixelSearch, FoundXDialogB, FoundYDialogB, x1, y1, x2, y2, 0xFFFFFF, 5, Fast
	if (ErrorLevel = 0)
	{
		if (debug)
		{
			SoundPlay *32
			PixelGetColor, pcolor, %FoundXDialogB%, %FoundYDialogB%
			dt := DevText(FoundXDialogB-450, FoundYDialogB, "Found white pixel " . pcolor . " @ #" . A_Index . " | X:" . FoundXDialogB . ", Y:" . FoundYDialogB,,, 14)
			devrhit1 := DevRect(FoundXDialogB-3, FoundYDialogB-3, FoundXDialogB+3, FoundYDialogB+3,,140)
			Sleep, 1500
			DestroyDevRect(devrhit1)
			DestroyDevText(dt)
		}
		return {"found": 1, "x": FoundXDialogB, "y": FoundYDialogB, "color": "white"}
	}
	else
	{
		; Golden dialog option
		PixelSearch, FoundXDialogB, FoundYDialogB, x1, y1, x2, y2, 0xFFCC32, 5, Fast RGB
		if (ErrorLevel = 0)
		{
			if (debug)
			{
				SoundPlay *32
				PixelGetColor, pcolor, %FoundXDialogB%, %FoundYDialogB%
				dt := DevText(FoundXDialogB-450, FoundYDialogB, "Found gold pixel " . pcolor . " @ #" . A_Index . " | X:" . FoundXDialogB . ", Y:" . FoundYDialogB,,, 14)
				devrhit1 := DevRect(FoundXDialogB-3, FoundYDialogB-3, FoundXDialogB+3, FoundYDialogB+3,,140)
				Sleep, 1500
				DestroyDevRect(devrhit1)
				DestroyDevText(dt)
			}
			return {"found": 1, "x": FoundXDialogB, "y": FoundYDialogB, "color": "gold"}
		}
		else
		{
			; Greyed out dialog option
			PixelSearch, FoundXDialogB, FoundYDialogB, x1, y1, x2, y2, 0x999999, 0, Fast RGB
			if (ErrorLevel = 0)
			{
				if (debug)
				{
					SoundPlay *32
					PixelGetColor, pcolor, %FoundXDialogB%, %FoundYDialogB%
					dt := DevText(FoundXDialogB-450, FoundYDialogB, "Found grey pixel " . pcolor . " @ #" . A_Index . " | X:" . FoundXDialogB . ", Y:" . FoundYDialogB,,, 14)
					devrhit1 := DevRect(FoundXDialogB-3, FoundYDialogB-3, FoundXDialogB+3, FoundYDialogB+3,,140)
					Sleep, 1500
					DestroyDevRect(devrhit1)
					DestroyDevText(dt)
				}
				return {"found": 1, "x": FoundXDialogB, "y": FoundYDialogB, "color": "grey"}
			}
		}
	}
	return {"found": 0, "x": -1, "y": -1, "color": "unknown"}
}

; Find where the bottom-most option is. For cases where NPCs say 4+ lines of text and the dialog gets moved up
GetDialogOffset(isMapMode)
{
	if (isMapMode)
	{
		/*
			Let me tell you a tale of a mental illness:
			Map UI selection menu:
			- expands up until its 5 options
			- shifts up and expands down on the 6th
			- expands down 6+
			G why...
		*/
		;testColor := 0x636459
		testColor := 0x5A5D58
		confidenceMargin := 8
		posX := 1296
		posSize := [42, 2]
		; Sort descending
		positions := [886, 836]
		Loop % positions.Length()
		{
			if (debug)
			{
				devrcheckregion1 := DevRect(posX, positions[A_Index], posX + posSize[1], positions[A_Index] + posSize[2],"FF00FF",140)
				Sleep, 400
				DestroyDevRect(devrcheckregion1)
			}
			PixelSearch, FoundXLowDialog, FoundYLowDialog, posX, positions[A_Index], posX + posSize[1], positions[A_Index] + posSize[2], testColor, confidenceMargin, Fast RGB
			if (ErrorLevel = 0)
			{
				if (debug)
				{
					SoundPlay *64
					devrlowestdialog1 := DevRect(FoundXLowDialog-50, FoundYLowDialog-3, FoundXLowDialog+50, FoundYLowDialog+3,,140)
					Sleep, 3000
					DestroyDevRect(devrlowestdialog1)
				}
				return {"found": 1, "x": FoundXLowDialog, "y": FoundYLowDialog}
			}
		}
		return {"found": 0, "x": -1, "y": -1}
	}
	else
	{
		testColor := 0x65655F
		confidenceMargin := 5
		checkInterval := 10
		checkArea := [[1290, 560], [1310, 855]]
		if (debug)
		{
			devrcheckarearegion1 := DevRect(checkArea[1][1], checkArea[1][2], checkArea[2][1], checkArea[2][2],"66FF66",140)
			Sleep, 1000
			DestroyDevRect(devrcheckarearegion1)
		}
		curY := checkArea[2][2]
		while (curY > checkArea[1][2])
		{
			if (debug)
			{
				devrcheckregion1 := DevRect(checkArea[1][1], curY - checkInterval, checkArea[2][1], curY,"FF00FF",140)
				Sleep, 400
				DestroyDevRect(devrcheckregion1)
			}
			;2E3A4B
			PixelSearch, FoundXLowDialog, FoundYLowDialog, checkArea[2][1], curY, checkArea[1][1], curY - checkInterval, testColor, confidenceMargin, Fast RGB
			if (ErrorLevel = 0)
			{
				if (debug)
				{
					SoundPlay *64
					devrlowestdialog1 := DevRect(FoundXLowDialog-50, FoundYLowDialog-3, FoundXLowDialog+50, FoundYLowDialog+3,,140)
					Sleep, 3000
					DestroyDevRect(devrlowestdialog1)
				}
				return {"found": 1, "x": FoundXLowDialog, "y": FoundYLowDialog}
			}
			
			curY := curY - checkInterval
		}
		return {"found": 0, "x": -1, "y": -1}
	}
}

GetDialogOptionPos(option)
{
	mapMode := IsInMapGUI()
	if (mapMode)
	{
		; In map
		dialogBoxPositions := [[468, 505], [542, 580], [617, 655], [690, 728], [765, 805], [840, 878]]
		areaXPositions := [1323, 1348]
		greyCheckMargin := 5
	}
	else
	{
		; Generic Dialog
		dialogBoxPositions := [[414, 450], [489, 525], [563, 599], [637, 673], [712, 748], [787, 823]]
		areaXPositions := [1325, 1350]
		greyCheckMargin := 8
	}
	confSearchSize := [20, 10]
	dialogOffsetInfo := GetDialogOffset(mapMode)
	if (dialogOffsetInfo["found"])
	{
		dialogOffsetY := (dialogOffsetInfo["y"] - dialogBoxPositions[6][2]) - 14
		if (debug)
		{
			dtOffset1 := DevText(areaXPositions[1]-600, dialogBoxPositions[6][2] + dialogOffsetY, "Lowest Y: " . dialogOffsetInfo["y"] . " | Dialog position offset: " . dialogOffsetY,,, 14)
			Sleep, 2000
			DestroyDevText(dtOffset1)
		}
	}
	else
	{
		dialogOffsetY := 0
	}
	Loop 6
	{
		firstMenuButton := FindFirstDialogOptionColorPixel(areaXPositions[1], dialogBoxPositions[A_Index][1] + dialogOffsetY, areaXPositions[2], dialogBoxPositions[A_Index][2] + dialogOffsetY)
		if (firstMenuButton["found"])
		{
			; Dialog option background check
			PixelSearch, FoundXGrey, FoundYGrey, firstMenuButton["x"] - confSearchSize[1], firstMenuButton["y"] - confSearchSize[2], firstMenuButton["x"] + confSearchSize[1], firstMenuButton["y"] + confSearchSize[2], 0x363E46, greyCheckMargin, Fast RGB
			if (ErrorLevel = 0)
			{
				TargetX := areaXPositions[1]+100
				optionIndex := A_Index + (option-1)
				if (optionIndex > 6)
				{
					; Something went wrong or user is trying to select a nonexisting option. Bail out.
					return {"x": -1, "y": -1, "found": 0}
				}
				TargetY := (dialogBoxPositions[optionIndex][1] + ((dialogBoxPositions[optionIndex][2] - dialogBoxPositions[optionIndex][1]) // 2)) + dialogOffsetY
				if (debug)
				{
					SoundPlay *64
					devr := DevRect(areaXPositions[1], dialogBoxPositions[A_Index][1] + dialogOffsetY, areaXPositions[2], dialogBoxPositions[A_Index][2] + dialogOffsetY, "FFD700")
					devrhit1 := DevRect(firstMenuButton["x"]-3, firstMenuButton["y"]-3, firstMenuButton["x"]+3, firstMenuButton["y"]+3,,140)
					Sleep, 3000
					PixelGetColor, pcolor1, %FoundXGrey%, %FoundYGrey%
					dt1 := DevText(areaXPositions[1]-450, dialogBoxPositions[A_Index][1] + dialogOffsetY, "Confirmed by pixel " . pcolor1 . " @ X:" . FoundXGrey . ", Y:" . FoundYGrey,,, 14)
					devr2 := DevRect(firstMenuButton["x"]-confSearchSize[1], firstMenuButton["y"] - confSearchSize[2], firstMenuButton["x"]+confSearchSize[1], firstMenuButton["y"] + confSearchSize[2], "11E66D")
					devrhit2 := DevRect(FoundXGrey-3, FoundYGrey-3, FoundXGrey+3, FoundYGrey+3,"00FF00",140)
					Sleep, 2000
					devr3 := DevRect(areaXPositions[1], dialogBoxPositions[optionIndex][1] + dialogOffsetY, areaXPositions[2], dialogBoxPositions[optionIndex][2] + dialogOffsetY, "00E6E7")
					Sleep, 1000
					tardevr := DevRect(TargetX-3, TargetY-3, TargetX+3, TargetY+3,"FF00FF",140)
					Sleep, 3000
					DestroyDevText(dt1)
					DestroyDevRect(devr)
					DestroyDevRect(devr2)
					DestroyDevRect(devr3)
					DestroyDevRect(devrhit1)
					DestroyDevRect(devrhit2)
					DestroyDevRect(tardevr)
				}
				return {"x": TargetX, "y": TargetY, "found": 1}
			}
		}
	}
	if (debug)
		SoundPlay *16
	return {"x": -1, "y": -1, "found": 0}
}

~CapsLock::
{
	; Run Auto Upgrade if in upgrade menu else AutoRun
	if !PassChecks(true, [0, 0])
		return
	if PassChecks(false, [1, 1])
	{
		;AutoUpgrade artifacts with Animation Skip
		KeyWait, CapsLock
		Sleep, 10
		if (GetKeyState("CapsLock", "T"))
		{
			Loop
			{
				if (!GetKeyState("CapsLock", "T"))
					Break
				ImageSearch, FoundXAutoFill, FoundYAutoFill, 1620, 740, 1745, 790, *50, *Trans0xFF0000 GenshinControlHints\AutoFill.png
				if (ErrorLevel != 0)
					Break
				ClickAndReturn(FoundXAutoFill+40, FoundYAutoFill+20, false, false)
				Sleep, 200
				FindAndClickConfirmButton(false)
				Sleep, 30
				ClickAndReturn(155, 155, false, false)
				Sleep, 30
				ClickAndReturn(155, 225, false, false)
				Sleep, 500
			}
			SetCapsLockState, Off
		}
		return
	}
	if PassChecks(false, [1, 0])
	{
		KeyWait, CapsLock
		Sleep, 10
		if (GetKeyState("CapsLock", "T"))
		{
			Send {w down}
			Loop 
			{
				KeyWait, w, D T0.1
				if (!GetKeyState("CapsLock", "T") || ErrorLevel = 0)
				{
					Break
				}
			}
			Send {w up}
			SetCapsLockState, Off
		}
		return
	}
}

CollectExpeditionRewards()
{
	ImageSearch, InExpScreenX, InExpScreenY, 0, 0, 150, 120, *60, *TransWhite GenshinControlHints\IsInExpeditionScreen.png
	if (ErrorLevel != 0)
	{
		SoundPlay *16
		return
	}
	locations := [[118, 163], [118, 235], [118, 305], [118, 380]]
	character_busy_box := [516, 106]
	character_box_x := [325, 850] ; 1-Busy Status, 2-Boost Arrow
	character_box_width := [516, 51] ; 1-Busy Status, 2-Boost Arrow
	character_box_height := 43
	character_box_locs := [120, 244, 369, 494, 619, 744, 868]
	search_box := [350, 150, 1310, 934]
	loc_num := 0
	Loop % locations.Length()
	{
		loc_num++
		; Click the location in the top left corner
		if (debug)
		{
			locname_dev_rect := DevRect(locations[loc_num][1]-5, locations[loc_num][2]-30, locations[loc_num][1]+100, locations[loc_num][2]+30, "11FFEB")
			Sleep, 1000
			DestroyDevRect(locname_dev_rect)
		}
		ClickAndReturn(locations[loc_num][1], locations[loc_num][2], false)
		Sleep, 500
		isNotDone := true
		while (isNotDone)
		{
			; Find a Compeleted Expedition
			isFound := false
			isSelected := false
			ImageSearch, FoundExpX, FoundExpY, search_box[1], search_box[2], search_box[3], search_box[4], *55, *Trans0xFF0000 GenshinControlHints\ExpeditionRewardBig.png
			if (ErrorLevel = 0)
			{
				isFound := true
				isSelected := true
			}
			else
			{
				ImageSearch, FoundExpX, FoundExpY, search_box[1], search_box[2], search_box[3], search_box[4], *55, *Trans0xFF0000 GenshinControlHints\ExpeditionReward.png
				if (ErrorLevel = 0)
				{
					isFound := true
				}
			}
			if (isFound)
			{
				if (debug)
				{
					reward_dev_rect := DevRect(FoundExpX, FoundExpY, FoundExpX+71, FoundExpY+22, "68A4FF")
					Sleep, 1000
					DestroyDevRect(reward_dev_rect)
					rewardclick_dev_rect := DevRect(FoundExpX+22-5, FoundExpY+71-5, FoundExpX+22+5, FoundExpY+71+5, "99FF14")
					Sleep, 1000
					DestroyDevRect(rewardclick_dev_rect)
				}
				if !(isSelected)
				{
					; Select it
					ClickAndReturn(FoundExpX+35, FoundExpY+83, false)
					Sleep, 500
				}
				; Claim
				FindAndClickConfirmButton(false)
				Sleep, 500
				ClickAndReturn(Round(A_ScreenWidth * Random(0.65, 0.75)), Random(900, 1000), false)
				Sleep, 500
				FindAndClickConfirmButton(false)
				Sleep, 1000
				skipped_characters := []
				finished_selection := false
				while (!finished_selection)
				{
					; Find a character that has a boost but is not busy ATM and click them
					char_num := 0
					preferred_char := 0
					Loop % character_box_locs.Length()
					{
						char_num++
						if ValueInArray(char_num, skipped_characters)
							continue
						if (debug)
						{
							charbox_dev_rect := DevRect(character_box_x[1], character_box_locs[char_num], character_box_x[1]+character_box_width[1], character_box_locs[char_num]+character_box_height, "FF00EE")
							Sleep, 1000
							DestroyDevRect(charbox_dev_rect)
						}
						PixelSearch, FoundBoostX, FoundBoostY, character_box_x[1], character_box_locs[char_num], character_box_x[1]+character_box_width[1], character_box_locs[char_num]+character_box_height, 0xDCBC60, 5, Fast RGB ;Is Busy? (Yellow)
						isBusy := -1
						if (ErrorLevel != 0)
						{
							PixelSearch, FoundBoostX, FoundBoostY, character_box_x[1], character_box_locs[char_num], character_box_x[1]+character_box_width[1], character_box_locs[char_num]+character_box_height, 0x99CC32, 10, Fast RGB ;Is Busy? (Green)
							if (ErrorLevel != 0)
							{
								isBusy := 0
							}
							else
							{
								isBusy := 1
							}
						}
						else
						{
							isBusy := 2
						}
						if (debug)
						{
							errorlvls_dt := DevText(965, character_box_locs[char_num], "Status: " . (isBusy = 0 ? "Free" : (isBusy = 2 ? "Exploring" : "Awaiting")),,, 14)
							Sleep, 2000
							DestroyDevText(errorlvls_dt)
						}
						if (isBusy = 0)
						{
							if (debug)
							{
								charbox_dev_rect := DevRect(character_box_x[1], character_box_locs[char_num], character_box_x[1]+character_box_width[1], character_box_locs[char_num]+character_box_height, "00FF00")
								Sleep, 500
								DestroyDevRect(charbox_dev_rect)
								Sleep, 500
								charboxboost_dev_rect := DevRect(character_box_x[2], character_box_locs[char_num], character_box_x[2]+character_box_width[2], character_box_locs[char_num]+character_box_height, "0033FF")
								Sleep, 1000
								DestroyDevRect(charboxboost_dev_rect)
							}
							PixelSearch, FoundBoostX, FoundBoostY, character_box_x[2], character_box_locs[char_num], character_box_x[2]+character_box_width[2], character_box_locs[char_num]+character_box_height, 0x99FF22, 5, Fast RGB
							if (ErrorLevel = 0)
							{
								; This is a Boosted Character
								preferred_char := char_num
								if (debug)
								{
									charbox_dev_rect := DevRect(character_box_x[2], character_box_locs[char_num], character_box_x[2]+character_box_width[2], character_box_locs[char_num]+character_box_height, "1DFF00")
									Sleep, 1000
									DestroyDevRect(charbox_dev_rect)
								}
								break
							}
							else
							{
								; This is not a Boosted Character but incase we have no boosted characters we will use this one
								preferred_char := char_num
								if (debug)
								{
									charbox_dev_rect := DevRect(character_box_x[2], character_box_locs[char_num], character_box_x[2]+character_box_width[2], character_box_locs[char_num]+character_box_height, "FF1500")
									Sleep, 1000
									DestroyDevRect(charbox_dev_rect)
								}
							}
						}
						else
						{
							if (debug)
							{
								charbox_dev_rect := DevRect(character_box_x[1], character_box_locs[char_num], character_box_x[1]+character_box_width[1], character_box_locs[char_num]+character_box_height, "FF1500")
								Sleep, 1000
								DestroyDevRect(charbox_dev_rect)
							}
						}
					}
					if (preferred_char != 0)
					{
						; If we have atleast one character available pick them
						if (debug)
						{
							charbox_dev_rect := DevRect(character_box_x[1], character_box_locs[preferred_char], character_box_x[1]+character_box_width[1], character_box_locs[preferred_char]+character_box_height, "2DFBFF")
							Sleep, 1000
							DestroyDevRect(charbox_dev_rect)
						}
						ClickAndReturn(character_box_x[1], character_box_locs[preferred_char]+30, false)
						Sleep, 500
						; Check for edge cases where clicking on a character does not select it due to some unexpected condition, such as selected character being dead
						ImageSearch,,, 0, 0, 400, 100, *55, *Trans0xFF0000 GenshinControlHints\IsInExpeditionCharSelection.png
						if (ErrorLevel = 0)
						{
							skipped_characters.Push(preferred_char)
						}
						else
						{
							finished_selection := true
						}
					}
					else
					{
						; No Available Characters found - sound an alarm and bail out
						SoundPlay *16
						return
					}
				}
				Sleep, 500
			}
			else
			{
				isNotDone := false
			}
		}
	}
	; Exit
	ClickAndReturn(1842, 45, false)
}

F12::
{
	if !PassChecks()
		return
	CollectExpeditionRewards()
	return
}

~1::
~2::
~3::
~4::
~5::
~6::
{
	if !PassChecks()
		return
	HKPressed := SubStr(A_ThisHotkey, 2, 1)
	dialogpos := GetDialogOptionPos(HKPressed)
	if (dialogpos["found"])
	{
		ClickAndReturn(dialogpos["x"], dialogpos["y"])
	}
	return
}
