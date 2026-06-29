import 'package:chat_aeron/features/auth/providers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_aeron/routes/app_routes.dart';

/// LoginPage
///
/// Production-ready authentication screen.
///
/// Responsibilities:
/// - Display branding
/// - Collect phone number
/// - Trigger authentication through the AuthController.
///
/// NOTE:
/// Firebase logic is NOT implemented here.
/// This page only interacts with the presentation layer.
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

    // Listen to authentication state.
    final authState = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (previous, next) {
      if (next.verificationId != null) {
        context.go(AppRoutes.otp);
      }

      if (next.errorMessage != null) {
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
                  const SizedBox(height: 30),

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

                  const SizedBox(height: 50),

                  Text("Phone Number", style: theme.textTheme.titleMedium),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "Enter phone number",
                      prefixText: "+91 ",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithPhone(
                                    _phoneController.text.trim(),
                                  );
                            },
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Continue"),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Display error message if present.
                  if (authState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        authState.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),

                  Text(
                    "By continuing, you agree to our Terms & Privacy Policy.",
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
