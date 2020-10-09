#RequireAdmin
$wimfile = "C:\WinPE_amd64\media\sources\boot.wim"
$targetpath = "C:\WinPE_amd64\mount"
$percent = 0
$value = 0
$Title = "Bogus"


$DISMp = Run(@ComSpec & " /c title " & $Title & "|" & 'Dism.exe /Mount-Image /ImageFile:"' & $wimfile & '" /index:1 /mountdir:"' & $targetpath, "", "", 2 + 4)



ProgressOn("Image Load", "Deploying Image", "0 percent")
While ProcessExists($DISMp)
    $line = StdoutRead($DISMp, 5)
	ConsoleWrite($line)
    If StringInStr($line, ".0%") Then
        $line1 = StringSplit($line, ".")
        $value = StringRight($line1[$line1[0] - 1], 2)
        $value = StringStripWS($value, 7)
    EndIf
    If $value == "00" Then $value = 100
    If @error Then ExitLoop
    Sleep(50)
    If $percent <> $value Then
        ProgressSet($value, "Deploying Image", "Boot.wim" & $value & "%")
        $percent = $value
    EndIf
    If $value = 100 Then ExitLoop
WEnd

ProgressOff()

;~ Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /commit
;~ Dism /Unmount-Image /MountDir:"C:\WinPE_amd64\mount" /discard
;~ Dism /Mount-Image /ImageFile:"C:\WinPE_amd64\media\sources\boot.wim" /index:1 /MountDir:"C:\WinPE_amd64\mount"
;~ https://www.autoitscript.com/forum/topic/123970-dism-console-progress-using-stdoutread/page/2/#comments
;~ https://www.autoitscript.com/forum/topic/127075-wimgapi-udf/#comments