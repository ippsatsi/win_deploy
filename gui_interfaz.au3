

#Region ### START Koda GUI section ### Form=d:\util\win_deploy\gui_design.kxf
$Activador = GUICreate("Activador", 615, 411, 183, 166)
$GroupSelDisk = GUICtrlCreateGroup("Seleccione disco", 16, 8, 577, 185)
$idListDiscos = GUICtrlCreateListView("#|  Modelo    |Sistema|Tamaño|Espacio Libre|Interface|Status", 40, 32, 521, 105, BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER))
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
$inFileImagePath = GUICtrlCreateInput("", 104, 224, 329, 21)
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
$ListImageSelect = GUICtrlCreateListView("#|Nombre                      |Descripcion                |Tamaño          ", 18, 16, 489, 281, BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 50)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 150)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 150)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 100)
$SelectImage = GUICtrlCreateButton("Selecccionar", 220, 320, 81, 25)

#EndRegion ### END Koda GUI section ###

;~ GUICtrlSetStyle($ListImageSelect,  BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER))
GUICtrlSetState($SelectImage, $GUI_DISABLE)

#Region ### START Koda GUI section ### Form=d:\util\win_deploy\formmensajesprogreso.kxf
$FormMensajesProgreso = GUICreate("FormMensajesProgreso", 615, 437, 212, 183, -1, -1, $Activador)
$MensajesInstalacion = GUICtrlCreateEdit("", 16, 16, 577, 353, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY), $WS_EX_STATICEDGE)
GUICtrlSetData(-1, "MensajesInstalacion")
$InstProgreso = GUICtrlCreateProgress(16, 392, 473, 25)
$Cancelar = GUICtrlCreateButton("Cancelar", 512, 392, 81, 25)
#EndRegion ### END Koda GUI section ###