---
title: BreakMySsh
description: 'Resolución de la máquina BreakMySsh de DockerLabs'
hide:
  - navigation
  - toc
---

<section
  class="writeup-intro"
  data-name="BreakMySsh"
  data-platform="DockerLabs"
  data-difficulty="Very Easy"
  data-os="Linux"
  data-status="Completada"
  data-access="SSH como root"
  data-escalation="No necesaria"
  data-date=""
  data-techniques="Nmap|SSH|Hydra|Fuerza bruta"
>

  <h1>BreakMySsh</h1>

  <div class="writeup-inline-badges">
    <span>DockerLabs</span>
    <span class="difficulty">Very Easy</span>
    <span>Linux</span>
    <span>Completada</span>
  </div>

  <p>M&#225;quina enfocada en reconocimiento de servicios, enumeraci&#243;n de SSH y ataque de diccionario con Hydra para conseguir acceso directo como usuario root.</p>

</section>
## 1. Preparación de la máquina

Primero se desplegó la máquina BreakMySsh desde DockerLabs.

<!-- IMAGEN PENDIENTE: despliegue de la máquina -->

## 2. Reconocimiento de puertos

Se realizó un escaneo completo para identificar los puertos TCP abiertos:

```bash
sudo nmap -p- --open -sS --min-rate 5000 -n -Pn -vvv <IP_OBJETIVO> -oG allPorts
```

### Explicación del comando

| Opción | Función |
|---|---|
| `-p-` | Escanea los 65 535 puertos TCP |
| `--open` | Muestra solamente los puertos abiertos |
| `-sS` | Realiza un escaneo TCP SYN |
| `--min-rate 5000` | Solicita una velocidad mínima de 5000 paquetes por segundo |
| `-n` | Desactiva la resolución DNS |
| `-Pn` | Omite el descubrimiento previo y trata el objetivo como activo |
| `-vvv` | Muestra información detallada durante el escaneo |
| `-oG allPorts` | Guarda el resultado en formato grepeable |

<!-- IMAGEN PENDIENTE: escaneo inicial con Nmap -->

## 3. Puerto encontrado

El escaneo mostró un único puerto abierto:

| Puerto | Servicio | Estado |
|---:|---|---|
| 22/TCP | SSH | Abierto |

El servicio SSH permite administrar una máquina remotamente mediante una conexión cifrada.

## 4. Enumeración del servicio SSH

Después se realizó un escaneo específico contra el puerto 22:

```bash
sudo nmap -p 22 -sCV <IP_OBJETIVO> -oN targeted
```

### Explicación

| Opción | Función |
|---|---|
| `-p 22` | Analiza únicamente el puerto 22 |
| `-sC` | Ejecuta los scripts predeterminados de Nmap |
| `-sV` | Intenta identificar la versión del servicio |
| `-oN targeted` | Guarda el resultado en formato normal |

El resultado identificó una versión de OpenSSH 7.7 utilizando el protocolo SSH 2.

<!-- IMAGEN PENDIENTE: enumeración detallada del puerto 22 -->

## 5. Investigación de vulnerabilidades

Se buscó información relacionada con la versión detectada:

```bash
searchsploit openssh 7.7
```

Encontrar una versión antigua no significa automáticamente que exista una vulnerabilidad explotable de forma remota.

Los resultados encontrados debían comprobarse individualmente para determinar:

- Qué sistema operativo afectaban.
- Qué configuración necesitaban.
- Si permitían ejecución remota.
- Si requerían credenciales previas.
- Si el código seguía siendo compatible.

Algunos exploits encontrados utilizaban Python 2 y no resultaron adecuados para el escenario.

<!-- IMAGEN PENDIENTE: resultados de Searchsploit -->

## 6. Ataque de diccionario contra SSH

Al no encontrar un exploit aplicable, se realizó un ataque de diccionario controlado con Hydra.

Se utilizaron:

- Un diccionario de posibles usuarios.
- Un diccionario de posibles contraseñas.
- El servicio SSH como objetivo.

```bash
hydra \
    -L usuarios.txt \
    -P contraseñas.txt \
    ssh://<IP_OBJETIVO>
```

### Explicación del comando

| Opción | Función |
|---|---|
| `-L usuarios.txt` | Carga una lista de posibles usuarios |
| `-P contraseñas.txt` | Carga una lista de posibles contraseñas |
| `ssh://<IP_OBJETIVO>` | Define SSH como servicio objetivo |

Hydra encontró las siguientes credenciales dentro del laboratorio:

```text
Usuario: root
Contraseña: estrella
```

<!-- IMAGEN PENDIENTE: resultado de Hydra -->

## 7. Acceso mediante SSH

Las credenciales encontradas se probaron directamente contra el servicio:

```bash
ssh root@<IP_OBJETIVO>
```

Después se introdujo la contraseña:

```text
estrella
```

La autenticación fue correcta y se obtuvo acceso directo como `root`.

<!-- IMAGEN PENDIENTE: acceso mediante SSH -->

## 8. Comprobación del acceso

Se comprobó el usuario actual:

```bash
whoami
```

Resultado:

```text
root
```

También se puede revisar la identidad completa con:

```bash
id
```

Al haber iniciado sesión directamente como `root`, no fue necesario realizar una escalada de privilegios adicional.

## 9. Vulnerabilidades encontradas

### Autenticación SSH permitida para root

El servidor permitía iniciar sesión directamente mediante SSH usando la cuenta `root`.

Esto aumenta el impacto de cualquier contraseña débil o filtrada.

### Contraseña débil

La contraseña podía encontrarse utilizando un ataque de diccionario.

### Falta de protección contra intentos repetidos

El servicio permitió realizar múltiples intentos de autenticación automatizados.

Esto indica que no existía una protección efectiva contra fuerza bruta o que era insuficiente.

## 10. Medidas de mitigación

- Deshabilitar el inicio de sesión directo como `root` mediante SSH.
- Configurar `PermitRootLogin no` en `sshd_config`.
- Utilizar usuarios sin privilegios para el acceso inicial.
- Usar contraseñas largas, únicas y aleatorias.
- Priorizar autenticación mediante claves SSH.
- Deshabilitar la autenticación mediante contraseña cuando sea posible.
- Implementar Fail2Ban o una solución equivalente.
- Limitar la cantidad de intentos de autenticación.
- Restringir el acceso al puerto 22 mediante firewall.
- Mantener OpenSSH actualizado.
- Supervisar los registros de autenticación.

## 11. Conclusión

La resolución siguió este flujo:

1. Escaneo completo de puertos.
2. Identificación del servicio SSH.
3. Enumeración de su versión.
4. Investigación de posibles vulnerabilidades.
5. Descarte de exploits no aplicables.
6. Ataque de diccionario con Hydra.
7. Obtención de credenciales válidas.
8. Acceso directo como usuario `root`.

El problema principal no fue únicamente la versión de OpenSSH, sino la combinación de autenticación directa como `root`, una contraseña débil y la ausencia de controles efectivos contra ataques de fuerza bruta.


