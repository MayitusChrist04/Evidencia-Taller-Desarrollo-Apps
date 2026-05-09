// ============================================================
//  sensor_logic.dart — Persona B
//  Lógica de conexión al ESP32 y adquisición de datos
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// ── IMPORTANT: Change this to your ESP32's IP shown in Serial Monitor ────────
const String esp32Url = 'http://172.20.10.6/datos';

/// Data model for a single sensor reading
class SensorReading {
  final int spo2;
  final int heartRate;
  final bool isValid;

  const SensorReading({
    required this.spo2,
    required this.heartRate,
    required this.isValid,
  });

  /// Empty/default reading when sensor is not connected
  factory SensorReading.empty() =>
      const SensorReading(spo2: -99, heartRate: -99, isValid: false);
}

/// Fetches a single reading from the ESP32 via HTTP GET.
/// Falls back to simulated data if the ESP32 is unreachable.
Future<SensorReading> fetchSensorReading() async {
  try {
    final response = await http
        .get(Uri.parse(esp32Url))
        .timeout(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SensorReading(
        spo2: (data['spo2'] as num).toInt(),
        heartRate: (data['frecuencia_cardiaca'] as num).toInt(),
        isValid: data['valido'] as bool,
      );
    }
  } catch (_) {
    // ESP32 not reachable — use simulated data for testing
    //return _simulatedReading(); // Uncomment this line to enable simulated data when ESP32 is not available and vice versa
    return SensorReading.empty(); // Comment this line to disable simulated data and show "Esperando..." state when ESP32 is not available and vice versa
  }
  return SensorReading.empty();
}

/// Generates simulated sensor data for testing without hardware
SensorReading _simulatedReading() {
  final rand = Random();
  return SensorReading(
    spo2: 95 + rand.nextInt(5),       // 95–99%
    heartRate: 65 + rand.nextInt(20), // 65–85 bpm
    isValid: true,
  );
}
