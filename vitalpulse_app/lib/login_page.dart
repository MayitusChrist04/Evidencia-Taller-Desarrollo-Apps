// ============================================================
//  login_page.dart — Persona A (diseño UI)
//  Usa auth_logic.dart de Persona B para la autenticación
// ============================================================

import 'package:flutter/material.dart';
import '../logic/auth_logic.dart';
import 'patient_data_page.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleAuth() {
    final email = _emailController.text.trim();

    // ── Lógica (Persona B) ──────────────────────────────────
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un correo válido')),
      );
      return;
    }

    if (isRegisteredUser(email)) {
      // Known user → go directly to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(patientName: getUserName(email)!),
        ),
      );
    } else {
      // New user → go to PatientData page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientDataPage(email: email),
        ),
      );
    }
  }

  // ── UI (Persona A) ────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header gradient
            Container(
              width: double.infinity,
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B5BDB), Color(0xFF7048E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text('Welcome',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Sign in to your account or create a new one',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            // Tab bar
            Row(
              children: ['Log In', 'Sign Up'].map((tab) {
                final selected =
                    (tab == 'Log In') == _isLogin;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _isLogin = tab == 'Log In'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF3B5BDB)
                            : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: selected
                                ? const Color(0xFF3B5BDB)
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      child: Text(tab,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                selected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _emailController,
                    hint: 'Email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot password?',
                          style: TextStyle(color: Color(0xFF3B5BDB))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B5BDB),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _isLogin ? 'Log In' : 'Sign Up',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('or continue with',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton(Icons.g_mobiledata, Colors.red),
                      const SizedBox(width: 16),
                      _socialButton(Icons.apple, Colors.black),
                      const SizedBox(width: 16),
                      _socialButton(
                          Icons.facebook, const Color(0xFF1877F2)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin ? 'Sign Up' : 'Log In',
                          style: const TextStyle(
                              color: Color(0xFF3B5BDB),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
