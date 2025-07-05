extension DurationExtension on int {
  /// Convert seconds to readable duration format (e.g., "1h 23m", "45m", "1m 30s")
  String toReadableDuration() {
    final duration = Duration(seconds: this);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else if (minutes > 0) {
      return seconds > 0 && minutes < 5
          ? '${minutes}m ${seconds}s'
          : '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }
}

extension DoubleExtension on double {
  /// Convert progress percentage to readable format (e.g., "36%")
  String toProgressString() {
    return '${toInt()}%';
  }
}

extension StringExtension on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Get string or default value if null/empty
  String orDefault(String defaultValue) {
    return isNullOrEmpty ? defaultValue : this!;
  }
}

extension DateTimeExtension on DateTime {
  /// Format DateTime to readable string (e.g., "2 hours ago", "Yesterday")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return difference.inDays == 1
          ? 'Yesterday'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
