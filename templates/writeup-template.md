---

title: NOMBRE_MAQUINA

description: Resolución de la máquina NOMBRE_MAQUINA de PLATAFORMA

---



# NOMBRE_MAQUINA



`PLATAFORMA` `DIFICULTAD` `SISTEMA_OPERATIVO` `Completada`



Breve descripción de la máquina, su objetivo principal y las técnicas más importantes utilizadas durante la resolución.



## Información de la máquina



| Campo | Valor |

|---|---|

| Plataforma | PLATAFORMA |

| Dificultad | DIFICULTAD |

| Sistema operativo | SISTEMA_OPERATIVO |

| Estado | Completada |

| Acceso inicial | METODO_ACCESO |

| Escalada de privilegios | METODO_ESCALADA |



## Técnicas utilizadas



`Nmap` `Enumeración` `TÉCNICA_1` `TÉCNICA_2` `TÉCNICA_3`



## 1. Preparación de la máquina



Explica cómo desplegaste, encendiste o te conectaste a la máquina.



```bash

COMANDO_DE_PREPARACION

```



<!-- IMAGEN PENDIENTE: captura del despliegue -->



## 2. Reconocimiento



Explica cómo identificaste la dirección IP y los puertos abiertos.



```bash

sudo nmap -p- --open -sS --min-rate 5000 -n -Pn -vvv <IP_OBJETIVO> -oG allPorts

```



### Puertos encontrados



| Puerto | Servicio | Estado |

|---:|---|---|

| PUERTO | SERVICIO | Abierto |



<!-- IMAGEN PENDIENTE: captura del escaneo inicial -->



## 3. Enumeración de servicios



Explica qué servicios encontraste y cómo obtuviste más información.



```bash

sudo nmap -p PUERTOS -sCV <IP_OBJETIVO> -oN targeted

```



### Hallazgos



- HALLAZGO_1

- HALLAZGO_2

- HALLAZGO_3



<!-- IMAGEN PENDIENTE: captura del escaneo de servicios -->



## 4. Enumeración específica



Explica la enumeración web, SMB, FTP, SSH, bases de datos u otros servicios encontrados.



```bash

COMANDO_DE_ENUMERACION

```



### Resultado



Describe la información importante encontrada.



<!-- IMAGEN PENDIENTE: captura de la enumeración -->



## 5. Explotación y acceso inicial



Explica la vulnerabilidad encontrada y cómo conseguiste acceso inicial.



```bash

COMANDO_DE_EXPLOTACION

```



### Credenciales encontradas



```text

Usuario: USUARIO

Contraseña: CONTRASEÑA

```



No incluyas credenciales personales ni información externa al laboratorio.



<!-- IMAGEN PENDIENTE: captura del acceso inicial -->



## 6. Enumeración interna



Después de obtener acceso, comprueba el usuario actual y la información del sistema:



```bash

whoami

id

hostname

uname -a

```



Explica los archivos, permisos, procesos o configuraciones relevantes encontrados.



## 7. Escalada de privilegios



Explica cómo identificaste el vector de escalada.



```bash

sudo -l

```



Describe el procedimiento utilizado para obtener privilegios elevados:



```bash

COMANDO_DE_ESCALADA

```



Comprueba el usuario final:



```bash

whoami

```



Resultado esperado:



```text

root

```



<!-- IMAGEN PENDIENTE: captura de la escalada -->



## 8. Vulnerabilidades encontradas



### VULNERABILIDAD_1



Explica qué estaba mal configurado y por qué representaba un riesgo.



### VULNERABILIDAD_2



Explica el segundo problema identificado.



### VULNERABILIDAD_3



Explica el tercer problema identificado.



## 9. Medidas de mitigación



- MEDIDA_DE_MITIGACION_1

- MEDIDA_DE_MITIGACION_2

- MEDIDA_DE_MITIGACION_3

- Aplicar el principio de mínimo privilegio.

- Utilizar contraseñas seguras y únicas.

- Mantener los servicios y paquetes actualizados.



## 10. Conclusión



Resume:



1\. Cómo descubriste los servicios.

2\. Cómo obtuviste acceso inicial.

3\. Cómo escalaste privilegios.

4\. Qué conceptos nuevos aprendiste.

5\. Qué errores cometiste y cómo los solucionaste.


