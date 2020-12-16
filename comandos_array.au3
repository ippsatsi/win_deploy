;Data
Global $arUnidadesBasicas[3][2]
$arUnidadesBasicas[0][0] = "S:"
$arUnidadesBasicas[0][1] = "System"
$arUnidadesBasicas[1][0] = "W:"
$arUnidadesBasicas[1][1] = "Windows"
$arUnidadesBasicas[2][0] = "R:"
$arUnidadesBasicas[2][1] = "Recovery"

;Comandos
Global $arrayComandos[6][5]

$arrayComandos[0][0] = "Activando Particion De Sistema..." ; Tarea a mostrar
$arrayComandos[0][1] = 'W:\Windows\System32\bcdboot W:\Windows /l es-mx /s S: /f ??param??' ; commando a ejecutar
$arrayComandos[0][2] = 'Archivos de arranque creados correctamente' ; salida a comparar si es exitoso
$arrayComandos[0][3] = 'Activacion' ; texto alternativo de tarea
$arrayComandos[0][4] = 'cmd' ; texto alternativo de tarea
;
$arrayComandos[1][0] = "Creando carpeta recovery..." ; Tarea a mostrar
$arrayComandos[1][1] = 'W:\Windows\System32\bcdboot W:\Windows /l es-mx /s S: /f ??param??' ; commando a ejecutar
$arrayComandos[1][2] = 'Carpeta recovery creada correctamente' ; salida a comparar si es exitoso
$arrayComandos[1][3] = 'Creacion carpeta recovery' ; texto alternativo de tarea
$arrayComandos[1][4] = 'autoit' ; texto alternativo de tarea
;Copiado con  particion Recovery
$arrayComandos[2][0] = "Copiando Winre.Wim..." ; Tarea a mostrar
$arrayComandos[2][1] = 'copy /y ??param??\winre.wim R:\Recovery\WindowsRE\winre.wim' ; commando a ejecutar
$arrayComandos[2][2] = '1 archivo(s) copiado(s)' ; salida a comparar si es exitoso
$arrayComandos[2][3] = 'Copiado Winre.wim' ; texto alternativo de tarea
$arrayComandos[2][4] = 2 ; cuantas tareas avanzamos si es exitoso el resultado
;Copiado sin  particion Recovery
$arrayComandos[3][0] = "Copiando Winre.Wim a la partición Windows ..." ; Tarea a mostrar
$arrayComandos[3][1] = 'copy /y ??param??\winre.wim W:\Windows\System32\Recovery\winre.wim' ; commando a ejecutar
$arrayComandos[3][2] = '1 archivo(s) copiado(s)' ; salida a comparar si es exitoso
$arrayComandos[3][3] = 'Copiado Winre.wim a W:' ; texto alternativo de tarea
$arrayComandos[3][4] = 1 ; cuantas tareas avanzamos si es exitoso el resultado
;
$arrayComandos[4][0] = "Registrando Winre.Wim..." ; Tarea a mostrar
$arrayComandos[4][1] = 'W:\Windows\System32\reagentc /setreimage /path ??param?? /target W:\Windows' ; commando a ejecutar
$arrayComandos[4][2] = 'n efectuada correctamente' ; salida a comparar si es exitoso
$arrayComandos[4][3] = 'Registro Winre.wim' ; texto alternativo de tarea
$arrayComandos[4][4] = 'cmd' ; texto alternativo de tarea
;
$arrayComandos[5][0] = "Registrando Winre.Wim..." ; Tarea a mostrar
$arrayComandos[5][1] = 'W:\Windows\System32\reagentc /setreimage /path ??param?? /target W:\Windows' ; commando a ejecutar
$arrayComandos[5][2] = 'La operación se completó correctamente' ; salida a comparar si es exitoso
$arrayComandos[5][3] = 'Registro Winre.wim' ; texto alternativo de tarea
$arrayComandos[5][4] = 'cmd' ; texto alternativo de tarea

Global $arPrepararUEFI[17][5]

