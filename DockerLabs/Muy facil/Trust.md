\---

title: "Máquina Trust (Muy Fácil) - DockerLabs"

date: 2026-05-12

categories: \[dockerlabs]

tags: \[writeup, linux, ssh, apache, gobuster, hydra, escalada-de-privilegios]

\---



\# Máquina Trust (Muy Fácil)



Hoy resolveré la máquina Trust de la plataforma DockerLabs.



\## Temas a tratar



\- Reconocimiento

\- Fuzzing

\- Escalada de privilegios



\---



\## Paso 1



Activamos la máquina Trust desde la terminal.



!\[Activación de máquina](https://blogger.googleusercontent.com/img/a/AVvXsEhrhycyEPU8XXyvp5xMaM3OogD5F6\_MUp-j\_9qHWOeAJorkrRxAHZ1MslroqvVYMexoUw4wZWcBpnI1jnf4f0yeRnF9pAM9SS6bD5H2aLPZyLTN19\_QaAMoJwtdgbZ2yAbPir3BfgjISduHRBXOgDPM7Opyx1mGjOMGy2eMiLh4Ye8oL8PtkCCXVFE9YKne)



\---



\## Paso 2



Realizamos un escaneo utilizando la herramienta \*\*Nmap\*\*.



!\[Escaneo Nmap](https://blogger.googleusercontent.com/img/a/AVvXsEiFgDJC9NG444l0PZwvTuF\_mVwcAHgthR0EzWOFVecYdMoIhfCWbKs6W8Q5Ekr-aQtcyglQKvnjLLwSyCWBV\_\_RN0nF1WsRu7FIqFS2x9FuVCtNpV41tqFP8hTNsyTX0UQkbnI\_Gr0eFBpK56WBwyno6-G4YxD2v1ajoNh-vdLcDpojkqmCDP76UlFwzw9r)



\### Parámetros usados



\- `-p- --open` → Escanea todos los puertos abiertos.

\- `-sS` → Escaneo SYN sin completar el Three-way handshake.

\- `--min-rate` → Define velocidad mínima de envío de paquetes.

\- `-n` → Desactiva resolución DNS.

\- `-Pn` → Asume todos los hosts activos.

\- `-vvv` → Modo verbose.

\- `-oG` → Exporta en formato grepeable.



\---



\## Paso 3



Interpretamos la información obtenida.



Tenemos dos puertos abiertos:



\- \*\*Puerto 22\*\* → Servicio SSH  

\- \*\*Puerto 80\*\* → Servicio HTTP  



\---



\## Paso 4



Examinamos más a detalle versión y servicios activos.



!\[Escaneo detallado](https://blogger.googleusercontent.com/img/a/AVvXsEiSkYfgFGUWPMcHXF8FtJlhEBD9ZkR2S4W8KhgtJ9h1l1prUThhBRClL9NYxzwMAY5X-OtsFc2BXV25tS1Lf8zLyYtjoYajvrpYj9QxWNkBl-P8JP565yu7OZ-4svb4bdEftsmvjDWxvlAVGR3wZbbpBWiqGBRoZQ-7JKQYf0ubPaQUjU8Y5cd68uz4cWe6)



\### Parámetros usados



\- `-p 22,80` → Analiza esos puertos específicos.

\- `-sCV` → Scripts básicos + detección de versión.



\---



\## Paso 5



Servicios detectados:



\- \*\*SSH\*\* → OpenSSH 9.2p1  

\- \*\*HTTP\*\* → Apache httpd 2.4.57  



Como no tenemos credenciales para SSH, accedemos vía navegador.



!\[Página Apache](https://blogger.googleusercontent.com/img/a/AVvXsEhCQF\_OCDe8cITrntNw6a2PUYk6AjFGqLtcCsShqFye39DKS7mve7ah\_LspDp3hCFiCFcwIpHM5jRcxa5kA35eRjlBoGm2DPNt2H4iZtMcVHz9vKdgBVqUh0OG\_pMoRu4pSq8AiN08MvcuEQnzF4ozniGUt\_apGDwdT1nqFpUybKVZ6HIs48zAEtmGWlLSc)



Es una página predeterminada de Apache.  

No se encontró nada relevante tras analizar tráfico con Wireshark y BurpSuite.



\---



\## Paso 6



Realizamos fuzzing para encontrar rutas ocultas.



Se utilizó \*\*Gobuster\*\*.



!\[Gobuster](https://blogger.googleusercontent.com/img/a/AVvXsEjpgU7i6KX7sQS-drgrQpbderbtLbANWdGyY5tzVEGg8mM3bTyFPGR2q\_mJtpqC4-vOxPonwVCwr2e1N6l6SZjGN6h1xlEz4e2vKEeNs\_Js1IrLMhqm20acnrRDGZv4cAzmFqiCs441gJrIAgHIjYyR0osYagC8C89ijLk9pLglaKvK863e4BQUdkkf2Z3J)



\### Parámetros usados



\- `-u` → URL objetivo

\- `-w` → Diccionario

\- `-x` → Extensiones adicionales

\- `-b` → Filtra códigos de estado



\---



\## Paso 7



Se descubre el archivo `secret.php`.



!\[Secret PHP](https://blogger.googleusercontent.com/img/a/AVvXsEjfHa-\_I4khYQ3YuZynFC5-f5YNCX4ITHGbNZJ\_3Its\_LWwSYkjQbWEsO\_1CRAdycpWwwCFdYvwAOH95\_JReBFraaYJi8\_iYs-5\_qOg63hmQt3vU5t3QRE-jdNOGf8vDCayuaN5Qt3P-VzyM8DCDPRopBLKq2qhnFlsGHUPOkl7sv\_GIk2-QAwBDpj\_-xn1)



Se obtiene posible usuario: \*\*Mario\*\*



\---



\## Paso 8



Ataque de fuerza bruta con \*\*Hydra\*\* contra SSH usando el usuario Mario.



!\[Hydra](https://blogger.googleusercontent.com/img/a/AVvXsEhakGGPYm5EYQPRI\_58MwnqpRM7oYUVGYWD9s\_QXYQ5du-zk4f\_GqO7ue8Ek5gjR715zN-ZoCoWS1ksDnP0coUN-t85CsrC5X4dhlQczAKt6mLZUvE7xGAUB9QqOdGc2UsBxNrxMf4OjyKW9SdkxueNlxtJ3Ewf5tS6SHcjCt-5CIq3jWAbq247UA9PC\_9Y)



\### Parámetros usados



\- `-l` → Usuario

\- `-P` → Diccionario



Credencial encontrada:



