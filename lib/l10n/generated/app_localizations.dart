import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SAMI MARKET'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @marketName.
  ///
  /// In en, this message translates to:
  /// **'Market Name'**
  String get marketName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link.'**
  String get resetPasswordMessage;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @customerCode.
  ///
  /// In en, this message translates to:
  /// **'Customer Code / #'**
  String get customerCode;

  /// No description provided for @customerCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 101 or A-12 (optional)'**
  String get customerCodeHint;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @searchCustomer.
  ///
  /// In en, this message translates to:
  /// **'Search customer...'**
  String get searchCustomer;

  /// No description provided for @noCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get noCustomers;

  /// No description provided for @noCustomersMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first customer to start tracking debts.'**
  String get noCustomersMessage;

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debt;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @addDebt.
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDebt;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get addPayment;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @remainingDebt.
  ///
  /// In en, this message translates to:
  /// **'Remaining Debt'**
  String get remainingDebt;

  /// No description provided for @totalDebt.
  ///
  /// In en, this message translates to:
  /// **'Total Debt'**
  String get totalDebt;

  /// No description provided for @totalPayments.
  ///
  /// In en, this message translates to:
  /// **'Total Payments'**
  String get totalPayments;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @customersWithDebt.
  ///
  /// In en, this message translates to:
  /// **'Customers With Debt'**
  String get customersWithDebt;

  /// No description provided for @paymentsToday.
  ///
  /// In en, this message translates to:
  /// **'Payments Today'**
  String get paymentsToday;

  /// No description provided for @debtsToday.
  ///
  /// In en, this message translates to:
  /// **'New Debts Today'**
  String get debtsToday;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @fullyPaid.
  ///
  /// In en, this message translates to:
  /// **'Fully Paid'**
  String get fullyPaid;

  /// No description provided for @hasDebt.
  ///
  /// In en, this message translates to:
  /// **'Has Debt'**
  String get hasDebt;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction? This will change the customer\'s balance.'**
  String get deleteConfirmMessage;

  /// No description provided for @archiveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive Customer?'**
  String get archiveConfirmTitle;

  /// No description provided for @archiveConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This customer will be archived and hidden from the list.'**
  String get archiveConfirmMessage;

  /// No description provided for @paymentExceedsDebt.
  ///
  /// In en, this message translates to:
  /// **'Payment cannot be greater than the current debt.'**
  String get paymentExceedsDebt;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get invalidAmount;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get noInternet;

  /// No description provided for @offlineSaved.
  ///
  /// In en, this message translates to:
  /// **'Your transaction was saved locally and will be synchronized automatically.'**
  String get offlineSaved;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Your data is safe locally. We will retry automatically.'**
  String get syncFailed;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get syncPending;

  /// No description provided for @syncComplete.
  ///
  /// In en, this message translates to:
  /// **'All data synced'**
  String get syncComplete;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backup;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreBackup;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully.'**
  String get backupCreated;

  /// No description provided for @restoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore this backup? Current data will be replaced.'**
  String get restoreConfirm;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully.'**
  String get restoreSuccess;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get accountInfo;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'customer'**
  String get customer;

  /// No description provided for @customersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} customers'**
  String customersCount(int count);

  /// No description provided for @currencyAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} ₺'**
  String currencyAmount(String amount);

  /// No description provided for @whoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get whoAreYou;

  /// No description provided for @chooseAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select your account type to proceed'**
  String get chooseAccountType;

  /// No description provided for @marketOwner.
  ///
  /// In en, this message translates to:
  /// **'Market Owner'**
  String get marketOwner;

  /// No description provided for @marketOwnerDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage customers, debts, and reports'**
  String get marketOwnerDesc;

  /// No description provided for @customerRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your debts, payments, and history'**
  String get customerRoleDesc;

  /// No description provided for @customerLogin.
  ///
  /// In en, this message translates to:
  /// **'Customer Login'**
  String get customerLogin;

  /// No description provided for @customerLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your Customer Code and secret PIN'**
  String get customerLoginSubtitle;

  /// No description provided for @customerPin.
  ///
  /// In en, this message translates to:
  /// **'Secret PIN'**
  String get customerPin;

  /// No description provided for @customerPinHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6 digits'**
  String get customerPinHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @forgotPinMessage.
  ///
  /// In en, this message translates to:
  /// **'Please contact the market owner to reset your PIN.'**
  String get forgotPinMessage;

  /// No description provided for @backToRoleSelection.
  ///
  /// In en, this message translates to:
  /// **'Back to Role Selection'**
  String get backToRoleSelection;

  /// No description provided for @welcomeCustomer.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name} 👋'**
  String welcomeCustomer(String name);

  /// No description provided for @noRemainingDebt.
  ///
  /// In en, this message translates to:
  /// **'No remaining debt'**
  String get noRemainingDebt;

  /// No description provided for @viewAllTransactions.
  ///
  /// In en, this message translates to:
  /// **'View All Transactions'**
  String get viewAllTransactions;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @currentPin.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPin;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm New PIN'**
  String get confirmNewPin;

  /// No description provided for @pinChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'PIN changed successfully.'**
  String get pinChangedSuccess;

  /// No description provided for @enableCustomerAccess.
  ///
  /// In en, this message translates to:
  /// **'Enable Customer App Access'**
  String get enableCustomerAccess;

  /// No description provided for @enableCustomerAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Create an account for the customer to track their debts'**
  String get enableCustomerAccessDesc;

  /// No description provided for @customerAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Customer Account Created Successfully'**
  String get customerAccountCreated;

  /// No description provided for @saveCredentialsWarning.
  ///
  /// In en, this message translates to:
  /// **'Save these credentials and provide them to the customer to log in.'**
  String get saveCredentialsWarning;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @copyPin.
  ///
  /// In en, this message translates to:
  /// **'Copy PIN'**
  String get copyPin;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @appAccess.
  ///
  /// In en, this message translates to:
  /// **'App Access'**
  String get appAccess;

  /// No description provided for @accessEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get accessEnabled;

  /// No description provided for @accessDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get accessDisabled;

  /// No description provided for @resetPin.
  ///
  /// In en, this message translates to:
  /// **'Reset PIN'**
  String get resetPin;

  /// No description provided for @resetPinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Generate a new PIN for this customer?'**
  String get resetPinConfirm;

  /// No description provided for @newPinGenerated.
  ///
  /// In en, this message translates to:
  /// **'New customer PIN is:'**
  String get newPinGenerated;

  /// No description provided for @disableAccess.
  ///
  /// In en, this message translates to:
  /// **'Disable Access'**
  String get disableAccess;

  /// No description provided for @enableAccess.
  ///
  /// In en, this message translates to:
  /// **'Enable Access'**
  String get enableAccess;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @sendNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Notification'**
  String get sendNotification;

  /// No description provided for @notificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification Message'**
  String get notificationMessage;

  /// No description provided for @notificationMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Please settle your remaining debt...'**
  String get notificationMessageHint;

  /// No description provided for @selectRecipients.
  ///
  /// In en, this message translates to:
  /// **'Select Recipients'**
  String get selectRecipients;

  /// No description provided for @sendToAll.
  ///
  /// In en, this message translates to:
  /// **'Send to All'**
  String get sendToAll;

  /// No description provided for @selectCustomers.
  ///
  /// In en, this message translates to:
  /// **'Select Specific Customers'**
  String get selectCustomers;

  /// No description provided for @sendNotificationBtn.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendNotificationBtn;

  /// No description provided for @notificationSent.
  ///
  /// In en, this message translates to:
  /// **'Notification Sent'**
  String get notificationSent;

  /// No description provided for @notificationSentTo.
  ///
  /// In en, this message translates to:
  /// **'Notification sent to {count} customer(s)'**
  String notificationSentTo(int count);

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get markAllRead;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @notificationHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter a notification message'**
  String get notificationHint;

  /// No description provided for @selectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one customer'**
  String get selectAtLeastOne;

  /// No description provided for @shareAccountStatement.
  ///
  /// In en, this message translates to:
  /// **'Share Account Statement'**
  String get shareAccountStatement;

  /// No description provided for @shareLastTransaction.
  ///
  /// In en, this message translates to:
  /// **'Share Last Transaction'**
  String get shareLastTransaction;

  /// No description provided for @shareDekont.
  ///
  /// In en, this message translates to:
  /// **'Share Dekont'**
  String get shareDekont;

  /// No description provided for @accountStatement.
  ///
  /// In en, this message translates to:
  /// **'Customer Account Statement'**
  String get accountStatement;

  /// No description provided for @transactionDekont.
  ///
  /// In en, this message translates to:
  /// **'Transaction Dekont'**
  String get transactionDekont;

  /// No description provided for @transactionNumber.
  ///
  /// In en, this message translates to:
  /// **'Transaction Ref'**
  String get transactionNumber;

  /// No description provided for @statementNumber.
  ///
  /// In en, this message translates to:
  /// **'Statement Ref'**
  String get statementNumber;

  /// No description provided for @beforeBalance.
  ///
  /// In en, this message translates to:
  /// **'Debt Before Transaction'**
  String get beforeBalance;

  /// No description provided for @afterBalance.
  ///
  /// In en, this message translates to:
  /// **'Debt After Transaction'**
  String get afterBalance;

  /// No description provided for @accountFullyPaid.
  ///
  /// In en, this message translates to:
  /// **'Account fully paid'**
  String get accountFullyPaid;

  /// No description provided for @thankYouForBusiness.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your business'**
  String get thankYouForBusiness;

  /// No description provided for @noTransactionsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No transactions registered yet.'**
  String get noTransactionsRegistered;

  /// No description provided for @generatingPdf.
  ///
  /// In en, this message translates to:
  /// **'Generating document...'**
  String get generatingPdf;

  /// No description provided for @pdfGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate document. Please try again.'**
  String get pdfGenerationFailed;

  /// No description provided for @noTransactionsToShare.
  ///
  /// In en, this message translates to:
  /// **'No transactions to share.'**
  String get noTransactionsToShare;

  /// No description provided for @dailyStatistics.
  ///
  /// In en, this message translates to:
  /// **'Daily Statistics & Reports'**
  String get dailyStatistics;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @pickDay.
  ///
  /// In en, this message translates to:
  /// **'Pick a Day'**
  String get pickDay;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous Day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next Day'**
  String get nextDay;

  /// No description provided for @netMovement.
  ///
  /// In en, this message translates to:
  /// **'Net Movement'**
  String get netMovement;

  /// No description provided for @operationsCount.
  ///
  /// In en, this message translates to:
  /// **'Operations Count'**
  String get operationsCount;

  /// No description provided for @activeCustomersCount.
  ///
  /// In en, this message translates to:
  /// **'Active Customers'**
  String get activeCustomersCount;

  /// No description provided for @debtsOnly.
  ///
  /// In en, this message translates to:
  /// **'Debts Only'**
  String get debtsOnly;

  /// No description provided for @paymentsOnly.
  ///
  /// In en, this message translates to:
  /// **'Payments Only'**
  String get paymentsOnly;

  /// No description provided for @allOperations.
  ///
  /// In en, this message translates to:
  /// **'All Operations'**
  String get allOperations;

  /// No description provided for @noTransactionsForDate.
  ///
  /// In en, this message translates to:
  /// **'No debts or payments recorded for this date.'**
  String get noTransactionsForDate;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dailySummary;

  /// No description provided for @operations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operations;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
