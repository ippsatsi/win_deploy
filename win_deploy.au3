#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_x64=win_deploy.exe
#AutoIt3Wrapper_Run_AU3Check=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <String.au3>
#include <EditConstants.au3>
#include <Array.au3>
#include <ColorConstants.au3>
#include <ListViewConstants.au3>
#include <AutoItConstants.au3>

#include <comandos_array.au3>
#include <funciones.au3>
#include <diskpart_funciones.au3>
#include <dism_funciones.au3>

Global $MensajeStatusError = ""
;Opciones GUI
Opt("GUIResizeMode", $GUI_DOCKTOP  + $GUI_DOCKSIZE)

Local $intGuiAncho = 598
Local $intGuiAltoMin = 443
Local $intGuiAltoMax = 500
Local $intAlinIzq1 = 16
Local $intAlinIzq2 = ($intAlinIzq1 * 2) + 6
#include <gui_interfaz.au3>
#Region ### START Koda GUI section ### Form=c:\users\luis\documents\form2.kxf
;Primera ventana
;~ Global $Form1_0 = GUICreate("Activador de Restauración", $intGuiAncho, $intGuiAltoMin,-1,-1)
;~ $GroupSelDisk = GUICtrlCreateGroup("Seleccione disco", 16, 8, $intGuiAncho - 37, 180)
;~ Global $idListDiscos = GUICtrlCreateListView("# |       Modelo      | Sistema | Tamaño  |Espacio Libre| Interface |Status  ", $intAlinIzq2, 33, 510, 100, BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER),$LVS_EX_INFOTIP) ;version: 0.4.1.0
;~ 					GUICtrlSendMsg(-1, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_GRIDLINES, $LVS_EX_GRIDLINES)
;~ Local $lblModoDisco = GUICtrlCreateLabel("Usar disco como: ", $intAlinIzq2, 145, 89, 25)
;~ Global $ctrlSelModoDisco = GUICtrlCreateCombo("", $intGuiAncho - 468, 145, 130, 25)
;~ GUICtrlSetData($ctrlSelModoDisco, "Seleccione|Nuevo|Reinstalacion", "Seleccione")
;~ GUICtrlSetState($ctrlSelModoDisco, $GUI_DISABLE)
;~ $btRefresh = GUICtrlCreateButton("Refrescar", $intGuiAncho - 142, 145, 89, 25)

;~ $GroupTipoInstalacion = GUICtrlCreateGroup("Seleccione tipo de instalacion", 16, 196, $intGuiAncho - 37, 57)
;~ Local $ck_UEFI = GUICtrlCreateRadio("", 32, 220, 17, 17)
;~ GUICtrlCreateLabel("UEFI", 52, 220, 25, 17)
;~ Local $ck_Csm = GUICtrlCreateRadio("", 100, 220, 17, 17)
;~ GUICtrlCreateLabel("CSM/MBR", 130, 220, 55, 17)
;~ Global $btFormatear = GUICtrlCreateButton("formatear", $intGuiAncho - 268, 215, 89, 25)
;  GUICtrlSetState($btFormatear, $GUI_DISABLE)
;~ $btNext = GUICtrlCreateButton("Siguiente", $intGuiAncho - 142, 215, 89, 25)

;~ $GroupSelImagen = GUICtrlCreateGroup("Seleccione imagen a instalar", 16, 260, $intGuiAncho - 37, 67)
;~ GUICtrlCreateLabel("archivo WIM", $intAlinIzq2, 294, 70, 17)
;~ Local $inFileImagePath = GUICtrlCreateInput("", $intAlinIzq2 + 70 , 289, 310, 21)
;~ $btFileSel = GUICtrlCreateButton("Examinar", $intGuiAncho - 142, 285, 89, 25)

;segunda ventana
Global $Form1_1 = GUICreate("Activador de Restauración", $intGuiAncho, $intGuiAltoMin,-1,-1)
$btAnterior = GUICtrlCreateButton("anterior", $intGuiAncho - 268, 215, 89, 25)
$btActivar = GUICtrlCreateButton("Activar", $intGuiAncho - 142, 215, 89, 25)
$Group1 = GUICtrlCreateGroup("Activación", 16, 8, $intGuiAncho - 37, 249)
;$List1 = GUICtrlCreateList("", 192, 56, 201, 19)
;$Combo1 = GUICtrlCreateCombo("Combo1", 88, 104, 177, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$lblArranque = GUICtrlCreateLabel("Tipo Arranque Actual: ", 42, 28, 156, 17)
Global $itemActivacion = GUICtrlCreateLabel("Activar particion de sistema", 52, 56, 156, 17)

GUICtrlCreateGroup("Arranque en disco:", 62, 75, 220,50)
Local $ckUEFI = GUICtrlCreateRadio("", 82, 95, 17, 17)
;~ GUICtrlCreateLabel("UEFI", 100, 97, 25, 17)
Local $ckCsm = GUICtrlCreateRadio("", 152, 95, 17, 17)
;~ GUICtrlCreateLabel("CSM/MBR", 170, 97, 55, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

Global $itemCopyWinre = GUICtrlCreateLabel("Copiado WinRE", 52, 137, 156, 17)
Global $itemRegWinre = GUICtrlCreateLabel("Registro WinRE", 52, 157, 156, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $lblEstado = GUICtrlCreateLabel("Listo", 16, 262, 375, 17)
Local $idProgressbar1 = GUICtrlCreateProgress(16, 282, $intGuiAncho - 168, 25)
$btDetalles = GUICtrlCreateButton("<< Detalles", $intGuiAncho - 142, 282, 89, 25)
Local $boolDetalles = False
Local $txtContenidoDetalles = ''
$BoxDetalles = GUICtrlCreateEdit("", 16, 325, $intGuiAncho - 37, 128, $ES_MULTILINE + $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_READONLY, $WS_EX_STATICEDGE)
WinMove($Form1_1,"",Default, Default,Default, $intGuiAltoMin)
WinMove($Activador,"",Default, Default,Default, $intGuiAltoMin)

#EndRegion ### END Koda GUI section ###
Local $txtCommandLine = ''
Local $txtBootOption = ''
Local $sTipoArranque = RegRead("HKLM\System\CurrentControlSet\Control", "PEFirmwareType")
If $sTipoArranque = 2 Then
	$sTipoArranque = "UEFI"
	GUICtrlSetState($ck_UEFI, $GUI_CHECKED)
Else
	$sTipoArranque = "CSM"
	GUICtrlSetState($ck_Csm, $GUI_CHECKED)
EndIf
GUICtrlSetData($lblArranque, "Arranque Actual de BIOS: " & $sTipoArranque)

GUISetState(@SW_HIDE, $Form1_1)
GUISetState(@SW_HIDE,$FormSelectImage)
GUISetState(@SW_HIDE,$FormMensajesProgreso)
GUISetState(@SW_SHOW, $Activador)
$intOperaciones = 0
Local $ContenedorCtrl[3]
$ContenedorCtrl[0] = $Form1_1
$ContenedorCtrl[1] = $BoxDetalles
$ContenedorCtrl[2] = $lblEstado
ActualizandoStatus("Listo")
RefrescarDiscos()

While 1
	$nMsg = GUIGetMsg(1)
	;obviamos los mensajes de movimiento del mouse
	If $nMsg[0] = $GUI_EVENT_MOUSEMOVE Then
		ContinueLoop
	EndIf
	Select
		;si el mensaje es de la primera ventana
	Case $nMsg[1] = $Activador
		CambiarEstado()
		ActivarBtFormatear()
		Switch $nMsg[0]
			Case $GUI_EVENT_CLOSE
				Exit
			Case $btRefresh
				RefrescarDiscos()
;~ 				Case $btNext
;~ 					GUISetState(@SW_SHOW, $Form1_1)
;~ 					GUISetState(@SW_HIDE, $Activador)
			Case $btInstalar
				GUISetState(@SW_SHOW, $FormMensajesProgreso)
;~ 				ConsoleWrite("Disco actual: " & $DiscoActual & @CRLF)
;~ 				PrepararDiscoNuevo()
;~ 				If ValidarParticiones() Then
;~ 					ConsoleWrite("Se crearon las particiones de manera correcta")
;~ 				Else
;~ 					ConsoleWrite("No estan todas las particiones necesarias")
;~ 				EndIf

			Case $btFileSel
				Local $sWimPathFile = FileOpenDialog("Seleccione el archivo WIM conteniendo la imagen", @WindowsDir & "\", "archivos wim (*.wim)", BitOR($FD_FILEMUSTEXIST, $FD_MULTISELECT))
				If $sWimPathFile <> "" Then
					GUICtrlSetData($inFileImagePath, $sWimPathFile)
					CargaListaImagenes($sWimPathFile)
				EndIf
			Case $btCambiarImagen
				GUISetState(@SW_SHOW,$FormSelectImage)
		EndSwitch
	Case $nMsg[1] = $FormSelectImage
		EventosSelectImage()
	Case $nMsg[1] = $FormMensajesProgreso
		EventosSelectProgreso()

	;si el mensaje es de la segunda ventana
	Case $nMsg[1] = $Form1_1

		Switch $nMsg[0]
			Case $GUI_EVENT_CLOSE
				Exit

			Case $btAnterior
				GUISetState(@SW_SHOW, $activador)
				GUISetState(@SW_HIDE, $Form1_1)
	;~ 		Case $Button2
	;~ 			$aClientSize = WinGetClientSize($Form1_1)
	;~ 			MsgBox($MB_SYSTEMMODAL, "", "Width: " & $aClientSize[0] & @CRLF & "Height: " & $aClientSize[1])
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
				GUICtrlSetData($lblEstado, "Iniciando activación de particiones...")
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
				; esta sera la ruta si existe particion Recovery
				; $rutaWinre define donde se alamacenara la imagen Recovery
				$rutaWinre = "R:\Recovery\WindowsRE"
				$unidadRecovery = "R:\"
				$RutaCopiadoOrigen = "W:\Windows\System32\Recovery"
				;Si existe R: (particion Recovery)
				If FileExists($unidadRecovery) Then
					If	FileExists($rutaWinre) Or (Not FileExists($rutaWinre) And DirCreate($rutaWinre)) Then
						_MensajesEstado($ContenedorCtrl[1],$ContenedorCtrl[2],$arrayComandos[$intOperaciones][2])
						$resultado = True
					ElseIf Not FileExists($rutaWinre) Then
						_MensajesEstado($ContenedorCtrl[1],$ContenedorCtrl[2],"Error: " & $arrayComandos[$intOperaciones][3])
						ContinueLoop
					EndIf
					If Not $resultado Then
						ContinueLoop
					EndIf
				Else ;si no existe particion Recovery no ejecutaremos la primera tarea de copiado, sino la siguiente q es para copiado sin R:
					$rutaWinre = $RutaCopiadoOrigen
					_MensajesEstado($ContenedorCtrl[1],$ContenedorCtrl[2], "Se usara la particion Windows para la imagen Recovery")
					$intOperaciones = $intOperaciones + 1
				EndIf

				GUICtrlSetData($idProgressbar1, 40)
				$resultado = False
				$intOperaciones = $intOperaciones + 1

				;Copiar Winre
				$LetrasUnidad = "C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:"
				$arrayLetras = StringSplit($LetrasUnidad, '|', 1)

				;Verificamos donde esta winre.wim antes de copiarlo
				; si existe en la imagen ya desplegada
				$parametro = ''
				If FileExists($RutaCopiadoOrigen & "\winre.wim") Then
					$parametro = $RutaCopiadoOrigen
					;Aca deberiamos ir a registrar directamente, codifcar despues
				Else ; sino esta en la imagen despleada la buscamos en algun usb ya sea en la raiz o en usb\IMA
					$archivo_wim = "\winre.wim"
					$rutaFinalWinre = "\usb\IMA"
					For $Letra in $arrayLetras
						$RutaArchivo = $Letra & $rutaFinalWinre & $archivo_wim
						$rutaWinreRaiz = $Letra & $archivo_wim
						If FileExists($RutaArchivo) Then
							$parametro = $Letra & $rutaFinalWinre
						ElseIf FileExists($rutaWinreRaiz) Then
							$parametro = $Letra
						EndIf
					Next

				EndIf
				If $parametro = '' Then
					_MensajesEstado($ContenedorCtrl[1],$ContenedorCtrl[2],"Error: No se ubica el archivo WinRE.wim")
					ContinueLoop
				EndIf
				;solo copiamos si la ruta destino $rutaWinre es diferente de la ruta origen $parametro, si son iguales indica q el archivo ya existe
				If $rutaWinre <> $parametro Then
					;ejecutamos el copiado #2
					$resultado = _EjecutarTarea($ContenedorCtrl,$arrayComandos, $itemCopyWinre, $intOperaciones, $parametro)
					If Not $resultado Then
						ContinueLoop
					EndIf
				Else
					_MensajesEstado($ContenedorCtrl[1],$ContenedorCtrl[2], "El archivo WinRE.wim ya esta en el destino, se obvia la copia")
				EndIf

				$resultado = False
				$intOperaciones = $intOperaciones + $arrayComandos[$intOperaciones][4]
				GUICtrlSetData($idProgressbar1, 70)
				;Registrar Winre #3 y pasamos la ruta de la imagen a registrar
				$resultado = _EjecutarTarea($ContenedorCtrl,$arrayComandos, $itemRegWinre, $intOperaciones, $rutaWinre)

				If Not $resultado Then
					ContinueLoop
				EndIf
				GUICtrlSetData($idProgressbar1, 100)
				_MensajesEstado($ContenedorCtrl[1],$ContenedorCtrl[2], "Activadas correctamente las particiones")
		EndSwitch
	EndSelect
WEnd