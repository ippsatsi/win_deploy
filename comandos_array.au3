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

Global $arComandosDiskpartUEFI[16][5]

$arComandosDiskpartUEFI[0][0] = "clean"
$arComandosDiskpartUEFI[0][1] = "ha limpiado"
$arComandosDiskpartUEFI[0][2] = "Limpiando disco"
$arComandosDiskpartUEFI[0][3] = ""

$arComandosDiskpartUEFI[1][0] = "convert gpt"
$arComandosDiskpartUEFI[1][1] = "correctamente el disco"
$arComandosDiskpartUEFI[1][2] = "convirtiendo a gpt"
$arComandosDiskpartUEFI[1][3] = ""

$arComandosDiskpartUEFI[2][0] = "create partition efi size=100"
$arComandosDiskpartUEFI[2][1] = "creado satisfactoriamente la"
$arComandosDiskpartUEFI[2][2] = "creando particion de Sistema"
$arComandosDiskpartUEFI[2][3] = ""

$arComandosDiskpartUEFI[3][0] = 'format quick fs=fat32 label="System"'
$arComandosDiskpartUEFI[3][1] = "volumen correctamente"
$arComandosDiskpartUEFI[3][2] = "forateando particion sistema"
$arComandosDiskpartUEFI[3][3] = ""

$arComandosDiskpartUEFI[4][0] = ""
$arComandosDiskpartUEFI[4][1] = ""
$arComandosDiskpartUEFI[4][2] = ""
$arComandosDiskpartUEFI[4][3] = "Sleep(1000)"

$arComandosDiskpartUEFI[5][0] = 'assign letter="S"'
$arComandosDiskpartUEFI[5][1] = "correctamente"
$arComandosDiskpartUEFI[5][2] = "Asignando letra S a particion de sistema"
$arComandosDiskpartUEFI[5][3] = ""

$arComandosDiskpartUEFI[6][0] = "create partition msr size=16"
$arComandosDiskpartUEFI[6][1] = "ha creado satisfactoriamente"
$arComandosDiskpartUEFI[6][2] = "creando particion especial microsoft"
$arComandosDiskpartUEFI[6][3] = ""

$arComandosDiskpartUEFI[7][0] = "create partition primary"
$arComandosDiskpartUEFI[7][1] = "creado satisfactoriamente la"
$arComandosDiskpartUEFI[7][2] = "creando particion Windows"
$arComandosDiskpartUEFI[7][3] = ""

$arComandosDiskpartUEFI[8][0] = "shrink minimum=650"
$arComandosDiskpartUEFI[8][1] = "correctamente"
$arComandosDiskpartUEFI[8][2] = "reduciendo particion para dar espacio a Recovery"
$arComandosDiskpartUEFI[8][3] = ""

$arComandosDiskpartUEFI[9][0] = 'format quick fs=ntfs label="Windows"'
$arComandosDiskpartUEFI[9][1] = "correctamente"
$arComandosDiskpartUEFI[9][2] = "formateando particion Windows"
$arComandosDiskpartUEFI[9][3] = ""

$arComandosDiskpartUEFI[10][0] = 'assign letter="W"'
$arComandosDiskpartUEFI[10][1] = "correctamente"
$arComandosDiskpartUEFI[10][2] = "asignando letra W a Windows"
$arComandosDiskpartUEFI[10][3] = ""

$arComandosDiskpartUEFI[11][0] = 'create partition primary'
$arComandosDiskpartUEFI[11][1] = "creado satisfactoriamente la"
$arComandosDiskpartUEFI[11][2] = "creando particion Recovery"
$arComandosDiskpartUEFI[11][3] = ""

$arComandosDiskpartUEFI[12][0] = 'format quick fs=ntfs label="Recovery tools"'
$arComandosDiskpartUEFI[12][1] = "correctamente"
$arComandosDiskpartUEFI[12][2] = "formateando particion Recovery"
$arComandosDiskpartUEFI[12][3] = ""

$arComandosDiskpartUEFI[13][0] = 'assign letter="R"'
$arComandosDiskpartUEFI[13][1] = "correctamente"
$arComandosDiskpartUEFI[13][2] = "asignando letra R a Recovery"
$arComandosDiskpartUEFI[13][3] = ""

$arComandosDiskpartUEFI[14][0] = 'set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac" override'
$arComandosDiskpartUEFI[14][1] = "correctamente"
$arComandosDiskpartUEFI[14][2] = "colocando atributo a Recovery"
$arComandosDiskpartUEFI[14][3] = ""

$arComandosDiskpartUEFI[15][0] = 'gpt attributes=0x8000000000000001'
$arComandosDiskpartUEFI[15][1] = "correctamente"
$arComandosDiskpartUEFI[15][2] = "ocultando a Recovery"
$arComandosDiskpartUEFI[15][3] = ""

