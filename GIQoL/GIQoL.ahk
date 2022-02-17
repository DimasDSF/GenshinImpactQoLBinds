#SingleInstance force
#MaxHotkeysPerInterval 50000
#MaxThreadsPerHotkey 1
SetBatchLines -1
SetMouseDelay, 5
SetStoreCapsLockMode, Off
CoordMode, Mouse, Screen

if A_IsAdmin != 1
{
	SoundPlay, *48
	MsgBox,,Restart as admin, 
(
Genshin Impact is using a launcher always running in admin mode

GIRebind requires running as admin to be able to pass keystrokes and mouse events to any admin mode app
), 15
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

   if Result > 1
      return 1
   else
      return 0
}

ClickAndReturn(x, y)
{
	MouseGetPos, startxpos, startypos
	MouseMove, x+Random(-5, 5), y+Random(-5, 5), 5
	Click
	Sleep, 200
	MouseMove, startxpos+Random(-10, 10), startypos+Random(-10, 10), 5
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

~f::
if !WinActive("ahk_class UnityWndClass")
	return
if !IsCursorVisible()
{
	Sleep, 200
	if GetKeyState("f", "P")
	{
		Loop
		{
			if not GetKeyState("f", "P")
				break
			Send {f down}
			Send {f up}
			Click, WheelDown
			Send {f down}
			Send {f up}
			Sleep, 15
		}
	}
}
return

~` & WheelUp::
DllCall("mouse_event", "UInt", 0x01, "UInt", 0, "UInt", -250)
return

~` & WheelDown::
DllCall("mouse_event", "UInt", 0x01, "UInt", 0, "UInt", 250)
return

~r::
if !WinActive("ahk_class UnityWndClass")
;ahk_exe GenshinImpact.exe
	return
if IsCursorVisible()
{
	ImageSearch, FoundX, FoundY, 0, (A_ScreenHeight // 2), A_ScreenWidth, A_ScreenHeight, *50, *TransBlack GenshinControlHints\Confirm.png
	if (ErrorLevel = 0)
	{
		ClickAndReturn(FoundX+6, FoundY)
		return
	}
	else
	{
		ImageSearch, FoundXTP, FoundYTP, 1400, 870, A_ScreenWidth, A_ScreenHeight, *60, *TransBlack GenshinControlHints\TPConfirm.png
		if (ErrorLevel = 0)
		{
			ClickAndReturn(FoundXTP+10, FoundYTP+3)
			return
		}
		else
		{
			ImageSearch, FoundXNavigate, FoundYNavigate, 1400, 950, A_ScreenWidth, A_ScreenHeight, *50, *TransBlack GenshinControlHints\Navigate.png
			if (ErrorLevel = 0)
			{
				ClickAndReturn(FoundXNavigate+10, FoundYNavigate+3)
				return
			}
			else
			{
				ImageSearch, FoundXObtain, FoundYObtain, 1040, 870, A_ScreenWidth, A_ScreenHeight, *70, *TransBlack GenshinControlHints\Obtain.png
				if (ErrorLevel = 0)
				{
					ClickAndReturn(FoundXObtain+13, FoundYObtain)
					return
				}
			}
		}
	}
}
return

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
		Sleep, 2000
		DestroyDevRect(devr)
	}
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

GetDialogOptionPos(option)
{
	mapMode := IsInMapGUI()
	if (!mapMode)
	{
		; Generic Dialog
		dialogBoxPositions := [[414, 450], [489, 525], [563, 599], [637, 673], [712, 748], [787, 823]]
		areaXPositions := [1325, 1400]
	}
	else
	{
		; In map
		dialogBoxPositions := [455, 886]
		areaXPositions := [1320, 1372]
	}
	confSearchSize := [30, 4]
	if (mapMode)
	{
		topY := dialogBoxPositions[1]
		while (topY < dialogBoxPositions[2])
		{
			firstMenuButton := FindFirstDialogOptionColorPixel(areaXPositions[1], topY, areaXPositions[2], dialogBoxPositions[2])
			if (!firstMenuButton["found"])
				break
			; Dialog option background check
			PixelSearch, FoundXGrey, FoundYGrey, firstMenuButton["x"] - confSearchSize[1], firstMenuButton["y"] - confSearchSize[2], firstMenuButton["x"] + confSearchSize[1], firstMenuButton["y"] + confSearchSize[2], 0x363E46, 5, Fast RGB
			if (ErrorLevel = 0)
			{
				TargetX := firstMenuButton["x"]+100
				optionOffset := 75 * (option-1)
				TargetY := firstMenuButton["y"]+optionOffset
				if (debug)
				{
					SoundPlay *64
					devrhit1 := DevRect(firstMenuButton["x"]-3, firstMenuButton["y"]-3, firstMenuButton["x"]+3, firstMenuButton["y"]+3,,140)
					Sleep, 3000
					PixelGetColor, pcolor1, %FoundXGrey%, %FoundYGrey%
					dt1 := DevText(firstMenuButton["x"]-450, firstMenuButton["y"], "Confirmed by pixel " . pcolor1 . " @ X:" . FoundXGrey . ", Y:" . FoundYGrey,,, 14)
					devr2 := DevRect(firstMenuButton["x"]-confSearchSize[1], firstMenuButton["y"] - confSearchSize[2], firstMenuButton["x"]+confSearchSize[1], firstMenuButton["y"] + confSearchSize[2], "11E66D")
					devrhit2 := DevRect(FoundXGrey-3, FoundYGrey-3, FoundXGrey+3, FoundYGrey+3,"00FF00",140)
					Sleep, 2000
					tardevr := DevRect(TargetX-3, TargetY-3, TargetX+3, TargetY+3,"FF00FF",140)
					Sleep, 3000
					DestroyDevRect(devrhit1)
					DestroyDevRect(devrhit2)
					DestroyDevText(dt1)
					DestroyDevRect(devr2)
					DestroyDevRect(tardevr)
				}
				return {"x": TargetX, "y": TargetY, "found": 1}
			}
			else
			{
				topY := firstMenuButton["y"] + 30
			}
		}
	}
	else
	{
		Loop 6
		{
			firstMenuButton := FindFirstDialogOptionColorPixel(areaXPositions[1], dialogBoxPositions[A_Index][1], areaXPositions[2], dialogBoxPositions[A_Index][2])
			if (firstMenuButton["found"])
			{
				; Dialog option background check
				PixelSearch, FoundXGrey, FoundYGrey, firstMenuButton["x"] - confSearchSize[1], firstMenuButton["y"] - confSearchSize[2], firstMenuButton["x"] + confSearchSize[1], firstMenuButton["y"] + confSearchSize[2], 0x363E46, 5, Fast RGB
				if (ErrorLevel = 0)
				{
					TargetX := areaXPositions[1]+100
					optionIndex := A_Index + (option-1)
					TargetY := (dialogBoxPositions[optionIndex][1] + ((dialogBoxPositions[optionIndex][2] - dialogBoxPositions[optionIndex][1]) // 2))
					if (debug)
					{
						SoundPlay *64
						devr := DevRect(areaXPositions[1], dialogBoxPositions[A_Index][1], areaXPositions[2], dialogBoxPositions[A_Index][2], "FFD700")
						devrhit1 := DevRect(firstMenuButton["x"]-3, firstMenuButton["y"]-3, firstMenuButton["x"]+3, firstMenuButton["y"]+3,,140)
						Sleep, 3000
						PixelGetColor, pcolor1, %FoundXGrey%, %FoundYGrey%
						dt1 := DevText(areaXPositions[1]-450, dialogBoxPositions[A_Index][1], "Confirmed by pixel " . pcolor1 . " @ X:" . FoundXGrey . ", Y:" . FoundYGrey,,, 14)
						devr2 := DevRect(firstMenuButton["x"]-confSearchSize[1], firstMenuButton["y"] - confSearchSize[2], firstMenuButton["x"]+confSearchSize[1], firstMenuButton["y"] + confSearchSize[2], "11E66D")
						devrhit2 := DevRect(FoundXGrey-3, FoundYGrey-3, FoundXGrey+3, FoundYGrey+3,"00FF00",140)
						Sleep, 2000
						devr3 := DevRect(areaXPositions[1], dialogBoxPositions[optionIndex][1], areaXPositions[2], dialogBoxPositions[optionIndex][2], "00E6E7")
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
	}
	if (debug)
		SoundPlay *16
	return {"x": -1, "y": -1, "found": 0}
}

~1::
~2::
~3::
~4::
~5::
~6::
if !WinActive("ahk_class UnityWndClass")
	return
if IsCursorVisible() == 0
	return
HKPressed := SubStr(A_ThisHotkey, 2, 1)
dialogpos := GetDialogOptionPos(HKPressed)
if (dialogpos["found"])
{
	ClickAndReturn(dialogpos["x"], dialogpos["y"])
}
return
