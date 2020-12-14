
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

	Local $sSalida

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

Func DiskpartCerrarProceso($Diskpart_pid)
	If $Diskpart_pid <> 0 Then
		StdinWrite($Diskpart_pid, "exit" & @CRLF)
		$Diskpart_pid = 0
	EndIf
EndFunc


Func Pausa_finalice_comando($Diskpart_pid)
	While StringRight(StdoutRead($Diskpart_pid, True, False), 10) <> "DISKPART> "
		Sleep(100)
	WEnd
EndFunc

Func LimpiarSalidaDiskpart($Diskpart_pid)
	Local $sSalidaLimpia, $sSalida

	$sSalida = StdoutRead($Diskpart_pid)
	;corregir carateres extraños
	$sSalida = StringReplace($sSalida, "S¡", "Si")
	$sSalida = StringReplace($sSalida, "¡", "í")
	$sSalida = StringReplace($sSalida, "£", "ú")
	$sSalida = StringReplace($sSalida, "¢", "ó")
	$sSalida = StringReplace($sSalida, "¤", "ñ")
	;eliminamos el prompt al final de la salida
	$sSalidaLimpia = StringReplace($sSalida,@CRLF & @CRLF & "DISKPART> ", "")
	;$sSalidaLimpia = StringReplace($sSalidaLimpia, @CRLF & @CRLF, "")
	Return $sSalidaLimpia
EndFunc

Func EjecutarComandoDiskpart($Diskpart_pid, $comando)
	If	$Diskpart_pid <> 0 Then
		StdinWrite($Diskpart_pid, $comando & @CRLF)
		Pausa_finalice_comando($Diskpart_pid)
		$sSalida = LimpiarSalidaDiskpart($Diskpart_pid)
		Return $sSalida
	Else
		ConsoleWrite("Error Ejecutando Diskpart")
		Return 1
	EndIf
EndFunc

Func _ConvertirGBbinToGBdecimal($intSize, $Unidad)
	If StringInStr($Unidad, "GB") Then
		Return  String(Round(Number($intSize) * 1.075)) & " GB"   ;1024  * 1024 * 1024
;		Return  String(Round(Number($size) * $FactorConversion)) & " GB"   ;1024  * 1024 * 1024
	Else
		Return $intSize & " " & $Unidad
	EndIf
EndFunc

Func ListarDiscos($Diskpart_pid)
	Local $sSalida
	$sSalida = EjecutarComandoDiskpart($Diskpart_pid, "list disk")
	ExtraerListaDiscos($sSalida)
 	;ConsoleWrite("_________")
	;ConsoleWrite($sSalida)
 	;ConsoleWrite("_________")
EndFunc

Func QuitarCabeceraTabla(ByRef $sSalida)
	;dividimos en lineas o filas
	$sSalida = StringSplit($sSalida, @LF, $STR_NOCOUNT)
	;eliminamos las 3 primeras filas, q son parte de la cabecera de la tabla
	_ArrayDelete($sSalida, 0)
	_ArrayDelete($sSalida, 0)
	_ArrayDelete($sSalida, 0)
EndFunc


Func ExtraerListaDiscos($sSalida)
	Local $arFilas, $i, $arSize

	$arFilas = $sSalida
	QuitarCabeceraTabla($arFilas)
	;_ArrayDisplay( $arFilas, "Lista Filas")
	Dim $arDisks[UBound($arFilas)][17]

	For $i = 0 to UBound($arFilas) - 1
		;# de disco
		$sDato = StringMid($arFilas[$i], 9,1)
		$arDisks[$i][0] = $sDato
		;Status  - si esta en linea
		$sDato = StringMid($arFilas[$i], 14,9)
		$arDisks[$i][1] = $sDato
		; Tamaño de disco
		$sDato = StringMid($arFilas[$i], 28,8)
		$arSize = StringSplit(StringStripWS($sDato,7)," ",2)
		;_ArrayDisplay( $arSize, "Lista Filas")
		$arDisks[$i][2] = _ConvertirGBbinToGBdecimal($arSize[0], $arSize[1])
		$arDisks[$i][3] = $arSize[1] ;Unidad
		;Espacio disponible
		$sDato = StringMid($arFilas[$i], 38,7)
		$arSize = StringSplit(StringStripWS($sDato,7)," ",2)
		$arDisks[$i][4] = _ConvertirGBbinToGBdecimal($arSize[0], $arSize[1])
		$arDisks[$i][5] = $arSize[1] ;Unidad
		; Si es dinamico
		$sDato = StringMid($arFilas[$i], 48,1)
		$arDisks[$i][6] = $sDato
		; Si es mbr o uefi o vacio
		$sDato = StringMid($arFilas[$i], 53,1)
		$arDisks[$i][7] = $sDato
	Next
;~ 	_ArrayDisplay( $arDisks, "Lista Filas")
	Return $arFilas
