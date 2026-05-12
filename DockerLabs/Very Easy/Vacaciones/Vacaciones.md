# Máquina Vacaciones #

Hoy resolveré la máquina Vacaciones de la plataforma DockerLabs.

Temas a tratar:

- Reconocimiento
- Fuerza bruta
- Escalada de privilegios

## Paso 1 ##

Activamos la máquina Vacaciones desde la terminal.

![Alt Imagen1](https://blogger.googleusercontent.com/img/a/AVvXsEhLEHN6wmvSOhsGlAZiMmBqbfMU7sM1YR1DtKG0ubJCQIoYHC-v5BeEM6BUqy1X2IAX0_BfaajGyjpu7w5TbfX6KMWaPp_84cg1SeAOQu3AAhPP220UkQ28LxhOpFlgOGfb1lMJvZyLbAwotg5tr5smdT9KWrhCQNZkPq9LC78BDsVymkZLgA9gomHi-TIX=w489-h174)

## Paso 2 ##

Realizamos un escaneo utlizando la herramienta **Nmap**

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEixguKHadv4l5dMDMo-0ZflEd91uzP7oTnqJIyaOSvNvMp9S5HbO23mxkub8pqs3iWqXGEKzUnxlpxybrUfbUEEruDNStBMwkQMFd8gQgHBq0uUja5sBjTrOuI4vxdrOR6Xus7eu88lk_Ftwd96HD3ixMzX5wIeZT7o-BsaTNj8Hj5lP501q50tktN2QMi6=w604-h296)

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

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEgZknSZfSmx9LAvBsjKR42H6NxjSAOVNa6WpaVecc8ryDK_KsWW-DoXwIROCkWtQvF_pSNjVPaLIZ0_Q6MU2WPtvHuRj-dKvzvBrKON_l_G1DCDoag-sDabS-xTwVKgNdMYJ3gWmwrEaubDcN6JCB25OzwRahoECOMOa7pKHIBPB-WzKQstfpeVemay_Qpw=w488-h372)

- 'p-22,80' = Examina exactamente ese puerto.
- '-sCV' = Lanza scripts basicos de reconocimiento y detecta la version de este.

## Paso 5 ##

Tenemos el servicio SSH con la version 7.6p1 y un servicio de apache corriendo en el puerto 80 con la version 2.4.29

Al entrar a la página web vemos que no hay nada, ni titulo ni contenido.

