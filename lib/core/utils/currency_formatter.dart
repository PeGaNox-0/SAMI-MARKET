import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Locale-aware currency formatting — NEVER store formatted strings in DB
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format amount with currency symbol: 1,250.00 ₺
  static String format(double amount, {String locale = 'ar'}) {
    final formatter = NumberFormat('#,##0.00', locale);
    return '${formatter.format(amount)} ${AppConstants.currency}';
  }

  /// Format without decimals for large display: 18,450 ₺
  static String formatCompact(double amount, {String locale = 'ar'}) {
    final formatter = NumberFormat('#,##0', locale);
    return '${formatter.format(amount)} ${AppConstants.currency}';
  }

  /// Format with sign: +250.00 ₺ or -100.00 ₺
  static String formatWithSign(double amount, String type, {String locale = 'ar'}) {
    final formatted = format(amount.abs(), locale: locale);
    if (type == AppConstants.typeDebt) {
      return '+$formatted';
    } else {
      return '-$formatted';
    }
  }

  /// Parse a display string back to double (for input fields)
  static double? tryParse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned);
  }
}
