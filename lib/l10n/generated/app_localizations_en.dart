// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SAMI MARKET';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get customers => 'Customers';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get login => 'Login';

  @override
  String get register => 'Create Account';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get marketName => 'Market Name';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordMessage =>
      'Enter your email to receive a password reset link.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get customerName => 'Customer Name';

  @override
  String get customerCode => 'Customer Code / #';

  @override
  String get customerCodeHint => 'e.g. 101 or A-12 (optional)';

  @override
  String get phone => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get notes => 'Notes';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get searchCustomer => 'Search customer...';

  @override
  String get noCustomers => 'No customers yet';

  @override
  String get noCustomersMessage =>
      'Add your first customer to start tracking debts.';

  @override
  String get debt => 'Debt';

  @override
  String get payment => 'Payment';

  @override
  String get addDebt => 'Add Debt';

  @override
  String get addPayment => 'Record Payment';

  @override
  String get amount => 'Amount';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get remainingDebt => 'Remaining Debt';

  @override
  String get totalDebt => 'Total Debt';

  @override
  String get totalPayments => 'Total Payments';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get customersWithDebt => 'Customers With Debt';

  @override
  String get paymentsToday => 'Payments Today';

  @override
  String get debtsToday => 'New Debts Today';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get fullyPaid => 'Fully Paid';

  @override
  String get hasDebt => 'Has Debt';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get customRange => 'Custom Range';

  @override
  String get deleteConfirmTitle => 'Delete Transaction?';

  @override
  String get deleteConfirmMessage =>
      'Are you sure you want to delete this transaction? This will change the customer\'s balance.';

  @override
  String get archiveConfirmTitle => 'Archive Customer?';

  @override
  String get archiveConfirmMessage =>
      'This customer will be archived and hidden from the list.';

  @override
  String get paymentExceedsDebt =>
      'Payment cannot be greater than the current debt.';

  @override
  String get invalidAmount => 'Please enter a valid amount.';

  @override
  String get requiredField => 'This field is required.';

  @override
  String get noInternet => 'No internet connection.';

  @override
  String get offlineSaved =>
      'Your transaction was saved locally and will be synchronized automatically.';

  @override
  String get syncFailed =>
      'Sync failed. Your data is safe locally. We will retry automatically.';

  @override
  String get syncPending => 'Pending sync';

  @override
  String get syncComplete => 'All data synced';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemMode => 'System';

  @override
  String get backup => 'Backup & Restore';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get backupCreated => 'Backup created successfully.';

  @override
  String get restoreConfirm =>
      'Are you sure you want to restore this backup? Current data will be replaced.';

  @override
  String get restoreSuccess => 'Data restored successfully.';

  @override
  String get accountInfo => 'Account Info';

  @override
  String get success => 'Success!';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get customer => 'customer';

  @override
  String customersCount(int count) {
    return '$count customers';
  }

  @override
  String currencyAmount(String amount) {
    return '$amount ₺';
  }

  @override
  String get whoAreYou => 'Who are you?';

  @override
  String get chooseAccountType => 'Select your account type to proceed';

  @override
  String get marketOwner => 'Market Owner';

  @override
  String get marketOwnerDesc => 'Manage customers, debts, and reports';

  @override
  String get customerRoleDesc => 'Track your debts, payments, and history';

  @override
  String get customerLogin => 'Customer Login';

  @override
  String get customerLoginSubtitle => 'Enter your Customer Code and secret PIN';

  @override
  String get customerPin => 'Secret PIN';

  @override
  String get customerPinHint => 'Enter 6 digits';

  @override
  String get loginButton => 'Login';

  @override
  String get forgotPin => 'Forgot PIN?';

  @override
  String get forgotPinMessage =>
      'Please contact the market owner to reset your PIN.';

  @override
  String get backToRoleSelection => 'Back to Role Selection';

  @override
  String welcomeCustomer(String name) {
    return 'Welcome $name 👋';
  }

  @override
  String get noRemainingDebt => 'No remaining debt';

  @override
  String get viewAllTransactions => 'View All Transactions';

  @override
  String get myAccount => 'My Account';

  @override
  String get changePin => 'Change PIN';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get newPin => 'New PIN';

  @override
  String get confirmNewPin => 'Confirm New PIN';

  @override
  String get pinChangedSuccess => 'PIN changed successfully.';

  @override
  String get enableCustomerAccess => 'Enable Customer App Access';

  @override
  String get enableCustomerAccessDesc =>
      'Create an account for the customer to track their debts';

  @override
  String get customerAccountCreated => 'Customer Account Created Successfully';

  @override
  String get saveCredentialsWarning =>
      'Save these credentials and provide them to the customer to log in.';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get copyPin => 'Copy PIN';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get done => 'Done';

  @override
  String get appAccess => 'App Access';

  @override
  String get accessEnabled => 'Enabled';

  @override
  String get accessDisabled => 'Disabled';

  @override
  String get resetPin => 'Reset PIN';

  @override
  String get resetPinConfirm => 'Generate a new PIN for this customer?';

  @override
  String get newPinGenerated => 'New customer PIN is:';

  @override
  String get disableAccess => 'Disable Access';

  @override
  String get enableAccess => 'Enable Access';

  @override
  String get notifications => 'Notifications';

  @override
  String get sendNotification => 'Send Notification';

  @override
  String get notificationMessage => 'Notification Message';

  @override
  String get notificationMessageHint =>
      'Example: Please settle your remaining debt...';

  @override
  String get selectRecipients => 'Select Recipients';

  @override
  String get sendToAll => 'Send to All';

  @override
  String get selectCustomers => 'Select Specific Customers';

  @override
  String get sendNotificationBtn => 'Send';

  @override
  String get notificationSent => 'Notification Sent';

  @override
  String notificationSentTo(int count) {
    return 'Notification sent to $count customer(s)';
  }

  @override
  String get noNotifications => 'No Notifications';

  @override
  String get markAllRead => 'Mark All Read';

  @override
  String get unread => 'Unread';

  @override
  String get notificationHint => 'Please enter a notification message';

  @override
  String get selectAtLeastOne => 'Please select at least one customer';

  @override
  String get shareAccountStatement => 'Share Account Statement';

  @override
  String get shareLastTransaction => 'Share Last Transaction';

  @override
  String get shareDekont => 'Share Dekont';

  @override
  String get accountStatement => 'Customer Account Statement';

  @override
  String get transactionDekont => 'Transaction Dekont';

  @override
  String get transactionNumber => 'Transaction Ref';

  @override
  String get statementNumber => 'Statement Ref';

  @override
  String get beforeBalance => 'Debt Before Transaction';

  @override
  String get afterBalance => 'Debt After Transaction';

  @override
  String get accountFullyPaid => 'Account fully paid';

  @override
  String get thankYouForBusiness => 'Thank you for your business';

  @override
  String get noTransactionsRegistered => 'No transactions registered yet.';

  @override
  String get generatingPdf => 'Generating document...';

  @override
  String get pdfGenerationFailed =>
      'Failed to generate document. Please try again.';

  @override
  String get noTransactionsToShare => 'No transactions to share.';

  @override
  String get dailyStatistics => 'Daily Statistics & Reports';

  @override
  String get selectDate => 'Select Date';

  @override
  String get pickDay => 'Pick a Day';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get previousDay => 'Previous Day';

  @override
  String get nextDay => 'Next Day';

  @override
  String get netMovement => 'Net Movement';

  @override
  String get operationsCount => 'Operations Count';

  @override
  String get activeCustomersCount => 'Active Customers';

  @override
  String get debtsOnly => 'Debts Only';

  @override
  String get paymentsOnly => 'Payments Only';

  @override
  String get allOperations => 'All Operations';

  @override
  String get noTransactionsForDate =>
      'No debts or payments recorded for this date.';

  @override
  String get dailySummary => 'Daily Summary';

  @override
  String get operations => 'Operations';
}
