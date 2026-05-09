#ifndef SERVER_H
#define SERVER_H

#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>

// ─── Credenciales WiFi ────────────────────────────────────────────────────────
// Cambia estos valores o usa variables de entorno / secrets.h
#define WIFI_SSID     "iPhone de Mario"
#define WIFI_PASSWORD "MayitusChrist123"

WebServer server(80);

// Referencias externas definidas en sensor.h
extern int32_t spo2;
extern int8_t  validSPO2;
extern int32_t heartRate;
extern int8_t  validHeartRate;

// ─── Endpoint: GET /datos ─────────────────────────────────────────────────────
// Retorna JSON con los datos fisiológicos actuales.
// FlutterFlow hace un HTTP GET a http://<IP_ESP32>/datos
void handleDatos() {
  // Habilitar CORS para que FlutterFlow pueda consumir el endpoint
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.sendHeader("Access-Control-Allow-Methods", "GET");

  StaticJsonDocument<256> doc;

  doc["spo2"]             = (validSPO2 == 1)       ? spo2      : -1;
  doc["frecuencia_cardiaca"] = (validHeartRate == 1) ? heartRate : -1;
  doc["valido"]           = (validSPO2 == 1 && validHeartRate == 1);
  doc["timestamp"]        = millis();

  String response;
  serializeJson(doc, response);

  server.send(200, "application/json", response);
  Serial.println("[SERVER] Solicitud /datos respondida: " + response);
}

// ─── Endpoint: GET /estado ────────────────────────────────────────────────────
// Verifica que el servidor está activo (health-check desde la app)
void handleEstado() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  StaticJsonDocument<128> doc;
  doc["estado"] = "activo";
  doc["ip"]     = WiFi.localIP().toString();
  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

// ─── Endpoint: 404 ───────────────────────────────────────────────────────────
void handleNotFound() {
  server.send(404, "text/plain", "Ruta no encontrada");
}

/**
 * Conecta al WiFi y levanta el servidor web.
 * Llama esta función una vez en setup().
 */
void initServer() {
  Serial.printf("[WIFI] Conectando a %s", WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int intentos = 0;
  while (WiFi.status() != WL_CONNECTED && intentos < 20) {
    delay(500);
    Serial.print(".");
    intentos++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("\n[WIFI] Conectado! IP: %s\n", WiFi.localIP().toString().c_str());
  } else {
    Serial.println("\n[WIFI] Error: No se pudo conectar al WiFi.");
    return;
  }

  // Registrar rutas
  server.on("/datos",  HTTP_GET, handleDatos);
  server.on("/estado", HTTP_GET, handleEstado);
  server.onNotFound(handleNotFound);

  server.begin();
  Serial.println("[SERVER] Servidor HTTP iniciado en puerto 80.");
  Serial.printf("[SERVER] URL de datos: http://%s/datos\n", WiFi.localIP().toString().c_str());
}

/**
 * Procesa las solicitudes entrantes.
 * Llama esta función en cada iteración de loop().
 */
void handleRequests() {
  server.handleClient();
}

#endif // SERVER_H 

