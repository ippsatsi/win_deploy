
#Dependencias
;ReemplazarCaracteresEspanol()
;_ConvertirGBbinToGBdecimal()

;Opciones Diskpart
Global $arDisks
Global $arParticiones
Global $Diskpart_pid = 0
Global $DiscoActual = "N"


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

Func LimpiarSalidaDiskpart($Diskpart_pid)
	Local $sSalidaLimpia, $sSalida
	$sSalida = StdoutRead($Diskpart_pid)
	;eliminamos el prompt al final de la salida
	$sSalida = ReemplazarCaracteresEspanol($sSalida)
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

Func TareaComandosDiskpart($arrayComando)
	Local $sSalida, $OK,  $arComando, $sSalidaComandos = '', $comando, $salida_correcta, $otro_comando, $nombreTarea
	If $DiscoActual = "N" Then
		ActualizandoStatus("Error de seleccion - No ha seleccionado un disco")
		Return
	EndIf
	$Diskpart_pid = Diskpart_creacion_proceso()
	If SeleccionarDisco($Diskpart_pid, $DiscoActual) Then
		FormProgreso_CambiarBtCerrarXCancelar()
		For $i = 0 To UBound($arrayComando) - 1
			$comando = $arrayComando[$i][0]
			$salida_correcta = $arrayComando[$i][1]
			$nombreTarea = "    " & $arrayComando[$i][2]
			$otro_comando = $arrayComando[$i][3]
			If $otro_comando Then
				Execute($otro_comando)
			Else
				;ActualizandoStatus($nombreTarea)
				MensajesProgreso($MensajesInstalacion, $nombreTarea)
				$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, $comando, $salida_correcta)
				$sSalidaComandos = "tarea " & $i & ":" & $nombreTarea & " - " & $sSalida & @CRLF
				If $sSalida Then Return $sSalidaComandos
			EndIf
			$n = 0
			While $n < 10
			If FormProgreso_SondearCancelacionCierre() Then
;~ 				Return MensajesProgreso($MensajesInstalacion, "  ----- Operacion Cancelada ----- ")
				Return "  ----- Operacion Cancelada ----- "
			EndIf
			Sleep(1)
			$n = $n + 1
			WEnd

		Next
		Return False
	EndIf
EndFunc

