import 'package:intl/intl.dart';

/// Locale-aware date formatting
class DateFormatter {
  DateFormatter._();

  /// Full date: 14 أغسطس 2026
  static String formatFull(DateTime date, {String locale = 'ar'}) {
    return DateFormat('d MMMM yyyy', locale).format(date.toLocal());
  }

  /// Short date: 14/08/2026
  static String formatShort(DateTime date, {String locale = 'ar'}) {
    return DateFormat('dd/MM/yyyy', locale).format(date.toLocal());
  }

  /// Date with time: 14 أغسطس 2026, 10:32
  static String formatWithTime(DateTime date, {String locale = 'ar'}) {
    return DateFormat('d MMMM yyyy, HH:mm', locale).format(date.toLocal());
  }

  /// Time only: 10:32
  static String formatTime(DateTime date, {String locale = 'ar'}) {
    return DateFormat('HH:mm', locale).format(date.toLocal());
  }

  /// Relative date: اليوم, 10:32 — or full date if not today
  static String formatRelative(DateTime date, {String locale = 'ar'}) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(localDate.year, localDate.month, localDate.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final time = DateFormat('HH:mm', locale).format(localDate);

    if (dateDay == today) {
      return locale == 'ar' ? 'اليوم، $time' : 'Today, $time';
    } else if (dateDay == yesterday) {
      return locale == 'ar' ? 'أمس، $time' : 'Yesterday, $time';
    } else {
      return formatFull(localDate, locale: locale);
    }
  }

  /// Relative date with exact time: اليوم 10:32 ص — أو 26/09/2026 • 10:32 ص
  static String formatRelativeWithTime(DateTime date, {String locale = 'ar'}) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(localDate.year, localDate.month, localDate.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final time = DateFormat('hh:mm a', locale).format(localDate);

    if (dateDay == today) {
      return locale == 'ar' ? 'اليوم $time' : 'Today $time';
    } else if (dateDay == yesterday) {
      return locale == 'ar' ? 'أمس $time' : 'Yesterday $time';
    } else {
      final dateStr = DateFormat('dd/MM/yyyy', locale).format(localDate);
      return '$dateStr • $time';
    }
  }

  /// Month year: أغسطس 2026
  static String formatMonthYear(DateTime date, {String locale = 'ar'}) {
    return DateFormat('MMMM yyyy', locale).format(date.toLocal());
  }
}
