---
title: BorazuwarahCTF
description: Resolución de la máquina BorazuwarahCTF de DockerLabs
---

<div class="writeup-hero">

  <div class="writeup-hero-content">

    <h1>BorazuwarahCTF</h1>

    <p class="writeup-hero-description">
      Máquina enfocada en reconocimiento, análisis de metadatos,
      fuerza bruta contra SSH y escalada de privilegios mediante
      una configuración insegura de sudo.
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
      <strong>SSH</strong>
    </div>

    <div class="writeup-summary-row">
      <span>Escalada</span>
      <strong>Sudo</strong>
    </div>

  </div>

</div>

<div class="writeup-techniques">
  <span class="writeup-technique">Nmap</span>
  <span class="writeup-technique">SSH</span>
  <span class="writeup-technique">ExifTool</span>
  <span class="writeup-technique">Hydra</span>
  <span class="writeup-technique">Esteganografía</span>
  <span class="writeup-technique">Fuerza bruta</span>
  <span class="writeup-technique">Sudo</span>
</div>

## Técnicas utilizadas

`Nmap` `SSH` `ExifTool` `Hydra` `Esteganografía` `Fuerza bruta` `Sudo`

## 1. Reconocimiento

El primer objetivo consiste en identificar los puertos abiertos de la máquina.

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
| `-Pn` | Trata el objetivo como activo sin realizar descubrimiento previo |
| `-vvv` | Aumenta el nivel de detalle mostrado |
| `-oG allPorts` | Guarda el resultado en formato grepeable |

El escaneo mostró dos puertos abiertos:

| Puerto | Servicio |
|---:|---|
| 22/TCP | SSH |
| 80/TCP | HTTP |

## 2. Enumeración de servicios

Después del escaneo inicial, se analizaron específicamente los puertos encontrados:

```bash
sudo nmap -p 22,80 -sCV <IP_OBJETIVO> -oN targeted
```

La opción `-sCV` combina:

- Detección de versiones de servicios con `-sV`.
- Ejecución de scripts predeterminados de Nmap con `-sC`.

Los resultados mostraron:

- Un servidor SSH en el puerto 22.
- Un servidor web Apache en el puerto 80.

## 3. Enumeración web

Al acceder al servicio HTTP se encontró una imagen que sugería la posible existencia de información oculta.

La técnica de ocultar información dentro de archivos, imágenes o contenido multimedia se conoce como **esteganografía**.

Para revisar los metadatos de la imagen se utilizó:

```bash
exiftool imagen
```

En los campos de metadatos se encontró el nombre del usuario:

```text
borazuwarah
```

La contraseña no se encontraba directamente expuesta.

## 4. Acceso inicial

Con el usuario identificado, se realizó una prueba de fuerza bruta controlada contra el servicio SSH utilizando Hydra y la lista `rockyou.txt`.

```bash
hydra -l borazuwarah -P /usr/share/wordlists/rockyou.txt ssh://<IP_OBJETIVO>
```

### Explicación

| Opción | Función |
|---|---|
| `-l borazuwarah` | Define un usuario específico |
| `-P rockyou.txt` | Utiliza un archivo con posibles contraseñas |
| `ssh://<IP_OBJETIVO>` | Define SSH como servicio objetivo |

Hydra encontró una contraseña válida, permitiendo iniciar sesión mediante SSH:

```bash
ssh borazuwarah@<IP_OBJETIVO>
```

## 5. Escalada de privilegios

Después de obtener acceso, se revisaron los permisos asignados mediante `sudo`:

```bash
sudo -l
```

La configuración permitía ejecutar comandos con privilegios elevados sin solicitar contraseña.

Aprovechando esta configuración se obtuvo una shell como usuario `root`:

```bash
sudo bash
```

La identidad del usuario se comprobó con:

```bash
whoami
```

Resultado:

```text
root
```

## 6. Vulnerabilidades encontradas

### Contraseña débil en SSH

La contraseña del usuario podía encontrarse mediante un ataque de diccionario.

### Información sensible en metadatos

El nombre del usuario estaba almacenado dentro de los metadatos de una imagen publicada en el servidor web.

### Permisos sudo inseguros

El usuario podía ejecutar una shell privilegiada sin autenticación adicional.

## 7. Medidas de mitigación

- Utilizar contraseñas largas, únicas y resistentes a ataques de diccionario.
- Deshabilitar la autenticación SSH mediante contraseña cuando sea posible.
- Utilizar claves SSH protegidas.
- Implementar límites de intentos y herramientas como Fail2Ban.
- Eliminar metadatos sensibles antes de publicar archivos.
- Aplicar el principio de mínimo privilegio en `/etc/sudoers`.
- Evitar permisos `NOPASSWD` para shells o comandos capaces de ejecutar otros procesos.

## 8. Conclusión

Esta máquina permitió practicar un flujo básico de pentesting:

1. Descubrimiento de puertos.
2. Enumeración de servicios.
3. Análisis de contenido web.
4. Extracción de metadatos.
5. Ataque de diccionario contra SSH.
6. Revisión de permisos sudo.
7. Escalada de privilegios hasta `root`.

El punto más crítico fue la combinación de una contraseña débil con una configuración excesivamente permisiva de `sudo`.