#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_x64=win_deploy.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <String.au3>
#include <ColorConstants.au3>
#include <comandos_array.au3>
#include <funciones.au3>
#include <EditConstants.au3>

Opt("GUIResizeMode", $GUI_DOCKTOP  + $GUI_DOCKSIZE)

Local $intGuiAncho = 598
Local $intGuiAltoMin = 343
Local $intGuiAltoMax = 500

#Region ### START Koda GUI section ### Form=c:\users\luis\documents\form2.kxf
Global $Form1_1 = GUICreate("Form1", $intGuiAncho, $intGuiAltoMin,-1,-1)
$btActivar = GUICtrlCreateButton("Activar", 338, 215, 89, 25)
$Button2 = GUICtrlCreateButton("Button1", 456, 215, 89, 25)
$Group1 = GUICtrlCreateGroup("Group1", 16, 8, 561, 249)
;$List1 = GUICtrlCreateList("", 192, 56, 201, 19)
;$Combo1 = GUICtrlCreateCombo("Combo1", 88, 104, 177, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$lblArranque = GUICtrlCreateLabel("Tipo Arranque: ", 42, 28, 156, 17)
Global $itemActivacion = GUICtrlCreateLabel("Activar particion de sistema", 42, 56, 156, 17)

GUICtrlCreateGroup("Arranque:", 52, 75, 220,50)
Local $ckUEFI = GUICtrlCreateRadio("", 72, 95, 17, 17)
GUICtrlCreateLabel("UEFI", 90, 97, 25, 17)
Local $ckCsm = GUICtrlCreateRadio("", 142, 95, 17, 17)
GUICtrlCreateLabel("CSM/MBR", 160, 97, 55, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

Global $itemCopyWinre = GUICtrlCreateLabel("Copiado WinRe", 42, 137, 156, 17)
Global $itemRegWinre = GUICtrlCreateLabel("Registro WinRe", 42, 157, 156, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $lblEstado = GUICtrlCreateLabel("Listo", 16, 262, 375, 17)
Local $idProgressbar1 = GUICtrlCreateProgress(16, 282, 430, 25)
$btDetalles = GUICtrlCreateButton("<< Detalles", 456, 282, 89, 25)
Local $boolDetalles = False
Local $txtContenidoDetalles = ''
$BoxDetalles = GUICtrlCreateEdit("", 16, 325, 561, 128, $ES_MULTILINE + $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_READONLY, $WS_EX_STATICEDGE)
WinMove($Form1_1,"",Default, Default,Default, $intGuiAltoMin)

#EndRegion ### END Koda GUI section ###
Local $txtCommandLine = ''
Local $txtBootOption = ''
Local $sTipoArranque = RegRead("HKLM\System\CurrentControlSet\Control", "PEFirmwareType")
If $sTipoArranque = 2 Then
	$sTipoArranque = "UEFI"
	GUICtrlSetState($ckUEFI, $GUI_CHECKED)
Else
	$sTipoArranque = "CSM"
	GUICtrlSetState($ckCsm, $GUI_CHECKED)
EndIf
GUICtrlSetData($lblArranque, "Tipo Arranque: " & $sTipoArranque)
GUISetState(@SW_SHOW)
$intOperaciones = 0
Local $ContenedorCtrl[3]
$ContenedorCtrl[0] = $Form1_1
$ContenedorCtrl[1] = $BoxDetalles
$ContenedorCtrl[2] = $lblEstado
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button2
			$aClientSize = WinGetClientSize($Form1_1)
			MsgBox($MB_SYSTEMMODAL, "", "Width: " & $aClientSize[0] & @CRLF & "Height: " & $aClientSize[1])
		Case $btDetalles

			If $boolDetalles = False Then
				WinMove($Form1_1,"",Default, Default,Default, $intGuiAltoMax)
				$boolDetalles = True
			Else
				WinMove($Form1_1,"",Default, Default,Default, $intGuiAltoMin)
				$boolDetalles = False
			EndIf


		Case $btActivar
			;MsgBox($MB_SYSTEMMODAL, "", "Default button clicked:" & $arrayComandos[0][3] & @CRLF & "Radio ")
;~ 			$Title = "Bogus"
;~ 			$psDismApply = Run(@ComSpec & " /c title " & $Title & "|" & 'Dism.exe /Apply-Image /ImageFile:D:\util\install.wim /Index:1 /ApplyDir:W:\', "", "", 2 + 4)

;~ 			While ProcessExists($psDismApply)
;~ 				$outConsole = StdoutRead($psDismApply,5)
;~ 				ConsoleWrite($outConsole)
;~ 			WEnd
;~ 			dism /Apply-Image /ImageFile:N:\Images\my-windows-partition.wim /Index:1 /ApplyDir:W:\
			$intOperaciones = 0
			GUICtrlSetData($BoxDetalles, '')
			GUICtrlSetData($idProgressbar1, 0)
			If	GUICtrlRead($ckUEFI) = $GUI_CHECKED Then
				$txtBootOption = "UEFI"
			Else
				$txtBootOption = "BIOS"
			EndIf
			; Activar particion sistema
			$resultado = _EjecutarTarea($ContenedorCtrl,$arrayComandos, $itemActivacion, $intOperaciones,$txtBootOption)
			$resultado = True

			If Not $resultado Then
				ContinueLoop
			EndIf
			GUICtrlSetData($idProgressbar1, 30)
			$resultado = False
			$intOperaciones = $intOperaciones + 1

			;Crear carpeta Winre
			_MensajesEstado($ContenedorCtrl[1],$ContenedorCtrl[2], $arrayComandos[$intOperaciones][0])
			$rutaWinre = "R:\Recovery\WindowsRE"
			$unidadRecovery = "R:\"
			If FileExists($unidadRecovery) Then
				ConsoleWrite("Existe R:")
				ContinueLoop
			EndIf

			If	FileExists($unidadRecovery) Or FileExists($rutaWinre) Or (Not FileExists($rutaWinre) And DirCreate($rutaWinre)) Then
				_MensajesEstado($ContenedorCtrl[1],$ContenedorCtrl[2],$arrayComandos[$intOperaciones][2])
				$resultado = True
			ElseIf Not FileExists($rutaWinre) Then
				_MensajesEstado($ContenedorCtrl[1],$ContenedorCtrl[2],"Error: " & $arrayComandos[$intOperaciones][3])
				ContinueLoop
			EndIf

			If Not $resultado Then
				ContinueLoop
			EndIf
			GUICtrlSetData($idProgressbar1, 40)
			$resultado = False
			$intOperaciones = $intOperaciones + 1

			;Copiar Winre
			$LetrasUnidad = "C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:"
			$arrayLetras = StringSplit($LetrasUnidad, '|', 1)


			$archivo_wim = "install.wim"
			$rutaFinalWinre = "\usb\IMA\"
			For $Letra in $arrayLetras
				$RutaArchivo = $Letra & $rutaFinalWinre & $archivo_wim
				If FileExists($RutaArchivo) Then

				EndIf
			Next

			$RutaCopiadoOrigen = "W:\Windows\System32\Recovery\"
			If FileExists($RutaCopiadoOrigen & "winre.wim") Then
				$parametro = $RutaCopiadoOrigen
			Else
				$archivo_wim = "install.wim"
				$rutaFinalWinre = "\usb\IMA\"
				For $Letra in $arrayLetras
					$RutaArchivo = $Letra & $rutaFinalWinre & $archivo_wim
					If FileExists($RutaArchivo) Then
						$parametro = $Letra & $rutaFinalWinre
					EndIf
				Next

			EndIf

			$resultado = _EjecutarTarea($ContenedorCtrl,$arrayComandos, $itemCopyWinre, $intOperaciones, $parametro)

			If Not $resultado Then
				ContinueLoop
			EndIf
			$resultado = False
			$intOperaciones = $intOperaciones + 1
			GUICtrlSetData($idProgressbar1, 70)
			;Registrar Winre
			$resultado = _EjecutarTarea($ContenedorCtrl,$arrayComandos, $itemRegWinre, $intOperaciones)

			If Not $resultado Then
				ContinueLoop
			EndIf
			GUICtrlSetData($idProgressbar1, 100)
			_MensajesEstado($ContenedorCtrl[1],$ContenedorCtrl[2], "Activadas correctamente las particiones")
	EndSwitch
WEnd