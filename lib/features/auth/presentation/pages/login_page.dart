import 'package:chat_aeron/features/auth/providers/auth_controller.dart';
import 'package:chat_aeron/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ------------------------------------------------------------
/// Login Page
/// ------------------------------------------------------------
///
/// Collects user's phone number and requests Firebase
/// to send an OTP.
///
/// Responsibilities:
/// • Validate phone number
/// • Trigger Send OTP
/// • Navigate to OTP screen
/// ------------------------------------------------------------
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  Icon(
                    Icons.chat_bubble_rounded,
                    size: 90,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "ChatAeron",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Fast. Secure. Smart Conversations.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 48),

                  Text("Phone Number", style: theme.textTheme.titleMedium),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      prefixText: "+91 ",
                      hintText: "Enter phone number",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              final phone =
                                  "+91${_phoneController.text.trim()}";

                              await ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithPhone(
                                    phoneNumber: phone,
                                    onCodeSent: (verificationId) {
                                      if (!context.mounted) return;

                                      context.go(
                                        AppRoutes.otp,
                                        extra: verificationId,
                                      );
                                    },
                                  );
                            },
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Continue"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (authState.errorMessage != null)
                    Text(
                      authState.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),

                  const SizedBox(height: 20),

                  Text(
                    "By continuing you agree to our Terms & Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