![Alt Imagen3](https://blogger.googleusercontent.com/img/a/AVvXsEichJcq6JQITJPdhdnMLd591tGUcRsgMuVBziySZaMiQ1oDOi635esZIXLWHPGs_cg3kGMecAeVelotBRKyfmEhUqfnZnH5JEnXtReneBi6qYZ2JaCQunE8UFpNFFbjWhZZ1t36qxKix0pki2-Sob1EzoRj-AmgDnPS23KxFWouAqbMron2GCUJ2TJzNILl=w557-h256)

Optamos por entrar a inspeccionar la página con la herramienta del mismo navegador y encontramos que había un comentario.

![Alt Imagen4](https://blogger.googleusercontent.com/img/a/AVvXsEiyCFSs1_VNaZ7RcyB3tcle6erOUOdrjQnNsDdTmyYSPHXLA0xGMjwhuMBrj5843fU8FCHvllHEFLlwuFPw_sJSWRvMcJOSe-xyae45BDVVYQE-SJsjpF-fM-kn9J93ooJqo1YxIOrFbakURArDkeIDVeDXq5QulmUACbhH56ODtj8QPSwDjr9dObyelCG2=w452-h319)

Así logramos obtener dos posibles usuarios para poder realizar fuerza bruta al puerto 22.

## Paso 6 ##

Ya teniendo el user 'camilo' y 'juan' podemos intentar realizar un ataque de fuerza bruta, utilizando hydra y la wordlist de rockyou.

![Alt Imagen5](https://blogger.googleusercontent.com/img/a/AVvXsEh2Tb9qszoDxijkj1M-i7Pb_Lc-Q9PBtySQlOW6NjJwC2t1RoGg-fz7q-gTx9_YWSqIvLM7gInaB1vnH7T2eo1JoitgwVa0TghmjfuEMWDFJUh0h4rhdaCgMhkJr3NcvoVhhb47ZFzmnGoAoZJWpKezs9BdPTs6eofU4Z99zN3rip4PbGIJC_uSABxhe7h2=w581-h205)

Despues de ejecutar hydra con el wordlist de rockyou yel user camilo podemos encontrar la contraseña, la cual usaremos para obtener acceso mediante SSH.

![Alt Imagen6](https://blogger.googleusercontent.com/img/a/AVvXsEhw9RoJeeJd7EBz4jy0_JcviK_oAyg0wHV7DcvFuYgQbnRwVqNN9rX83gFWfnX7y6xUGPEN6zsN--qGhyhp1gqghR1KY51VDHpCm-4A_yVdew6J2bvoy1FJtLm0Bd5pPzWPXgoEpjUwW6Wj9-R9UtIU8vZ1zar6S8EEYwu877wqYUVvVaRbXdgi0wYMMD7f=w515-h122)

## Paso 7 ##

Ya con el usuario camilo, tendremos que buscar vulnerabilidades para la escalada de privilegio.

Luego de una amplia búsqueda el usuario camilo estaba bastante limitado, pero Juan nos dejo un correo el cual pudimos leer buscando archivos .txt, dejandonos la contraseña de Juan.

![Alt Imagen7](https://blogger.googleusercontent.com/img/a/AVvXsEjpQxC1fzMCoRW6HsbYXOvfUTq71nu-M2r3rBjc5VD62FylR4b62cm-kE0SUZ2LMl06vDUvJ_c8lmetqYWNfMvwVFXMhNBoNBdyXkpwR_M9UDpmAvlO67ZJbPRbpwG07GrXUwWeXCONkLGuGCpEpJ3iddcS9oFIGksuI8j3CqqbNYyDuUbA6unJd_Px8nzJ=w517-h325)

![Alt Imagen8](https://blogger.googleusercontent.com/img/a/AVvXsEhfepc_iWZ9uZHgWmvWHd81fyZe6lJRiNaIt-aB7R8p_yktvRxynbt1OhdYTdoL4ekv_upqmuiYgxXt_KGk6aOiSCp4WMT9gI5OqSEisJyjm-jAqUXliWxCEvI6fKswEYdzvqx4v0rZ9soUV_wbKGXK42Hr3Yt-r5iR5VmL9czHYJb5daYCK6GMFpRwUz7N)

Ya con el usuario de Juan volvemos a buscar vulnerabilidades para la escalada de privilegio a usuario root.

![Alt Imagen9](https://blogger.googleusercontent.com/img/a/AVvXsEh4mHIkIBzHkFUBoOEzfDqkqBnYrQLZNcslKe3heXcGZeUBmustYucSCGl-iDcgdnMI6GFZtds7uNadPVkermBJLED2PLKBd8AmO18hxkkEAjbPqx98mAkCpjikOUFtuk0IwWIOPd3ACTvcThJWOeRAIUIAGcC4B83cbC04_zhULZSuAzCySPMoZaJAHNcW=w528-h99)

Encontramos que podemos ejecutar ruby como root.

## Paso 8 ##

Procedemos a usar ruby como root, ejecutando código desde la misma terminal para poder correr una shells.

![Alt Imagen10](https://blogger.googleusercontent.com/img/a/AVvXsEhTYOuUUGCfbvrNrZk469UZiBr2ErKSebNCQTCRj2K9Mly-_B6_1ij_OUscDFYWBpl-3uxC6YUTTdFfq8YE5-tywbGxOBCdnLD8VQh0YT1vU-GjV7lg2UC0Dz9_E-X27YsbbhINisT6de6HLBIAIN_osMN7wVvFm2P63mRIA3ANL58ksSmVXQ8Wbv97ln37=w446-h119)

Y asi, finalmente ya somos usuarios root, con los privilegios totales.

Gracias por leer este WriteUp. :)
