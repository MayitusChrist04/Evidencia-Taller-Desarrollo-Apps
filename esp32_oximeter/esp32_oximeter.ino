/**
 * ============================================================
 *  Oxímetro ESP32 + MAX30102  →  FlutterFlow
 * ============================================================
 *  Autor del equipo: Mario Tapia Escamilla
 *  Repo: https://github.com/MayitusChrist04/Evidencia-Taller-Desarrollo-Apps.git
 *
 *  Librerías requeridas (instalar en Arduino IDE / PlatformIO):
 *    - SparkFun MAX3010x Pulse and Proximity Sensor Library
 *    - ArduinoJson  (v6.x)
 *    - WebServer    (incluida en el ESP32 core)
 *    - WiFi         (incluida en el ESP32 core)
 *
 *  Conexiones físicas (MAX30102 → ESP32):
 *    VIN  →  3.3V
 *    GND  →  GND
 *    SDA  →  GPIO 21
 *    SCL  →  GPIO 22
 *    INT  →  No conectado (opcional)
 * ============================================================
 */

#include "sensor.h"
#include "server.h"

// ─── Intervalo de actualización del sensor ────────────────────────────────────
#define SENSOR_UPDATE_MS  2000   // Actualizar lectura cada 1 segundo



// ─────────────────────────────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  Serial.println("\n=== Oxímetro ESP32 iniciando ===");

  // 1. Inicializar sensor MAX30102
  if (!initSensor()) {
    Serial.println("[ERROR] Sensor no disponible. El sistema continuará sin lecturas.");
  }

  // 2. Conectar WiFi y levantar servidor HTTP
  initServer();

  Serial.println("=== Sistema listo ===\n");
}

// ─────────────────────────────────────────────────────────────────────────────
void loop() {
  // Atender solicitudes HTTP → nunca se bloquea
  handleRequests();

  // Agregar una muestra al buffer por iteración
  if (fingerDetected()) {
    updateSensor();
  } else {
    // Resetear cuando no hay dedo
    bufferIndex = 0;
    bufferReady = false;
    spo2        = -1;
    heartRate   = -1;
    validSPO2      = 0;
    validHeartRate = 0;
  }
