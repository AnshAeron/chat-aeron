import 'package:chat_aeron/features/auth/providers/auth_controller.dart';
import 'package:chat_aeron/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    // Error listener
    ref.listen(authControllerProvider, (previous, next) {
      final error = next.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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

                  // EMAIL
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Enter email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PASSWORD
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Enter password",
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
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();

                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Enter email & password"),
                                  ),
                                );
                                return;
                              }

                              await ref
                                  .read(authControllerProvider.notifier)
                                  .login(email: email, password: password);

                              // 🔥 FINAL FIX: GO TO HOME
                              if (context.mounted) {
                                context.go(AppRoutes.home);
                              }
                            },
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Login"),
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

                  TextButton(
                    onPressed: () => context.go(AppRoutes.signup),
                    child: const Text("Don't have an account? Sign Up"),
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