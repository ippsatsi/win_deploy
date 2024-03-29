#include <GuiEdit.au3>
#include <ScrollBarsConstants.au3>

Global $arParticionesSistema[3][2], $estadoCancelar = False, $flagRecoveryAdyacente = False
Global $rutaWinre = "R:\Recovery\WindowsRE"
;20 puntos para preparacion de disco
;60 puntos para aplicacion de imagenes
;20 puntos para activacion de particiones

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

Func ExtraerRutaPadre($Ruta)
	;extraemos la ruta al folder donde ubicamos el archivo WIM, y usamos la misma ruta
	;para el archivo Recovery.wim
	Local $intUltimoBackslash = StringInStr($Ruta, "\",0,-1)
	Local $strLocationFolderDestino = StringMid($Ruta, 1, $intUltimoBackslash)
	Return $strLocationFolderDestino
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
	ActualizandoStatus("Examinando Discos...")
	$Diskpart_pid = Diskpart_creacion_proceso()
	ListarDiscos($Diskpart_pid)
	ObtenerInfoDisco($Diskpart_pid)
	GUICtrlSetState($btRefresh, $GUI_ENABLE)
	DiskpartCerrarProceso($Diskpart_pid)
	ActualizandoStatus("Listo")
	$Diskpart_pid = 0
	GUICtrlSetState($ctrlSelModoDisco, $GUI_DISABLE)
	;se comenta, ya no sera necesario desde la version 2.0
	;GUICtrlSetState($btExtractWinRE, $GUI_DISABLE)
EndFunc

Func CambiarEstado()
	Local $ItemSelected
	$ItemSelected = ControlListView($Activador, "", $idListDiscos,"GetSelected")
	If $ItemSelected = "" Then
		GUICtrlSetData($ctrlSelModoDisco, "Seleccione")
		GUICtrlSetState($ctrlSelModoDisco, $GUI_DISABLE)
		;se comenta, ya no sera necesario desde la version 2.0
		;GUICtrlSetState($btExtractWinRE, $GUI_DISABLE)
		$DiscoActual = "N"
	Else
		GUICtrlSetState($ctrlSelModoDisco, $GUI_ENABLE)
		;se comenta, ya no sera necesario desde la version 2.0
		;GUICtrlSetState($btExtractWinRE, $GUI_ENABLE)
		$DiscoActual = $ItemSelected
	EndIf
 EndFunc
;~ Funcion para buscar discos vacios y seleccionarlos automaticamente
 Func f_AutoSelect()
	Local $numDevices, $sistDisco, $interfaceDisco, $setSelect, $i
	$numDevices = ControlListView($Activador, "", $idListDiscos,"GetItemCount") ;obtenemos cantidad de discos en el ListView
	If $numDevices < 1 Then Return True
    $i = 0
	$setSelect = False
    Do
	   $sistDisco = ControlListView($Activador, "", $idListDiscos, "GetText", $i, 2) ;obtenemos el dato de la columna SISTEMA
	   $interfaceDisco = ControlListView($Activador, "", $idListDiscos, "GetText", $i, 5) ;obtenemos el dato de la columna interface
;~ 	   MsgBox(0, "prueba boton", "$i: " & $i & " $sistDisco: " & $sistDisco & " $interfaceDisco: " & $interfaceDisco )
	   If $sistDisco == "vacio" And $interfaceDisco <> "USB" Then
		   ControlListView($Activador, "", $idListDiscos,"SelectClear")
		   ControlListView($Activador, "", $idListDiscos,"Select", $i )
		   GUICtrlSetData($ctrlSelModoDisco, $ModoDiscoTotal)
		   GUICtrlSetState($ctrlSelModoDisco, $GUI_ENABLE)
		   $setSelect = True
		EndIf
		$i += 1
	Until ($i = $numDevices) Or ($setSelect)
 EndFunc

Func ActivarBtInstalacion()
	Local $ValorModoDisco, $sValorIndexSeleccionado, $ItemSelected
    $ItemSelected = ControlListView($Activador, "", $idListDiscos,"GetSelected")
	$ValorModoDisco = GUICtrlRead($ctrlSelModoDisco)
	$sValorIndexSeleccionado = GUICtrlRead($InIndexImage)
;~ 	Activamos bt Instalar solo si esta seleccionada alguna opcion NUEVO/REINSTALACION y ya imagen ya fue seleccionada
    If $ValorModoDisco = "Seleccione" Or $sValorIndexSeleccionado = "" Then
		GUICtrlSetData($btInstalar, "Instalar")
		GUICtrlSetState($btInstalar, $GUI_DISABLE)
;~ 	 ElseIf $ValorModoDisco = "Nuevo" Then
;~ 		GUICtrlSetData($btInstalar, "Inst. Rapida")
;~ 		GUICtrlSetState($btInstalar, $GUI_ENABLE)
;~ 		gi_estadoActivadorSistInstalacion($GUI_ENABLE)
	 Else
		GUICtrlSetData($btInstalar, "Instalar")
		GUICtrlSetState($btInstalar, $GUI_ENABLE)
		gi_estadoActivadorSistInstalacion($GUI_ENABLE)
	 EndIf
	 ; solo si el disco esta vacio, adveritmos q una reinstalacion no es valida
	 $sistDisco = ControlListView($Activador, "", $idListDiscos, "GetText", $ItemSelected, 2) ;obtenemos el dato de la columna SISTEMA
     If $sistDisco = "vacio" And $ValorModoDisco = "Reinstalacion" Then
		 MsgBox($MB_SYSTEMMODAL, "Disco vacio", "No es posible reinstalar en un disco sin particiones")
		 GUICtrlSetData($ctrlSelModoDisco, "Seleccione")
		 CambiarEstado()
	 EndIf
EndFunc

Func DetectarDiscoUSB()
	$sTipoDisco = $arDisks[$DiscoActual][10]
	If $sTipoDisco = "USB" Then
		Local $intRespuesta = MsgBox(4,"Tipo de Disco Extraible", "El tipo de disco seleccionado es USB. ¿Esta seguro de instalar en este tipo de disco?")
		If $intRespuesta = 7 Then
			$MensajeStatusError = "No Se formateara el USB"
			ActualizandoStatus()
			Return True
		EndIf
	EndIf
	Return False
EndFunc

Func PrepararDisco($flgDiscoEntero)
	Local $sTipoDisco, $intRespuesta, $Resultado
	GUICtrlSetState($btInstalar, $GUI_DISABLE)
	If $DiscoActual = "N" Then
		$MensajeStatusError = "Error de seleccion - No ha seleccionado un disco"
		ActualizandoStatus()
		Return False
	EndIf
;~ 	If DetectarDiscoUSB() Then Return False
;~ 	$sTipoDisco = $arDisks[$DiscoActual][10]
;~ 	If $sTipoDisco = "USB" Then
;~ 		$intRespuesta = MsgBox(4,"Tipo de Disco Extraible", "El tipo de disco seleccionado es USB. ¿Esta seguro de instalar en este tipo de disco?")
;~ 		If $intRespuesta = 7 Then
;~ 			$MensajeStatusError = "No Se formateara el USB"
;~ 			ActualizandoStatus()
;~ 			Return False
;~ 		EndIf
;~ 	EndIf

	If $strSistemaSel = "BIOS" Then
		$arrayCmdDisco = $arPrepararMBR
;~ 		$Resultado = TareaComandosDiskpart($arPrepararMBR)
	Else
		$arrayCmdDisco = $arPrepararUEFI
;~ 		$Resultado = TareaComandosDiskpart($arPrepararUEFI)
	EndIf
	;si es instalacion a particion, borramos las tareas no necesarias
	If Not $flgDiscoEntero Then
		;si no es adyacente eliminamos la tarea "shrink"
		If Not $flagRecoveryAdyacente Then
			_ArrayDelete($arrayCmdDisco, 8) ; tarea shrink
		EndIf

		_ArrayDelete($arrayCmdDisco, "0;1") ; tarea borrado disco
	EndIf

	$Resultado = TareaComandosDiskpart($arrayCmdDisco)
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
	;$xBoxProgreso, es el id del control
	; $gi_AlmacenTextoMensajes es donde se acumula la salida de los comandos
	$gi_AlmacenTextoMensajes &= " " & $mensaje & @CRLF
	GUICtrlSetData($xBoxProgreso,$gi_AlmacenTextoMensajes)
	_GUICtrlEdit_Scroll($xBoxProgreso, $SB_SCROLLCARET)
	Return $mensaje
EndFunc

Func MensajesProgresoSinCRLF($xBoxProgreso, $mensaje, $xlblEstado = 0)
	;$xBoxProgreso, es el id del control
	; $gi_AlmacenTextoMensajes es donde se acumula la salida de los comandos
	$gi_AlmacenTextoMensajes &= $mensaje
	GUICtrlSetData($xBoxProgreso, $gi_AlmacenTextoMensajes)
	Return $mensaje
EndFunc

Func f_MensajesProgreso_MostrarProgresoTexto($xBoxProgreso, $mensaje)
	;$xBoxProgreso, es el id del control
	; $gi_AlmacenTextoMensajes es donde se acumula la salida de los comandos
	; Aca a diferencia de las funciones anteriores, mantenemos sin actualizar el $gi_AlmacenTextoMensajes, y solo actualizamos el
	; el $mensaje con la nueva data
	GUICtrlSetData($xBoxProgreso, $gi_AlmacenTextoMensajes & $mensaje)
	Return $mensaje
EndFunc

Func f_ProgresoTexto($intValor, $intMOD)
	If $intValor > 100 Or $intValor < 0 Then Return "Error en lectura progreso"
	$strProgresoTexto = "   ["
	For $i = 0 To $intValor
		If Mod($i,$intMOD) = 0 Then $strProgresoTexto &= "="
	Next
	For $i = ($intValor + 1) To 100
		If Mod($i,$intMOD) = 0 Then $strProgresoTexto &= "  "
	Next
	$strProgresoTexto &= "]"
	Return $strProgresoTexto
EndFunc

Func LimpiarVentanaProgreso()
	$gi_AlmacenTextoMensajes = ""
	$intBarraProgresoGUI = 0
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
;~ 	LimpiarVentanaProgreso()
;~ 	f_AsignarParametros()

	GUISetState(@SW_SHOW, $FormMensajesProgreso)
   ;ConsoleWrite("Disco actual: " & $DiscoActual & @CRLF)
	f_MensajeTitulo("Iniciando Instalación en Disco")
	MensajesProgreso($MensajesInstalacion, "Preparando disco " & $DiscoActual & ":")
	FormProgreso_lblProgreso("Preparando disco... ")
	If Not PrepararDisco(True) Then Return False
	If Not ValidarParticiones() Then Return False
	If Not f_AplicarImagenes() Then Return False
	GUICtrlSetState($Cancelar, $GUI_ENABLE)
	GUICtrlSetData($Cancelar, "Cerrar")
    WinSetTitle($FormMensajesProgreso, "", "Instalacion finalizada correctamente")
	Return True
EndFunc

Func f_InstalarEnParticiones()
	;seleccionar disco
	$Diskpart_pid = Diskpart_creacion_proceso()
	If SeleccionarDisco($Diskpart_pid, $DiscoActual) Then
	;verificamos q tenga particiones
		If Not dpf_ListarParticiones($Diskpart_pid) Then
			MsgBox($MB_SYSTEMMODAL, "Disco vacio", "El disco seleccionado no posee ninguna partición")
			Return False
		EndIf
	;_ArrayDisplay($arParticiones, "lista")
	EndIf
	;verificamos q existan las particiones necesarias q usa el Windows
	If $arDisks[$DiscoActual][7] = "UEFI" Then
		$minParticiones = 5
	Else
		$minParticiones = 4
	EndIf
	ConsoleWrite("particiones necesarias: " & UBound($arParticiones) & @CRLF)
	If UBound($arParticiones) < $minParticiones Then
		MsgBox(0, "Particiones", "El disco solo tiene " & UBound($arParticiones) & " particion(es), no parece tener particion de solo datos"  )
		Return False
	EndIf
	GUISetState(@SW_SHOW, $FormMensajesProgreso)
	f_MensajeTitulo("Iniciando Instalacion en Disco")
	MensajesProgreso($MensajesInstalacion, "Se encontraron " & UBound($arParticiones) & " particion(es) en el disco")
	MensajesProgreso($MensajesInstalacion, "Preparando disco " & $DiscoActual & ":")
	FormProgreso_lblProgreso("Preparando disco... ")
	$intPartActual = 0

	;detectar particion sistema
	If $arDisks[$DiscoActual][7] = "UEFI" Then
		$strSistemaSel = "UEFI"
		;si es UEFI, puede q sea la 2 particion la q sea de sistema
		If Not IsPartitionType($intPartActual, $SYSTEM_PART_NUM) Then
			$intPartActual += 1
			If Not IsPartitionType($intPartActual, $SYSTEM_PART_NUM) Then
				ConsoleWrite("El disco no posee partición de sistema")
				MensajesProgreso($MensajesInstalacion, "El disco no posee partición de sistema")
				Return False
			EndIf
		EndIf
	Else
		$strSistemaSel = "BIOS"
	EndIf
	$arParticionesSistema[0][0] = $arParticiones[$intPartActual][0]
	MensajesProgreso($MensajesInstalacion, "Se detecto la partición " & $arParticionesSistema[0][0] & " como partición de arranque")
	ConsoleWrite("arParSis: " & $arParticionesSistema[0][0] & @CRLF)
	$arSize = StringSplit($arParticiones[$intPartActual][2], " ", $STR_NOCOUNT)
	;Confirmamos q tenga particion de sistema
	If ($arSize[0] > 300 And $arSize[1] = "MB") Or $arSize[1] = "GB" Then
		ConsoleWrite("No tiene particion de sistema" & @CRLF)
		MensajesProgreso($MensajesInstalacion, "El disco no posee partición de sistema")
		Return False
	EndIf
	$intBarraProgresoGUI = 5
	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)

	;detectar particion principal
	$intPartActual += 1
	If $arDisks[$DiscoActual][7] = "UEFI" Then
		$intPartActual += 1
	EndIf
	$arParticionesSistema[1][0] = $arParticiones[$intPartActual][0]
	If Not IsPartitionType($intPartActual, $PRINCIPAL_PART_NUM) Then
		MsgBox($MB_SYSTEMMODAL, "Partición Windows", "El disco no tiene partición con Windows")
		MensajesProgreso($MensajesInstalacion, "El disco no posee partición de sistema")
		Return False
	EndIf
	ConsoleWrite("arParPrincipal: " & $arParticionesSistema[1][0] & @CRLF)
	MensajesProgreso($MensajesInstalacion, "Se detecto la partición " & $arParticionesSistema[1][0] & " como partición Windows")
	$intBarraProgresoGUI = 8
	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)

	;detectar particion recovery, si esta contigua, habilitar flag RecoveryAdyacente
	$arParticionesSistema[2][0] = 99 ; 99 es la bandera cuando no encontramos Recovery
	$intPartActual += 1
	If IsPartitionType($intPartActual, $RECOVERY_PART_NUM) Then
		$arParticionesSistema[2][0] = $arParticiones[$intPartActual][0]
		$flagRecoveryAdyacente = True
		$msjRecovery = " "
	Else
		For $i = 0 to UBound($arParticiones)- 1
		If IsPartitionType($i, $RECOVERY_PART_NUM) Then
			$arParticionesSistema[2][0] = $arParticiones[$i][0]
		EndIf
		$flagRecoveryAdyacente = False
		$msjRecovery = "no "
	Next
	EndIf

	ConsoleWrite("Partición Recovery: " & $arParticionesSistema[2][0] & @CRLF)
	If $arParticionesSistema[2][0] = 99 Then
		MsgBox($MB_SYSTEMMODAL, "Partición Recovery", "El disco no tiene partición Recovery")
		MensajesProgreso($MensajesInstalacion, "El disco no posee partición Recovery")
		Return False
	EndIf
	MensajesProgreso($MensajesInstalacion, "Se detecto la partición " & $arParticionesSistema[2][0] & " como partición Recovery y " & $msjRecovery & "es adyacente" )
	$intBarraProgresoGUI = 11
	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)

	;verificar partiones principales y recovery
	; asignar letras a las 2 particiones
	$Letra = dpf_AsignarLetra($Diskpart_pid, $arParticionesSistema[1][0])
	If $Letra = "." Then
		MsgBox($MB_SYSTEMMODAL, "Asignacion de Letras", "No se pudo asignar una letra a la particon principal")
		Return False
	EndIf
	$arParticionesSistema[1][1] = $Letra
	$Letra = dpf_AsignarLetra($Diskpart_pid, $arParticionesSistema[2][0])
	If $Letra = "." Then
		MsgBox($MB_SYSTEMMODAL, "Asignacion de Letras", "No se pudo asignar una letra a la particon Recovery")
		Return False
	EndIf
	$arParticionesSistema[2][1] = $Letra
	If FileExists($arParticionesSistema[1][1] & ":\Windows") Then
		ConsoleWrite("Carpeta Windows Existe" & @CRLF)
	Else
		MsgBox($MB_SYSTEMMODAL, "Carpetas Sistema", "No se encontró la carpeta " & $arParticionesSistema[1][1] & ":\Windows")
		MensajesProgreso($MensajesInstalacion, "No se encontró la carpeta " & $arParticionesSistema[1][1] & ":\Windows")
		Return False
	EndIf
	MensajesProgreso($MensajesInstalacion, "Se encontró la carpeta " & $arParticionesSistema[1][1] & ":\Windows")
	If FileExists($arParticionesSistema[2][1] & ":\Recovery") Then
		ConsoleWrite("Carpeta Recovery Existe" & @CRLF)
	Else
		MsgBox($MB_SYSTEMMODAL, "Carpetas Sistema", "No se encontró la carpeta " & $arParticionesSistema[2][1] & ":\Recovery")
		MensajesProgreso($MensajesInstalacion, "No se encontró la carpeta " & $arParticionesSistema[2][1] & ":\Recovery")
		Return False
	EndIf
	MensajesProgreso($MensajesInstalacion, "Se encontró la carpeta " & $arParticionesSistema[2][1] & ":\Recovery")
	$intBarraProgresoGUI = 14
	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)

