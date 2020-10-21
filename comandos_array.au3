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