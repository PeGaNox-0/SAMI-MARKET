/// Application-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'إدارة الديون';
  static const String appNameEn = 'Debt Manager';
  static const String currency = '₺';
  static const String currencyCode = 'TRY';

  // Transaction types
  static const String typeDebt = 'debt';
  static const String typePayment = 'payment';

  // Sync statuses
  static const String syncPending = 'pending';
  static const String syncSynced = 'synced';
  static const String syncFailed = 'failed';

  // Pagination
  static const int defaultPageSize = 20;
  static const int recentTransactionsLimit = 10;

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration syncRetryDelay = Duration(seconds: 30);
}
