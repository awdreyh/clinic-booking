// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '茶记';

  @override
  String get navTea => '茶';

  @override
  String get navTeaware => '茶具';

  @override
  String get navLog => '记录';

  @override
  String get navProfile => '我的';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get add => '添加';

  @override
  String get next => '下一步';

  @override
  String get finish => '完成';

  @override
  String get confirm => '确定';

  @override
  String get language => '语言';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get chooseLanguageTitle => '选择语言';

  @override
  String get chooseLanguagePrompt =>
      '请选择您的语言 / Please choose your preferred language';

  @override
  String get signOut => '退出登录';

  @override
  String get welcomeUser => '欢迎！';

  @override
  String get myBookings => '我的预约';

  @override
  String get nextBooking => '下一次预约';

  @override
  String get noUpcomingBookings => '暂无未来预约';

  @override
  String get addBooking => '新增预约';

  @override
  String get otherUpcomingBookings => '其他未来预约';

  @override
  String get bookingLoadError => '无法加载预约。';

  @override
  String get retry => '重试';

  @override
  String get bookingType => '预约类型';

  @override
  String get singleBooking => '单次';

  @override
  String get weeklyBooking => '每周';

  @override
  String get fortnightlyBooking => '每两周';

  @override
  String get monthlyBooking => '每月';

  @override
  String get selectTherapist => '治疗师';

  @override
  String get selectRoom => '诊室';

  @override
  String get selectDate => '日期';

  @override
  String get chooseTherapistAndRoom => '请选择治疗师和诊室以查看可预约时间。';

  @override
  String get availabilityLoadError => '无法加载可预约时间。';

  @override
  String get noAvailableDates => '未来 90 天没有可预约日期。';

  @override
  String get selectTime => '时间';

  @override
  String get selectDateFirst => '请选择日期以查看可预约时间。';

  @override
  String get noTimeslotsForDate => '该日期没有可预约时间段。';

  @override
  String get bookingCreated => '预约已创建。';

  @override
  String get bookingOptionsLoadError => '无法加载预约选项。';

  @override
  String spacesRemaining(int count) => '剩余 $count 个名额';

  @override
  String recurringAvailabilityNote(int days) =>
      '循环预约将使用未来 $days 天内匹配的可用时间段。';

  @override
  String bookingSessions(int count) {
    return count == 0 ? '请选择时间段' : '预约 $count 次';
  }

  @override
  String get confirmDeleteTitle => '确认删除';

  @override
  String get confirmDeleteMessage => '确定要删除吗？此操作无法撤销。';
}
