import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tea Journal'**
  String get appTitle;

  /// No description provided for @navTea.
  ///
  /// In en, this message translates to:
  /// **'Tea'**
  String get navTea;

  /// No description provided for @navTeaware.
  ///
  /// In en, this message translates to:
  /// **'Teaware'**
  String get navTeaware;

  /// No description provided for @navLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get navLog;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

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

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @chooseLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguageTitle;

  /// No description provided for @chooseLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please choose your preferred language / 请选择您的语言'**
  String get chooseLanguagePrompt;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeUser;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get myBookings;

  /// No description provided for @nextBooking.
  ///
  /// In en, this message translates to:
  /// **'Next booking'**
  String get nextBooking;

  /// No description provided for @noUpcomingBookings.
  ///
  /// In en, this message translates to:
  /// **'No upcoming bookings'**
  String get noUpcomingBookings;

  /// No description provided for @addBooking.
  ///
  /// In en, this message translates to:
  /// **'Add booking'**
  String get addBooking;

  /// No description provided for @otherUpcomingBookings.
  ///
  /// In en, this message translates to:
  /// **'Other upcoming bookings'**
  String get otherUpcomingBookings;

  /// No description provided for @bookingLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your bookings.'**
  String get bookingLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @bookingType.
  ///
  /// In en, this message translates to:
  /// **'Booking type'**
  String get bookingType;

  /// No description provided for @singleBooking.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get singleBooking;

  /// No description provided for @weeklyBooking.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyBooking;

  /// No description provided for @fortnightlyBooking.
  ///
  /// In en, this message translates to:
  /// **'Fortnightly'**
  String get fortnightlyBooking;

  /// No description provided for @monthlyBooking.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyBooking;

  /// No description provided for @selectTherapist.
  ///
  /// In en, this message translates to:
  /// **'Therapist'**
  String get selectTherapist;

  /// No description provided for @selectRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get selectRoom;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get selectDate;

  /// No description provided for @chooseTherapistAndRoom.
  ///
  /// In en, this message translates to:
  /// **'Select a therapist and room to view availability.'**
  String get chooseTherapistAndRoom;

  /// No description provided for @availabilityLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load availability.'**
  String get availabilityLoadError;

  /// No description provided for @noAvailableDates.
  ///
  /// In en, this message translates to:
  /// **'No available dates in the next 90 days.'**
  String get noAvailableDates;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get selectTime;

  /// No description provided for @selectDateFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a date to see available times.'**
  String get selectDateFirst;

  /// No description provided for @noTimeslotsForDate.
  ///
  /// In en, this message translates to:
  /// **'No available timeslots for this date.'**
  String get noTimeslotsForDate;

  /// No description provided for @bookingCreated.
  ///
  /// In en, this message translates to:
  /// **'Booking created.'**
  String get bookingCreated;

  /// No description provided for @bookingOptionsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load booking options.'**
  String get bookingOptionsLoadError;

  /// No description provided for @spacesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{# space remaining} other{# spaces remaining}}'**
  String spacesRemaining(int count);

  /// No description provided for @recurringAvailabilityNote.
  ///
  /// In en, this message translates to:
  /// **'Recurring bookings use matching available slots for the next {days} days.'**
  String recurringAvailabilityNote(int days);

  /// No description provided for @bookingSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Select a timeslot} one{Book # session} other{Book # sessions}}'**
  String bookingSessions(int count);

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this? This action cannot be undone.'**
  String get confirmDeleteMessage;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
