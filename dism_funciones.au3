;dism /get-imageinfo /imagefile:
Global $arImagenes

Func DismSuccessDosIdiomas($sSalida)
	If StringInStr($sSalida,"The operation completed successfully") Or StringInStr($sSalida,"La operación se completó correctamente") Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func ConvertDismBytesToGb($sValor)
	Local $intValor
	$sValor = StringReplace($sValor, ",", "")
	$sValor = StringReplace($sValor, "bytes", "")
	$intValor = Number($sValor)
	$intValor = $intValor/1024
	$intValor = $intValor/1024
	$intValor = $intValor/1024
	Return Round($intValor,1)
EndFunc


Func CargaListaImagenes($sRutaFileWim)
	Local $txtCommandLine = "dism /get-imageinfo /imagefile:" & $sRutaFileWim
	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	ActualizandoStatus("Buscando imagenes en el archivo ...")
	ProcessWaitClose($psTarea)
	Local $sSalida = StdoutRead($psTarea)
	$sSalida = ReemplazarCaracteresEspanol($sSalida)
	;para q reconozca en ingles y español
	StringReplace($sSalida, "Index :", "Imagen:")
	Local $intNumIndex = @extended
	StringReplace($sSalida, "Índice:", "Imagen:")
	$intNumIndex = @extended + $intNumIndex
	If DismSuccessDosIdiomas($sSalida) And $intNumIndex > 0 Then
		Dim $arImagenes[$intNumIndex][4]
		$sSalida = StringReplace($sSalida,@CRLF & @CRLF , "|")
		Local $arSalida = StringSplit($sSalida, "|", $STR_NOCOUNT)
		;Eliminamos las 2 primeras lineas q son
		;Deployment Image Servicing and Management tool Version: 10.0.19041.572
		;Details for image : D:\install.wim
		_ArrayDelete($arSalida, 0)
		_ArrayDelete($arSalida, 0)
		;y la ultima q es:
		;The operation completed successfully.
		_ArrayDelete($arSalida, UBound($arSalida)-1)
		For $i = 0 To UBound($arSalida) - 1
			Local $arImagen = ExtraerDatosImagen($arSalida[$i])
			$arImagenes[$i][0] = ExtraerValorParametro($arImagen[0])
			$arImagenes[$i][1] = ExtraerValorParametro($arImagen[1])
			$arImagenes[$i][2] = ExtraerValorParametro($arImagen[2])
			$arImagenes[$i][3] = ConvertDismBytesToGb(ExtraerValorParametro($arImagen[3])) & " Gb"
		Next
		UpdateCtrlInputImageNameSelect(0)
		ActualizandoStatus("Finalizada busqueda de imagenes")
		RellenarCtrlListView($ListImageSelect, $arImagenes)
	Else
		ActualizandoStatus("Ocurrio un error al examinar el archivo WIM")
	EndIf
EndFunc

Func ExtraerDatosImagen($sDatosImagen)
	Local $arImagen = StringSplit($sDatosImagen, @LF, $STR_NOCOUNT)
	Return $arImagen
EndFunc

Func RellenarCtrlListView($ctrlLista, $arTabla)
	Local $sTextoCelda,$sTextoFila
	Local $intNumCol = UBound($arTabla, 2)
	Dim $arFila[$intNumCol]
	GUICtrlSendMsg($ctrlLista, $LVM_DELETEALLITEMS, 0, 0)	; Limpiamos el ctrl Lista
	For $Item = 0 To UBound($arTabla) - 1
		For $i = 0 To $intNumCol - 1
			$arFila[$i] = $arTabla[$Item][$i]
		Next
		$sTextoFila = _ArrayToString($arFila,"|")
		GUICtrlCreateListViewItem($sTextoFila, $ctrlLista)
	Next
EndFunc

Func EventosSelectImage()
	CambiarEstadoVentanaSelectImage()
	Switch $nMsg[0]
		Case $GUI_EVENT_CLOSE
			GUISetState(@SW_HIDE,$FormSelectImage)
		Case $SelectImage
			CargaImagenSelect()
			GUISetState(@SW_HIDE,$FormSelectImage)
	EndSwitch
EndFunc

Func CambiarEstadoVentanaSelectImage()
	Local $ItemSelected
	$ItemSelected = ControlListView($FormSelectImage, "", $ListImageSelect,"GetSelected")
	If $ItemSelected = "" Then
		GUICtrlSetState($SelectImage, $GUI_DISABLE)
	Else
		GUICtrlSetState($SelectImage, $GUI_ENABLE)
	EndIf
