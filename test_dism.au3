#RequireAdmin

#include <Array.au3>

$wimfile = "C:\WinPE_amd64\media\sources\boot.wim"
$targetpath = "C:\WinPE_amd64\mount"
$percent = 0
$value = 0
$Title = "Bogus"


$DISMp = Run(@ComSpec & " /c title " & $Title & "|" & 'Dism.exe /Mount-Image /ImageFile:"' & $wimfile & '" /index:1 /mountdir:"' & $targetpath, "", "", 2 + 4)

Local $hTimer = TimerInit()

ProgressOn("Image Load", "Deploying Image", "0 percent")
While ProcessExists($DISMp)
    $line = StdoutRead($DISMp, 5)
	;ConsoleWrite($line)

    If StringInStr($line, ".0%") Then
        $line1 = StringSplit($line, ".")
		;_ArrayDisplay( StringSplit( $line, @LF), "asDisksxxx")
        $value = StringRight($line1[$line1[0] - 1], 2)
        $value = StringStripWS($value, 7)
    EndIf
    If $value == "00" Then $value = 100
    If @error Then ExitLoop
    Sleep(50)
    If $percent <> $value Then
		$iRatioRestante = (100 - $value)/$value
		$mmTiempoTranscurrido = TimerDiff($hTimer)
		$mmTiempoEstimadoTotal = ($mmTiempoTranscurrido * $iRatioRestante) + $mmTiempoTranscurrido
		$ssTiempoTranscurrido = Floor($mmTiempoTranscurrido/1000)
		$ssTiempoTotal = Floor($mmTiempoEstimadoTotal/1000)
        ProgressSet($value, "Deploying Image Total Est: " & $ssTiempoTotal & " seg ", "Boot.wim Trancurrido: " & $ssTiempoTranscurrido & " seg " & $value & "%")
        $percent = $value
    EndIf
    If $value = 100 Then ExitLoop
WEnd


$DISMp = Run(@ComSpec & " /c title " & $Title & "|" & 'Dism.exe /Unmount-Image '  & ' /mountdir:"' & $targetpath & '" /discard', "", "", 2 + 4)
ProcessWaitClose($DISMp)
ProgressOff()

;~ Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /commit
;~ Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /discard
;~ Dism /Mount-Image /ImageFile:"C:\WinPE_amd64\media\sources\boot.wim" /index:1 /MountDir:"C:\WinPE_amd64\mount"
;~ https://www.autoitscript.com/forum/topic/123970-dism-console-progress-using-stdoutread/page/2/#comments
;~ https://www.autoitscript.com/forum/topic/127075-wimgapi-udf/#comments
;~ dism /Apply-Image /ImageFile:N:\Images\my-windows-partition.wim /Index:1 /ApplyDir:W:\