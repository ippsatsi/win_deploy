
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

Func Diskpart_creacion_proceso()

	Local $Diskpart_pid, $sSalida

	$Diskpart_pid = Run("DiskPart.exe", "", @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)

	While StringRight(StdoutRead($Diskpart_pid, True, False), 10) <> "DISKPART> "
		Sleep(100)

		If Not(ProcessExists($Diskpart_pid)) Then
			MsgBox($MB_SYSTEMMODAL, "", "No se pudo inicializar diakpart ")
			$Diskpart_pid = 0
		EndIf
	Wend

	If $Diskpart_pid <> 0 Then
		$sSalida = StdoutRead($Diskpart_pid)
		ConsoleWrite($sSalida)
	EndIf
	Return $Diskpart_pid
EndFunc

Func Pausa_finalice_comando($Diskpart_pid)
	While StringRight(StdoutRead($Diskpart_pid, True, False), 10) <> "DISKPART> "
		Sleep(100)
	WEnd
EndFunc

Func LimpiarSalidaDiskpart($Diskpart_pid)
	Local $sSalidaLimpia, $sSalida

	$sSalida = StdoutRead($Diskpart_pid)
	$sSalidaLimpia = StringReplace($sSalida,@CRLF & @CRLF & "DISKPART> ", "")
	;$sSalidaLimpia = StringReplace($sSalidaLimpia, @CRLF & @CRLF, "")
	Return $sSalidaLimpia
EndFunc


Func ListarDiscos($Diskpart_pid)
	Local $sSalida
	If	$Diskpart_pid <> 0 Then
		StdinWrite($Diskpart_pid, "List Disk" & @CRLF)
		Pausa_finalice_comando($Diskpart_pid)
		$sSalida = LimpiarSalidaDiskpart($Diskpart_pid)
		ExtraerFilasTabla($sSalida)
		ConsoleWrite("_________")

		ConsoleWrite($sSalida)
		ConsoleWrite("_________")
	EndIf
EndFunc

Func ExtraerFilasTabla($sSalida)
	Local $arFilas
	$arFilas = StringSplit($sSalida, @LF, $STR_NOCOUNT)
	_ArrayDelete($arFilas, 0)
	_ArrayDelete($arFilas, 0)
	_ArrayDelete($arFilas, 0)
	_ArrayDisplay( $arFilas, "Lista Filas")

	Return $arFilas
EndFunc



