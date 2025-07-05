// lib/src/core/navigations/app_router.dart
import 'package:flutter/material.dart';

import '../../presentation/screens/home/home.dart';
import '../../presentation/screens/video_player/video_player_screen.dart';
import '../../presentation/splash/splash_screen.dart';
import 'navigation_arguments.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String videoPlayer = '/video-player';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings: settings);

      case home:
        return _buildRoute(const HomeScreen(), settings: settings);

      case videoPlayer:
        final args = settings.arguments as VideoPlayerArguments?;
        if (args == null) {
          return _buildErrorRoute('Video player arguments missing');
        }

        // ✅ Type-safe: Now using VideoModel directly
        return _buildRoute(
          VideoPlayerScreen(
            videos: args.safePlaylist,
            initialIndex: args.safeInitialIndex,
          ),
          settings: settings,
          fullscreenDialog: true,
        );

      default:
        return _buildErrorRoute('Route not found: ${settings.name}');
    }
  }

  static MaterialPageRoute<T> _buildRoute<T>(
    Widget page, {
    required RouteSettings settings,
    bool fullscreenDialog = false,
  }) {
    return MaterialPageRoute<T>(
      builder: (context) => page,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }

  static Route<dynamic> _buildErrorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(home, (route) => false),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
