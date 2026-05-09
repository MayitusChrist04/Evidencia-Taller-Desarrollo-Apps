// ============================================================
//  health_logic.dart — Persona B
//  Lógica de evaluación de salud y recomendaciones según SpO2
// ============================================================

import 'package:flutter/material.dart';

/// Result of evaluating a SpO2 value
class HealthStatus {
  final String label;
  final Color color;
  final String recommendation;
  final bool isNormal;

  HealthStatus({
    required this.label,
    required this.color,
    required this.recommendation,
    required this.isNormal,
  });
}

/// Evaluates a SpO2 value and returns the corresponding health status
HealthStatus evaluateSpo2(int spo2) {
  if (spo2 >= 95) {
    return HealthStatus(
      label: 'Normal',
      color: const Color(0xFF3B5BDB),
      recommendation:
          'Tu nivel de oxígeno en sangre es normal ($spo2%). '
          'Continúa con tus hábitos saludables y realiza una '
          'revisión de seguimiento en 30 días.',
      isNormal: true,
    );
  } else if (spo2 >= 90) {
    return HealthStatus(
      label: 'Bajo',
      color: Colors.orange,
      recommendation:
          'Tu nivel de oxígeno está ligeramente bajo ($spo2%). '
          'Se recomienda descanso, buena ventilación y consulta '
          'médica próximamente.',
      isNormal: false,
    );
  } else if (spo2 > 0) {
    return HealthStatus(
      label: 'Crítico',
      color: Colors.red,
      recommendation:
          'Tu nivel de oxígeno es crítico ($spo2%). '
          'Por favor busca atención médica de inmediato o llama '
          'a servicios de emergencia.',
      isNormal: false,
    );
  } else {
    return HealthStatus(
      label: 'Esperando...',
      color: Colors.grey,
      recommendation:
          'Coloca el sensor correctamente para obtener una lectura de SpO2.',
      isNormal: false,
    );
  }
}

/// Returns medical history items based on whether readings are normal
List<Map<String, dynamic>> getMedicalHistory(bool isNormal) {
  if (isNormal) {
    return [
      {
        'icon': Icons.monitor_heart_outlined,
        'color': const Color(0xFF3B5BDB),
        'title': 'Revisión de oximetría',
        'date': 'Hoy',
        'status': 'Estable',
        'statusColor': Colors.green,
      },
      {
        'icon': Icons.water_drop_outlined,
        'color': Colors.blue,
        'title': 'Análisis de sangre',
        'date': 'Última lectura',
        'status': 'Normal',
        'statusColor': Colors.green,
      },
      {
        'icon': Icons.computer_outlined,
        'color': Colors.teal,
        'title': 'Sesión de telesalud',
        'date': 'Recomendado en 30 días',
        'status': 'Seguimiento',
        'statusColor': Colors.orange,
      },
    ];
  } else {
    return [
      {
        'icon': Icons.monitor_heart_outlined,
        'color': Colors.red,
        'title': 'Revisión de oximetría',
        'date': 'Hoy',
        'status': 'Irregular',
        'statusColor': Colors.red,
      },
      {
        'icon': Icons.local_hospital_outlined,
        'color': Colors.red,
        'title': 'Consulta médica urgente',
        'date': 'Recomendada hoy',
        'status': 'Urgente',
        'statusColor': Colors.red,
      },
      {
        'icon': Icons.computer_outlined,
        'color': Colors.orange,
        'title': 'Sesión de telesalud',
        'date': 'Programar pronto',
        'status': 'Pendiente',
        'statusColor': Colors.orange,
      },
    ];
  }
}

/// Calculates average from a list of integers
int calculateAverage(List<int> values) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a + b) ~/ values.length;
}
