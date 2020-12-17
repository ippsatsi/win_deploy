;dism /get-imageinfo /imagefile:
Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)