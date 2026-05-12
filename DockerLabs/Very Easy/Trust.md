# Máquina Trust #

Hoy resolveré la máquina Trust de la plataforma DockerLabs.
Temas a tratar:

- Reconocimiento
- Fuzzing
- Escala de privilegios

## Paso 1 ##

Activamos la máquina Trust desde la terminal.

![Alt Imagen1](https://blogger.googleusercontent.com/img/a/AVvXsEhrhycyEPU8XXyvp5xMaM3OogD5F6_MUp-j_9qHWOeAJorkrRxAHZ1MslroqvVYMexoUw4wZWcBpnI1jnf4f0yeRnF9pAM9SS6bD5H2aLPZyLTN19_QaAMoJwtdgbZ2yAbPir3BfgjISduHRBXOgDPM7Opyx1mGjOMGy2eMiLh4Ye8oL8PtkCCXVFE9YKne=w353-h267)

## Paso 2 ##

Realizamos un escaneo utlizando la herramienta **Nmap**

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEiFgDJC9NG444l0PZwvTuF_mVwcAHgthR0EzWOFVecYdMoIhfCWbKs6W8Q5Ekr-aQtcyglQKvnjLLwSyCWBV__RN0nF1WsRu7FIqFS2x9FuVCtNpV41tqFP8hTNsyTX0UQkbnI_Gr0eFBpK56WBwyno6-G4YxD2v1ajoNh-vdLcDpojkqmCDP76UlFwzw9r=w390-h252)

- '-p- --open' = Escanea todos los puertos con el estado abierto
- '-sS'= Es un escaneo SYN que evita que el Three-way handshake se complete
- '--min-rate' = Envia paquetes no mas lentos que la cantidad que elijas
- '-n' = Desactiva la resolicion DNS
- '-Pn' = Toma todos los host como activos para evitar hacer ping a cada uno
- '-vvv' = Muestra el proceso en pantalla mientras se va escaneando
- 'oG' = Exporta tu escaneo en un formato grepeable para poder examinarlo mas adelante si se necesita

## Paso 3 ##

Interpretamos la información obtenida.

Tenemos dos puertos abiertos:

- Puerto 22: En este puerto corre el servicio ssh
- Puerto 80: En este puerto corre el servicio http

## Paso 4 ##

Luego de identificar los puertos y el servicio que corre, debemos examinar mas a detalle como la version y que esta corriendo exactamente.

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEiSkYfgFGUWPMcHXF8FtJlhEBD9ZkR2S4W8KhgtJ9h1l1prUThhBRClL9NYxzwMAY5X-OtsFc2BXV25tS1Lf8zLyYtjoYajvrpYj9QxWNkBl-P8JP565yu7OZ-4svb4bdEftsmvjDWxvlAVGR3wZbbpBWiqGBRoZQ-7JKQYf0ubPaQUjU8Y5cd68uz4cWe6=w578-h235)

- 'p-22,80' = Examina exactamente esos dos puertos.
- '-sCV' = Lanza scripts basicos de reconocimiento y detecta la version de este.

## Paso 5 ##

Tenemos el servicio SSH con la version OpenSSH 9.2p1 y en el puerto 80 el servicio de Apache con la version httpd 2.4.57

En el caso de SSH no tenemos ni usuarios ni contraseñas, asi que optaremos por entrar a la página web desde nuestro navegador.

