# 💰 UniPocket

> **Your personal finance companion — offline, private, and beautifully simple.**

UniPocket is a fully offline expense and budget tracking app built with **Flutter**. No ads, no cloud sync, no subscriptions. Your financial data stays 100% on your device.

---

## ✨ Features

### 💸 Expense & Allowance Tracking
- Add allowance and expenses in seconds
- 12 built-in student categories (Rent, Groceries, Eating Out, Transport, and more)
- Smart category suggestions based on transaction title
- Duplicate transaction detection
- Edit and delete transactions with swipe gestures
- Undo delete with 3-second snackbar

### 📊 Budget Management
- Set budgets per category
- Real-time budget progress tracking
- Overspend alerts and visual indicators

### 📈 Analytics
- Spending overview (Today / This Month / Allowance)
- Category-wise breakdown
- Balance card with allowance vs expense summary

### 🎨 UI & UX
- Beautiful purple gradient design
- Full **Dark Mode** support
- Eye icon to hide/show balance privately
- Haptic feedback on interactions
- Double tap to clear amount field
- Remembers your last used category
- Smooth animations and transitions
- Onboarding screen for first-time setup

### ⚙️ Settings & Customization
- Multi-currency support (100+ currencies)
- Theme switcher (Light / Dark / System)
- Profile with editable name and email
- PIN lock security
- Budget alert threshold slider
- Demo data generator to try the app instantly
- Export data (PDF & Excel)

### 🔒 Privacy & Security
- 100% offline — no internet required
- Data stored locally using SQLite/SharedPreferences
- Optional PIN protection
- Privacy mode to hide balance

---

## 🛠️ Built With

| Technology | Purpose |
|------------|---------|
| [Flutter](https://flutter.dev) | UI Framework |
| [Dart](https://dart.dev) | Programming Language |
| [Riverpod](https://riverpod.dev) | State Management |
| [Provider](https://pub.dev/packages/provider) | Legacy State |
| [GoRouter](https://pub.dev/packages/go_router) | Navigation |
| [SharedPreferences](https://pub.dev/packages/shared_preferences) | Local Storage (Web) |
| [SQLite / sqflite](https://pub.dev/packages/sqflite) | Local Storage (Mobile) |
| [Google Fonts](https://pub.dev/packages/google_fonts) | Typography |
| [FL Chart](https://pub.dev/packages/fl_chart) | Charts & Graphs |
| [Currency Picker](https://pub.dev/packages/currency_picker) | Currency Selector |
| [Flutter Slidable](https://pub.dev/packages/flutter_slidable) | Swipe Actions |
| [Lottie](https://pub.dev/packages/lottie) | Animations |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.5.0`
- Dart SDK `^3.5.0`
- Android Studio or VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/alyankhan137137-source/unipocket.git

# Navigate into the project
cd unipocket

# Install dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Run on Android device
flutter run
```

---

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| 🌐 Web (Chrome) | ✅ Supported |
| 🤖 Android | ✅ Supported (API 21+) |
| 🍎 iOS | 🔄 Coming Soon |
| 🖥️ Windows | 🔄 Coming Soon |

---

## 📂 Project Structure

```
lib/
├── constants/         # Colors, styles, app constants
├── core/              # Validators, error handling, soft delete
├── database/          # Database helper (SQLite + SharedPreferences)
├── features/          # Feature modules (profile, transactions, recurring, notifications)
├── models/            # Data models (Expense, Budget, Category, Settings)
├── providers/         # State management providers
├── repositories/      # Data repositories
├── router/            # GoRouter navigation setup
├── screens/           # UI screens
│   ├── analytics/     # Analytics & charts
│   ├── auth/          # PIN lock screen
│   ├── budget/        # Budget management
│   ├── expenses/      # Add/edit transactions
│   ├── home/          # Dashboard
│   ├── onboarding/    # First-time setup
│   └── settings/      # App settings
├── utils/             # Utilities (PDF, Excel, Smart Features)
└── widgets/           # Reusable widgets
```

---

## 🤝 Contributing

This is a personal project but contributions are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👨‍💻 Developer

**Alyan Khan**

- GitHub: [@alyankhan137137-source](https://github.com/alyankhan137137-source)

---

## ⭐ Show Your Support

If you like this project, give it a ⭐ on GitHub — it means a lot!

---

*Built with ❤️ using Flutter*
