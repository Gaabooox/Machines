# Máquina Trust #

Hoy resolveré la máquina Trust de la plataforma DockerLabs.
Temas a tratar:

- Reconocimiento
- Fuzzing
- Escala de privilegios

## Paso 1 ##

Activamos la máquina Trust desde la terminal.

![Alt Imagen1](https://blogger.googleusercontent.com/img/a/AVvXsEhrhycyEPU8XXyvp5xMaM3OogD5F6_MUp-j_9qHWOeAJorkrRxAHZ1MslroqvVYMexoUw4wZWcBpnI1jnf4f0yeRnF9pAM9SS6bD5H2aLPZyLTN19_QaAMoJwtdgbZ2yAbPir3BfgjISduHRBXOgDPM7Opyx1mGjOMGy2eMiLh4Ye8oL8PtkCCXVFE9YKne=w353-h267)

## Paso 2 ##

Realizamos un escaneo utlizando la herramienta **Nmap**

![Alt Imagen2](https://blogger.googleusercontent.com/img/a/AVvXsEiFgDJC9NG444l0PZwvTuF_mVwcAHgthR0EzWOFVecYdMoIhfCWbKs6W8Q5Ekr-aQtcyglQKvnjLLwSyCWBV__RN0nF1WsRu7FIqFS2x9FuVCtNpV41tqFP8hTNsyTX0UQkbnI_Gr0eFBpK56WBwyno6-G4YxD2v1ajoNh-vdLcDpojkqmCDP76UlFwzw9r=w390-h252)

- '-p- --open' = Escanea todos los puertos con el estado abierto
- '-sS'= Es un escaneo SYN que evita que el Three-way handshake se complete
- '--min-rate' = Envia paquetes no mas lentos que la cantidad que elijas
- '-n' = Desactiva la resolicion DNS
- '-Pn' = Toma todos los host como activos para evitar hacer ping a cada uno
- '-vvv' = Muestra el proceso en pantalla mientras se va escaneando
- 'oG' = Exporta tu escaneo en un formato grepeable para poder examinarlo mas adelante si se necesita
