// ============================================================
//  dashboard_page.dart — Persona A (diseño UI)
//  Usa sensor_logic.dart y health_logic.dart de Persona B
// ============================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../logic/sensor_logic.dart';
import '../logic/health_logic.dart';
import 'patient_profile_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  final String patientName;

  const DashboardPage({super.key, required this.patientName});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ── State variables ──────────────────────────────────────────────────────────
  int spo2 = 0;
  int heartRate = 0;
  bool isValid = false;
  bool sensorConnected = false;
  HealthStatus healthStatus = evaluateSpo2(0); // ← Persona B logic

  final List<double> _pulseTrend = List.filled(10, 72.0);
  final List<int> _spo2Readings = [];

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // ── Logic calls (Persona B) ──────────────────────────────────────────────────
  void _startPolling() {
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 1), (_) async {
      final reading = await fetchSensorReading(); // sensor_logic.dart
      if (!mounted) return;
      setState(() {
        sensorConnected = true;
        isValid = reading.isValid;
        if (reading.isValid && reading.spo2 > 0) {
          spo2 = reading.spo2;
          heartRate = reading.heartRate;
          _spo2Readings.add(spo2);
          _pulseTrend.removeAt(0);
          _pulseTrend.add(heartRate.toDouble());
          healthStatus = evaluateSpo2(spo2); // health_logic.dart
        }
      });
    });
  }

  int get _minSpo2 =>
      _spo2Readings.isEmpty ? 0 : _spo2Readings.reduce(min);
  int get _maxSpo2 =>
      _spo2Readings.isEmpty ? 0 : _spo2Readings.reduce(max);
  int get _avgSpo2 => calculateAverage(_spo2Readings); // health_logic.dart

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientProfilePage(
          patientName: widget.patientName,
          avgSpo2: _avgSpo2,
          avgHeartRate: heartRate,
          isNormal: healthStatus.isNormal,
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // ── UI (Persona A) ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VitalPulse',
                          style: TextStyle(
                              color: Color(0xFF3B5BDB),
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                      Text('Real-time Monitoring',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.grey),
                        onPressed: _logout,
                        tooltip: 'Cerrar sesión',
                      ),
                      GestureDetector(
                        onTap: _goToProfile,
                        child: CircleAvatar(
                          backgroundColor:
                              const Color(0xFF3B5BDB).withOpacity(0.1),
                          child: Text(
                            widget.patientName.isNotEmpty
                                ? widget.patientName[0].toUpperCase()
                                : 'P',
                            style: const TextStyle(
                                color: Color(0xFF3B5BDB),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sensor status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: sensorConnected
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      sensorConnected ? Icons.wifi : Icons.wifi_off,
                      color: sensorConnected ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      sensorConnected
                          ? 'Sensor Connected'
                          : 'Connecting to sensor...',
                      style: TextStyle(
                          color: sensorConnected
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SpO2 card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 190,
                            height: 190,
                            child: CircularProgressIndicator(
                              value: spo2 / 100,
                              strokeWidth: 14,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  healthStatus.color),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('SpO2',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                              Text(
                                spo2 > 0 ? '$spo2%' : '--',
                                style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              Text(healthStatus.label,
                                  style: TextStyle(
                                      color: healthStatus.color,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem('Min',
                            _spo2Readings.isEmpty ? '--%' : '$_minSpo2%'),
                        _statItem('Avg',
                            _spo2Readings.isEmpty ? '--%' : '$_avgSpo2%'),
                        _statItem('Max',
                            _spo2Readings.isEmpty ? '--%' : '$_maxSpo2%'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Heart rate card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.favorite,
                          color: Colors.red, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Heart Rate',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                          Text(
                            heartRate > 0 ? '$heartRate BPM' : '-- BPM',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isValid
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                              radius: 4,
                              backgroundColor:
                                  isValid ? Colors.green : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            isValid ? 'Valid' : 'Waiting',
                            style: TextStyle(
                                color:
                                    isValid ? Colors.green : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pulse trend chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pulse Trend',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text('LIVE',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _PulsePainter(_pulseTrend),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('10s',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 11)),
                        ...[9, 8, 7, 6, 5, 4, 3, 2].map((s) => Text(
                            '${s}s',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11))),
                        const Text('Now',
                            style: TextStyle(
                                color: Color(0xFF3B5BDB), fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Last 10 seconds',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12)),
                        Text(
                          heartRate > 0 ? '$heartRate BPM' : '-- BPM',
                          style: const TextStyle(
                              color: Color(0xFF3B5BDB),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Patient profile section
              const Text('Patient Profile',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _goToProfile,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            const Color(0xFF3B5BDB).withOpacity(0.1),
                        child: Text(
                          widget.patientName.isNotEmpty
                              ? widget.patientName
                                  .split(' ')
                                  .take(2)
                                  .map((w) => w[0])
                                  .join()
                                  .toUpperCase()
                              : 'P',
                          style: const TextStyle(
                              color: Color(0xFF3B5BDB),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.patientName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87)),
                            const Text('Ver perfil completo →',
                                style: TextStyle(
                                    color: Color(0xFF3B5BDB),
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87)),
      ],
    );
  }
}

// ── Custom painter for pulse trend ────────────────────────────────────────────
class _PulsePainter extends CustomPainter {
  final List<double> data;
  _PulsePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final minVal = data.reduce(min) - 5;
    final maxVal = data.reduce(max) + 5;
    final range = maxVal - minVal;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF3B5BDB).withOpacity(0.3),
          const Color(0xFF3B5BDB).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = const Color(0xFF3B5BDB)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.data != data;
}
