;dism /get-imageinfo /imagefile:
Global $arImagenes

Func CargaListaImagenes($sRutaFileWim)
	Local $txtCommandLine = "dism /get-imageinfo /imagefile:" & $sRutaFileWim
	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	ProcessWaitClose($psTarea)
	Local $sSalida = StdoutRead($psTarea)
	StringReplace($sSalida, "Index :", "Imagen:")
	Local $intNumIndex = @extended
	If StringInStr($sSalida,"The operation completed successfully") And $intNumIndex > 0 Then
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
			$arImagenes[$i][3] = ExtraerValorParametro($arImagen[3])
		Next
		GUICtrlSetData($InImageName, $arImagenes[0][1])
		GUICtrlSetData($InIndexImage, $arImagenes[0][0])
	EndIf
EndFunc

Func ExtraerDatosImagen($sDatosImagen)
	Local $arImagen = StringSplit($sDatosImagen, @LF, $STR_NOCOUNT)
	Return $arImagen
EndFunc

Func RellenarListImagenes($ctrlLista, $arTabla)
	GUICtrlSendMsg($ctrlLista, $LVM_DELETEALLITEMS, 0, 0)	; Limpiamos el ctrl Lista
	For $Item = 0 To UBound($arTabla) - 1
		$arFila = $arTabla[$Item]
		For $i = 0 To

	Next

EndFunc
