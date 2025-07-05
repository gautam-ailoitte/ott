import 'package:flutter/material.dart';

import 'page_transitions.dart';

class TransitionBuilder {
  /// Slide transition for home to video player
  static Route<T> slideFromBottom<T>(Widget page, {RouteSettings? settings}) {
    return CustomPageRoute<T>(
      page: page,
      transitionType: TransitionType.slideFromBottom,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      settings: settings,
      fullscreenDialog: true,
    );
  }

  /// Fade transition for general navigation
  static Route<T> fade<T>(Widget page, {RouteSettings? settings}) {
    return CustomPageRoute<T>(
      page: page,
      transitionType: TransitionType.fade,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      settings: settings,
    );
  }

  /// Scale transition for modal-like screens
  static Route<T> scale<T>(Widget page, {RouteSettings? settings}) {
    return CustomPageRoute<T>(
      page: page,
      transitionType: TransitionType.scale,
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      settings: settings,
    );
  }

  /// Slide transition for horizontal navigation
  static Route<T> slideHorizontal<T>(Widget page, {RouteSettings? settings}) {
    return CustomPageRoute<T>(
      page: page,
      transitionType: TransitionType.slide,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      settings: settings,
    );
  }

  /// No transition for instant navigation
  static Route<T> none<T>(Widget page, {RouteSettings? settings}) {
    return CustomPageRoute<T>(
      page: page,
      transitionType: TransitionType.none,
      duration: Duration.zero,
      settings: settings,
    );
  }
}
