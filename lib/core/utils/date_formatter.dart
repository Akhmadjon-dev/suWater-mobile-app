import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Relative time for recent, short date for older (e.g., "5m ago", "3d ago", "Mar 12")
  static String relative(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  /// Full date with time (e.g., "12.03.2026 14:30")
  static String dateTime(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  /// Short date only (e.g., "12.03.2026")
  static String date(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  /// For scheduled dates — shows dateTime or "Not set"
  static String scheduled(String? isoDate) {
    if (isoDate == null) return 'Not set';
    return dateTime(isoDate);
  }

  /// Compact date for comment timestamps (e.g., "Mar 12, 14:30")
  static String compact(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('MMM d, HH:mm').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  /// Relative time in Uzbek (e.g., "Bugun", "Kecha", "3 kun oldin")
  static String relativeUz(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) return 'Bugun';
      if (diff.inDays == 1) return 'Kecha';
      if (diff.inDays < 7) return '${diff.inDays} kun oldin';
      return date(isoDate);
    } catch (_) {
      return isoDate;
    }
  }
}
