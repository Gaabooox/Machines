---
title: Test
description: 'Resolución de la máquina Test de Hack The Box'
hide:
  - navigation
  - toc
---

<section
  class="writeup-intro"
  data-name="Test"
  data-platform="Hack The Box"
  data-difficulty="Medium"
  data-os="Windows"
  data-status="Completada"
  data-access="shh"
  data-escalation="no se"
  data-date="2026-07-13"
  data-techniques="nmap|rufus"
>

  <h1>Test</h1>

  <div class="writeup-inline-badges">
    <span>Hack The Box</span>
    <span class="difficulty">Medium</span>
    <span>Windows</span>
    <span>Completada</span>
  </div>

  <p>SHH</p>

</section>

## 1. Preparación de la máquina

Explica cómo desplegaste, encendiste o conectaste la máquina.

<!-- IMAGEN PENDIENTE: despliegue de la máquina -->

## 2. Reconocimiento

```bash
sudo nmap -p- --open -sS --min-rate 5000 -n -Pn -vvv <IP_OBJETIVO> -oG allPorts
```

### Puertos encontrados

| Puerto | Servicio | Estado |
|---:|---|---|
| PUERTO | SERVICIO | Abierto |

<!-- IMAGEN PENDIENTE: escaneo inicial -->

## 3. Enumeración de servicios

```bash
sudo nmap -p PUERTOS -sCV <IP_OBJETIVO> -oN targeted
```

Explica las versiones, tecnologías y hallazgos relevantes.

<!-- IMAGEN PENDIENTE: enumeración detallada -->

## 4. Enumeración específica

Documenta la enumeración web, FTP, SMB, SSH u otros servicios.

```bash
COMANDO_DE_ENUMERACION
```

<!-- IMAGEN PENDIENTE: enumeración específica -->

## 5. Explotación y acceso inicial

Explica la vulnerabilidad y el procedimiento seguido.

```bash
COMANDO_DE_EXPLOTACION
```

<!-- IMAGEN PENDIENTE: acceso inicial -->

## 6. Enumeración interna

```bash
whoami
id
hostname
uname -a
```

Documenta usuarios, archivos, procesos, permisos y configuraciones relevantes.

## 7. Escalada de privilegios

```bash
sudo -l
```

Explica el vector utilizado:

```bash
COMANDO_DE_ESCALADA
```

Comprueba el usuario final:

```bash
whoami
```

<!-- IMAGEN PENDIENTE: acceso root -->

## 8. Vulnerabilidades encontradas

### VULNERABILIDAD_1

Explica la causa y el riesgo.

### VULNERABILIDAD_2

Explica la causa y el riesgo.

## 9. Medidas de mitigación

- MEDIDA_1
- MEDIDA_2
- Aplicar el principio de mínimo privilegio.
- Utilizar contraseñas seguras y únicas.
- Mantener servicios y paquetes actualizados.

## 10. Conclusión

Resume el acceso inicial, la escalada, las vulnerabilidades y lo aprendido.