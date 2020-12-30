
Global $rutaWinre = "R:\Recovery\WindowsRE"

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

Func _EjecutarTarea2 ($xContenedorCtrl, $arrayComandos,$ctrlItem, $numTarea, $parametro = '')
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
	Else
		Return $intSize & " " & $Unidad
	EndIf
EndFunc

Func RefrescarDiscos()
	GUICtrlSetState($btRefresh, $GUI_DISABLE)
	GUICtrlSetState($btInstalar, $GUI_DISABLE)
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
		GUICtrlSetData($ctrlSelModoDisco, "Seleccione")
		GUICtrlSetState($ctrlSelModoDisco, $GUI_DISABLE)
		$DiscoActual = "N"
	Else
		GUICtrlSetState($ctrlSelModoDisco, $GUI_ENABLE)
		$DiscoActual = $ItemSelected
	EndIf
EndFunc

Func ActivarBtInstalacion()
	Local $ValorModoDisco, $sValorIndexSeleccionado
	$ValorModoDisco = GUICtrlRead($ctrlSelModoDisco)
	$sValorIndexSeleccionado = GUICtrlRead($InIndexImage)
	If $ValorModoDisco <> "nuevo" Or $sValorIndexSeleccionado = "" Then
		GUICtrlSetState($btInstalar, $GUI_DISABLE)
	Else
		GUICtrlSetState($btInstalar, $GUI_ENABLE)
	EndIf
EndFunc

Func PrepararDiscoNuevo()
	Local $sTipoDisco, $intRespuesta, $Resultado
	GUICtrlSetState($btInstalar, $GUI_DISABLE)
	If $DiscoActual = "N" Then
		$MensajeStatusError = "Error de seleccion - No ha seleccionado un disco"
		ActualizandoStatus()
		Return False
	EndIf
	$sTipoDisco = $arDisks[$DiscoActual][10]
	If $sTipoDisco = "USB" Then
		$intRespuesta = MsgBox(4,"Tipo de Disco Extraible", "El tipo de disco seleccionado es USB. ¿Esta seguro de instalar en este tipo de disco?")
		If $intRespuesta = 7 Then
			$MensajeStatusError = "No Se formateara el USB"
			ActualizandoStatus()
			Return False
		EndIf
	EndIf
	If $strSistemaSel = "BIOS" Then
		$Resultado = TareaComandosDiskpart($arPrepararMBR)
	Else
		$Resultado = TareaComandosDiskpart($arPrepararUEFI)
	EndIf
	If $Resultado Then
		Local $sError = $Resultado & " Fallo: La tarea no se pudo completar"
		RefrescarDiscos()
		$MensajeStatusError = $sError
		MensajesProgreso($MensajesInstalacion, $sError)
		Return False
	Else
		RefrescarDiscos()
		ActualizandoStatus("Se crearon las particiones en el Disco con Sist. " & $strSistemaSel)
		Return True
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
		MensajesProgreso($MensajesInstalacion, "Se crearon las particiones de manera correcta" & @CRLF )
		Return True
	Else
		MensajesProgreso($MensajesInstalacion, "No estan todas las particiones necesarias")
		Return False
	EndIf
EndFunc

Func ActualizandoStatus($status = $MensajeStatusError)
	GUICtrlSetData($ctrlStatus, $status)
	$MensajeStatusError = ""
EndFunc

Func MensajesProgreso($xBoxProgreso, $mensaje, $xlblEstado = 0)
	$gi_AlmacenTextoMensajes &= " " & $mensaje & @CRLF
	GUICtrlSetData($xBoxProgreso,$gi_AlmacenTextoMensajes)
	Return $mensaje
EndFunc

Func MensajesProgresoSinCRLF($xBoxProgreso, $mensaje, $xlblEstado = 0)
	$gi_AlmacenTextoMensajes &= $mensaje
	GUICtrlSetData($xBoxProgreso, $gi_AlmacenTextoMensajes)
	Return $mensaje
EndFunc

Func LimpiarVentanaProgreso()
	$gi_AlmacenTextoMensajes = ""
	GUICtrlSetData($MensajesInstalacion, $gi_AlmacenTextoMensajes)
EndFunc

Func FormProgreso_lblProgreso($mensaje, $mensaje_derecha = "")
	GUICtrlSetData($lblTextoProgreso, $mensaje)
	GUICtrlSetData($lblTextoProgresoDerecha, $mensaje_derecha)
EndFunc

Func f_MensajeTitulo($mensaje)
	MensajesProgreso($MensajesInstalacion, $mensaje)
	MensajesProgreso($MensajesInstalacion, _StringRepeat("-", StringLen($mensaje)*1.7))
	MensajesProgreso($MensajesInstalacion, " ")
EndFunc

Func f_KillIfProcessExists($process_name)
	While ProcessExists($process_name)
		ProcessClose($process_name)
	WEnd
EndFunc