![Alt Imagen3](https://blogger.googleusercontent.com/img/a/AVvXsEhCQF_OCDe8cITrntNw6a2PUYk6AjFGqLtcCsShqFye39DKS7mve7ah_LspDp3hCFiCFcwIpHM5jRcxa5kA35eRjlBoGm2DPNt2H4iZtMcVHz9vKdgBVqUh0OG_pMoRu4pSq8AiN08MvcuEQnzF4ozniGUt_apGDwdT1nqFpUybKVZ6HIs48zAEtmGWlLSc=w588-h270)

Como vemos es una página web predeterminada de Apache, por mi parte realice un scaneo por wireshark y un analisis a la solicitud por burpsuite pero no encontre nada fuera de lo comun ni nada que pueda comprometer la máquina.

## Paso 6 ##

Opte por realizar un ataque de fuzzing para encontrar rutas escondidas en la página entre ellos archivos php, html o text.

Utilice la herramienta gobuster para el fuzzeo, de igual manera puedes usar el que tu desees.

![Alt Imagen4](https://blogger.googleusercontent.com/img/a/AVvXsEjpgU7i6KX7sQS-drgrQpbderbtLbANWdGyY5tzVEGg8mM3bTyFPGR2q_mJtpqC4-vOxPonwVCwr2e1N6l6SZjGN6h1xlEz4e2vKEeNs_Js1IrLMhqm20acnrRDGZv4cAzmFqiCs441gJrIAgHIjYyR0osYagC8C89ijLk9pLglaKvK863e4BQUdkkf2Z3J=w622-h231)

- '-u' = Indica la dirección web.
- '-w'= Indica el diccionario que vamos a usar.
- '-x' = Indica extensiones que tambien quieres que se analicen si existen o no.
- '-b' = Elimina las respuesta de servidor que tu elijas para disminuir ruido visual.

## Paso 7 ##

En la imagen anterior pudimos visualizar que hay un documento llamado secret.php, el cual accederemos desde la web para ver el contenido.

![Alt Imagen5](https://blogger.googleusercontent.com/img/a/AVvXsEjfHa-_I4khYQ3YuZynFC5-f5YNCX4ITHGbNZJ_3Its_LWwSYkjQbWEsO_1CRAdycpWwwCFdYvwAOH95_JReBFraaYJi8_iYs-5_qOg63hmQt3vU5t3QRE-jdNOGf8vDCayuaN5Qt3P-VzyM8DCDPRopBLKq2qhnFlsGHUPOkl7sv_GIk2-QAwBDpj_-xn1=w553-h253)

Al ver la página tenemos un posible usuario llamado Mario, el cual podemos usarlo para realizar un ataque de fuerza bruta con Hydra al servicio de SSH.

## Paso 8 ##

Procedemos a realizar el ataque con hydra al servicio SSH usando el posible usuario anterior llamado Mario.

![Alt Imagen6](https://blogger.googleusercontent.com/img/a/AVvXsEhakGGPYm5EYQPRI_58MwnqpRM7oYUVGYWD9s_QXYQ5du-zk4f_GqO7ue8Ek5gjR715zN-ZoCoWS1ksDnP0coUN-t85CsrC5X4dhlQczAKt6mLZUvE7xGAUB9QqOdGc2UsBxNrxMf4OjyKW9SdkxueNlxtJ3Ewf5tS6SHcjCt-5CIq3jWAbq247UA9PC_9Y=w650-h93)

- '-l' = Indica el usuario que vamos a probar.
- '-P'= Indica el diccionario que vamos a usar.

Encontramos la contraseña 'Chocolate', la cual probaremos para tener acceso mediante SSH.

## Paso 9 ##

Entramos mediante SSH desde la consola probando el usuario 'Mario' y la contraseña 'Chocolate'.

![Alt Imagen7](https://blogger.googleusercontent.com/img/a/AVvXsEi9pPGMtMotGBs2zrW5r1luEnCD4YPVCA3ogBVag9E7AEqt_lKU4VZwxFpxtSuXLgRvMHZ400S30_MHv9UfMSmq4ITSRe8unKafxX983_vSroqxjd5cEGLaYj64ghu2-YMXT_8rg2NtT7yOrEmGgrO2wSEK2XKay_jXuMTFT1PbNeGtzO1ar7BpIWubWGgK=w518-h207)

## Paso 10 ##

Al ver que ya estamos con el usuario de Mario, procedemos a listar los comandos permitidos para ejecturse como super usuario.

![Alt Imagen8](https://blogger.googleusercontent.com/img/a/AVvXsEjo00JfqPxwK-qvw8NrvYlTxRiW0QmcvjFOvu_FgNgEEb0NnfpIznnX_pwgXO_E9eDG6JsStLYm2z5_lxuGynHl03QKoWk92FgOSo0RyXUQb5NVO6TvtyAsiWAiW2R1UMtmgBrm7hmP_rmeFF-g0K4hHVrWqaK1a_ZFwowumzzGvArE31VDZyVQCvwInMIG=w542-h127)

En la imágen, podemos ver que 'vim' se puede ejecutar como superusuario.
    *Vim : Es un editor de texto parecido a visual studio code, pero que corre desde la terminal.

## Paso 11 ##

Probamos que efectivamente vim se pueda correr como super usuario, para lograr tener el acceso a root.

![Alt Imagen9](https://blogger.googleusercontent.com/img/a/AVvXsEhCa9R4mX4KjzRkKKzUZ_s_pb-8f4BVHPltONCyoow5yrHCrLRH44jsIP0dfUcp9b6LPlKmUUWRz_1-X_3EQOJBXw01NLi6nREmXKhsRD13xjsTLYlL-oKNg_uqz1JsJf-X5DAIYnUEB9WmHvnz9Im76PrBeXdWj-RZMrKv5g_V2dfaPBadamYYWNpsJ8mt=w552-h124)

![Alt Imagen10](https://blogger.googleusercontent.com/img/a/AVvXsEh68Q3uf2xfL3pi_HUcukm39ZsYVpKpJo-Am2kqQn-DBkNJExBFJz1b2jZZbtREzdEhrZ3Uldj826oPl0fOEtYbQLkeb2zp6tL-5n5mSr65AI7dm67mtDswZQsDtz8OJIRmMFYdq6SSEoPh2cHqejSLDhsnXq6nWFeU7EZxUEf8X3M31obJXSn_M6keDUfe=w586-h102)

Teniendo esto, ya contamos con acceso a root y como cereza del pastel podemos hacer que el usuario mario siempre tenga el acceso a root sin necesidad de contraseña modificando el archivo sudoers y agrega la línea 'mario ALL=(ALL) NOPASSWD: ALL' y guardamos los cambios.

![Alt Imagen11](https://blogger.googleusercontent.com/img/a/AVvXsEgkohFFMq8JMjMBNXQT2Cu22OZadG3j6Zdpp7Zvp6V2hqBJGmTcjI2qR5EWYk76CUCRoo-kh-FQQU7N727SprRaCj_CQEML7JpUNG-1LmUdUyR9D43NLGtjffzEdQI6-pOgcCSFXINJAOdyxmXpZDxcuJMmWtrw1Hm57qNzUaOIs8s25c7_DQQdXbqWPtl2=w489-h128)

Comprobamos lo realizado:

![Alt Imagen12](https://blogger.googleusercontent.com/img/a/AVvXsEialK8YD1_h6VPsmooWUGr7QdMQrEnYVv4spc598dnHKAjo7O0CPIXQJpkJvyrEh4jqQ-NxvyReuHYa5uM_QoFssZkx_0vSBgf4WFsFizCPxbYcawIgpGYN884vpQox1oZ_JbfzvhpNuUsjUifcAElInxNSF6Vt92du9mYQAz5UlxWQcYG2x__uP3hQmU8e=w524-h93)

Como vemos, el usuario mario ya puede ser superusuario sin neccesidad de contraseña.
Gracias por leer este WriteUp. :)
