import 'dart:convert';

import 'package:flutter/services.dart';

class MockVideoDataSource {
  static const String _jsonAssetPath = 'assets/mock_data.json';

  Map<String, dynamic>? _cachedData;

  /// Load mock data from JSON asset
  Future<Map<String, dynamic>> loadMockData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final String jsonString = await rootBundle.loadString(_jsonAssetPath);
      _cachedData = json.decode(jsonString) as Map<String, dynamic>;
      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load mock data: $e');
    }
  }

  /// Clear cached data
  void clearCache() {
    _cachedData = null;
  }
}
