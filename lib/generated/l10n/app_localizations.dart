import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
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
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nexora Khata'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Income-Expense Manager'**
  String get appSubtitle;

  /// No description provided for @splashContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue Anyway'**
  String get splashContinue;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdate;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get commonNoData;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get commonFilter;

  /// No description provided for @commonSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get commonSort;

  /// No description provided for @commonMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get commonMore;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get commonWarning;

  /// No description provided for @commonInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get commonInfo;

  /// No description provided for @commonAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get commonAmount;

  /// No description provided for @commonDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get commonDate;

  /// No description provided for @commonNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get commonNote;

  /// No description provided for @commonType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get commonType;

  /// No description provided for @commonCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get commonCategory;

  /// No description provided for @commonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get commonBalance;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get commonSearchHint;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSaveLabel;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonUpdateLabel.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdateLabel;

  /// No description provided for @commonConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirmLabel;

  /// No description provided for @commonSaveShort.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSaveShort;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get statusReceived;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusPendingAlt.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPendingAlt;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusUnselected.
  ///
  /// In en, this message translates to:
  /// **'Unselected'**
  String get statusUnselected;

  /// No description provided for @payCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get payCash;

  /// No description provided for @payBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get payBank;

  /// No description provided for @payBkash.
  ///
  /// In en, this message translates to:
  /// **'bKash'**
  String get payBkash;

  /// No description provided for @payNagad.
  ///
  /// In en, this message translates to:
  /// **'Nagad'**
  String get payNagad;

  /// No description provided for @payRocket.
  ///
  /// In en, this message translates to:
  /// **'Rocket'**
  String get payRocket;

  /// No description provided for @payCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get payCard;

  /// No description provided for @payCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get payCheck;

  /// No description provided for @payMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payMethod;

  /// No description provided for @payPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payPayment;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @monthShort1.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthShort1;

  /// No description provided for @monthShort2.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthShort2;

  /// No description provided for @monthShort3.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthShort3;

  /// No description provided for @monthShort4.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthShort4;

  /// No description provided for @monthShort5.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthShort5;

  /// No description provided for @monthShort6.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthShort6;

  /// No description provided for @monthShort7.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthShort7;

  /// No description provided for @monthShort8.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthShort8;

  /// No description provided for @monthShort9.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthShort9;

  /// No description provided for @monthShort10.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthShort10;

  /// No description provided for @monthShort11.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthShort11;

  /// No description provided for @monthShort12.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthShort12;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySun;

  /// No description provided for @timeYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} years ago'**
  String timeYearsAgo(Object count);

  /// No description provided for @timeMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String timeMonthsAgo(Object count);

  /// No description provided for @timeWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String timeWeeksAgo(Object count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeDaysAgo(Object count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String timeHoursAgo(Object count);

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String timeMinutesAgo(Object count);

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @numCrore.
  ///
  /// In en, this message translates to:
  /// **'{count} crore'**
  String numCrore(Object count);

  /// No description provided for @numLakh.
  ///
  /// In en, this message translates to:
  /// **'{count} lakh'**
  String numLakh(Object count);

  /// No description provided for @numThousand.
  ///
  /// In en, this message translates to:
  /// **'{count} thousand'**
  String numThousand(Object count);

  /// No description provided for @valRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String valRequired(Object field);

  /// No description provided for @valThisField.
  ///
  /// In en, this message translates to:
  /// **'this field'**
  String get valThisField;

  /// No description provided for @valValue.
  ///
  /// In en, this message translates to:
  /// **'value'**
  String get valValue;

  /// No description provided for @valMinLength.
  ///
  /// In en, this message translates to:
  /// **'{field} must be at least {min} characters'**
  String valMinLength(Object field, Object min);

  /// No description provided for @valMaxLength.
  ///
  /// In en, this message translates to:
  /// **'{field} can be at most {max} characters'**
  String valMaxLength(Object field, Object max);

  /// No description provided for @valEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get valEmail;

  /// No description provided for @valPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (e.g. 01XXXXXXXXX)'**
  String get valPhone;

  /// No description provided for @valAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get valAmountRequired;

  /// No description provided for @valAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount (greater than 0)'**
  String get valAmountInvalid;

  /// No description provided for @valNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Number is required'**
  String get valNumberRequired;

  /// No description provided for @valNumberPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive number'**
  String get valNumberPositive;

  /// No description provided for @valUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL'**
  String get valUrl;

  /// No description provided for @valMismatch.
  ///
  /// In en, this message translates to:
  /// **'{field} does not match'**
  String valMismatch(Object field);

  /// No description provided for @valDate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date'**
  String get valDate;

  /// No description provided for @valEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get valEnterAmount;

  /// No description provided for @valEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get valEnterValidAmount;

  /// No description provided for @valSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get valSelectCategory;

  /// No description provided for @valEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get valEnterName;

  /// No description provided for @valEnterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get valEnterNameHint;

  /// No description provided for @valSelectField.
  ///
  /// In en, this message translates to:
  /// **'Select {label}'**
  String valSelectField(Object label);

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// No description provided for @navLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get navLoans;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardTodaySummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get dashboardTodaySummary;

  /// No description provided for @dashboardTodayIncome.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Income'**
  String get dashboardTodayIncome;

  /// No description provided for @dashboardTodayExpense.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Expense'**
  String get dashboardTodayExpense;

  /// No description provided for @dashboardBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get dashboardBalance;

  /// No description provided for @dashboardTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get dashboardTotalLabel;

  /// No description provided for @dashboardCashBalance.
  ///
  /// In en, this message translates to:
  /// **'Cash Balance'**
  String get dashboardCashBalance;

  /// No description provided for @dashboardBankBalance.
  ///
  /// In en, this message translates to:
  /// **'Bank Balance'**
  String get dashboardBankBalance;

  /// No description provided for @dashboardTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get dashboardTotalIncome;

  /// No description provided for @dashboardTotalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get dashboardTotalExpense;

  /// No description provided for @dashboardMonthlyChart.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get dashboardMonthlyChart;

  /// No description provided for @dashboardIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get dashboardIncome;

  /// No description provided for @dashboardExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get dashboardExpense;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get dashboardReport;

  /// No description provided for @dashboardAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get dashboardAddIncome;

  /// No description provided for @dashboardAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get dashboardAddExpense;

  /// No description provided for @dashboardTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get dashboardTransfer;

  /// No description provided for @dashboardNoTransaction.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get dashboardNoTransaction;

  /// No description provided for @dashboardRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get dashboardRecentTransactions;

  /// No description provided for @dashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboardViewAll;

  /// No description provided for @dashboardToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardToday;

  /// No description provided for @txnAllTitle.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get txnAllTitle;

  /// No description provided for @txnSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get txnSearchHint;

  /// No description provided for @txnLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading transactions...'**
  String get txnLoading;

  /// No description provided for @txnNoData.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get txnNoData;

  /// No description provided for @txnNoDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to add a new transaction'**
  String get txnNoDataSubtitle;

  /// No description provided for @txnNew.
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get txnNew;

  /// No description provided for @txnAddPrompt.
  ///
  /// In en, this message translates to:
  /// **'What would you like to add?'**
  String get txnAddPrompt;

  /// No description provided for @txnIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get txnIncomeTitle;

  /// No description provided for @txnIncomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Money received (salary, sales, etc.)'**
  String get txnIncomeSubtitle;

  /// No description provided for @txnExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get txnExpenseTitle;

  /// No description provided for @txnExpenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Money spent (food, rent, etc.)'**
  String get txnExpenseSubtitle;

  /// No description provided for @txnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get txnType;

  /// No description provided for @txnAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get txnAll;

  /// No description provided for @txnClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get txnClearAll;

  /// No description provided for @txnLoan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get txnLoan;

  /// No description provided for @txnTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get txnTransfer;

  /// No description provided for @txnCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get txnCategories;

  /// No description provided for @txnLists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get txnLists;

  /// No description provided for @incListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View all income transactions'**
  String get incListSubtitle;

  /// No description provided for @expListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View all expense transactions'**
  String get expListSubtitle;

  /// No description provided for @txnTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get txnTransferTitle;

  /// No description provided for @txnTransferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move money between cash or bank accounts'**
  String get txnTransferSubtitle;

  /// No description provided for @txnStatusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get txnStatusFilter;

  /// No description provided for @txnRepay.
  ///
  /// In en, this message translates to:
  /// **'Repay'**
  String get txnRepay;

  /// No description provided for @incListTitle.
  ///
  /// In en, this message translates to:
  /// **'Income List'**
  String get incListTitle;

  /// No description provided for @incMonthlyReportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get incMonthlyReportTooltip;

  /// No description provided for @incCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get incCategoryTooltip;

  /// No description provided for @incSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search income...'**
  String get incSearchHint;

  /// No description provided for @incLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading income...'**
  String get incLoading;

  /// No description provided for @incEmpty.
  ///
  /// In en, this message translates to:
  /// **'No income yet'**
  String get incEmpty;

  /// No description provided for @incEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to add income'**
  String get incEmptySubtitle;

  /// No description provided for @incAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get incAdd;

  /// No description provided for @incNew.
  ///
  /// In en, this message translates to:
  /// **'New Income'**
  String get incNew;

  /// No description provided for @incEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get incEdit;

  /// No description provided for @incUpdated.
  ///
  /// In en, this message translates to:
  /// **'Income updated'**
  String get incUpdated;

  /// No description provided for @incAdded.
  ///
  /// In en, this message translates to:
  /// **'New income added'**
  String get incAdded;

  /// No description provided for @incDetail.
  ///
  /// In en, this message translates to:
  /// **'Income Details'**
  String get incDetail;

  /// No description provided for @incNotFound.
  ///
  /// In en, this message translates to:
  /// **'Income not found'**
  String get incNotFound;

  /// No description provided for @incTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get incTotal;

  /// No description provided for @incNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get incNoData;

  /// No description provided for @incNoDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No income found for this year'**
  String get incNoDataSubtitle;

  /// No description provided for @incExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get incExportCsv;

  /// No description provided for @incExportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data to export'**
  String get incExportEmpty;

  /// No description provided for @incExportError.
  ///
  /// In en, this message translates to:
  /// **'Problem exporting: {error}'**
  String incExportError(Object error);

  /// No description provided for @incCsvHeader.
  ///
  /// In en, this message translates to:
  /// **'Month,Transactions,Total Income'**
  String get incCsvHeader;

  /// No description provided for @incShareText.
  ///
  /// In en, this message translates to:
  /// **'Income Monthly Report {year}'**
  String incShareText(Object year);

  /// No description provided for @incCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String incCount(Object count);

  /// No description provided for @incUnit.
  ///
  /// In en, this message translates to:
  /// **''**
  String get incUnit;

  /// No description provided for @incCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Income Categories'**
  String get incCategoryTitle;

  /// No description provided for @expListTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense List'**
  String get expListTitle;

  /// No description provided for @expDailyTab.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get expDailyTab;

  /// No description provided for @expMonthlyTab.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get expMonthlyTab;

  /// No description provided for @expMonthlyReportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get expMonthlyReportTooltip;

  /// No description provided for @expCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get expCategoryTooltip;

  /// No description provided for @expSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search expenses...'**
  String get expSearchHint;

  /// No description provided for @expLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading expenses...'**
  String get expLoading;

  /// No description provided for @expEmpty.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get expEmpty;

  /// No description provided for @expEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to add expenses'**
  String get expEmptySubtitle;

  /// No description provided for @expAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get expAdd;

  /// No description provided for @expNew.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get expNew;

  /// No description provided for @expEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get expEdit;

  /// No description provided for @expUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated'**
  String get expUpdated;

  /// No description provided for @expAdded.
  ///
  /// In en, this message translates to:
  /// **'New expense added'**
  String get expAdded;

  /// No description provided for @expDetail.
  ///
  /// In en, this message translates to:
  /// **'Expense Details'**
  String get expDetail;

  /// No description provided for @expNotFound.
  ///
  /// In en, this message translates to:
  /// **'Expense not found'**
  String get expNotFound;

  /// No description provided for @expTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get expTotal;

  /// No description provided for @expMonthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expense Report'**
  String get expMonthlyReport;

  /// No description provided for @expDailyReport.
  ///
  /// In en, this message translates to:
  /// **'Daily Expense Report'**
  String get expDailyReport;

  /// No description provided for @expEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'No expenses'**
  String get expEmptyDay;

  /// No description provided for @expEmptyDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses found for this date'**
  String get expEmptyDaySubtitle;

  /// No description provided for @expCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String expCount(Object count);

  /// No description provided for @expCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Categories'**
  String get expCategoryTitle;

  /// No description provided for @expCsvHeader.
  ///
  /// In en, this message translates to:
  /// **'Month,Transactions,Total Expense'**
  String get expCsvHeader;

  /// No description provided for @expSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get expSupplier;

  /// No description provided for @expDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get expDeleteConfirm;

  /// No description provided for @expDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expDeleted;

  /// No description provided for @incDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this income?'**
  String get incDeleteConfirm;

  /// No description provided for @incDeleted.
  ///
  /// In en, this message translates to:
  /// **'Income deleted'**
  String get incDeleted;

  /// No description provided for @trfSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transfer completed'**
  String get trfSuccess;

  /// No description provided for @trfTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get trfTitle;

  /// No description provided for @trfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer money between cash or bank accounts'**
  String get trfSubtitle;

  /// No description provided for @trfFrom.
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get trfFrom;

  /// No description provided for @trfTo.
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get trfTo;

  /// No description provided for @trfNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Why was this transfer made (optional)'**
  String get trfNoteHint;

  /// No description provided for @trfSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get trfSave;

  /// No description provided for @formAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get formAmount;

  /// No description provided for @formAmountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get formAmountHint;

  /// No description provided for @formDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get formDate;

  /// No description provided for @formNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get formNote;

  /// No description provided for @formNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a description...'**
  String get formNoteHint;

  /// No description provided for @formReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get formReference;

  /// No description provided for @formReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Invoice number, etc.'**
  String get formReferenceHint;

  /// No description provided for @formCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get formCategory;

  /// No description provided for @formNewCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get formNewCategory;

  /// No description provided for @formCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get formCategoryName;

  /// No description provided for @formCategoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Clothes, Bills, Medical'**
  String get formCategoryNameHint;

  /// No description provided for @formCategoryAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add category'**
  String get formCategoryAddFailed;

  /// No description provided for @formImageAttached.
  ///
  /// In en, this message translates to:
  /// **'Image attached'**
  String get formImageAttached;

  /// No description provided for @formImageAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get formImageAdd;

  /// No description provided for @formWebImageUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Image attachment is not supported on web'**
  String get formWebImageUnsupported;

  /// No description provided for @catEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get catEmptyTitle;

  /// No description provided for @catEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a new category'**
  String get catEmptySubtitle;

  /// No description provided for @catAddLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get catAddLabel;

  /// No description provided for @catEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get catEdit;

  /// No description provided for @catDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get catDelete;

  /// No description provided for @catDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get catDeleteTitle;

  /// No description provided for @catDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete the \"{name}\" category?'**
  String catDeleteMessage(Object name);

  /// No description provided for @catDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get catDeleted;

  /// No description provided for @catUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get catUpdated;

  /// No description provided for @catAdded.
  ///
  /// In en, this message translates to:
  /// **'New category added'**
  String get catAdded;

  /// No description provided for @catName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get catName;

  /// No description provided for @catNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get catNameHint;

  /// No description provided for @catDesc.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get catDesc;

  /// No description provided for @catOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get catOptional;

  /// No description provided for @catIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get catIcon;

  /// No description provided for @detNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get detNote;

  /// No description provided for @detDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get detDelete;

  /// No description provided for @detDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get detDate;

  /// No description provided for @detCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get detCategory;

  /// No description provided for @detPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get detPayment;

  /// No description provided for @detReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get detReference;

  /// No description provided for @detCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created Date'**
  String get detCreatedAt;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get filterCancelled;

  /// No description provided for @loanTitle.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loanTitle;

  /// No description provided for @loanRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get loanRefresh;

  /// No description provided for @loanLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading loan accounts...'**
  String get loanLoading;

  /// No description provided for @loanNew.
  ///
  /// In en, this message translates to:
  /// **'New Account'**
  String get loanNew;

  /// No description provided for @loanEmpty.
  ///
  /// In en, this message translates to:
  /// **'No accounts'**
  String get loanEmpty;

  /// No description provided for @loanEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track money borrowed from or lent to friends by adding a new account'**
  String get loanEmptySubtitle;

  /// No description provided for @loanAll.
  ///
  /// In en, this message translates to:
  /// **'All Accounts'**
  String get loanAll;

  /// No description provided for @loanSearch.
  ///
  /// In en, this message translates to:
  /// **'Search accounts...'**
  String get loanSearch;

  /// No description provided for @loanSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching account found'**
  String get loanSearchEmpty;

  /// No description provided for @loanEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get loanEdit;

  /// No description provided for @loanDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get loanDelete;

  /// No description provided for @loanSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get loanSettled;

  /// No description provided for @loanReceivable.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get loanReceivable;

  /// No description provided for @loanDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get loanDebt;

  /// No description provided for @loanSummary.
  ///
  /// In en, this message translates to:
  /// **'Loan Summary'**
  String get loanSummary;

  /// No description provided for @loanTotalReceivable.
  ///
  /// In en, this message translates to:
  /// **'Total Receivable'**
  String get loanTotalReceivable;

  /// No description provided for @loanTotalDebt.
  ///
  /// In en, this message translates to:
  /// **'Total Debt'**
  String get loanTotalDebt;

  /// No description provided for @loanNet.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get loanNet;

  /// No description provided for @loanBorrowLent.
  ///
  /// In en, this message translates to:
  /// **'Borrowed {borrowed} · Lent {lent}'**
  String loanBorrowLent(Object borrowed, Object lent);

  /// No description provided for @loanDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get loanDetailTitle;

  /// No description provided for @loanTxnLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading transactions...'**
  String get loanTxnLoading;

  /// No description provided for @loanTxnEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get loanTxnEmpty;

  /// No description provided for @loanTxnEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add borrowed or lent money using the button below'**
  String get loanTxnEmptySubtitle;

  /// No description provided for @loanHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get loanHistory;

  /// No description provided for @loanAddTxn.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get loanAddTxn;

  /// No description provided for @loanActionPrompt.
  ///
  /// In en, this message translates to:
  /// **'What are you doing?'**
  String get loanActionPrompt;

  /// No description provided for @loanBorrow.
  ///
  /// In en, this message translates to:
  /// **'Borrowed Money'**
  String get loanBorrow;

  /// No description provided for @loanBorrowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Borrowed money from {name}'**
  String loanBorrowSubtitle(Object name);

  /// No description provided for @loanLend.
  ///
  /// In en, this message translates to:
  /// **'Lent Money'**
  String get loanLend;

  /// No description provided for @loanLendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lent money to {name}'**
  String loanLendSubtitle(Object name);

  /// No description provided for @loanRepay.
  ///
  /// In en, this message translates to:
  /// **'Repay'**
  String get loanRepay;

  /// No description provided for @loanRepaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Return or deposit money'**
  String get loanRepaySubtitle;

  /// No description provided for @loanDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this account?'**
  String get loanDeleteTitle;

  /// No description provided for @loanDeleteMsg.
  ///
  /// In en, this message translates to:
  /// **'All transactions for this person will be deleted'**
  String get loanDeleteMsg;

  /// No description provided for @loanDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get loanDeleted;

  /// No description provided for @loanTxnDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction?'**
  String get loanTxnDeleteTitle;

  /// No description provided for @loanTxnDeleteMsg.
  ///
  /// In en, this message translates to:
  /// **'This transaction will be deleted'**
  String get loanTxnDeleteMsg;

  /// No description provided for @loanTxnDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get loanTxnDeleted;

  /// No description provided for @loanFullSettled.
  ///
  /// In en, this message translates to:
  /// **'Fully Settled'**
  String get loanFullSettled;

  /// No description provided for @loanYouReceive.
  ///
  /// In en, this message translates to:
  /// **'I will receive'**
  String get loanYouReceive;

  /// No description provided for @loanYouOwe.
  ///
  /// In en, this message translates to:
  /// **'I have to pay'**
  String get loanYouOwe;

  /// No description provided for @loanBorrowLabel.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get loanBorrowLabel;

  /// No description provided for @loanLendLabel.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get loanLendLabel;

  /// No description provided for @loanRepayBorrow.
  ///
  /// In en, this message translates to:
  /// **'Repay (Borrowed)'**
  String get loanRepayBorrow;

  /// No description provided for @loanRepayLend.
  ///
  /// In en, this message translates to:
  /// **'Repay (Lent)'**
  String get loanRepayLend;

  /// No description provided for @loanRepayBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Repaying Borrowed'**
  String get loanRepayBorrowed;

  /// No description provided for @loanRepayLent.
  ///
  /// In en, this message translates to:
  /// **'Repaying Lent'**
  String get loanRepayLent;

  /// No description provided for @loanTxnRepaySelectError.
  ///
  /// In en, this message translates to:
  /// **'Select which account you are repaying'**
  String get loanTxnRepaySelectError;

  /// No description provided for @loanTxnBorrowedMsg.
  ///
  /// In en, this message translates to:
  /// **'Money borrowed'**
  String get loanTxnBorrowedMsg;

  /// No description provided for @loanTxnLentMsg.
  ///
  /// In en, this message translates to:
  /// **'Money lent'**
  String get loanTxnLentMsg;

  /// No description provided for @loanTxnRepaidMsg.
  ///
  /// In en, this message translates to:
  /// **'Repayment made'**
  String get loanTxnRepaidMsg;

  /// No description provided for @loanTxnAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get loanTxnAddTitle;

  /// No description provided for @loanTxnEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get loanTxnEditTitle;

  /// No description provided for @loanTxnAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get loanTxnAccount;

  /// No description provided for @loanTxnType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get loanTxnType;

  /// No description provided for @loanTxnBorrowSub.
  ///
  /// In en, this message translates to:
  /// **'I borrowed money'**
  String get loanTxnBorrowSub;

  /// No description provided for @loanTxnLendSub.
  ///
  /// In en, this message translates to:
  /// **'I lent money'**
  String get loanTxnLendSub;

  /// No description provided for @loanTxnRepayWhich.
  ///
  /// In en, this message translates to:
  /// **'Which account is being repaid?'**
  String get loanTxnRepayWhich;

  /// No description provided for @loanTxnRepayBorrow.
  ///
  /// In en, this message translates to:
  /// **'Borrowed Money'**
  String get loanTxnRepayBorrow;

  /// No description provided for @loanTxnRepayBorrowSub.
  ///
  /// In en, this message translates to:
  /// **'I am repaying'**
  String get loanTxnRepayBorrowSub;

  /// No description provided for @loanTxnRepayLend.
  ///
  /// In en, this message translates to:
  /// **'Lent Money'**
  String get loanTxnRepayLend;

  /// No description provided for @loanTxnRepayLendSub.
  ///
  /// In en, this message translates to:
  /// **'Receiving back'**
  String get loanTxnRepayLendSub;

  /// No description provided for @loanTxnNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Reason for this transaction (optional)'**
  String get loanTxnNoteHint;

  /// No description provided for @loanTxnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get loanTxnSave;

  /// No description provided for @loanTxnUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get loanTxnUpdate;

  /// No description provided for @loanContactUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated'**
  String get loanContactUpdated;

  /// No description provided for @loanContactAdded.
  ///
  /// In en, this message translates to:
  /// **'New account added'**
  String get loanContactAdded;

  /// No description provided for @loanContactEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get loanContactEdit;

  /// No description provided for @loanContactNew.
  ///
  /// In en, this message translates to:
  /// **'New Account'**
  String get loanContactNew;

  /// No description provided for @loanName.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get loanName;

  /// No description provided for @loanNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rakib, Aunt, Uncle'**
  String get loanNameHint;

  /// No description provided for @loanPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get loanPhone;

  /// No description provided for @loanPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get loanPhoneHint;

  /// No description provided for @loanNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Any notes (optional)'**
  String get loanNoteHint;

  /// No description provided for @loanFirstTxn.
  ///
  /// In en, this message translates to:
  /// **'First Transaction (optional)'**
  String get loanFirstTxn;

  /// No description provided for @rptDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get rptDaily;

  /// No description provided for @rptWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get rptWeekly;

  /// No description provided for @rptMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get rptMonthly;

  /// No description provided for @rptYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get rptYearly;

  /// No description provided for @rptCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get rptCategory;

  /// No description provided for @rptIncomeExpense.
  ///
  /// In en, this message translates to:
  /// **'Income-Expense'**
  String get rptIncomeExpense;

  /// No description provided for @rptCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get rptCashFlow;

  /// No description provided for @rptTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get rptTitle;

  /// No description provided for @rptSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get rptSelectDate;

  /// No description provided for @rptDailyReport.
  ///
  /// In en, this message translates to:
  /// **'Daily Report'**
  String get rptDailyReport;

  /// No description provided for @rptSelectWeek.
  ///
  /// In en, this message translates to:
  /// **'Select Week (any day)'**
  String get rptSelectWeek;

  /// No description provided for @rptLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get rptLoading;

  /// No description provided for @rptYearlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Yearly Report - {year}'**
  String rptYearlyTitle(Object year);

  /// No description provided for @rptCatIncome.
  ///
  /// In en, this message translates to:
  /// **'Income by Category'**
  String get rptCatIncome;

  /// No description provided for @rptCatExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense by Category'**
  String get rptCatExpense;

  /// No description provided for @rptNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get rptNoData;

  /// No description provided for @rptIncomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense - {year}'**
  String rptIncomeVsExpense(Object year);

  /// No description provided for @rptCashFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow - {month} {year}'**
  String rptCashFlowTitle(Object month, Object year);

  /// No description provided for @rptSelectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get rptSelectMonth;

  /// No description provided for @rptNoTxn.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get rptNoTxn;

  /// No description provided for @rptNoTxnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No income or expense found for this period'**
  String get rptNoTxnSubtitle;

  /// No description provided for @rptDayWise.
  ///
  /// In en, this message translates to:
  /// **'Day-wise Report'**
  String get rptDayWise;

  /// No description provided for @rptIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get rptIncome;

  /// No description provided for @rptExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get rptExpense;

  /// No description provided for @rptTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get rptTotal;

  /// No description provided for @rptCategories.
  ///
  /// In en, this message translates to:
  /// **'{count} categories'**
  String rptCategories(Object count);

  /// No description provided for @rptDayLabel.
  ///
  /// In en, this message translates to:
  /// **'{date}\n{label}: {amount}'**
  String rptDayLabel(Object amount, Object date, Object label);

  /// No description provided for @rptNetAmount.
  ///
  /// In en, this message translates to:
  /// **'Net Amount'**
  String get rptNetAmount;

  /// No description provided for @rptTotalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get rptTotalTransactions;

  /// No description provided for @rptCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String rptCount(Object count);

  /// No description provided for @rptCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get rptCash;

  /// No description provided for @rptBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get rptBank;

  /// No description provided for @rptCashBalance.
  ///
  /// In en, this message translates to:
  /// **'Cash Balance'**
  String get rptCashBalance;

  /// No description provided for @rptBankBalance.
  ///
  /// In en, this message translates to:
  /// **'Bank Balance'**
  String get rptBankBalance;

  /// No description provided for @rptTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get rptTotalBalance;

  /// No description provided for @rptTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get rptTotalAmount;

  /// No description provided for @rptNet.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get rptNet;

  /// No description provided for @rptIncomeSheet.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get rptIncomeSheet;

  /// No description provided for @rptExpenseSheet.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get rptExpenseSheet;

  /// No description provided for @rptMonthlySheet.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get rptMonthlySheet;

  /// No description provided for @rptYearlySheet.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get rptYearlySheet;

  /// No description provided for @rptCashflowSheet.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get rptCashflowSheet;

  /// No description provided for @rptMonthlyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report - {month} {year}'**
  String rptMonthlyReportTitle(Object month, Object year);

  /// No description provided for @rptYearlyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Yearly Report - {year}'**
  String rptYearlyReportTitle(Object year);

  /// No description provided for @rptCashflowReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow Report - {month} {year}'**
  String rptCashflowReportTitle(Object month, Object year);

  /// No description provided for @rptHeaderDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get rptHeaderDate;

  /// No description provided for @rptHeaderCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get rptHeaderCategory;

  /// No description provided for @rptHeaderCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get rptHeaderCustomer;

  /// No description provided for @rptHeaderSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get rptHeaderSupplier;

  /// No description provided for @rptHeaderDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get rptHeaderDescription;

  /// No description provided for @rptHeaderAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get rptHeaderAmount;

  /// No description provided for @rptHeaderStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get rptHeaderStatus;

  /// No description provided for @rptHeaderMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get rptHeaderMonth;

  /// No description provided for @rptHeaderIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get rptHeaderIncome;

  /// No description provided for @rptHeaderExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get rptHeaderExpense;

  /// No description provided for @rptHeaderNet.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get rptHeaderNet;

  /// No description provided for @rptHeaderCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get rptHeaderCash;

  /// No description provided for @rptHeaderBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get rptHeaderBank;

  /// No description provided for @rptHeaderTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get rptHeaderTotal;

  /// No description provided for @rptTotalTxnsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions: {count}'**
  String rptTotalTxnsLabel(Object count);

  /// No description provided for @rptSummaryLine.
  ///
  /// In en, this message translates to:
  /// **'Income: {income}  Expense: {expense}  Net: {net}  Transactions: {count}'**
  String rptSummaryLine(
    Object count,
    Object expense,
    Object income,
    Object net,
  );

  /// No description provided for @rptLoanTaken.
  ///
  /// In en, this message translates to:
  /// **'Loan (Borrowed)'**
  String get rptLoanTaken;

  /// No description provided for @rptLoanGiven.
  ///
  /// In en, this message translates to:
  /// **'Loan (Lent)'**
  String get rptLoanGiven;

  /// No description provided for @customReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Report'**
  String get customReportTitle;

  /// No description provided for @rptFromDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get rptFromDate;

  /// No description provided for @rptToDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get rptToDate;

  /// No description provided for @rptIncomeCategory.
  ///
  /// In en, this message translates to:
  /// **'Income Category'**
  String get rptIncomeCategory;

  /// No description provided for @rptExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get rptExpenseCategory;

  /// No description provided for @rptAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get rptAllCategories;

  /// No description provided for @rptGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get rptGenerate;

  /// No description provided for @rptSharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get rptSharePdf;

  /// No description provided for @rptPreviewPdf.
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get rptPreviewPdf;

  /// No description provided for @rptPrintPdf.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get rptPrintPdf;

  /// No description provided for @rptSelectRange.
  ///
  /// In en, this message translates to:
  /// **'Choose a date range and filters, then press Generate'**
  String get rptSelectRange;

  /// No description provided for @rptNoDataForRange.
  ///
  /// In en, this message translates to:
  /// **'No transactions found for this range'**
  String get rptNoDataForRange;

  /// No description provided for @rptDetailTxn.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get rptDetailTxn;

  /// No description provided for @setTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setTitle;

  /// No description provided for @setPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get setPreferences;

  /// No description provided for @setDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get setDarkMode;

  /// No description provided for @setDatabase.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get setDatabase;

  /// No description provided for @setBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get setBackup;

  /// No description provided for @setBackupTake.
  ///
  /// In en, this message translates to:
  /// **'Take Backup'**
  String get setBackupTake;

  /// No description provided for @setBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Offline Backup'**
  String get setBackupRestore;

  /// No description provided for @setBackupRestoreSub.
  ///
  /// In en, this message translates to:
  /// **'Backup, restore, export & import'**
  String get setBackupRestoreSub;

  /// No description provided for @setOnlineBackup.
  ///
  /// In en, this message translates to:
  /// **'Online Backup'**
  String get setOnlineBackup;

  /// No description provided for @setOnlineBackupSub.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore on Google Drive'**
  String get setOnlineBackupSub;

  /// No description provided for @setOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get setOther;

  /// No description provided for @setAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get setAbout;

  /// No description provided for @setPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get setPrivacy;

  /// No description provided for @setTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get setTerms;

  /// No description provided for @setLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get setLanguage;

  /// No description provided for @setSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get setSelectLanguage;

  /// No description provided for @setBangla.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get setBangla;

  /// No description provided for @setAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get setAppVersion;

  /// No description provided for @setAutoBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic Offline Backup'**
  String get setAutoBackup;

  /// No description provided for @setBackupFreq.
  ///
  /// In en, this message translates to:
  /// **'Backup Frequency'**
  String get setBackupFreq;

  /// No description provided for @setAutoBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatic backups will be taken while the app is running'**
  String get setAutoBackupDesc;

  /// No description provided for @setHourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get setHourly;

  /// No description provided for @setDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get setDaily;

  /// No description provided for @setWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get setWeekly;

  /// No description provided for @setMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get setMonthly;

  /// No description provided for @setManualBackup.
  ///
  /// In en, this message translates to:
  /// **'Manual Offline Backup'**
  String get setManualBackup;

  /// No description provided for @setManualBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a backup copy of the current database'**
  String get setManualBackupDesc;

  /// No description provided for @setTakeBackup.
  ///
  /// In en, this message translates to:
  /// **'Take Backup'**
  String get setTakeBackup;

  /// No description provided for @setRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get setRestore;

  /// No description provided for @setRestoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Restoring will replace current data with the backup file'**
  String get setRestoreWarning;

  /// No description provided for @setRestoreFromHistory.
  ///
  /// In en, this message translates to:
  /// **'From History'**
  String get setRestoreFromHistory;

  /// No description provided for @setRestoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'From File'**
  String get setRestoreFromFile;

  /// No description provided for @setExportImport.
  ///
  /// In en, this message translates to:
  /// **'Export / Import'**
  String get setExportImport;

  /// No description provided for @setShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get setShare;

  /// No description provided for @setImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get setImport;

  /// No description provided for @setBackupHistory.
  ///
  /// In en, this message translates to:
  /// **'Offline Backup History'**
  String get setBackupHistory;

  /// No description provided for @setBackupCount.
  ///
  /// In en, this message translates to:
  /// **'{count} | {size}'**
  String setBackupCount(Object count, Object size);

  /// No description provided for @setErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String setErrorPrefix(Object error);

  /// No description provided for @setNoBackup.
  ///
  /// In en, this message translates to:
  /// **'No backups'**
  String get setNoBackup;

  /// No description provided for @setFirstBackup.
  ///
  /// In en, this message translates to:
  /// **'Take your first backup'**
  String get setFirstBackup;

  /// No description provided for @setFileShare.
  ///
  /// In en, this message translates to:
  /// **'Share File'**
  String get setFileShare;

  /// No description provided for @setDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get setDelete;

  /// No description provided for @setRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get setRestoreConfirmTitle;

  /// No description provided for @setRestoreConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Restore data from {name}?\nCurrent data will be deleted.'**
  String setRestoreConfirmMsg(Object name);

  /// No description provided for @setDeleteBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Backup'**
  String get setDeleteBackupTitle;

  /// No description provided for @setDeleteBackupMsg.
  ///
  /// In en, this message translates to:
  /// **'Delete the {name} backup?'**
  String setDeleteBackupMsg(Object name);

  /// No description provided for @setBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup successful: {file}'**
  String setBackupSuccess(Object file);

  /// No description provided for @setBackupWebUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Backup is not supported on web'**
  String get setBackupWebUnsupported;

  /// No description provided for @setBackupWebShareUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Sharing backups is not supported on web'**
  String get setBackupWebShareUnsupported;

  /// No description provided for @setFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String setFailed(Object error);

  /// No description provided for @setNoBackupFound.
  ///
  /// In en, this message translates to:
  /// **'No backup found'**
  String get setNoBackupFound;

  /// No description provided for @setSelectBackup.
  ///
  /// In en, this message translates to:
  /// **'Select Backup'**
  String get setSelectBackup;

  /// No description provided for @setRestoreConfirmMsg2.
  ///
  /// In en, this message translates to:
  /// **'Restore from {name}?\nAll current data will be deleted!'**
  String setRestoreConfirmMsg2(Object name);

  /// No description provided for @setRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore successful! {file}'**
  String setRestoreSuccess(Object file);

  /// No description provided for @setRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get setRestoreFailed;

  /// No description provided for @setImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Import'**
  String get setImportConfirmTitle;

  /// No description provided for @setImportConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Import {name}?\nCurrent data will be replaced!'**
  String setImportConfirmMsg(Object name);

  /// No description provided for @setImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import successful'**
  String get setImportSuccess;

  /// No description provided for @setImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get setImportFailed;

  /// No description provided for @obkTitle.
  ///
  /// In en, this message translates to:
  /// **'Online Backup'**
  String get obkTitle;

  /// No description provided for @obkYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your Google Account'**
  String get obkYourAccount;

  /// No description provided for @obkSignedInDesc.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore your data on Google Drive'**
  String get obkSignedInDesc;

  /// No description provided for @obkSignedOutDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google to backup and restore your data on Google Drive'**
  String get obkSignedOutDesc;

  /// No description provided for @obkSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get obkSignIn;

  /// No description provided for @obkSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get obkSignOut;

  /// No description provided for @obkSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String obkSignedInAs(Object email);

  /// No description provided for @obkBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get obkBackupNow;

  /// No description provided for @obkRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from Google Drive'**
  String get obkRestore;

  /// No description provided for @obkStatus.
  ///
  /// In en, this message translates to:
  /// **'Backup Status'**
  String get obkStatus;

  /// No description provided for @obkLastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last Backup'**
  String get obkLastBackup;

  /// No description provided for @obkBackupDate.
  ///
  /// In en, this message translates to:
  /// **'Backup Date'**
  String get obkBackupDate;

  /// No description provided for @obkBackupSize.
  ///
  /// In en, this message translates to:
  /// **'Backup Size'**
  String get obkBackupSize;

  /// No description provided for @obkNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get obkNever;

  /// No description provided for @obkNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get obkNotSignedIn;

  /// No description provided for @obkNoBackupYet.
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get obkNoBackupYet;

  /// No description provided for @obkRestoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Restoring will replace all current data on this device with the online backup'**
  String get obkRestoreWarning;

  /// No description provided for @obkRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get obkRestoreConfirmTitle;

  /// No description provided for @obkRestoreConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Replace all current data with the Google Drive backup?'**
  String get obkRestoreConfirmMsg;

  /// No description provided for @obkUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup uploaded to Google Drive'**
  String get obkUploadSuccess;

  /// No description provided for @obkRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore successful! Please restart the app.'**
  String get obkRestoreSuccess;

  /// No description provided for @obkErrorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get obkErrorNoInternet;

  /// No description provided for @obkErrorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first'**
  String get obkErrorNotSignedIn;

  /// No description provided for @obkErrorSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign in was cancelled'**
  String get obkErrorSignInCancelled;

  /// No description provided for @obkErrorSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get obkErrorSignInFailed;

  /// No description provided for @obkErrorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied for Google Drive'**
  String get obkErrorPermissionDenied;

  /// No description provided for @obkErrorTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired, please sign in again'**
  String get obkErrorTokenExpired;

  /// No description provided for @obkErrorMissingBackup.
  ///
  /// In en, this message translates to:
  /// **'No backup found on Google Drive'**
  String get obkErrorMissingBackup;

  /// No description provided for @obkErrorUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload backup'**
  String get obkErrorUploadFailed;

  /// No description provided for @obkErrorDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to download backup'**
  String get obkErrorDownloadFailed;

  /// No description provided for @obkErrorRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get obkErrorRestoreFailed;

  /// No description provided for @obkErrorUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Online backup is not supported on this platform'**
  String get obkErrorUnsupported;

  /// No description provided for @obkErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again'**
  String get obkErrorUnknown;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A modern bookkeeping application'**
  String get aboutSubtitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get aboutVersion;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get aboutDeveloper;

  /// No description provided for @aboutEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get aboutEmail;

  /// No description provided for @aboutWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutWebsite;

  /// No description provided for @aboutRights.
  ///
  /// In en, this message translates to:
  /// **'© 2026 BadhonByte. All rights reserved.'**
  String get aboutRights;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'We take your privacy very seriously. This privacy policy explains how Nexora Khata collects, uses and protects your information.'**
  String get privacyIntro;

  /// No description provided for @privacyCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'What Information We Collect'**
  String get privacyCollectTitle;

  /// No description provided for @privacyCollect1.
  ///
  /// In en, this message translates to:
  /// **'• We store your accounting data (income, expenses, transactions) locally on your device.\n'**
  String get privacyCollect1;

  /// No description provided for @privacyCollect2.
  ///
  /// In en, this message translates to:
  /// **'• We do not collect personal identifiers such as name, address or phone number, unless you voluntarily provide them.\n'**
  String get privacyCollect2;

  /// No description provided for @privacyCollect3.
  ///
  /// In en, this message translates to:
  /// **'• We may collect basic usage information such as app version and device type.'**
  String get privacyCollect3;

  /// No description provided for @privacyUseTitle.
  ///
  /// In en, this message translates to:
  /// **'How We Use Information'**
  String get privacyUseTitle;

  /// No description provided for @privacyUse1.
  ///
  /// In en, this message translates to:
  /// **'• Your information is used only to ensure the app works and to store and manage your accounts.\n'**
  String get privacyUse1;

  /// No description provided for @privacyUse2.
  ///
  /// In en, this message translates to:
  /// **'• We do not share your information with any third party.\n'**
  String get privacyUse2;

  /// No description provided for @privacyUse3.
  ///
  /// In en, this message translates to:
  /// **'• Your information always stays on your device and is never sent to our servers.'**
  String get privacyUse3;

  /// No description provided for @privacySecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Security'**
  String get privacySecurityTitle;

  /// No description provided for @privacySecurity1.
  ///
  /// In en, this message translates to:
  /// **'• Your data is stored locally on your device.\n'**
  String get privacySecurity1;

  /// No description provided for @privacySecurity2.
  ///
  /// In en, this message translates to:
  /// **'• We take appropriate security measures to keep your data safe.\n'**
  String get privacySecurity2;

  /// No description provided for @privacySecurity3.
  ///
  /// In en, this message translates to:
  /// **'• No third party can access your data.'**
  String get privacySecurity3;

  /// No description provided for @privacyRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privacyRightsTitle;

  /// No description provided for @privacyRights1.
  ///
  /// In en, this message translates to:
  /// **'• You can backup, export or delete your data at any time.\n'**
  String get privacyRights1;

  /// No description provided for @privacyRights2.
  ///
  /// In en, this message translates to:
  /// **'• You can delete all data from the app settings.\n'**
  String get privacyRights2;

  /// No description provided for @privacyRights3.
  ///
  /// In en, this message translates to:
  /// **'• Your data is completely under your control.'**
  String get privacyRights3;

  /// No description provided for @privacyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactMsg.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about this privacy policy, contact us: '**
  String get privacyContactMsg;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'By using the Nexora Khata app, you agree to the following terms and conditions.'**
  String get termsIntro;

  /// No description provided for @termsServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Terms'**
  String get termsServiceTitle;

  /// No description provided for @termsService1.
  ///
  /// In en, this message translates to:
  /// **'• Nexora Khata is a personal bookkeeping application that helps you track your income and expenses.\n'**
  String get termsService1;

  /// No description provided for @termsService2.
  ///
  /// In en, this message translates to:
  /// **'• This app is provided on an \"as is\" basis.\n'**
  String get termsService2;

  /// No description provided for @termsService3.
  ///
  /// In en, this message translates to:
  /// **'• We reserve the right to change the terms of service at any time without prior notice.'**
  String get termsService3;

  /// No description provided for @termsUserTitle.
  ///
  /// In en, this message translates to:
  /// **'User Responsibilities'**
  String get termsUserTitle;

  /// No description provided for @termsUser1.
  ///
  /// In en, this message translates to:
  /// **'• You are responsible for keeping your account information and password confidential.\n'**
  String get termsUser1;

  /// No description provided for @termsUser2.
  ///
  /// In en, this message translates to:
  /// **'• You must not perform any illegal activity through the app.\n'**
  String get termsUser2;

  /// No description provided for @termsUser3.
  ///
  /// In en, this message translates to:
  /// **'• You will provide accurate and up-to-date information.\n'**
  String get termsUser3;

  /// No description provided for @termsUser4.
  ///
  /// In en, this message translates to:
  /// **'• It is your responsibility to refrain from misusing the app.'**
  String get termsUser4;

  /// No description provided for @termsAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Policies'**
  String get termsAccountTitle;

  /// No description provided for @termsAccount1.
  ///
  /// In en, this message translates to:
  /// **'• You must be at least 13 years old to use the app.\n'**
  String get termsAccount1;

  /// No description provided for @termsAccount2.
  ///
  /// In en, this message translates to:
  /// **'• An account cannot be logged into from multiple devices.\n'**
  String get termsAccount2;

  /// No description provided for @termsAccount3.
  ///
  /// In en, this message translates to:
  /// **'• Any misconduct or misuse may result in the cancellation of your account.'**
  String get termsAccount3;

  /// No description provided for @termsDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get termsDisclaimerTitle;

  /// No description provided for @termsDisclaimer1.
  ///
  /// In en, this message translates to:
  /// **'• Nexora Khata does not provide financial advice.\n'**
  String get termsDisclaimer1;

  /// No description provided for @termsDisclaimer2.
  ///
  /// In en, this message translates to:
  /// **'• We try our best to ensure the accuracy of the app\'s information, but we are not responsible for any errors or losses.\n'**
  String get termsDisclaimer2;

  /// No description provided for @termsDisclaimer3.
  ///
  /// In en, this message translates to:
  /// **'• We will not be liable for any financial loss resulting from the use of the app.'**
  String get termsDisclaimer3;

  /// No description provided for @termsLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get termsLimitsTitle;

  /// No description provided for @termsLimits1.
  ///
  /// In en, this message translates to:
  /// **'• Under no circumstances will Nexora Khata or BadhonByte be liable for any direct, indirect, incidental or consequential damages.\n'**
  String get termsLimits1;

  /// No description provided for @termsLimits2.
  ///
  /// In en, this message translates to:
  /// **'• Our liability is limited to the value of the app.\n'**
  String get termsLimits2;

  /// No description provided for @termsLimits3.
  ///
  /// In en, this message translates to:
  /// **'• Rights that cannot be excluded under local law will not be affected by these terms.'**
  String get termsLimits3;

  /// No description provided for @termsContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get termsContactTitle;

  /// No description provided for @termsContactMsg.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about the terms, contact us: '**
  String get termsContactMsg;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account to continue'**
  String get authLoginSubtitle;

  /// No description provided for @authUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username or Email'**
  String get authUsernameLabel;

  /// No description provided for @authUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your username or email'**
  String get authUsernameHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginButton;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authSignupLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authSignupLink;

  /// No description provided for @authLoginError.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get authLoginError;

  /// No description provided for @authLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get authLoginSuccess;

  /// No description provided for @authSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authSignupTitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to start tracking your finances'**
  String get authSignupSubtitle;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullNameLabel;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authFullNameHint;

  /// No description provided for @authNewUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authNewUsernameLabel;

  /// No description provided for @authNewUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get authNewUsernameHint;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get authConfirmPasswordHint;

  /// No description provided for @authSignupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignupButton;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginLink;

  /// No description provided for @authUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get authUsernameTaken;

  /// No description provided for @authPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsMismatch;

  /// No description provided for @authSignupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get authSignupSuccess;

  /// No description provided for @authRequiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get authRequiredField;

  /// No description provided for @authPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters'**
  String get authPasswordMin;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailHint;

  /// No description provided for @authSecurityQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Security Question'**
  String get authSecurityQuestionLabel;

  /// No description provided for @authSecurityAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Security Answer'**
  String get authSecurityAnswerLabel;

  /// No description provided for @authSecurityAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the answer'**
  String get authSecurityAnswerHint;

  /// No description provided for @authSecurityQuestionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose a security question'**
  String get authSecurityQuestionRequired;

  /// No description provided for @authForgotLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotLink;

  /// No description provided for @authForgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get authForgotTitle;

  /// No description provided for @authForgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email to recover your account'**
  String get authForgotSubtitle;

  /// No description provided for @authForgotEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email'**
  String get authForgotEmailHint;

  /// No description provided for @authForgotContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authForgotContinue;

  /// No description provided for @authForgotQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Question'**
  String get authForgotQuestionTitle;

  /// No description provided for @authForgotQuestionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answer the security question you set during sign-up'**
  String get authForgotQuestionSubtitle;

  /// No description provided for @authForgotQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your answer'**
  String get authForgotQuestionHint;

  /// No description provided for @authForgotVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authForgotVerify;

  /// No description provided for @authForgotEmailNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get authForgotEmailNotFound;

  /// No description provided for @authForgotWrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'Incorrect answer'**
  String get authForgotWrongAnswer;

  /// No description provided for @authForgotNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a New Password'**
  String get authForgotNewPasswordTitle;

  /// No description provided for @authForgotNewPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account'**
  String get authForgotNewPasswordSubtitle;

  /// No description provided for @authForgotNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get authForgotNewPasswordLabel;

  /// No description provided for @authForgotNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get authForgotNewPasswordHint;

  /// No description provided for @authForgotConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get authForgotConfirmPasswordLabel;

  /// No description provided for @authForgotConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter the new password'**
  String get authForgotConfirmPasswordHint;

  /// No description provided for @authForgotResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authForgotResetButton;

  /// No description provided for @authForgotResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. Please login.'**
  String get authForgotResetSuccess;

  /// No description provided for @authForgotBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authForgotBack;

  /// No description provided for @setAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get setAccount;

  /// No description provided for @setLoggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Logged in as'**
  String get setLoggedInAs;

  /// No description provided for @setLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get setLogout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMsg;

  /// No description provided for @logoutConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmYes;

  /// No description provided for @logoutConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get logoutConfirmNo;

  /// No description provided for @notifGoodMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get notifGoodMorningTitle;

  /// No description provided for @notifGoodMorningBody.
  ///
  /// In en, this message translates to:
  /// **'Start your day fresh. Don\'t forget to record today\'s income and expenses.'**
  String get notifGoodMorningBody;

  /// No description provided for @notifGoodAfternoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get notifGoodAfternoonTitle;

  /// No description provided for @notifGoodAfternoonBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your khata up to date. Note any income or expense you made today.'**
  String get notifGoodAfternoonBody;

  /// No description provided for @notifGoodNightTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get notifGoodNightTitle;

  /// No description provided for @notifGoodNightBody.
  ///
  /// In en, this message translates to:
  /// **'Review today\'s records before you sleep. Rest well!'**
  String get notifGoodNightBody;

  /// No description provided for @notifDaySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get notifDaySummaryTitle;

  /// No description provided for @notifDaySummaryBody.
  ///
  /// In en, this message translates to:
  /// **'Income: {income} | Expense: {expense} | Balance: {balance}'**
  String notifDaySummaryBody(Object balance, Object expense, Object income);

  /// No description provided for @notifLoanTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan Reminder'**
  String get notifLoanTitle;

  /// No description provided for @notifLoanBorrowBody.
  ///
  /// In en, this message translates to:
  /// **'You took a loan of {amount} from {name} on {date}. Have you thought about paying it back?'**
  String notifLoanBorrowBody(Object amount, Object date, Object name);

  /// No description provided for @notifLoanLendBody.
  ///
  /// In en, this message translates to:
  /// **'You lent {amount} to {name} on {date}. Has the money been returned?'**
  String notifLoanLendBody(Object amount, Object date, Object name);
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
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
