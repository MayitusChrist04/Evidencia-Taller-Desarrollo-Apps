// ============================================================
//  patient_profile_page.dart — Persona A (diseño UI)
//  Usa health_logic.dart de Persona B para recomendaciones
// ============================================================

import 'package:flutter/material.dart';
import '../logic/health_logic.dart';

class PatientProfilePage extends StatelessWidget {
  final String patientName;
  final int avgSpo2;
  final int avgHeartRate;
  final bool isNormal;

  const PatientProfilePage({
    super.key,
    required this.patientName,
    required this.avgSpo2,
    required this.avgHeartRate,
    required this.isNormal,
  });

  String get _initials {
    final parts = patientName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'P';
  }

  @override
  Widget build(BuildContext context) {
    // ── Lógica (Persona B) ──────────────────────────────────
    final status = evaluateSpo2(avgSpo2);
    final history = getMedicalHistory(isNormal);

    // ── UI (Persona A) ────────────────────────────────────────
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Perfil del Paciente',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        const Color(0xFF3B5BDB).withOpacity(0.12),
                    child: Text(_initials,
                        style: const TextStyle(
                            color: Color(0xFF3B5BDB),
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Text(patientName,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(
                    'Patient ID: #VP-${patientName.hashCode.abs() % 90000 + 10000}',
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recommendation banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: status.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: status.color.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isNormal
                        ? Icons.check_circle_outline
                        : avgSpo2 >= 90
                            ? Icons.warning_amber_outlined
                            : Icons.error_outline,
                    color: status.color,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      status.recommendation,
                      style: TextStyle(
                          color: status.color.withOpacity(0.9),
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Health overview card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Health Overview',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87)),
                      const Icon(Icons.medical_services_outlined,
                          color: Color(0xFF3B5BDB), size: 20),
                    ],
                  ),
                  const Divider(height: 20),
                  _overviewRow(
                    label: 'Avg. SpO2 (Last 24h)',
                    value: avgSpo2 > 0 ? '$avgSpo2%' : '--%',
                    valueColor: Colors.black87,
                  ),
                  const SizedBox(height: 12),
                  _overviewRow(
                    label: 'Avg. Heart Rate',
                    value: avgHeartRate > 0
                        ? '$avgHeartRate BPM'
                        : '-- BPM',
                    valueColor: const Color(0xFF3B5BDB),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Medical history
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Medical History',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87)),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All',
                      style: TextStyle(color: Color(0xFF3B5BDB))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: history.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (item['color'] as Color)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'] as String,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.black87)),
                                  const SizedBox(height: 2),
                                  Text(item['date'] as String,
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(item['status'] as String,
                                style: TextStyle(
                                    color: item['statusColor'] as Color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      if (i < history.length - 1)
                        const Divider(
                            height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _overviewRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ],
    );
  }
}
