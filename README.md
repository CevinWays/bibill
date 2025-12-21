# Bibill 📱💸

Bibill is a sleek and simple subscription tracker application built with Flutter. It helps you manage your recurring expenses, track due dates, and get notified before payments are due.

## ✨ Features

### 📅 Subscription Management
- **Add & Edit**: Easily add new subscriptions with details like name, price, billing cycle, and start date.
- **Flexible Periods**: Supports various billing cycles including **Weekly (Mingguan)**, **Monthly (Bulanan)**, **Quarterly (Kuartal)**, and **Yearly (Tahunan)**.
- **CRUD Operations**: Full capability to update details or delete subscriptions you no longer need.

### 🔔 Smart Reminders
- **Local Notifications**: Never miss a payment again.
- **Auto-Schedule**: The app automatically schedules notifications **7 days** and **1 day** before your bill is due.
- **Testing Mode**: Includes a manual trigger to verify notification permissions and settings on your device.

### 🎨 Modern UI/UX
- **Visual Dashboard**: Clean home screen displaying all your subscriptions sorted by the next due date.
- **Status Indicators**: Visual cues for bills that are due **"Hari ini"**, **"xx hari lagi"**, or **"Terlambat"**.
- **Dynamic Icons**: Auto-generated colorful icons for each subscription based on their name.
- **Indonesian Localization**: customized for Indonesian users with IDR formatting and localized terms.

### 💾 Data Persistence
- **Offline First**: All data is stored locally on your device using SQLite, ensuring your data is private and accessible without internet.

## 🛠️ Tech Stack

- **Framework**: Flutter & Dart \
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Cubit)
- **Database**: [sqflite](https://pub.dev/packages/sqflite)
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **Styling**: [google_fonts](https://pub.dev/packages/google_fonts) (Outfit & Poppins)
- **Utilities**: [intl](https://pub.dev/packages/intl), [uuid](https://pub.dev/packages/uuid)

## 🚀 Getting Started

1. **Prerequisites**: Ensure you have Flutter installed.
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the App**:
   ```bash
   flutter run
   ```

## 📱 Permissions (Android)

For notifications to work correctly on Android 13+, please allow the **Post Notifications** permission when promoted upon first launch.
