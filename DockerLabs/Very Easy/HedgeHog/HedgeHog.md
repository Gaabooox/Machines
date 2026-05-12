# Máquina HedgeHog #

Hoy resolveré la máquina HedgeHog de la plataforma DockerLabs.

Temas a tratar:

- Reconocimiento
- Fuerza bruta
- Escalada de privilegios

## Paso 1 ##

Activamos la máquina HedgeHog desde la terminal.

![Alt Imagen1](https://blogger.googleusercontent.com/img/a/AVvXsEgXgHBkjdqweVYgmuJ0noHELBKnIUYQqBEO6Mr5MkNx2GE_LG0RVdKv2IvSNTqUKrQEfeeG7xHnB9GwLxVqxabeiq3xaHzxsLWZWMOsV1mp0-eL7aQEgeBly9WzQIFpqMU3EL9JvQ-Rr7ghxdFD5zJGh4hStRUguDWuReAFtqZSV8i2gvLbIgaPEO35JfiS=w381-h302)

## Paso 2 ##

Realizamos un escaneo utlizando la herramienta **Nmap**

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEgO_mhWNxdVsJ3wKmlicOrOXzts1IL5F5rO8wVGGiMRcgFd9WvCqXses49ay-NP4EKWidQ7_qWJwjuNqczoswIZqgMI-helPPb_H28KHlTb_IJYWGrr-hL_JLL5i-NfPWV-Q3ewwJ1OK4gLqXgcJ6l3nfFeii-DniZ5GKChBga_EW_XkBaioG4DADB8ACZo=w452-h331)

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

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEgbracBK1ufeYvj0cSZ4A-VRspoTmjVOBJtjUNjipEPW4x9FFy34IV2HYZHCSePjdgBTy5ud97lZs-8fO1lY9x0HdLPnYqONk1oya6H5klI5KDEPh8m6RlCmjzfQu_SDLCA-miPO4c355YRHwbkaj-3iKovWpV6cNsSFZyFnR8wAzAVC8roLZAkur_PoaTM=w456-h265)

- 'p-22,80' = Examina exactamente ese puerto.
- '-sCV' = Lanza scripts basicos de reconocimiento y detecta la version de este.

## Paso 5 ##

Tenemos el servicio SSH con la version 9.6p1 y un servicio de apache corriendo en el puerto 80 con la version 2.4.58.

En el caso de SSH no podemos vulnerar mediante un exploit ya conocido, por lo cual optamos en ver la pagina que esta corriendo en el puerto 80.