EndFunc

Func SeleccionarDisco($Diskpart_pid, $intNumDisco)
	Local $sSalida, $OK

	$sSalida = EjecutarComandoDiskpart($Diskpart_pid, "sel disk " & $intNumDisco)
	If StringInStr($sSalida, "El disco " & $intNumDisco & " es ahora el disco seleccionado") > 0 Then
;~ 		ConsoleWrite($sSalida & "??????")
		Return True
	Else
		Return False
	EndIf
EndFunc

Func ExtraerValorParametro($ParamValor)
	Local $arParametro
	$arParametro = StringSplit(StringStripWS($ParamValor,7), ":",2)
	;una vez extraido, le limpiamos los espacios
	Return StringStripWS($arParametro[1],3)
EndFunc

Func ExtraerDetalleDisco($sSalida, $idArrarDisks)
	; lo dividimos en lineas
	;ConsoleWrite($sSalida)
	$sSalida = StringSplit($sSalida, @LF, $STR_NOCOUNT)
	$arDisks[$idArrarDisks][8] = $sSalida[1] ; Modelo
	$arDisks[$idArrarDisks][9] = ExtraerValorParametro($sSalida[2]) ;Id de disco
	If $arDisks[$idArrarDisks][9] = "00000000" Then
		$arDisks[$idArrarDisks][7] = "vacio"
	ElseIf $arDisks[$idArrarDisks][7] = "*" Then
		$arDisks[$idArrarDisks][7] = "UEFI"
	Else
		$arDisks[$idArrarDisks][7] = "MBR"
	EndIf

	$arDisks[$idArrarDisks][10] = ExtraerValorParametro($sSalida[3]) ;Tipo de conexion
EndFunc

Func RellenarCtrlList()
	;Local $ctrlListFila
	GUICtrlSendMsg($idListDiscos, $LVM_DELETEALLITEMS, 0, 0)	; Limpiamos el ctrl Lista
	If $Diskpart_pid <> 0 Then
		Dim $ctrlListFila[Ubound($arDisks)]
		For $idLista = 0 To UBound($arDisks) - 1
			GUICtrlCreateListViewItem($arDisks[$idLista][0] & "|" & $arDisks[$idLista][8] & "|" & _
				$arDisks[$idLista][7] & "|" & $arDisks[$idLista][2] & "|" & $arDisks[$idLista][4] & "|" & _
				$arDisks[$idLista][10] & "|" & $arDisks[$idLista][1], $idListDiscos)
		Next
	Else
		GUICtrlCreateListViewItem("x|Error en|comando|diskpart|x|x" , $idListDiscos)
	EndIf
EndFunc

Func ObtenerInfoDisco($Diskpart_pid)
	Local $intNumDisco, $sSalida

	For $idArray = 0 To UBound($arDisks) - 1
		; Seleccionamos disco
		$intNumDisco = $arDisks[$idArray][0]
		If StringIsDigit($intNumDisco) = 1 Then
			If SeleccionarDisco($Diskpart_pid, $intNumDisco) Then
				$sSalida = EjecutarComandoDiskpart($Diskpart_pid, "detail disk")
				ExtraerDetalleDisco($sSalida, $idArray)
;~ 				ConsoleWrite($sSalida)
			Else
				ConsoleWrite("Error en la seleccion de disco")
				$Diskpart_pid = 0
				Return
			EndIf
		Else
			ConsoleWrite("Error en el numero de disco" & $intNumDisco)
			$Diskpart_pid = 0
			Return
		EndIf
	Next
	RellenarCtrlList()
	;_ArrayDisplay( $arDisks, "Lista Filas")
EndFunc

Func RefrescarDiscos()
	GUICtrlSetState($btRefresh, $GUI_DISABLE)
	$Diskpart_pid = Diskpart_creacion_proceso()
	ListarDiscos($Diskpart_pid)
	ObtenerInfoDisco($Diskpart_pid)
	GUICtrlSetState($btRefresh, $GUI_ENABLE)
	DiskpartCerrarProceso($Diskpart_pid)
	$Diskpart_pid = 0
	GUICtrlSetState($ctrlSelModoDisco, $GUI_DISABLE)
EndFunc

Func CambiarEstado()
	Local $ItemSelected
	$ItemSelected = ControlListView($Form1_0, "", $idListDiscos,"GetSelected")
	If $ItemSelected = "" Then
		;ConsoleWrite("nada" & @CRLF)
		GUICtrlSetData($ctrlSelModoDisco, "Seleccione")
		GUICtrlSetState($ctrlSelModoDisco, $GUI_DISABLE)
	Else
		;ConsoleWrite("sel: " & $ItemSelected)
		GUICtrlSetState($ctrlSelModoDisco, $GUI_ENABLE)
	EndIf

EndFunc



