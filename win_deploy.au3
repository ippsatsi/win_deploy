#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_x64=win_deploy.exe
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Fileversion=2.0.2.0
#AutoIt3Wrapper_Res_HiDpi=Y
#AutoIt3Wrapper_Run_AU3Check=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <String.au3>
#include <EditConstants.au3>
#include <Array.au3>
#include <ColorConstants.au3>
#include <ListViewConstants.au3>
#include <AutoItConstants.au3>

#include <comandos_array.au3>
#include <funciones.au3>
#include <diskpart_funciones.au3>
#include <dism_funciones.au3>

Global $MensajeStatusError = ""
Global $intBarraProgresoGUI = 0

Global $strSistemaSel = ""
Global $pathFileWimSel = ""
Global $strImageNameSel = ""
Global $intIndexImageSel = 1
Global $strVersionApp = " v2.020"

;Opciones GUI
Opt("GUIResizeMode", $GUI_DOCKTOP  + $GUI_DOCKSIZE)
;T:\Recovery\WindowsRE
#include <gui_interfaz.au3>

; para que tenga un tamaño uniforme aun cuando los controles cambien de tamaño en tiempo de ejecucion
;~ WinMove($Activador,"",Default, Default,Default, $intGuiAltoMin)

Local $txtCommandLine = ''
Local $txtBootOption = ''
Local $sTipoArranque = RegRead("HKLM\System\CurrentControlSet\Control", "PEFirmwareType")
If $sTipoArranque = 2 Then
	$sTipoArranque = "UEFI"
	GUICtrlSetState($ck_UEFI, $GUI_CHECKED)
Else
	$sTipoArranque = "CSM"
	GUICtrlSetState($ck_Csm, $GUI_CHECKED)
EndIf

GUISetState(@SW_HIDE,$FormSelectImage)
GUISetState(@SW_HIDE,$FormMensajesProgreso)
GUISetState(@SW_HIDE,$FormReinstalacion)
GUISetState(@SW_HIDE,$FormAcerca)
GUISetState(@SW_SHOW, $Activador)
RefrescarDiscos()
ActualizandoStatus("Listo")
f_AutoSelect()

While 1
	$nMsg = GUIGetMsg(1)
	;obviamos los mensajes de movimiento del mouse
	If $nMsg[0] = $GUI_EVENT_MOUSEMOVE Then
		ContinueLoop
	EndIf
	Select
		;si el mensaje es de la ventana principal
		Case $nMsg[1] = $Activador
			CambiarEstado()
			ActivarBtInstalacion()
			Switch $nMsg[0]
				Case $GUI_EVENT_CLOSE
					Exit
				;se comenta, ya no sera necesario desde la version 2.0
				;Case $btExtractWinRE
				;	f_ExtractWinREImagen()
				Case $btRefresh
					RefrescarDiscos()
				Case $btInstalar
					$selComboModo = GUICtrlRead($ctrlSelModoDisco)
					If $selComboModo = $ModoDiscoTotal Then
						If Not f_InstalarEnDiscoNuevo() Then FormProgreso_lblProgreso("Se encontraron problemas en la instalacion")
					Else
;~ 						GUISetState(@SW_SHOW,$FormReinstalacion)
						If Not f_InstalarEnParticiones() Then FormProgreso_lblProgreso("Se encontraron problemas en la instalacion")
                        ;dpf_ObtenerParticiones()
					EndIf
				 Case $btFileSel
					Global $sWimPathFile = FileOpenDialog("Seleccione el archivo WIM conteniendo la imagen", @WindowsDir & "\", "archivos wim (*.wim)", BitOR($FD_FILEMUSTEXIST, $FD_MULTISELECT))
					If $sWimPathFile <> "" Then
						GUICtrlSetData($inFileImagePath, $sWimPathFile)
						CargaListaImagenes($sWimPathFile)
					EndIf
				Case $btCambiarImagen
					GUISetState(@SW_SHOW,$FormSelectImage)
				Case $IconAbout
					GUISetState(@SW_SHOW,$FormAcerca)

			EndSwitch
;~ 		mensaje de la ventana de seleccion de imagen
		Case $nMsg[1] = $FormSelectImage
			EventosSelectImage()
			;mensajes de la ventana q muestra el progreso del despliegue de la imagen
		Case $nMsg[1] = $FormMensajesProgreso
			gi_EventosSelectProgreso()
		Case $nMsg[1] = $FormReinstalacion
			gi_EventosReinstalacion()
			;mensajes de la ventana Acerca
		Case $nMsg[1] = $FormAcerca
			gi_EventosVentanaAcerca()
	EndSelect
WEnd


