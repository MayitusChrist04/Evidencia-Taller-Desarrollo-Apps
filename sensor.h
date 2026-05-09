#ifndef SENSOR_H
#define SENSOR_H

#include <Wire.h>
#include "MAX30105.h"       // SparkFun MAX3010x library
#include "spo2_algorithm.h" // SparkFun SpO2 algorithm

// ─── Parámetros del algoritmo ────────────────────────────────────────────────
#define BUFFER_LENGTH     50   // Muestras para el cálculo
#define SPO2_MIN_VALID    85    // % mínimo considerado válido
#define HR_MIN_VALID      40    // bpm mínimo considerado válido
#define HR_MAX_VALID      200   // bpm máximo considerado válido

MAX30105 particleSensor;

// Buffers requeridos por el algoritmo SparkFun
uint32_t irBuffer[BUFFER_LENGTH];
uint32_t redBuffer[BUFFER_LENGTH];

// Valores calculados (accesibles desde main)
int32_t spo2    = 0;
int8_t  validSPO2 = 0;
int32_t heartRate = 0;
int8_t  validHeartRate = 0;

/**
 * Inicializa el sensor MAX30102 via I2C.
 * Retorna true si el sensor fue detectado correctamente.
 */
bool initSensor() {
  if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) {
    Serial.println("[SENSOR] MAX30102 no encontrado. Verifica conexiones SDA/SCL.");
    return false;
  }

  // Configuración del sensor
  byte ledBrightness = 60;    // 0=Off, 255=50mA
  byte sampleAverage = 4;     // 1, 2, 4, 8, 16, 32
  byte ledMode       = 2;     // 1=Red only, 2=Red+IR, 3=Red+IR+Green
  int  sampleRate    = 100;   // muestras/segundo: 50, 100, 200, 400...
  int  pulseWidth    = 411;   // microsegundos: 69, 118, 215, 411
  int  adcRange      = 4096;  // 2048, 4096, 8192, 16384

  particleSensor.setup(ledBrightness, sampleAverage, ledMode,
                       sampleRate, pulseWidth, adcRange);

  Serial.println("[SENSOR] MAX30102 inicializado correctamente.");
  return true;
}

// Buffer index para llenar de forma no bloqueante
int bufferIndex = 0;
bool bufferReady = false;

// Llama esta función en cada iteración de loop()
// Va llenando el buffer de a una muestra por vez
void updateSensor() {
  if (!particleSensor.available()) {
    particleSensor.check();
    return;
  }

  redBuffer[bufferIndex] = particleSensor.getRed();
  irBuffer[bufferIndex]  = particleSensor.getIR();
  particleSensor.nextSample();
  bufferIndex++;

  // Cuando el buffer está lleno, calcular SpO2
  if (bufferIndex >= BUFFER_LENGTH) {
    bufferIndex = 0;
    bufferReady = true;
    maxim_heart_rate_and_oxygen_saturation(
      irBuffer, BUFFER_LENGTH, redBuffer,
      &spo2, &validSPO2, &heartRate, &validHeartRate
    );
    Serial.printf("[SENSOR] SpO2: %d%% (valido:%d) | FC: %d bpm (valido:%d)\n",
                  spo2, validSPO2, heartRate, validHeartRate);
  }
}

/**
 * Verifica si el dedo está colocado sobre el sensor.
 * Usa el valor IR como indicador de contacto.
 */
bool fingerDetected() {
  long irValue = particleSensor.getIR();
  return (irValue > 50000);  // Umbral empírico para dedo puesto
}

#endif // SENSOR_H
