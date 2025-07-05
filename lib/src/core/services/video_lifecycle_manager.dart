// // lib/src/core/services/video_lifecycle_manager.dart
// // import 'package:better_player/better_player.dart';
// import 'package:better_player_plus/better_player_plus.dart';
// import 'package:flutter/material.dart';
//
// class VideoLifecycleManager with WidgetsBindingObserver {
//   static final VideoLifecycleManager _instance =
//       VideoLifecycleManager._internal();
//   factory VideoLifecycleManager() => _instance;
//   VideoLifecycleManager._internal();
//
//   BetterPlayerController? _activeController;
//   bool _wasPlaying = false;
//   bool _isInitialized = false;
//
//   /// Initialize the lifecycle manager
//   void initialize() {
//     if (_isInitialized) return;
//
//     WidgetsBinding.instance.addObserver(this);
//     _isInitialized = true;
//     debugPrint('VideoLifecycleManager: Initialized');
//   }
//
//   /// Dispose the lifecycle manager
//   void dispose() {
//     if (!_isInitialized) return;
//
//     WidgetsBinding.instance.removeObserver(this);
//     _activeController = null;
//     _isInitialized = false;
//     debugPrint('VideoLifecycleManager: Disposed');
//   }
//
//   /// Register active video controller
//   void registerController(BetterPlayerController controller) {
//     _activeController = controller;
//     debugPrint('VideoLifecycleManager: Controller registered');
//   }
//
//   /// Unregister video controller
//   void unregisterController() {
//     _activeController = null;
//     _wasPlaying = false;
//     debugPrint('VideoLifecycleManager: Controller unregistered');
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//
//     if (_activeController == null) return;
//
//     switch (state) {
//       case AppLifecycleState.paused:
//       case AppLifecycleState.inactive:
//         _handleAppPaused();
//         break;
//       case AppLifecycleState.resumed:
//         _handleAppResumed();
//         break;
//       case AppLifecycleState.detached:
//         _handleAppDetached();
//         break;
//       case AppLifecycleState.hidden:
//         _handleAppPaused();
//         break;
//     }
//   }
//
//   void _handleAppPaused() {
//     if (_activeController?.isPlaying() == true) {
//       _wasPlaying = true;
//       _activeController?.pause();
//       debugPrint('VideoLifecycleManager: Video paused due to app background');
//     }
//   }
//
//   void _handleAppResumed() {
//     if (_wasPlaying && _activeController != null) {
//       _activeController?.play();
//       _wasPlaying = false;
//       debugPrint('VideoLifecycleManager: Video resumed due to app foreground');
//     }
//   }
//
//   void _handleAppDetached() {
//     _activeController?.pause();
//     _wasPlaying = false;
//     debugPrint('VideoLifecycleManager: Video stopped due to app termination');
//   }
// }
//
// // Extension to easily integrate with video player widgets
// extension VideoPlayerLifecycle on BetterPlayerController {
//   void registerLifecycle() {
//     VideoLifecycleManager().registerController(this);
//   }
//
//   void unregisterLifecycle() {
//     VideoLifecycleManager().unregisterController();
//   }
// }
