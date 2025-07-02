import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/bowling/presentation/pages/bowling_demo_page.dart';
import '../features/bowling/presentation/pages/bowling_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String demo = '/demo';
  static const String fullGame = '/full-game';
  static const String settings = '/settings';
  static const String profile = '/profile';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const BowlingDemoPage(),
    ),
    GoRoute(
      path: AppRoutes.demo,
      name: 'demo',
      builder: (context, state) => const BowlingDemoPage(),
    ),
    GoRoute(
      path: AppRoutes.fullGame,
      name: 'fullGame',
      builder: (context, state) => const BowlingPage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'The page you\'re looking for doesn\'t exist.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