;~ 	_ArrayDisplay($arParticionesSistema, "lista2")
	; eliminar particiones sistema, principal y recovery
	If $arDisks[$DiscoActual][7] = "UEFI" Then
		dpf_EliminarParticionArranqueUEFI($Diskpart_pid, $arParticionesSistema[0][0])
	Else
		dpf_EliminarParticion($Diskpart_pid, $arParticionesSistema[0][0])
	EndIf
	$intBarraProgresoGUI = 16
	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
	dpf_EliminarParticion($Diskpart_pid, $arParticionesSistema[1][0])
	$intBarraProgresoGUI = 18
	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
	dpf_EliminarParticion($Diskpart_pid, $arParticionesSistema[2][0])
	$intBarraProgresoGUI = 20
	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
	;Return False
	;crear particiones
;~ 	_ArrayDisplay($arParticionesSistema, "lista3")
	If Not PrepararDisco(False) Then Return False ; cuando es a particiones es False
;~ 	_ArrayDisplay($arParticionesSistema, "lista4")
	If Not ValidarParticiones() Then Return False
	If Not f_AplicarImagenes() Then Return False
	GUICtrlSetState($Cancelar, $GUI_ENABLE)
	GUICtrlSetData($Cancelar, "Cerrar")
    WinSetTitle($FormMensajesProgreso, "", "Instalacion finalizada correctamente")
	Return True