EndFunc

Func CargaImagenSelect()
	Local $ItemSelected
	If ControlListView($FormSelectImage, "", $ListImageSelect, "GetItemCount") > 0 Then
		$ItemSelected = ControlListView($FormSelectImage, "", $ListImageSelect,"GetSelected")
		UpdateCtrlInputImageNameSelect($ItemSelected)
	EndIf
EndFunc

Func UpdateCtrlInputImageNameSelect($intNumImage)
	GUICtrlSetData($InImageName, $arImagenes[$intNumImage][1])
	GUICtrlSetData($InIndexImage, $arImagenes[$intNumImage][0])
EndFunc

Func df_AplicarImagen($FilePath, $IndexImage)
	;dism /Apply-Image /ImageFile:%1 /Index:1 /ApplyDir:W:\
	Local $txtCommandLine = "dism /Apply-Image /ImageFile:" & $FilePath & " /Index:" & $IndexImage & " /ApplyDir:W:\"
	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	Local $value = 0
	Local $percent = 0
	;para validar la aplicacion correcta de la imagen
	Local $GoodApply = False
	Local $hTimer = TimerInit()
	f_MensajeTitulo("Aplicando imagen a Particion: " & $strImageNameSel)
	MensajesProgresoSinCRLF($MensajesInstalacion,"   [")
	While ProcessExists($psTarea)
		FormProgreso_EnableCancelar()
		$line = StdoutRead($psTarea, True)
		If StringInStr($line, ".0%") Then
			$line1 = StringSplit($line, ".0%",$STR_ENTIRESPLIT)
			;ConsoleWrite("$line1[" & ($line1[0] - 1) & "]:" & $line1[$line1[0]] & @CRLF)
			$value = StringRight($line1[$line1[0] - 1], 2) ; agarramos el ultimo % leido
			;ConsoleWrite("----" & $value & "????" & @CRLF)
		EndIf
		; Si llega a 00 es porque llego al 100% y finalizo correctamente
		If $value == "00" Then $value = 100
		;si llega a 98, establecemos una variable como bandera de q posiblemente finalice
		;correctamente Dism, por q no siempre llega al 100% cuando finaliza
		;correctamente, y como no podemos saber el exit code de dism, usamos GoodApply
		If $value == "98" Then $GoodApply = True
		Local $n = 0
		While $n < 15 ;fijamos en 10 el numero de eventos a procesar de la cola
			If FormProgreso_SondearCancelacionCierre() Then
				f_KillIfProcessExists("Dism.exe")
				ActualizandoStatus("Operacion Cancelada")
				MensajesProgreso($MensajesInstalacion, " ")
				MensajesProgreso($MensajesInstalacion, "   ---- Operacion Cancelada ----   ")
				$n = 15
			EndIf
			Sleep(1)
			$n = $n + 1
		WEnd
		Sleep(100)
		If $percent <> $value Then
			;calculamos el tiempo transcurrido y estimado
			$iRatioRestante = (100 - $value)/$value
			$mmTiempoTranscurrido = TimerDiff($hTimer)
			$mmTiempoEstimadoTotal = ($mmTiempoTranscurrido * $iRatioRestante) + $mmTiempoTranscurrido
			$ssTiempoTranscurrido = Floor($mmTiempoTranscurrido/1000)
			$ssTiempoTotal = Floor($mmTiempoEstimadoTotal/1000)
			;Establecemos cada cuanto deben agregarse "="
			If Mod($value,4) = 0 Then
				MensajesProgresoSinCRLF($MensajesInstalacion,"=")
			EndIf
			FormProgreso_lblProgreso("Aplicando imagen, Total Est: " & $ssTiempoTotal & " seg" ,"Trancurrido: " & $ssTiempoTranscurrido & " seg   " & $value & "%")
			$percent = $value
		EndIf
		If $value = 100 Then
			$GoodApply = True
			ExitLoop
		EndIf
	WEnd
	If $GoodApply Then
		MensajesProgresoSinCRLF($MensajesInstalacion,"]")
		MensajesProgreso($MensajesInstalacion, " ")
		MensajesProgreso($MensajesInstalacion, "Imagen aplicada correctamente")
		Return True
	Else
		MensajesProgreso($MensajesInstalacion, " ")
		MensajesProgreso($MensajesInstalacion, "Error, no se pudo completar la aplicacion de la imagen")
		Return False
	EndIf
EndFunc
