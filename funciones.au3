
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
;~ 		ConsoleWrite($sSalida)
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

Func LimpiarSalidaDiskpart($Diskpart_pid)
	Local $sSalidaLimpia, $sSalida

	$sSalida = StdoutRead($Diskpart_pid)
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

Func EjecutarCompararComandoDiskpart($Diskpart_pid, $comando, $sSalidaAComparar)
	;cuando la funcion se ejecute correctamente, su salida sera False, sino seran los mensajes de error generados
	Local $sErrores
	If	$Diskpart_pid <> 0 Then
		StdinWrite($Diskpart_pid, $comando & @CRLF)
		Pausa_finalice_comando($Diskpart_pid)
		$sSalida = LimpiarSalidaDiskpart($Diskpart_pid)
		If StringInStr($sSalida, $sSalidaAComparar) Then
			Return False
		EndIf
		$sErrores = "Comando no tuvo la salida esperada" & @CRLF
		$sErrores = $sErrores & "salida incorrecta:" & $sSalida  & @CRLF
		Return $sErrores
	EndIf
	$sErrores = "Proceso Diskpart no disponible" & @CRLF
	Return $sErrores
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
	GUICtrlSendMsg($idListDiscos, $LVM_DELETEALLITEMS, 0, 0)	; Limpiamos el ctrl Lista
	If $Diskpart_pid <> 0 Then
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
	GUICtrlSetState($btFormatear, $GUI_DISABLE)
	If $DiscoActual = "N" Then
		MsgBox(0, "Error de seleccion", "No ha seleccionado un disco")
		Return
	EndIf
	$sTipoDisco = $arDisks[$DiscoActual][10]
	If $sTipoDisco = "USB" Then
		$intRespuesta = MsgBox(4,"Tipo de Disco Extraible", "El tipo de disco seleccionado es USB. ¿Esta seguro de instalar en este tipo de disco?")
		If $intRespuesta = 7 Then
			ConsoleWrite("No Se formateara el USB")
			Return
		EndIf
	EndIf
	$Resultado = TareaComandosDiskpart($arPrepararMBR)
	If $Resultado Then
		ConsoleWrite("Fallo: " & $Resultado & @CRLF)
	EndIf

EndFunc

Func CrearDiscoUEFI()
	Local $sSalida, $OK,  $sSalidaComandos = ''
	If $DiscoActual = "N" Then
		MsgBox(0, "Error de seleccion", "No ha seleccionado un disco")
		Return
	EndIf
	$Diskpart_pid = Diskpart_creacion_proceso()
	If SeleccionarDisco($Diskpart_pid, $DiscoActual) Then
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, "clean", "ha limpiado")
		$sSalidaComandos = "clean:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, "convert gpt", "correctamente el disco")
		$sSalidaComandos = $sSalidaComandos & "convert:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, "create partition efi size=100", "creado satisfactoriamente la")
		$sSalidaComandos = $sSalidaComandos & "create1:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'format quick fs=fat32 label="System"', 'volumen correctamente')
		$sSalidaComandos = $sSalidaComandos & "format1:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		;Creamos un retraso para darle tiempo al sistema q libere las letras de unidad, en el caso q estemos reintentando
		Execute("Sleep(2000)")
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'assign letter="S"', "correctamente")
		$sSalidaComandos = $sSalidaComandos & "assign1:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'create partition msr size=16', "ha creado satisfactoriamente")
		$sSalidaComandos = $sSalidaComandos & "create2:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'create partition primary', "creado satisfactoriamente la")
		$sSalidaComandos = $sSalidaComandos & "create3:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'shrink minimum=650', "correctamente")
		$sSalidaComandos = $sSalidaComandos & "shrink:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'format quick fs=ntfs label="Windows"', "correctamente")
		$sSalidaComandos = $sSalidaComandos & "format2:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'assign letter="W"', "correctamente")
		$sSalidaComandos = $sSalidaComandos & "assign2:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'create partition primary', "creado satisfactoriamente la")
		$sSalidaComandos = $sSalidaComandos & "create4:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'format quick fs=ntfs label="Recovery tools"', "correctamente")
		$sSalidaComandos = $sSalidaComandos & "format3:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'assign letter="R"', "correctamente")
		$sSalidaComandos = $sSalidaComandos & "assign3:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac" override', "correctamente")
		$sSalidaComandos = $sSalidaComandos & "set:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, 'gpt attributes=0x8000000000000001', "correctamente")
		$sSalidaComandos = $sSalidaComandos & "gpt1:" & $sSalida & @CRLF
		If $sSalida Then Return $sSalidaComandos
		Return False
	EndIf
EndFunc

Func TareaComandosDiskpart($arrayComando)
	Local $sSalida, $OK,  $arComando, $sSalidaComandos = '', $comando, $salida_correcta, $otro_comando, $nombreTarea
	If $DiscoActual = "N" Then
		MsgBox(0, "Error de seleccion", "No ha seleccionado un disco")
		Return
	EndIf
	$Diskpart_pid = Diskpart_creacion_proceso()
	If SeleccionarDisco($Diskpart_pid, $DiscoActual) Then
		For $i = 0 To UBound($arrayComando) - 1
			$comando = $arrayComando[$i][0]
			$salida_correcta = $arrayComando[$i][1]
			$nombreTarea = $arrayComando[$i][2]
			$otro_comando = $arrayComando[$i][3]
			If $otro_comando Then
				Execute($otro_comando)
			Else
				$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, $comando, $salida_correcta)
				$sSalidaComandos = "tarea " & $i & ":" & $nombreTarea & " - " & $sSalida & @CRLF
				If $sSalida Then Return $sSalidaComandos
			EndIf
		Next
		Return False
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