EndFunc

Func f_AplicarImagenes()
	;aplicamos imagen sistema a la particion con la letra W:
	If Not df_AplicarImagen($pathFileWimSel, $intIndexImageSel, "W") Then Return False
	;version q usa 2 imagenes
;~ 	;extraemos la ruta al folder donde ubicamos el archivo WIM, y usamos la misma ruta
;~ 	;para el archivo Recovery.wim
;~ 	Local $intUltimoBackslash = StringInStr($pathFileWimSel, "\",0,-1)
;~ 	Local $strLocationFolderDestino = StringMid($pathFileWimSel, 1, $intUltimoBackslash)
	Local $strLocationFolderDestino = ExtraerRutaPadre($pathFileWimSel)
	;aplicamos imagen Recovery a la particion con la letra R:
	If Not df_AplicarImagen($strLocationFolderDestino & "Recovery.wim", 1, "R") Then Return False
	If Not f_ActivarParticiones() Then Return False
	MensajesProgreso($MensajesInstalacion, "Finalizaron todas las tareas correctamente")
	MensajesProgreso($MensajesInstalacion, "Se instaló correctamente la imagen en el Disco")
	FormProgreso_lblProgreso("Instalación correcta de la imagen")
	Return True
EndFunc

Func f_AsignarParametros()
	$strSistemaSel = LeerSistemaSeleccionado()
	$pathFileWimSel = GUICtrlRead($inFileImagePath)
	$intIndexImageSel = GUICtrlRead($InIndexImage)
	$strImageNameSel = GUICtrlRead($InImageName)
EndFunc

Func f_ActivarParticiones()
	f_MensajeTitulo("Activando Particiones de Sistema y Recovery:")
	FormProgreso_lblProgreso("Activando Particiones ...")
	;activamos particion sistema
	If Not f_TareaCMD($arrayComandos, 0, $strSistemaSel) Then Return False
	$intBarraProgresoGUI = 84
	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
	;--------- Bloque comentado, nueva version usara imagen Recovery

;~ 	;creamos carpeta Recovery
;~ 	If DirCreate($rutaWinre) Then
;~ 		MensajesProgreso($MensajesInstalacion, "    " & $arrayComandos[1][0])
;~ 	Else
;~ 		MensajesProgreso($MensajesInstalacion, "No se pudo crear la carpeta Recovery")
;~ 		Return False
;~ 	EndIf
;~ 	$intBarraProgresoGUI = 88
;~ 	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
	;ubicar la ruta de WinRE
;~ 	Local $rutaFileWinREaCopiar = f_UbicarWinreImagen()
;~ 	If $rutaFileWinREaCopiar = '' Then
;~ 		MensajesProgreso($MensajesInstalacion, "No se ubica el archivo WinRE, extraerlo con boton Obtener WinRE y copiarlo en la raiz del USB. No puede continuar la instalacion")
;~ 		Return False
;~ 	EndIf
;~ 	MensajesProgreso($MensajesInstalacion, "    Ubicado WinRE en: " & $rutaFileWinREaCopiar)
;~ 	$intBarraProgresoGUI = 92
;~ 	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
;~ 	;copiado de imagen winre
;~ 	If Not f_TareaCMD($arrayComandos, 2, $rutaFileWinREaCopiar) Then Return False
;~ 	$intBarraProgresoGUI = 96
;~ 	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
	;--------- Fin de Bloque comentado, nueva version usara imagen Recovery
	;registrando WinRE: Global $rutaWinre
	If Not f_TareaCMD($arrayComandos, 4, $rutaWinre) Then Return False
	$intBarraProgresoGUI = 88
	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
	Local $OsGuid = f_FindGuidBcdedit()
	If $OsGuid = "." Then
		MensajesProgreso($MensajesInstalacion, "    Se recomienda ejecutar 'reagentc /enable' para finalizar la activacion")
		;Return False
		Local $strLocationFolderDestino = ExtraerRutaPadre($pathFileWimSel)
		If Not f_TareaCMD($arrayComandos, 8, $strLocationFolderDestino) Then MensajesProgreso($MensajesInstalacion, "    Error copiando recovery_enable.cmd")
	Else
		If Not f_TareaCMD($arrayComandos, 4, $rutaWinre) Then Return False
		$intBarraProgresoGUI = 92
		gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
		If Not f_TareaCMD($arrayComandos, 7, $OsGuid) Then Return False
	EndIf
	$intBarraProgresoGUI = 100
	gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
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
	Local $psTarea = Run(@ComSpec & " /c " & $comando, "", @SW_HIDE, $STDERR_MERGED)
	ProcessWaitClose($psTarea)
	Local $readConsole = StdoutRead($psTarea)
	If StringInStr($readConsole, $salida_correcta) Then
		Return True
	Else
		MensajesProgreso($MensajesInstalacion, "Error: " & $nombreTarea & " no se pudo completar la tarea")
		MensajesProgreso($MensajesInstalacion, "Este comando se ejecuto:" & @CRLF & $comando)
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
	Else ; sino esta en la imagen desplegada, la buscamos en algun usb ya sea en la raiz o en usb\IMA
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

Func f_CambiarAMinutos($segundos)
	Local $strUnidadTiempo
	If $segundos > 60 Then
		Return Int($segundos/60) & " min " & Mod($segundos,60) & " seg"
	Else
		Return $segundos & " seg"
	EndIf
EndFunc

Func f_UltNElemArray_to_Texto($arSalida, $intIndice, $intN)
	Local $strTexto = ""
	If UBound($arSalida) < $intN Then Return "Error en array"
	For $i = ($intIndice - $intN) To $intIndice
		$strTexto &= $arSalida[$i] & @CRLF
	Next
	Return $strTexto
EndFunc

Func f_ExtractWinREImagen()
	;Tarea principal para extrear la el archivo winre.wim de la particion oculta Recovery y copiarlo a la ubicacion del ejecutable
	Local $intNumTipoPart = 2
	If $DiscoActual = "N" Then
		$MensajeStatusError = "Error de seleccion - No ha seleccionado un disco"
		ActualizandoStatus()
		Return False
	EndIf
	$sTipoDisco = $arDisks[$DiscoActual][10]
	If $sTipoDisco <> "SATA" And $sTipoDisco <> "NVME" Then
		MsgBox(0,"Tipo de Disco", "El tipo de disco seleccionado no es SATA o M2. No esta permitida la extraccion en discos que no sean de esos formatos")
		Return False
	EndIf
	LimpiarVentanaProgreso()
	f_AsignarParametros()
	WinSetTitle($FormMensajesProgreso, "", "Extraccion de WinRE")
	FormProgreso_DisableCancelar()
	GUISetState(@SW_SHOW, $FormMensajesProgreso)
	If Not dpf_AsignarLetraToPartition($intNumTipoPart) Then Return False
	MensajesProgreso($MensajesInstalacion, "Iniciando copiado de WinRE.wim...")
	If f_CopiarWinreArchivo() Then
		MensajesProgreso($MensajesInstalacion, "Se copió correctamente WinRE a " & @ScriptDir)
		FileSetAttrib ( @ScriptDir &"\winre.wim", "-S-H")
	EndIf

	$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, "remove", "DiskPart quitó correctamente la letra de unidad o el punto de montaje")
	If $sSalida Then
		MensajesProgreso($MensajesInstalacion, "Error al remover la letra " & $arTiposPartitions[$intNumTipoPart][2] & "" )
		Return False
	EndIf
	MensajesProgreso($MensajesInstalacion, @CRLF & "FINAL de la extraccion, debe copiar el archivo WinRE a la raiz del disco Instalador de Imagenes")
