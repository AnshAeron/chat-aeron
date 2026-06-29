import 'package:chat_aeron/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/splash_controller.dart';

/// ------------------------------------------------------------
/// Splash Page
/// ------------------------------------------------------------
///
/// Responsibilities:
/// - Display ChatAeron branding.
/// - Trigger app initialization.
/// - Navigate to Home or Login based on auth status.
/// ------------------------------------------------------------
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Run after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isAuthenticated = await ref
          .read(splashControllerProvider.notifier)
          .initializeApp();
      if (!mounted) return;
      if (isAuthenticated) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble_rounded,
                  size: 90,
                ),
                const SizedBox(height: 24),
                Text(
                  'ChatAeron',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Fast. Secure. Smart Conversations.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
