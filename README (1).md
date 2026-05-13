# 💰 UniPocket

> **Your personal finance companion — offline, private, and beautifully simple.**

UniPocket is a fully offline expense and budget tracking app built with **Flutter**. No ads, no cloud sync, no subscriptions. Your financial data stays 100% on your device.

---

## ✨ Features

### 💸 Expense & Allowance Tracking
- **Quick Logging:** Add allowance and expenses in seconds.
- **Student-Centric:** 12 built-in categories specifically for university life (Rent, Groceries, Eating Out, Transport, etc.).
- **Smart Logic:** Category suggestions based on title and duplicate transaction detection.
- **Interactive UI:** Swipe to edit or delete with a 3-second "Undo" safety net.
- **Monthly Allowance:** Set a master monthly funding goal (parents, jobs, etc.) and track your total spending against it.

### 🔁 Recurring Transactions
- **Automation:** Automate your regular bills, subscriptions, or weekly allowances.
- **Flexible Scheduling:** Set up daily, weekly, monthly, or yearly repeats.

### 📊 Budget & Analytics
- **Master Budget:** A special top-level "Monthly Allowance" budget that sits above regular category budgets for comprehensive financial oversight.
- **Budget Tracking:** Set monthly limits per category with real-time progress bars.
- **Visual Insights:** Beautifully rendered charts for category breakdowns and balance history.
- **Overspend Alerts:** Visual indicators when you're nearing or exceeding your limits.

### 🔔 Smart Reminders & Widgets
- **Daily Reminders:** Stay consistent with customizable notification reminders.
- **Home Screen Widgets:** View your balance and quick-add expenses directly from your home screen.

### 🔒 Security & Privacy
- **100% Offline:** No cloud, no tracking. Your data never leaves your phone.
- **Biometric Lock:** Secure your financial data with Fingerprint, FaceID, or a custom PIN.
- **Privacy Mode:** Hide sensitive balance amounts with a single tap.

### ⚙️ Power User Tools
- **Export Reports:** Generate professional PDF or Excel reports for your records.
- **Multi-Currency:** Support for over 100+ global currencies.
- **Customizable Profile:** Personalize with your name, email, and profile photo.
- **Demo Mode:** Populate the app with sample data instantly to explore features.

---

## 🛠️ Built With

| Technology | Purpose |
|------------|---------|
| [Flutter](https://flutter.dev) | UI Framework |
| [Riverpod](https://riverpod.dev) | State Management & Code Generation |
| [GoRouter](https://pub.dev/packages/go_router) | Declarative Routing |
| [SQLite / sqflite](https://pub.dev/packages/sqflite) | Local Persistence |
| [FL Chart](https://pub.dev/packages/fl_chart) | Data Visualization |
| [Local Auth](https://pub.dev/packages/local_auth) | Biometric Security |
| [Home Widget](https://pub.dev/packages/home_widget) | Android/iOS Integration |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.5.0`
- Dart SDK `^3.5.0`

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/alyankhan137137-source/unipocket.git
   ```

2. **Navigate into the project root:**
   ```bash
   cd unipocket
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Generate necessary code (Required for Riverpod & Router):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

```
lib/
├── constants/         # App-wide colors, themes, and static strings
├── core/              # Validators, mixins, and core business logic
├── database/          # SQLite helpers and SharedPreferences logic
├── features/          # Feature-based modules (Recurring, Notifications, Profile)
├── models/            # Data entities and JSON serialization
├── providers/         # Riverpod providers for state handling
├── repositories/      # Data access layer abstraction
├── router/            # Navigation configuration (GoRouter)
├── screens/           # Main UI views (Home, Analytics, Settings, etc.)
├── utils/             # Helper classes (PDF/Excel generators, formatters)
└── widgets/           # Shared UI components
```

---

## 👨‍💻 Developer

**Alyan Khan**
- GitHub: [@alyankhan137137-source](https://github.com/alyankhan137137-source)

---

## ⭐ Support

If you find this app helpful, please give it a ⭐ on GitHub!

---

*Built with ❤️ for students, by a student.*
