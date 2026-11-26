Personal Finance Assistant

A clean, offline-first personal finance tracking app built with Flutter, Riverpod, GoRouter, and SQLite. Track your income, expenses, pending receivables, and scheduled bills to always know your true spendable balance.

Features
Onboarding & Starting Balance — Set your initial balance on first launch (or start from 0,00 ₺) and update it anytime in Settings.
Dashboard Overview — View your Total Current Balance, Spendable Balance (current balance minus upcoming scheduled payments), monthly income/expense summary, upcoming bills, and recent transactions at a glance.
Transactions Management — Add, edit, delete, and filter income and expense records by category, date, and optional notes. Supports Pending Income (not added to balance until marked as received).
Calendar & Scheduled Payments — Plan one-time or recurring payments (weekly, monthly, yearly) on an interactive calendar (table_calendar) and mark them as paid with one tap.
Local Payment Reminders — Receive local notifications before (1 day, 3 days, 1 week) and on the due date via flutter_local_notifications, with a built-in test notification option.
Precision Currency Handling — Integer-based (kurus) Money value object to avoid floating-point rounding errors.
Localization — Built-in English (default) and Turkish language support with persistent selection.
Theming — Light, Dark, and System theme modes persisted locally.
Tech Stack
Framework: Flutter (Dart ^3.14.0)
State Management: flutter_riverpod
Navigation: go_router (StatefulShellRoute.indexedStack)
Local Storage: sqflite (SQLite) & shared_preferences
Calendar: table_calendar
Notifications: flutter_local_notifications & timezone
Formatting & i18n: intl & flutter_localizations
Project Structure
text
lib/
├── app.dart
├── main.dart
├── core/
│   ├── database/         # SQLite database helper
│   ├── l10n/             # AppLocalizations (EN / TR) & LocaleNotifier
│   ├── money/            # Integer-based Money parsing & formatting
│   ├── notifications/    # Local notification scheduling service
│   ├── router/           # GoRouter configuration
│   ├── settings/         # App settings & SharedPreferences provider
│   ├── theme/            # Light/Dark themes & ThemeMode provider
│   └── widgets/          # Shared shell & UI components
└── features/
    ├── dashboard/        # Balance summary, quick actions & overview
    ├── onboarding/       # Initial balance setup
    ├── reports/          # Financial reports & charts (in progress)
    ├── scheduled_payments/ # Calendar & recurring bill reminders
    ├── settings/         # Theme, language, notifications & account
    └── transactions/     # Income/expense CRUD & filtering
Getting Started
Prerequisites
Flutter SDK (Dart SDK ^3.14.0)
Android Studio / Xcode or a connected physical device
Installation & Running
bash
# 1. Clone the repository
git clone https://github.com/yigitcvt/personal-finance-assistant.git
cd personal-finance-assistant
# 2. Install dependencies
flutter pub get
# 3. Run unit tests
flutter test
# 4. Run the app
flutter run
License

This project is open source and available under the MIT License.
