import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl                 = TextEditingController();
  final _emailCtrl                = TextEditingController();
  final _passwordCtrl             = TextEditingController();
  final _passwordConfirmationCtrl = TextEditingController(); // nama field: password_confirmation
  final _formKey                  = GlobalKey<FormState>();

  bool    _isLoading       = false;
  bool    _obscurePassword = true;
  bool    _obscureConfirm  = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmationCtrl.dispose();
    super.dispose();
  }

  // ─── POST /api/register ───────────────────────────────────────────
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading      = true;
      _errorMessage   = null;
      _successMessage = null;
    });

    try {
      // Field WAJIB: name, email, password, password_confirmation
      // JANGAN ubah nama field — harus sama persis dengan Laravel
      final result = await ApiService.register(
        name                 : _nameCtrl.text.trim(),
        email                : _emailCtrl.text.trim(),
        password             : _passwordCtrl.text,
        passwordConfirmation : _passwordConfirmationCtrl.text, // ← 'password_confirmation'
      );

      if (!mounted) return;

      // Laravel saat ini return { success: true } langsung
      if (result['success'] == true) {
        setState(() {
          _successMessage = 'Akun berhasil dibuat! Silakan login.';
        });
        // Tunggu 2 detik lalu balik ke login
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        // Tampilkan error dari Laravel
        final errors = result['errors'];
        if (errors != null) {
          final errMsg = (errors as Map).values
              .map((e) => (e as List).join(', '))
              .join('\n');
          setState(() => _errorMessage = errMsg);
        } else {
          setState(() => _errorMessage = result['message'] ?? 'Registrasi gagal');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Tidak bisa terhubung ke server. Cek koneksi atau URL API.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title          : const Text('Buat Akun'),
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // ── Header ───────────────────────────────────────
              const Text(
                'Daftar BeautyHub',
                style: TextStyle(
                  fontSize  : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Isi data diri kamu untuk mulai',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // ── Pesan Error ──────────────────────────────────
              if (_errorMessage != null) ...[
                Container(
                  padding    : const EdgeInsets.all(12),
                  decoration : BoxDecoration(
                    color       : Colors.red[50],
                    border      : Border.all(color: Colors.red[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Pesan Sukses ─────────────────────────────────
              if (_successMessage != null) ...[
                Container(
                  padding    : const EdgeInsets.all(12),
                  decoration : BoxDecoration(
                    color       : Colors.green[50],
                    border      : Border.all(color: Colors.green[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Nama ─────────────────────────────────────────
              TextFormField(
                controller : _nameCtrl,
                decoration : InputDecoration(
                  labelText : 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person_outline),
                  border    : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled    : true,
                  fillColor : Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nama wajib diisi';
                  if (v.length > 100) return 'Nama maksimal 100 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Email ─────────────────────────────────────────
              TextFormField(
                controller  : _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration  : InputDecoration(
                  labelText : 'Email',
                  hintText  : 'contoh@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border    : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled    : true,
                  fillColor : Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email wajib diisi';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Password ──────────────────────────────────────
              TextFormField(
                controller : _passwordCtrl,
                obscureText: _obscurePassword,
                decoration : InputDecoration(
                  labelText : 'Password',
                  hintText  : 'Minimal 8 karakter',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled   : true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                  if (v.length < 8) return 'Password minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Konfirmasi Password ───────────────────────────
              // Field name di Laravel: password_confirmation
              TextFormField(
                controller : _passwordConfirmationCtrl,
                obscureText: _obscureConfirm,
                decoration : InputDecoration(
                  labelText : 'Konfirmasi Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled   : true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                  if (v != _passwordCtrl.text) return 'Password tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Tombol Daftar ─────────────────────────────────
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style    : ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  foregroundColor: Colors.white,
                  padding        : const EdgeInsets.symmetric(vertical: 16),
                  shape          : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width : 20,
                        child : CircularProgressIndicator(
                          strokeWidth: 2,
                          color      : Colors.white,
                        ),
                      )
                    : const Text(
                        'Daftar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16),

              // ── Link ke Login ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? '),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        color     : Color(0xFFE91E8C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}