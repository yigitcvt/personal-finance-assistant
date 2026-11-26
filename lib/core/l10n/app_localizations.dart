import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/scheduled_payments/domain/scheduled_payment_model.dart';

/// Centralized localization system supporting English (default) and Turkish.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('tr'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  /// Helper for non-Widget layers (e.g. NotificationService).
  static AppLocalizations forLocale(Locale locale) => AppLocalizations(locale);

  String get _lang => _translations.containsKey(locale.languageCode)
      ? locale.languageCode
      : 'en';

  String _t(String key) {
    return _translations[_lang]?[key] ?? _translations['en']![key] ?? key;
  }

  String _tParams(String key, Map<String, String> params) {
    var text = _t(key);
    params.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  // --- Locale-aware Date Formatting ---
  String formatDate(DateTime date) {
    return DateFormat.yMd(_lang).format(date);
  }

  // --- App & Navigation ---
  String get appTitle => _t('appTitle');
  String get navDashboard => _t('navDashboard');
  String get navTransactions => _t('navTransactions');
  String get navCalendar => _t('navCalendar');
  String get navReports => _t('navReports');
  String get navSettings => _t('navSettings');

  // --- Onboarding ---
  String get welcomeTitle => _t('welcomeTitle');
  String get welcomeSubtitle => _t('welcomeSubtitle');
  String get initialBalanceLabel => _t('initialBalanceLabel');
  String get invalidAmountError => _t('invalidAmountError');
  String get continueButton => _t('continueButton');
  String get startWithZeroButton => _t('startWithZeroButton');

  // --- Dashboard ---
  String get totalCurrentBalance => _t('totalCurrentBalance');
  String get spendableBalance => _t('spendableBalance');
  String get pendingScheduledPayments => _t('pendingScheduledPayments');
  String get pendingIncomeLabel => _t('pendingIncomeLabel');
  String get addIncome => _t('addIncome');
  String get addExpense => _t('addExpense');
  String get monthlyIncome => _t('monthlyIncome');
  String get monthlyExpense => _t('monthlyExpense');
  String get upcomingPayments => _t('upcomingPayments');
  String get planButton => _t('planButton');
  String get noUpcomingPaymentsDesc => _t('noUpcomingPaymentsDesc');
  String get recentTransactions => _t('recentTransactions');
  String get noTransactionsTitle => _t('noTransactionsTitle');
  String get noTransactionsDashboardSubtitle =>
      _t('noTransactionsDashboardSubtitle');
  String get transactionsLoadError => _t('transactionsLoadError');
  String get markPaidShort => _t('markPaidShort');

  // --- Transactions Screen & Form ---
  String get transactionsTitle => _t('transactionsTitle');
  String get addTransaction => _t('addTransaction');
  String get filterAll => _t('filterAll');
  String get filterIncome => _t('filterIncome');
  String get filterExpense => _t('filterExpense');
  String get filterPendingIncome => _t('filterPendingIncome');
  String get noFilteredTransactionsTitle => _t('noFilteredTransactionsTitle');
  String get noTransactionsListSubtitle => _t('noTransactionsListSubtitle');
  String get noFilteredTransactionsSubtitle =>
      _t('noFilteredTransactionsSubtitle');
  String get editTransaction => _t('editTransaction');
  String get newTransaction => _t('newTransaction');
  String get expense => _t('expense');
  String get income => _t('income');
  String get transactionNameLabel => _t('transactionNameLabel');
  String get transactionNameHint => _t('transactionNameHint');
  String get amountLabel => _t('amountLabel');
  String get incomeStatusLabel => _t('incomeStatusLabel');
  String get statusReceived => _t('statusReceived');
  String get statusPending => _t('statusPending');
  String get pendingIncomeHelper => _t('pendingIncomeHelper');
  String get categoryLabel => _t('categoryLabel');
  String get dateLabel => _t('dateLabel');
  String get noteOptionalLabel => _t('noteOptionalLabel');
  String get noteOptionalHint => _t('noteOptionalHint');
  String get saveChanges => _t('saveChanges');
  String get save => _t('save');
  String get cancel => _t('cancel');
  String get delete => _t('delete');
  String get deleteRecordTitle => _t('deleteRecordTitle');
  String deleteRecordConfirm(String title) =>
      _tParams('deleteRecordConfirm', {'title': title});
  String get enterTransactionNameError => _t('enterTransactionNameError');
  String get enterPositiveAmountError => _t('enterPositiveAmountError');
  String get pendingBadge => _t('pendingBadge');
  String get markAsReceived => _t('markAsReceived');

  // --- Scheduled Payments & Calendar ---
  String get calendarTitle => _t('calendarTitle');
  String get planPayment => _t('planPayment');
  String dayRecordsHeader(String date) =>
      _tParams('dayRecordsHeader', {'date': date});
  String recordsCount(int count) =>
      _tParams('recordsCount', {'count': count.toString()});
  String get noDayRecordsTitle => _t('noDayRecordsTitle');
  String get noDayRecordsSubtitle => _t('noDayRecordsSubtitle');
  String get scheduledPaymentSubtitle => _t('scheduledPaymentSubtitle');
  String get markAsPaid => _t('markAsPaid');
  String get editPayment => _t('editPayment');
  String get planFuturePayment => _t('planFuturePayment');
  String get paymentNameLabel => _t('paymentNameLabel');
  String get paymentNameHint => _t('paymentNameHint');
  String get dueDateLabel => _t('dueDateLabel');
  String get recurrenceLabel => _t('recurrenceLabel');
  String get reminderTimeLabel => _t('reminderTimeLabel');
  String get enterPaymentNameError => _t('enterPaymentNameError');
  String get deletePaymentTitle => _t('deletePaymentTitle');
  String deletePaymentConfirm(String title) =>
      _tParams('deletePaymentConfirm', {'title': title});

  String frequencyLabel(RecurrenceFrequency frequency) {
    return switch (frequency) {
      RecurrenceFrequency.once => _t('freqOnce'),
      RecurrenceFrequency.weekly => _t('freqWeekly'),
      RecurrenceFrequency.monthly => _t('freqMonthly'),
      RecurrenceFrequency.yearly => _t('freqYearly'),
    };
  }

  String reminderOptionLabel(int days) {
    return switch (days) {
      0 => _t('reminderDueDay'),
      1 => _t('reminder1Day'),
      3 => _t('reminder3Days'),
      7 => _t('reminder7Days'),
      _ => _t('reminderDueDay'),
    };
  }

  // --- Categories ---
  String categoryName(String categoryId) {
    return _t('cat_$categoryId');
  }

  // --- Reports ---
  String get reportsTitle => _t('reportsTitle');
  String get reportsHeading => _t('reportsHeading');
  String get reportsEmptyDesc => _t('reportsEmptyDesc');

  // --- Settings ---
  String get settingsTitle => _t('settingsTitle');
  String get appearanceSection => _t('appearanceSection');
  String get themeTitle => _t('themeTitle');
  String get themeSubtitle => _t('themeSubtitle');
  String get themeLight => _t('themeLight');
  String get themeDark => _t('themeDark');
  String get themeSystem => _t('themeSystem');
  String get languageTitle => _t('languageTitle');
  String get languageSubtitle => _t('languageSubtitle');
  String get selectLanguageTitle => _t('selectLanguageTitle');
  String get notificationsSection => _t('notificationsSection');
  String get paymentRemindersTitle => _t('paymentRemindersTitle');
  String get paymentRemindersSubtitle => _t('paymentRemindersSubtitle');
  String get sendTestNotificationTitle => _t('sendTestNotificationTitle');
  String get sendTestNotificationSubtitle => _t('sendTestNotificationSubtitle');
  String get testNotificationSent => _t('testNotificationSent');
  String get testNotificationCheckPerms => _t('testNotificationCheckPerms');
  String get accountSection => _t('accountSection');
  String get invalidAmountShortError => _t('invalidAmountShortError');

  // --- Notifications ---
  String get notifChannelName => _t('notifChannelName');
  String get notifChannelDesc => _t('notifChannelDesc');
  String get notifTestBody => _t('notifTestBody');
  String get notifUpcomingTitle => _t('notifUpcomingTitle');
  String notifUpcomingBody(String title, String amount, int days) => _tParams(
        'notifUpcomingBody',
        {'title': title, 'amount': amount, 'days': days.toString()},
      );
  String get notifDueTodayTitle => _t('notifDueTodayTitle');
  String notifDueTodayBody(String title, String amount) => _tParams(
        'notifDueTodayBody',
        {'title': title, 'amount': amount},
      );

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'appTitle': 'Finance Assistant',
      'navDashboard': 'Home',
      'navTransactions': 'Transactions',
      'navCalendar': 'Calendar',
      'navReports': 'Reports',
      'navSettings': 'Settings',
      'welcomeTitle': 'Welcome',
      'welcomeSubtitle':
          'Enter your current starting balance to begin tracking your personal finances. You can update this anytime in Settings.',
      'initialBalanceLabel': 'Starting Balance',
      'invalidAmountError': 'Enter a valid amount (e.g. 12500.50)',
      'continueButton': 'Continue',
      'startWithZeroButton': 'Start with 0.00 ₺ for now',
      'totalCurrentBalance': 'Total Current Balance',
      'spendableBalance': 'Spendable Balance',
      'pendingScheduledPayments': 'Upcoming scheduled payments',
      'pendingIncomeLabel': 'Pending income (not received yet)',
      'addIncome': 'Add Income',
      'addExpense': 'Add Expense',
      'monthlyIncome': 'This Month\'s Income',
      'monthlyExpense': 'This Month\'s Expense',
      'upcomingPayments': 'Upcoming Payments',
      'planButton': 'Schedule',
      'noUpcomingPaymentsDesc':
          'No upcoming scheduled payments. Add bills or subscriptions to see your true spendable balance.',
      'recentTransactions': 'Recent Transactions',
      'noTransactionsTitle': 'No transactions yet',
      'noTransactionsDashboardSubtitle':
          'Use the quick buttons above to add your first income or expense.',
      'transactionsLoadError': 'Could not load transactions',
      'markPaidShort': 'Paid',
      'transactionsTitle': 'Transactions',
      'addTransaction': 'Add Transaction',
      'filterAll': 'All',
      'filterIncome': 'Income',
      'filterExpense': 'Expenses',
      'filterPendingIncome': 'Pending Income',
      'noFilteredTransactionsTitle': 'No records match this filter',
      'noTransactionsListSubtitle':
          'Start tracking your balance by adding your first income or expense.',
      'noFilteredTransactionsSubtitle':
          'Try selecting a different filter or adding a new transaction.',
      'editTransaction': 'Edit Transaction',
      'newTransaction': 'New Transaction',
      'expense': 'Expense',
      'income': 'Income',
      'transactionNameLabel': 'Transaction Name',
      'transactionNameHint': 'e.g. Weekly groceries, October salary',
      'amountLabel': 'Amount',
      'incomeStatusLabel': 'Income Status',
      'statusReceived': 'Received',
      'statusPending': 'Not received yet',
      'pendingIncomeHelper':
          'Pending income is not added to your current balance until marked as received.',
      'categoryLabel': 'Category',
      'dateLabel': 'Date',
      'noteOptionalLabel': 'Note (Optional)',
      'noteOptionalHint': 'Add a short note',
      'saveChanges': 'Save Changes',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'deleteRecordTitle': 'Delete Record',
      'deleteRecordConfirm': 'Are you sure you want to delete "{title}"?',
      'enterTransactionNameError': 'Please enter a transaction name.',
      'enterPositiveAmountError': 'Please enter a valid amount greater than 0.',
      'pendingBadge': 'Pending',
      'markAsReceived': 'Mark received',
      'calendarTitle': 'Calendar & Payments',
      'planPayment': 'Schedule Payment',
      'dayRecordsHeader': 'Records for {date}',
      'recordsCount': '{count} records',
      'noDayRecordsTitle': 'No records for this day',
      'noDayRecordsSubtitle':
          'Tap the button below to schedule a payment for this day.',
      'scheduledPaymentSubtitle': 'Scheduled Payment',
      'markAsPaid': 'Mark paid',
      'editPayment': 'Edit Payment',
      'planFuturePayment': 'Schedule Future Payment',
      'paymentNameLabel': 'Payment Name',
      'paymentNameHint': 'e.g. Rent, Internet bill, Spotify',
      'dueDateLabel': 'Due Date',
      'recurrenceLabel': 'Recurrence',
      'reminderTimeLabel': 'Reminder Time',
      'enterPaymentNameError': 'Please enter a payment name.',
      'deletePaymentTitle': 'Delete Payment',
      'deletePaymentConfirm':
          'Are you sure you want to delete the scheduled payment "{title}"?',
      'freqOnce': 'One-time',
      'freqWeekly': 'Weekly',
      'freqMonthly': 'Monthly',
      'freqYearly': 'Yearly',
      'reminderDueDay': 'On due date',
      'reminder1Day': '1 day before',
      'reminder3Days': '3 days before',
      'reminder7Days': '1 week before',
      'cat_inc_maas': 'Salary',
      'cat_inc_burs': 'Scholarship',
      'cat_inc_harclik': 'Allowance',
      'cat_inc_freelance': 'Freelance',
      'cat_inc_ek_gelir': 'Side Income',
      'cat_inc_diger': 'Other',
      'cat_exp_market': 'Groceries',
      'cat_exp_yemek': 'Dining',
      'cat_exp_ulasim': 'Transport',
      'cat_exp_faturalar': 'Bills',
      'cat_exp_egitim': 'Education',
      'cat_exp_eglence': 'Entertainment',
      'cat_exp_abonelikler': 'Subscriptions',
      'cat_exp_saglik': 'Health',
      'cat_exp_diger': 'Other',
      'reportsTitle': 'Reports',
      'reportsHeading': 'Reports & Charts',
      'reportsEmptyDesc':
          'Category spending charts and monthly financial summaries will appear here.',
      'settingsTitle': 'Settings',
      'appearanceSection': 'Appearance',
      'themeTitle': 'Theme',
      'themeSubtitle': 'Your preference is saved automatically.',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'themeSystem': 'System',
      'languageTitle': 'Language',
      'languageSubtitle': 'Choose your preferred app language',
      'selectLanguageTitle': 'Select Language',
      'notificationsSection': 'Notifications',
      'paymentRemindersTitle': 'Payment Reminders',
      'paymentRemindersSubtitle':
          'Send local reminders before and on the due date',
      'sendTestNotificationTitle': 'Send Test Notification',
      'sendTestNotificationSubtitle':
          'Verify Android notification permissions and delivery',
      'testNotificationSent': 'Test notification sent.',
      'testNotificationCheckPerms':
          'Notification sent (check permission settings if not visible).',
      'accountSection': 'Account',
      'invalidAmountShortError': 'Enter a valid amount',
      'notifChannelName': 'Payment Reminders',
      'notifChannelDesc':
          'Local reminders for upcoming bills and scheduled payments',
      'notifTestBody':
          'Local notifications are active! Your upcoming payments will be reminded on time.',
      'notifUpcomingTitle': 'Upcoming Payment Reminder',
      'notifUpcomingBody':
          '{title} ({amount}) is due in {days} day(s).',
      'notifDueTodayTitle': 'Payment Due Today',
      'notifDueTodayBody': '{title} ({amount}) is due today.',
    },
    'tr': {
      'appTitle': 'Finans Asistanı',
      'navDashboard': 'Ana Sayfa',
      'navTransactions': 'İşlemler',
      'navCalendar': 'Takvim',
      'navReports': 'Raporlar',
      'navSettings': 'Ayarlar',
      'welcomeTitle': 'Hoş Geldiniz',
      'welcomeSubtitle':
          'Kişisel finans takibine başlamak için mevcut başlangıç bakiyenizi girin. Dilerseniz bunu daha sonra Ayarlar üzerinden güncelleyebilirsiniz.',
      'initialBalanceLabel': 'Başlangıç Bakiyesi',
      'invalidAmountError': 'Geçerli bir tutar girin (örn: 12500,50)',
      'continueButton': 'Devam Et',
      'startWithZeroButton': 'Şimdilik 0,00 ₺ ile başla',
      'totalCurrentBalance': 'Toplam Mevcut Bakiye',
      'spendableBalance': 'Harcanabilir Bakiye',
      'pendingScheduledPayments': 'Bekleyen planlı ödemeler',
      'pendingIncomeLabel': 'Henüz hesaba geçmeyen gelir',
      'addIncome': 'Gelir Ekle',
      'addExpense': 'Gider Ekle',
      'monthlyIncome': 'Bu Ayki Gelir',
      'monthlyExpense': 'Bu Ayki Gider',
      'upcomingPayments': 'Yaklaşan Ödemeler',
      'planButton': 'Planla',
      'noUpcomingPaymentsDesc':
          'Yaklaşan planlı ödemeniz yok. Fatura veya abonelik ekleyerek harcanabilir bakiyenizi net görün.',
      'recentTransactions': 'Son İşlemler',
      'noTransactionsTitle': 'Henüz bir işleminiz yok',
      'noTransactionsDashboardSubtitle':
          'Yukarıdaki hızlı butonlarla ilk gelir veya giderinizi ekleyebilirsiniz.',
      'transactionsLoadError': 'İşlemler yüklenemedi',
      'markPaidShort': 'Ödendi',
      'transactionsTitle': 'İşlemler',
      'addTransaction': 'İşlem Ekle',
      'filterAll': 'Tümü',
      'filterIncome': 'Gelirler',
      'filterExpense': 'Giderler',
      'filterPendingIncome': 'Bekleyen Gelir',
      'noFilteredTransactionsTitle': 'Bu filtrede kayıt bulunamadı',
      'noTransactionsListSubtitle':
          'İlk gelir veya giderinizi ekleyerek bakiyenizi takip etmeye başlayın.',
      'noFilteredTransactionsSubtitle':
          'Farklı bir filtre seçebilir veya yeni işlem ekleyebilirsiniz.',
      'editTransaction': 'İşlemi Düzenle',
      'newTransaction': 'Yeni İşlem',
      'expense': 'Gider',
      'income': 'Gelir',
      'transactionNameLabel': 'İşlem Adı',
      'transactionNameHint': 'Örn: Haftalık market, Ekim maaşı',
      'amountLabel': 'Tutar',
      'incomeStatusLabel': 'Gelir Durumu',
      'statusReceived': 'Alındı',
      'statusPending': 'Hesaba geçmedi',
      'pendingIncomeHelper':
          'Henüz hesaba geçmeyen gelirler mevcut bakiyenize eklenmez.',
      'categoryLabel': 'Kategori',
      'dateLabel': 'Tarih',
      'noteOptionalLabel': 'Açıklama (İsteğe bağlı)',
      'noteOptionalHint': 'Kısa bir not ekleyebilirsiniz',
      'saveChanges': 'Değişiklikleri Kaydet',
      'save': 'Kaydet',
      'cancel': 'İptal',
      'delete': 'Sil',
      'deleteRecordTitle': 'Kaydı Sil',
      'deleteRecordConfirm': '"{title}" kaydını silmek istediğinize emin misiniz?',
      'enterTransactionNameError': 'Lütfen bir işlem adı girin.',
      'enterPositiveAmountError': 'Lütfen 0\'dan büyük geçerli bir tutar girin.',
      'pendingBadge': 'Bekliyor',
      'markAsReceived': 'Alındı yap',
      'calendarTitle': 'Takvim & Ödemeler',
      'planPayment': 'Ödeme Planla',
      'dayRecordsHeader': '{date} Kayıtları',
      'recordsCount': '{count} kayıt',
      'noDayRecordsTitle': 'Bu gün için kayıt bulunmuyor',
      'noDayRecordsSubtitle':
          'Aşağıdaki butonla bu güne planlı ödeme ekleyebilirsiniz.',
      'scheduledPaymentSubtitle': 'Planlı Ödeme',
      'markAsPaid': 'Ödendi yap',
      'editPayment': 'Ödemeyi Düzenle',
      'planFuturePayment': 'Gelecek Ödeme Planla',
      'paymentNameLabel': 'Ödeme Adı',
      'paymentNameHint': 'Örn: Kira, İnternet faturası, Spotify',
      'dueDateLabel': 'Son Ödeme Tarihi',
      'recurrenceLabel': 'Tekrarlama Sıklığı',
      'reminderTimeLabel': 'Hatırlatma Zamanı',
      'enterPaymentNameError': 'Lütfen bir ödeme adı girin.',
      'deletePaymentTitle': 'Ödemeyi Sil',
      'deletePaymentConfirm':
          '"{title}" planlı ödemesini silmek istiyor musunuz?',
      'freqOnce': 'Tek seferlik',
      'freqWeekly': 'Haftalık',
      'freqMonthly': 'Aylık',
      'freqYearly': 'Yıllık',
      'reminderDueDay': 'Ödeme günü',
      'reminder1Day': '1 gün önce',
      'reminder3Days': '3 gün önce',
      'reminder7Days': '1 hafta önce',
      'cat_inc_maas': 'Maaş',
      'cat_inc_burs': 'Burs',
      'cat_inc_harclik': 'Harçlık',
      'cat_inc_freelance': 'Freelance',
      'cat_inc_ek_gelir': 'Ek gelir',
      'cat_inc_diger': 'Diğer',
      'cat_exp_market': 'Market',
      'cat_exp_yemek': 'Yemek',
      'cat_exp_ulasim': 'Ulaşım',
      'cat_exp_faturalar': 'Faturalar',
      'cat_exp_egitim': 'Eğitim',
      'cat_exp_eglence': 'Eğlence',
      'cat_exp_abonelikler': 'Abonelikler',
      'cat_exp_saglik': 'Sağlık',
      'cat_exp_diger': 'Diğer',
      'reportsTitle': 'Raporlar',
      'reportsHeading': 'Raporlar ve Grafikler',
      'reportsEmptyDesc':
          'Kategori bazlı harcama grafikleri ve aylık finans özetleri burada yer alacak.',
      'settingsTitle': 'Ayarlar',
      'appearanceSection': 'Görünüm',
      'themeTitle': 'Tema',
      'themeSubtitle': 'Seçiminiz kalıcı olarak kaydedilir.',
      'themeLight': 'Açık',
      'themeDark': 'Koyu',
      'themeSystem': 'Sistem',
      'languageTitle': 'Dil',
      'languageSubtitle': 'Uygulama dilini seçin',
      'selectLanguageTitle': 'Dil Seçin',
      'notificationsSection': 'Bildirimler',
      'paymentRemindersTitle': 'Ödeme Hatırlatmaları',
      'paymentRemindersSubtitle':
          'Ödeme gününden önce ve ödeme günü bildirim gönder',
      'sendTestNotificationTitle': 'Test Bildirimi Gönder',
      'sendTestNotificationSubtitle':
          'Android bildirim iznini ve çalışmasını doğrula',
      'testNotificationSent': 'Test bildirimi gönderildi.',
      'testNotificationCheckPerms':
          'Bildirim gönderildi (izin ayarlarını kontrol edin).',
      'accountSection': 'Hesap',
      'invalidAmountShortError': 'Geçerli bir tutar girin',
      'notifChannelName': 'Ödeme Hatırlatıcıları',
      'notifChannelDesc':
          'Yaklaşan fatura ve planlı ödemeler için yerel hatırlatmalar',
      'notifTestBody':
          'Yerel bildirimler aktif! Yaklaşan ödemeleriniz zamanında hatırlatılacak.',
      'notifUpcomingTitle': 'Yaklaşan Ödeme Hatırlatması',
      'notifUpcomingBody':
          '{title} ({amount}) ödemesine {days} gün kaldı.',
      'notifDueTodayTitle': 'Ödeme Günü Bugün',
      'notifDueTodayBody': '{title} ({amount}) için son ödeme günü bugün.',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'tr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
