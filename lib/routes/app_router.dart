import 'package:chat_aeron/features/auth/presentation/pages/login_page.dart';
import 'package:chat_aeron/features/auth/presentation/pages/signup_page.dart';
import 'package:chat_aeron/features/chat/presentation/pages/contacts_page.dart';
import 'package:chat_aeron/features/home/home_page.dart';
import 'package:chat_aeron/features/chat/presentation/pages/chat_page.dart';
import 'package:chat_aeron/features/splash/presentation/pages/splash_page.dart';
import 'package:chat_aeron/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_aeron/features/chat/domain/entities/chat_entity.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,

  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupPage(),
    ),

    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),

    GoRoute(
      path: AppRoutes.contacts,
      builder: (context, state) => const ContactsPage(),
    ),

    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) {
        final chat = state.extra as ChatEntity;
        return ChatPage(chat: chat);
      },
    ),
  ],

  errorBuilder: (context, state) {
    return Scaffold(body: Center(child: Text("Route error: ${state.error}")));
  },
);
