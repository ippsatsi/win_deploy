#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("Form1", 615, 437, 192, 124)
$Group1 = GUICtrlCreateGroup("Group1", 144, 88, 209, 49)
$Radio1 = GUICtrlCreateRadio("Radio1", 160, 104, 17, 17)
$Radio2 = GUICtrlCreateRadio("Radio2", 272, 104, 17, 17)
$Label1 = GUICtrlCreateLabel("Label1", 184, 104, 36, 17)
$Label2 = GUICtrlCreateLabel("Label2", 296, 104, 36, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd
