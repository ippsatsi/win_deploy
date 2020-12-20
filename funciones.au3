
Func _CirculoResultado ($x, $y, $color)

	Local $Verde = 0x00ff00
	Local $Rojo = 0xff0000
	Local $circ_color = $Rojo
	If $color = "verde" Then
		$circ_color = $Verde
	EndIf
	Local $a=GuiCtrlCreateGraphic($x, $y, 10,10)
	GUICtrlSetGraphic(-1,$GUI_GR_COLOR, $circ_color,$circ_color)
	GUICtrlSetGraphic(-1,$GUI_GR_ELLIPSE,1,1,8,8)
	GuiCtrlSetState($a, $GUI_SHOW)
	Return $a
EndFunc

Func _EjecutarTarea ($xContenedorCtrl, $arrayComandos,$ctrlItem, $numTarea, $parametro = '')
	Local $txtCommandLine
	Local $posX, $posY
	Local $arrayComando[4]
	Local $resultado = False

	$arrayComando[0] = $arrayComandos[$numTarea][0]
	$arrayComando[1] = $arrayComandos[$numTarea][1]
	$arrayComando[2] = $arrayComandos[$numTarea][2]
	$arrayComando[3] = $arrayComandos[$numTarea][3]
	if $parametro <> '' Then
		$txtCommandLine = StringReplace($arrayComando[1],"??param??", $parametro)
	Else
		$txtCommandLine = $arrayComando[1]
	EndIf
;,
	;Local $txtCommandLine = 'W:\Windows\System32\bcdboot W:\Windows /l es-mx /s S: /f ' & $txtBootOption
	;en la caja de detalles insertamos un Enter para q se vea mas limpio
	GUICtrlSetData($xContenedorCtrl[1], @CRLF, 1)
	; mostramos mensaje de inicio de tares
	_MensajesEstado($xContenedorCtrl[1],$xContenedorCtrl[2], $arrayComando[0])
	GUICtrlSetData($xContenedorCtrl[1], _StringRepeat("=", StringLen($arrayComando[0])) & @CRLF, 1)
	;insertamos la linea de comandos a ejecutar
	GUICtrlSetData($xContenedorCtrl[1], $txtCommandLine & @CRLF, 1)

	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	ProcessWaitClose($psTarea)
	Local $readConsole = StdoutRead($psTarea)
	; obtenemos la posicion del control, para colocarle a su costado la luz roja o verde segun el resultado
	$arrayPos = ControlGetPos($xContenedorCtrl[0], "", $ctrlItem )
	$posX = $arrayPos[0]
	$posY = $arrayPos[1]
	If StringInStr($readConsole, $arrayComando[2]) Then
		$b = _CirculoResultado($posX - 12, $posY + 2 , "verde")

		_MensajesEstado($xContenedorCtrl[1],$xContenedorCtrl[2], $arrayComando[2])
		$resultado = True
	Else
		$b = _CirculoResultado($posX - 12, $posY + 2, "rojo")
		_MensajesEstado($xContenedorCtrl[1],$xContenedorCtrl[2], "Error: " & $arrayComando[3])
		GUICtrlSetData($xContenedorCtrl[1], $readConsole & @CRLF, 1)
	EndIf

	Return $resultado
EndFunc

Func _MensajesEstado ($xBoxDetalles, $xlblEstado, $mensaje)
	GUICtrlSetData($xBoxDetalles, $mensaje & @CRLF, 1)
	GUICtrlSetData($xlblEstado, $mensaje)
EndFunc

Func LeerSistemaSeleccionado()
	If	GUICtrlRead($ck_UEFI) = $GUI_CHECKED Then
		$txtBootOption = "UEFI"
	Else
		$txtBootOption = "BIOS"
	EndIf
	Return $txtBootOption
EndFunc

Func ReemplazarCaracteresEspanol($sSalida)
	;corregir carateres extraños
	$sSalida = StringReplace($sSalida, "S¡", "Si")
	$sSalida = StringReplace($sSalida, "¡", "í")
	$sSalida = StringReplace($sSalida, "£", "ú")
	$sSalida = StringReplace($sSalida, "¢", "ó")
	$sSalida = StringReplace($sSalida, "¤", "ñ")
	$sSalida = StringReplace($sSalida, "Ö", "Í")
	Return $sSalida
EndFunc

Func _ConvertirGBbinToGBdecimal($intSize, $Unidad)
	If StringInStr($Unidad, "GB") Then
		Return  String(Round(Number($intSize) * 1.075)) & " GB"   ;1024  * 1024 * 1024
;		Return  String(Round(Number($size) * $FactorConversion)) & " GB"   ;1024  * 1024 * 1024
	Else
		Return $intSize & " " & $Unidad
	EndIf
EndFunc

Func RefrescarDiscos()
	GUICtrlSetState($btRefresh, $GUI_DISABLE)
	$Diskpart_pid = Diskpart_creacion_proceso()
	ActualizandoStatus("Examinando Discos...")
	ListarDiscos($Diskpart_pid)
	ObtenerInfoDisco($Diskpart_pid)
	GUICtrlSetState($btRefresh, $GUI_ENABLE)
	DiskpartCerrarProceso($Diskpart_pid)
	ActualizandoStatus("Listo")
	$Diskpart_pid = 0
	GUICtrlSetState($ctrlSelModoDisco, $GUI_DISABLE)
EndFunc

Func CambiarEstado()
	Local $ItemSelected
	$ItemSelected = ControlListView($Activador, "", $idListDiscos,"GetSelected")
	If $ItemSelected = "" Then
		;ConsoleWrite("nada" & @CRLF)
		GUICtrlSetData($ctrlSelModoDisco, "Seleccione")
		GUICtrlSetState($ctrlSelModoDisco, $GUI_DISABLE)
		$DiscoActual = "N"
	Else
		;ConsoleWrite("sel: " & $ItemSelected)
		GUICtrlSetState($ctrlSelModoDisco, $GUI_ENABLE)
		$DiscoActual = $ItemSelected
		$Diskpart_pid = Diskpart_creacion_proceso()
	EndIf
EndFunc

Func ActivarBtFormatear()
	Local $ValorModoDisco
	$ValorModoDisco = GUICtrlRead($ctrlSelModoDisco)
	If $ValorModoDisco <> "nuevo" Then
		GUICtrlSetState($btInstalar, $GUI_DISABLE)
	Else
		GUICtrlSetState($btInstalar, $GUI_ENABLE)
	EndIf
EndFunc

Func PrepararDiscoNuevo()
	Local $sTipoDisco, $intRespuesta, $Resultado
	GUICtrlSetState($btInstalar, $GUI_DISABLE)
	If $DiscoActual = "N" Then
;~ 		MsgBox(0, "Error de seleccion", "No ha seleccionado un disco")
		$MensajeStatusError = "Error de seleccion - No ha seleccionado un disco"
		ActualizandoStatus()
		Return
	EndIf
	$sTipoDisco = $arDisks[$DiscoActual][10]
	If $sTipoDisco = "USB" Then
		$intRespuesta = MsgBox(4,"Tipo de Disco Extraible", "El tipo de disco seleccionado es USB. ¿Esta seguro de instalar en este tipo de disco?")
		If $intRespuesta = 7 Then
			$MensajeStatusError = "No Se formateara el USB"
			ActualizandoStatus()
			Return
		EndIf
	EndIf
	Local $SelectedSystem = LeerSistemaSeleccionado()
	If $SelectedSystem = "BIOS" Then
		$Resultado = TareaComandosDiskpart($arPrepararMBR)
	Else
		$Resultado = TareaComandosDiskpart($arPrepararUEFI)
	EndIf
	If $Resultado Then
		Local $sError = GUICtrlRead($ctrlStatus) & " Fallo: La tarea no se pudo completar"
		RefrescarDiscos()
		$MensajeStatusError = $sError
		ActualizandoStatus()
	Else
		RefrescarDiscos()
		ActualizandoStatus("Se crearon las particiones en el Disco con Sist. " & $SelectedSystem)
	EndIf
EndFunc

Func ValidarParticiones()
	Local $arUnidadesSistema, $i, $Unidad, $LetraBuscar, $LabelBuscar, $flag = 0
	$arUnidadesSistema = DriveGetDrive($DT_ALL)
	For $Unidad = 0 To 2
		$LetraBuscar = $arUnidadesBasicas[$Unidad][0]
		$LabelBuscar = $arUnidadesBasicas[$Unidad][1]
		For $i = 0 To $arUnidadesSistema[0]
			If $arUnidadesSistema[$i] = $LetraBuscar Then
				$Label = DriveGetLabel($arUnidadesSistema[$i]  & "\")
				If $Label = $LabelBuscar Then
					$flag = $flag + 1
				EndIf
			EndIf
		Next
	Next
	If $flag = 3 Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func ActualizandoStatus($status = $MensajeStatusError)
	GUICtrlSetData($ctrlStatus, $status)
	$MensajeStatusError = ""
EndFunc

Func _MensajesProgreso($xBoxProgreso, $mensaje, $xlblEstado = 0)
	GUICtrlSetData($xBoxProgreso, $mensaje & @CRLF, 1)
;~ 	GUICtrlSetData($xlblEstado, $mensaje)
EndFunc


