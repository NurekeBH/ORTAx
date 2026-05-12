import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import 'auth_controller.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  int _step = 0;

  Future<void> _next() async {
    final notifier = ref.read(authProvider.notifier);
    if (_step == 0) {
      if (_phoneCtrl.text.trim().length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Телефон нөмірін дұрыс енгізіңіз')),
        );
        return;
      }
      final ok = await notifier.requestReset(phone: _phoneCtrl.text.trim());
      if (!mounted) return;
      if (ok) {
        setState(() => _step = 1);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SMS жіберілді (демо: код 0000)')),
        );
      }
    } else if (_step == 1) {
      if (_otpCtrl.text.length != 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('4 таңбалы кодты енгізіңіз')),
        );
        return;
      }
      setState(() => _step = 2);
    } else {
      if (_newPassCtrl.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Кем дегенде 6 таңба')),
        );
        return;
      }
      final ok = await notifier.resetPassword(
        phone: _phoneCtrl.text.trim(),
        otp: _otpCtrl.text.trim(),
        newPassword: _newPassCtrl.text,
      );
      if (!mounted) return;
      if (ok) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
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
                const Text('SMS-те келген кодты енгізіңіз (демо: 0000)'),
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
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  auth.error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: auth.loading ? null : _next,
                child: auth.loading
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