![Alt Imagen3](https://blogger.googleusercontent.com/img/a/AVvXsEhRbrOfJnMiJtfKykyXC4KDzKykQ7OffHLLnV6f4tWXxPxUbJW-lFAB6upFnNY-05KMHncw5VuKciFJuyUmDF7jVhBGIrEFEVWkBcHD8VLkHv_4qyDgqil6NcUHQtB3zQBcDCiPDFPHHgR93wDbFrOyiTXih-NhZnMsQlEDRgMR8FYHLvsq-wn1y_9jH1kn=w505-h189)

Como vemos en la pagina solo hay una palabra llamada tails, no tenemos ninguna otra información, por mi parte intente hacer un escaneo de directorios mediante gobuster, pero tampoco encontre nada.

![Alt Imagen4](https://blogger.googleusercontent.com/img/a/AVvXsEhc6C7g-ydN9OBU1jxBvJtVthBHXnp8nEFtUrwippX8X2g4GrVi_oInXxbiCmjY1ZAjUUdEgSchijqpDFpcGs8a60I8_aaEpRnGIXDljW5Qe9XfZwebyP4NrPbKZGXNyir6bIxTHtQH0lUUOtfo_tNdEaYWgc0WS5Uj7--3fgmmqFc2J15ZRjH3YzXEom1a=w470-h272)

Por lo cual podemos hacer un ataque de fuerza bruta probando la palabra tails como usuario de SSH.

## Paso 6 ##

Utilizando hydra y la wordlist de rockyou, pero el probiema es que al usar un wordlist tan grande el programa de hydra nos dice que demorara demasiadas hora, por lo cual si tomamos como indicio el nombre tails, refiriendose a la cola en español, podemos invertir la wordlist empezando por el final.

![Alt Imagen5](https://blogger.googleusercontent.com/img/a/AVvXsEj7NSh1jwR7deYkdadZ3wIBK6Toxf_g4eCqBTiSNtiPdfSsRApchtJe8MKEscP6xEFYwdReRA96dxLiuplN3uxvjVihaEKRlLl2IPBlpqNZSm3ja9EFM_W8YU0J9NoCcwoQbM9loIkygNBeZcrNv5538IJTK41lMcXsI2L71Wl7Z-KZ9LH-AQzG_g1El8E4=w630-h63)

- 'tac' = Es un cat pero al reves, es decir invierte el output.
- 'sed = Recorre linea por linea, modificando lo que se le indica.
- 's/^[[:space:]]*//' = Elimina todos los espacios en blanco que hay linea por linea ya que en las contraseñas no se utiliza los espacios en blancos

![Alt Imagen6](https://blogger.googleusercontent.com/img/a/AVvXsEhobe4xOjxZlsOXOvOo7-8OAS_oXSubzm2s-zo7uzXttsuPF5D1aaR6HZ2bqCK1EzW2fcIUX5-JP1TQYEWChA2Qx6lI3um9btXkDATh61D2wYlVRMMmRy8SAUil8iUq92vap7MUyQ13LwIY3Oqcyl4Cw5J8SOhBwK7BWUbrqF0rZbZi-O3gb0DDqgjvtFFF=w456-h154)

Despues de ejecutar hydra con el nuevo wordlist al reves de rockyou podemos encontrar la contraseña, la cual usaremos para obtener acceso mediante SSH.

## Paso 7 ##

Ingresamos mediante SSH y vemos que somos el usuario tails, tendremos que buscar vulnerabilidades para la escalada de privilegio.

![Alt Imagen7](https://blogger.googleusercontent.com/img/a/AVvXsEhhuHMRKrg3wt2mkcq4Evg1RblWVPlxcvD_BegrU0PZTxn27gK8ZFt3e1DsumHKMll6hE5L7c8qQ_lueb8y_mO4bi6nG7ryWnYfVCtnMONNaJNpWnra-3CoEn8GchPXUI2zU_Ot2Dr2xB8MdONuH0J9i3yKmZkuiHgAa_wfVnA3qYNKb31ap6mm8nMMLKgP=w408-h108)

Observamos que podemos ejecutar comandos con el usuario sonic sin necesidad de contraseña, lo cual optaremos en abrir la bash con el usuario sonic, para seguir buscando vulnerabilidades.

![Alt Imagen8](https://blogger.googleusercontent.com/img/a/AVvXsEhixicgAXS-0GTLY8BhzRx4nsbB5DsxkhXm9HUuX2S3SAodgDYDbKrcKwgLJUesgkOYpozHwx9qIcY5_RW3_MTprM5vl3ULlau0TBHL6UQhECsdPvAsIlwBstl-mrv29bdSG9qonNNGNYN-4xEPdNoveNc_PTTadQN2qz2uS3oDbbccxlTeFQC15LgxpTz5=w425-h123)

Como vemos el usuario sonic, puede ejecutar comandos como root, es decir sonic es igual a root, lo cual de igual manera escalamos privilegio.

![Alt Imagen9](https://blogger.googleusercontent.com/img/a/AVvXsEgQkQP44vgk6UdVfz1_NYObz3Q3OSTWl9suoN9VxkiEqx57Kx6jZTglt67YcTopYWtPR-JWIDE6a3AALZx301U_Ct5sNUHFxLiSDJy0bq3GX_fVU5LV2iR3PIyrt4qEUw08vGPyNCdMxCfNDfTiHLOlDIk7d-jcWeUCiadSFiK66MDm-Bw8Wgsag21rLlGk=w423-h74)

Y asi, finalmente ya somos usuarios root, con los privilegios totales.

Gracias por leer este WriteUp. :)
