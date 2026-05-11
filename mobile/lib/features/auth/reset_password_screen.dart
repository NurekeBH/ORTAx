import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  int _step = 0;
  bool _loading = false;

  Future<void> _next() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (_step < 2) {
        _step++;
      } else {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Құпиясөзді қалпына келтіру')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_step == 0) ...[
                const Text('Тіркелген телефон нөміріңізді енгізіңіз'),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                  decoration: const InputDecoration(labelText: 'Телефон', prefixIcon: Icon(Icons.phone)),
                ),
              ] else if (_step == 1) ...[
                const Text('SMS-те келген кодты енгізіңіз'),
                const SizedBox(height: 16),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'SMS код', prefixIcon: Icon(Icons.sms_outlined)),
                ),
              ] else ...[
                const Text('Жаңа құпиясөзді енгізіңіз'),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Жаңа құпиясөз', prefixIcon: Icon(Icons.lock_outline)),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _loading ? null : _next,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : Text(_step == 2 ? 'Сақтау' : 'Жалғастыру'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
