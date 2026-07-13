---
title: FirstHacking
description: Resolución de la máquina FirstHacking de DockerLabs
---

# FirstHacking

`DockerLabs` `Very Easy` `Linux` `Completada`

Máquina enfocada en reconocimiento de servicios, enumeración FTP, búsqueda de vulnerabilidades conocidas y explotación de una versión vulnerable de vsftpd.

## Información de la máquina

| Campo | Valor |
|---|---|
| Plataforma | DockerLabs |
| Dificultad | Very Easy |
| Sistema operativo | Linux |
| Estado | Completada |
| Servicio principal | FTP |
| Puerto principal | 21/TCP |
| Acceso obtenido | Root mediante explotación del servicio |

## Técnicas utilizadas

`Nmap` `FTP` `Searchsploit` `Análisis de exploits` `Backdoor`

## 1. Preparación de la máquina

Se desplegó la máquina FirstHacking desde DockerLabs.

<!-- IMAGEN PENDIENTE: despliegue de FirstHacking -->

## 2. Reconocimiento de puertos

Se realizó un escaneo completo de puertos TCP:

```bash
sudo nmap -p- --open -sS --min-rate 5000 -n -Pn -vvv <IP_OBJETIVO> -oG allPorts
```

| Opción | Función |
|---|---|
| `-p-` | Escanea los 65 535 puertos TCP |
| `--open` | Muestra solamente puertos abiertos |
| `-sS` | Realiza un escaneo TCP SYN |
| `--min-rate 5000` | Solicita una velocidad mínima de envío |
| `-n` | Desactiva la resolución DNS |
| `-Pn` | Trata el objetivo como activo |
| `-vvv` | Muestra información detallada |
| `-oG allPorts` | Guarda el resultado en formato grepeable |

<!-- IMAGEN PENDIENTE: escaneo inicial -->

## 3. Puerto encontrado

El escaneo mostró un único puerto abierto:

| Puerto | Servicio | Estado |
|---:|---|---|
| 21/TCP | FTP | Abierto |

FTP se utiliza para transferir archivos entre sistemas mediante una conexión de red.

## 4. Enumeración del servicio

Se realizó un escaneo específico contra el puerto 21:

```bash
sudo nmap -p 21 -sCV <IP_OBJETIVO> -oN targeted
```

El resultado identificó:

```text
Servicio: FTP
Software: vsftpd
Versión: 2.3.4
```

<!-- IMAGEN PENDIENTE: identificación de vsftpd 2.3.4 -->

## 5. Búsqueda de vulnerabilidades

Se utilizó Searchsploit para buscar exploits públicos relacionados:

```bash
searchsploit vsftpd 2.3.4
```

También se puede inspeccionar la información de un resultado con:

```bash
searchsploit -x <RUTA_DEL_EXPLOIT>
```

La revisión mostró un exploit relacionado con una puerta trasera presente en una distribución comprometida de vsftpd 2.3.4.

<!-- IMAGEN PENDIENTE: resultado de Searchsploit -->

## 6. Análisis del exploit

El comportamiento vulnerable utilizaba un nombre de usuario que contenía:

```text
:)
```

Esta secuencia activaba la puerta trasera y abría un servicio adicional desde el que podía obtenerse una shell.

Antes de ejecutar código público se debe revisar:

- Qué acciones realiza.
- Qué dirección IP recibe.
- Qué puerto utiliza.
- Si necesita Python 2 o Python 3.
- Si contiene instrucciones peligrosas adicionales.

<!-- IMAGEN PENDIENTE: revisión del código del exploit -->

## 7. Explotación

El exploit seleccionado se ejecutó contra la máquina:

```bash
python3 <EXPLOIT>.py <IP_OBJETIVO>
```

El nombre y los argumentos exactos dependen del archivo obtenido mediante Searchsploit.

Después de ejecutarlo correctamente se obtuvo una shell con privilegios elevados.

<!-- IMAGEN PENDIENTE: ejecución del exploit -->

## 8. Comprobación del acceso

Se verificó el usuario actual:

```bash
whoami
```

Resultado:

```text
root
```

También se comprobó la identidad completa:

```bash
id
```

## 9. Vulnerabilidades encontradas

### Servicio FTP vulnerable

La máquina ejecutaba una distribución vulnerable de vsftpd 2.3.4.

### Software desactualizado

El servicio utilizaba una versión antigua y asociada con una puerta trasera conocida.

### Exposición innecesaria de FTP

El puerto 21 estaba disponible para cualquier equipo con acceso a la red del laboratorio.

## 10. Medidas de mitigación

- Retirar versiones comprometidas o desactualizadas de vsftpd.
- Instalar paquetes únicamente desde repositorios confiables.
- Verificar firmas y hashes de los paquetes.
- Sustituir FTP por SFTP cuando sea posible.
- Restringir el acceso mediante firewall.
- Deshabilitar servicios que no sean necesarios.
- Mantener inventariado y actualizado el software.
- Supervisar puertos y procesos inesperados.

## 11. Conclusión

La resolución siguió este flujo:

1. Escaneo completo de puertos.
2. Identificación de FTP en el puerto 21.
3. Detección de vsftpd 2.3.4.
4. Búsqueda de exploits conocidos.
5. Revisión del código antes de ejecutarlo.
6. Explotación de la puerta trasera.
7. Obtención de acceso como `root`.

La lección principal fue que la versión de un servicio debe comprobarse y relacionarse con vulnerabilidades reales antes de intentar explotarlo.
