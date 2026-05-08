// ============================================================
//  patient_data_page.dart — Persona A (diseño UI)
//  Usa auth_logic.dart de Persona B para guardar el usuario
// ============================================================

import 'package:flutter/material.dart';
import '../logic/auth_logic.dart';
import 'dashboard_page.dart';

class PatientDataPage extends StatefulWidget {
  final String email;

  const PatientDataPage({super.key, required this.email});

  @override
  State<PatientDataPage> createState() => _PatientDataPageState();
}

class _PatientDataPageState extends State<PatientDataPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGender = 'Masculino';

  void _goToDashboard() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa tu nombre completo')),
      );
      return;
    }

    // ── Lógica (Persona B) ──────────────────────────────────
    registerUser(widget.email, name);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(patientName: name),
      ),
    );
  }

  // ── UI (Persona A) ────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ingresa tus datos',
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
            _sectionCard(
              icon: Icons.person_outline,
              title: 'Información Personal',
              children: [
                _inputField(
                    controller: _nameController,
                    label: 'Nombre completo',
                    hint: 'Ej. Juan García López'),
                const SizedBox(height: 16),
                _inputField(
                    controller: _ageController,
                    label: 'Edad',
                    hint: 'Ej. 35',
                    keyboardType: TextInputType.number),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              icon: Icons.people_outline,
              title: 'Género',
              children: [
                const Text('Selecciona tu género',
                    style:
                        TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children:
                      ['Masculino', 'Femenino', 'Otro'].map((gender) {
                    final selected = _selectedGender == gender;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedGender = gender),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF3B5BDB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF3B5BDB)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(gender,
                            style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              icon: Icons.monitor_weight_outlined,
              title: 'Medidas Corporales',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _inputField(
                          controller: _weightController,
                          label: 'Peso (kg)',
                          hint: 'Ej. 70',
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _inputField(
                          controller: _heightController,
                          label: 'Estatura (cm)',
                          hint: 'Ej. 175',
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _goToDashboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Siguiente',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
            children: [
              Icon(icon, color: const Color(0xFF3B5BDB), size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: Color(0xFF3B5BDB),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.black54, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF3B5BDB))),
          ),
        ),
      ],
    );
  }
}