EndFunc

Func f_CopiarWinreArchivo()
	;Copiamos Winre.wim de la particion Recovery a la ubicacion del ejecutable
	Local $comando = "xcopy R:\Recovery\WindowsRE\WinRE.wim " & @ScriptDir & " /q /y /h"
	;xcopy no funciona con solo $STDERR_CHILD)
	Local $cmdXcopy = Run(@ComSpec & " /c " & $comando, "", @SW_HIDE, BitOR($STDIN_CHILD, $STDOUT_CHILD, $STDERR_CHILD))
	ProcessWaitClose($cmdXcopy)
	Local $readConsole = StdoutRead($cmdXcopy)
;~ 	ConsoleWrite($readConsole)
	If StringInStr($readConsole, "1 archivo(s) copiado(s)") Then
		Return True
	Else
		MensajesProgreso($MensajesInstalacion, "Error al copiar WinRE a " & @ScriptDir)
		Return False
	EndIf
EndFunc

Func f_FindGuidBcdedit()
	Local $Resultado = "."
	Local $txtCommandLine1 = "W:\Windows\System32\bcdedit.exe -enum -V"
	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine1, "W:\Windows\System32\", @SW_HIDE, $STDOUT_CHILD)
	ProcessWaitClose($psTarea)
	$strSalida = StdoutRead($psTarea)
	;verificamos q no haya un error en la salida, verificando q la salida tenga por lo menos 600 caracteres
	If StringLen($strSalida) < 600 Then Return $Resultado
	; Buscamos la seccion cargador de arranque de Windows
	Local $intUbicacionCargador = StringInStr($strSalida, "Cargador ",0,-1)
	;sino existiera cargador, salimos con error
	If $intUbicacionCargador = 0 Then
		ConsoleWrite("--$intUbicacionCargador=0: " & $strSalida & @CRLF)
		Return $Resultado
	EndIf
	;seleccionamos todo el texto a partir de cargador
	Local $strCampoCargador = StringMid($strSalida, $intUbicacionCargador)
;~ 	ConsoleWrite("dato:" & $strLocationFolderDestino & @CRLF)
	;convertimos a array de lineas
	Local $aArray = StringSplit(StringTrimRight(StringStripCR($strCampoCargador), StringLen(@CRLF)), @CRLF)
	;_ArrayDisplay($aArray)
	;buscamos la primera linea q muestre W:, la linea anterior a esa, tendrá el guid
	For $i=1 To $aArray[0]
		If StringInStr($aArray[$i], "W:") Then
			$arLinea = StringSplit(StringStripWS($aArray[$i-1],$STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES), " ", $STR_NOCOUNT )
			$Resultado = $arLinea[1]
			ConsoleWrite("--" &$arLinea[1] & @CRLF)
			Return $Resultado
		EndIf
	Next

EndFunc

Func f_reinstalacion()
   ;leer particiones del disco
   ;detectar particiones de sistema, windows y recovery
   ; eliminar las particiones correctamente y vovler a crearlas
   ;instalar imagenes
   ;activar particiones
EndFunc
