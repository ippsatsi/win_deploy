#RequireAdmin
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <ColorConstants.au3>
#include <funciones.au3>

Opt("GUIResizeMode", $GUI_DOCKTOP  + $GUI_DOCKSIZE)

Local $intGuiAncho = 598
Local $intGuiAltoMin = 344
Local $intGuiAltoMax = 500

#Region ### START Koda GUI section ### Form=c:\users\luis\documents\form2.kxf
$Form1_1 = GUICreate("Form1", $intGuiAncho, $intGuiAltoMin,-1,-1,$WS_SIZEBOX)
$btActivar = GUICtrlCreateButton("Activar", 338, 215, 89, 25)
$Button2 = GUICtrlCreateButton("Button1", 456, 215, 89, 25)
$Group1 = GUICtrlCreateGroup("Group1", 16, 8, 561, 249)
;$List1 = GUICtrlCreateList("", 192, 56, 201, 19)
;$Combo1 = GUICtrlCreateCombo("Combo1", 88, 104, 177, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$lblArranque = GUICtrlCreateLabel("Tipo Arranque: ", 42, 28, 156, 17)
$Label1 = GUICtrlCreateLabel("Activar particion de sistema", 42, 56, 156, 17)

GUICtrlCreateGroup("Arranque:", 42, 95, 220,50)
Local $ckUEFI = GUICtrlCreateRadio("", 62, 115, 17, 17)
GUICtrlCreateLabel("UEFI", 80, 117, 25, 17)
Local $ckCsm = GUICtrlCreateRadio("", 132, 115, 17, 17)
GUICtrlCreateLabel("CSM/MBR", 150, 117, 55, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $idProgressbar1 = GUICtrlCreateProgress(16, 270, 430, 25)
$btDetalles = GUICtrlCreateButton("<< Detalles", 456, 270, 89, 25)
Local $boolDetalles = False
Local $txtContenidoDetalles = ''
$BoxDetalles = GUICtrlCreateLabel("", 16, 320, 561, 118, -1, $WS_EX_STATICEDGE)

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Local $sTipoArranque = RegRead("HKLM\System\CurrentControlSet\Control", "PEFirmwareType")
If $sTipoArranque = 2 Then
	$sTipoArranque = "UEFI"
	GUICtrlSetState($ckUEFI, $GUI_CHECKED)
Else
	$sTipoArranque = "CSM"
	GUICtrlSetState($ckCsm, $GUI_CHECKED)
EndIf

GUICtrlSetData($lblArranque, "Tipo Arranque: " & $sTipoArranque)


While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btDetalles
			If $boolDetalles = False Then
				WinMove($Form1_1,"",Default, Default,Default, $intGuiAltoMax)
				$boolDetalles = True
			Else
				WinMove($Form1_1,"",Default, Default,Default, $intGuiAltoMin)
				$boolDetalles = False
			EndIf


		Case $btActivar
			MsgBox($MB_SYSTEMMODAL, "", "Default button clicked:" & @CRLF & "Radio ")
;~ 			$Title = "Bogus"
;~ 			$psDismApply = Run(@ComSpec & " /c title " & $Title & "|" & 'Dism.exe /Apply-Image /ImageFile:D:\util\install.wim /Index:1 /ApplyDir:W:\', "", "", 2 + 4)

;~ 			While ProcessExists($psDismApply)
;~ 				$outConsole = StdoutRead($psDismApply,5)
;~ 				ConsoleWrite($outConsole)
;~ 			WEnd
;~ 			dism /Apply-Image /ImageFile:N:\Images\my-windows-partition.wim /Index:1 /ApplyDir:W:\
			$psBCDboot = Run(@ComSpec & " /c " & 'W:\Windows\System32\bcdboot W:\Windows /l es-mx /s S:', "", @SW_HIDE, $STDOUT_CHILD)
			ProcessWaitClose($psBCDboot)

			Local $readConsole = StdoutRead($psBCDboot)
			If StringInStr($readConsole, "Archivos de arranque creados correctamente") Then
				$b = _CirculoResultado(30, 30, "verde")
				MsgBox($MB_SYSTEMMODAL, "", "Activacion" & @CRLF & "OK ")
			EndIf

			ConsoleWrite($readConsole)

	EndSwitch
WEnd