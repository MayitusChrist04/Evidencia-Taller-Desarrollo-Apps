/**
 * ============================================================
 *  Oxímetro ESP32 + MAX30102  →  FlutterFlow
 * ============================================================
 *  Autor del equipo: [nombres]
 *  Repo: https://github.com/tu-equipo/tu-repo
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
#define SENSOR_UPDATE_MS  1000   // Actualizar lectura cada 1 segundo

unsigned long lastSensorUpdate = 0;

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
  // Atender solicitudes HTTP de la app FlutterFlow
  handleRequests();

  // Actualizar lectura del sensor periódicamente
  unsigned long now = millis();
  if (now - lastSensorUpdate >= SENSOR_UPDATE_MS) {
    lastSensorUpdate = now;

    if (fingerDetected()) {
      readSensor();
    } else {
      Serial.println("[SENSOR] Dedo no detectado. Esperando...");
      // Resetear valores cuando no hay contacto
      spo2      = -1;
      heartRate = -1;
      validSPO2      = 0;
      validHeartRate = 0;
    }
  }
}
