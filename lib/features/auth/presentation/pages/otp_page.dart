import 'package:chat_aeron/features/auth/providers/auth_controller.dart';
import 'package:chat_aeron/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// OTP Verification Screen
///
/// Receives the Firebase verificationId from the Login screen.
class OtpPage extends ConsumerStatefulWidget {
  final String verificationId;

  const OtpPage({super.key, required this.verificationId});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();

    ref.listenManual<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted) return;

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      if (next.isAuthenticated &&
          next.isAuthenticated != previous?.isAuthenticated) {
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP.')),
      );
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(verificationId: widget.verificationId, smsCode: otp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              Icon(
                Icons.lock_outline,
                size: 80,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: 20),

              Text(
                "OTP Verification",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: 10),

              const Text(
                "Enter the 6-digit code sent to your phone.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                enabled: !authState.isLoading,
                decoration: const InputDecoration(
                  labelText: "OTP",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              FilledButton(
                onPressed: authState.isLoading ? null : _verifyOtp,
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Verify OTP"),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: authState.isLoading ? null : () {
                  context.go(AppRoutes.login);
                },
                child: const Text("Didn't receive OTP? Go back"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