$arPrepararUEFI[0][0] = "clean"
$arPrepararUEFI[0][1] = "ha limpiado"
$arPrepararUEFI[0][2] = "Limpiando disco"
$arPrepararUEFI[0][3] = ""

$arPrepararUEFI[1][0] = "convert gpt"
$arPrepararUEFI[1][1] = "correctamente el disco"
$arPrepararUEFI[1][2] = "convirtiendo a gpt"
$arPrepararUEFI[1][3] = ""

$arPrepararUEFI[2][0] = "create partition efi size=100"
$arPrepararUEFI[2][1] = "creado satisfactoriamente la"
$arPrepararUEFI[2][2] = "creando particion de Sistema"
$arPrepararUEFI[2][3] = ""

$arPrepararUEFI[3][0] = 'format quick fs=fat32 label="System"'
$arPrepararUEFI[3][1] = "volumen correctamente"
$arPrepararUEFI[3][2] = "forateando particion sistema"
$arPrepararUEFI[3][3] = ""

$arPrepararUEFI[4][0] = ""
$arPrepararUEFI[4][1] = ""
$arPrepararUEFI[4][2] = ""
$arPrepararUEFI[4][3] = "Sleep(2000)"

$arPrepararUEFI[5][0] = 'assign letter="S"'
$arPrepararUEFI[5][1] = "correctamente"
$arPrepararUEFI[5][2] = "Asignando letra S a particion de sistema"
$arPrepararUEFI[5][3] = ""

$arPrepararUEFI[6][0] = "create partition msr size=16"
$arPrepararUEFI[6][1] = "ha creado satisfactoriamente"
$arPrepararUEFI[6][2] = "creando particion especial microsoft"
$arPrepararUEFI[6][3] = ""

$arPrepararUEFI[7][0] = "create partition primary"
$arPrepararUEFI[7][1] = "creado satisfactoriamente la"
$arPrepararUEFI[7][2] = "creando particion Windows"
$arPrepararUEFI[7][3] = ""

$arPrepararUEFI[8][0] = "shrink minimum=650"
$arPrepararUEFI[8][1] = "correctamente"
$arPrepararUEFI[8][2] = "reduciendo particion para dar espacio a Recovery"
$arPrepararUEFI[8][3] = ""
; le damos tiempo al comando shrink q finalice
$arPrepararUEFI[9][0] = ""
$arPrepararUEFI[9][1] = ""
$arPrepararUEFI[9][2] = ""
$arPrepararUEFI[9][3] = "Sleep(2000)"

$arPrepararUEFI[10][0] = 'format quick fs=ntfs label="Windows"'
$arPrepararUEFI[10][1] = "correctamente"
$arPrepararUEFI[10][2] = "formateando particion Windows"
$arPrepararUEFI[10][3] = ""

$arPrepararUEFI[11][0] = 'assign letter="W"'
$arPrepararUEFI[11][1] = "correctamente"
$arPrepararUEFI[11][2] = "asignando letra W a Windows"
$arPrepararUEFI[11][3] = ""

$arPrepararUEFI[12][0] = 'create partition primary'
$arPrepararUEFI[12][1] = "creado satisfactoriamente la"
$arPrepararUEFI[12][2] = "creando particion Recovery"
$arPrepararUEFI[12][3] = ""

$arPrepararUEFI[13][0] = 'format quick fs=ntfs label="Recovery"'
$arPrepararUEFI[13][1] = "correctamente"
$arPrepararUEFI[13][2] = "formateando particion Recovery"
$arPrepararUEFI[13][3] = ""

$arPrepararUEFI[14][0] = 'assign letter="R"'
$arPrepararUEFI[14][1] = "correctamente"
$arPrepararUEFI[14][2] = "asignando letra R a Recovery"
$arPrepararUEFI[14][3] = ""

$arPrepararUEFI[15][0] = 'set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac" override'
$arPrepararUEFI[15][1] = "correctamente"
$arPrepararUEFI[15][2] = "colocando atributo a Recovery"
$arPrepararUEFI[15][3] = ""

