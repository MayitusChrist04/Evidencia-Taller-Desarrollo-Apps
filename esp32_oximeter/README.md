# Firmware de Transmision e Integracion - Persona D

Este modulo del repositorio contiene el desarrollo correspondiente a la persona D, enfocado en la conectividad WiFi, la creacion del servidor HTTP y la integracion final del firmware para el oximetro basado en ESP32.

## Responsabilidades
- Configuracion del stack de red WiFi en el microcontrolador ESP32.
- Desarrollo del servidor web embebido para la exposicion de datos fisiologicos.
- Creacion del endpoint JSON para la comunicacion con FlutterFlow.
- Integracion de los modulos de sensorica y logica principal del sistema.

## Archivos
- esp32_oximeter/server.h: Gestiona la conexion a la red local y define las rutas del servidor web (/datos y /estado).
- esp32_oximeter/esp32_oximeter.ino: Coordina la inicializacion del servidor y el manejo de peticiones entrantes en el loop principal

## Detalles de Implementacion 

El proyecto requiere que los datos de SpO2 obtenidos por el sensor MAX30102 sean accesibles de forma inalambrica por una aplicacion movil en tiempo real

Se implemento un servidor web en el puerto 80 del ESP32 utilizando las librerias WiFi.h y WebServer.h Se configuro un endpoint que serializa las variables de salud en un formato JSON compatible con APIs REST mediante la libreria ArduinoJson. Ademas, se habilitaron los encabezados de control de acceso (CORS) para permitir que la aplicacion FlutterFlow realice peticiones GET exitosas

La integracion permite una comunicacion fluida entre el hardware biomedico y la interfaz de usuario, eliminando la necesidad de cables y permitiendo el monitoreo remoto del paciente con una latencia minima

## Instrucciones de Configuracion
Para desplegar este modulo, es necesario editar las siguientes lineas en server.h con las credenciales de la red local:

#define WIFI_SSID "NOMBRE_RED"
#define WIFI_PASSWORD "CONTRASEÑA"

Una vez cargado el codigo, la direccion IP asignada aparecerá en el Monitor Serial (115200 baud) y deberá ser ingresada en el modulo de API Call de FlutterFlow
