import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../config/constants.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

/// Pantalla de verificación de email
/// Muestra instrucciones y permite reenviar el email de verificación
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? _timer;
  Timer? _countdownTimer;
  int _countdown = 0;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    // Verificar cada 3 segundos si el email fue verificado
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authProvider = context.read<AuthProvider>();
      final isVerified = await authProvider.checkEmailVerified();

      if (isVerified && mounted) {
        _timer?.cancel();
        // TODO: Navegar a Workshop Home
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Email verificado correctamente!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendVerificationEmail();

    if (!mounted) return;

    if (success) {
      // Iniciar countdown de 60 segundos
      setState(() {
        _canResend = false;
        _countdown = 60;
      });

      // Cancelar timer anterior si existe
      _countdownTimer?.cancel();

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_countdown == 0) {
          timer.cancel();
          setState(() {
            _canResend = true;
          });
        } else {
          setState(() {
            _countdown--;
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Email de verificación enviado',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.secondary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Error al enviar email',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppConstants.defaultPadding * 2,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_unread,
                            size: 80,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'Verifica tu Email',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Hemos enviado un email de verificación a tu correo electrónico.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Por favor revisa tu bandeja de entrada y haz clic en el enlace de verificación.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Loading indicator
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Esperando verificación...',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 32),

                        // Resend Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return OutlinedButton(
                              onPressed: _canResend && !authProvider.isLoading
                                  ? _resendVerificationEmail
                                  : null,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 32,
                                ),
                                side: BorderSide(
                                  color: _canResend
                                      ? AppTheme.primary
                                      : AppTheme.textTertiary,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _canResend
                                    ? 'Reenviar Email'
                                    : 'Espera $_countdown segundos',
                                style: TextStyle(
                                  color: _canResend
                                      ? AppTheme.primary
                                      : AppTheme.textTertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Sign Out Button
                        TextButton(
                          onPressed: _signOut,
                          child: const Text(
                            'Cerrar sesión',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Help Text
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '💡 Si no recibes el email, revisa tu carpeta de spam',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