$arPrepararUEFI[16][0] = 'gpt attributes=0x8000000000000001'
$arPrepararUEFI[16][1] = "correctamente"
$arPrepararUEFI[16][2] = "ocultando a Recovery"
$arPrepararUEFI[16][3] = ""

Global $arPrepararMBR[15][5]

$arPrepararMBR[0][0] = "clean"
$arPrepararMBR[0][1] = "ha limpiado"
$arPrepararMBR[0][2] = "Limpiando disco"
$arPrepararMBR[0][3] = ""

$arPrepararMBR[1][0] = "create partition primary size=100"
$arPrepararMBR[1][1] = "creado satisfactoriamente la"
$arPrepararMBR[1][2] = "creando particion de Sistema"
$arPrepararMBR[1][3] = ""

$arPrepararMBR[2][0] = 'format quick fs=ntfs label="System"'
$arPrepararMBR[2][1] = "volumen correctamente"
$arPrepararMBR[2][2] = "forateando particion sistema"
$arPrepararMBR[2][3] = ""

$arPrepararMBR[3][0] = ""
$arPrepararMBR[3][1] = ""
$arPrepararMBR[3][2] = ""
$arPrepararMBR[3][3] = "Sleep(2000)"

$arPrepararMBR[4][0] = 'assign letter="S"'
$arPrepararMBR[4][1] = "correctamente"
$arPrepararMBR[4][2] = "Asignando letra S a particion de sistema"
$arPrepararMBR[4][3] = ""

$arPrepararMBR[5][0] = "active"
$arPrepararMBR[5][1] = " actual como activa"
$arPrepararMBR[5][2] = "activando la particion de sistema"
$arPrepararMBR[5][3] = ""

$arPrepararMBR[6][0] = "create partition primary"
$arPrepararMBR[6][1] = "creado satisfactoriamente la"
$arPrepararMBR[6][2] = "creando particion Windows"
$arPrepararMBR[6][3] = ""

$arPrepararMBR[7][0] = "shrink minimum=650"
$arPrepararMBR[7][1] = "correctamente"
$arPrepararMBR[7][2] = "reduciendo particion para dar espacio a Recovery"
$arPrepararMBR[7][3] = ""
; le damos tiempo al comando shrink q finalice
$arPrepararMBR[8][0] = ""
$arPrepararMBR[8][1] = ""
$arPrepararMBR[8][2] = ""
$arPrepararMBR[8][3] = "Sleep(2000)"

$arPrepararMBR[9][0] = 'format quick fs=ntfs label="Windows"'
$arPrepararMBR[9][1] = "correctamente"
$arPrepararMBR[9][2] = "formateando particion Windows"
$arPrepararMBR[9][3] = ""

$arPrepararMBR[10][0] = 'assign letter="W"'
$arPrepararMBR[10][1] = "correctamente"
$arPrepararMBR[10][2] = "asignando letra W a Windows"
$arPrepararMBR[10][3] = ""

$arPrepararMBR[11][0] = 'create partition primary'
$arPrepararMBR[11][1] = "creado satisfactoriamente la"
$arPrepararMBR[11][2] = "creando particion Recovery"
$arPrepararMBR[11][3] = ""

$arPrepararMBR[12][0] = 'format quick fs=ntfs label="Recovery"'
$arPrepararMBR[12][1] = "correctamente"
$arPrepararMBR[12][2] = "formateando particion Recovery"
$arPrepararMBR[12][3] = ""

$arPrepararMBR[13][0] = 'assign letter="R"'
$arPrepararMBR[13][1] = "correctamente"
$arPrepararMBR[13][2] = "asignando letra R a Recovery"
$arPrepararMBR[13][3] = ""

$arPrepararMBR[14][0] = 'set id=27 override'
$arPrepararMBR[14][1] = "correctamente"
$arPrepararMBR[14][2] = "colocando atributo a Recovery"
$arPrepararMBR[14][3] = ""

