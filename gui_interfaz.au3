

#Region ### START Koda GUI section ### Form=d:\util\win_deploy\gui_design.kxf
$Activador = GUICreate("Instalador de Imagenes de SO" & $strVersionApp, 615, 411, 183, 166)
$GroupSelDisk = GUICtrlCreateGroup("Seleccione disco", 16, 8, 577, 185)
$idListDiscos = GUICtrlCreateListView("#|  Modelo    |Sistema|Tama�o|Espacio Libre|Interface|Status", 40, 32, 521, 105, BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 30)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 150)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 4, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 5, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 6, 70)
$btRefresh = GUICtrlCreateButton("Refrescar", 456, 150, 105, 25)
$ctrlSelModoDisco = GUICtrlCreateCombo("Seleccione", 136, 152, 105, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Nuevo|Reinstalacion")
$lblModoDisco = GUICtrlCreateLabel("Instalar disco como:", 40, 154, 86, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$GroupTipoInstalacion = GUICtrlCreateGroup("Seleccione tipo de instalacion", 16, 304, 577, 57)
$btInstalar = GUICtrlCreateButton("Inst. Rapida", 456, 324, 105, 25)
$ck_UEFI = GUICtrlCreateRadio("", 32, 328, 17, 17)
$ck_Csm = GUICtrlCreateRadio("", 112, 328, 17, 17)
$lblUEFI = GUICtrlCreateLabel("UEFI", 56, 330, 28, 17)
$lblCSM = GUICtrlCreateLabel("CSM/MBR", 135, 330, 56, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$GroupSelImagen = GUICtrlCreateGroup("Seleccione imagen a instalar", 16, 200, 577, 97)
$lblFileWim = GUICtrlCreateLabel("archivo WIM", 32, 228, 65, 17)
$inFileImagePath = GUICtrlCreateInput("", 104, 224, 329, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
$btFileSel = GUICtrlCreateButton("Examinar", 456, 222, 105, 25)
$btCambiarImagen = GUICtrlCreateButton("Cambiar", 456, 258, 105, 25)
$lblNameImage = GUICtrlCreateLabel("Imagen:", 40, 262, 42, 17)
$InImageName = GUICtrlCreateInput("", 104, 260, 265, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
$lblIndexImage = GUICtrlCreateLabel("#", 384, 264, 11, 17)
$InIndexImage = GUICtrlCreateInput("", 408, 260, 25, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
GUICtrlCreateGroup("", -99, -99, 1, 1)
$ctrlStatus = GUICtrlCreateLabel("Listo", 16, 384, 578, 17, -1, $WS_EX_STATICEDGE)
#EndRegion ### END Koda GUI section ###

;~ GUICtrlSetStyle($idListDiscos,  BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER))
GUICtrlSendMsg($idListDiscos, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_GRIDLINES, $LVS_EX_GRIDLINES)

#Region ### START Koda GUI section ### Form=d:\util\win_deploy\formselectimage.kxf
$FormSelectImage = GUICreate("Seleccionar Imagen", 522, 359, 192, 124, -1, -1, $Activador)
$ListImageSelect = GUICtrlCreateListView("#|Nombre                      |Descripcion                |Tama�o          ", 18, 16, 489, 281, BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 50)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 150)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 150)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 100)
$SelectImage = GUICtrlCreateButton("Selecccionar", 220, 320, 81, 25)

#EndRegion ### END Koda GUI section ###

;~ GUICtrlSetStyle($ListImageSelect,  BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER))
GUICtrlSetState($SelectImage, $GUI_DISABLE)

#Region ### START Koda GUI section ### Form=c:\users\luis\documents\win_deploy\formmensajesprogreso.kxf
$FormMensajesProgreso = GUICreate("Instalacion en curso", 615, 454, 192, 124, -1, -1, $Activador)
$MensajesInstalacion = GUICtrlCreateEdit("", 16, 16, 577, 353, BitOR($GUI_SS_DEFAULT_EDIT,$ES_AUTOHSCROLL,$ES_AUTOVSCROLL,$ES_READONLY), $WS_EX_STATICEDGE)
GUICtrlSetData(-1, "")
$InstProgreso = GUICtrlCreateProgress(16, 416, 473, 25)
$Cancelar = GUICtrlCreateButton("Cancelar", 512, 416, 81, 25)
$lblTextoProgreso = GUICtrlCreateLabel("", 16, 392, 260, 17)
$lblTextoProgresoDerecha = GUICtrlCreateLabel("", 280, 392, 210, 17, $SS_RIGHT)
#EndRegion ### END Koda GUI section ###

;Funciones GUI
;$lblMensajesInstalacion = GUICtrlCreateLabel("", 16, 16, 577, 353)
;GUICtrlSetState($lblMensajesInstalacion,$GUI_ONTOP+$GUI_FOCUS)

Global $gi_boolPuedoCerrarProgreso = True
Global $gi_AlmacenTextoMensajes = ""

Func FormProgreso_ActualizarLabelProgreso($status)
	GUICtrlSetData($lblTextoProgreso, $status)
EndFunc

Func FormProgreso_DisableCancelar()
	$gi_boolPuedoCerrarProgreso = False
	GUICtrlSetState($Cancelar, $GUI_DISABLE)
EndFunc

Func FormProgreso_EnableCancelar()
	$gi_boolPuedoCerrarProgreso = True
	GUICtrlSetState($Cancelar, $GUI_ENABLE)
EndFunc

Func FormProgreso_SondearCancelacionCierre()
	Local $msg
	$msg = GUIGetMsg()
	If $msg <> $GUI_EVENT_MOUSEMOVE Then
		If $msg = $Cancelar Then
			Return True
		Else
			Return False
		EndIf
	EndIf
EndFunc

Func gi_EventosSelectProgreso()
	Switch $nMsg[0]
		Case $GUI_EVENT_CLOSE
			GUISetState(@SW_HIDE,$FormMensajesProgreso)
	EndSwitch
EndFunc

Func gi_MostrarAvanceBarraProgresoGUI($idProgressbar, $value)
	GUICtrlSetData($idProgressbar, Int($value))
EndFunc