Func f_InstalarEnDiscoNuevo()
	LimpiarVentanaProgreso()
	f_AsignarParametros()
	GUISetState(@SW_SHOW, $FormMensajesProgreso)
	;ConsoleWrite("Disco actual: " & $DiscoActual & @CRLF)
	f_MensajeTitulo("Iniciando Instalacion en Disco")
	MensajesProgreso($MensajesInstalacion, "Preparando disco " & $DiscoActual & ":")
	FormProgreso_lblProgreso("Preparando disco... ")
	If Not PrepararDiscoNuevo() Then Return
	If Not ValidarParticiones() Then Return
	If Not df_AplicarImagen($pathFileWimSel, $intIndexImageSel) Then Return
	If Not f_ActivarParticiones() Then Return
	MensajesProgreso($MensajesInstalacion, "Finalizaron todas las tareas correctamente")
	MensajesProgreso($MensajesInstalacion, "Se instalo correctamente la imagen en el Disco")
EndFunc

Func f_AsignarParametros()
	$strSistemaSel = LeerSistemaSeleccionado()
	$pathFileWimSel = GUICtrlRead($inFileImagePath)
	$intIndexImageSel = GUICtrlRead($InIndexImage)
	$strImageNameSel = GUICtrlRead($InImageName)
EndFunc

Func f_ActivarParticiones()
	f_MensajeTitulo("Activando Particiones de Sistema y Recovery:")
	;activamos particion sistema
	If Not f_TareaCMD($arrayComandos, 0, $strSistemaSel) Then Return False
	;creamos carpeta Recovery
	If DirCreate($rutaWinre)) Then
		MensajesProgreso($MensajesInstalacion, $arrayComandos[1][0])
	Else
		MensajesProgreso($MensajesInstalacion, "No se pudo crear la carpeta Recovery")
		Return False
	EndIf
	;ubicar la ruta de WinRE
	Local $rutaFileWinREaCopiar = f_UbicarWinreImagen()
	If $rutaFileWinREaCopiar = '' Then
		MensajesProgreso($MensajesInstalacion, "No se ubica el archivo WinRE, no puede continuar la instalacion")
		Return False
	EndIf
	MensajesProgreso($MensajesInstalacion, "Ubicado WinRE en: " & $rutaFileWinREaCopiar)
	;copiado de imagen winre
	If Not f_TareaCMD($arrayComandos, 2, $rutaFileWinREaCopiar) Then Return False
	;registrando WinRE: Global $rutaWinre
	If Not f_TareaCMD($arrayComandos, 3, $rutaWinre) Then Return False
	Return True
EndFunc

Func f_ReemplazarParametro($comando, $parametro)
	if $parametro <> '' Then
		Return StringReplace($comando,"??param??", $parametro)
	Else
		Return $comando
	EndIf
EndFunc


Func f_TareaCMD($arrayComando, $intNumTarea, $parametro = "")
	Local $strTxtCommando, $mensaje
	$comando = f_ReemplazarParametro($arrayComando[$intNumTarea][1], $parametro)
	$salida_correcta = $arrayComando[$intNumTarea][2]
	$nombreTarea = "    " & $arrayComando[$intNumTarea][0]
	$otro_comando = $arrayComando[$intNumTarea][3]
	MensajesProgreso($MensajesInstalacion, $nombreTarea)
	;Ejecutamos el comando
	Local $psTarea = Run(@ComSpec & " /c " & $comando, "", @SW_HIDE, $STDOUT_CHILD)
	ProcessWaitClose($psTarea)
	Local $readConsole = StdoutRead($psTarea)
	If StringInStr($readConsole, $salida_correcta) Then
		Return True
	Else
		MensajesProgreso($MensajesInstalacion, "Error: " & $nombreTarea & " no se pudo completar la tarea")
		MensajesProgreso($MensajesInstalacion, "La tarea produjo esta salida:" & @CRLF & $readConsole)
;~ 		GUICtrlSetData($xContenedorCtrl[1], $readConsole & @CRLF, 1)
		Return False
	EndIf
EndFunc

Func f_UbicarWinreImagen()
	Local $RutaArchivo, $rutaWinreRaiz
	Local $RutaCopiadoOrigen = "W:\Windows\System32\Recovery"
	Local $LetrasUnidad = "C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:"
	Local $arrayLetras = StringSplit($LetrasUnidad, '|', 1)

	;Verificamos donde esta winre.wim antes de copiarlo
	; si existe en la imagen ya desplegada
	Local $parametro = ''
	If FileExists($RutaCopiadoOrigen & "\winre.wim") Then
		$parametro = $RutaCopiadoOrigen
		;Aca deberiamos ir a registrar directamente, codifcar despues
	Else ; sino esta en la imagen despleada la buscamos en algun usb ya sea en la raiz o en usb\IMA
		Local $archivo_wim = "\winre.wim"
		Local $rutaFinalWinre = "\usb\IMA"
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
	Return $parametro
EndFunc



