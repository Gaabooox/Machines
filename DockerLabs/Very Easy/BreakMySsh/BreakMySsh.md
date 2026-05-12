# Máquina Break My Ssh #

Hoy resolveré la máquina BreakMySsh de la plataforma DockerLabs.
Temas a tratar:

- Reconocimiento
- Fuerza bruta
- Escala de privilegios

## Paso 1 ##

Activamos la máquina BreakMySsh desde la terminal.

![Alt Imagen1](https://blogger.googleusercontent.com/img/a/AVvXsEhHL3GTohf06oNNUgLtoa2UDM-dOWO4BTjyW3DQYy6DQQ3zqoQ5d0Nin-784RRYDmbGHqZmfbTITtHHkRXTYa5-SnrIhWcGDhWGvMahCd5x19UmNb00kxCwxbKXuGubasoh7XRKXGiXHByy9Lu3wq-HlTOW14UOU3qFaucn8BiP9rLvj6qzjqw04whQUboP=w399-h147)

## Paso 2 ##

Realizamos un escaneo utlizando la herramienta **Nmap**

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEi9iEssywqu0JCrPxFxCSUkEKRCElSjmEHyo1JDeOS_B-QxjEyzMHCkVOvX3tfiksJVGsXX3jJ9zqpYQ3M1mnqcwEWuMKZNPbOYYEJ_rdJFYBI4OoOm8uFNSPJwDuTazp0zHt31bHEcG4QNhA9IFqox3pKWDLB1r9fx6Z7h28eSyhR4fNt-fyUVGE8BGdrf=w481-h358)

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

## Paso 4 ##

Luego de identificar los puertos y el servicio que corre, debemos examinar mas a detalle como la versión y que esta corriendo exactamente.

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEixkcODpLPWpzkVWegUo07aQgSeD-XDfzak9HDkj63iA6fnF-FO7eqK35Hn5bfWFe5Fi57Pev0vfoAm7gPxY65DG-vfX8GwkAjNkJW3TYyqVzaYRhdA-E5Z53dqyuPQVToP3hlH9CIuwVRI8_3gh2yp_-W52B_esXjXXrRicsn5YhCFPJz3PKnFQq3y4SIf=w543-h219)

- 'p-22' = Examina exactamente ese puerto.
- '-sCV' = Lanza scripts basicos de reconocimiento y detecta la version de este.

## Paso 5 ##

Tenemos el servicio SSH con la version OpenSSH 7.7 protocol 2, como sabemos es una versión muy antigua por lo cual optamos en buscar exploits ya elaborados para esa versión.

![Alt Imagen3](https://blogger.googleusercontent.com/img/a/AVvXsEiqFy0caQCdtSFunnmgFMfoZoSDvEEVweimQfdGUIjyseI5c9hxFWSztkUv9r4_2GpolArJ2tUvLNEr9NTmC3l1OtjgHZBWJ9Qe8-hKy0yy7HNuPfjF_XYZe2-Swu3pIhbGJYzhGVKf7sG_hXRhMXLIhwhfpAEgYiXnZeSIZ9d7FbPMtZmHlx5o3KVWBqW0=w507-h155)

![Alt Imagen4](https://blogger.googleusercontent.com/img/a/AVvXsEgbtALMdBkMhsoyGLUFtEu4wuMxqP34Os-OTekcaVHsd6u0_HRkNVcfcx5dF3-a1q4tJhWjuO1Y7Fckf9klQMN1CEcCnzzJJV0j0ZPirCC38AMY7G9G1d4QPvs9Cf_8IMhPvMxE5GtyrBWUXtOPRVDDMApYNrW9CFxzYJNZ8jseVrq-sEaok4mApH1lcmE4=w400-h323)

Examinamos los exploits pero son version python 2, lo cual genera incompatibilidad por lo cual optamos por hacer un ataque de fuerza bruta con hydra.

## Paso 6 ##

Procedemos a realizar el ataque con hydra al servicio SSH usando un diccionario de usuarios y contraseñas comunes.

![Alt Imagen5](https://blogger.googleusercontent.com/img/a/AVvXsEh4G3mEhXMOYXToQBa0f3kPEKFa7K4r8WmzHwV5a6AI3a7ez4E1cl-ht5Tsad0Tu-PzKddMWL1GlmBR2iRilrBFBuUIFvLM7q-KVP_E27orj0NTgDfOdWplM0BcN-UDvkbbMW8GD4JxfHIujF7UYO38qNivAaF3Y_R9Xn57b23k-Ryj8OsBm0DQjt2h6aeZ=w580-h145)

- '-L' = Indica el diccionario de usuarios que vamos a probar.
- '-P'= Indica el diccionario de contraseñas que vamos a usar.

Encontramos el usuario 'root' y la contraseña 'estrella', la cual probaremos para tener acceso mediante SSH.

## Paso 7 ##

Entramos mediante SSH desde la consola probando el usuario 'root' y la contraseña 'estrella'.

![Alt Imagen6](https://blogger.googleusercontent.com/img/a/AVvXsEgflFv6X_196k2PPREwSG00wvl65MK9SpGVIDrWvonnwlW13G9Tn6G2qIelpsTlIXVqGDCuhiJ3CZr4A8L7hr8SloTqC33oq7Ulj8a6Ivgyj7x9Jznxc-6noigvtVfFW8SJ3i5LWCp9WgXwz03bSXahYrXQeZ1ilquXsvrl0Fvlc2FinHzGwdF1assXh0tl=w493-h245)

Como vemos, el usuario y la contraseña si funcionan y ya contamos con acceso root de la máquina.

Gracias por leer este WriteUp. :)
