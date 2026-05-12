# Máquina BorazuwarahCTF #

Hoy resolveré la máquina BorazuwarahCTF de la plataforma DockerLabs.

Temas a tratar:

- Reconocimiento
- Esteganografía
- Fuerza bruta
- Escalada de privilegios

## Paso 1 ##

Activamos la máquina BorazuwarahCTF desde la terminal.

![Alt Imagen1](https://blogger.googleusercontent.com/img/a/AVvXsEgUHZYRO-GOBxVhu_EvGhJEkcSOf0sanMCTz_mMQZ8O9WmKWBWLud0m8BufVWQau0l1fmVkB6zBELA6Y0EDaSXKZZhnbtvnZ0uZD4Oc2BbUCEpIOOzHIhU67ZDz10K8AYiSlLAEmwQ_BVb852EEWGPLq2GX28zT6j1o_MceEIjdbf253cRUviSohGPWfXl8=w405-h338)

## Paso 2 ##

Realizamos un escaneo utlizando la herramienta **Nmap**

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEiRi5PnNB--1-dUdP95cPgEUfy3D48aEsGT9Iyzqkzrl1i_LX7Hqnj-V36jMQQl_n4ybtGyDWKK4EIP6CC0Zrj4MwCqSXZ0GGvh4Kldax7ABRRK40XYuFWNnVZjsZYQEIcOdrLCqhToNnDe_c9y2tIoH8WslXG5q4DrHUVsRo9RN8CdZWl1af-bFooZRo6o=w465-h324)

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

- Puerto 22: En este puerto corre el servicio ssh
- Puerto 80: En este puerto corre el servicio http

## Paso 4 ##

Luego de identificar el puertos abierto que corre, debemos examinar mas a detalle como la versión y que servicio esta corriendo exactamente.

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEhZUF7ySATyNmycMiTHhwI3zyuPa6qs4j-ALjL1vvao65aTwGibt9QxHjEBFpfakseZdkAjCVx1YBPDsZH4fE3wfyotdRy7b92QsIfs8lUbqqqer83oU32q--doMM-mEHxuX5B4jKRfI8JBBXtX8zhl7m1-stVSi_-dAvxng0wK4QdZsEYrV7BT6ugTg45P=w505-h398)

- 'p-22,80' = Examina exactamente ese puerto.
- '-sCV' = Lanza scripts basicos de reconocimiento y detecta la version de este.

## Paso 5 ##

Tenemos el servicio SSH con la version 9.2p1 y un servicio de apache corriendo en el puerto 80 con la version 2.4.59

En el caso de SSH no podemos vulnerar mediante un exploit ya conocido, por lo cual optamos en ver la pagina que esta corriendo en el puerto 80.

![Alt Imagen3](https://blogger.googleusercontent.com/img/a/AVvXsEiSEob3H7FQZRiFDxPaxCvNrS54VZvdb_jeiL5_31xt1jV_NFV2ANwWRgsn2bD5uud2xdzBBmQVJ3bNEiwxOLj_yGOhNur-u9tcYCxwwcxvhn6O3q3Xfgg2YRM5P8OY8-1dZSutqgvodaW84UdheDGxlLP7hfSNImjvJJVoi3sj_iGolGtYHbKtAszatRgM=w321-h308)

Al visualizar esta imagen, por instinto me hace sospechar que la imagen puede venir con alguna informacián oculta, además porque la imagen es un huevo sorpresa kinder, el cual comercialmente siempre al abrir el huevo encuentras una sorpresa dentro, a esta técnica de ocultar información dentro de archivos se llama esteganografía.

Intentaré obtener la información oculta con la herramienta 'ExifTool' el cual muestra los metadatos

![Alt Imagen4](https://blogger.googleusercontent.com/img/a/AVvXsEj-q7WhPooByluRYFzoE2qgDmUlRKo2unEicX3pkg2NfRPIsX_XAzD-oTR4hm72QiJYaXmNspLBInbpYYRGpim4EH0XokrbYEM9j_gnzlC3uL03sKTb5mkD1ZWfu306uhh1vtqpPzuRf6IFFCdiGaAQnng8JLNI5Z15iBOg46kpFuvRR8HppuUB4q05Aa8m)

Como vemos en los campos de Description y Title se encuentra información del user pero el password aparece vacía.

## Paso 6 ##

Ya teniendo el user 'borazuwarah' podemos intentar realizar un ataque de fuerza bruta, utilizando hydra y la wordlist de rockyou.

![Alt Imagen5](https://blogger.googleusercontent.com/img/a/AVvXsEj3hg2_VQ7KWs_IQX7q29oA_hl6GntePWQYitNIlqonH8s4nR__Fphz7R51chqu6WZMY3gwkyAX0d7aV5gUYarQi0jY5MuzjPaC5CEH--h8xRjUF4sMfyahrSXfe0EaH4dngW6OAdiZEXyS0PIqblInfSJNTGXto-6y3QiYmlKdTAfcFi6x6bJm7GpQdZzT=w506-h103)

Despues de ejecutar hydra con el wordlist de rockyou podemos encontrar la contraseña, la cual usaremos para obtener acceso mediante SSH.

## Paso 7 ##

Ingresamos mediante SSH y vemos que somos el usuario borazuwarah, tendremos que buscar vulnerabilidades para la escalada de privilegio.

![Alt Imagen7](https://blogger.googleusercontent.com/img/a/AVvXsEh4D9hL1FrFy5Whl8YLB701vm3uDObf2RrUZaqliw5e0StEiqlemI9lKJA7DTz9tNKj0q4Ova99a9k_kinizoDcX10yBv3otRNcCPVmxxhXvZv7ZFO90m5mCP7DvHdMEyE41Jr37GN9w3u58QkhBMHzQl4EhPew42jKq3kwe8ocKzb5VRqb5Et0dOCjalXQ=w506-h128)

Observamos que podemos ejecutar comandos superusuario sin necesidad de contraseña, lo cual optaremos en abrir la bash, para seguir buscando vulnerabilidades.

![Alt Imagen8](https://blogger.googleusercontent.com/img/a/AVvXsEj-jEzNfweYTaQPmLdyQ5s4EDLucW0F48Nx3kaS41tRoplHmIFCjHy4yO0iE2PMefLZKUEDBs8DBsQCLdfv-OfbM7xvT7YnKH8k4O3AS_zFtFsbdiaCQz_jcsZLPwfiseBKbFwkR7IPmw75leqv_xLS9u98D01VrrlwRB6Q5MYovic4wHNEhBYSuW316-vR=w547-h70)

Y asi, finalmente ya somos usuarios root, con los privilegios totales.

Gracias por leer este WriteUp. :)
