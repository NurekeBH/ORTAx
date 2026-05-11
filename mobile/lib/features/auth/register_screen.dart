import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _otpSent = false;
  bool _loading = false;

  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Телефон нөмірін дұрыс енгізіңіз')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _otpSent = true;
    });
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Тіркелу',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _phoneCtrl,
                  enabled: !_otpSent,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                  decoration: const InputDecoration(
                    labelText: 'Телефон нөмірі',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '+7...',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  enabled: !_otpSent,
                  decoration: const InputDecoration(
                    labelText: 'Құпиясөз',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Кем дегенде 6 таңба';
                    return null;
                  },
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'SMS код',
                      prefixIcon: Icon(Icons.sms_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.length != 4) return '4 таңбалы кодты енгізіңіз';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : (_otpSent ? _verify : _sendOtp),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(_otpSent ? 'Растау' : 'SMS код жіберу'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Аккаунтыңыз бар ма? '),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Кіру'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
