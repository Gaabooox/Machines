# Máquina FirstHacking #

Hoy resolveré la máquina FirstHacking de la plataforma DockerLabs.

Temas a tratar:

- Reconocimiento
- Búsqueda de exploits

## Paso 1 ##

Activamos la máquina FirstHacking desde la terminal.

![Alt Imagen1](https://blogger.googleusercontent.com/img/a/AVvXsEig8giUfBNkhyk4aYi175z9U1UNHzpikgASb6Z4FGv5hrMJ_RX1pos223oL4Xjr9-2cuFRimxvaUNNaQ25LT25cd8YSU2XQgleTdxOXc4Il6Ay_2E-e5slEB4vWB-kdD0m-3-rTMPv18geIak4bO9dNoV4GTbOaVGyj9OGSTDOdR3TxwaK96QTKk1abG9ey=w480-h178)

## Paso 2 ##

Realizamos un escaneo utlizando la herramienta **Nmap**

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEjI3nNec6pQl-zmdaoi1HcJq0uQgr8FpvMRZqwmfzbhBkE8IkFfFPHsjp7vJ43yjHJN4Crr5KRVH76feqQ0vmBks0kO_i_PyEqNXIEm2ywrCrp94wyfPDJiTHtzd_7lZmFnqqwhCe9GnBjcyEZ5xopS3aa5aIh-9VOsllEar8Y9oOORvKoG4ujzdV5h0LgY=w506-h327)

- '-p- --open' = Escanea todos los puertos con el estado abierto
- '-sS'= Es un escaneo SYN que evita que el Three-way handshake se complete
- '--min-rate' = Envia paquetes no mas lentos que la cantidad que elijas
- '-n' = Desactiva la resolicion DNS
- '-Pn' = Toma todos los host como activos para evitar hacer ping a cada uno
- '-vvv' = Muestra el proceso en pantalla mientras se va escaneando
- 'oG' = Exporta tu escaneo en un formato grepeable para poder examinarlo mas adelante si se necesita

## Paso 3 ##

Interpretamos la información obtenida.

Tenemos un solo puerto abierto:

- Puerto 21: En este puerto corre el servicio ftp

## Paso 4 ##

Luego de identificar el puertos abierto que corre, debemos examinar mas a detalle como la versión y que esta corriendo exactamente.

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEj6EKWkX2MBrHHRmMGdEzFki-VTcU_YdulGxSZG2mO87Dbo3FJC52zzD84_Xhdi6TgBTNRz4wrbyQWjeFlNbsuakNF8PDr3dKC8u_UFAzrGGcFYqY6THdXHiyyetleET8qG8duNOsKdkdCxVE4ncEYugUR2NSFqvEdwA6o9qR5nmR596S3yJas9-RF6Cd0r=w463-h204)

- 'p-21' = Examina exactamente ese puerto.
- '-sCV' = Lanza scripts basicos de reconocimiento y detecta la version de este.

## Paso 5 ##

Tenemos el servicio FTP con la version vsftpd 2.3.4, como sabemos es una versión muy antigua por lo cual optamos en buscar exploits ya elaborados para esa versión.

![Alt Imagen3](https://blogger.googleusercontent.com/img/a/AVvXsEhy4vW_KagQCY47JAAbzKDK4EuapSXa69DLdu_Qi45D64ZvPp3xzIYGtAWC7O2PYOXHIa7gV9V7dfqG02wrsJsparFibCH69h0WJ-l5Q-E7e-WsgnlBnAsfBx3EZMXXAyW7DjEUzUqcOs2HL8cMlquPLs5nWb77VbHGb8QiopFm7y3WGMRrl-G6eCAuh0gs=w461-h121)

Encontramos un exploit que te genera un backdoor, procedemos a desde el archivo .py, y leer en que consiste.

![Alt Imagen4](https://blogger.googleusercontent.com/img/a/AVvXsEjysistBwAZC0fF_EaxniCDGbiBkMmyYbp8VazrXiCOLapZykc_hSu5afbGqfo5qx6Ej7B_4DlQuS1iADbgqS957VwbD3Cj3cbwJwLMFgpDmxaT8qcWP-WZZoyLIQf_oAPc9qRa_Lvd55V6_mcsv_RFsU2DQa4QPPWaxlFR_BbXIFdjnRzZMNmVdFe5_Lx6=w428-h404)

Leyendo las lineas de codigo, entendemos que esta aprovechandose de un usuario el cual lleve el simbolo ': )', estos simbolos rompen la autenticacion, permitiendonos entrar como usuarios root, cabe recalcar que leyendo el CVE de esta vulneracion ya subsanada, se concluye que es un caso muy atipico y particular.

## Paso 6 ##

Procedemos a ejecutar el archivo py para tener acceso root.

![Alt Imagen5](https://blogger.googleusercontent.com/img/a/AVvXsEjjM_8JqKgQDjWjETBXOheyGeH3RkFYO_tAq3WHwc3Z0iwArFVbo9DnS7MInvhaZ8A1cHfGPpQlM6kTt0s2LleQMP32eYDYs_eIGN1iUwP6Zu-IkUv69eMbC-5U5xjYL07-54raUFEnuRQX_hPJH5PqghATMRXUE8cp1_lr95F6tlzwXKJuPRvVVPWmYuvD=w511-h118)

Como vemos, el exploit si funciona y ya contamos con acceso root de la máquina.

Gracias por leer este WriteUp. :)
