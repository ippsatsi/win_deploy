

#Region ### START Koda GUI section ### Form=d:\util\win_deploy\gui_design.kxf
$Activador = GUICreate("Instalador de Imagenes de SO" & $strVersionApp, 615, 411, 183, 166)
$GroupSelDisk = GUICtrlCreateGroup("Seleccione disco", 16, 8, 577, 185)
$idListDiscos = GUICtrlCreateListView("#|  Modelo    |Sistema|Tamaño|Espacio Libre|Interface|Status", 40, 32, 521, 105, BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 30)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 150)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 4, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 5, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 6, 70)
$btExtractWinRE = GUICtrlCreateButton("Obtener WinRE", 296, 150, 125, 25)
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
$FormSelectImage = GUICreate("Seleccionar Imagen", 613, 359, 192, 124, -1, -1, $Activador)
$ListImageSelect = GUICtrlCreateListView("#|Nombre                      |Descripcion                |Tamaño          ", 18, 16, 577, 281, BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 20)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 150)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 350)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 50)
$SelectImage = GUICtrlCreateButton("Selecccionar", 266, 320, 81, 25)

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

### --------------------------- GUI DE REISNTALACION ----------------------------------------------------------------------------------------------###
#Region ### START Koda GUI section ### Form=D:\util\win_deploy\FormReinstalacion.kxf
$FormReinstalacion = GUICreate("Reinstalacion", 327, 386, 192, 124)
$grpPartInDisk = GUICtrlCreateGroup("Particiones del Disco", 16, 8, 297, 129)
$ListViewParticionesDisco = GUICtrlCreateListView("#|Nombre|Letra|Tipo|Tamaño", 24, 24, 281, 105,  BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 25)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 80)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 40)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 60)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 4, 70)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$grpPartUsar = GUICtrlCreateGroup("Particiones a utilizar: ", 16, 152, 297, 169)
$selSistema = GUICtrlCreateCombo("selSistema", 136, 168, 113, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$lblSystem = GUICtrlCreateLabel("Sistema", 34, 175, 41, 17)
$selWindows = GUICtrlCreateCombo("Combo1", 136, 208, 113, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$lblWindows = GUICtrlCreateLabel("Windows", 34, 215, 48, 17)
$selRecovery = GUICtrlCreateCombo("Combo1", 136, 248, 113, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$lblRecovery = GUICtrlCreateLabel("Recovery", 34, 255, 50, 17)
$chkRecoveryShrink = GUICtrlCreateCheckbox("chkRecoveryShrink", 32, 280, 17, 17)
$lblRecoveryShrink1 = GUICtrlCreateLabel("Recovery se creara a partir de la reduccion de", 64, 280, 223, 17, $SS_LEFTNOWORDWRAP)
$lblRecoveryShrink2 = GUICtrlCreateLabel("la particion de Windows", 63, 297, 223, 17, $SS_LEFTNOWORDWRAP)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$btReinstalacion = GUICtrlCreateButton("Reinstalar", 123, 344, 81, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
GUICtrlSendMsg($ListViewParticionesDisco, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_GRIDLINES, $LVS_EX_GRIDLINES)

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

Func gi_EventosReinstalacion()
	Switch $nMsg[0]
		Case $GUI_EVENT_CLOSE
			GUISetState(@SW_HIDE,$FormReinstalacion)
	EndSwitch
EndFunc

