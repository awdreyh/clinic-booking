// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tea Journal';

  @override
  String get navTea => 'Tea';

  @override
  String get navTeaware => 'Teaware';

  @override
  String get navLog => 'Log';

  @override
  String get navProfile => 'Profile';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get confirm => 'Confirm';

  @override
  String get language => 'Language';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get chooseLanguageTitle => 'Choose your language';

  @override
  String get chooseLanguagePrompt =>
      'Please choose your preferred language / 请选择您的语言';

  @override
  String get signOut => 'Sign Out';

  @override
  String get welcomeUser => 'Welcome!';

    @override
    String get myBookings => 'My bookings';

    @override
    String get nextBooking => 'Next booking';

    @override
    String get noUpcomingBookings => 'No upcoming bookings';

    @override
    String get addBooking => 'Add booking';

    @override
    String get otherUpcomingBookings => 'Other upcoming bookings';

    @override
    String get bookingLoadError => 'Could not load your bookings.';

  @override
  String get retry => 'Retry';

  @override
  String get bookingType => 'Booking type';

  @override
  String get singleBooking => 'Single';

  @override
  String get weeklyBooking => 'Weekly';

  @override
  String get fortnightlyBooking => 'Fortnightly';

  @override
  String get monthlyBooking => 'Monthly';

  @override
  String get selectTherapist => 'Therapist';

  @override
  String get selectRoom => 'Room';

  @override
  String get selectDate => 'Date';

  @override
  String get chooseTherapistAndRoom =>
      'Select a therapist and room to view availability.';

  @override
  String get availabilityLoadError => 'Could not load availability.';

  @override
  String get noAvailableDates => 'No available dates in the next 90 days.';

  @override
  String get selectTime => 'Time';

  @override
  String get selectDateFirst => 'Select a date to see available times.';

  @override
  String get noTimeslotsForDate => 'No available timeslots for this date.';

  @override
  String get bookingCreated => 'Booking created.';

  @override
  String get bookingOptionsLoadError => 'Could not load booking options.';

  @override
  String spacesRemaining(int count) =>
      count == 1 ? '1 space remaining' : '$count spaces remaining';

  @override
  String recurringAvailabilityNote(int days) =>
      'Recurring bookings use matching available slots for the next $days days.';

  @override
  String bookingSessions(int count) {
    if (count == 0) return 'Select a timeslot';
    return count == 1 ? 'Book 1 session' : 'Book $count sessions';
  }

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this? This action cannot be undone.';
}
