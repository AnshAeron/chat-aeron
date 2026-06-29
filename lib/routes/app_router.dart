import 'package:chat_aeron/features/auth/presentation/pages/login_page.dart';
import 'package:chat_aeron/features/auth/presentation/pages/otp_page.dart';
import 'package:chat_aeron/features/home/home_page.dart';
import 'package:chat_aeron/features/profile/presentation/pages/profile_page.dart';
import 'package:chat_aeron/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:chat_aeron/features/splash/presentation/pages/splash_page.dart';
import 'package:chat_aeron/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_aeron/features/contacts/presentation/pages/contacts_pages.dart';

/// ------------------------------------------------------------
/// App Router
/// ------------------------------------------------------------
///
/// Centralized navigation configuration for ChatAeron.
///
/// Benefits:
/// - Single source of truth for navigation.
/// - Easy authentication redirects.
/// - Deep linking support.
/// - Scalable routing architecture.
/// ------------------------------------------------------------

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,

  routes: [
    /// Splash Screen
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),

    /// Login Screen
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),

    /// OTP Verification Screen
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final verificationId = state.extra as String;

        return OtpPage(verificationId: verificationId);
      },
    ),
    /// Home Screen
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),

    /// Profile Setup Screen (first-time)
    GoRoute(
      path: AppRoutes.profileSetup,
      builder: (context, state) => const ProfileSetupPage(),
    ),

    /// Profile Screen
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    /// Contacts Screen
    GoRoute(
      path: AppRoutes.contacts,
      builder: (context, state) => const ContactsPage(),
    ),
  ],

  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text(
          'No route defined for:\n${state.uri}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  },
);
