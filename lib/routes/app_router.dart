import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chat_aeron/features/splash/presentation/pages/splash_page.dart';
import 'package:chat_aeron/features/auth/presentation/pages/login_page.dart';
import 'package:chat_aeron/features/auth/presentation/pages/otp_page.dart';
import 'app_routes.dart';

/// ------------------------------------------------------------
/// App Router
/// ------------------------------------------------------------
///
/// This file manages all navigation in ChatAeron.
///
/// Why?
/// - Single place for all routes.
/// - Easy authentication redirects.
/// - Deep linking support.
/// - Production-ready architecture.
///
/// NOTE:
/// Currently only Splash is a real screen.
/// Home and Login are placeholders and will be replaced later.
/// ------------------------------------------------------------

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    /// Splash
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),

    /// Login
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) =>
          const _PlaceholderScreen(title: 'Login Screen'),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(path: AppRoutes.otp, builder: (context, state) => const OtpPage()),

    /// Home
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) =>
          const _PlaceholderScreen(title: 'Home Screen'),
    ),
  ],
);

/// ------------------------------------------------------------
/// Temporary Placeholder Screen
/// ------------------------------------------------------------
///
/// These screens are temporary.
///
/// As each feature is developed, these placeholders
/// will be replaced with actual pages.
/// ------------------------------------------------------------
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
